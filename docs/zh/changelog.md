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

## [4.0.0] - 2026-06-01

**版本概述**：修复 Godot 4.6 下部分 GF 脚本因 `Variant` 推断警告被当作错误而导致编辑器和 LSP 解析失败的问题，恢复文档悬浮、补全和脚本加载。本版本按主版本发布，集中清理会长期积累维护债务的公开命名、返回类型和资源类型边界。

### 🔄 机制更改 (Changed)

- 更新 `CODING_STYLE.md` 的类型推断规范：GF 框架源码默认使用显式类型，来自 `Dictionary`、`Array`、反射调用、脚本加载、弱引用等 `Variant` 边界的数据必须先校验再收窄。
- 新增维护测试约束 `kernel/core`、`kernel/base`、`kernel/extension` 以及已完成清理的关键 `kernel/editor` 入口中的高风险 `:=` 动态推断、`:= ... as Type` 和易遮蔽基类 API 的局部命名，防止框架核心边界再次出现会阻断 Godot 4.6 解析的模式。
- 扩展 `GFVariantData` 的通用收窄接口，统一 standard 与 extensions 中来自 `Dictionary`、反射调用和序列化载荷的基础 Variant 读取语义。

### 🐛 Bug 修复 (Fixed)

- 为若干 `GF` 运行时工具脚本补足局部变量显式类型，避免 `Variant` 返回值在 Godot 4.6 中触发 `Warning treated as error` 解析失败。
- 受影响范围包括快照历史、JSONL 日志、场景历史、运行时 Inspector、可调属性、表面材质、信号连接和通知队列等通用工具脚本。
- 修复 `GFVariantData.merge_dictionary()` 在 `String` / `StringName` 等价键递归合并时可能生成重复字段或漏合并嵌套字典的问题。
- 对 `GFArchitecture`、`GFBinding`、`GFBindBuilder`、`GFBindableProperty`、`GFReactiveEffect`、`GFNodeContext` 和 `GFObjectPropertyTools` 统一收口动态类型读取，减少裸 `as Object/Script/Dictionary/Array` 与从 `Dictionary.get()` 直接推断局部类型的维护风险。
- 对 `GFController` 的事件绑定恢复路径、`GFDependencyScopeSupport` 的弱引用/释放标志读取、`GFExtensionManifest` 的 manifest 数据解包、`GFExtensionSettings` 的启用状态缓存与 `GFExtensionUsageAudit` 的扫描参数解包统一做了显式收窄，避免扩展边界再引入隐式 Variant 推断。
- 为 `GFExtensionSettings` 增加框架内部 `set_cached_manifests()` 入口，让编辑器流程和维护测试可以复用启用扩展选择逻辑，而不依赖私有缓存字段。
- 将 `GFBinder` 与 `GFBindBuilder` 的声明式装配链返回值收窄为 `GFBindBuilder`，让 Installer 代码在进入绑定链后保留类型提示和安全方法访问。
- 将 `GFShakePreset`、`GFShakeTrack` 与 `GFTileRuleSet` 的采样种子命名收敛为语义更明确的 `sample_seed` / `selection_seed`，避免遮蔽 Godot 全局 `seed()`。
- 将 `GFNetworkSession` 的连接状态命名收敛为 `has_connection`，避免与 Godot/脚本常见连接查询语义混淆。
- 对 `GFPluginMenu` 与 `GFResourceTableEditor` 的编辑器菜单条目、资源扫描选项、列声明和脚本过滤读取做显式类型收窄，降低编辑器工具链在严格警告下加载失败的概率。
- 修复 `GFInstanceGuard` 对已释放对象执行 `is` 检查时触发的引擎错误，并增强对象池与 UI 栈对 stale freed 引用的防御性清理。
- 清理源码和维护测试中的无类型声明、缺少 await、整数除法、未使用信号、基类/全局命名遮蔽、三元类型不兼容和不安全属性访问警告；对明确的后台协程启动点使用局部 `@warning_ignore("missing_await")` 标注 fire-and-forget 语义。
- 将命中/交互接收器的通用消息接收逻辑改为显式 signal emitter Callable，避免公共信号只通过字符串反射发射而被 LSP 判定为未使用。
- 将 `GFSourceBuilder` 的源码写入、缩进和清空方法调整为命令式 `void` API，避免代码生成器调用方反复丢弃 builder 返回值。
- 修复 `GFInputRemapConfig` 直接加载到 `String` 键重映射资源时，`StringName` API 无法稳定读取或清理覆盖绑定的问题。
- 修复 `GFCapabilityUtility.dispose()` 只清空索引而不注销 receiver 能力的问题；现在会触发移除 Hook、清理 receiver 元数据，并按所有权释放 Utility 创建或实例化的节点能力。
- 将 ActionQueue 测试中的队列系统和拦截器夹具改为运行期加载，避免 GUT 收集阶段静态加载 `GFActionQueueSystem` 后再加载 Capability 测试时触发 Godot 退出期资源清理崩溃。
- 修复后，编辑器中的脚本解析、语言服务器和文档悬浮可重新正常工作。

