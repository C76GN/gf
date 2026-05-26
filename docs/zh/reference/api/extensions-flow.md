# Flow API

Module: `extensions/flow`

## Classes

- [`GFFlowContext`](#gfflowcontext)
- [`GFFlowGraph`](#gfflowgraph)
- [`GFFlowGraphDock`](#gfflowgraphdock)
- [`GFFlowGraphEditorModel`](#gfflowgrapheditormodel)
- [`GFFlowNode`](#gfflownode)
- [`GFFlowPort`](#gfflowport)
- [`GFFlowRunner`](#gfflowrunner)

## GFFlowContext

- Path: `addons/gf/extensions/flow/runtime/gf_flow_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFFlowContext: 通用流程图执行上下文。 用于在流程节点之间共享数据，并提供可选的 GFArchitecture 访问入口。

### Properties

#### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

共享数据表。

Schemas:

- `values`: 流程执行期间共享的项目自定义 Dictionary；键通常为 StringName，值由项目决定。

#### `next_node_ids`

- API: `public`

```gdscript
var next_node_ids: PackedStringArray = PackedStringArray()
```

下一个节点覆盖。流程节点可写入该列表动态控制分支。

#### `has_next_node_override`

- API: `public`

```gdscript
var has_next_node_override: bool = false
```

是否显式覆盖了下一个节点。允许节点用空列表表达“停止继续推进”。

### Methods

#### `set_architecture`

- API: `public`

```gdscript
func set_architecture(architecture: GFArchitecture) -> void:
```

设置上下文所属架构。

Parameters:

| Name | Description |
|---|---|
| `architecture` | 架构实例。 |

#### `get_architecture`

- API: `public`

```gdscript
func get_architecture() -> GFArchitecture:
```

获取上下文所属架构。

Returns: 架构实例；不可用时返回 null。

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> GFFlowContext:
```

写入共享值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `value` | 值。 |

Returns: 当前上下文，便于链式构造。

Schemas:

- `value`: 要写入 values 的任意项目值。

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取共享值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `default_value` | 默认值。 |

Returns: 共享值或默认值。

Schemas:

- `default_value`: key 缺失时返回的任意默认值。
- `return`: values 中的项目值，或传入的 default_value。

#### `set_next_nodes`

- API: `public`

```gdscript
func set_next_nodes(node_ids: PackedStringArray) -> void:
```

覆盖当前节点执行后的下一个节点列表。

Parameters:

| Name | Description |
|---|---|
| `node_ids` | 节点标识列表。 |

#### `has_next_nodes_override`

- API: `public`

```gdscript
func has_next_nodes_override() -> bool:
```

检查当前节点是否显式覆盖了后继节点。

Returns: 已覆盖返回 true。

#### `clear_next_nodes`

- API: `public`

```gdscript
func clear_next_nodes() -> void:
```

清空下一个节点覆盖。

#### `register_condition_handler`

- API: `public`

```gdscript
func register_condition_handler(condition_id: StringName, handler: Callable) -> bool:
```

注册条件查询处理器。

Parameters:

| Name | Description |
|---|---|
| `condition_id` | 条件标识。 |
| `handler` | 查询回调，建议签名为 func(condition_id: StringName, payload: Variant, context: GFFlowContext) -> Variant。 |

Returns: 注册成功返回 true。

#### `unregister_condition_handler`

- API: `public`

```gdscript
func unregister_condition_handler(condition_id: StringName) -> void:
```

注销条件查询处理器。

Parameters:

| Name | Description |
|---|---|
| `condition_id` | 条件标识。 |

#### `has_condition_handler`

- API: `public`

```gdscript
func has_condition_handler(condition_id: StringName) -> bool:
```

检查条件查询处理器是否存在。

Parameters:

| Name | Description |
|---|---|
| `condition_id` | 条件标识。 |

Returns: 存在返回 true。

#### `clear_condition_handlers`

- API: `public`

```gdscript
func clear_condition_handlers() -> void:
```

清空所有条件查询处理器。

#### `query_condition`

- API: `public`

```gdscript
func query_condition( condition_id: StringName, payload: Variant = null, default_value: Variant = false ) -> Dictionary:
```

查询条件值。

Parameters:

| Name | Description |
|---|---|
| `condition_id` | 条件标识。 |
| `payload` | 调用方传入的载荷。 |
| `default_value` | 缺失处理器或处理器未返回值时使用的默认值。 |

Returns: 统一条件查询结果。

Schemas:

- `payload`: 条件处理器接收的任意项目载荷；框架只透传。
- `default_value`: 缺失处理器或处理器未返回值时使用的任意默认值。
- `return`: 包含 ok、condition_id、value、reason 和 metadata 字段的 Dictionary。

#### `set_node_runtime_value`

- API: `public`

```gdscript
func set_node_runtime_value(node_id: StringName, key: StringName, value: Variant) -> void:
```

写入指定流程节点的运行态值。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `key` | 运行态键。 |
| `value` | 运行态值。 |

Schemas:

- `value`: 要写入指定节点运行态的任意项目值。

#### `get_node_runtime_value`

- API: `public`

```gdscript
func get_node_runtime_value(node_id: StringName, key: StringName, default_value: Variant = null) -> Variant:
```

读取指定流程节点的运行态值。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `key` | 运行态键。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 运行态值或默认值。

Schemas:

- `default_value`: 运行态缺失时返回的任意默认值。
- `return`: 节点运行态中的项目值，或传入的 default_value。

#### `clear_node_runtime_state`

- API: `public`

```gdscript
func clear_node_runtime_state(node_id: StringName = &"") -> void:
```

清空节点运行态。node_id 为空时清空全部节点运行态。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |

#### `serialize_runtime_state`

- API: `public`

```gdscript
func serialize_runtime_state() -> Dictionary:
```

序列化上下文持有的节点运行态。

Returns: 运行态快照。

Schemas:

- `return`: 包含 nodes 字段的 Dictionary；nodes 按 node_id 保存节点运行态 Dictionary。

#### `deserialize_runtime_state`

- API: `public`

```gdscript
func deserialize_runtime_state(data: Dictionary) -> void:
```

反序列化节点运行态到当前上下文。

Parameters:

| Name | Description |
|---|---|
| `data` | 运行态快照。 |

Schemas:

- `data`: serialize_runtime_state() 返回的运行态 Dictionary。

## GFFlowGraph

- Path: `addons/gf/extensions/flow/resources/gf_flow_graph.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFFlowGraph: 资源化通用流程图。 只维护节点集合与起始节点，不规定具体编辑器表现或业务语义。

### Properties

#### `start_node_id`

- API: `public`

```gdscript
var start_node_id: StringName = &""
```

起始节点标识。

#### `nodes`

- API: `public`

```gdscript
var nodes: Array[GFFlowNode] = []
```

流程节点列表。

#### `connections`

- API: `public`

```gdscript
var connections: Array[Dictionary] = []
```

节点连接列表。连接结构为 from_node_id/from_port_id/to_node_id/to_port_id/metadata。

Schemas:

- `connections`: 连接字典数组；每项包含 from_node_id、from_port_id、to_node_id、to_port_id 和 metadata 字段。

#### `validate_port_compatibility`

- API: `public`

```gdscript
var validate_port_compatibility: bool = true
```

校验时是否把端口值类型和类名提示不兼容视为错误。

#### `warn_unreachable_nodes`

- API: `public`

```gdscript
var warn_unreachable_nodes: bool = true
```

校验时是否提示从 start_node_id 无法到达的节点。

#### `warn_cycles`

- API: `public`

```gdscript
var warn_cycles: bool = true
```

校验时是否提示图中的循环。

#### `warn_terminal_nodes`

- API: `public`

```gdscript
var warn_terminal_nodes: bool = false
```

校验时是否提示没有后继的终端节点。默认关闭，避免把正常结束节点视为问题。

#### `editor_groups`

- API: `public`

```gdscript
var editor_groups: Array[Dictionary] = []
```

编辑器分组数据。结构由编辑器工具解释，运行时不读取。

Schemas:

- `editor_groups`: 编辑器分组字典数组；字段由 FlowGraph 编辑器或项目工具解释。

#### `editor_metadata`

- API: `public`

```gdscript
var editor_metadata: Dictionary = {}
```

编辑器或项目工具的附加元数据。

Schemas:

- `editor_metadata`: 编辑器或项目工具自定义元数据 Dictionary；运行时不解释其中键值。

#### `metadata_schema`

- API: `public`

```gdscript
var metadata_schema: Dictionary = {}
```

编辑器或项目工具元数据的轻量 Schema。框架只校验结构，不解释业务含义。

Schemas:

- `metadata_schema`: 轻量元数据校验规则 Dictionary；键为元数据 key，值为包含 required、allow_null、type、class_name、allowed_values 等字段的规则字典。

### Methods

#### `set_node`

- API: `public`

```gdscript
func set_node(node: GFFlowNode) -> void:
```

设置或替换一个节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 流程节点。 |

#### `get_node`

- API: `public`

```gdscript
func get_node(node_id: StringName) -> GFFlowNode:
```

获取节点。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |

Returns: 流程节点；不存在时返回 null。

#### `has_node`

- API: `public`

```gdscript
func has_node(node_id: StringName) -> bool:
```

检查节点是否存在。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |

Returns: 存在返回 true。

#### `remove_node`

- API: `public`

```gdscript
func remove_node(node_id: StringName) -> void:
```

移除节点。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |

#### `add_connection`

- API: `public`

```gdscript
func add_connection( from_node_id: StringName, from_port_id: StringName, to_node_id: StringName, to_port_id: StringName, metadata: Dictionary = {} ) -> bool:
```

添加节点连接。

Parameters:

| Name | Description |
|---|---|
| `from_node_id` | 来源节点。 |
| `from_port_id` | 来源端口；为空时表示节点级执行连接。 |
| `to_node_id` | 目标节点。 |
| `to_port_id` | 目标端口；为空时表示节点级执行连接。 |
| `metadata` | 项目自定义元数据。 |

Returns: 添加成功返回 true。

Schemas:

- `metadata`: 连接自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

#### `remove_connection`

- API: `public`

```gdscript
func remove_connection( from_node_id: StringName, from_port_id: StringName, to_node_id: StringName, to_port_id: StringName ) -> bool:
```

移除指定节点连接。

Parameters:

| Name | Description |
|---|---|
| `from_node_id` | 连接起点节点标识。 |
| `from_port_id` | 连接起点端口标识。 |
| `to_node_id` | 目标标识。 |
| `to_port_id` | 目标标识。 |

Returns: 移除成功返回 true。

#### `remove_connections_for_node`

- API: `public`

```gdscript
func remove_connections_for_node(node_id: StringName) -> void:
```

移除与指定节点相关的所有连接。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |

#### `has_connection`

- API: `public`

```gdscript
func has_connection( from_node_id: StringName, from_port_id: StringName, to_node_id: StringName, to_port_id: StringName ) -> bool:
```

检查连接是否存在。

Parameters:

| Name | Description |
|---|---|
| `from_node_id` | 连接起点节点标识。 |
| `from_port_id` | 连接起点端口标识。 |
| `to_node_id` | 目标标识。 |
| `to_port_id` | 目标标识。 |

Returns: 存在返回 true。

#### `get_connections_from`

- API: `public`

```gdscript
func get_connections_from(node_id: StringName, port_id: StringName = &"") -> Array[Dictionary]:
```

获取从指定节点或端口发出的连接。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `port_id` | 端口标识；为空时返回该节点所有输出连接。 |

Returns: 连接副本列表。

Schemas:

- `return`: 连接字典数组；每项包含 from_node_id、from_port_id、to_node_id、to_port_id 和 metadata 字段。

#### `get_connections_to`

- API: `public`

```gdscript
func get_connections_to(node_id: StringName, port_id: StringName = &"") -> Array[Dictionary]:
```

获取指向指定节点或端口的连接。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `port_id` | 端口标识；为空时返回该节点所有输入连接。 |

Returns: 连接副本列表。

Schemas:

- `return`: 连接字典数组；每项包含 from_node_id、from_port_id、to_node_id、to_port_id 和 metadata 字段。

#### `get_connected_node_ids_from`

- API: `public`

```gdscript
func get_connected_node_ids_from(node_id: StringName, port_id: StringName = &"") -> PackedStringArray:
```

获取指定节点或端口连接到的目标节点。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `port_id` | 端口标识；为空时返回该节点所有输出目标。 |

Returns: 目标节点标识列表。

#### `check_connection_compatibility`

- API: `public`

```gdscript
func check_connection_compatibility( from_node_id: StringName, from_port_id: StringName, to_node_id: StringName, to_port_id: StringName ) -> Dictionary:
```

检查指定连接端口的兼容性。

Parameters:

| Name | Description |
|---|---|
| `from_node_id` | 来源节点。 |
| `from_port_id` | 来源端口。 |
| `to_node_id` | 目标节点。 |
| `to_port_id` | 目标端口。 |

Returns: 兼容性报告。

Schemas:

- `return`: 包含 ok、reason、message、from_node_id、from_port_id、to_node_id 和 to_port_id 等字段的 Dictionary。

#### `get_connection_compatibility_report`

- API: `public`

```gdscript
func get_connection_compatibility_report() -> Array[Dictionary]:
```

获取所有连接的兼容性报告。

Returns: 兼容性报告列表。

Schemas:

- `return`: 兼容性报告字典数组；每项结构同 check_connection_compatibility() 返回值。

#### `set_node_editor_position`

- API: `public`

```gdscript
func set_node_editor_position(node_id: StringName, position: Vector2) -> bool:
```

设置节点编辑器位置。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `position` | 编辑器坐标。 |

Returns: 设置成功返回 true。

#### `set_node_editor_layout`

- API: `public`

```gdscript
func set_node_editor_layout( node_id: StringName, position: Vector2, size: Vector2 = Vector2.ZERO, collapsed: bool = false ) -> bool:
```

设置节点编辑器布局。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点标识。 |
| `position` | 编辑器坐标。 |
| `size` | 编辑器尺寸；Vector2.ZERO 表示由编辑器自行决定。 |
| `collapsed` | 是否折叠显示。 |

Returns: 设置成功返回 true。

#### `get_editor_catalog`

- API: `public`

```gdscript
func get_editor_catalog() -> Dictionary:
```

获取编辑器或可视化工具可消费的节点目录。

Returns: 节点目录字典。

Schemas:

- `return`: 包含 node_count、nodes 和 categories 字段的 Dictionary；nodes 为节点目录条目数组，categories 按分类名分组。

#### `describe_graph`

- API: `public`

```gdscript
func describe_graph() -> Dictionary:
```

描述流程图结构。

Returns: 图描述字典。

Schemas:

- `return`: 包含 start_node_id、node_count、nodes、connection_count、connections、validate_port_compatibility、diagnostics 和 editor 字段的 Dictionary。

#### `instantiate_graph`

- API: `public`

```gdscript
func instantiate_graph(options: Dictionary = {}) -> GFFlowGraph:
```

创建可运行的流程图副本。

Parameters:

| Name | Description |
|---|---|
| `options` | 可选参数，支持 clear_runtime_state。 |

Returns: 流程图副本；复制失败时返回 null。

Schemas:

- `options`: 可选项 Dictionary；支持 clear_runtime_state: bool。

#### `serialize_runtime_state`

- API: `public`

```gdscript
func serialize_runtime_state() -> Dictionary:
```

序列化图内节点运行态。

Returns: 运行态快照。

Schemas:

- `return`: 包含 nodes 字段的 Dictionary；nodes 按 node_id 保存节点运行态 Dictionary。

#### `deserialize_runtime_state`

- API: `public`

```gdscript
func deserialize_runtime_state(data: Dictionary) -> void:
```

反序列化图内节点运行态。

Parameters:

| Name | Description |
|---|---|
| `data` | 运行态快照。 |

Schemas:

- `data`: serialize_runtime_state() 返回的运行态快照 Dictionary。

#### `clear_runtime_state`

- API: `public`

```gdscript
func clear_runtime_state() -> void:
```

清空图内所有节点运行态。

#### `validate_metadata`

- API: `public`

```gdscript
func validate_metadata(target_metadata: Dictionary, schema: Dictionary = {}) -> Dictionary:
```

校验元数据是否符合轻量 Schema。

Parameters:

| Name | Description |
|---|---|
| `target_metadata` | 待校验元数据。 |
| `schema` | 可选 Schema；为空时使用 metadata_schema。 |

Returns: 校验报告。

Schemas:

- `target_metadata`: 待校验的元数据 Dictionary。
- `schema`: 可选轻量 Schema Dictionary；为空时使用 metadata_schema。
- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action、error_count 和 warning_count 等字段。

#### `validate_graph_metadata`

- API: `public`

```gdscript
func validate_graph_metadata() -> Dictionary:
```

校验当前图编辑器元数据。

Returns: 校验报告。

Schemas:

- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action、error_count 和 warning_count 等字段。

#### `validate_graph`

- API: `public`

```gdscript
func validate_graph() -> Dictionary:
```

校验流程图结构。

Returns: 校验报告。

Schemas:

- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、node_count、connection_count、summary、issues 和 next_action 等字段。

#### `build_editor_report`

- API: `public`

```gdscript
func build_editor_report() -> Dictionary:
```

构建面向编辑器和可视化工具的流程图报告。

Returns: 包含校验、目录和编辑器元数据的报告。

Schemas:

- `return`: 包含 ok、healthy、summary、next_action、validation、catalog 和 editor 字段的 Dictionary。

## GFFlowGraphDock

- Path: `addons/gf/extensions/flow/editor/gf_flow_graph_dock.gd`
- Extends: `Control`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFFlowGraphDock: FlowGraph 图形化编辑与结构检查工作区页面。 为资源化流程图提供路径加载、GraphEdit 预览/连线、校验摘要、节点/连接清单 和通用自动布局，不提供业务节点库，也不解释项目自定义元数据。

### Methods

#### `set_graph`

- API: `public`

```gdscript
func set_graph(graph: GFFlowGraph, path: String = "") -> void:
```

设置当前查看的 FlowGraph。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `path` | 可选资源路径。 |

#### `set_graph_path`

- API: `public`

```gdscript
func set_graph_path(path: String) -> void:
```

设置并加载当前 FlowGraph 资源路径。

Parameters:

| Name | Description |
|---|---|
| `path` | `res://` 资源路径。 |

#### `refresh`

- API: `public`

```gdscript
func refresh() -> void:
```

刷新当前 FlowGraph 视图。

#### `get_last_view_model`

- API: `public`

```gdscript
func get_last_view_model() -> Dictionary:
```

获取最近一次 FlowGraph 视图模型。

Returns: 视图模型字典副本。

Schemas:

- `return`: Dictionary，由 GFFlowGraphEditorModel.build_view_model() 生成的视图模型副本。

## GFFlowGraphEditorModel

- Path: `addons/gf/extensions/flow/editor/gf_flow_graph_editor_model.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFFlowGraphEditorModel: FlowGraph 编辑器视图模型构建器。 将 GFFlowGraph 转换为 GraphEdit、自定义编辑器或项目工具可直接消费的 节点、端口、连接和校验结构。它只整理数据，不绑定具体 UI 实现。

### Properties

#### `default_node_size`

- API: `public`

```gdscript
var default_node_size: Vector2 = Vector2(220.0, 120.0)
```

节点未显式设置尺寸时使用的默认编辑器尺寸。

#### `include_invalid_connections`

- API: `public`

```gdscript
var include_invalid_connections: bool = true
```

是否把校验失败的连接也写入视图模型。

### Methods

#### `build_view_model`

- API: `public`

```gdscript
func build_view_model(graph: Resource) -> Dictionary:
```

构建流程图编辑器视图模型。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |

Returns: 视图模型字典。

Schemas:

- `return`: Dictionary，包含 ok、start_node_id、node_count、connection_count、nodes、node_lookup、connections、groups、metadata、validation。

#### `build_editor_report`

- API: `public`

```gdscript
func build_editor_report(graph: Resource) -> Dictionary:
```

构建 FlowGraph 编辑器报告。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |

Returns: 编辑器诊断、目录和元数据报告。

Schemas:

- `return`: Dictionary，包含 ok、healthy、summary、next_action、validation、catalog 和 editor。

#### `build_editor_catalog`

- API: `public`

```gdscript
func build_editor_catalog(graph: Resource) -> Dictionary:
```

获取编辑器可消费的节点目录，不调用节点/端口脚本方法。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |

Returns: 节点目录字典。

Schemas:

- `return`: Dictionary，包含 node_count、nodes 和 categories；nodes 为节点目录记录数组。

#### `validate_graph_for_editor`

- API: `public`

```gdscript
func validate_graph_for_editor(graph: Resource) -> Dictionary:
```

校验 FlowGraph 结构，不调用项目节点/端口脚本方法。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |

Returns: 校验报告。

Schemas:

- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action 和计数字段。

#### `validate_metadata_for_editor`

- API: `public`

```gdscript
func validate_metadata_for_editor(target_metadata: Dictionary, schema: Dictionary = {}) -> Dictionary:
```

校验编辑器元数据。

Parameters:

| Name | Description |
|---|---|
| `target_metadata` | 待校验元数据。 |
| `schema` | 轻量 Schema。 |

Returns: 校验报告。

Schemas:

- `target_metadata`: Dictionary，待校验的编辑器或项目工具元数据。
- `schema`: Dictionary，键为元数据 key，值为包含 required、allow_null、type、class_name、allowed_values 等字段的规则字典。
- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action 和计数字段。

#### `apply_node_layout`

- API: `public`

```gdscript
func apply_node_layout( graph: GFFlowGraph, node_id: StringName, position: Vector2, size: Vector2 = Vector2.ZERO, collapsed: bool = false ) -> bool:
```

应用单个节点布局。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `node_id` | 节点标识。 |
| `position` | 编辑器坐标。 |
| `size` | 编辑器尺寸；Vector2.ZERO 表示使用默认尺寸。 |
| `collapsed` | 是否折叠。 |

Returns: 应用成功返回 true。

#### `apply_node_positions`

- API: `public`

```gdscript
func apply_node_positions(graph: GFFlowGraph, positions: Dictionary) -> int:
```

批量应用节点位置。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `positions` | node_id 到 Vector2 的映射。 |

Returns: 成功更新的节点数量。

Schemas:

- `positions`: Dictionary，键为节点标识，值为 Vector2 编辑器坐标。

#### `auto_layout`

- API: `public`

```gdscript
func auto_layout(graph: GFFlowGraph, options: Dictionary = {}) -> Dictionary:
```

自动生成并应用节点布局。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `options` | 布局选项，透传给 GFGraphLayoutUtility.make_layered_layout()。 |

Returns: 布局报告，包含 positions 与 changed_count。

Schemas:

- `options`: Dictionary，传给 GFGraphLayoutUtility.make_layered_layout() 的布局选项。
- `return`: Dictionary，包含 ok、positions、changed_count，失败时包含 error。

#### `build_selection_package`

- API: `public`

```gdscript
func build_selection_package(graph: GFFlowGraph, node_ids: PackedStringArray) -> Dictionary:
```

构建节点选择包，用于编辑器复制、剪切或跨工具传递。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `node_ids` | 选中的节点标识列表。 |

Returns: 选择包字典。

Schemas:

- `return`: Dictionary，包含 ok、node_count、connection_count、nodes、connections 和 node_ids。

#### `paste_selection_package`

- API: `public`

```gdscript
func paste_selection_package( graph: GFFlowGraph, selection_package: Dictionary, offset: Vector2 = Vector2.ZERO, options: Dictionary = {} ) -> Dictionary:
```

将选择包粘贴到流程图。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `selection_package` | build_selection_package() 返回的选择包。 |
| `offset` | 粘贴时叠加到节点编辑器位置的偏移。 |
| `options` | 可选参数，支持 keep_original_ids。 |

Returns: 粘贴报告。

Schemas:

- `selection_package`: Dictionary，由 build_selection_package() 返回，包含 nodes、connections 和 node_ids。
- `options`: Dictionary，可包含 keep_original_ids。
- `return`: Dictionary，包含 ok、added_node_ids、added_node_count、added_connection_count、failed_connection_count 和 id_map。

#### `remove_nodes`

- API: `public`

```gdscript
func remove_nodes(graph: GFFlowGraph, node_ids: PackedStringArray) -> Dictionary:
```

从流程图移除一组节点及其相关连接。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `node_ids` | 节点标识列表。 |

Returns: 移除报告。

Schemas:

- `return`: Dictionary，包含 ok、removed_node_ids、removed_node_count 和 connection_count。

## GFFlowNode

- Path: `addons/gf/extensions/flow/resources/gf_flow_node.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFFlowNode: 通用流程图节点基类。 节点只描述执行入口和默认后继节点。具体条件、命令、等待逻辑由项目继承实现。

### Properties

#### `node_id`

- API: `public`

```gdscript
var node_id: StringName = &""
```

节点稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

节点显示名；为空时回退到 node_id。

#### `category`

- API: `public`

```gdscript
var category: StringName = &""
```

节点分类，仅供编辑器、搜索或项目工具使用。

#### `next_node_ids`

- API: `public`

```gdscript
var next_node_ids: PackedStringArray = PackedStringArray()
```

默认后继节点列表。

#### `wait_for_result`

- API: `public`

```gdscript
var wait_for_result: bool = true
```

返回 Signal 时是否等待。

#### `input_ports`

- API: `public`

```gdscript
var input_ports: Array[GFFlowPort] = []
```

输入端口描述。仅用于编辑器、校验和项目层数据连接。

#### `output_ports`

- API: `public`

```gdscript
var output_ports: Array[GFFlowPort] = []
```

输出端口描述。仅用于编辑器、校验和项目层数据连接。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

#### `editor_position`

- API: `public`

```gdscript
var editor_position: Vector2 = Vector2.ZERO
```

编辑器中的节点位置。

#### `editor_size`

- API: `public`

```gdscript
var editor_size: Vector2 = Vector2.ZERO
```

编辑器中的节点尺寸；为 ZERO 时表示由编辑器自行决定。

#### `editor_collapsed`

- API: `public`

```gdscript
var editor_collapsed: bool = false
```

编辑器中是否折叠显示。

#### `runtime_state`

- API: `public`

```gdscript
var runtime_state: Dictionary = {}
```

节点运行态数据。默认不导出，项目可通过序列化接口自行存档或迁移。

Schemas:

- `runtime_state`: 项目自定义运行态 Dictionary；键和值由节点实现维护。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute(_context: GFFlowContext) -> Variant:
```

执行节点。

Parameters:

| Name | Description |
|---|---|
| `_context` | 流程上下文。 |

Returns: 可返回 null 或 Signal。

Schemas:

- `return`: null、Signal 或项目节点实现约定的结果值。

#### `get_next_nodes`

- API: `public`

```gdscript
func get_next_nodes(context: GFFlowContext) -> PackedStringArray:
```

获取执行完成后的后继节点。

Parameters:

| Name | Description |
|---|---|
| `context` | 流程上下文。 |

Returns: 后继节点标识列表。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取节点显示名。

Returns: 显示名。

#### `get_input_ports`

- API: `public`

```gdscript
func get_input_ports() -> Array[GFFlowPort]:
```

获取输入端口。

Returns: 输入端口数组。

#### `get_output_ports`

- API: `public`

```gdscript
func get_output_ports() -> Array[GFFlowPort]:
```

获取输出端口。

Returns: 输出端口数组。

#### `get_input_port`

- API: `public`

```gdscript
func get_input_port(port_id: StringName) -> GFFlowPort:
```

按端口标识查找输入端口。

Parameters:

| Name | Description |
|---|---|
| `port_id` | 端口标识。 |

Returns: 输入端口；不存在时返回 null。

#### `get_output_port`

- API: `public`

```gdscript
func get_output_port(port_id: StringName) -> GFFlowPort:
```

按端口标识查找输出端口。

Parameters:

| Name | Description |
|---|---|
| `port_id` | 端口标识。 |

Returns: 输出端口；不存在时返回 null。

#### `describe_ports`

- API: `public`

```gdscript
func describe_ports() -> Dictionary:
```

描述节点端口。

Returns: 端口描述字典。

Schemas:

- `return`: 包含 inputs 和 outputs 字段的 Dictionary；每个字段为端口描述数组。

#### `describe_editor`

- API: `public`

```gdscript
func describe_editor() -> Dictionary:
```

描述节点编辑器元数据。

Returns: 编辑器元数据字典。

Schemas:

- `return`: 包含 display_name、category、position、size 和 collapsed 字段的 Dictionary。

#### `describe_node`

- API: `public`

```gdscript
func describe_node() -> Dictionary:
```

描述节点。

Returns: 节点描述字典。

Schemas:

- `return`: 包含 node_id、display_name、category、next_node_ids、wait_for_result、ports、editor 和 metadata 字段的 Dictionary。

#### `set_runtime_value`

- API: `public`

```gdscript
func set_runtime_value(key: StringName, value: Variant) -> void:
```

写入节点运行态值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `value` | 值。 |

Schemas:

- `value`: 任意可写入 runtime_state 的项目值。

#### `get_runtime_value`

- API: `public`

```gdscript
func get_runtime_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取节点运行态值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `default_value` | 默认值。 |

Returns: 运行态值或默认值。

Schemas:

- `default_value`: 缺失时返回的任意项目值。
- `return`: 找到的运行态值，或传入的 default_value。

#### `clear_runtime_state`

- API: `public`

```gdscript
func clear_runtime_state() -> void:
```

清空节点运行态数据。

#### `serialize_runtime_state`

- API: `public`

```gdscript
func serialize_runtime_state() -> Dictionary:
```

序列化节点运行态数据。

Returns: 运行态数据副本。

Schemas:

- `return`: runtime_state 的深拷贝 Dictionary。

#### `deserialize_runtime_state`

- API: `public`

```gdscript
func deserialize_runtime_state(data: Dictionary) -> void:
```

反序列化节点运行态数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 运行态数据。 |

Schemas:

- `data`: serialize_runtime_state() 返回的运行态 Dictionary。

## GFFlowPort

- Path: `addons/gf/extensions/flow/resources/gf_flow_port.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFFlowPort: 流程节点端口描述。 端口只描述节点对外暴露的输入/输出能力，供编辑器、校验器或项目层 构建可视化流程使用；运行时如何解释端口数据仍由具体节点决定。

### Enums

#### `Direction`

- API: `public`

```gdscript
enum Direction { ## 输入端口。 INPUT, ## 输出端口。 OUTPUT, }
```

端口方向。

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 任意值。 ANY, ## 布尔。 BOOL, ## 数值。 NUMBER, ## 字符串。 STRING, ## Vector2。 VECTOR2, ## Vector3。 VECTOR3, ## Dictionary。 DICTIONARY, ## Array。 ARRAY, ## Object 或 Resource。 OBJECT, }
```

端口值类型提示。

### Properties

#### `port_id`

- API: `public`

```gdscript
var port_id: StringName = &""
```

端口稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

显示名称。

#### `direction`

- API: `public`

```gdscript
var direction: Direction = Direction.OUTPUT
```

端口方向。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.ANY
```

值类型提示。

#### `allow_multiple`

- API: `public`

```gdscript
var allow_multiple: bool = false
```

是否允许多条连接。

#### `editor_color`

- API: `public`

```gdscript
var editor_color: Color = Color.TRANSPARENT
```

编辑器或可视化工具使用的端口颜色。透明色表示由工具自行决定。

#### `type_hint`

- API: `public`

```gdscript
var type_hint: StringName = &""
```

更细粒度的值类型提示，例如项目自定义数据结构名。框架不解释该字段。

#### `class_name_hint`

- API: `public`

```gdscript
var class_name_hint: StringName = &""
```

Object / Resource 端口的类名提示。仅在项目或校验器显式使用时参与兼容性判断。

#### `semantic_tags`

- API: `public`

```gdscript
var semantic_tags: PackedStringArray = PackedStringArray()
```

语义标签列表，供搜索、编辑器过滤或项目工具使用。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `get_port_id`

- API: `public`

```gdscript
func get_port_id() -> StringName:
```

获取端口标识。

Returns: 端口标识。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取显示名称。

Returns: 显示名称。

#### `has_semantic_tag`

- API: `public`

```gdscript
func has_semantic_tag(tag: StringName) -> bool:
```

检查是否包含语义标签。

Parameters:

| Name | Description |
|---|---|
| `tag` | 标签。 |

Returns: 包含返回 true。

#### `is_compatible_with`

- API: `public`

```gdscript
func is_compatible_with(target_port: GFFlowPort) -> bool:
```

判断当前端口是否可连接到目标端口。

Parameters:

| Name | Description |
|---|---|
| `target_port` | 目标端口。 |

Returns: 兼容返回 true。

#### `get_compatibility_report`

- API: `public`

```gdscript
func get_compatibility_report(target_port: GFFlowPort) -> Dictionary:
```

获取当前端口连接到目标端口的兼容性报告。

Parameters:

| Name | Description |
|---|---|
| `target_port` | 目标端口。 |

Returns: 兼容性报告。

Schemas:

- `return`: 包含 ok、reason、message、source_port_id、source_value_type、target_port_id 和 target_value_type 字段的 Dictionary。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述端口。

Returns: 端口描述字典。

Schemas:

- `return`: 包含 port_id、display_name、direction、value_type、allow_multiple、editor_color、type_hint、class_name_hint、semantic_tags 和 metadata 字段的 Dictionary。

## GFFlowRunner

- Path: `addons/gf/extensions/flow/runtime/gf_flow_runner.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFFlowRunner: 通用流程图执行器。 按节点后继关系执行 GFFlowGraph，支持 Signal 等待、取消和简单循环保护。

### Signals

#### `flow_started`

- API: `public`

```gdscript
signal flow_started(graph: GFFlowGraph)
```

流程开始时发出。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |

#### `node_started`

- API: `public`

```gdscript
signal node_started(node_id: StringName, node: GFFlowNode)
```

节点开始执行时发出。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点 ID。 |
| `node` | 节点资源。 |

#### `node_completed`

- API: `public`

```gdscript
signal node_completed(node_id: StringName, node: GFFlowNode)
```

节点完成执行时发出。

Parameters:

| Name | Description |
|---|---|
| `node_id` | 节点 ID。 |
| `node` | 节点资源。 |

#### `flow_completed`

- API: `public`

```gdscript
signal flow_completed
```

流程完成时发出。

#### `flow_cancelled`

- API: `public`

```gdscript
signal flow_cancelled
```

流程取消时发出。

### Properties

#### `is_running`

- API: `public`

```gdscript
var is_running: bool = false
```

当前是否正在执行。

#### `max_executed_nodes`

- API: `public`

```gdscript
var max_executed_nodes: int = 1024
```

最多执行节点数量，避免循环图无限运行。小于等于 0 表示不限制。

#### `signal_timeout_seconds`

- API: `public`

```gdscript
var signal_timeout_seconds: float = 30.0
```

Signal 等待超时时间。小于等于 0 表示不启用超时。

#### `signal_timeout_respects_time_scale`

- API: `public`

```gdscript
var signal_timeout_respects_time_scale: bool = true
```

Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。

#### `isolate_graph_runtime_state`

- API: `public`

```gdscript
var isolate_graph_runtime_state: bool = true
```

运行时是否把节点 runtime_state 隔离到 GFFlowContext，避免污染共享图资源。

### Methods

#### `run`

- API: `public`

```gdscript
func run(graph: GFFlowGraph, context: GFFlowContext = null) -> void:
```

运行流程图。

Parameters:

| Name | Description |
|---|---|
| `graph` | 流程图资源。 |
| `context` | 可选上下文。 |

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

请求取消流程。

#### `with_signal_timeout`

- API: `public`

```gdscript
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFFlowRunner:
```

设置 Signal 等待超时时间。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 秒数；小于等于 0 时表示不启用超时。 |
| `respect_time_scale` | 是否跟随 GFTimeUtility 的暂停与 time_scale。 |

Returns: 当前执行器。

