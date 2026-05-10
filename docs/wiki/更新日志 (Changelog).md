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

本页面只保留最近三个版本线的更新记录，当前保留 `2.1.x`、`2.0.x` 与 `1.34.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

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

---

## [2.0.0] - 2026-05-10

**版本概述**：GF 2.0.0 破坏性清理版本，移除已经影响默认行为清晰度的 1.x 兼容层，并把安全、校验和命名一致性作为新的默认约束。

### 🔄 机制更改 (Changed)
- `GFFlowGraph.validate_port_compatibility` 默认改为 `true`，端口值类型或 Object 类名提示不兼容时，校验和新增连接都会默认拒绝。
- `GFStorageUtility.allow_absolute_paths` 默认改为 `false`，传入绝对路径时默认收敛到当前存档目录下的同名文件。
- `GFStorageUtility.require_integrity_checksum` 与 `GFStorageCodec.require_integrity_checksum` 默认改为 `true`，启用完整性校验后，缺失 `_meta.checksum` 的载荷会默认读取失败。
- `GFStorageUtility` 与 `GFStorageCodec` 默认关闭旧版纯 JSON 回退；配置混淆、压缩或 Binary 后，解码失败不会再自动读取未混淆 JSON 原始 bytes。
- `GFStorageUtility.normalize_json_numbers` 与 `GFStorageCodec.normalize_json_numbers` 默认改为 `false`，JSON 读取默认保留解析出的数字类型。
- `gf/project/fail_on_installer_error` 默认改为 `true`，项目级 Installer 路径为空、脚本无法加载或未继承 `GFInstaller` 时会默认中断架构初始化。
- `BindableProperty` 重命名为 `GFBindableProperty`，文件从 `addons/gf/core/bindable_property.gd` 改为 `addons/gf/core/gf_bindable_property.gd`。
- `TypeEventSystem` 重命名为 `GFTypeEventSystem`，文件从 `addons/gf/core/type_event_system.gd` 改为 `addons/gf/core/gf_type_event_system.gd`。
- `GFTypeEventSystem.max_dispatch_depth` 默认改为 `64`，递归事件派发链会默认启用嵌套深度保护。
- `GFNetworkMessageValidator.max_packet_size` 默认改为 `64 KiB`，网络消息默认启用全局包体上限。
- `GFNetworkUtility` 入站通道匹配不再读取业务 `payload.channel_id` 字段；通道应写入 `GFNetworkMessage.channel_id` 元信息，或使用与 `message_type` 同名的通道。
- `GFNodeStateMachine.start_mode` 默认改为 `AFTER_HOST_READY`，初始状态默认等待宿主节点 `_ready()` 完成后再进入。
- `GFCapability`、`GFNodeCapability`、`GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability` 的默认依赖移除策略改为 `REMOVE_AUTO_DEPENDENCIES`，主能力移除后会清理仅由它自动补齐且未被显式添加的依赖能力。
- `GFSeedUtility.set_full_state()` 只接收 `get_full_state()` 产生的完整状态字典，不再把整数主 RNG 状态作为完整状态入口。
- `GFBuff` 应用和移除修饰器时只使用 `GFModifier.attribute_id` 查找目标属性，不再把 `source_id` 当作目标属性回退。

### 🐛 Bug 修复 (Fixed)
- 修复 `GFStorageCodec` JSON checksum 在不同 Godot JSON 数字解析结果下可能把合法载荷误判为损坏的问题；checksum 输入会稳定规范化整数字面量，但不会改变 `decode()` 返回的数据类型。
- 修复配置混淆密钥读取旧版纯 JSON 时，非法 base64 文本可能触发 Godot 引擎错误并污染测试结果的问题。

### ⚠️ 废弃与移除 (Deprecated/Removed)
- 移除 `GFModifier.source_tag` 旧字段别名。
- 移除 `GFBuff` 对空 `attribute_id` 的 `source_id` 兼容回退。
- 移除无 `GF` 前缀的公开类名 `BindableProperty` 与 `TypeEventSystem`。

### 🔌 API 变动说明 (API Changes)
- 旧代码中的 `BindableProperty` 需要改为 `GFBindableProperty`；旧文件路径 `res://addons/gf/core/bindable_property.gd` 需要改为 `res://addons/gf/core/gf_bindable_property.gd`。
- 旧代码中的 `TypeEventSystem` 需要改为 `GFTypeEventSystem`；旧文件路径 `res://addons/gf/core/type_event_system.gd` 需要改为 `res://addons/gf/core/gf_type_event_system.gd`。
- 旧代码中的 `modifier.source_tag = &"ATK"` 需要改为 `modifier.attribute_id = &"ATK"`；若该修饰器还需要按来源移除，应额外设置 `modifier.source_id`。
- 旧资源若依赖不兼容 FlowGraph 端口连接，需要显式把 `validate_port_compatibility` 设为 `false` 作为过渡，或修正端口类型。
- 可信编辑器工具若确实需要读写绝对路径，需要显式设置 `GFStorageUtility.allow_absolute_paths = true`。
- 旧存档若已经启用完整性校验但历史文件没有 `_meta.checksum`，迁移脚本需要临时设置 `require_integrity_checksum = false`，读取后再按新设置写回。
- 旧存档若依赖“配置混淆、压缩或 Binary 失败后仍按纯 JSON 读取”的回退，需要临时设置 `allow_legacy_plain_json_fallback = true`，读取后再按新 codec 设置写回。
- 旧存档若依赖 JSON 读取时把 `1.0` 归一为 `1`，需要临时设置 `normalize_json_numbers = true`，迁移后按新默认保留 JSON 数字类型。
- 旧项目若暂时需要跳过无效项目级 Installer，需要显式把 `Project Settings > gf/project/fail_on_installer_error` 设为 `false`。
- 旧项目若刻意依赖无限递归事件链，需要显式设置 `GFTypeEventSystem.max_dispatch_depth = 0`，或通过 `Gf.configure_event_debugging(0, ...)` 关闭保护。
- 旧项目若需要发送超过 `64 KiB` 的网络消息，需要显式调大 `GFNetworkMessageValidator.max_packet_size`，或设为 `0` 关闭全局包体上限。
- 旧代码若把通道标识放在业务 `payload["channel_id"]` 中，需要改为设置 `GFNetworkMessage.channel_id`，或统一使用 `send_message_on_channel()`。
- 旧项目若依赖 `GFNodeStateMachine` 在宿主 `_ready()` 前进入初始状态，需要显式设置 `start_mode = GFNodeStateMachine.StartMode.ON_READY`。
- 旧能力若依赖“移除主能力后自动补齐的依赖能力继续保留”，需要重写 `get_dependency_removal_policy()` 并返回 `GFCapabilityUtility.DependencyRemovalPolicy.KEEP_DEPENDENCIES`。
- 旧代码若调用 `set_full_state(rng_state_int)`，需要改为 `set_state(rng_state_int)`；完整回放状态应传入 `get_full_state()` 返回的字典。
- 新增 `GFStorageUtility.allow_legacy_plain_json_fallback`、`GFStorageCodec.allow_legacy_plain_json_fallback`、`GFTypeEventSystem.DEFAULT_MAX_DISPATCH_DEPTH` 和 `GFNetworkMessageValidator.DEFAULT_MAX_PACKET_SIZE`。

