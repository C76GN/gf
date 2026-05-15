# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

正式文档中的更新日志只保留当前最新发布版本。发布新版本时，应将 `[未发布]` 合并为具体版本条目，并删除上一个正式版本条目；旧版本历史以 Git 历史和 GitHub Releases 为准，避免正式文档长期膨胀。

---

## [3.8.0] - 2026-05-15

**版本概述**：本版集中强化 GF 框架的运行时一致性、编辑器诊断体验和可选扩展事务边界，新增多项向后兼容公开 API，并修复异步等待、能力容器、存档回滚、输入、音频、场景、网络和战斗等模块的边界问题。

### 🚀 新增特性

- GF Workspace 新增独立窗口置顶控制，并将 Signal Graph 工作区收敛为更明确的“信号诊断”页面。
- Capability 新增 `required_capabilities` 导出依赖声明和 `unregister_capability()` 注销入口，便于编辑器静态校验与场景容器所有权分离。
- 行为树、Flow、JobWorker、Settings、GravityProbe 和音频句柄补充运行态隔离、等待 payload、保存批处理、采样缓存和状态查询等公开能力。

### 🔄 机制更改

- Capability 依赖声明优先使用 `required_capabilities` 导出数组；节点能力 Inspector 校验只读取导出属性，不执行项目能力脚本方法。
- GF Workspace 的 Signal Graph 页面更名为“信号诊断”，将“持久连接 / 空信号 / 实时追踪”调整为更直观的“保存连接 / 未连接信号 / 追踪发射”，并让追踪默认跟随连接页当前可见信号，避免 `draw` 等无关内建信号刷屏。
- GF Workspace 新增“置顶”开关，可让独立工作区窗口保持在其他窗口上方，便于同屏调试。
- `GFArchitecture` 在模块异步初始化、超时失败、动态注销和 alias 注册路径上加强状态一致性：迟到 coroutine 不能推进已注销模块，初始化失败会清理半注册状态，alias 会拒绝无继承关系的目标类型。
- 外部实例工厂的所有权语义收敛：`register_factory_instance()` / `replace_factory_instance()` 暴露的项目实例在工厂解绑时不会被框架 `dispose()`，只释放 GF 侧 owner 事件和依赖作用域。
- `GFAsyncWaitSupport` 新增结构化 Signal payload 等待能力，`GFCommandSequence` 与 `GFJobWorker` 会把异步 Signal 结果按同步返回值处理。
- `GFVisualAction` 统一承载内置可等待视觉动作的完成信号与一次性发射状态，Tween 类动作只保留自己的 Tween 生命周期逻辑。
- `GFSettingsUtility` 自动保存改为支持防抖、批处理和显式 flush，减少设置页连续变化时的重复落盘。
- `GFFlowRunner` 默认把共享 `GFFlowGraph` 的节点运行态隔离到 `GFFlowContext`，避免多个 runner 复用同一资源时串状态。
- `GFBehaviorTree.Runner` 默认复制运行树，保留配置但隔离 `RUNNING` 游标、计数器和调试状态。
- `GFBehaviorTree.BTNode.duplicate_runtime()` 对未知自定义节点默认保留原实例，避免 Runner 复制运行树时把项目子类降级为基础节点；持有独立运行态的自定义节点仍应重写该方法。
- `GFCapabilityRecipe` 默认事务化应用；失败时会回滚本次新增能力、分组和复用能力的 active 状态。
- `GFSaveGraphUtility.apply_scope()` 默认事务化回滚本次由工厂创建的实体；工厂创建但无法归属到 `GFSaveSource` 的实体会被释放。
- ActionQueue 的 Tween 类动作改用动作自身完成信号，不再手动发射 Godot `Tween.finished`；替换拦截器返回的新动作会先注入依赖，再继续进入后续拦截器。
- Combat 扩展收敛匿名 Buff、技能执行结果和发射体结束语义：空 `id` Buff 不再互相刷新，技能只有 `_try_execute()` 成功才进入冷却，发射体默认只在 accepted hit 后结束。
- `GFNetworkUtility` 入站消息会用后端 `peer_id` 覆盖 `GFNetworkMessage.sender_id`，避免信任客户端伪造身份。
- `GFStorageCodec` 在启用框架存储元信息时会保护用户根字典中的 `_meta` 字段，避免与存储 metadata 抢键。
- `GFUIUtility` 的异步 push/replace 增加层级请求序号，清层、替换或释放后迟到的资源回调不会重新压入旧面板。