### 🔌 API 变动说明 (API Changes)

- `GFShakePreset.seed` 与 `GFShakeTrack.seed` 重命名为 `sample_seed`。
- `GFTileRuleSet.resolve(..., seed)` 参数重命名为 `selection_seed`。
- `GFNetworkSession.is_connected` 重命名为 `has_connection`。
- `GFAction.callback(callback, args)` 参数重命名为 `action_callback`。
- `GFInventoryStack.add_amount(add_amount, registry)` 与 `remove_amount(remove_amount)` 参数重命名为 `quantity`。
- `GFResourceRegistryEntry.configure(path, ...)` 参数重命名为 `entry_path`。
- `GFResourceRegistry.entries` 导出属性类型从 `Array[Resource]` 收窄为 `Array[GFResourceRegistryEntry]`。
- `GFRenderWarmupManifest.add_resource_path(resource_path, ..., metadata)` 参数重命名为 `entry_resource_path` 与 `entry_metadata`。
- `GFInputIconAtlasProvider.set_icon_path(icon_key, resource_path)` 参数重命名为 `icon_resource_path`。
- `GFNodeStateMachine` 的 owned event 注册/清理参数从 `owner` 重命名为 `listener_owner`。
- `GFSourceBuilder.line()`、`doc()`、`section()`、`blank()`、`indent()`、`dedent()` 与 `clear()` 不再返回 `GFSourceBuilder`，请按命令式逐行调用；`build()` 仍返回源码字符串。
- `GFBinder.bind_model()`、`bind_system()`、`bind_utility()`、`bind_factory()` 的返回类型从 `Variant` 收窄为 `GFBindBuilder`；`GFBindBuilder.from_factory()`、`from_instance()`、`with_alias()` 也返回 `GFBindBuilder`。
- `GFCapabilityUtility.dispose()` 的行为更严格：它会注销已索引 receiver 上的能力；`add_capability()` / `add_scene_capability()` 创建或实例化的能力由 Utility 释放，`add_capability_instance()` 传入的外部实例只解除登记。
- `GFVariantData` 新增 `as_dictionary()`、`as_array()`、`to_array()`、`to_bool()`、`to_int()`、`to_float()`、`to_text()`、`to_string_name()`、`to_vector2()`、`to_vector3()`、`to_string_array()`、`to_string_name_array()`、`to_int_array()` 以及对应的 Vector / 数组 options 读取器，作为 standard/extensions 的统一 Variant 收窄入口。

### 📘 升级指南 (Migration Guide)

