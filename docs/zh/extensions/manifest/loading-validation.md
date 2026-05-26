# 读取与校验

`GFExtensionManifest` 负责读取和校验 manifest。

`GFExtensionCatalog` 负责扫描 `addons/gf/extensions` 下的一层扩展目录。

`GFExtensionSettings` 负责读取项目启用状态、查询扩展是否存在或启用、补齐依赖闭包、收集启用扩展的 Installer 路径和编辑器扩展路径，并提供按扩展 ID 解析扩展内资源或加载启用扩展脚本的统一入口。

`GFExtensionSettings` 会缓存一次 manifest 扫描结果，避免编辑器 Inspector、扩展面板和扩展查询在同一会话里反复读盘。

扩展目录发生变化时可调用 `clear_manifest_cache()` 刷新。

依赖补齐会检测循环依赖并停止递归。

正常无环时，`resolve_extension_dependencies()`、`get_enabled_manifests()` 和启用扩展路径收集都会保持依赖优先顺序，不依赖 manifest 扫描顺序。

`get_manifest_graph_report()` 可一次性报告重复扩展 ID、缺失硬依赖、无效 manifest 与依赖环。
