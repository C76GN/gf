## GFTimeProvider: 架构 tick 时间缩放协议。
##
## 该基类只定义 `GFArchitecture` 需要理解的时间控制契约。
## 具体时间工具可以继承它来提供暂停、缩放和物理子步能力。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFTimeProvider
extends GFUtility


# --- 公共方法 ---

## 获取普通 tick 使用的 delta。
## [br]
## @api public
## [br]
## @param delta: 引擎原始帧间隔时间。
## [br]
## @return 模块应接收的 delta。
func get_scaled_delta(delta: float) -> float:
	return delta


## 获取 physics_tick 使用的 delta 子步数组。
## [br]
## @api public
## [br]
## @param delta: 引擎原始物理帧间隔时间。
## [br]
## @return 模块应依次接收的 physics delta。
func get_physics_scaled_delta_steps(delta: float) -> Array[float]:
	return [get_scaled_delta(delta)]


## 判断当前物理帧是否需要拆分为多个子步。
## [br]
## @api public
## [br]
## @param delta: 引擎原始物理帧间隔时间。
## [br]
## @return 需要拆分时返回 true。
func should_substep_physics(delta: float) -> bool:
	return get_physics_scaled_delta_steps(delta).size() > 1


## 检查当前时间提供者是否处于全局暂停状态。
## [br]
## @api public
## [br]
## @return 暂停时返回 true。
func is_time_paused() -> bool:
	return false
