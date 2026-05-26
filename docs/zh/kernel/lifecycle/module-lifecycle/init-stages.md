# 三阶段初始化

调用 `Gf.init()` 后，框架会遍历所有模块组件，并依次触发 `init()`、`async_init()`、`ready()` 三个阶段。默认保持注册顺序；如果模块设置了 `lifecycle_priority`，同类模块会按数值从高到低初始化，释放时反向处理。

所有 `GFModel`、`GFSystem` 和 `GFUtility` 基类都提供这三个虚方法供模块重写。

## 同步初始化

```gdscript
func init() -> void:
	# 同步的初步设置。
```

`init()` 会首先遍历并调用所有实例。它适合执行没有外部依赖、立即完成的轻量设置，例如绑定初始响应式属性、设置默认数值等。

此时不能保证其他模块已经完成 `init()`，因此不建议在这里频繁跨模块调用。

## 异步等待

```gdscript
func async_init() -> void:
	var asset_utility := Gf.get_utility(GFAssetUtility) as GFAssetUtility
	var load_state := { "done": false, "resource": null }
	asset_utility.load_async("res://data/tables.json", func(resource: Resource) -> void:
		load_state.resource = resource
		load_state.done = true
	)
	while not load_state.done:
		await Engine.get_main_loop().process_frame
```

`async_init()` 会在所有 `init()` 执行完毕后串行运行。它返回 `void`，但 Godot 4 支持在 `void` 函数内部使用 `await`；框架的 `Gf.init()` 会自动等待每个模块的 `async_init()` 完成，避免模块在异步资源未就绪前进入 `ready()` 或 tick。

## 就绪完成

```gdscript
func ready() -> void:
	register_simple_event(&"GAME_STARTED", _on_game_started)
```

`ready()` 会在所有模块的 `async_init()` 结束后触发。此时整个架构已经完成挂载，模块可以安全获取其他 Model、System 或 Utility，并注册事件监听。
