# GF Framework Addon

[Project README](../../README.md) | [简体中文](../../README.zh.md) | [Read the Docs](https://gf-framework.readthedocs.io/)

This directory is the distributable Godot addon for GF Framework. Copy `addons/gf` into a Godot 4 project, enable `GF Framework` from `Project > Project Settings > Plugins`, and the plugin will register:

```text
Gf -> res://addons/gf/kernel/core/gf.gd
```

The plugin also provides the `GF Packages` bottom panel for inspecting package manifests, enabling or disabling packages, auto-running enabled package installers, excluding disabled packages during export, and reporting disabled-package references when strict export checks are enabled.

## Layout

- `kernel`: runtime kernel, base contracts, architecture container, binding, events, commands, queries, factories, AutoLoad entry, package infrastructure, and core editor integration.
- `standard`: stable standard library, including foundation, input, utilities, state machines, command history, sequence helpers, and common support primitives.
- `packages/official`: optional official packages shipped with GF.
- `packages/community`: convention folder for local or third-party packages.

Official packages do not hard depend on each other. Unused packages may be disabled, excluded from export, or removed after project references are gone.

## 中文说明

本目录是 GF Framework 的 Godot 插件分发目录。将 `addons/gf` 复制到 Godot 4 项目后，在 `Project > Project Settings > Plugins` 启用 `GF Framework`，插件会自动注册 `Gf` AutoLoad，并提供 `GF Packages` 底部面板用于查看、启用、禁用和导出管理 GF 包。

完整项目说明请看仓库根目录的 [`README.md`](../../README.md) 和 [`README.zh.md`](../../README.zh.md)，正式文档请看 [Read the Docs](https://gf-framework.readthedocs.io/)。

## License

Apache License 2.0. See [`../../LICENSE.md`](../../LICENSE.md).
