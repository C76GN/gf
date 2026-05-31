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

## [4.1.0] - 2026-06-01

**版本概述**：补强通用 HTTP 响应对象的 header 读取语义，扩展 2D 曲线/折线基础算法的虚线切分与闭合多边形圆角化能力，并增加通用资源依赖收集、弹簧平滑数学与 3D 物理多命中射线查询。

### 🚀 新增特性 (Added)

- `GFHttpResponse` 新增 `get_header()`、`get_header_values()` 与 `get_headers_dictionary()`，用于稳定读取响应头并保留重复 header 值。
- `GFCurve2DMath` 新增 `make_dashed_polyline_segments()` 与 `round_polygon_points()`，用于在不创建节点、不绑定绘制语义的前提下切分虚线折线并生成闭合多边形圆角点序列。
- 新增 `GFSpringMath`，用于对 float、角度、Vector2 与 Vector3 执行无状态二阶弹簧步进，不绑定节点、Tween 或具体表现语义。
- `GFResourceRegistryTools` 新增 `collect_dependency_paths()`，用于基于 Godot 资源依赖关系收集路径闭包，便于构建资源注册表、预加载分组或预热清单。
- 新增 `GFPhysicsQueryUtility.raycast_all_3d()`，用于沿同一条 3D 射线收集多个物理命中结果，不绑定视觉、Combat 或 Interaction 语义。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/foundation/math/gf_curve_2d_math.gd`
- `addons/gf/standard/foundation/math/gf_spring_math.gd`
- `addons/gf/standard/utilities/assets/gf_resource_registry_tools.gd`
- `addons/gf/standard/utilities/spatial/gf_physics_query_utility.gd`
- `addons/gf/standard/utilities/io/gf_http_response.gd`
- `tests/gf_core/extensions/action_queue/test_gf_action_queue.gd`
- `tests/gf_core/standard/utilities/assets/test_gf_resource_registry_tools.gd`
- `tests/gf_core/standard/foundation/math/test_gf_curve_2d_math.gd`
- `tests/gf_core/standard/foundation/math/test_gf_spring_math.gd`
- `tests/gf_core/standard/utilities/spatial/test_gf_physics_query_utility.gd`
- `tests/gf_core/standard/utilities/io/test_gf_http_request_builder.gd`
- `docs/zh/standard/foundation/grid-spatial/curve-2d.md`
- `docs/zh/standard/foundation/grid-spatial/spring-math.md`
- `docs/zh/standard/utilities/io/assets-jobs-warmup/asset-utility/resource-registry.md`
- `docs/zh/standard/input-flow/spatial-query.md`
- `docs/zh/standard/utilities/io/config-remote-outbox/http-async-batch.md`
