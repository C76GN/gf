# tests/gf_core/test_gf_state_machine.gd

## 测试 GFStateMachine 的状态注册、切换、update 驱动及信号发送功能。
extends GutTest


# --- 私有变量 ---

var _fsm: GFStateMachine


# --- 辅助状态类 ---

class TrackingState:
	extends GFState

	var enter_count: int = 0
	var exit_count: int = 0
	var update_count: int = 0
	var last_msg: Dictionary = {}

	func enter(msg: Dictionary = {}) -> void:
		enter_count += 1
		last_msg = msg

	func update(_delta: float) -> void:
		update_count += 1

	func exit() -> void:
		exit_count += 1


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_fsm = GFStateMachine.new()


func after_each() -> void:
	_fsm = null


# --- 测试：注册与启动 ---

## 验证 start() 调用初始状态的 enter()。
func test_start_calls_enter() -> void:
	var state := TrackingState.new()
	_fsm.add_state(&"Idle", state)
	_fsm.start(&"Idle")

	assert_eq(state.enter_count, 1, "start 应调用一次 enter。")
	assert_eq(_fsm.current_state_name, &"Idle", "current_state_name 应为 Idle。")


## 验证 start() 可传入初始消息。
func test_start_passes_msg() -> void:
	var state := TrackingState.new()
	_fsm.add_state(&"Idle", state)
	_fsm.start(&"Idle", {"key": 42})

	assert_eq(state.last_msg.get("key"), 42, "enter 应收到传入的 msg。")


## 验证 start() 对未知状态名打印错误且不崩溃。
func test_start_unknown_state_is_safe() -> void:
	_fsm.start(&"Unknown")
	assert_eq(_fsm.current_state_name, &"", "未找到状态时 current_state_name 应保持空。")


# --- 测试：状态切换 ---

## 验证 change_state 调用旧状态 exit() 和新状态 enter()。
func test_change_state_calls_exit_and_enter() -> void:
	var idle := TrackingState.new()
	var run := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.add_state(&"Run", run)
	_fsm.start(&"Idle")

	_fsm.change_state(&"Run")

	assert_eq(idle.exit_count, 1, "离开 Idle 应调用一次 exit。")
	assert_eq(run.enter_count, 1, "进入 Run 应调用一次 enter。")
	assert_eq(_fsm.current_state_name, &"Run", "current_state_name 应更新为 Run。")


## 验证 change_state 发出 state_changed 信号。
func test_change_state_emits_signal() -> void:
	var idle := TrackingState.new()
	var run := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.add_state(&"Run", run)
	_fsm.start(&"Idle")

	watch_signals(_fsm)
	_fsm.change_state(&"Run")

	assert_signal_emitted_with_parameters(_fsm, "state_changed", [&"Idle", &"Run"])


## 验证 change_state 对未知状态名打印错误且不改变当前状态。
func test_change_state_unknown_is_safe() -> void:
	var idle := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.start(&"Idle")

	_fsm.change_state(&"NonExistent")

	assert_eq(_fsm.current_state_name, &"Idle", "未找到状态时 current_state_name 不应变化。")


# --- 测试：update 与 stop ---

## 验证 update 将 delta 传递给当前状态。
func test_update_calls_current_state_update() -> void:
	var idle := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.start(&"Idle")

	_fsm.update(0.016)
	_fsm.update(0.016)

	assert_eq(idle.update_count, 2, "调用两次 update 应驱动状态的 update 两次。")


## 验证 stop() 调用当前状态的 exit() 并清空状态。
func test_stop_calls_exit_and_clears_state() -> void:
	var idle := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.start(&"Idle")

	_fsm.stop()

	assert_eq(idle.exit_count, 1, "stop 应调用当前状态的 exit。")
	assert_eq(_fsm.current_state_name, &"", "stop 后 current_state_name 应清空。")
