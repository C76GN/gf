## 测试 GFNotificationUtility 的通用通知队列行为。
extends GutTest


# --- 常量 ---

const GFNotificationUtilityBase = preload("res://addons/gf/utilities/gf_notification_utility.gd")


# --- 测试方法 ---

## 验证通知入队后会立即成为当前通知。
func test_notification_push_starts_active_notification() -> void:
	var notifications := GFNotificationUtilityBase.new()

	var notification_id := notifications.push_notification("Saved", "System")
	var active := notifications.get_active_notification()

	assert_gt(notification_id, 0, "推送通知应返回有效 id。")
	assert_eq(active.get("message"), "Saved", "首条通知应立即成为当前通知。")
	assert_eq(active.get("title"), "System", "通知标题应保留。")


## 验证通知按时长结束并启动下一条。
func test_notification_tick_advances_queue() -> void:
	var notifications := GFNotificationUtilityBase.new()
	notifications.push_notification("First", "", GFNotificationUtilityBase.Level.INFO, { "duration_seconds": 0.1 })
	notifications.push_notification("Second", "", GFNotificationUtilityBase.Level.INFO, { "duration_seconds": 1.0 })

	notifications.tick(0.2)
	var active := notifications.get_active_notification()

	assert_eq(active.get("message"), "Second", "当前通知超时后应启动下一条。")
	assert_eq(notifications.get_queue().size(), 0, "第二条启动后等待队列应为空。")


## 验证重复通知会被抑制。
func test_notification_suppresses_duplicates() -> void:
	var notifications := GFNotificationUtilityBase.new()

	var first_id := notifications.push_notification("Duplicated", "", GFNotificationUtilityBase.Level.INFO, { "key": "same" })
	var second_id := notifications.push_notification("Duplicated again", "", GFNotificationUtilityBase.Level.INFO, { "key": "same" })

	assert_eq(second_id, first_id, "同 key 通知应返回已有通知 id。")
	assert_eq(notifications.get_queue().size(), 0, "重复通知不应进入等待队列。")
