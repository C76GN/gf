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

## [3.12.1] - 2026-05-18

**版本概述**：修复 Godot 4.6 Inspector 校验提示解析、业务接收目标转发和自动发送分发一致性问题。

### 🐛 Bug 修复

- 修复 AudioBank 与 NodeStateMachine Inspector 在 Godot 4.6 中格式化 `GFValidationIssue` 提示时错误调用双参数 `Object.get()`，避免编辑器加载插件脚本失败，并新增维护检查防止显式对象类型再次混用 `Dictionary.get()` 默认值写法。
- 修复 `GFSaveScope`、`GFSaveSource` 和 `GFSaveIdentity` 作为运行时基类声明 `@tool` 导致项目业务脚本继承后在编辑器中反复出现 `@tool` 基类警告的问题；SaveGraph 编辑器诊断仍通过导出属性读取结构，不要求用户业务脚本声明 `@tool`。
- 修复 HurtBox / InteractionReceiver 的 `receiver_path` 业务目标不实现接收函数或不返回报告时被误判为失败的问题；业务目标现在可只作为 `context.target`，副作用式业务接收函数也会沿用桥接节点的接收报告并正常发出接收信号。
- 修复 HitBox / Projectile / InteractionSensor 的自动发送分发固定使用桥接节点的问题；当 `sender_path` 指向的业务发送者实现 `send_to()` 时，分组/范围广播和发射体命中会交给业务发送者接管。

### 🔌 API 变动说明

- 本版本没有新增、移除或重命名公开方法、导出属性、信号或资源字段；调整的是已文档化的运行时行为。

### 📘 升级指南

- 自定义编辑器或 Inspector 代码如需展示 `GFValidationIssue`，应先通过 `GFValidationDiagnosticAdapter` 转成诊断字典，避免把 `RefCounted` 当作 `Dictionary` 调用双参数 `get()`。
- 自定义 SaveScope / SaveSource / SaveIdentity 脚本不需要为了消除继承警告而声明 `@tool`；只有确实要在编辑器预览阶段执行项目自定义采集或应用逻辑时，才需要项目自行评估并声明 `@tool`。
- 使用 `receiver_path` 的 HurtBox / InteractionReceiver 可把路径指向普通业务节点；只有业务节点实现对应接收函数时才会额外调用业务接收函数。
- 使用 `sender_path` 的 HitBox、Projectile 或 InteractionSensor 可在业务发送者中实现 `send_to(receiver, payload_override, id_override)` 接管自动发送；未实现时仍回退到桥接节点自身。

### 📁 核心受影响文件

- Inspector 提示：`addons/gf/standard/utilities/audio/editor/gf_audio_bank_inspector_plugin.gd`、`addons/gf/standard/state_machine/node/editor/gf_node_state_machine_inspector_plugin.gd`。
- SaveGraph 运行时基类：`addons/gf/extensions/save/core/gf_save_scope.gd`、`addons/gf/extensions/save/core/gf_save_source.gd`、`addons/gf/extensions/save/core/gf_save_identity.gd`。
- 消息收发共享实现：`addons/gf/standard/common/gf_message_receiver_support.gd`。
- Combat 桥接：`addons/gf/extensions/combat/hit_detection/gf_hit_box_2d.gd`、`addons/gf/extensions/combat/hit_detection/gf_hit_box_3d.gd`、`addons/gf/extensions/combat/hit_detection/gf_hurt_box_2d.gd`、`addons/gf/extensions/combat/hit_detection/gf_hurt_box_3d.gd`、`addons/gf/extensions/combat/projectiles/gf_projectile_2d.gd`、`addons/gf/extensions/combat/projectiles/gf_projectile_3d.gd`。
- Interaction 桥接：`addons/gf/extensions/interaction/nodes/gf_interaction_receiver.gd`、`addons/gf/extensions/interaction/nodes/gf_interaction_sensor.gd`。
- 测试与维护检查：`tests/gf_core/extensions/combat/test_gf_combat_extension.gd`、`tests/gf_core/extensions/combat/test_gf_projectiles.gd`、`tests/gf_core/extensions/interaction/test_gf_interaction_nodes.gd`、`tests/gf_core/maintenance/test_gdscript_parse_validation.gd`。
