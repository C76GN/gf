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
	var dispose_count: int = 0
	var last_msg: Dictionary = {}

	func enter(msg: Dictionary = {}) -> void:
		enter_count += 1
		last_msg = msg

	func update(_delta: float) -> void:
		update_count += 1

	func exit() -> void:
		exit_count += 1

	func dispose() -> void:
		dispose_count += 1
		super.dispose()

	func has_machine() -> bool:
		return _get_machine() != null


class DummyModel:
	extends GFModel


class DummySystem:
	extends GFSystem


class DummyUtility:
	extends GFUtility


class ContextUtility:
	extends GFUtility


class ContextHolder:
	extends RefCounted


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_fsm = GFStateMachine.new()


func after_each() -> void:
	if _fsm != null:
		_fsm.dispose()
	_fsm = null
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null


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


## 验证状态可通过自身代理请求状态切换。
func test_state_can_request_change_state() -> void:
	var idle := TrackingState.new()
	var run := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.add_state(&"Run", run)
	_fsm.start(&"Idle")

	idle.change_state(&"Run")

	assert_eq(idle.exit_count, 1, "State.change_state 应委托状态机退出当前状态。")
	assert_eq(run.enter_count, 1, "State.change_state 应委托状态机进入目标状态。")
	assert_eq(_fsm.current_state_name, &"Run", "State.change_state 应更新状态机当前状态。")


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


# --- 测试：dispose 与引用释放 ---

## 验证 dispose() 退出当前状态、释放所有状态并断开 State -> Machine 回链。
func test_dispose_exits_current_state_and_disposes_all_states() -> void:
	var idle := TrackingState.new()
	var run := TrackingState.new()
	_fsm.add_state(&"Idle", idle)
	_fsm.add_state(&"Run", run)
	_fsm.start(&"Idle")

	_fsm.dispose()

	assert_eq(idle.exit_count, 1, "dispose 应先退出当前状态。")
	assert_eq(idle.dispose_count, 1, "dispose 应释放当前状态。")
	assert_eq(run.dispose_count, 1, "dispose 应释放未激活但已注册的状态。")
	assert_false(idle.has_machine(), "dispose 后当前状态不应继续持有状态机引用。")
	assert_false(run.has_machine(), "dispose 后未激活状态不应继续持有状态机引用。")
	assert_eq(_fsm.current_state_name, &"", "dispose 后 current_state_name 应清空。")


## 验证替换同名状态时旧状态会断开对状态机的引用。
func test_add_state_replaces_old_state_safely() -> void:
	var old_idle := TrackingState.new()
	var new_idle := TrackingState.new()
	_fsm.add_state(&"Idle", old_idle)
	_fsm.add_state(&"Idle", new_idle)
	_fsm.start(&"Idle")

	assert_eq(old_idle.dispose_count, 1, "同名状态被替换时旧状态应被释放。")
	assert_false(old_idle.has_machine(), "同名状态被替换时旧状态不应保留状态机引用。")
	assert_true(new_idle.has_machine(), "新状态应持有可用的状态机弱引用。")
	assert_eq(new_idle.enter_count, 1, "启动时应进入新注册的状态。")


## 验证未 setup 或已 dispose 的状态代理方法不会崩溃。
func test_add_state_replacing_current_state_switches_active_reference() -> void:
	var old_idle := TrackingState.new()
	var new_idle := TrackingState.new()

	_fsm.add_state(&"Idle", old_idle)
	_fsm.start(&"Idle")
	_fsm.add_state(&"Idle", new_idle)
	_fsm.update(0.016)

	assert_eq(old_idle.exit_count, 1, "替换当前激活状态时，旧状态应先退出。")
	assert_eq(old_idle.dispose_count, 1, "替换当前激活状态时，旧状态应被释放。")
	assert_eq(new_idle.enter_count, 1, "替换当前激活状态时，新状态应接管并进入。")
	assert_eq(new_idle.update_count, 1, "接管后的新状态应继续接收 update。")


func test_state_proxy_methods_without_machine_are_safe() -> void:
	var state := TrackingState.new()

	state.change_state(&"Any")

	assert_null(state.get_model(DummyModel), "未绑定状态机的 State.get_model 应安全返回 null。")
	assert_null(state.get_system(DummySystem), "未绑定状态机的 State.get_system 应安全返回 null。")
	assert_null(state.get_utility(DummyUtility), "未绑定状态机的 State.get_utility 应安全返回 null。")


# --- 测试：框架依赖访问 ---

## 验证无 context 创建时，状态机仍可通过全局 Gf 获取框架依赖。
func test_get_dependencies_without_context_uses_global_architecture() -> void:
	var dependencies: Dictionary = await _setup_dependency_architecture()

	assert_eq(_fsm.get_model(DummyModel), dependencies["model"], "无 context 时应能获取 Model。")
	assert_eq(_fsm.get_system(DummySystem), dependencies["system"], "无 context 时应能获取 System。")
	assert_eq(_fsm.get_utility(DummyUtility), dependencies["utility"], "无 context 时应能获取 Utility。")


## 验证有效 context 不影响状态机获取框架依赖。
func test_get_dependencies_with_valid_context_uses_global_architecture() -> void:
	var dependencies: Dictionary = await _setup_dependency_architecture()
	var context := ContextHolder.new()
	_fsm.dispose()
	_fsm = GFStateMachine.new(context)

	assert_eq(_fsm.get_model(DummyModel), dependencies["model"], "有效 context 下应能获取 Model。")
	assert_eq(_fsm.get_system(DummySystem), dependencies["system"], "有效 context 下应能获取 System。")
	assert_eq(_fsm.get_utility(DummyUtility), dependencies["utility"], "有效 context 下应能获取 Utility。")


## 验证当 context 是已注入架构的模块时，状态机优先使用该局部架构。
func test_get_dependencies_with_module_context_uses_injected_architecture() -> void:
	var parent_arch := GFArchitecture.new()
	await Gf.set_architecture(parent_arch)

	var child_arch := GFArchitecture.new(parent_arch)
	var context := ContextUtility.new()
	var local_utility := DummyUtility.new()
	await child_arch.register_utility_instance(context)
	await child_arch.register_utility_instance(local_utility)

	_fsm.dispose()
	_fsm = GFStateMachine.new(context)

	assert_eq(_fsm.get_utility(DummyUtility), local_utility, "模块 context 应让状态机解析到注入的局部架构。")

	child_arch.dispose()
	parent_arch.dispose()
	Gf._architecture = null


## 验证 context 已释放时，状态机会拒绝继续访问框架依赖。
func test_get_dependency_with_released_context_returns_null() -> void:
	await _setup_dependency_architecture()
	var context := ContextHolder.new()
	_fsm.dispose()
	_fsm = GFStateMachine.new(context)
	context = null

	var model := _fsm.get_model(DummyModel)

	assert_null(model, "context 失效后应拒绝获取 Model。")
	assert_push_error("[GFStateMachine] 上下文无效，无法获取 Model。")


# --- 私有/辅助方法 ---

func _setup_dependency_architecture() -> Dictionary:
	var architecture := GFArchitecture.new()
	var model := DummyModel.new()
	var system := DummySystem.new()
	var utility := DummyUtility.new()

	await architecture.register_model_instance(model)
	await architecture.register_system_instance(system)
	await architecture.register_utility_instance(utility)
	await Gf.set_architecture(architecture)

	return {
		"model": model,
		"system": system,
		"utility": utility,
	}
