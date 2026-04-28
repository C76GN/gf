# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：极其重要。详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## [1.14.2] - 2026-04-28

**版本概述**：聚焦文档与当前实现对齐、运行时边界行为收紧和测试覆盖补强，修复输入计时、数据绑定与原生 Signal 工具中的细小边缘问题，并补充多组刁钻边界测试。

### 🔄 机制更改 (Changed)
- **Utility Tick 文档语义对齐**：文档与源码注释统一说明 `GFArchitecture` 会调度 `GFSystem`，以及实现了 `tick()` / `physics_tick()` 的 `GFUtility`。
- **注册示例异步一致性**：生命周期、战斗扩展等文档中的 `register_*()` 示例补充 `await`，避免动态注册时误以为三阶段生命周期已立即完成。
- **命令执行语义澄清**：命令文档明确 `Gf.send_command()` 会先注入当前 `GFArchitecture` 再执行，直接 `execute()` 只适合完全不依赖框架访问的命令。
- **工具箱示例修正**：`GFTimerUtility` 示例改为“逻辑时间”表述；`GFUIUtility` 示例区分同步加载场景 `push_panel()` 与已实例化节点 `push_panel_instance()`。
- **生命周期文档旧 API 清理**：异步加载示例改用当前 `GFAssetUtility.load_async()`；简单事件监听示例改用 `Gf.listen_simple()`。
- **表现动作示例修正**：`GFVisualAction` 示例改为在目标节点上调用 `target_card.create_tween()`。

### 🐛 Bug 修复 (Fixed)
- **输入工具负 delta 防护**：`GFInputUtility.tick()` 忽略小于等于 0 的 delta，避免输入缓冲和土狼时间被负 delta 反向延长。
- **BindableProperty 多节点同回调绑定**：同一个 callable 绑定到多个 Node 时，任一节点退出不会提前断开其它节点仍在使用的 `value_changed` 连接。
- **Signal 无效连接追踪**：`GFSignalUtility.connect_signal()` 在底层连接启动失败后会从追踪表移除该连接，避免无效连接残留到 owner 清理流程中。
- **测试脚本警告清理**：修正 `test_gf_signal_utility.gd` 中未使用局部变量导致的 `UNUSED_VARIABLE` 警告。

### ✅ 测试补强 (Tests)
- **数据绑定边界**：覆盖同一 callable 绑定多个节点并随节点退出逐步解绑的行为。
- **Signal 工具边界**：覆盖无效 callback 不进入追踪表，以及断开连接后 pending delayed callback 不再触发。
- **输入与计时边界**：覆盖非正数缓冲时长、负 delta、0 秒定时器立即执行、无效定时器 callback、同帧多定时器执行顺序和 `dispose()` 清理。
- **工厂生命周期边界**：覆盖 singleton 工厂错误类型不缓存、释放缓存重建，以及父级 singleton 工厂保持所属架构注入。
- **Foundation 边界**：补充大数解析/除零/负数非整数幂、网格非法输入与阻塞寻路、紧凑格式化进位、负数小数分组、进度曲线 string override、非法指数倍率、负离线时长与零仓储上限等测试。

### 🔌 API 变动说明 (API Changes)
- 无公开 API 签名变更。
- `GFInputUtility.tick(delta)` 对 `delta <= 0.0` 的行为收紧为不推进计时器。

### 📘 升级指南 (Migration Guide)
1. 旧项目无需迁移公开接口；如果有测试或调试脚本依赖负 delta 延长输入窗口，需要改为显式刷新缓冲/土狼时间。
2. 文档示例中的注册流程请按 `await register_*()` 书写，尤其是在架构已初始化后的动态注册场景。
3. 直接调用 `Command.execute()` 前请确认命令不依赖框架注入；需要访问 Model/System/Utility 时继续使用 `Gf.send_command()` 或架构工厂创建实例。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/bindable_property.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/docs/wiki/01. 架构概览 (Architecture).md`
- `addons/gf/docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `addons/gf/docs/wiki/03. 更新机制 (Update Loop).md`
- `addons/gf/docs/wiki/06. 命令与查询 (Commands & Queries).md`
- `addons/gf/docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `addons/gf/docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `addons/gf/docs/wiki/10. 战斗扩展 (Combat Extension).md`
- `addons/gf/utilities/gf_input_utility.gd`
- `addons/gf/utilities/gf_signal_utility.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_big_number.gd`
- `tests/gf_core/test_gf_grid_math.gd`
- `tests/gf_core/test_gf_input_utility.gd`
- `tests/gf_core/test_gf_number_formatter.gd`
- `tests/gf_core/test_gf_progression_math.gd`
- `tests/gf_core/test_gf_signal_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_timer_utility.gd`

---

## [1.14.1] - 2026-04-28

**版本概述**：聚焦框架边界正确性、异步初始化一致性和高频路径性能，修复定点数长精度解析、项目 Installer 并发、能力依赖失败回滚、状态机重入和 Signal 空参数等边缘问题。

### 🚀 新增特性 (Added)
- **Model 自定义存档键**：`GFModel.get_save_key()` 可为运行时脚本或需要重命名兼容的 Model 提供稳定快照键。
- **项目 Installer 状态信号**：`GFArchitecture.project_installers_finished` 可唤醒并发 `Gf.init()` 等待方。
- **DebugOverlay 刷新间隔**：`GFDebugOverlayUtility.refresh_interval_seconds` 与 `set_refresh_interval()` 支持降低可见时的反射刷新频率。
- **编辑器类型索引缓存**：`GFEditorTypeIndex.clear_cache()` 支持清理脚本与场景根脚本缓存。

### 🔄 机制更改 (Changed)
- **定点数除法精度**：`GFFixedDecimal` 大位移除法改为整数/十进制字符串路径，避免 float 精度损失。
- **表现动作超时语义**：`GFVisualAction.with_signal_timeout()` 新增可选参数 `respect_time_scale`，默认让 Signal 超时跟随 `GFTimeUtility` 暂停与时间缩放。
- **战斗系统迭代优化**：`GFCombatSystem` 处理 Buff 与技能 CD 时不再每帧复制数组。
- **DebugOverlay 性能优化**：悬浮面板只在刷新间隔到期时重新反射 Model 数据。
- **编辑器扫描复用**：`GFEditorTypeIndex` 复用已加载脚本和场景根脚本结果，减少重复同步加载。

### 🐛 Bug 修复 (Fixed)
- **Singleton 工厂缓存**：`GFBinding` 会丢弃已释放或排队释放的缓存实例，且不会缓存失败创建结果。
- **工厂类型校验**：工厂返回对象必须继承或等于绑定脚本类型，避免错误实例进入缓存。
- **项目 Installer 并发**：并发 `Gf.init()` 会等待正在运行的项目 Installer 完成，不再跳过未完成装配。
- **NodeContext 异步生命周期**：`GFNodeContext` 在等待父架构、安装模块和初始化后会重新确认节点与架构仍有效。
- **Signal trailing null**：`GFSignalConnection` 会根据声明参数数量保留显式发出的尾部 `null`。
- **能力依赖回滚**：能力依赖链创建失败时，会撤销本轮自动创建且未被其他能力持有的依赖。
- **节点状态重入**：`GFNodeStateGroup` 支持状态退出期间请求新切换，旧状态不会重复退出，最终目标以退出期请求为准。
- **纯代码状态机重启**：`GFStateMachine.start()` 在已有当前状态时会先退出旧状态。
- **长小数字符串解析**：`GFFixedDecimal.from_string()` 会先按目标精度解析和舍入，不再先钳制来源小数位。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFModel.get_save_key() -> StringName`。
- 新增 `GFArchitecture.project_installers_finished`。
- 新增 `GFArchitecture.is_project_installers_running() -> bool`。
- 新增 `GFArchitecture.begin_project_installers() -> bool`。
- 新增 `GFArchitecture.finish_project_installers() -> void`。
- 新增 `GFBinding.clear_cached_instance() -> void`。
- 新增 `GFDebugOverlayUtility.refresh_interval_seconds: float`。
- 新增 `GFDebugOverlayUtility.set_refresh_interval(seconds: float) -> void`。
- 新增 `GFEditorTypeIndex.clear_cache() -> void`。
- `GFVisualAction.with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFVisualAction` 新增可选参数，旧调用保持兼容。

### 📘 升级指南 (Migration Guide)
1. 旧 `with_signal_timeout(seconds)` 调用无需迁移；如果希望超时继续使用真实时间，请改为 `with_signal_timeout(seconds, false)`。
2. 使用运行时脚本 Model 或需要跨版本重命名存档键时，重写 `get_save_key()` 返回稳定 `StringName`。
3. 如果项目依赖 DebugOverlay 每帧刷新，可将 `refresh_interval_seconds` 设置为 `0.0`。
4. 工厂 provider 现在会校验返回对象脚本类型；如果之前返回了不匹配对象，需要修正 provider 或注册键。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/base/gf_model.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_binding.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/editor/gf_editor_type_index.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/utilities/gf_debug_overlay_utility.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_fixed_decimal.gd`
- `tests/gf_core/test_gf_model_serialization.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `tests/gf_core/test_gf_signal_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_state_machine.gd`

---

## [1.14.0] - 2026-04-28

**版本概述**：补强原生 Signal 连接、表现动作队列分流和场景树状态机能力，让 GF 在 UI、动画、角色控制器和临时表现流场景中具备更完整的框架级支持。

### 🚀 新增特性 (Added)
- **原生 Signal 工具**：新增 `GFSignalUtility` 与 `GFSignalConnection`，支持 owner 归属清理、安全断开、默认参数、`filter()` / `map()` / `delay()` / `debounce()` / `once()` 链式处理。
- **命名动作队列**：`GFActionQueueSystem` 新增命名队列 API，可为战斗、对白、教程、临时 UI 等表现流创建互不阻塞的独立队列。
- **节点绑定队列**：命名队列可绑定到节点生命周期，绑定节点释放后会取消当前动作并清空队列。
- **跳过当前动作**：`GFActionQueueSystem.skip_current_action()` 可取消当前动作并继续消费后续队列。
- **场景树状态机**：新增 `GFNodeStateMachine`、`GFNodeStateGroup` 与 `GFNodeState`，适合依赖动画、输入、碰撞或子节点引用的状态逻辑。
- **节点状态模板**：编辑器菜单新增 `工具 > GF > 生成 NodeState` 与 `工具 > GF > 生成 NodeStateMachine`。

### 🔄 机制更改 (Changed)
- **表现队列分流**：默认队列保持兼容；命名队列作为可选分流能力，不改变已有 `enqueue()` / `push_front()` 行为。
- **状态机职责分层**：纯代码 `GFStateMachine` 保持轻量逻辑状态职责；节点式状态机作为可选扩展承载场景树状态。
- **节点状态自动重载**：节点式状态机与状态组会监听子节点加入，在 `ready` 后动态补充状态时自动重新加载。
- **编辑器菜单收束**：GF 模板和代码生成入口集中到单个 `工具 > GF` 子菜单，减少对 Godot 工具菜单公共空间的占用。

### 🐛 Bug 修复 (Fixed)
- **节点状态机内部组生命周期**：内部状态组改为状态机的内部子节点，并在重新加载与退出树时显式清理，避免测试和运行期出现 orphan 节点。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFSignalUtility`。
- 新增 `GFSignalConnection`。
- 新增 `GFActionQueueSystem.get_named_queue(queue_name: StringName) -> GFActionQueueSystem`。
- 新增 `GFActionQueueSystem.get_linked_queue(queue_name: StringName, linked_node: Node) -> GFActionQueueSystem`。
- 新增 `GFActionQueueSystem.bind_to_node(linked_node: Node) -> void`。
- 新增 `GFActionQueueSystem.enqueue_to()` / `enqueue_fire_and_forget_to()` / `enqueue_parallel_to()`。
- 新增 `GFActionQueueSystem.push_front_to()`。
- 新增 `GFActionQueueSystem.clear_named_queue()` / `clear_all_named_queues()`。
- 新增 `GFActionQueueSystem.skip_current_action() -> void`。
- 新增 `GFNodeStateMachine`。
- 新增 `GFNodeStateGroup`。
- 新增 `GFNodeState`。

