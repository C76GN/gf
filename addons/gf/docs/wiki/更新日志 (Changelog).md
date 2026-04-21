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
