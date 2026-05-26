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

## [3.18.0] - 2026-05-26

**版本概述**：新增一组保持框架抽象边界的基础设施能力，重点补强 3D 网格/表面映射、通用 SaveGraph 数据源和可组合标签条件；这些能力只提供纯算法、Resource 契约或通用适配，不绑定具体玩法、TileMap、渲染、碰撞或业务语义。

### 🚀 新增特性 (Added)

- 新增 `GFRegionMap3D`，提供 `Vector3i` 格子到三维区域的通用数据映射、脏区域追踪、区域快照和格子范围到区域键查询，适合大地图局部保存、编辑器批处理和运行时 3D 格子缓存，不绑定 TileMap、渲染、碰撞或项目规则。
- 新增 `GFGridKey3D`，提供有限范围内 `Vector3i` 格坐标、`Vector3` 位置量化和方向编号的稳定整数 key packing，减少项目侧重复字符串 key 与临时 hash。
- 新增 `GFGridPlaneMapper3D`，提供 axis-aligned 3D 表面到局部 2D 邻域坐标的映射与采样，便于复用 `GFTileRuleSet` 等 2D 邻域规则而不绑定具体瓦片或地图语义。
- 新增 `GFSaveDataSource`，让 Resource、目标 Node 或目标属性上的通用数据对象通过 `to_dict()` / `from_dict()` 风格协议接入 SaveGraph，减少项目为纯数据状态重复编写 `GFSaveSource` 子类。
- 新增 `GFTagExpression`，在 `GFTagQuery` 之上提供可嵌套 all/any/none 标签表达式与匹配报告，便于技能条件、AI 感知、配置过滤和编辑器筛选复用复杂标签规则。

### 🔌 API 变动说明 (API Changes)

- 新增公开 API：`GFRegionMap3D`、`GFGridKey3D`、`GFGridPlaneMapper3D`、`GFSaveDataSource`、`GFTagExpression`。
- `gf.save` 内置扩展的 `extension_version` 从 `2.1.0` 升至 `2.2.0`，表示新增向后兼容的 SaveGraph 数据源能力。
- 本版本不移除或重命名既有公开 API。

### 📘 升级指南 (Migration Guide)

- 本版本为向后兼容新增能力，现有项目无需迁移。
- 需要为纯数据 Resource、Node 或属性接入 SaveGraph 时，可以优先评估 `GFSaveDataSource`，避免为简单状态对象重复编写专用 `GFSaveSource` 子类。
- 需要在 3D 地面、墙面或天花板上复用 2D 邻域规则时，可以使用 `GFGridPlaneMapper3D` 将 3D 表面邻域映射为局部 2D offset。

### 📁 核心受影响文件 (Affected Files)

- 标准库基础能力：`addons/gf/standard/foundation/math/gf_region_map_3d.gd`、`addons/gf/standard/foundation/math/gf_grid_key_3d.gd`、`addons/gf/standard/foundation/math/gf_grid_plane_mapper_3d.gd`、`addons/gf/standard/foundation/tags/gf_tag_expression.gd`。
- Save 扩展：`addons/gf/extensions/save/core/gf_save_data_source.gd`、`addons/gf/extensions/save/gf_extension.json`。
- 测试与文档：`tests/gf_core/standard/foundation/math/**`、`tests/gf_core/standard/foundation/tags/**`、`tests/gf_core/extensions/save/**`、`docs/zh/standard/foundation/grid-spatial.md`、`docs/zh/standard/foundation/data-validation.md`、`docs/zh/extensions/save-graph/index.md`。
- 发布元数据：`addons/gf/plugin.cfg`、`addons/gf/extensions/*/gf_extension.json`、`ASSET_LIBRARY.md`。
