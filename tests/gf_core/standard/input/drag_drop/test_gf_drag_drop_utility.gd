## 测试通用拖拽会话与落点匹配工具。
extends GutTest


# --- 测试方法 ---

## 验证拖拽释放会选择命中的最高优先级落点。
func test_drop_chooses_highest_priority_accepting_zone() -> void:
	var utility := GFDragDropUtility.new()
	utility.register_rect_zone(
		&"low",
		Rect2(Vector2.ZERO, Vector2(100.0, 100.0)),
		PackedStringArray(["item"]),
		{ "priority": 1 }
	)
	utility.register_rect_zone(
		&"high",
		Rect2(Vector2.ZERO, Vector2(100.0, 100.0)),
		PackedStringArray(["item"]),
		{ "priority": 10 }
	)

	var session_id := utility.start_drag(&"item", { "id": "sample" }, Vector2(10.0, 10.0))
	var result := utility.drop(session_id, Vector2(20.0, 20.0))

	assert_true(bool(result.get("ok", false)), "命中可接收落点时应返回成功。")
	assert_eq(result.get("zone_id"), &"high", "应选择最高优先级落点。")
	assert_false(utility.has_active_session(session_id), "成功 drop 后会话应结束。")


## 验证落点拒绝时保留当前拖拽会话。
func test_rejected_drop_keeps_session_active() -> void:
	var utility := GFDragDropUtility.new()
	utility.register_rect_zone(
		&"locked",
		Rect2(Vector2.ZERO, Vector2(100.0, 100.0)),
		PackedStringArray(["item"]),
		{
			"drop": func(_session: GFDragSession, _zone: GFDropZone, _position: Variant) -> Dictionary:
				return {
					"ok": false,
					"reason": &"locked",
				},
		}
	)

	var session_id := utility.start_drag(&"item", null, Vector2(5.0, 5.0))
	var result := utility.drop(session_id, Vector2(10.0, 10.0))

	assert_false(bool(result.get("ok", true)), "落点回调可拒绝释放。")
	assert_eq(result.get("reason"), &"locked", "拒绝原因应透传。")
	assert_true(utility.has_active_session(session_id), "拒绝 drop 后会话应继续保持。")


## 验证布尔拒绝结果会得到稳定默认原因。
func test_boolean_false_drop_uses_default_reject_reason() -> void:
	var utility := GFDragDropUtility.new()
	var reject_drop := func(_session: GFDragSession, _zone: GFDropZone, _position: Variant) -> bool:
		return false
	utility.register_rect_zone(
		&"rejecting",
		Rect2(Vector2.ZERO, Vector2(100.0, 100.0)),
		PackedStringArray(["item"]),
		{
			"drop": reject_drop,
		}
	)

	var session_id := utility.start_drag(&"item", null, Vector2(5.0, 5.0))
	var result := utility.drop(session_id, Vector2(10.0, 10.0))

	assert_false(bool(result.get("ok", true)), "布尔 false 应表示 drop 被拒绝。")
	assert_eq(result.get("reason"), &"drop_rejected", "未显式提供原因时应给出稳定默认原因。")
	assert_true(utility.has_active_session(session_id), "拒绝 drop 后会话应继续保持。")


## 验证 Control 落点按全局矩形命中。
func test_control_zone_uses_global_rect() -> void:
	var utility := GFDragDropUtility.new()
	var control := Control.new()
	control.position = Vector2(40.0, 40.0)
	control.size = Vector2(30.0, 30.0)
	add_child_autofree(control)
	await get_tree().process_frame

	utility.register_control_zone(&"control", control, PackedStringArray(["ui"]))
	var session_id := utility.start_drag(&"ui", null, Vector2(45.0, 45.0))

	assert_eq(utility.get_drop_candidates(session_id, Vector2(45.0, 45.0)).size(), 1, "指针在控件全局矩形内应命中落点。")
	assert_eq(utility.get_drop_candidates(session_id, Vector2(10.0, 10.0)).size(), 0, "指针在控件外不应命中落点。")