### 📘 升级指南 (Migration Guide)
1. 旧动作队列调用无需迁移；需要多条表现流互不阻塞时，再改用命名队列 API。
2. 业务事件仍推荐使用 `TypeEventSystem`；Godot 节点信号、UI 信号和动画完成信号推荐使用 `GFSignalUtility`。
3. 纯逻辑状态继续使用 `GFStateMachine`；依赖场景树节点引用的状态可改用 `GFNodeStateMachine`。
4. 使用编辑器模板生成新节点状态后，只需继承 `_initialize()`、`_enter()`、`_exit()` 等 Hook 编写业务逻辑。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/utilities/gf_signal_utility.gd`
- `addons/gf/docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `addons/gf/docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `tests/gf_core/test_gf_signal_utility.gd`

---

## [1.13.0] - 2026-04-27

**版本概述**：强化能力组件的运行时正确性、编辑器体验与强类型访问，同时补充轻量交互流程、动态属性包、递归注入和日志过滤能力。

### 🚀 新增特性 (Added)
- **能力容器类型匹配**：Node 能力会根据 receiver 与能力节点类型创建 `Node` / `Node2D` / `Node3D` / `Control` 容器，保留空间变换与 UI 继承语义。
- **能力依赖移除策略**：`GFCapabilityUtility.DependencyRemovalPolicy` 支持保留依赖或清理仅由主能力自动补齐且未显式添加的依赖。
- **能力递归注入**：场景能力挂载时会递归向子节点注入当前架构。
- **能力强类型访问器**：`GFAccessGenerator` 现在会为 `GFCapability` / `GFNodeCapability` 生成 `get/add/has/remove/if_has` helper。
- **能力编辑器模板**：编辑器菜单新增 `GF/生成 Capability` 与 `GF/生成 NodeCapability`。
- **能力 Inspector 属性编辑**：目标节点 Inspector 的 `GF Capabilities` 区域可直接显示并编辑能力导出属性。
- **动态属性包能力**：新增 `GFPropertyBagCapability`，提供少量运行时键值的轻量存取能力。
- **交互流程入口**：新增 `GFInteractions` 与 `GFInteractionFlow`，用于创建链式交互上下文并把上下文传入命令或事件。
- **显式注入 API**：`GFArchitecture`、`Gf` 与 `GFNodeContext` 新增 `inject_object()` 与 `inject_node_tree()`。
- **日志过滤与延迟消息**：`GFLogUtility` 新增 `min_level` 与 `debug_lazy()` / `info_lazy()` / `warn_lazy()` / `error_lazy()` / `fatal_lazy()`。

### 🔄 机制更改 (Changed)
- **编辑器类型扫描复用**：新增 `GFEditorTypeIndex`，供编辑器工具复用脚本与能力场景查询逻辑。
- **能力场景挂载更稳健**：能力容器仍复用 `GFCapabilityContainer` 行为脚本，旧场景中的普通容器保持兼容。
- **访问器生成范围扩大**：生成的 `GFAccess` 包含能力操作入口，减少 `GFCapabilityUtility` 手写样板。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFCapability.get_dependency_removal_policy() -> int`。
- 新增 `GFNodeCapability.get_dependency_removal_policy() -> int`。
- 新增 `GFCapabilityUtility.DependencyRemovalPolicy`。
- 新增 `GFCapabilityUtility.add_required_capability(receiver: Object, capability_type: Script, provider: Variant = null) -> Object`。
- 新增 `GFArchitecture.inject_object(instance: Object) -> void`。
- 新增 `GFArchitecture.inject_node_tree(node: Node) -> void`。
- 新增 `Gf.inject_object(instance: Object) -> void`。
- 新增 `Gf.inject_node_tree(node: Node) -> void`。
- 新增 `GFNodeContext.inject_object(instance: Object) -> void`。
- 新增 `GFNodeContext.inject_node_tree(node: Node) -> void`。
- 新增 `GFPropertyBagCapability`。
- 新增 `GFInteractions`。
- 新增 `GFInteractionFlow`。
- 新增 `GFLogUtility.min_level: int`。
- 新增 `GFLogUtility.debug_lazy()` / `info_lazy()` / `warn_lazy()` / `error_lazy()` / `fatal_lazy()`。

### 📘 升级指南 (Migration Guide)
1. 旧能力组件无需迁移；默认依赖移除策略仍是保留依赖。
2. 如果希望移除主能力时同步清理自动补齐依赖，请重写 `get_dependency_removal_policy()` 并返回 `REMOVE_AUTO_DEPENDENCIES`。
3. 如果项目使用 `Node2D`、`Node3D` 或 `Control` 能力，建议回归检查场景层级；新容器会保留对应类型继承，通常无需业务代码调整。
4. 需要高频日志时，建议设置 `min_level` 并使用 lazy 日志方法，避免被过滤日志仍构造复杂字符串。
5. 重新运行 `GF/生成强类型访问器` 后，可直接使用生成的能力 helper。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/editor/gf_editor_type_index.gd`
- `addons/gf/extensions/capability/gf_capability.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/capability/gf_node_capability.gd`
- `addons/gf/extensions/capability/gf_property_bag_capability.gd`
- `addons/gf/extensions/interaction/gf_interaction_flow.gd`
- `addons/gf/extensions/interaction/gf_interactions.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `addons/gf/docs/wiki/12. 能力组件 (Capabilities).md`
- `tests/gf_core/test_gf_access_generator.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_log_utility.gd`

---

## [1.12.0] - 2026-04-27

**版本概述**：聚焦框架边界稳定性与异步生命周期一致性，修复事件派发、NodeContext、能力挂载、动作取消、对象池预热和战斗 Buff 刷新中的边缘问题，并补充对应回归测试。

### 🚀 新增特性 (Added)
- **BindableProperty 直觉属性访问**：`BindableProperty` 新增 `value` 属性，读写语义与 `get_value()` / `set_value()` 保持一致。
- **对象池容量控制**：`GFObjectPoolUtility` 新增 `max_available_per_scene`，可限制每个 `PackedScene` 在池内保留的可用节点数量。

### 🔄 机制更改 (Changed)
- **项目 Installer 异步装配**：`Gf.init()` / `set_architecture()` 现在会等待项目 Installer 的 `install()` 与 `install_bindings()` 完成后再启动架构生命周期。
- **Scoped 上下文初始化顺序**：子 `GFNodeContext` 初始化前会等待父级架构 ready，避免子模块早于父架构进入 ready。
- **资源与场景加载轮询语义**：`GFAssetUtility` 与 `GFSceneUtility` 默认设置 `ignore_pause = true`，明确资源轮询不应被全局暂停语义阻断。
- **确定性分支随机种子**：`GFSeedUtility.get_branched_rng()` 改用稳定 FNV-1a 派生种子，避免依赖 Godot 内置 `hash()`。
- **Buff 刷新语义补强**：重复 Buff 刷新会同步新的 `duration` / `time_left`，并在 `max_stacks > 1` 时增加层数但不超过上限。

### 🐛 Bug 修复 (Fixed)
- **事件 owner 派发期注销边界**：`TypeEventSystem.unregister_owner()` 在事件派发中不再直接修改 listener 数组，而是登记 pending remove，避免复杂嵌套派发下顺序不稳定。
- **Controller 悬挂监听**：`GFController._exit_tree()` 会主动注销 owner-bound 事件监听，减少临时 UI 节点销毁后的延迟清理。
- **能力场景实例泄漏**：`GFCapabilityUtility.add_scene_capability()` 在注册失败或被重复能力忽略时会释放新实例；`PackedScene` provider 依赖失败时也会释放已创建能力。
- **动作组取消不完整**：`GFVisualActionGroup.cancel()` 会递归取消子动作；内置 Tween 动作会 kill 当前 Tween。
- **对象池异步预热生命周期**：`GFObjectPoolUtility.prewarm_async()` 在 Utility dispose 后会停止后续批次，避免清空池后继续实例化。
- **Quest 深层 payload 防护**：`GFQuestUtility` 对 `payload.amount` 设置嵌套深度上限，并在派发任务列表前复制数组，避免回调中修改监听任务影响当前迭代。
- **Combat 集合迭代防护**：`GFCombatSystem` 处理 Buff 与 Skill 时迭代副本，避免 `on_tick()` 或 `skill.update()` 间接修改集合造成遍历风险。
- **状态机 exit 嵌套切换**：`GFStateMachine` 在 `exit()` 中再次请求切换时会合并到当前切换，避免旧状态重复 exit 或外层目标覆盖最终状态。
- **存档槽位假阳性**：`GFStorageUtility.has_slot()` 现在要求数据文件和元数据文件同时存在。

### 🔌 API 变动说明 (API Changes)
- 新增 `BindableProperty.value: Variant`。
- 新增 `GFObjectPoolUtility.max_available_per_scene: int`，默认为 `0` 表示不限制。
- `Gf.init()` / `Gf.set_architecture()` 会等待异步 Installer 钩子，旧调用方式保持不变。
- `GFStorageUtility.has_slot()` 判断更严格；孤立 metadata 文件不再被视为有效槽位。

### 📘 升级指南 (Migration Guide)
1. 旧的 `get_value()` / `set_value()` 调用无需迁移；新项目可直接使用 `prop.value`。
2. 如果项目依赖 `has_slot()` 只检查 metadata 的旧行为，请改为显式调用 `load_slot_meta()`，或补齐对应的数据文件。
3. 如果自定义 `GFVisualAction` 持有 Tween、AnimationPlayer 或外部异步句柄，建议重写 `cancel()` 同步停止底层表现。
4. 如果对象池存在波峰后长期占用大量节点，可设置 `max_available_per_scene` 控制保留容量。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/base/gf_controller.gd`
- `addons/gf/core/bindable_property.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/extensions/action_queue/gf_flash_action.gd`
- `addons/gf/extensions/action_queue/gf_move_tween_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_seed_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/plugin.cfg`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_quest_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_type_event_system.gd`

---

## [1.11.0] - 2026-04-27

**版本概述**：强化 Capability 的编辑器接入、运行时启停和查询能力，并补充轻量交互上下文与 SFX 并发上限控制，让局部对象组合更适合中大型项目使用。

