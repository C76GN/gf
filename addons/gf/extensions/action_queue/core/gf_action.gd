## GFAction: 动作队列常用工厂。
##
## 提供轻量、静态的动作创建入口，让项目用更少样板组合 ActionQueue。
## 它只创建通用动作，不隐含任何项目业务流程。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFAction
extends RefCounted


# --- 公共方法 ---

## 创建顺序动作组。
## [br]
## @api public
## [br]
## @param actions: 子动作列表。
## [br]
## @return 顺序动作组。
## [br]
## @schema actions: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。
static func sequence(actions: Array) -> GFVisualActionGroup:
	return GFVisualActionGroup.new(actions, false)


## 创建并行动作组。
## [br]
## @api public
## [br]
## @param actions: 子动作列表。
## [br]
## @return 并行动作组。
## [br]
## @schema actions: Array，元素为 GFVisualAction 或实现 execute() 协议的动作对象。
static func parallel(actions: Array) -> GFVisualActionGroup:
	return GFVisualActionGroup.new(actions, true)


## 创建等待动作。
## [br]
## @api public
## [br]
## @param seconds: 等待秒数。
## [br]
## @param host_node: 可选宿主节点。
## [br]
## @return 等待动作。
static func wait(seconds: float, host_node: Node = null) -> GFWaitAction:
	return GFWaitAction.new(seconds, host_node)


## 创建回调动作。
## [br]
## @api public
## [br]
## @param callback: 要执行的回调。
## [br]
## @param args: 回调参数。
## [br]
## @return 回调动作。
## [br]
## @schema args: Array，传给 callback.callv() 的参数列表。
static func callback(callback: Callable, args: Array = []) -> GFCallableAction:
	return GFCallableAction.new(callback, args)


## 创建重复动作。
## [br]
## @api public
## [br]
## @param action_factory: 每轮创建动作的工厂。
## [br]
## @param count: 重复次数；0 表示无限重复。
## [br]
## @return 重复动作。
static func repeat(action_factory: Callable, count: int = 1) -> GFRepeatAction:
	return GFRepeatAction.new(action_factory, count)


## 创建无限重复动作。
## [br]
## @api public
## [br]
## @param action_factory: 每轮创建动作的工厂。
## [br]
## @return 无限重复动作。
static func repeat_forever(action_factory: Callable) -> GFRepeatAction:
	return GFRepeatAction.new(action_factory, 0)


