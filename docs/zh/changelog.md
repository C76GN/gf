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

## [3.6.0] - 2026-05-14

**版本概述**：本轮聚焦 GF 编辑器工作区形态、Flow 图形化编辑体验，以及标准库空间/表面查询工具的通用能力增强；所有新增能力保持抽象、可选，不引入具体业务节点或项目适配逻辑。

### 🚀 新增特性

- Kernel 编辑器新增独立 GF 工作区窗口，插件启用或编辑器打开时默认弹出，也可由工具菜单“打开 GF 工作区”再次进入，用于承载 kernel、standard 和启用扩展贡献的通用页面。
- GF Workspace 的关于面板新增 Issues、Releases 和手动最新版本检测入口，便于在编辑器内查看项目支持与发布信息。
- 新增 GitHub Release 自动化工作流与 changelog 提取工具，推送不带 `v` 的 SemVer tag 后可自动生成 Release 说明。
- Flow 扩展的 `GFFlowGraphDock` 升级为 GraphEdit 工作区，可查看节点、拖动 `editor_position`、建立/移除通用连接，并继续展示校验清单与自动布局入口。
- `GFFlowGraphEditorModel` 新增 GraphEdit slot 描述字段，用于区分节点级执行连接 slot 与数据端口 slot。
- `GFSurfaceUtility` 新增缓存策略、自动缓存容量、Mesh surface 缓存预热与单 Mesh 缓存移除 API。
- `GFQuadTreeUtility` 新增点查询、首个点命中查询、可选精确命中测试、实体矩形读取、重复插入替换与显式 `compact()` 重建。

### 🔄 机制更改

- GF 插件不再把完整工作区安装到底部面板，改为独立窗口承载，并使用短页面标签与完整 tooltip 兼顾空间和语义。
- GF Workspace 页面统一使用通用页面根、工具栏、摘要、空状态和详情区构建方式，减少各工具面板在布局密度、状态颜色和文案风格上的漂移。
- Flow 图形编辑器仍只操作 `GFFlowGraph` 的通用节点、端口、连接和编辑器元数据，不提供业务节点库，也不解释项目流程语义。
- GF 内置扩展目录从 `addons/gf/extensions/official/<name>` 扁平化为 `addons/gf/extensions/<name>`，不再提供插件内 `community` 目录；项目组合、第三方能力和业务适配应放在项目代码或独立 Godot 插件中。
- GF 内置扩展 ID 从 `gf.official.*` 迁移为 `gf.*`，旧 ID 不再兼容；项目设置、脚本和工具应显式迁移到新 ID。
- GF 发布 tag 统一采用 `3.6.0` 这类不带 `v` 的 SemVer 格式，Release 自动化会据此校验版本元数据并提取更新说明。

### 🐛 Bug 修复

- `GFCapabilityUtility` 现在由框架层主动维护能力实例的 `receiver` 字段，避免项目能力重写 `on_gf_capability_added()` / `on_gf_capability_removed()` 但忘记调用 `super` 时，Hook 内 `get_capability()` 返回 null。
- 修复干净编辑器缓存下部分 `:=` 写法无法完成类型推断，导致 Combat 发射器与核心测试脚本重新扫描时报 Parse Error 的问题。
- 修复 GF Workspace 关于弹窗可能沿用异常窗口高度的问题，并压缩正文布局，确保联系方式直接可见。

### 🔌 API 变动说明

- 新增公开类：无。
- `GFSurfaceUtility` 新增 `CacheMode`、`DEFAULT_AUTO_CACHE_SIZE`、`cache_mode`、`auto_cache_size`、`cache_mesh_surface()`、`erase_cached_mesh()`、`set_auto_cache_size()`。
- `GFQuadTreeUtility` 新增 `insert_with_hit_test()`、`set_entity_hit_test()`、`clear_entity_hit_test()`、`get_entity_rect()`、`query_point()`、`query_first_point()`、`compact()`、`get_debug_snapshot()`。
- `GFFlowGraphEditorModel.build_view_model()` 的节点条目新增 `execution_slot_index`，端口条目新增 `graph_slot_index`，连接条目新增 `from_graph_slot_index` 与 `to_graph_slot_index`；原有字段保持兼容。
- `GFExtensionManifest` 新增统一 kind：`extension`；旧 manifest 中的 `official` / `community` 不再兼容，会被校验为无效 kind。GF 内置扩展的 `extension_version` 与硬依赖边界由维护测试覆盖。
- `GFExtensionManifest` 移除 `optional_dependencies` 字段；`GFExtensionSettings.get_manifest_graph_report()` 同步移除 `optional_dependency_warnings` 与 `warning_count` 输出。
- `GFExtensionCatalog` 新增 `load_extension_manifests()` 作为单目录扫描入口，移除旧 `load_official_manifests()` / `load_community_manifests()`。
- `GFExtensionSettings` 查询与路径收集方法移除 `include_community` 参数；扩展目录统一后不再需要社区扩展开关。

