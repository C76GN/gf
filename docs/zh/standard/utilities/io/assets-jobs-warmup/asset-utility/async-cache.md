# 异步加载与 LRU 缓存

当项目需要按需加载特效、图标、UI 面板或关卡资源，并希望统一处理缓存、并发请求、取消和调试快照时，可以使用 `GFAssetUtility`。

```gdscript
var assets := Gf.get_utility(GFAssetUtility) as GFAssetUtility

# 异步加载一个带路径的资源。缓存命中时直接返回，
# 如果已有相同请求，则共用同一次加载；如果没有，则发起新的 threaded request。
assets.load_async("res://actors/runtime_actor.tscn", func(res: Resource) -> void:
	var actor_scene := res as PackedScene
	if actor_scene != null:
		add_child(actor_scene.instantiate())
)
```

它内置 LRU 上限。当缓存过大时，会自动清理长期未被提取引用的资源。`max_cache_size = 0` 会禁用并清空缓存；`pin_cache(path)` 会用引用计数锁定关键资源，重复 pin 需要对应次数 `unpin_cache(path)` 后才会重新参与 LRU 淘汰。

```gdscript
assets.max_cache_size = 128
assets.load_async("res://ui/inventory_panel.tscn", _on_panel_loaded, "PackedScene")

assets.pin_cache("res://ui/common_icons.tres")
```

同一路径的并发加载会合并到同一个 threaded request。如果已存在请求或缓存的资源类型与新的 `type_hint` 明显不兼容，回调会收到 `null`。命中缓存时回调会同步执行。