## 创建通用属性 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param property_name: 属性路径。
## [br]
## @param target_value: 目标值。
## [br]
## @param duration: 持续时间。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema target_value: Variant，可被 Tween 写入 property_name 的目标值。
## [br]
## @schema options: Dictionary，支持 host_node、duration_scale、loop_count、ignore_time_scale、process_mode、pause_mode、delay、parallel、as_relative、transition_type 和 ease_type。
static func tween(
	target: Object,
	property_name: NodePath,
	target_value: Variant,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	var config := GFTweenActionConfig.new()
	var step := config.add_property_step(property_name, target_value, duration)
	_apply_tween_options(config, step, options)
	return config.create_action(target, options.get("host_node", null) as Node) as GFConfiguredTweenAction


## 创建通用相对属性 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param property_name: 属性路径。
## [br]
## @param offset: 相对偏移值。
## [br]
## @param duration: 持续时间。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema offset: Variant，会与当前属性值相加的相对偏移。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。
static func tween_by(
	target: Object,
	property_name: NodePath,
	offset: Variant,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	var merged_options := options.duplicate(true)
	merged_options["as_relative"] = true
	return tween(target, property_name, offset, duration, merged_options)


## 创建移动到目标位置的 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标节点。
## [br]
## @param target_position: 目标位置。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 位置属性路径。
## [br]
## @return 移动动作。
## [br]
## @schema target_position: Variant，可写入 property_name 的目标位置，通常为 Vector2、Vector3 或 float。
static func move_to(
	target: Node,
	target_position: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"position"
) -> GFMoveTweenAction:
	return GFMoveTweenAction.new(target, target_position, duration, property_name)


## 创建相对移动 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param offset: 相对偏移。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 位置属性路径。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema offset: Variant，会与当前 property_name 值相加的相对偏移。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。
static func move_by(
	target: Object,
	offset: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"position",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween_by(target, property_name, offset, duration, options)


## 创建缩放到目标值的 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param scale_value: 目标缩放。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 缩放属性路径。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema scale_value: Variant，可写入 property_name 的目标缩放值。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options。
static func scale_to(
	target: Object,
	scale_value: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"scale",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, property_name, scale_value, duration, options)


## 创建相对缩放 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param scale_delta: 相对缩放偏移。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 缩放属性路径。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema scale_delta: Variant，会与当前 property_name 值相加的相对缩放偏移。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。
static func scale_by(
	target: Object,
	scale_delta: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"scale",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween_by(target, property_name, scale_delta, duration, options)


## 创建旋转到目标值的 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param rotation_value: 目标旋转值。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 旋转属性路径。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema rotation_value: Variant，可写入 property_name 的目标旋转值。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options。
static func rotate_to(
	target: Object,
	rotation_value: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"rotation",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, property_name, rotation_value, duration, options)


## 创建相对旋转 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param rotation_delta: 相对旋转偏移。
## [br]
## @param duration: 持续时间。
## [br]
## @param property_name: 旋转属性路径。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema rotation_delta: Variant，会与当前 property_name 值相加的相对旋转偏移。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。
static func rotate_by(
	target: Object,
	rotation_delta: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"rotation",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween_by(target, property_name, rotation_delta, duration, options)


## 创建透明度 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象，通常为 CanvasItem。
## [br]
## @param alpha: 目标 alpha。
## [br]
## @param duration: 持续时间。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options。
static func fade_to(
	target: Object,
	alpha: float,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, ^"modulate:a", alpha, duration, options)


## 创建相对透明度 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象，通常为 CanvasItem。
## [br]
## @param alpha_delta: 相对 alpha 偏移。
## [br]
## @param duration: 持续时间。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options，并强制启用 as_relative。
static func fade_by(
	target: Object,
	alpha_delta: float,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween_by(target, ^"modulate:a", alpha_delta, duration, options)


## 创建整体颜色 Tween 动作。
## [br]
## @api public
## [br]
## @param target: 目标对象，通常为 CanvasItem。
## [br]
## @param color: 目标颜色。
## [br]
## @param duration: 持续时间。
## [br]
## @param options: 可选 Tween 配置。
## [br]
## @return 配置化 Tween 动作。
## [br]
## @schema options: Dictionary，字段同 tween() 的 options。
static func colorize(
	target: Object,
	color: Color,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, ^"modulate", color, duration, options)


## 创建设置任意属性的瞬时动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param property_name: 属性路径。
## [br]
## @param value: 要写入的值。
## [br]
## @return 回调动作。
## [br]
## @schema value: Variant，会通过 target.set_indexed(property_name, value) 写入的值。
static func set_property(target: Object, property_name: NodePath, value: Variant) -> GFCallableAction:
	return GFCallableAction.new(func() -> void:
		if is_instance_valid(target):
			target.set_indexed(property_name, value)
	)


## 创建设置 visible 属性的瞬时动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param visible: 可见性。
## [br]
## @param property_name: 可见性属性路径。
## [br]
## @return 回调动作。
static func set_visible(target: Object, visible: bool, property_name: NodePath = ^"visible") -> GFCallableAction:
	return set_property(target, property_name, visible)


## 创建显示目标的瞬时动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param property_name: 可见性属性路径。
## [br]
## @return 回调动作。
static func show(target: Object, property_name: NodePath = ^"visible") -> GFCallableAction:
	return set_visible(target, true, property_name)


## 创建隐藏目标的瞬时动作。
## [br]
## @api public
## [br]
## @param target: 目标对象。
## [br]
## @param property_name: 可见性属性路径。
## [br]
## @return 回调动作。
static func hide(target: Object, property_name: NodePath = ^"visible") -> GFCallableAction:
	return set_visible(target, false, property_name)


## 创建释放节点的瞬时动作。
## [br]
## @api public
## [br]
## @param target: 要释放的节点。
## [br]
## @return 回调动作。
static func remove_node(target: Node) -> GFCallableAction:
	return GFCallableAction.new(func() -> void:
		if is_instance_valid(target):
			target.queue_free()
	)


# --- 私有/辅助方法 ---

static func _apply_tween_options(
	config: GFTweenActionConfig,
	step: GFTweenActionStep,
	options: Dictionary
) -> void:
	if options.has("duration_scale"):
		config.duration_scale = float(options["duration_scale"])
	if options.has("loop_count"):
		config.loop_count = maxi(int(options["loop_count"]), 0)
	if options.has("ignore_time_scale"):
		config.ignore_time_scale = bool(options["ignore_time_scale"])
	if options.has("process_mode"):
		config.process_mode = int(options["process_mode"])
	if options.has("pause_mode"):
		config.pause_mode = int(options["pause_mode"])

	if options.has("delay"):
		step.delay = maxf(float(options["delay"]), 0.0)
	if options.has("parallel"):
		step.parallel = bool(options["parallel"])
	if options.has("as_relative"):
		step.as_relative = bool(options["as_relative"])
	if options.has("transition_type"):
		step.transition_type = int(options["transition_type"])
	if options.has("ease_type"):
		step.ease_type = int(options["ease_type"])