### 🚀 新增特性 (Added)
- **节点能力基类**：新增 `GFNodeCapability`，适合需要碰撞、输入、动画或子节点引用的场景能力。
- **能力 Inspector**：启用插件后，选中普通 `Node` 可在 Inspector 中添加、启停、编辑和移除 `GFNodeCapability` 能力脚本或能力场景。
- **能力启停 API**：`GFCapabilityUtility` 新增 `set_capability_active()`、`is_capability_active()` 和 `capability_active_changed` 信号。
- **能力反向索引**：新增 `get_receivers_with()` 与 `get_capabilities()`，支持按能力类型查询 receiver 和能力实例。
- **能力分组查询**：新增 receiver 分组 API，支持 `add_receiver_to_group()`、`get_receivers_in_group_with()` 等轻量索引能力。
- **交互上下文**：新增 `GFInteractionContext`，用于在命令、事件或能力方法之间传递 sender、target、payload 和分组名。
- **SFX 并发控制**：`GFAudioUtility` 新增 `max_sfx_players` 与 `SFXOverflowPolicy`，支持跳过新请求或停止最早 SFX。

### 🔄 机制更改 (Changed)
- **Node 能力停用语义**：通过 `GFCapabilityUtility.set_capability_active()` 停用 Node 能力时，会临时禁用能力节点树的 `process_mode`，重新启用时恢复原状态。
- **能力挂载自动索引**：能力注册、移除和失效清理会同步维护反向索引，查询路径会自动清理已释放 receiver。
- **插件编辑器工具扩展**：`addons/gf/plugin.gd` 会注册 GF Capability Inspector，并在插件禁用时清理对应 Inspector 插件。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFNodeCapability`。
- 新增 `GFInteractionContext`。
- 新增 `GFCapability.active: bool`。
- 新增 `GFCapability.on_gf_capability_active_changed(receiver: Object, active: bool) -> void`。
- 新增 `GFCapabilityUtility.capability_active_changed(receiver, capability_type, capability, active)`。
- 新增 `GFCapabilityUtility.set_capability_active(receiver: Object, capability_type: Script, active: bool) -> void`。
- 新增 `GFCapabilityUtility.is_capability_active(receiver: Object, capability_type: Script) -> bool`。
- 新增 `GFCapabilityUtility.get_receivers_with(capability_type: Script, include_subclasses: bool = true) -> Array[Object]`。
- 新增 `GFCapabilityUtility.get_capabilities(capability_type: Script, include_subclasses: bool = true) -> Array[Object]`。
- 新增 `GFCapabilityUtility.add_receiver_to_group(receiver: Object, group_name: StringName) -> void`。
- 新增 `GFCapabilityUtility.remove_receiver_from_group(receiver: Object, group_name: StringName) -> void`。
- 新增 `GFCapabilityUtility.get_receiver_groups(receiver: Object) -> Array[StringName]`。
- 新增 `GFCapabilityUtility.get_receivers_in_group(group_name: StringName) -> Array[Object]`。
- 新增 `GFCapabilityUtility.get_receivers_in_group_with(group_name: StringName, capability_type: Script, include_subclasses: bool = true) -> Array[Object]`。
- 新增 `GFCapabilityUtility.clear_receiver_groups(receiver: Object) -> void`。
- 新增 `GFAudioUtility.SFXOverflowPolicy`、`max_sfx_players` 与 `sfx_overflow_policy`。

### 📘 升级指南 (Migration Guide)
1. 旧的 `GFCapability` 用法保持兼容；需要编辑器添加和场景节点能力时，推荐新建脚本继承 `GFNodeCapability`。
2. 需要临时关闭能力时，优先调用 `set_capability_active()`，不要只手动改 `active` 字段。
3. 需要范围索敌、交互候选或 UI 选择列表时，可以用 `get_receivers_with()` 和分组查询替代业务层手写索引。
4. 如果项目有大量短促 SFX，建议设置 `max_sfx_players`，并按听感选择 `SKIP_NEW` 或 `STOP_OLDEST`。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/extensions/capability/gf_capability.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/capability/gf_node_capability.gd`
- `addons/gf/extensions/interaction/gf_interaction_context.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `addons/gf/docs/wiki/12. 能力组件 (Capabilities).md`
- `tests/gf_core/test_gf_audio_utility.gd`
- `tests/gf_core/test_gf_capability_utility.gd`

---

## [1.10.0] - 2026-04-27

**版本概述**：新增 GF 原生 Capability 扩展和强类型访问器生成器，让对象局部能力组合与 IDE 补全更加稳定，同时保持核心架构显式分层、可选接入与 scoped 架构兼容。

### 🚀 新增特性 (Added)
- **对象能力组件系统**：新增 `GFCapability`、`GFCapabilityUtility` 与 `GFCapabilityContainer`，支持为任意 `Object` / `Node` 挂载、查询、移除能力组件。
- **显式能力依赖**：能力可实现 `get_required_capabilities() -> Array[Script]` 声明依赖，挂载时自动补齐并检测循环依赖。
- **Node 能力容器**：Node 能力会自动挂入 receiver 下的 `GFCapabilityContainer`；场景中的容器子节点也可自动注册为父节点能力。
- **能力生命周期 Hook**：能力可实现 `on_gf_capability_added(receiver)`、`on_gf_capability_removed(receiver)` 与 `inject_dependencies(architecture)`。
- **强类型访问器生成器**：新增 `GFAccessGenerator`，编辑器菜单 `GF/生成强类型访问器` 会生成 `GFAccess` helper。
- **访问器输出设置**：新增项目设置 `gf/codegen/access_output_path`，默认输出到 `res://gf/generated/gf_access.gd`。
- **工厂存在性查询**：`GFArchitecture` 与 `Gf` 新增 `has_factory(script_cls)`，用于无副作用地判断短生命周期对象工厂是否存在。

### 🔄 机制更改 (Changed)
- **能力组合收敛为扩展层**：能力组合进入 `extensions/capability`，不改变 `GFArchitecture` 的 Model/System/Utility 注册语义。
- **Command / Query 生成创建策略**：生成的 `GFAccess.create_*()` 会优先走架构工厂；没有工厂时回退到脚本 `new()` 并注入当前架构。
- **插件菜单扩展**：`addons/gf/plugin.gd` 新增强类型访问器生成菜单，并确保 codegen 项目设置存在。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFCapability`。
- 新增 `GFCapabilityUtility.has_capability(receiver, capability_type) -> bool`。
- 新增 `GFCapabilityUtility.get_capability(receiver, capability_type) -> Object`。
- 新增 `GFCapabilityUtility.add_capability(receiver, capability_type, provider = null) -> Object`。
- 新增 `GFCapabilityUtility.add_capability_instance(receiver, capability, as_type = null) -> Object`。
- 新增 `GFCapabilityUtility.add_scene_capability(receiver, scene, as_type = null) -> Object`。
- 新增 `GFCapabilityUtility.remove_capability(receiver, capability_type) -> void`。
- 新增 `GFCapabilityUtility.clear_capabilities(receiver) -> void`。
- 新增 `GFCapabilityContainer`。
- 新增 `GFAccessGenerator.generate(output_path = DEFAULT_OUTPUT_PATH) -> Error`。
- 新增 `GFArchitecture.has_factory(script_cls: Script) -> bool`。
- 新增 `Gf.has_factory(script_cls: Script) -> bool`。

### 📘 升级指南 (Migration Guide)
1. 旧项目无需迁移；Capability 是可选扩展，只有注册 `GFCapabilityUtility` 后才启用。
2. 需要复用对象局部行为时，优先将能力实现为 `GFCapability` 或带 Hook 的 Node，而不是继续扩大实体脚本。
3. 大型项目可在提交前运行 `GF/生成强类型访问器`，把生成的 `GFAccess` 一并提交，提升调用点补全质量。
4. 如果 Command / Query 必须通过自定义工厂创建，请继续在架构中注册工厂；生成访问器会优先使用该工厂。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/extensions/capability/gf_capability.gd`
- `addons/gf/extensions/capability/gf_capability_container.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `addons/gf/docs/wiki/12. 能力组件 (Capabilities).md`
- `addons/gf/docs/wiki/Home.md`
- `addons/gf/docs/wiki/_Sidebar.md`
- `tests/gf_core/test_gf_access_generator.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`

---

## [1.9.3] - 2026-04-27

**版本概述**：聚焦生命周期边界、异步取消与资源类型一致性，修复动态注册、队列等待、战斗清理、命令历史和数值格式化中的边缘问题，并补充对应回归测试。

### 🚀 新增特性 (Added)
- **动作队列当前动作取消**：`GFVisualAction` 新增 `cancel()`，`GFVisualActionGroup` 会通过执行序号停止内部等待。
- **命令历史异步超时**：`GFCommandHistoryUtility` 新增 `async_timeout_seconds`，避免异步命令 Signal 丢失后永久锁住历史操作。
- **音频总线常量与回退**：`GFAudioUtility` 新增 `BGM_BUS_NAME` / `SFX_BUS_NAME` 常量，缺少对应总线时自动回退 `Master` 并提示。

### 🔄 机制更改 (Changed)
- **Tick 只驱动 ready 模块**：`GFArchitecture.tick()` / `physics_tick()` 现在只驱动生命周期已到阶段三的模块，避免动态注册慢初始化对象提前参与帧循环。
- **失效 alias 不再遮蔽回退**：本地 alias 指向未注册目标时，查询会继续走 assignable 查询与父架构回退。
- **资源 pending 保留 type_hint**：`GFAssetUtility` 的 pending 请求会记录 `type_hint`；同一路径不同类型提示的并发请求会被拒绝并回调 `null`。
- **NodeContext 等待改用生命周期信号**：`GFNodeContext.wait_until_ready()` 不再逐帧轮询，而是等待架构初始化完成信号。
- **任务 float 进度四舍五入**：`GFQuestUtility` 对 float 或字典中的 float `amount` 使用四舍五入，避免静默截断。

### 🐛 Bug 修复 (Fixed)
- **UI 入栈失败后下层面板不可见**：修复 `GFUIUtility` 的 `config_callback` 销毁新面板时，旧栈顶未恢复显示的问题。
- **动作队列清空仍卡在当前等待**：`GFActionQueueSystem.clear_queue(true)` 现在会取消当前等待并丢弃后续动作。
- **战斗系统释放未清理效果**：`GFCombatSystem.dispose()` 会移除存活实体上的 Buff 效果、断开技能信号并清空索引；已释放实体清理不再触发 typed Object 错误。
- **命令历史缺少架构注入与取消**：历史执行、撤销、重做和反序列化恢复的命令会注入当前架构；dispose 会取消等待中的异步操作。
- **科学计数法尾数进位错误**：`GFBigNumber.to_scientific_string()` 在尾数舍入到 10 时会正确进位指数。
- **定点数大位移除法错误缩放**：`GFFixedDecimal.divide()` 对超过整数缩放安全上限的正位移使用浮点兜底并钳制溢出，不再把缩放位数截断成错误结果。
- **定点数转大数重复加载脚本**：`GFFixedDecimal.to_big_number()` 改为预加载脚本引用。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFVisualAction.cancel() -> void`。
- 新增 `GFCommandHistoryUtility.async_timeout_seconds: float`。
- 新增 `GFAudioUtility.BGM_BUS_NAME` 与 `GFAudioUtility.SFX_BUS_NAME`。
- `GFActionQueueSystem.clear_queue(stop_current: bool = false)` 新增可选参数，旧调用保持兼容。
- `GFAssetUtility.is_loading(path: String, type_hint: String = "")` 新增可选参数，旧调用保持兼容。
- `GFAssetUtility.cancel(path: String, type_hint: String = "")` 新增可选参数，旧调用保持兼容。

