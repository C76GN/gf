# Flow、Domain 与 Physics

本页聚焦 Flow 扩展的流程图、Physics 扩展的重力场，以及 Domain 扩展的通用领域数据模型。
## 通用流程图 (`GFFlowGraph`)

`GFFlowGraph` / `GFFlowNode` / `GFFlowRunner` 提供资源化流程图执行基础。它只负责节点查找、后继推进、Signal 等待、取消和循环保护；节点具体做什么、如何分支、是否驱动 UI、剧情、任务或教程，仍由项目层通过继承 `GFFlowNode` 决定。

```gdscript
class_name CheckDoorNode
extends GFFlowNode


func execute(context: GFFlowContext) -> Variant:
	if context.get_value(&"has_key", false):
		context.set_next_nodes(PackedStringArray(["open"]))
	else:
		context.set_next_nodes(PackedStringArray(["locked"]))
	return null
```

```gdscript
var graph := GFFlowGraph.new()
graph.start_node_id = &"check_door"
graph.nodes = [
	CheckDoorNode.new(),
	OpenDoorNode.new(),
	ShowLockedHintNode.new(),
]

var runner := GFFlowRunner.new()
runner.run(graph, GFFlowContext.new(Gf.architecture, { &"has_key": true }))
```

`GFFlowPort` 可为节点声明输入/输出端口、值类型提示和自定义元数据；`GFFlowGraph.connections` 可描述节点级或端口级连接，`validate_graph()` 可提前检查缺失后继节点、重复节点 ID、端口 ID、连接端点和单连接端口约束。`GFFlowPort` 还提供 `editor_color`、`type_hint`、`class_name_hint` 和 `semantic_tags`，供编辑器颜色、搜索过滤、类名提示和项目工具索引使用；这些字段默认不影响运行时执行。`start_node_id` 为空时运行器会跳过执行，适合由项目层手动选择起始节点；正式资源应把起点设为已有节点。流程图适合做“可配置流程编排”的底座，但 GF 不提供业务节点库。项目可以把命令、交互、UI 动画、等待条件等封装为自己的节点资源。

```gdscript
graph.add_connection(&"check_door", &"", &"open", &"")
graph.add_connection(&"check_door", &"", &"locked", &"")
```

`GFFlowGraph` 默认启用 `validate_port_compatibility`，会使用端口的 `value_type` 和 Object 端口的 `class_name_hint` 检查端口级连接，避免编辑器或导入流程把明显不兼容的数据线写入资源。迁移旧资源时可以临时关闭该属性；需要独立检查时，可调用 `check_connection_compatibility()` 或 `get_connection_compatibility_report()`，再由项目决定是阻止保存、显示警告还是只作为提示。

`validate_graph()` 还会输出通用拓扑诊断：`warn_unreachable_nodes` 默认提示从 `start_node_id` 无法到达的节点，`warn_cycles` 默认提示循环结构，`warn_terminal_nodes` 可显式开启以提示无后继节点。这些诊断只作为 warning，不假设循环或终端节点一定错误；项目可以在编辑器、导入流程或 CI 中按自己的资源规范决定是否把某类 warning 提升为错误。

节点可以填写 `display_name`、`category`、`editor_position`、`editor_size` 和 `editor_collapsed`，这些字段只服务编辑器、搜索和可视化工具，不影响运行时执行。`get_editor_catalog()` 会按分类输出节点、端口和编辑器元数据，`build_editor_report()` 会组合目录、校验摘要和 `next_action`，适合项目自己的 GraphEdit 面板或导出工具消费。`GFFlowGraphEditorModel` 进一步把节点、端口索引、GraphEdit slot、连接端口索引、分组和校验结果整理成视图模型，并提供 `auto_layout()` 复用 `GFGraphLayoutUtility` 写入初始节点位置。项目工具还可以用 `build_selection_package()`、`paste_selection_package()` 和 `remove_nodes()` 实现复制、粘贴、删除或批量改图，而不要求使用 GF 内置 UI。启用 GF 插件后，选中 `GFFlowGraph` 资源时 Inspector 会提供起始节点选择和校验摘要；GF 工作区中的 `GFFlowGraphDock` 可以加载流程图资源，在独立 GF 工作区窗口中以 GraphEdit 查看节点、拖动位置、建立或移除通用连接、查看节点/连接/问题清单，并显式触发通用自动布局。这个面板只操作通用编辑器元数据，不提供业务节点库，也不替项目决定流程含义。