### 🐛 Bug 修复

- 修复节点状态机校验器和 Capability Inspector 在编辑器中扫描非 `@tool` 项目脚本时可能调用 placeholder 方法并报错的问题。
- 修复 GF Workspace 置顶时窗口仍处于 transient 状态导致 Godot 输出 `Transient windows can't become on top` 错误的问题。
- 修复 `GFTypeEventSystem` 注册带过量 bound 参数的回调时可能通过校验、派发时才报错的问题，并清理空监听桶。
- 修复 `GFBindableProperty.bind_to()` 自动解绑可能断开业务层手动连接同一 callable 的问题。
- 修复 `GFBindableProperty.bind_to()` 将同一 callable 绑定到多个节点时，第一个绑定节点退出后可能无法在最后一个节点退出时清理框架连接的问题。
- 修复 `GFSaveGraphUtility.apply_scope()` 在载荷结构错误早退时可能残留本次事务创建实体上下文的问题。
- 修复 `GFBehaviorTree.Runner` 默认复制运行树时，未重写 `duplicate_runtime()` 的自定义节点可能丢失项目重写逻辑的问题。
- 修复 `GFInputBinding` 在组合键释放顺序变化时，释放事件可能因修饰键状态不一致而无法匹配的问题。
- 修复输入瞬时状态在 process frame 信号阶段可能过早清理，导致 System tick 读不到 `just_started` / `just_completed` 的问题。
- 修复 `GFCommandSequence` 异步步骤 Signal 发出失败字典时仍被当作成功的问题，并避免 rollback 未完成前重入运行状态。
- 修复 `GFJobWorker` 等待永不发射的处理器 Signal 时可能永久卡在 processing 的问题。
- 修复 `GFAssetUtility` 已取消加载完成后仍写入缓存，以及 owner 已释放时句柄回调仍可能拿到资源的问题。
- 修复 `GFAudioUtility` SFX 句柄在异步资源返回前停止后仍可能播放，以及池化播放器复用时旧 stream/bus/音量/pitch 残留的问题。
- 修复 `GFSceneUtility.load_previous_scene()` 在返回切场失败时提前弹出历史记录的问题。
- 修复 `GFNodeState` / `GFNodeStateGroup` 退出、移除或清空状态时 owner 事件监听可能残留的问题。
- 修复 `GFConfigTableImporter` CSV 引号未闭合时缺少稳定行列诊断的问题。
- 修复 `GFInventoryOperationResult.partial()` 可能出现 `ok=false` 但 `reason=&"ok"` 的冲突结果。
- 修复 `GFShakeReceiver2D/3D` 直接覆盖目标 transform，可能抹掉抖动期间外部移动、动画或布局更新的问题。
- 修复 `GFGravityProbe3D` 同一帧重复采样同一位置时无缓存导致的重复 field 扫描问题。
- 修复 `GFTurnFlowSystem` 阶段/行动等待 Signal 超时、停止或重入时可能继续旧流程或重复解析行动的问题。
- 修复 `GFCapabilityContainer` 子能力被提前移走、reparent 或释放后可能残留能力记录的问题，并避免容器离树时同步拆除场景子节点触发 Godot busy parent 错误。

### 🔌 API 变动说明