### 📘 升级指南 (Migration Guide)
1. 旧的 `clear_queue()`、`is_loading(path)` 与 `cancel(path)` 调用无需改动；需要终止当前等待动作时改用 `clear_queue(true)`。
2. 如果项目没有配置 `BGM` / `SFX` 音频总线，`GFAudioUtility` 会回退到 `Master`；正式项目建议在 Audio Bus Layout 中补齐对应总线。
3. 如果同一路径需要以不同 `type_hint` 加载，请等待前一个请求结束后再发起新请求，或统一调用方的类型提示。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/foundation/numeric/gf_big_number.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `addons/gf/plugin.cfg`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_big_number.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_command_history_utility.gd`
- `tests/gf_core/test_gf_fixed_decimal.gd`
- `tests/gf_core/test_gf_quest_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `tests/gf_core/test_gf_ui_utility.gd`

---

## [1.9.2] - 2026-04-27

**版本概述**：聚焦 Scoped 架构隔离、运行时空值防御与高频路径性能，修复局部上下文被全局 `Gf` 绕过的依赖解析问题，并补强对象池、动作队列、日志、资源缓存与定点数边界稳定性。

### 🚀 新增特性 (Added)
- **Controller 安全架构查询**：新增 `GFController.get_architecture_or_null()`，用于需要静默判断上下文架构是否可用的控制器场景。
- **对象池分批预热**：新增 `GFObjectPoolUtility.prewarm_async(scene, parent, count, batch_size = 32)`，可把大量节点预热拆分到多帧执行。
- **动作与技能架构注入**：`GFVisualAction` 与 `GFSkill` 新增 `inject_dependencies(architecture)`，允许动作队列与战斗系统把 scoped 架构传递给短生命周期对象。
- **日志 flush 策略配置**：`GFLogUtility` 新增 `flush_interval_msec` 与 `flush_immediately`，可在性能与日志落盘可靠性之间按项目需求选择。

### 🔄 机制更改 (Changed)
- **Scoped 依赖解析收敛**：`GFSceneUtility`、`GFUIUtility`、`GFAudioUtility`、`GFLevelUtility`、`GFQuestUtility`、`GFConsoleUtility`、`GFCombatSystem` 与 `GFStateMachine` 现在优先使用注入或上下文架构，只有缺少上下文时才回退全局 `Gf`。
- **Tick 缓存遍历更严格**：`GFArchitecture.tick()` / `physics_tick()` 会跳过同一帧中已注销的模块，避免旧缓存继续驱动已移除对象。
- **动作队列消费优化**：`GFActionQueueSystem` 使用队头索引消费队列，避免顺序消费时频繁 `pop_front()` 搬移数组。
- **网格 BFS 队列优化**：`GFGridMath` 的泛洪、BFS 寻路与连线搜索改用队头索引遍历。
- **资源缓存 LRU 优化**：`GFAssetUtility` 的 LRU 记录改为访问序号，减少每次访问时的数组擦除成本。
- **日志写入优化**：普通日志不再每条强制 flush；错误与致命日志仍会立即 flush，销毁时统一 flush。

### 🐛 Bug 修复 (Fixed)
- **技能自定义施放检查被跳过**：修复 owner 没有 TagComponent 且无必需标签时，`GFSkill.can_execute()` 直接返回 true 而不调用 `_custom_can_execute()` 的问题。
- **对象池预热空场景崩溃**：`GFObjectPoolUtility.prewarm()` 现在会校验 `PackedScene` 与预热数量，避免 `scene.instantiate()` 空引用。
- **注册别名空实例崩溃**：`register_*_instance_as()` 现在会在 alias 注册前校验实例与脚本，避免无效实例继续访问 `get_script()`。
- **命令、查询与事件空输入崩溃**：`GFArchitecture.send_command()`、`send_query()`、`send_event()` 与 `TypeEventSystem.send()` 增加空输入保护。
- **SFX 异步销毁后播放**：`GFAudioUtility.play_sfx()` 现在会在异步加载回调中校验生命周期序号，Utility 销毁后不会继续播放。
- **定点数边界溢出**：`GFFixedDecimal` 的加法、乘法、字符串解析与除法舍入改为整数边界判断，避免 int64 边界附近因 float 精度或 `remainder * 2` 溢出产生错误结果。
- **零目标任务状态不一致**：`GFQuestUtility.start_quest()` 对 `target_count <= 0` 的任务会立即标记完成，并发出进度与完成信号。
- **日志保留数量负值越界**：`GFLogUtility.max_log_files` 会钳制到至少 1，避免负数配置导致旧日志清理越界。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFController.get_architecture_or_null() -> GFArchitecture`。
- 新增 `GFObjectPoolUtility.prewarm_async(scene: PackedScene, parent: Node, count: int, batch_size: int = 32) -> void`。
- 新增 `GFVisualAction.inject_dependencies(architecture: GFArchitecture) -> void`。
- 新增 `GFSkill.inject_dependencies(architecture: GFArchitecture) -> void`。
- 新增 `GFLogUtility.flush_interval_msec: int`。
- 新增 `GFLogUtility.flush_immediately: bool`。
- `GFQuestUtility.start_quest()` 对 `target_count <= 0` 的行为从“等待事件后才完成”调整为“启动即完成”。

### 📘 升级指南 (Migration Guide)
1. 使用 `GFNodeContext.SCOPED` 的项目无需改动调用方式；原先错误落到全局架构的 Utility / System 现在会优先使用局部架构。
2. 如果自定义 `GFVisualAction` 或 `GFSkill` 需要解析架构依赖，可以实现或继承 `inject_dependencies()`，并由 `GFActionQueueSystem` / `GFCombatSystem` 自动注入。
3. 大批量对象池预热建议从 `prewarm()` 迁移到 `await prewarm_async(..., batch_size)`，避免单帧实例化尖峰。
4. 如项目依赖每条普通日志立刻落盘，可设置 `GFLogUtility.flush_immediately = true` 或 `flush_interval_msec = 0`。
5. 如果旧任务配置中使用 `target_count <= 0` 表示“永不完成”，需要改为正数目标或在业务层禁用该任务。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/base/gf_command.gd`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_query.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/action_queue/gf_audio_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/combat/gf_skill.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/foundation/math/gf_grid_math.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/utilities/gf_debug_overlay_utility.gd`
- `addons/gf/utilities/gf_level_utility.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_audio_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_fixed_decimal.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_quest_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_state_machine.gd`

---

## [1.9.1] - 2026-04-27

**版本概述**：在 `1.9.0` 的 Installer、NodeContext 与父级架构回退基础上，继续吸收依赖注入容器的声明式绑定、生命周期策略和监听拥有者清理能力，补齐大型项目装配可读性、动态模块事件清理以及局部上下文下短生命周期对象注入语义。

### 🚀 新增特性 (Added)
- **声明式绑定装配器**：新增 `GFBinder`、`GFBindBuilder`、`GFBinding` 与 `GFBindingLifetimes`，支持 `bind_model()` / `bind_system()` / `bind_utility()` / `bind_factory()` 链式声明绑定来源、别名与生命周期。
- **Installer 绑定入口**：`GFInstaller` 新增 `install_bindings(binder: Variant)`，项目安装器可以同时保留旧的 `install(architecture)` 与新的声明式装配写法。
- **NodeContext 绑定入口**：`GFNodeContext` 新增 `install_bindings(binder: Variant)`，局部 scoped 架构可以用同一套装配语义注册场景专属模块和工厂。
- **拥有者绑定事件监听**：新增 `register_event_owned()` / `register_simple_event_owned()` / `unregister_owner_events()` 以及 `Gf.listen_owned()` / `Gf.listen_simple_owned()` / `Gf.unlisten_owner()`，支持按监听拥有者批量清理。
- **Utility 事件便捷方法**：`GFUtility` 补齐 `register_event()` / `register_simple_event()` 等事件辅助方法，与 `GFSystem`、`GFController` 保持一致。
- **上下文就绪等待**：新增 `GFNodeContext.wait_until_ready()` 与 `GFController.wait_for_context_ready()`，用于在 scoped 架构异步初始化完成后再安全访问局部依赖。
- **工厂实例绑定**：新增 `register_factory_instance()` / `replace_factory_instance()`，可把已有实例作为 `create_instance()` 的单例返回来源。

### 🔄 机制更改 (Changed)
- **工厂注册改为绑定对象承载**：短生命周期对象工厂现在统一由 `GFBinding` 管理 provider、lifetime 与自动注入策略。
- **工厂生命周期可配置**：`register_factory()` / `replace_factory()` 新增可选 `lifetime` 参数，默认保持 transient 行为；singleton 工厂会缓存首次解析出的实例。
- **父级 transient 工厂注入请求方架构**：子架构回退到父级 transient 工厂时，新对象会注入发起解析的子架构；singleton 工厂仍注入拥有该绑定的架构。
- **模块事件注册默认 owner-bound**：`GFSystem`、`GFUtility`、`GFController` 的基类事件注册方法现在默认以自身为 owner，模块注销时自动清理对应监听。
- **注册边界校验更严格**：底层 `register_model/system/utility()` 现在会校验实例基类、脚本存在性以及注册脚本与实例脚本的继承关系，避免把错误类型塞进错误注册槽位。

### 🐛 Bug 修复 (Fixed)
- **动态注销后的事件监听残留**：注销 `System` / `Utility` 时会自动移除该实例拥有的类型事件与简单事件监听，避免临时模块释放后继续接收事件。
- **事件派发中的 owner 清理一致性**：派发过程中调用 owner 批量注销时，会同步处理 pending add/remove，避免同一轮或下一轮派发误触发已清理监听。
- **文档回调签名漂移**：修正 BindableProperty 示例中 `value_changed` 回调参数与实际 `(old_value, new_value)` 语义不一致的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFArchitecture.create_binder() -> Variant` 与 `Gf.create_binder() -> Variant`。
- 新增 `GFInstaller.install_bindings(binder: Variant) -> void`。
- 新增 `GFNodeContext.install_bindings(binder: Variant) -> void`。
- 新增 `GFNodeContext.wait_until_ready() -> GFArchitecture`。
- 新增 `GFController.wait_for_context_ready() -> GFArchitecture`。
- 新增 `GFArchitecture.register_event_owned()` / `register_simple_event_owned()` / `unregister_owner_events()`。
- 新增 `Gf.listen_owned()` / `listen_simple_owned()` / `unlisten_owner()`。
- 新增 `GFArchitecture.register_factory_instance()` / `replace_factory_instance()`。
- 新增 `Gf.register_factory_instance()` / `replace_factory_instance()`。
- `GFArchitecture.register_factory(script_cls, factory, lifetime = GFBindingLifetimes.Lifetime.TRANSIENT)` 新增可选 `lifetime` 参数，旧调用保持兼容。
- `GFArchitecture.replace_factory(script_cls, factory, lifetime = GFBindingLifetimes.Lifetime.TRANSIENT)` 新增可选 `lifetime` 参数，旧调用保持兼容。
- `Gf.register_factory()` / `Gf.replace_factory()` 同步新增可选 `lifetime` 参数，旧调用保持兼容。

