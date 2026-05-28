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

## [3.21.0] - 2026-05-28

**版本概述**：新增网格变换、层名 bitmask、资源注册表、音频混音控制、调试向量绘制和 Asset Store 发布元数据审计，继续扩展 GF 标准层的通用基础能力。

### 🚀 新增特性 (Added)

- 新增 `GFGridTransform2D`，提供 2D 矩形局部空间的旋转、镜像和对角翻转纯坐标映射。
- 新增 `GFLayerMaskUtility`，提供层名数组、零基层索引和 32 位 bitmask 的互转，并可读取 Godot 2D / 3D 物理层名称。
- 新增 `GFResourceRegistryEntry` 与 `GFResourceRegistry`，用稳定 ID 管理资源路径、类型提示和通用字段索引，并可显式衔接 `GFAssetUtility` 进行异步加载或分组预热。
- `GFAudioUtility` 新增通用混音控制入口，支持 dB 总线音量、平滑过渡、总线静音、效果属性写入、混音快照和临时 duck / restore。
- `GFDebugDrawUtility` 新增 2D/3D 向量绘制便捷入口，复用现有 line 命令缓冲表达主向量、轴向分量和 2D 箭头。

### 🔄 机制更改 (Changed)

- `tools/gf_maintenance.py release-status` 新增 Asset Store 元数据、插件入口脚本、插件目录必备文件和发布包归档规则审计，发布工作流同步校验 `ASSET_STORE.md`。

### 🔌 API 变动说明 (API Changes)

- 新增公开类 `GFGridTransform2D`。
- 新增公开类 `GFLayerMaskUtility`。
- 新增公开类 `GFResourceRegistryEntry`。
- 新增公开类 `GFResourceRegistry`。
- `GFAudioUtility` 新增公开常量 `SILENCE_VOLUME_DB`，以及 `set_bus_volume_db()`、`get_bus_volume_db()`、`set_bus_mute()`、`set_bus_effect_property()`、`capture_mix_snapshot()`、`apply_mix_snapshot()`、`duck_bus()` 与 `restore_ducked_bus()`。
- `GFAudioBackend` 新增可选覆写入口 `set_bus_volume_db()`、`set_bus_mute()`、`set_bus_effect_property()` 与 `apply_mix_snapshot()`。
- `GFDebugDrawUtility` 新增公开方法 `draw_vector_2d()` 与 `draw_vector_3d()`。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/foundation/math/gf_grid_transform_2d.gd`
- `addons/gf/standard/foundation/math/gf_layer_mask_utility.gd`
- `addons/gf/standard/utilities/assets/gf_resource_registry_entry.gd`
- `addons/gf/standard/utilities/assets/gf_resource_registry.gd`
- `addons/gf/standard/utilities/audio/gf_audio_utility.gd`
- `addons/gf/standard/utilities/audio/gf_audio_backend.gd`
- `addons/gf/standard/utilities/debug/gf_debug_draw_utility.gd`
- `tests/gf_core/standard/foundation/math/test_gf_grid_transform_2d.gd`
- `tests/gf_core/standard/foundation/math/test_gf_layer_mask_utility.gd`
- `tests/gf_core/standard/utilities/assets/test_gf_resource_registry.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`
- `tests/gf_core/standard/utilities/debug/test_gf_debug_draw_utility.gd`
- `docs/zh/standard/foundation/grid-spatial/grid-2d-hex/grid-transform.md`
- `docs/zh/standard/foundation/scalars/layer-mask.md`
- `docs/zh/standard/utilities/io/assets-jobs-warmup/asset-utility/resource-registry.md`
- `docs/zh/standard/utilities/runtime/audio/playback/ambient-bus-concurrency.md`
- `docs/zh/standard/utilities/runtime/debug-observability/debug-visual-inspection/debug-draw.md`
- `ASSET_STORE.md`
- `tools/gf_maintenance.py`
- `tools/gf_mcp_server.py`
- `tools/extract_release_notes.py`
