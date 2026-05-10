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

## 维护策略

本页面只保留最近三个版本线的更新记录，当前保留 `2.3.x`、`2.2.x` 与 `2.1.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [2.3.0] - 2026-05-10

**版本概述**：补齐 `GFStorageUtility` 在存储根目录内管理通用文件的公开入口，便于项目在不绕过框架路径安全策略的前提下维护缓存、缩略图、manifest 或自定义资源。

### 🚀 新增特性 (Added)
- `GFStorageUtility` 新增 `ensure_directory()`、`list_files()` 与 `delete_file()`，用于创建存储目录、按扩展名枚举文件和删除存储相对文件；默认继续拒绝绝对路径并阻止 `..` 跨目录。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageUtility.ensure_directory(directory_name := "") -> Error`。
- 新增 `GFStorageUtility.list_files(directory_name := "", extension_filter := "", recursive := false) -> PackedStringArray`。
- 新增 `GFStorageUtility.delete_file(file_name: String) -> Error`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。已有槽位读档 UI 继续使用 `list_slots()`；只有需要管理存储根目录下的普通文件时再使用新增文件管理 API。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_storage_utility.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

---

## [2.2.0] - 2026-05-10

**版本概述**：补齐两个通用运行时辅助能力，分别覆盖安全富文本格式化和状态快照级回滚，保持框架抽象边界，不引入项目业务流程。

### 🚀 新增特性 (Added)
- 新增 `GFRichTextFormatter`，提供 BBCode 安全转义、Markdown 常见子集转 BBCode、变量占位符替换和可配置 token 替换，适合把外部文本、本地化参数或项目生成图标片段安全写入 `RichTextLabel`。
- 新增 `GFSnapshotHistoryUtility`，提供通用快照栈、按 ID/索引恢复、前后跳转、历史上限裁剪、调试快照和默认架构全局快照捕获/恢复；也支持通过自定义回调接入任意项目状态。

### 🐛 Bug 修复 (Fixed)
- 修复新增富文本测试中的局部参数名 shadow `Node.name` 警告，避免 Godot 以 `SHADOWED_VARIABLE_BASE_CLASS` 报告测试脚本。

### 🔌 API 变动说明 (API Changes)
- 新增公开类 `GFRichTextFormatter`，包含 `to_bbcode()`、`markdown_to_bbcode()`、`replace_variables()`、`replace_tokens()`、`escape_bbcode()` 与 `strip_bbcode()`。
- 新增公开类 `GFSnapshotHistoryUtility`，包含 `snapshot_recorded`、`snapshot_restored`、`history_changed` 信号，`max_history_size`、`current_index`、`snapshot_count` 属性，以及 `configure()`、`capture()`、`push_snapshot()`、`step_back()`、`step_forward()`、`restore_index()`、`restore_snapshot_id()`、`get_current_snapshot()`、`get_history()`、`clear()` 和 `get_debug_snapshot()`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要安全拼接富文本或做状态快照级回滚时按需引入新增类。
- `GFSnapshotHistoryUtility` 是状态快照历史，不替代逐命令撤销的 `GFCommandHistoryUtility`，也不替代持久化写盘的 `GFStorageUtility`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_rich_text_formatter.gd`
- `addons/gf/utilities/gf_snapshot_history_utility.gd`
- `tests/gf_core/test_gf_rich_text_formatter.gd`
- `tests/gf_core/test_gf_snapshot_history_utility.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`

---

## [2.1.1] - 2026-05-10

**版本概述**：修复场景切换在 `_ready()` 或初始化完成后立即调用时可能触发的 Godot 场景树时序错误，并明确缓存命中切场的异步完成语义。

### 🐛 Bug 修复 (Fixed)
- `GFSceneUtility` 的 loading scene 切入、缓存命中目标切换和失败恢复现在统一延迟到安全帧执行，避免在 `_ready()` 或初始化完成后立刻调用 `load_scene_async()` 时触发 Godot 的 `Parent node is busy adding/removing children` 场景树时序错误。

### 🔄 机制更改 (Changed)
- 命中预加载缓存的 `load_scene_async()` 不再保证在同一调用栈内完成切场；请继续通过 `scene_load_completed` / `scene_switch_completed` 或下一帧后的状态读取确认切换完成。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_scene_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`

---

## [2.1.0] - 2026-05-10

**版本概述**：在 2.0.0 基础上继续收敛高收益通用能力，补齐存储后端同步协调、节点状态 Resource 组合钩子、行为树节点集、动作队列易用层和若干纯算法/运行时辅助。

