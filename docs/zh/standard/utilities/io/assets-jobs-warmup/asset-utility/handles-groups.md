# 资源句柄与分组预热

当资源会被多个短生命周期对象持有时，可以用 `GFAssetHandle` 表达所有权。句柄会增加路径引用计数并锁定缓存，`release()` 后才允许 LRU 淘汰。

如果传入 owner，`release_owner(owner)` 或 Node 退出树时会释放该 owner 的引用。

资源分组适合 UI 包、关卡包或主题包这类“成组预热、成组卸载”的通用流程，不要求项目把业务语义写进工具层。

```gdscript
assets.load_handle_async(
	"res://ui/inventory_panel.tscn",
	func(handle: GFAssetHandle) -> void:
		if handle == null:
			return
		var scene := handle.get_resource() as PackedScene
		add_child(scene.instantiate())
		handle.release(),
	"PackedScene",
	self,
	&"inventory_ui"
)

assets.preload_group_async(
	&"battle_ui",
	[
		{ "path": "res://ui/battle_hud.tscn", "type_hint": "PackedScene" },
		{ "path": "res://ui/skill_icon_atlas.tres", "type_hint": "Resource" },
	],
	func(report: Dictionary) -> void:
		print(report["ok"])
)
```