运行器优先使用节点或上下文提供的后继列表；当节点没有默认后继、上下文也没有显式覆盖时，才会回退到 `connections`。如果节点需要明确停止，可调用 `context.set_next_nodes(PackedStringArray())`。节点 `wait_for_result` 且 `execute()` 返回 Signal 时，`GFFlowRunner` 会安全等待发射源或节点离树，并使用 `with_signal_timeout(seconds, respect_time_scale)` 控制等待上限；默认超时同样跟随 `GFTimeUtility` 的暂停与 `time_scale`。等待期间调用 `cancel()` 后，运行器会停止在当前等待点，不再发送当前节点完成事件或推进后继节点。如果自定义节点在 `execute()` 内部自行 await 且永不返回，运行器无法替它取消这段内部逻辑，项目层应把等待对象作为 Signal 返回。

`GFFlowContext` 可注册条件查询处理器：`register_condition_handler(condition_id, handler)` 接收一个通用 `Callable`，`query_condition()` 会把返回值归一化为 `ok`、`value`、`reason` 和 `metadata`。这适合把“某个条件如何判断”留在项目层，同时让节点、导入器或编辑器工具使用同一套查询结果结构。`GFFlowNode.runtime_state` 提供不导出的节点运行态字典，`GFFlowGraph.serialize_runtime_state()` / `deserialize_runtime_state()` 可保存和恢复图内节点状态；需要从资源创建运行副本时，优先使用 `instantiate_graph()`，默认会清空运行态，避免编辑器资源被运行时临时数据污染。

`GFFlowGraph.metadata_schema` 是轻量元数据约束，支持 `required`、`type`、`class_name`、`allow_null` 和 `allowed_values` 这类通用规则。`validate_graph_metadata()` 只校验 `editor_metadata` 的结构，不解释字段业务含义；项目可以把它接到导入、保存前检查或自定义编辑器提示中。

---


## 通用 3D 重力场 (`GFGravityField3D` / `GFGravityProbe3D`)

`GFGravityField3D` 提供通用加速度场：可以朝向节点原点、远离原点或使用固定方向，并支持常量、线性、平方反比和曲线衰减。它适合需要局部重力、行星引力、磁力、推斥场、风场或任何“按位置采样一个加速度向量”的 3D 项目，但不直接修改角色控制器、RigidBody 或相机。

```gdscript
var field := GFGravityField3D.new()
field.direction_mode = GFGravityField3D.DirectionMode.TOWARD_ORIGIN
field.acceleration = 12.0
field.radius = 20.0
field.falloff_mode = GFGravityField3D.FalloffMode.LINEAR
add_child(field)
```

`GFGravityProbe3D` 会从指定场景树分组采样所有暴露 `get_acceleration_at(world_position)` 的对象，并汇总当前位置的加速度、上方向和下方向：

```gdscript
var probe := GFGravityProbe3D.new()
add_child(probe)

func _physics_process(delta: float) -> void:
	var acceleration := probe.sample()
	velocity += acceleration * delta
	up_direction = probe.get_up_direction()
```

默认分组是 `gf_gravity_field_3d`，`GFGravityField3D` 进树时会自动加入。项目可以继承 `GFGravityField3D` 重写 `_get_direction_at(world_position)`，或提供自己的对象加入同一分组，只要实现 `get_acceleration_at()` 即可被采样。GF 层只提供采样和方向计算，不接管运动积分、碰撞响应、角色朝向、网络同步或具体玩法规则。

---


## 通用领域数据模型 (`GFInventoryModel` / `GFAttributeSet` / `GFTraitSet` / `GFEquipmentSet`)

这些类只提供通用数据结构，不内置任何具体玩法：