### 📘 升级指南 (Migration Guide)
1. 旧的 `install(architecture)`、`register_*()`、`Gf.listen()` / `Gf.listen_simple()` 仍可继续使用，无需一次性迁移。
2. 新项目或注册项较多的项目，建议优先把模块、alias 和工厂写入 `install_bindings()`，让装配关系集中可读。
3. `GFSystem`、`GFUtility`、`GFController` 内部注册事件时，优先使用基类 `register_event()` / `register_simple_event()`；普通对象优先使用 `Gf.listen_owned()` 并在退出时调用 `Gf.unlisten_owner()`。
4. 需要短生命周期 Command / Query 访问依赖时，优先通过 `create_instance()` 创建；局部场景下它会拿到正确的 scoped 架构注入。
5. 如果旧代码直接调用底层 `register_utility(SomeBase, wrong_instance)` 这类不匹配注册，新版本会报错并拒绝注册，请改为正确基类或显式 alias。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_bind_builder.gd`
- `addons/gf/core/gf_binder.gd`
- `addons/gf/core/gf_binding.gd`
- `addons/gf/core/gf_binding_lifetimes.gd`
- `addons/gf/core/gf_installer.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/docs/wiki/01. 架构概览 (Architecture).md`
- `addons/gf/docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `addons/gf/docs/wiki/04. 事件系统 (Event System).md`
- `addons/gf/docs/wiki/06. 命令与查询 (Commands & Queries).md`
- `addons/gf/docs/wiki/更新日志 (Changelog).md`
- `addons/gf/utilities/gf_quest_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_type_event_system.gd`

---

## [1.9.0] - 2026-04-27

**版本概述**：吸收依赖注入容器的装配经验，补强项目启动安装器、场景级局部上下文、父级架构回退与注册边界提示，同时修复事件系统遍历中先注册再注销的 pending 合并边缘问题。

### 🚀 新增特性 (Added)
- **项目级 Installer**：新增 `GFInstaller`，可在 `Project Settings > gf/project/installers` 中登记安装器脚本，由 `Gf.init()` / `Gf.set_architecture()` 在生命周期初始化前自动执行。
- **场景级 NodeContext**：新增 `GFNodeContext`，支持 `SCOPED` 与 `INHERITED` 两种模式；Scoped 架构会自动初始化、驱动 tick，并在节点退出树时释放局部模块。
- **父级架构回退**：`GFArchitecture` 新增父级架构引用，本地未找到依赖时可回退到父级架构查询，便于关卡、房间、调试面板等局部模块复用全局服务。
- **模块注入 Hook**：注册模块时，如果实例实现了 `inject_dependencies(architecture)`，框架会自动注入当前架构引用。
- **显式替换接口**：新增 `replace_model()` / `replace_system()` / `replace_utility()`，用于明确替换已注册模块并释放旧实例。
- **短生命周期对象工厂**：新增 `register_factory()` / `create_instance()`，用于创建 Command、Query、技能执行载体等无需进入生命周期的临时对象，并自动注入当前架构。

### 🔄 机制更改 (Changed)
- **重复注册显式提示**：重复调用 `register_model/system/utility()` 时不再静默忽略，而是输出 warning，并提示使用 replace 接口。
- **插件设置补齐**：编辑器插件现在会创建 `gf/project/installers` 项目设置，并在添加/移除 `Gf` AutoLoad 前检查 ProjectSettings 状态。
- **事件 pending 合并收敛**：类型事件与简单事件在遍历中先注册再注销同一回调时，会移除对应 pending add，避免下一次派发误触发。
- **上下文优先的基类访问**：`GFController` 会沿父节点查找最近的 `GFNodeContext`；注册到架构的 `GFModel`、`GFSystem`、`GFUtility` 以及经架构执行/创建的 `GFCommand`、`GFQuery` 会优先使用注入架构解析依赖。

### 🐛 Bug 修复 (Fixed)
- **事件回调残留**：修复同一轮事件派发中 `register -> unregister` 同一个回调后，该回调仍可能在 flush 后残留的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFInstaller.install(architecture: GFArchitecture) -> void`。
- 新增 `GFNodeContext`、`GFNodeContext.ScopeMode`、`GFNodeContext.context_ready`。
- 新增 `GFArchitecture.get_parent_architecture()` / `set_parent_architecture()`。
- 新增 `GFArchitecture.replace_model()` / `replace_system()` / `replace_utility()`。
- 新增 `GFArchitecture.register_factory()` / `replace_factory()` / `unregister_factory()` / `create_instance()`。
- 新增 `Gf.replace_model()` / `replace_system()` / `replace_utility()`。
- 新增 `Gf.unregister_model()` / `unregister_system()` / `unregister_utility()`。
- 新增 `Gf.register_factory()` / `replace_factory()` / `unregister_factory()` / `create_instance()`。
- `GFController.get_model()` / `get_system()` / `get_utility()` 现在优先使用最近的 `GFNodeContext`。

### 📘 升级指南 (Migration Guide)
1. 旧项目无需强制迁移；手写 boot 注册流程保持可用。
2. 若项目启动注册项越来越多，建议创建一个或多个 `GFInstaller`，并把路径加入 `gf/project/installers`。
3. 若存在关卡专属 System/Utility，建议用 `GFNodeContext.SCOPED` 承载，避免手动维护瞬态清理列表。
4. 若旧代码依赖重复注册静默忽略，当前版本会多一条 warning；如确实需要替换，请改用 `replace_*()`。
5. 如果某个 `GFController` 被放在 `GFNodeContext` 子树下，它现在会优先访问局部架构；若需要访问全局架构，请显式使用 `Gf.get_architecture()`。

### 📁 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/base/gf_command.gd`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_query.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_installer.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/plugin.gd`
- `addons/gf/docs/wiki/01. 架构概览 (Architecture).md`
- `addons/gf/docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_type_event_system.gd`

---

## [1.8.0] - 2026-04-26

**版本概述**：补齐小型游戏高频基础能力，收敛战斗修饰器语义、关卡流程、网格算法与常用表现动作，并同步修正文档和生成模板中的接口漂移。

### 🚀 新增特性 (Added)
- **网格算法基础件**：新增 `GFGridMath`，提供索引转换、邻居枚举、泛洪、BFS 寻路与两折连线判断。
- **关卡流程工具**：新增 `GFLevelUtility`，统一处理关卡开始、重开、胜利、失败信号，并可在重开时清理命令历史与表现队列。
- **常用表现动作**：新增 `GFMoveTweenAction`、`GFFlashAction` 与 `GFAudioAction`，覆盖移动、闪色、音效三类常见队列动作。

### 🔄 机制更改 (Changed)
- **生命周期推进顺序统一**：同一阶段内改为 `Model -> Utility -> System`，与文档和启动约定保持一致。
- **战斗修饰器语义收敛**：`GFModifier` 新增 `attribute_id` 与 `source_id`，明确区分“作用到哪个属性”和“来自哪个来源”。
- **Seed 分支 RNG 不污染主流**：`GFSeedUtility.get_branched_rng()` 改为基于主 RNG 状态与分支计数派生，不再推进主随机流。

### 🐛 Bug 修复 (Fixed)
- **Buff 属性挂载歧义**：修复 Buff 应用修饰器时把来源标识误当属性名的问题，并保留旧 `source_tag` 写法作为兼容回退。
- **文档与生成模板漂移**：修复命令返回值、状态机入口参数、撤销接口、数据绑定代码块、Controller 缓存说明等过期示例。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFModifier.attribute_id: StringName`。
- 新增 `GFModifier.source_id: StringName`。
- `GFModifier.create_base_add/create_percent_add/create_final_add()` 的第二参数现在表示 `attribute_id`，第三参数表示 `source_id`。
- `GFModifier.source_tag` 暂保留为兼容别名，会映射到 `source_id`。

### 📘 升级指南 (Migration Guide)
1. 旧项目如果用 `GFModifier.create_percent_add(0.2, &"STR")` 表示作用属性，无需修改。
2. 如果旧项目把第二参数当“来源”使用，请改为 `GFModifier.create_percent_add(0.2, &"ATK", &"SourceId")`，或显式设置 `source_id`。
3. 如果需要按来源批量移除修饰器，请使用 `remove_modifiers_by_source(source_id)` 并确保修饰器来源写入 `source_id`。

## [1.7.1] - 2026-04-25

**版本概述**：聚焦 1.7.0 引入 Foundation 后暴露出的数值边界，以及核心生命周期、命令历史和动作队列在异步场景下的稳定性，补齐若干会导致假完成、栈乱序或队列悬挂的防御。

### 🔄 机制更改 (Changed)
- **初始化等待语义收敛**：`GFArchitecture.init()` 在已有初始化流程进行中时，会等待该流程完成或被中断后再返回，不再让并发调用方提前越过生命周期屏障。
- **初始化中断保护**：`GFArchitecture.dispose()` 会让进行中的生命周期推进失效；旧的 `async_init()` await 恢复后不会继续写回已清理的架构状态。
- **Tick 遍历缓存**：`GFArchitecture.tick()` 与 `physics_tick()` 改为遍历注册时维护的可驱动模块缓存，减少每帧 `Dictionary.values()` 带来的数组分配。
- **命令历史异步互斥**：`GFCommandHistoryUtility` 在异步执行、撤销或重做尚未结束时，会拒绝新的历史变更，避免 undo/redo 栈顺序被完成时序污染。
- **动作队列等待超时**：`GFVisualAction` 新增 `signal_timeout_seconds` 与 `with_signal_timeout()`，默认 30 秒；等待信号长期不发时会输出 warning 并继续队列。
- **资源加载回调顺序收敛**：`GFAssetUtility` 在派发异步加载回调前会先移除对应 pending 项，允许回调内安全重新请求同一路径。