### 📘 升级指南

- 未直接引用旧扩展路径或旧扩展 ID 的项目通常无需迁移；GF 工作区改为默认弹出的独立窗口后，原有页面仍由相同 manifest/editor records 注入，关闭后可从工具菜单重新打开。
- 如果项目脚本、场景、资源或生成代码中直接引用了 `res://addons/gf/extensions/official/<name>/...`，请改为 `res://addons/gf/extensions/<name>/...`。
- 如果项目设置或代码中使用 `gf.official.<name>` 扩展 ID，必须改为 `gf.<name>`；旧 ID 不再运行时兼容归一，会被启用状态诊断报告为未知扩展 ID。
- 如果曾把项目或第三方扩展放在 `addons/gf/extensions/community`，请迁移到项目自己的目录或独立 Godot 插件中，不再作为 GF 插件目录的一部分维护。
- 如果自定义工具直接读取 `GFFlowGraphEditorModel` 的 `from_port_index` / `to_port_index` 驱动 GraphEdit，建议改用新增的 `from_graph_slot_index` / `to_graph_slot_index`，避免节点级执行连接和数据端口 0 混淆。
- 如果项目依赖 `GFQuadTreeUtility.insert()` 对同一 ID 产生重复索引，应改为显式使用不同实体 ID；现在重复插入同一 ID 会替换旧矩形。

### 📁 核心受影响文件

- `addons/gf/kernel/editor/gf_plugin_dock_tools.gd`
- `addons/gf/kernel/editor/gf_plugin_actions.gd`
- `addons/gf/kernel/editor/gf_editor_workspace_ui.gd`
- `addons/gf/kernel/editor/gf_editor_workspace_window.gd`
- `addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd`
- `addons/gf/kernel/extension/gf_extension_catalog.gd`
- `addons/gf/kernel/extension/gf_extension_manifest.gd`
- `addons/gf/kernel/extension/gf_extension_settings.gd`
- `addons/gf/plugin.gd`
- `addons/gf/plugin.cfg`
- `addons/gf/extensions/*/gf_extension.json`
- `.github/workflows/release.yml`
- `tools/extract_release_notes.py`
- `AI_MAINTENANCE.md`
- `ASSET_LIBRARY.md`
- `addons/gf/extensions/flow/editor/gf_flow_graph_dock.gd`
- `addons/gf/extensions/flow/editor/gf_flow_graph_editor_model.gd`
- `addons/gf/extensions/capability/core/gf_capability_utility.gd`
- `addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd`
- `addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd`
- `addons/gf/standard/utilities/display/gf_surface_utility.gd`
- `addons/gf/standard/utilities/spatial/gf_quad_tree_utility.gd`
- `addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd`
- `docs/zh/editor/index.md`
- `docs/zh/extensions/index.md`
- `docs/zh/extensions/capability/index.md`
- `docs/zh/extensions/flow-domain-physics/index.md`
- `docs/zh/standard/utilities/runtime/debug-observability.md`
- `docs/zh/standard/input-flow/spatial-query.md`
- `docs/zh/standard/utilities/runtime/settings-ui-scene.md`
- `tests/gf_core/kernel/editor/test_gf_plugin_helpers.gd`
- `tests/gf_core/kernel/extension/test_gf_extension_manifest.gd`
- `tests/gf_core/maintenance/test_layer_boundary_validation.gd`
- `tests/gf_core/extensions/flow/test_gf_flow_graph.gd`
- `tests/gf_core/extensions/capability/test_gf_capability_utility.gd`
- `tests/gf_core/standard/utilities/display/test_gf_surface_utility.gd`
- `tests/gf_core/standard/utilities/spatial/test_gf_quad_tree_utility.gd`
