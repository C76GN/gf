# GFAction 工厂

框架内置了几个常用动作，避免每个项目重复写样板类。

```gdscript
q_sys.enqueue(GFMoveTweenAction.new(card_node, Vector2(400, 300), 0.25))
q_sys.enqueue(GFFlashAction.new(card_node, Color.WHITE, 0.12))
q_sys.enqueue(GFAudioAction.new("res://audio/sfx/hit.wav"))
```

这些动作只封装通用表现操作，不解释项目对象含义。

需要更短的组合写法时，可以使用 `GFAction` 静态工厂创建常见动作。

它只负责生成 `GFVisualAction`，不隐含任何业务流程。

```gdscript
q_sys.enqueue(GFAction.sequence([
	GFAction.move_to(card_node, Vector2(400, 300), 0.2),
	GFAction.parallel([
		GFAction.fade_to(card_node, 0.4, 0.12),
		GFAction.wait(0.12, card_node),
	]),
	GFAction.callback(func() -> void:
		print("visual done")
	),
]))
```

`GFAction` 也提供 `tween_by()`、`move_by()`、`scale_to()`、`scale_by()`、`rotate_to()`、`rotate_by()`、`fade_by()`、`colorize()`、`set_property()`、`show()`、`hide()` 和 `remove_node()` 等便捷工厂。

这些工厂仅将常见属性写入、Tween 或节点释放转换为 `GFVisualAction`；调度方式、业务对象含义和流程语义仍由调用方决定。