### 🐛 Bug 修复 (Fixed)
- **并发初始化假完成**：修复第二个 `await Gf.init()` 在第一轮初始化仍处于 `async_init()` 时直接返回的问题。
- **销毁后旧初始化写回**：修复 `dispose()` 中断初始化后，旧 await 恢复仍可能继续推进模块阶段并标记架构已初始化的问题。
- **无架构门面空引用**：修复 `Gf.get_model()` / `send_event()` 等门面方法在架构不存在时链式调用 null 的崩溃风险。
- **异步 undo/redo 栈污染**：修复多次触发异步撤销或重做时，命令按完成顺序回写导致历史栈乱序的问题。
- **Signal 永不发射卡队列**：修复动作返回的 Signal 长期不发且发射源仍有效时，`GFActionQueueSystem` 可能永久保持 processing 的问题。
- **定点数非法输入边界**：`GFFixedDecimal` 现在会拒绝 NaN/INF、畸形字符串和过大的小数位，避免整数缩放溢出或静默解析为错误数值。
- **大数字符串校验**：`GFBigNumber.from_string()` 现在会拒绝包含非法字符或重复小数点的输入。
- **定点数截断格式化失效**：修复 `GFNumberFormatter.format_full()` 对 `GFFixedDecimal` 忽略 `use_truncation` 的问题。
- **战斗扩展空值与标签边界**：修复空 Modifier、空 Skill/Buff、负数标签移除层数，以及缺少 TagComponent 时必需标签被绕过的边界问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFVisualAction.signal_timeout_seconds: float`。
- 新增 `GFVisualAction.with_signal_timeout(seconds: float) -> GFVisualAction`。
- 新增 `GFFixedDecimal.MAX_DECIMAL_PLACES`。
- `GFVisualAction` 等待 Signal 的默认行为增加 30 秒安全超时；如确实需要无限等待，可将 `signal_timeout_seconds` 设为 `0.0`。

### 📘 升级指南 (Migration Guide)
1. 如果项目中存在超长时间等待的自定义 `GFVisualAction`，请显式调用 `with_signal_timeout(0.0)` 关闭超时，或设置更符合业务的秒数。
2. 如果导表或存档会传入 `GFFixedDecimal` 的小数位，请确保不超过 `GFFixedDecimal.MAX_DECIMAL_PLACES`。
3. 如果之前依赖 `GFFixedDecimal.from_string()` / `GFBigNumber.from_string()` 对非法字符串的宽松解析，需要改为在上层清洗输入或处理返回零值的错误分支。
4. 如果有代码在异步 undo/redo 尚未完成时继续写入命令历史，应改为等待当前操作完成后再触发下一次历史变更。

### 📍 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/combat/gf_attribute.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/combat/gf_skill.gd`
- `addons/gf/extensions/combat/gf_tag_component.gd`
- `addons/gf/foundation/formatting/gf_number_formatter.gd`
- `addons/gf/foundation/math/gf_progression_math.gd`
- `addons/gf/foundation/numeric/gf_big_number.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_big_number.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_command_history_utility.gd`
- `tests/gf_core/test_gf_fixed_decimal.gd`
- `tests/gf_core/test_gf_number_formatter.gd`
- `tests/gf_core/test_gf_singleton.gd`

## [1.7.0] - 2026-04-24

**版本概述**：为挂机和模拟经营等高数值项目补出独立的 `Foundation` 基础层，明确纯算法/值对象与运行时 `Utility` 的边界，并正式引入大数、定点数、统一数值显示格式化与进度曲线数学能力。

### 🚀 新增特性 (Added)
- **Foundation 基础层**：新增 `addons/gf/foundation/` 目录，用于承载不进入 `GFArchitecture` 的纯值对象、纯算法和纯格式化工具。
- **大数值对象**：新增 `GFBigNumber`，使用尾数 + 指数表示超大数值，提供解析、比较、加减乘除、幂运算与科学计数法输出能力。
- **定点小数值对象**：新增 `GFFixedDecimal`，用于货币、税率、经营数值等对累计误差敏感的场景，支持缩放对齐、乘除和多种舍入策略。
- **统一数字格式化工具**：新增 `GFNumberFormatter`，支持 `FULL`、`COMPACT_SHORT`、`SCIENTIFIC`、`ENGINEERING` 与 `AUTO` 五种显示记法。
- **进度曲线数学工具**：新增 `GFProgressionMath`，提供价格曲线、收益曲线、分段配置、里程碑倍率、软上限与分段离线收益结算能力。
- **Foundation 文档页**：新增 Wiki 页面 `11. 基础层 (Foundation Layer)`，专门定义 `Foundation / Utility / Extension` 的边界。

### 🔄 机制更改 (Changed)
- **分层定义收敛**：`README`、架构概览与 Wiki 首页现在统一说明：`Foundation` 负责纯基础件，`Utility` 负责运行时服务；不再鼓励把所有通用能力都收纳到 `Utility`。
- **工具页职责收敛**：`08. 实用工具箱 (Utility Toolkit)` 现在明确只讨论需要注册到框架、参与生命周期的运行时工具。
- **脚本解析依赖收敛**：`GFBigNumber`、`GFFixedDecimal` 与 `GFNumberFormatter` 在跨脚本协作时改用显式 `load()` / `preload()` 路径，避免把运行与测试建立在 `.godot` 缓存文件之上。
- **Foundation 数学边界收敛**：价格/收益曲线、软上限和离线收益结算现在被归类为 `Foundation` 的纯公式能力；更高层的生产线模拟、建筑状态机与资源流转仍留给后续扩展层或具体项目实现。

### 🐰 Bug 修复 (Fixed)
- **定点小数字符串接口冲突**：避免 `GFFixedDecimal` 覆盖 `RefCounted/Object.to_string()` 的无参原生接口，改用语义更明确的 `to_decimal_string()`。

### 📢 API 变动说明 (API Changes)
- 新增 `GFBigNumber`
- 新增 `GFFixedDecimal`
- 新增 `GFNumberFormatter`
- 新增 `GFProgressionMath`
- 新增 `GFBigNumber.powi(power: int) -> GFBigNumber`
- 新增 `GFBigNumber.powf(power: float) -> GFBigNumber`
- 新增 `GFFixedDecimal.to_decimal_string(trim_zeroes: bool = false) -> String`

### 📌 升级指南 (Migration Guide)
1. 如果你之前打算把大数、定点数或数值显示格式化实现为 `GFUtility`，现在建议直接放进 `Foundation`，不要注册到 `Gf.register_utility()`。
2. 对挂机/放置类项目，超大量级资源建议优先使用 `GFBigNumber`；对模拟经营类项目，价格、费率与货币建议优先使用 `GFFixedDecimal`。
3. 需要 UI 显示缩写时，直接调用 `GFNumberFormatter.format_compact()` / `format_auto()`；不要把“显示转换”写回 `Model` 的真实存储字段。
4. 如果你的价格或收益曲线参数来自外部导表，推荐仍然把参数放在 JSON/CSV/Luban 里，但将公式执行统一收敛到 `GFProgressionMath`。
5. 如果后续需求开始涉及多建筑联动、资源链推演或生产队列模拟，请优先考虑放到后续 `Extension` 或项目层，而不是继续把高层玩法逻辑塞回 `Foundation`。

### 📍 核心受影响文件 (Affected Files)
- `README.md`
- `addons/gf/plugin.cfg`
- `addons/gf/foundation/formatting/gf_number_formatter.gd`
- `addons/gf/foundation/math/gf_progression_math.gd`
- `addons/gf/foundation/numeric/gf_big_number.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/docs/wiki/01. 架构概览 (Architecture).md`
- `addons/gf/docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `addons/gf/docs/wiki/11. 基础层 (Foundation Layer).md`
- `addons/gf/docs/wiki/Home.md`
- `addons/gf/docs/wiki/_Sidebar.md`
- `tests/gf_core/test_gf_big_number.gd`
- `tests/gf_core/test_gf_fixed_decimal.gd`
- `tests/gf_core/test_gf_number_formatter.gd`
- `tests/gf_core/test_gf_progression_math.gd`

## [1.6.5] - 2026-04-24

**版本概述**：聚焦一批高频基础能力的边界收敛与可维护性优化，重点补强数据绑定清理、属性只读封装、存档崩溃恢复，以及资源缓存配置变更的即时生效语义。

### 🚀 新增特性 (Added)
- **只读响应式属性视图**：新增 `GFReadOnlyBindableProperty`，用于对外暴露只读的绑定接口，同时保留 `get_value()`、`value_changed`、`bind_to()` 与 `unbind_all()` 等常用能力。

### 🔄 机制更改 (Changed)
- **属性只读封装收敛**：`GFAttribute.current_value` 现在通过只读访问器返回响应式结果视图，内部计算改为写入私有 `BindableProperty` 源对象，避免外部替换或直接改写最终值。
- **存档事务恢复前置化**：`GFStorageUtility` 在读写槽位与纯数据文件前，都会先尝试恢复遗留的 `.tmp` / `.bak` 事务文件；已提交主文件存在时会优先保留正式数据，并清理悬挂临时文件。
- **缓存上限即时生效**：`GFAssetUtility.max_cache_size` 改为带 setter 的运行时配置；调小容量时会立刻执行 LRU 淘汰，设为 `0` 时会立即清空现有缓存。

### 🐞 Bug 修复 (Fixed)
- **解绑后残留节点退出监听**：修复 `BindableProperty.unbind_all()` 只断开 `value_changed`、未同步移除 `bind_to()` 附加的 `tree_exited` 自动解绑监听的问题。
- **中断事务恢复缺口**：修复 `GFStorageUtility` 在进程中断后可能直接清理 `.bak` / `.tmp` 文件、导致错过恢复窗口的问题；现在会优先恢复最后一份可确认的有效数据。
- **属性最终值可被外部绕过公式改写**：修复 `GFAttribute.current_value` 可被调用方直接 `set_value()` 的封装漏洞；现在外部写入会被拒绝并输出明确错误提示。

### 📢 API 变动说明 (API Changes)
- 新增 `GFReadOnlyBindableProperty`。
- `GFAttribute.current_value` 仍可作为 `BindableProperty` 使用，但语义调整为只读视图；外部调用 `set_value()` 不再生效，并会输出错误日志。
- `GFAssetUtility.max_cache_size` 现在在运行中修改时会立即影响当前缓存，而不是等到下次 `put_cache()` 才生效。

### 📌 升级指南 (Migration Guide)
1. 如果旧项目曾直接调用 `attribute.current_value.set_value(...)` 或重写整个 `current_value` 属性，请改为通过 `set_base_value()`、增删 `GFModifier`，或在修改修饰器后调用 `force_recalculate()`。
2. 如果项目依赖 `GFAssetUtility` 在缩小 `max_cache_size` 后“暂不淘汰旧缓存”的旧行为，需要同步调整测试或监控逻辑，因为该属性现在会立刻收敛到新上限。
3. 如果项目中曾手动清理 `GFStorageUtility` 的 `.tmp` / `.bak` 文件，建议改为优先调用正式的读写接口，让恢复逻辑统一接管中断场景。

### 📍 核心受影响文件 (Affected Files)
- `addons/gf/core/bindable_property.gd`
- `addons/gf/core/gf_read_only_bindable_property.gd`
- `addons/gf/extensions/combat/gf_attribute.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_storage_utility.gd`

## [1.6.4] - 2026-04-22

**版本概述**：继续收敛一批运行时边界问题，重点补齐动态注册模块的初始化一致性、动作队列组合动作的等待安全、存档写入的事务回滚，以及战斗与对象池的状态自修复能力。

### 🔧 机制更改 (Changed)
- **动态注册模块生命周期补偿**：`GFArchitecture.init()` 现在按阶段推进 `Model/System/Utility` 生命周期，并会持续补齐初始化过程中动态注册的模块，确保其也能完整执行 `init()`、`async_init()` 与 `ready()`。
- **组合动作异步调度收敛**：`GFVisualActionGroup` 现在统一通过延迟调度启动并复用安全等待逻辑，顺序组在“全部为即时动作”时不会再因为返回信号过早发射而让队列错过连接时机。
- **存档写入改为临时文件提交**：`GFStorageUtility.save_slot()` 与 `save_data()` 现在先写入 `.tmp` 文件，再以提交/回滚流程覆盖正式文件，降低覆盖写入过程中出现半成功状态的概率。
- **模型快照键收敛为稳定标识**：`GFArchitecture` 生成可序列化 Model 快照时不再回退到运行时 `instance_id`；现在要求脚本具备 `class_name` 或有效 `resource_path`，以避免跨运行恢复失配。

### 🐞 Bug 修复 (Fixed)
- **初始化期新注册模块漏掉后续阶段**：修复模块在其他模块的 `init()` / `async_init()` / `ready()` 中被注册时，只执行部分生命周期、最终状态不一致的问题。
- **顺序组合动作偶发卡队列**：修复 `GFVisualActionGroup` 在顺序模式下包含纯同步动作时，`_sequence_completed` 可能早于外层等待方连接，导致动作队列长期不出队的问题。
- **等待信号发射源失效导致悬挂**：`GFActionQueueSystem` 与 `GFVisualActionGroup` 现在统一通过 `GFVisualAction.await_result_safely()` 处理等待对象失效、节点提前离树等情况，避免等待永远不结束。
- **槽位覆盖失败污染旧存档**：修复 `GFStorageUtility` 在覆盖现有槽位时 metadata 写入失败可能留下“部分新数据 + 部分旧文件”的混合状态问题。
- **技能与 Buff 缺失 owner**：`GFCombatSystem.add_skill()` / `add_buff()` 现在会在对象未显式设置 `owner` 时自动回填为目标实体，避免后续执行和属性修正依赖空 owner。
- **对象池死亡引用残留**：`GFObjectPoolUtility` 在获取、归还和统计前会先清理已释放或待删除节点，避免 `_all_nodes` / `_available_pools` 长期积累无效引用。

### 📢 API 变动说明 (API Changes)
- 新增 `GFVisualAction.await_result_safely(result: Variant) -> void`
- `GFArchitecture.get_all_models_state()` 与 `restore_all_models_state()` 现在会跳过缺少稳定标识的可序列化 Model，并通过 `push_error` 提示调用方修正脚本定义。

### 📌 升级指南 (Migration Guide)
1. 如果项目中存在运行时动态生成、且实现了 `to_dict()` / `from_dict()` 的匿名 `GFModel` 脚本，请为其补充 `class_name`，或改为可落盘脚本资源，避免快照恢复时被跳过。
2. 如果上层自定义 `GFVisualAction` 并需要等待异步结果，建议统一复用 `await_result_safely()`，不要再各自实现一套等待和失效保护逻辑。
3. 如果项目曾隐式依赖 `GFStorageUtility` 的“直接覆盖写入”行为，请留意同目录下会短暂出现 `.tmp` / `.bak` 事务文件；正常提交后这些文件会被自动清理。

### 📍 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_model_serialization.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_storage_utility.gd`

