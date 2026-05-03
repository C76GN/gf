# GF Framework

GF Framework is a lightweight game architecture framework for Godot 4. It separates data, logic, presentation, runtime services, and pure algorithm utilities so projects can keep predictable lifecycles and clear dependency boundaries as they grow.

## Installation

Copy `addons/gf` into your Godot project, then enable `GF Framework` from `Project > Project Settings > Plugins`.

Godot does not automatically enable editor plugins after files are copied into `addons`. This is expected behavior. Enable `GF Framework` manually so the plugin can register project settings, editor tools, and the `Gf` AutoLoad.

When the plugin is enabled, it registers the `Gf` AutoLoad automatically:

```text
Gf -> res://addons/gf/core/gf.gd
```

## Quick Start

```gdscript
extends Node


func _ready() -> void:
	Gf.register_model(PlayerModel.new())
	Gf.register_utility(GFStorageUtility.new())
	Gf.register_system(BattleSystem.new())

	await Gf.init()

	var player_model := Gf.get_model(PlayerModel) as PlayerModel
	var battle_system := Gf.get_system(BattleSystem) as BattleSystem
	battle_system.start_encounter(player_model)
```

## Main Features

- Lifecycle-managed `GFModel`, `GFSystem`, `GFController`, and `GFUtility` modules.
- Project installers and declarative binding helpers for assembling game modules.
- Typed events, string events, bindable properties, commands, queries, and factories.
- Foundation helpers for big numbers, fixed decimals, resourceized formulas, number formatting, grid math, 3D spatial hashing, and progression curves.
- Runtime utilities for versioned storage, codecs, save graph composition, save pipelines, save diagnostics, settings, display/audio application, assets, remote text/JSON caching, scenes, time, timers, input buffering, resourceized input mapping with modifiers/triggers, 3D values, conflict reports, player-scoped input device assignment, touch controls, audio banks, ambient channels, analytics transports, UI, logging, governed diagnostics, notification queues, quests, object pools, and native signal connections.
- Extensions for pure-code and node-based state machines, state guards and blackboards, resourceized flow graphs with port metadata, connections and validation, pluggable network backends with optional ENet transport, network session/channel metadata, node-state configuration, state history, and stack-style child states.
- Editor tools for generating typed accessors and project constants, inspecting save payloads, common GF script templates, node-state initial-state selection, and reusable Node3D/Mesh/MeshLibrary thumbnail rendering.

## Chinese Summary

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

复制 `addons/gf` 后，Godot 不会自动启用插件。请在 `Project > Project Settings > Plugins` 中手动启用 `GF Framework`，插件启用后会自动注册 `Gf` AutoLoad 与编辑器工具。

## License

Apache License 2.0. See `LICENSE.md`.