- `GFInventoryModel`：按 `item_id` 管理数量和元数据，支持 `to_dict()` / `from_dict()`。
- `GFInventoryItemDefinition` / `GFInventoryItemRegistry`：资源化描述物品堆叠容量、最大堆叠数量、分类标签和实例数据兼容规则。
- `GFInventoryStack` / `GFSlotInventoryModel`：管理固定或可增长槽位中的堆叠，支持 partial add/remove、移动、合并、交换、容量查询、索引查询、注册表约束校验和序列化。
- `GFInventoryOperationResult`：统一描述添加、移除、移动等操作的请求数量、接受数量、剩余数量和原因。
- `GFAttributeSet`：按 `attribute_id` 管理基础值、当前值、上下限和元数据，支持快照恢复、派生属性规则，并可选择接入 `GFTraitSet` 计算修饰后数值。
- `GFDerivedAttributeRule`：描述一个目标属性如何由其他属性按权重或回调派生，适合把“最大值、评分、容量、派生速度”等通用依赖关系留在数据层。
- `GFTraitSet`：按 `target_id` 和可选 `category` 收集数值特征，并按优先级合并。
- `GFEquipmentSet`：管理一组 `GFEquipmentSlot`，通过标签判断某个 `item_id` 是否可挂载。

```gdscript
var inventory := GFInventoryModel.new()
inventory.add_item(&"item_a", 3, { "source": "runtime" })

var traits := GFTraitSet.new()
var bonus := GFTrait.new()
bonus.target_id = &"speed"
bonus.value = 2.0
traits.add_trait(bonus)

var attributes := GFAttributeSet.new()
attributes.define_attribute(&"speed", 10.0, 10.0, 0.0, 99.0)
var speed := attributes.get_value_with_traits(&"speed", traits)

var power_rule := GFDerivedAttributeRule.new()
power_rule.attribute_id = &"power"
power_rule.source_attribute_ids = [&"speed"]
power_rule.source_weights = { &"speed": 2.0 }
attributes.add_derived_rule(power_rule)

var equipment := GFEquipmentSet.new()
var weapon_slot := GFEquipmentSlot.new()
weapon_slot.slot_id = &"weapon"
weapon_slot.accepted_tags = [&"weapon"]
equipment.set_slot(weapon_slot)
equipment.equip(&"weapon", &"iron_sword", [&"weapon"])
```

`GFDerivedAttributeRule` 默认使用 `source_attribute_ids` 和 `source_weights` 做线性组合，再加上 `flat_bonus` 并按规则上下限钳制；需要更复杂的项目公式时，可以设置 `compute_callback`。`GFAttributeSet` 会在来源属性当前值、基础值或上下限变化后重算依赖它的规则，并用循环保护避免派生属性互相递归。规则只描述数值依赖，不规定属性名称含义；存档快照仍只保存属性记录，派生规则应作为配置或资源由项目层加载。

需要背包、格子 UI、带实例数据的物品或部分加入/移除时，不要把复杂度塞进轻量 `GFInventoryModel`，而是新增一个 `GFSlotInventoryModel`：

```gdscript
var definition := GFInventoryItemDefinition.new()
definition.item_id = &"item_a"
definition.max_stack_amount = 20
definition.stack_key_fields = PackedStringArray(["variant"])

var registry := GFInventoryItemRegistry.new()
registry.set_definition(definition)

var slots := GFSlotInventoryModel.new()
slots.registry = registry
slots.set_slot_count(24)

var result := slots.add_item(&"item_a", 35, { "variant": "basic" })
print(result.accepted_amount, result.remaining_amount)
```

`GFSlotInventoryModel.get_slots_for_item()` 会维护物品到槽位的惰性索引，适合 UI 局部刷新或规则查询；`validate_inventory()` 和 `apply_registry_constraints()` 可检查或修复注册表约束，例如未注册物品、单堆叠超量或堆叠数量超限。默认实例数据比较仍由 `stack_key_fields` 控制；需要更特殊的合并规则时，可给 `GFInventoryItemDefinition.compatibility_checker` 传入项目层回调，但 GF 不保存该回调到字典数据中。

这些模型适合放在项目自己的 `Model` 或资源配置中，具体物品含义、标签体系和结算规则仍由项目层定义。