### 🚀 新增特性 (Added)
- 新增 `GFStorageSyncUtility`，基于 `GFStorageBackend` 和 `GFStorageConflictReport` 协调两个字典存储后端的单文件或批量同步，支持 newest/local/remote/manual/custom 冲突策略、dry-run 写回开关、写回结果和调试快照。
- 新增 `GFNodeStateCondition` 与 `GFNodeStateBehavior`，可作为 Resource 挂到 `GFNodeState.enter_conditions`、`exit_conditions` 和 `behaviors`，复用进入/退出条件、生命周期行为和状态事件处理。
- `GFBehaviorTree` 新增 `Parallel`、`RandomSelector`、`RandomSequence`、`AlwaysSucceed`、`AlwaysFail`、`Limit`、`Repeat`、`UntilSuccess`、`UntilFail` 与 `ParallelPolicy`，补齐常见纯代码行为树组合节点。
- 新增 `GFAction`、`GFCallableAction`、`GFWaitAction` 与 `GFRepeatAction`，为 `GFActionQueueSystem` 提供常见表现动作工厂、回调动作、等待动作和重复动作。
- 新增 `GFSteeringAgent`、`GFSteeringAcceleration` 与 `GFSteeringMath`，提供 seek/flee/arrive/pursue/evade/face/separation/cohesion/blend/priority/path follow 等纯 steering 原语。
- 新增 `GFPattern2D` 与 GF Pattern2D Inspector 网格编辑器，用于资源化编辑通用二维格子模式。
- 新增 `GFViewportUtility`，提供通用 SubViewport 分屏布局、相机挂载、后处理材质和调试快照。
- 新增 `GFInputDirectionHistory`，提供最后按下方向优先的通用方向输入仲裁。
- 新增 `GFNetworkReconnectPolicy`，提供可复用的网络重连退避策略。
- 新增 `GFTextFitUtility`，提供 Label / RichTextLabel 的通用字体尺寸适配辅助。
- 新增 `GFInputSequenceBranch` 与 `GFInputSequenceStep`，让 `GFInputSequenceTrigger` 支持多分支、单步间隔、按住时间和释放完成条件。
- 新增 `GFHitBoxState2D` 与 `GFHitBoxState3D`，用于统一启停命中/受击区域组。
- 新增 `GFDerivedAttributeRule`，为 `GFAttributeSet` 提供通用派生属性计算规则。

