## 测试 GFAnalyticsUtility 的本地队列、dry-run flush 与配置行为。
extends GutTest


# --- 私有变量 ---

var _analytics: GFAnalyticsUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_analytics = GFAnalyticsUtility.new()
	_analytics.init()
	_analytics.config.auto_capture_context = false
	_analytics.config.flush_interval_seconds = 0.0


func after_each() -> void:
	if _analytics != null:
		_analytics.dispose()
	_analytics = null
	_remove_file_if_exists("user://gf_analytics_client.cfg")
	_remove_file_if_exists("user://test_gf_analytics_client.cfg")


# --- 测试方法 ---

## 验证事件记录会进入队列并带上基础标识。
func test_track_adds_event_to_queue() -> void:
	_analytics.identify("client-a")
	_analytics.track(&"opened", { "index": 1 })

	assert_eq(_analytics.get_queue_size(), 1, "记录事件后队列长度应增加。")
	assert_eq(_analytics.get_client_id(), "client-a", "identify 应替换 client_id。")


## 验证 endpoint 为空时 flush 走 dry-run 成功路径。
func test_flush_without_endpoint_is_dry_run_success() -> void:
	watch_signals(_analytics)
	_analytics.config.batch_size = 10
	_analytics.track(&"opened")

	_analytics.flush()

	assert_eq(_analytics.get_queue_size(), 0, "dry-run flush 成功后应清空本批队列。")
	assert_signal_emitted(_analytics, "flush_started", "flush 应发出开始信号。")
	assert_signal_emitted(_analytics, "flush_completed", "dry-run 应发出完成信号。")
	assert_signal_not_emitted(_analytics, "flush_failed", "dry-run 成功不应发出失败信号。")


## 验证队列超过上限时丢弃最旧事件。
func test_queue_respects_max_size() -> void:
	_analytics.config.max_queue_size = 2
	_analytics.config.batch_size = 10

	_analytics.track(&"first")
	_analytics.track(&"second")
	_analytics.track(&"third")

	assert_eq(_analytics.get_queue_size(), 2, "队列不应超过 max_queue_size。")


## 验证运行时代码写入非法批量配置时会被钳制，不会破坏队列。
func test_runtime_config_values_are_clamped() -> void:
	_analytics.config.max_queue_size = 0
	_analytics.config.batch_size = 0
	_analytics.track(&"first")
	_analytics.track(&"second")

	assert_eq(_analytics.config.max_queue_size, 1, "max_queue_size 应被钳制为至少 1。")
	assert_eq(_analytics.config.batch_size, 1, "batch_size 应被钳制为至少 1。")
	assert_eq(_analytics.get_queue_size(), 0, "batch_size 钳制为 1 后事件应立即 dry-run flush。")


## 验证配置关闭后不会继续记录事件。
func test_disabled_config_ignores_events() -> void:
	var config := GFAnalyticsConfig.new()
	config.enabled = false
	_analytics.configure(config)

	_analytics.track(&"ignored")

	assert_eq(_analytics.get_queue_size(), 0, "禁用后不应记录事件。")


## 验证持久 client id 可跨实例复用。
func test_persistent_client_id_survives_new_instance() -> void:
	var config := GFAnalyticsConfig.new()
	config.client_id_storage_path = "user://test_gf_analytics_client.cfg"
	config.flush_interval_seconds = 0.0
	config.auto_capture_context = false

	var first := GFAnalyticsUtility.new()
	first.configure(config)
	first.init()
	var client_id := first.get_client_id()
	first.dispose()

	var second := GFAnalyticsUtility.new()
	second.configure(config)
	second.init()

	assert_false(client_id.is_empty(), "首次初始化应生成 client id。")
	assert_eq(second.get_client_id(), client_id, "第二个实例应读取已持久化的 client id。")
	second.dispose()


## 验证 init 不会覆盖提前 identify 的稳定 ID。
func test_identify_before_init_is_preserved() -> void:
	var analytics := GFAnalyticsUtility.new()
	analytics.identify("pre-init-client")
	analytics.init()

	assert_eq(analytics.get_client_id(), "pre-init-client", "init 不应覆盖提前设置的 client id。")
	analytics.dispose()


## 验证自定义 transport hook 可接管 flush。
func test_transport_callback_receives_payload() -> void:
	var captured := { "payload": {} }
	_analytics.transport_callback = func(payload: Dictionary) -> Dictionary:
		captured["payload"] = payload
		return { "success": true, "accepted": 1, "custom": true }

	_analytics.track(&"opened")
	_analytics.flush()

	var captured_payload := captured["payload"] as Dictionary
	assert_true(captured_payload.has("events"), "transport hook 应收到由事件批次构建的 payload。")
	assert_eq(_analytics.get_queue_size(), 0, "自定义 transport 成功后应清空本批队列。")


## 验证 shutdown 会 flush 剩余事件并阻止后续记录。
func test_shutdown_flushes_and_ignores_future_events() -> void:
	_analytics.track(&"before_shutdown")

	_analytics.shutdown()
	_analytics.track(&"after_shutdown")

	assert_eq(_analytics.get_queue_size(), 0, "shutdown dry-run flush 后队列应为空，后续事件应被忽略。")


## 验证 shutdown 在同步 flush 路径中会清空超过单批大小的队列。
func test_shutdown_flushes_all_synchronous_batches() -> void:
	_analytics.config.batch_size = 10
	_analytics.config.max_queue_size = 10
	for index: int in range(5):
		_analytics.track(&"queued", { "index": index })
	_analytics.config.batch_size = 2

	_analytics.shutdown()

	assert_eq(_analytics.get_queue_size(), 0, "shutdown 应连续 flush dry-run 批次直到队列清空。")


# --- 私有/辅助方法 ---

func _remove_file_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