- `GFEditorWorkspaceWindow` 新增 `set_always_on_top_enabled(enabled)` 与 `is_always_on_top_enabled()`，用于控制独立工作区窗口置顶状态。
- `GFCapabilityUtility` 新增 `unregister_capability(receiver, capability_type)`，用于只解除能力登记和 Hook，不释放场景树拥有的能力实例。
- `GFCapability`、`GFNodeCapability`、`GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability` 新增 `required_capabilities: Array[Script]` 导出属性，默认 `get_required_capabilities()` 会返回该数组。
- `GFBinding._init()` 新增缓存实例所有权参数；外部通常不直接调用，但自定义绑定工具需要区分框架创建实例与项目传入实例。
- `GFAsyncWaitSupport` 新增 `await_signal_payload_safely()`，用于安全等待 Signal 并读取发射参数。
- `GFSettingsUtility` 新增 `save_debounce_seconds`、`begin_batch()`、`end_batch(save_after_change)`、`queue_save()`、`flush_pending_save()` 与 `tick(delta)`。
- `GFJobWorker` 新增 `signal_timeout_seconds` 与 `signal_timeout_respects_time_scale` 导出属性。
- `GFAudioEmitterHandle` 新增 `is_stop_requested()`。
- `GFFlowContext` 新增 `set_node_runtime_value()`、`get_node_runtime_value()`、`clear_node_runtime_state()`、`serialize_runtime_state()` 与 `deserialize_runtime_state()`；`GFFlowRunner` 新增 `isolate_graph_runtime_state`。
- `GFBehaviorTree.BTNode` 及内置节点新增 `duplicate_runtime()`；`GFBehaviorTree.Runner` 新增 `duplicates_runtime_tree`，构造参数也可控制是否复制运行树。
- `GFVisualAction` 新增内部完成信号 `_action_completed`，供内置可等待动作统一返回。
- `GFSkill.execute()` 现在返回 `bool`；需要自定义执行成败时重写 `_try_execute(targets) -> bool`，旧 `_on_execute(targets)` 仍作为默认成功路径。
- `GFGravityProbe3D` 新增 `cache_samples_per_frame`。

### 📘 升级指南

- 新能力脚本建议用 `required_capabilities` 声明静态依赖；只有确实需要运行时动态依赖时，才继续重写 `get_required_capabilities()`。编辑器 Inspector 只校验 `required_capabilities`，不会执行非 `@tool` 项目脚本方法。
- 希望节点状态机编辑器校验识别的状态名和状态组名，应写入 `state_name` / `group_name` 导出属性；运行时动态覆盖 `get_state_name()` / `get_group_name()` 不再参与编辑器校验。
- 自定义 `GFSkill` 若需要“施放失败不进冷却”，请迁移到 `_try_execute(targets) -> bool`；仅重写 `_on_execute()` 的旧技能会被视为执行成功并保持原有冷却行为。
- 如果项目复用同一个 `GFFlowGraph` 或行为树配置给多个实体，可以继续复用资源；默认 runner 已隔离运行态。若项目自己已经复制运行实例，也可按需关闭 runner 的默认复制/隔离。
- 自定义行为树节点若有独立运行态，请重写 `duplicate_runtime()` 并返回自身类型的新实例；没有独立运行态的节点可沿用默认实现。
- 若项目依赖 `GFAssetUtility.cancel()` 后迟到资源仍进入缓存，需要改为重新发起显式加载请求。
- 若项目把业务 `_meta` 字段放在存档根字典，可直接升级；新的 codec 会保留该字段。自定义读取器如果手写解析框架 metadata，应改用 codec 输出结果而不是直接读取根 `_meta`。

### 📁 核心受影响文件

- 运行时核心：`addons/gf/kernel/core/gf_architecture.gd`、`addons/gf/kernel/core/gf_bindable_property.gd`、`addons/gf/standard/common/gf_async_wait_support.gd`。
- 可选扩展：`addons/gf/extensions/action_queue/**`、`addons/gf/extensions/capability/**`、`addons/gf/extensions/flow/**`、`addons/gf/extensions/save/**`、`addons/gf/extensions/combat/**`。
- 标准库工具：`addons/gf/standard/utilities/assets/**`、`addons/gf/standard/utilities/audio/**`、`addons/gf/standard/utilities/jobs/**`、`addons/gf/standard/utilities/settings/**`、`addons/gf/standard/utilities/storage/**`。
- 发布元数据：`addons/gf/plugin.cfg`、`addons/gf/extensions/*/gf_extension.json`、`ASSET_LIBRARY.md`。
