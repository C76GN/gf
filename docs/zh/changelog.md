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

## [3.10.0] - 2026-05-17

**版本概述**：本轮加固 JSON 存储、Variant JSON 编码和确定性随机状态的 64 位整数处理，避免 Godot 4.6 JSON 解析造成 checksum 误报或回放状态精度丢失；同时新增纯数据后台工作协调器，标准化 CPU/IO 线程工作、ResourceLoader 线程加载和主线程应用边界。

### 🚀 新增特性

- 标准库 jobs 目录新增 `GFBackgroundWorkUtility` 与 `GFBackgroundWorkTask`，用于提交纯 Variant CPU/IO 后台工作、合并 threaded `ResourceLoader` 请求、限制并发线程数量、协作式取消、主线程应用回调和调试快照。

### 🔄 机制更改

- `GFSeedUtility.get_full_state()` 现在输出带 `state_schema_version = 2` 的状态字典，并将 `global_seed`、`rng_state` 与分支计数保存为十进制字符串，确保默认 JSON 存储可精确往返。
- `GFVariantJsonCodec.variant_to_json_compatible()` 会把超出 JSON 安全范围的 64 位整数编码为 `Int64` 类型标记；`PackedInt64Array` 的元素也会以文本形式保存在类型标记中。
- `GFSettingsUtility` 持久化设置值时复用 `GFVariantJsonCodec` 处理非设置专用类型，设置中的超大整数现在会以类型标记保存。

### 🐛 Bug 修复

- 修复 `GFStorageCodec` 在 Godot 4.6 下对非字符串 JSON 字典键排序时使用 `String(int)` 导致解析失败的问题。
- 修复 JSON checksum 在载荷包含 64 位整数或 `StringName` 键时，写入后读回可能被误判为完整性损坏的问题。
- 修复 `GFSeedUtility` 完整随机状态通过默认 JSON 存储后，主种子、RNG 状态或分支计数可能因 64 位整数精度丢失而破坏确定性回放的问题。
- 修复 `GFStorageSyncUtility` 使用非数字 metadata 比较冲突新旧时，任意 Variant 字符串化可能触发 Godot `String(Variant)` 转换错误的问题。
- 修复 `GFSettingDefinition` 将数字等非字符串值钳制为 `STRING` / `STRING_NAME` 时可能触发 `String(Variant)` 转换错误的问题。
- 修复 `GFSaveGraphUtility` 校验或应用手写载荷时，非字符串 source/scope key 可能触发 `String(Variant)` 转换错误的问题。

### 🔌 API 变动说明

- `GFSeedUtility.get_full_state()` 的状态字典新增明确的 `state_schema_version` 字段，当前值为 `2`；`global_seed`、`rng_state` 与 `branch_counters` 的计数值由整数改为十进制字符串。
- `GFVariantJsonCodec.variant_to_json_compatible()` 新增 `encode_unsafe_ints` 选项；默认 `true`，可显式设为 `false` 以保留旧的裸数字输出。
- 新增公开类 `GFBackgroundWorkUtility` 和 `GFBackgroundWorkTask`；后台工作提交方法返回 `RefCounted` 任务实例，实际对象为 `GFBackgroundWorkTask`。

### 📘 升级指南

- 项目代码不要再把 `get_full_state()` 的 `global_seed`、`rng_state` 或分支计数字段当作数字直接编辑；恢复时继续把完整字典交给 `set_full_state()`。
- JSON 存档中需要精确保留任意 64 位整数的业务字段，应使用字符串、`GFVariantJsonCodec` 的类型化 JSON 值，或切换到 `GFStorageCodec.Format.BINARY`。
- 项目若直接读取 `get_full_state()` 字典做调试展示，可显示 `state_schema_version`，但业务判断不要把它当作 GF 框架版本号。
- 新后台工作推荐只传路径、ID、数值、数组和字典等纯 Variant 数据；需要触碰 Node、Resource 或 UI 的逻辑应放到 `apply_callback`，由 `GFBackgroundWorkUtility.tick()` 在主线程执行。

### 📁 核心受影响文件

- 随机状态：`addons/gf/standard/utilities/random/gf_seed_utility.gd`。
- 存储编码：`addons/gf/standard/utilities/storage/gf_storage_codec.gd`。
- 存储同步：`addons/gf/standard/utilities/storage/gf_storage_sync_utility.gd`。
- 设置持久化：`addons/gf/standard/utilities/settings/gf_settings_utility.gd`、`addons/gf/standard/utilities/settings/gf_setting_definition.gd`。
- Variant JSON 编码：`addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`。
- 存档图：`addons/gf/extensions/save/graph/gf_save_graph_utility.gd`。
- 后台工作协调：`addons/gf/standard/utilities/jobs/gf_background_work_utility.gd`、`addons/gf/standard/utilities/jobs/gf_background_work_task.gd`。
- 测试：`tests/gf_core/standard/utilities/jobs/test_gf_background_work_utility.gd`。
- 文档：`docs/zh/standard/utilities/io/assets-jobs-warmup.md`、`docs/zh/standard/utilities/io/index.md`。
