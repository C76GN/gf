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
- Typed events, string events, bindable properties, computed properties, reactive effects, commands, queries, and factories.
- Foundation helpers for big numbers, fixed decimals, resourceized formulas, number formatting, rich text formatting, typed JSON Variant conversion, weighted selection, tag queries, blackboard schemas, graph search, 2D/3D grid math, reusable 2D grid patterns, pathfinding, flow fields, tile map snapshots, tile neighbor rules, 3D spatial hashing, steering math with dynamic collision avoidance, and progression curves.
- Runtime utilities for versioned storage, storage file management, codecs, storage backend synchronization, request outboxes, snapshot history, save slot workflows, save graph composition, save pipelines, pipeline traces, save diagnostics, settings, display/audio application, assets with handles/groups, remote text/JSON caching, scenes with preload caching, preload maps, transition params and history, build info snapshots with optional export metadata, debug draw command buffering, node tree helpers, 3D surface material lookup, time, timers, job workers, input buffering, resourceized input mapping with virtual input sources and recording/playback, modifiers/triggers, 3D values, formatter providers, generic joypad text, conflict reports, direction input history, player-scoped input device assignment, touch controls, audio banks, audio emitter handles with owner-bound release, audio bank mounters, ambient channels, optional spatial audio source following, analytics transports, UI stacks and route mapping, SubViewport layouts, logging, governed diagnostics, architecture dependency diagnostics, notification queues, quests, object pools, and native signal connections.
- Extensions for pure-code hierarchical and node-based state machines, parent/child state paths, event bubbling, state guards, resourceized node-state conditions/behaviors, blackboards, runtime snapshots, action queues with common action factories, interceptors, resourceized tween configs and shake feedback actions, command sequence failure policies, capability recipes and inspection reports, interaction sender/receiver nodes, 3D pointer interaction bridging, combat hit context bridge nodes with configurable Buff refresh/tick policies, slot inventory models, resourceized flow graphs with port metadata, connections, validation, topology diagnostics and editor view models, pluggable network backends with optional ENet/WebSocket transports, reconnect backoff policies, network session/channel metadata, generic 3D gravity fields, node-state configuration, state history, and stack-style child states.
- Editor tools for generating typed GF/config accessors and project constants, inspecting save payloads, applying node capability recipes, validating node capability dependencies, optional build metadata export, common GF script templates, node-state initial-state selection, reusable drag-paint Pattern2D grid editing, and Node3D/Mesh/MeshLibrary thumbnail rendering.

## Chinese Summary

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

复制 `addons/gf` 后，Godot 不会自动启用插件。请在 `Project > Project Settings > Plugins` 中手动启用 `GF Framework`，插件启用后会自动注册 `Gf` AutoLoad 与编辑器工具。

## License

Apache License 2.0. See `LICENSE.md`.
