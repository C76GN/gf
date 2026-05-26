# 拖放会话

如果项目已经把鼠标、触摸、手柄光标或编辑器指针整理成统一位置，并希望再把“拖拽会话”和“可释放落点”拆出来复用，可以使用 `GFDragDropUtility`。

它只管理 `GFDragSession`、`GFDropZone`、命中排序和 drop 结果包装，不读取 `InputEvent`，不移动节点，也不规定背包、棋盘、卡牌、技能栏或编辑器工具的业务含义。

## 最小流程

```gdscript
var drag_drop := GFDragDropUtility.new()
var toolbar_drop := func(session: GFDragSession, zone: GFDropZone, position: Variant) -> Dictionary:
	return {
		"ok": true,
		"payload": session.payload,
		"zone": zone.zone_id,
		"position": position,
	}

drag_drop.register_rect_zone(
	&"toolbar",
	Rect2(Vector2(0.0, 0.0), Vector2(320.0, 64.0)),
	PackedStringArray(["command"]),
	{
		"priority": 10,
		"drop": toolbar_drop,
	}
)

var session_id := drag_drop.start_drag(&"command", { "id": &"inspect" }, pointer_position)
drag_drop.update_drag(session_id, pointer_position)
var result := drag_drop.drop(session_id, release_position)
```

## 使用边界

`GFDropZone` 可以由矩形、`Control.get_global_rect()` 或自定义 `contains_callable` 描述命中范围；`accepted_types` 为空表示不限制拖拽类型，`priority` 越大越优先。

更复杂的权限、容量、冷却、网格占用或跨模块事务应写在项目自己的 `can_accept` / `drop` 回调、Command 或 System 中，再把最终结果以 `{ "ok": true }` 或 `{ "ok": false, "reason": ... }` 返回给工具。
