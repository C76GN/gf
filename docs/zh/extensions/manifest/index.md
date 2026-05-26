# Manifest 规范

每个扩展应提供 `gf_extension.json`。它声明扩展 ID、版本、依赖、装配入口、编辑器贡献和默认启用状态。

## 阅读入口

- [基础格式](format.md)：`gf_extension.json` 的标准字段示例。
- [版本字段](version-fields.md)：`version` 与 `extension_version` 的职责和递增规则。
- [路径贡献](path-contributions.md)：Installer、编辑器、导入导出、glTF 和访问器生成贡献路径。
- [读取与校验](loading-validation.md)：`GFExtensionManifest`、`GFExtensionCatalog`、`GFExtensionSettings` 与图报告。

## 使用边界

Manifest 是轻量文件约定，不是依赖安装器。外部插件如果要组合多个 GF 内置扩展，应在自己的代码、Installer 或文档中表达组合关系，不写回 GF 内置扩展。

## 类型与依赖

`kind` 对 GF 内置扩展使用 `extension`；标准库内部 manifest 使用 `standard`。扩展工具只处理这两个稳定类型。

`dependencies` 是硬依赖。启用当前扩展时，`GFExtensionSettings` 会自动补齐这些依赖，并让依赖扩展排在依赖方之前。GF 内置扩展只允许声明 `gf.kernel` 与 `gf.standard`，并且源码只能引用自身、`kernel` 和稳定的 `standard`。
