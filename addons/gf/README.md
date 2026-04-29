# GF Framework

GF Framework is a lightweight game architecture framework for Godot 4. It separates data, logic, presentation, runtime services, and pure algorithm utilities so projects can keep predictable lifecycles and clear dependency boundaries as they grow.

## Installation

Copy `addons/gf` into your Godot project, then enable `GF Framework` from `Project > Project Settings > Plugins`.

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
- Foundation helpers for big numbers, fixed decimals, resourceized formulas, number formatting, grid math, and progression curves.
- Runtime utilities for storage, assets, scenes, time, timers, input, input device assignment, touch controls, audio banks, analytics, UI, logging, quests, object pools, and native signal connections.
- Extensions for pure-code and node-based state machines, command sequences, turn-flow helpers, named action queues, generic domain models, capability components, interaction flows, and lightweight combat systems.
- Editor tools for generating typed accessors, common GF script templates, and reusable thumbnail rendering.

## Chinese Summary

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

## License

Apache License 2.0. See `LICENSE.md`.