### 🔄 机制更改 (Changed)
- `GFNodeState` 在保留继承式虚方法为主控制路径的基础上，新增 Resource 条件和行为调度；条件与 `_can_enter()` / `_can_exit()` 共同决定守卫结果，行为在状态自身虚方法之后执行。
- `GFActionQueueSystem` 新增当前动作暂停、恢复、完成和查询 API；`GFVisualAction` 新增 `pause()`、`resume()` 与 `finish()` 可重写控制钩子。
- `GFBindableProperty` 新增 `mutate()` 与 Array/Dictionary 原地修改辅助，便于引用类型变化后同步触发 `value_changed`。
- `GFAccessGenerator` 的项目常量访问器现在只采集项目保存的 InputMap 动作，并稳定包含 GF 已知 ProjectSettings 键；编辑器专用动作不再进入 `GFProjectAccess.InputActions`。
- `GFViewportUtility` 新增屏幕/世界坐标转换、3D 屏幕射线和射线检测辅助，并在非 stretch 分屏布局中稳定保留配置渲染尺寸。
- `GFInputMappingUtility` 新增动作 just-completed 与最近完成持续时间记录，供释放型触发器或项目层查询。
- `GFAttributeSet` 可注册派生属性规则，并在来源属性变化后自动重算依赖属性。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageSyncUtility.sync_data(file_name, local_backend, remote_backend, options)`、`sync_many(file_names, local_backend, remote_backend, options)` 和相关 `ConflictStrategy` / `SyncStatus` 枚举。
- 新增 `GFNodeStateCondition.evaluate(state, phase, peer_state, args)` 与 `GFNodeStateBehavior` 的 `initialize()`、`enter()`、`exit()`、`pause()`、`resume()`、`handle_state_event()` 钩子。
- `GFNodeState` 新增导出数组 `enter_conditions`、`exit_conditions` 与 `behaviors`。这是向后兼容新增；旧状态脚本无需迁移。
- 新增 `GFActionQueueSystem.pause_current_action()`、`resume_current_action()`、`finish_current_action()` 与 `get_current_action()`；新增 `GFVisualAction.pause()`、`resume()` 与 `finish()`。
- 新增 `GFBindableProperty.mutate()`、`append_to_array()`、`append_array()`、`erase_from_array()`、`set_dictionary_value()`、`erase_dictionary_key()` 与 `clear_collection()`。
- 新增 `GFPattern2D`、`GFViewportUtility`、`GFTextFitUtility`、`GFInputDirectionHistory`、`GFInputSequenceBranch`、`GFInputSequenceStep`、`GFNetworkReconnectPolicy`、`GFHitBoxState2D`、`GFHitBoxState3D`、`GFDerivedAttributeRule` 和 steering/action helper 相关公开类。均为向后兼容新增。
- `GFInputMappingUtility` 新增 `was_action_just_completed()`、`get_last_completed_duration()`、`was_action_just_completed_for_player()` 与 `get_last_completed_duration_for_player()`。
- `GFViewportUtility` 新增 `screen_to_world_ray_3d()`、`raycast_from_screen_3d()`、`world_to_screen_3d()`、`world_to_screen_2d()` 与 `screen_to_world_2d()`。
- `GFAttributeSet` 新增 `derived_rules`、`add_derived_rule()`、`remove_derived_rule()`、`get_derived_rule()` 与 `recalculate_derived()`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要多后端存储同步时，先把本地、云端或平台存储适配为 `GFStorageBackend`，再由 `GFStorageSyncUtility` 选择或合并记录。
- 如果后端元数据没有可比较的 revision/timestamp，不要依赖默认 newest 策略自动猜测；应显式使用 local/remote/manual/custom 策略。
- 复杂状态仍建议写成 `GFNodeState` 子类；可复用、可配置、可组合的守卫和横切行为再抽为 `GFNodeStateCondition` / `GFNodeStateBehavior`。
- 旧项目无需迁移。需要更丰富行为树、表现队列工厂、steering、二维 pattern、分屏或输入方向仲裁时，可按需引入新增类；不要把它们作为项目必须采用的业务层规范。
- 旧输入序列资源可继续使用 `required_action_ids`。需要释放型序列或多条可替代序列时，再按需迁移到 `GFInputSequenceBranch` / `GFInputSequenceStep`。
- 属性规则、命中区域状态组和文本适配都为可选能力；项目应只在确实能减少重复代码或提升抽象边界时引入。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_storage_sync_utility.gd`
- `addons/gf/utilities/gf_behavior_tree.gd`
- `addons/gf/utilities/gf_viewport_utility.gd`
- `addons/gf/utilities/gf_text_fit_utility.gd`
- `addons/gf/core/gf_bindable_property.gd`
- `addons/gf/extensions/action_queue/**`
- `addons/gf/extensions/network/gf_network_reconnect_policy.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `addons/gf/extensions/state_machine/gf_node_state_condition.gd`
- `addons/gf/extensions/state_machine/gf_node_state_behavior.gd`
- `addons/gf/foundation/math/gf_pattern_2d.gd`
- `addons/gf/foundation/math/gf_steering_agent.gd`
- `addons/gf/foundation/math/gf_steering_acceleration.gd`
- `addons/gf/foundation/math/gf_steering_math.gd`
- `addons/gf/input/gf_input_direction_history.gd`
- `addons/gf/input/gf_input_sequence_trigger.gd`
- `addons/gf/input/gf_input_sequence_branch.gd`
- `addons/gf/input/gf_input_sequence_step.gd`
- `addons/gf/extensions/combat/gf_hit_box_state_2d.gd`
- `addons/gf/extensions/combat/gf_hit_box_state_3d.gd`
- `addons/gf/extensions/domain/gf_derived_attribute_rule.gd`
- `addons/gf/editor/gf_pattern_2d_inspector_plugin.gd`
- `addons/gf/editor/gf_pattern_2d_editor_property.gd`
- `tests/gf_core/test_gf_storage_sync_utility.gd`
- `tests/gf_core/test_gf_node_state_resources.gd`
- `tests/gf_core/test_gf_behavior_tree.gd`
- `tests/gf_core/test_gf_visual_actions.gd`
- `tests/gf_core/test_gf_action_queue.gd`
- `tests/gf_core/test_gf_steering_math.gd`
- `tests/gf_core/test_gf_pattern_2d.gd`
- `tests/gf_core/test_gf_viewport_utility.gd`
- `tests/gf_core/test_gf_text_fit_utility.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_domain_extensions.gd`
- `tests/gf_core/test_gf_input_direction_history.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/05. 数据绑定 (Data Binding).md`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `README.md`
- `addons/gf/README.md`