## [1.6.3] - 2026-04-21

**版本概述**：聚焦一批运行时一致性与边界稳定性修复，补齐时间控制定时器、异步命令历史、音频异步竞态、状态机热替换、战斗索引清理，以及对象池错误归还等高频运行路径的安全性。

### 🔧 机制更改 (Changed)
- **框架级定时器正式接入时间控制**：`GFTimerUtility` 改为由框架 `tick()` 推进的纯代码定时器，不再依赖 `SceneTree.create_timer()`；现在会遵循 `GFTimeUtility` 的 `time_scale` 与 `is_paused`。
- **命令历史快照补全 redo 栈**：`GFArchitecture.get_global_snapshot()` 现在会保存 `GFCommandHistoryUtility` 的完整历史，而不仅是 undo 栈；恢复时也会兼容旧版仅含数组的历史快照。
- **动作队列等待保护统一化**：`GFActionQueueSystem` 将所有需要等待的 `Signal` 统一走对象有效性守卫路径，非 `Node` 发射源失效时也会自动结束等待，避免卡死队列。

### 🐞 Bug 修复 (Fixed)
- **异步切场失败未清理瞬态实例**：`GFSceneUtility` 在异步加载失败时现在同样会执行 `cleanup_transients()`，避免 loading 流程中注册的临时 `System/Model` 残留。
- **异步命令过早写入撤销栈**：`GFCommandHistoryUtility.execute_command()` 现在会在异步命令真正完成后再记录到 undo 栈，避免“尚未落地就可撤销”的历史错位。
- **BGM 迟到回调覆盖新请求**：`GFAudioUtility` 为 BGM 异步加载增加请求序号守卫，旧请求完成时不再回写并覆盖最新播放结果。
- **活跃状态热替换悬挂**：`GFStateMachine.add_state()` 在替换当前激活状态时会先退出旧状态，再让新状态接管当前引用，避免 `_current_state` 指向已释放对象。
- **战斗实体索引残留**：`GFCombatSystem` 修复未注册实体的活跃索引移除错误，并在 `tick()` 中同步清理已释放实体的主索引与活跃索引。
- **无架构时战斗事件发送崩溃**：`GFCombatSystem` 现在只会在存在有效架构时分发战斗事件，未初始化框架时不再因事件总线缺失直接报错。
- **对象池误归还污染其他池**：`GFObjectPoolUtility.release()` 现在会基于节点记录的原始 `PackedScene` 回收到正确对象池，并对错误传入的 `scene` 发出警告。

### 📢 API 变动说明 (API Changes)
- 新增 `GFCommandHistoryUtility.serialize_full_history() -> Dictionary`
- 新增 `GFCommandHistoryUtility.deserialize_full_history(data: Dictionary, command_builder: Callable) -> void`
- `GFArchitecture.restore_global_snapshot()` 现在兼容两种命令历史格式：
  1. 旧版 `Array`
  2. 新版 `{ "undo": Array, "redo": Array }`

### 📌 升级指南 (Migration Guide)
1. 如果上层曾直接依赖 `GFArchitecture.get_global_snapshot()["command_history"]` 为数组，请更新为同时兼容 `Dictionary` 与旧版 `Array`。
2. 如项目中存在手动向 `GFObjectPoolUtility.release()` 传错 `scene` 的调用，当前版本会发出 warning；建议尽快改正调用点，而不是长期依赖回退修正。
3. 如需让延时逻辑受全局暂停和时间缩放控制，请优先使用已注册到架构中的 `GFTimerUtility`，而不是自行 `create_timer()`。

### 📍 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_timer_utility.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_audio_utility.gd`
- `tests/gf_core/test_gf_command_history_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_model_serialization.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `tests/gf_core/test_gf_timer_utility.gd`

## [1.6.2] - 2026-04-21

**版本概述**：收敛一批运行时稳定性与一致性问题，重点修复场景异步切换失败回退、战斗索敌形状缺口、UI 异步生命周期竞态，以及 Utility 在动态注销时的悬挂监听。
### 🔧 机制更改 (Changed)
- **场景异步切换失败回退**：`GFSceneUtility.load_scene_async()` 现在先发起目标场景加载请求，再决定是否切到 `loading scene`；只有在可恢复上一场景时才会进入过渡场景，并在加载成功后统一复位内部状态。
- **技能施法中心语义收敛**：`GFSkill.execute()` 的 `cast_center` 改为可选参数；未传值时回退到施法者位置，显式传入 `Vector2.ZERO` 时会被视为合法世界坐标，不再被误判为“未传中心点”。
- **索敌规则补齐形状参数**：`GFSkillTargetingRule` 新增 `rectangle_size`、`forward_direction` 与 `sector_angle_degrees`，将矩形/扇形索敌从“枚举已暴露、实现未落地”的状态收敛为可直接配置的正式能力。
- **UI 异步回调生命周期保护**：`GFUIUtility` 新增活跃态守卫，异步加载完成时会先确认 Utility 与目标 `CanvasLayer` 仍然有效，再决定是否实例化并入栈面板。
- **脚本头部规范收敛**：移除 `# path/to/file.gd` 形式的文件路径注释要求，统一以文件级 `##` 文档注释承担脚本头部说明，减少重复维护与纯样板差异。
### 🐞 Bug 修复 (Fixed)
- **loading scene 卡死恢复**：修复 `GFSceneUtility` 在目标资源不是 `PackedScene`、异步加载失败或切场景失败时可能把玩家留在 loading scene 的问题。
- **矩形/扇形索敌缺失**：修复 `GFSkillTargetingUtility` 对 `RECTANGLE` / `SECTOR` 仅做标签过滤、未做空间裁剪的问题。
- **手动指向技能默认中心错误**：修复手动目标校验直接使用 `Vector2.ZERO`，导致未传施法中心时不会回退到施法者位置的问题。
- **SimpleEvent 悬挂监听**：`GFQuestUtility.dispose()` 现在会反注册已绑定的 simple event；`GFConsoleUtility.dispose()` 也会主动断开 `GFLogUtility.log_emitted` 连接，避免动态注销后的悬挂回调。
- **存档槽位假阳性**：`GFStorageUtility.save_slot()` 现改为先写核心数据，再写 metadata；若新槽位 metadata 写入失败，会回滚已写入的数据文件，避免 `has_slot()` 误判。
- **资源异步失败不回调**：`GFAssetUtility` 现在在请求发起失败、资源无效或异步加载失败时也会回调监听者，并传入 `null` 资源，便于上层统一兜底。
- **命令历史接口补全**：补齐 `GFCommandHistoryUtility.execute_command()`，与现有文档示例和命令历史职责保持一致。
### 📢 API 变动说明 (API Changes)
- `GFSkill.execute(manual_target: Object = null, cast_center: Variant = null) -> void`
- `GFSkillTargetingRule.rectangle_size: Vector2`
- `GFSkillTargetingRule.forward_direction: Vector2`
- `GFSkillTargetingRule.sector_angle_degrees: float`
- `GFCommandHistoryUtility.execute_command(cmd: GFUndoableCommand) -> Variant`
### 📌 升级指南 (Migration Guide)
1. 之前通过 `Vector2.ZERO` 代表“未传施法中心”的调用方，需要改为直接省略第二个参数，或显式传入 `null`。
2. 需要矩形/扇形索敌的技能资源，现在应补充填写 `rectangle_size`、`forward_direction`、`sector_angle_degrees`，避免继续只依赖 `radius` 的旧配置。
3. 若上层逻辑依赖 `GFAssetUtility` 在失败时“静默不回调”，现在需要兼容 `null` 资源回调分支。
### 📍 核心受影响文件 (Affected Files)
- `CODING_STYLE.md`
- `addons/gf/extensions/combat/gf_skill.gd`
- `addons/gf/extensions/combat/gf_skill_targeting_rule.gd`
- `addons/gf/extensions/combat/gf_skill_targeting_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_combat_targeting.gd`
- `tests/gf_core/test_gf_ui_utility.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_gf_quest_utility.gd`
- `tests/gf_core/test_gf_console_utility.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_command_history_utility.gd`

---

## [1.6.1] - 2026-04-21

**版本概述**：修复纯代码状态机的 RefCounted 引用环风险，明确 context 的生命周期守卫语义，并补充状态机关键生命周期测试。

### 🔄 机制更改 (Changed)
- **StateMachine context 语义收敛**：`GFStateMachine.new(context)` 中的 `context` 现在仅作为可选生命周期守卫；未传入 context 时，状态机仍可通过全局 `Gf` 访问已初始化架构内的 Model/System/Utility。
- **同名状态替换清理**：`GFStateMachine.add_state()` 替换同名状态时会释放旧状态对状态机的引用，避免旧状态继续持有过期回链。
- **依赖访问前置保护**：`GFStateMachine.get_model/get_system/get_utility()` 会先检查 context 与架构可用性，失败时返回 `null` 并输出明确错误信息。

