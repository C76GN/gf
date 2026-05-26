# 版本字段

`version` 表示 manifest 的发行版本。

GF 内置扩展的 `version` 必须始终等于当前 GF 发行版本。例如 GF 3.5.0 发布时，所有 `addons/gf/extensions/*/gf_extension.json` 都应写入 `"version": "3.5.0"`。

外部插件可使用自己的发行版本。

`extension_version` 表示扩展自身版本。GF 内置扩展必须显式填写该字段，并按扩展内公开行为独立递增：

- 兼容 bug 修复递增 patch。
- 向后兼容的新公开 API、配置或功能递增 minor。
- 破坏兼容递增 major。

没有发生扩展内行为变化的内置扩展，在 GF 发行版本递增时只同步 `version`，不递增 `extension_version`。