### 📘 升级指南 (Migration Guide)
- 全局搜索 `BindableProperty` 和 `TypeEventSystem`，分别替换为 `GFBindableProperty` 和 `GFTypeEventSystem`；同时更新任何手写 preload 路径。
- 扫描项目中 `source_tag` 的使用，改成 `attribute_id`；不要再把 `source_id` 作为目标属性名。
- 对已有 FlowGraph 资源运行 `validate_graph()`，修复 `incompatible_connection_ports` 报告；短期迁移可关闭单个资源的 `validate_port_compatibility`。
- 审查所有传给 `GFStorageUtility` 的路径。运行时和用户输入路径应保持默认拒绝绝对路径；只有受信任的编辑器工具链才启用绝对路径。
- 启用 `use_integrity_checksum` 的项目应检查旧存档是否都包含 `_meta.checksum`；缺失时先用 `require_integrity_checksum = false` 做一次迁移写回，再恢复默认严格读取。
- 如果旧项目曾把未混淆 JSON 文件交给已配置混淆密钥、压缩或 Binary 的存档工具读取，迁移时先打开 `allow_legacy_plain_json_fallback`，读出后立即用当前 codec 重新保存。
- 如果旧逻辑区分 `int` 和 `float`，检查 JSON 存档中 `1.0` 这类值；迁移阶段可打开 `normalize_json_numbers` 保持旧行为。
- 检查 `Project Settings > gf/project/installers`。修复空路径、加载失败或未继承 `GFInstaller` 的脚本；只在迁移期临时关闭 `gf/project/fail_on_installer_error`。
- 检查会在事件回调中再次派发事件的逻辑。正常业务链应不受 `64` 层限制影响；确实需要更深或无限制时，显式调整 `max_dispatch_depth`。
- 检查网络同步、存档同步或调试快照消息大小。超过 `64 KiB` 的消息应拆分、压缩、走专用通道，或显式调整校验器上限。
- 检查自定义网络后端或协议适配层。逻辑通道应通过消息元信息传递，不再塞进业务 payload 字段。
- 检查场景中的 `GFNodeStateMachine`。依赖旧 `_ready()` 顺序的状态机显式设为 `ON_READY`；依赖宿主初始化完成的状态机可使用新的默认值。
- 检查带 `get_required_capabilities()` 的能力。若依赖能力本身承载长期状态，应在项目中显式添加该依赖，或让主能力返回 `KEEP_DEPENDENCIES`。
- 检查随机回放或存档代码。保存完整随机状态时使用 `get_full_state()`，只保存主 RNG 整数状态时使用 `get_state()` / `set_state()`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_bindable_property.gd`
- `addons/gf/core/gf_computed_property.gd`
- `addons/gf/core/gf_reactive_effect.gd`
- `addons/gf/core/gf_read_only_bindable_property.gd`
- `addons/gf/core/gf_type_event_system.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/plugin.gd`
- `addons/gf/extensions/capability/gf_capability.gd`
- `addons/gf/extensions/capability/gf_node_capability.gd`
- `addons/gf/extensions/capability/gf_node_2d_capability.gd`
- `addons/gf/extensions/capability/gf_node_3d_capability.gd`
- `addons/gf/extensions/capability/gf_control_capability.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/extensions/network/gf_network_message.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/network/gf_network_message_validator.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/input/gf_input_binding.gd`
- `addons/gf/utilities/gf_storage_codec.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_seed_utility.gd`
- `addons/gf/extensions/combat/gf_modifier.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_bindable_property.gd`
- `tests/gf_core/test_gf_type_event_system.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_storage_codec.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_gf_combat_extension.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `README.md`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `docs/wiki/03. 更新机制 (Update Loop).md`
- `docs/wiki/04. 事件系统 (Event System).md`
- `docs/wiki/05. 数据绑定 (Data Binding).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/09. 最佳实践 (Best Practices).md`
- `docs/wiki/10. 战斗扩展 (Combat Extension).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`