- 将 `GFShakePreset.seed` 和 `GFShakeTrack.seed` 改为 `sample_seed`。
- 若以命名参数调用 `GFTileRuleSet.resolve(..., seed = value)`，改为 `selection_seed = value`；位置参数调用保持语义不变。
- 将读取 `GFNetworkSession.is_connected` 的代码改为读取 `has_connection`。
- 若直接写入 `GFResourceRegistry.entries`，请改为写入 `GFResourceRegistryEntry` 实例；旧的“任意 Resource 只要带有同名方法/字段即可”反射兼容路径已移除。
- 若项目或扩展代码链式调用 `GFSourceBuilder`，改为分行调用，例如先 `builder.line(...)`，再 `builder.indent()`，最后用 `builder.build()` 取结果。
- `GFInstaller.install_bindings(binder: Variant)` 的钩子签名保持不变；进入绑定链前请先确认 `binder is GFBinder`，之后可把逻辑交给接收 `GFBinder` 的私有辅助方法。
- 如果项目曾依赖 `GFCapabilityUtility.dispose()` 后 receiver 上仍保留能力元数据，需要改为在销毁前保存所需状态；外部节点或对象池能力请继续通过 `add_capability_instance()` 挂载，避免 Utility 接管释放。
- 若使用命名参数调用上述 API，请同步改为新的参数名；位置参数调用保持原有参数顺序和运行语义。
- 若编辑器仍保留旧缓存，重启 Godot 或重载语言服务器即可刷新解析结果。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/extensions/action_queue/actions/gf_flash_action.gd`
- `addons/gf/extensions/capability/core/gf_capability_utility.gd`
- `addons/gf/extensions/combat/projectiles/gf_homing_projectile_motion.gd`
- `addons/gf/extensions/domain/inventory/gf_inventory_item_definition.gd`
- `addons/gf/extensions/domain/quest/gf_quest_utility.gd`
- `addons/gf/extensions/flow/editor/gf_flow_graph_dock.gd`
- `addons/gf/extensions/interaction/nodes/gf_interaction_sensor.gd`
- `addons/gf/extensions/network/contracts/gf_network_contract_message.gd`
- `addons/gf/kernel/core/gf.gd`
- `addons/gf/kernel/core/gf_architecture.gd`
- `addons/gf/kernel/core/gf_binder.gd`
- `addons/gf/kernel/core/gf_binding.gd`
- `addons/gf/kernel/core/gf_bind_builder.gd`
- `addons/gf/kernel/core/gf_bindable_property.gd`
- `addons/gf/kernel/core/gf_instance_guard.gd`
- `addons/gf/kernel/core/gf_node_context.gd`
- `addons/gf/kernel/core/gf_object_property_tools.gd`
- `addons/gf/kernel/core/gf_reactive_effect.gd`
- `addons/gf/kernel/core/gf_script_type_inspector.gd`
- `addons/gf/kernel/core/gf_type_event_system.gd`
- `addons/gf/kernel/base/gf_dependency_scope_support.gd`
- `addons/gf/kernel/base/gf_controller.gd`
- `addons/gf/kernel/editor/gf_source_builder.gd`
- `addons/gf/kernel/editor/gf_thumbnail_renderer.gd`
- `addons/gf/kernel/extension/gf_extension_manifest.gd`
- `addons/gf/kernel/extension/gf_extension_settings.gd`
- `addons/gf/kernel/extension/gf_extension_usage_audit.gd`
- `addons/gf/kernel/editor/gf_plugin_menu.gd`
- `addons/gf/kernel/editor/gf_resource_table_editor.gd`
- `addons/gf/standard/utilities/nodes/gf_object_pool_utility.gd`
- `addons/gf/standard/utilities/ui/gf_ui_utility.gd`
- `addons/gf/standard/foundation/formula/gf_formula.gd`
- `addons/gf/standard/foundation/math/gf_grid_generation_step_2d.gd`
- `addons/gf/standard/foundation/math/gf_region_map_3d.gd`
- `addons/gf/standard/foundation/numeric/gf_big_number.gd`
- `addons/gf/standard/foundation/tags/gf_tag_expression.gd`
- `addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd`
- `addons/gf/standard/foundation/validation/gf_validation_runner.gd`
- `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- `addons/gf/standard/input/drag_drop/gf_drag_session.gd`
- `addons/gf/standard/input/drag_drop/gf_drop_zone.gd`
- `addons/gf/standard/input/mapping/gf_input_profile_bank.gd`
- `addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd`
- `addons/gf/standard/state_machine/node/gf_node_state_group.gd`
- `addons/gf/standard/utilities/assets/gf_asset_utility.gd`
- `addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd`
- `addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`
- `addons/gf/standard/utilities/history/gf_snapshot_history_utility.gd`
- `addons/gf/standard/utilities/logging/gf_json_line_log_sink.gd`
- `addons/gf/standard/utilities/scene/gf_scene_utility.gd`
- `addons/gf/standard/utilities/debug/gf_runtime_inspector_utility.gd`
- `addons/gf/standard/utilities/debug/gf_runtime_tunable_property.gd`
- `addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd`
- `addons/gf/standard/utilities/debug/gf_support_report_utility.gd`
- `addons/gf/standard/utilities/display/gf_surface_utility.gd`
- `addons/gf/standard/utilities/io/gf_request_outbox_utility.gd`
- `addons/gf/standard/utilities/signals/gf_signal_connection.gd`
- `addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd`
- `addons/gf/standard/utilities/ui/gf_notification_utility.gd`
- `CODING_STYLE.md`
- `tests/gf_core/maintenance/test_gdscript_parse_validation.gd`
- `tests/gf_core/extensions/action_queue/test_gf_action_queue.gd`
- `tests/gf_core/extensions/capability/test_gf_capability_utility.gd`
- `tests/gf_core/fixtures/action_queue/action_queue_interceptor_fixtures.gd`
- `docs/zh/extensions/capability/node-capabilities.md`
- `docs/zh/extensions/capability/runtime-interface.md`