### 🐛 Bug 修复 (Fixed)
- **状态机引用环释放**：`GFState` 改为通过 `WeakRef` 持有所属 `GFStateMachine`，并新增释放路径，避免 `GFStateMachine -> GFState -> GFStateMachine` 形成 RefCounted 环状引用。
- **State 代理空引用保护**：未 setup 或已 dispose 的 `GFState` 调用 `get_model/get_system/get_utility/change_state()` 时不再因状态机引用为空而崩溃。
- **状态机销毁补全**：`GFStateMachine.dispose()` 会先退出当前状态，再释放所有已注册状态并清空 context 弱引用。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStateMachine.dispose() -> void`，用于显式释放状态机持有的状态与 context 引用。
- 新增 `GFState.dispose() -> void`，用于断开状态到所属状态机的弱引用。
- `GFStateMachine._init(context: Object = null)` 保持原签名，但 `context` 从必需访问前提调整为可选生命周期守卫。

### 📘 升级指南 (Migration Guide)
1. 如果某个 `GFSystem` 或 `GFUtility` 持有 `GFStateMachine`，建议在宿主 `dispose()` 中调用 `_fsm.dispose()`。
2. 旧的 `GFStateMachine.new()` 用法保持可用；如希望宿主销毁后阻止状态继续访问框架依赖，可改为 `GFStateMachine.new(self)`。
3. 如果重写了 `GFState.dispose()`，请在方法内调用 `super.dispose()`，否则状态可能继续保留状态机弱引用。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `tests/gf_core/test_gf_state_machine.gd`

---

## [1.6.0] - 2026-04-19

**版本概述**：补强运行时模块注册能力、抽象别名查询，以及 ActionQueue、简单事件、对象池在大型项目中的安全边界。

### 🚀 新增特性 (Added)
- **初始化后动态注册补偿**：`GFArchitecture.register_model/system/utility*()` 在架构已初始化后注册新模块时，会自动补跑该模块的 `init()` -> `async_init()` -> `ready()`，避免运行时热插模块只进入字典却未完成生命周期。
- **模块别名注册**：新增 `register_model_alias()` / `register_system_alias()` / `register_utility_alias()`，以及 `register_*_instance_as()` / `Gf.register_*_as()`，可将具体实现以抽象基类或接口式脚本暴露给调用方。
- **ActionQueue 显式 fire-and-forget**：`GFVisualAction` 新增 `CompletionMode` 与 `as_fire_and_forget()` / `as_wait_for_signal()`；`GFActionQueueSystem` 新增 `enqueue_fire_and_forget()` 与 `push_front_fire_and_forget()`。
- **对象池节点 Hook**：`GFObjectPoolUtility` 会在取出/归还节点时调用节点树上的 `on_gf_pool_acquire()` 与 `on_gf_pool_release()`，便于节点自清 Tween、信号和临时状态。

### 🔄 机制更改 (Changed)
- **按基类唯一匹配回退**：当 `get_model/system/utility()` 未命中精确脚本或 alias 时，会尝试在已注册实例中寻找唯一的继承匹配；若匹配多个，会警告并返回 `null`，要求使用显式 alias 消除歧义。
- **简单事件签名校验**：`TypeEventSystem.register_simple()` 现在与类型事件一样，会对对象方法形式的回调做参数数量校验，要求至少能接收一个 `payload` 参数。
- **Action 结果等待语义显式化**：队列等待不再只依赖“是否返回 Signal”的隐式约定；仍保持旧默认行为，但可通过 `completion_mode` 明确声明。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFArchitecture.register_system_alias(alias_cls, target_cls)` / `register_model_alias()` / `register_utility_alias()`。
- 新增 `GFArchitecture.register_system_instance_as(instance, alias_cls)` / `register_model_instance_as()` / `register_utility_instance_as()`。
- 新增 `Gf.register_system_as(instance, alias_cls)` / `register_model_as()` / `register_utility_as()`。
- 新增 `GFVisualAction.CompletionMode`、`GFVisualAction.completion_mode`、`GFVisualAction.as_fire_and_forget()`、`GFVisualAction.as_wait_for_signal()`、`GFVisualAction.should_wait_for_result(result)`。
- 新增 `GFActionQueueSystem.enqueue_fire_and_forget(action)` 与 `push_front_fire_and_forget(action)`。
- `GFObjectPoolUtility` 支持节点可选实现 `on_gf_pool_acquire()` 与 `on_gf_pool_release()`。

### 📘 升级指南 (Migration Guide)
1. 旧项目无需立即修改；默认注册、事件、队列等待语义保持兼容。
2. 如果项目有 `JSONConfigProvider extends GFConfigProvider` 这类抽象适配器，推荐使用 `Gf.register_utility_as(JSONConfigProvider.new(), GFConfigProvider)`，之后即可 `Gf.get_utility(GFConfigProvider)`。
3. 如果某个视觉动作只是启动动画、音效或粒子，不希望阻塞队列，请使用 `queue.enqueue_fire_and_forget(action)` 或 `action.as_fire_and_forget()`。
4. 对象池节点若持有 Tween、临时连接、一次性状态，建议实现 `on_gf_pool_release()` 清理，`on_gf_pool_acquire()` 重置。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_type_event_system.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`

---

## [1.5.1] - 2026-04-19

**版本概述**：补强事件系统嵌套派发安全性，并为命令历史提供显式异步撤销/重做入口。

### 🚀 新增特性 (Added)
- **异步命令历史操作**：`GFCommandHistoryUtility` 新增 `undo_last_async()` 与 `redo_async()`，当命令返回 `Signal` 时会等待完成后再移动撤销/重做栈。

### 🔄 机制更改 (Changed)
- **事件派发深度计数**：`TypeEventSystem` 将遍历中注册/注销的合并时机从单层布尔标记改为派发深度计数，嵌套事件会等到最外层派发结束后统一合并 pending 操作。
- **撤销命令返回值**：`GFUndoableCommand.undo()` 现在返回 `Variant`，与 `execute()` 一样可返回 `Signal` 表示异步撤销流程。

### 🐛 Bug 修复 (Fixed)
- **嵌套事件 pending 提前合并**：修复事件回调中再次发送事件时，内层派发可能提前合并外层注册/注销请求的问题。
- **同步 API 兼容性保护**：保留 `undo_last()` / `redo()` 的同步语义，避免因为异步支持导致所有旧调用点都必须改为 `await`。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFCommandHistoryUtility.undo_last_async() -> bool`。
- 新增 `GFCommandHistoryUtility.redo_async() -> bool`。
- `GFUndoableCommand.undo()` 签名由 `void` 调整为 `Variant`。

### 📘 升级指南 (Migration Guide)
1. 如果你的自定义命令重写了 `undo() -> void`，建议改为 `undo() -> Variant` 并在同步场景下 `return null`。
2. 如果撤销或重做过程需要等待动画、网络、资源加载等异步流程，请调用 `await history.undo_last_async()` 或 `await history.redo_async()`。
3. 已有纯同步项目可继续使用 `undo_last()` 与 `redo()`，无需立即改动调用点。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/type_event_system.gd`
- `addons/gf/utilities/gf_command_history_utility.gd`
- `addons/gf/extensions/command/gf_undoable_command.gd`
- `tests/gf_core/test_type_event_system.gd`
- `tests/gf_core/test_gf_command_history_utility.gd`

---

## [1.5.0] - 2026-04-18

**版本概述**：稳定框架启动协议与运行时调度边界，修复对象池、战斗实体注销、异步资源多回调等关键可靠性问题，并同步 README 与测试覆盖。

### 🚀 新增特性 (Added)
- **Gf 启动入口补全**：新增 `Gf.init()`，支持先调用 `Gf.register_model()` / `Gf.register_system()` / `Gf.register_utility()`，再统一初始化架构。
- **架构懒创建能力**：新增 `Gf.create_architecture()` 与 `Gf.has_architecture()`，让框架入口能在首次注册模块时自动创建默认 `GFArchitecture`。
- **只读架构属性**：新增 `Gf.architecture` 只读访问器，用于与文档中的快照示例保持一致。
- **Utility 暂停控制**：`GFUtility` 新增 `ignore_pause`，带 `tick()` / `physics_tick()` 的 Utility 可选择在全局暂停时接收原始 delta。

### 🔄 机制更改 (Changed)
- **统一 Tick 调度**：`GFArchitecture.tick()` 与 `physics_tick()` 现在会驱动已注册 System，以及实现了 `tick()` / `physics_tick()` 的 Utility。
- **异步资源回调合并**：`GFAssetUtility.load_async()` 对同一路径的并发请求不再丢弃后续回调，资源完成后会广播给所有等待者。
- **对象池回收状态**：`GFObjectPoolUtility.release()` 现在会隐藏 `CanvasItem`、禁用节点处理，并在重新 `acquire()` 时恢复原状态。
- **日志文件命名**：`GFLogUtility` 日志文件名增加秒与毫秒，降低同一分钟内重复初始化覆盖日志的概率。

### 🐛 Bug 修复 (Fixed)
- **Utility 注册空脚本保护**：修复 `register_utility_instance()` 在脚本为空时报错后仍继续注册 `null` 键的问题。
- **战斗活跃索引清理**：修复 `GFCombatSystem.unregister_entity()` 使用错误键清理 `_active_entities`，导致注销实体仍可能被 tick 处理的问题。
- **无架构查询降噪**：部分 Utility 在查询架构前会先通过 `Gf.has_architecture()` 判断，减少未初始化场景下的误报错误日志。

### 🔌 API 变动说明 (API Changes)
- 新增 `Gf.init() -> void`。
- 新增 `Gf.create_architecture() -> GFArchitecture`。
- 新增 `Gf.has_architecture() -> bool`。
- 新增只读属性 `Gf.architecture: GFArchitecture`。
- 新增 `GFUtility.ignore_pause: bool`。
- 原有 `Gf.set_architecture(architecture_instance)` 保持可用，语义仍为设置并初始化指定架构。

### 📘 升级指南 (Migration Guide)
1. 推荐启动流程更新为：先 `Gf.register_*()` 注册模块，再 `await Gf.init()` 启动生命周期。
2. 若使用自定义 `GFArchitecture`，请先把模块注册到该架构实例，再调用 `await Gf.set_architecture(arch)`。
3. 若自定义 Utility 实现了 `tick()`，从 1.5.0 起会被架构自动驱动；如该 Utility 不应自动更新，请移除 `tick()` 或在内部自行控制开关。
4. 若对象池节点依赖回收后继续可见或继续 process，需要改为在 `acquire()` 后重新显式开启相关表现逻辑。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `README.md`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`

---

## [1.4.1] - 2026-03-27

**版本概述**：修复 `GFObjectPoolUtility` 的重复归还与死对象（Dead Object）断言报错引发的崩溃问题。

### 🐛 Bug 修复 (Fixed)
- **对象池引用保护**：修复了在 `GFObjectPoolUtility` 中高频或意外对同一节点多次调用 `release()` 操作时，同一对象多次插入可用对象列表（Available Pool），造成后续重用冲突的问题。
- **安全对象推测**：修复了若节点在未触发 `release` 或已经处于池中时，遭到外部环境强行 `queue_free()` 销毁。下一次对象池因分配资源而调用 `acquire()` 取出此变量时，进行 `as Node` 的强类型安全检查时引发的引发变量转换失败级引擎层面报错。

### 📘 升级指南 (Migration Guide)
1.4.1 核心修补了引擎处理死对象赋值特性和自身管理漏洞，无需修改原有项目代码，覆盖更新即可。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_object_pool_utility.gd`
