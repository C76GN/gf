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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.34.x`、`1.33.x` 与 `1.32.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

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

---

## [1.33.0] - 2026-05-09

**版本概述**：收敛框架内部重复辅助逻辑，新增通用 Variant Foundation 工具，并保持 GF 1.x 公开行为兼容。

### 🚀 新增特性 (Added)
- 新增 `GFVariantUtility`，提供 Dictionary/Array 深拷贝、递归默认值合并以及 Vector2/Vector3/Color 与数组之间的 JSON 友好转换。

### 🔄 机制更改 (Changed)
- Combat Hit/HurtBox、Interaction Sensor/Receiver、节点序列化器和基础依赖作用域改为复用内部 support 脚本，减少 2D/3D、收发桥接与基类重复实现，公开 API 与行为保持不变。
- 节点序列化器的通用字段采集与应用改为规格表驱动，保留现有存档 payload 字段和应用顺序语义。
- 校验、存储、导表字段、设置定义、输入重映射和交互/命中上下文的集合复制逻辑改为复用 `GFVariantUtility`。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFVariantUtility` 为向后兼容的 Foundation API，不需要注册到 `Gf.register_utility()`。
- 未移除、重命名或改变现有公开类、信号、导出变量与公共方法签名。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。项目层若已有相同的 Dictionary/Array 深拷贝或 Vector/Color 数组转换辅助，可逐步替换为 `GFVariantUtility`。
- `GFVariantUtility.duplicate_variant()` 不会序列化 `Object` / `Resource` 引用；需要持久化对象时仍应由项目层转换为纯数据。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/foundation/variant/gf_variant_utility.gd`
- `addons/gf/base/gf_dependency_scope_support.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/base/gf_command.gd`
- `addons/gf/base/gf_query.gd`
- `addons/gf/extensions/common/**`
- `addons/gf/extensions/combat/**`
- `addons/gf/extensions/save/**`
- `addons/gf/extensions/interaction/**`
- `addons/gf/foundation/validation/**`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_config_table_column.gd`
- `addons/gf/utilities/gf_setting_definition.gd`
- `addons/gf/input/**`
- `tests/gf_core/test_gf_variant_utility.gd`
- `docs/wiki/11. 基础层 (Foundation Layer).md`

---

## [1.32.0] - 2026-05-09

**版本概述**：补齐一组通用框架能力：槽位库存、反馈采样、任务消费、音频集合挂载、输入文本、构建导出、信号图索引、音频播放句柄、场景命中桥接和校验报告基础件，保持 1.x 兼容。

### 🚀 新增特性 (Added)
- 新增 `GFInventoryItemDefinition`、`GFInventoryItemRegistry`、`GFInventoryStack`、`GFInventoryOperationResult` 与 `GFSlotInventoryModel`，提供可选槽位库存、堆叠容量、实例数据兼容、移动/交换和序列化能力。
- 新增 `GFShakePreset`、`GFShakeUtility`、`GFShakeAction`、`GFShakeReceiver2D` 与 `GFShakeReceiver3D`，提供资源化反馈采样、命名 channel 播放、动作队列入口和 2D/3D 节点接收器。
- 新增 `GFJobWorker`，可作为场景节点按批次消费 `GFJobQueueUtility` 队列。
- 新增 `GFAudioBankMounter`，支持场景生命周期自动注册、恢复或卸载 `GFAudioBank`。
- 新增 `GFInputDeviceTextProvider`，为 Joypad 输入提供通用方位文本和 options 覆盖。
- 新增 `GFBuildInfoExportPlugin`，提供可选导出时 Git 构建元数据写入入口。
- 新增 `GFAudioEmitterHandle` 与 `GFAudioUtility` 的 SFX/空间音效 handle 播放方法，用于主动停止、淡出、owner 绑定释放和读取本次播放状态；空间音效播放入口新增可选声源跟随。
- 新增 `GFCombatHitContext`、`GFHitBox2D`、`GFHitBox3D`、`GFHurtBox2D` 与 `GFHurtBox3D`，提供通用 2D/3D 命中上下文收发桥接。
- 新增 `GFValidationIssue`、`GFValidationReport` 与 `GFValidationUtility`，提供通用校验问题、报告聚合、摘要统计和字典报告兼容辅助。
- `GFSceneSignalAudit` 新增运行时节点 DTO 与 `index_signal_graph()`，便于项目调试 UI 构建信号图索引。
- `GFSceneUtility` 新增 loading scene 错误回调方法名 `loading_screen_error_method`，默认调用 `show_error(message)`。

### 🔄 机制更改 (Changed)
- `GFInputFormatter` 的 Joypad 默认文本从泛化编号升级为通用方位/轴文本；项目仍可通过 provider 或 options 覆盖。
- GF 编辑器插件新增构建信息导出设置项，默认关闭自动写入，避免改变现有导出流程。
- `GFCapabilityRecipe.validate_recipe()` 改为通过通用校验报告基础件生成结果，保留原有字典字段并补齐空报告摘要。
- `GFSaveGraphUtility` 的诊断报告统计与下一步建议改为复用通用字典报告辅助，返回字段保持兼容。
- `GFGridMath` 连线访问状态、`GFGridOccupancy` 格子索引和 `GFSpatialHash3D` 空间桶索引改用坐标值 key，减少高频查询中的临时字符串分配，公开 API 保持不变。
- `GFTypeEventSystem` 类型派发缓存改为按受影响脚本类型局部失效，并缓存脚本继承链查询，降低动态监听注册/注销后的派发抖动。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；现有轻量 `GFInventoryModel`、`GFJobQueueUtility`、`GFAudioUtility`、`GFInputFormatter`、`GFCombatSystem`、`GFSceneUtility` 和字典式校验报告调用保持有效。
- `GFValidationIssue`、`GFValidationReport` 与 `GFValidationUtility` 是新增 Foundation API，不需要注册到 `Gf.register_utility()`。
- `GFAudioEmitterHandle` 新增 `bind_to_owner()`、`unbind_owner()`，调试快照新增 `owner_valid` 字段。
- `GFAudioUtility` 新增 `play_sfx_handle()`、`play_sfx_clip_handle()`、`play_sfx_from_bank_handle()`、`play_sfx_event_handle()`、`play_sfx_clip_2d_handle()`、`play_sfx_clip_3d_handle()`、`play_sfx_event_2d_handle()`、`play_sfx_event_3d_handle()` 与 `get_ambient_handle()`；2D/3D 空间 SFX 播放方法新增可选 `follow_source` 参数，默认 `false` 保持旧行为。
- `GFSceneSignalAudit.build_signal_graph()` 返回字典新增 `nodes` 字段。
- `GFSceneUtility` 新增公开变量 `loading_screen_error_method`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要格子背包时新增 `GFSlotInventoryModel`，不要替换已有计数型 `GFInventoryModel`。
- 反馈采样只输出通用偏移；项目应自行决定目标节点、相机、UI 或 shader 的应用方式。
- 音频 handle 只控制本次播放器，旧的 fire-and-forget 播放方法无需迁移；空间 SFX 默认仍是当前位置一次性播放，只有显式传入 `follow_source = true` 时才跟随声源节点。
- Hit/HurtBox 只传递 `GFCombatHitContext` 和报告；项目仍应在业务层决定伤害、治疗、阵营、无敌帧或表现反馈。
- 自动构建元数据默认关闭；需要导出时写入 Git 字段时，在 Project Settings 中启用 `gf/build/export/write_git_metadata`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/domain/**`
- `addons/gf/extensions/feedback/**`
- `addons/gf/extensions/combat/**`
- `addons/gf/foundation/validation/**`
- `addons/gf/foundation/math/gf_grid_math.gd`
- `addons/gf/foundation/math/gf_grid_occupancy.gd`
- `addons/gf/foundation/math/gf_spatial_hash_3d.gd`
- `addons/gf/core/gf_type_event_system.gd`
- `addons/gf/extensions/capability/gf_capability_recipe.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/utilities/gf_audio_emitter_handle.gd`
- `addons/gf/utilities/gf_job_worker.gd`
- `addons/gf/utilities/gf_audio_bank_mounter.gd`
- `addons/gf/input/gf_input_device_text_provider.gd`
- `addons/gf/editor/gf_build_info_export_plugin.gd`
- `addons/gf/editor/gf_scene_signal_audit.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `tests/gf_core/**`
- `docs/wiki/**`
