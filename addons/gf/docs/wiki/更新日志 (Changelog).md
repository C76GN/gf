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