---

## [1.34.0] - 2026-05-09

**版本概述**：新增一组通用运行时准备、诊断报告、输入图标、网络同步原语和 FlowGraph 编辑器元数据能力，保持 GF 1.x 兼容。

### 🚀 新增特性 (Added)
- 新增 `GFRenderWarmupManifest` 与 `GFRenderWarmupUtility`，支持按清单或节点树收集渲染资源，并按帧预算预热 Mesh、Material、Texture、Shader 等通用资源。
- 新增 `GFSupportReportUtility`，支持聚合用户描述、构建信息、诊断快照、日志和项目自定义分区，并导出 JSON、写入文件或交给项目回调提交。
- 新增 `GFInputIconAtlasProvider`，通过显式路径、纹理映射或路径模板把输入事件解析为项目自有图标资源。
- 新增 `GFFixedTickClock`、`GFNetworkSnapshot` 与 `GFNetworkHistoryBuffer`，提供固定 tick、状态快照、浅层 delta 和有限历史缓冲原语。
- 新增 `GFScriptTypeUtility` 与 `GFDecimalStringUtility`，将脚本继承判断和小数字符串规则收敛为可复用 Foundation API。

### 🔄 机制更改 (Changed)
- `GFFlowPort` 新增编辑器颜色、类型提示、类名提示和语义标签字段，并提供端口兼容性报告。
- `GFFlowGraph` 新增可选 `validate_port_compatibility` 校验和连接兼容性查询；默认关闭，旧资源行为保持兼容。
- 编辑器索引、访问器生成、能力系统、资源表过滤和插件诊断改为复用 `GFScriptTypeUtility`；数字格式化、大数和定点数解析改为复用 `GFDecimalStringUtility`。
- FlowGraph 字典校验报告改为复用 `GFValidationUtility.finalize_report()`，异步 Signal 等待清理改为复用内部支持脚本，返回字段与等待语义保持兼容。
- `GFRenderWarmupManifest` 与 `GFRenderWarmupUtility` 共用同一套预热条目规范化规则，避免清单描述与队列处理出现分叉。
- `GFNetworkSnapshot` 差量删除列表保留原始 key 类型，避免非字符串状态键在浅层 delta 中丢失类型。

### 🐛 Bug 修复 (Fixed)
- 加固输入图标、渲染预热和支持报告中的 Variant 到文本转换，避免非字符串配置值触发 Godot `String` 构造错误。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；未移除、重命名或改变现有公开类、信号、导出变量与公共方法签名。
- `GFRenderWarmupUtility` 与 `GFSupportReportUtility` 是可注册 Utility；网络同步原语为独立 `RefCounted`，不需要注册到架构。
- `GFRenderWarmupManifest` 新增静态方法 `normalize_entry(entry)`；`GFScriptTypeUtility` 与 `GFDecimalStringUtility` 是 Foundation API，不需要注册到架构。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要更严格 FlowGraph 端口检查时，显式开启 `validate_port_compatibility`。
- 输入图标、支持报告提交和网络同步策略仍由项目层配置；GF 只提供通用抽象和数据结构。
- 项目层若已有同类脚本继承判断、小数字符串格式化或预热条目清洗辅助，可逐步替换为新的 Foundation / Manifest API。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_render_warmup_manifest.gd`
- `addons/gf/utilities/gf_render_warmup_utility.gd`
- `addons/gf/utilities/gf_support_report_utility.gd`
- `addons/gf/input/gf_input_icon_atlas_provider.gd`
- `addons/gf/extensions/network/gf_fixed_tick_clock.gd`
- `addons/gf/extensions/network/gf_network_snapshot.gd`
- `addons/gf/extensions/network/gf_network_history_buffer.gd`
- `addons/gf/extensions/flow/gf_flow_port.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/foundation/reflection/gf_script_type_utility.gd`
- `addons/gf/foundation/formatting/gf_decimal_string_utility.gd`
- `addons/gf/extensions/common/gf_async_wait_support.gd`
- `tests/gf_core/**`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
