## GFAction: 动作队列常用工厂。
##
## 提供轻量、静态的动作创建入口，让项目用更少样板组合 ActionQueue。
## 它只创建通用动作，不隐含任何项目业务流程。
class_name GFAction
extends RefCounted


# --- 公共方法 ---

## 创建顺序动作组。
## @param actions: 子动作列表。
## @return 顺序动作组。
static func sequence(actions: Array) -> GFVisualActionGroup:
	return GFVisualActionGroup.new(actions, false)


## 创建并行动作组。
## @param actions: 子动作列表。
## @return 并行动作组。
static func parallel(actions: Array) -> GFVisualActionGroup:
	return GFVisualActionGroup.new(actions, true)


## 创建等待动作。
## @param seconds: 等待秒数。
## @param host_node: 可选宿主节点。
## @return 等待动作。
static func wait(seconds: float, host_node: Node = null) -> GFWaitAction:
	return GFWaitAction.new(seconds, host_node)


## 创建回调动作。
## @param callback: 要执行的回调。
## @param args: 回调参数。
## @return 回调动作。
static func callback(callback: Callable, args: Array = []) -> GFCallableAction:
	return GFCallableAction.new(callback, args)


## 创建重复动作。
## @param action_factory: 每轮创建动作的工厂。
## @param count: 重复次数；0 表示无限重复。
## @return 重复动作。
static func repeat(action_factory: Callable, count: int = 1) -> GFRepeatAction:
	return GFRepeatAction.new(action_factory, count)


## 创建无限重复动作。
## @param action_factory: 每轮创建动作的工厂。
## @return 无限重复动作。
static func repeat_forever(action_factory: Callable) -> GFRepeatAction:
	return GFRepeatAction.new(action_factory, 0)


## 创建通用属性 Tween 动作。
## @param target: 目标对象。
## @param property_name: 属性路径。
## @param target_value: 目标值。
## @param duration: 持续时间。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
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


## 创建移动到目标位置的 Tween 动作。
## @param target: 目标节点。
## @param target_position: 目标位置。
## @param duration: 持续时间。
## @param property_name: 位置属性路径。
## @return 移动动作。
static func move_to(
	target: Node,
	target_position: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"position"
) -> GFMoveTweenAction:
	return GFMoveTweenAction.new(target, target_position, duration, property_name)


## 创建相对移动 Tween 动作。
## @param target: 目标对象。
## @param offset: 相对偏移。
## @param duration: 持续时间。
## @param property_name: 位置属性路径。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func move_by(
	target: Object,
	offset: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"position",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	var merged_options := options.duplicate(true)
	merged_options["as_relative"] = true
	return tween(target, property_name, offset, duration, merged_options)


## 创建缩放到目标值的 Tween 动作。
## @param target: 目标对象。
## @param scale_value: 目标缩放。
## @param duration: 持续时间。
## @param property_name: 缩放属性路径。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func scale_to(
	target: Object,
	scale_value: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"scale",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, property_name, scale_value, duration, options)


## 创建相对缩放 Tween 动作。
## @param target: 目标对象。
## @param scale_delta: 相对缩放偏移。
## @param duration: 持续时间。
## @param property_name: 缩放属性路径。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func scale_by(
	target: Object,
	scale_delta: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"scale",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	var merged_options := options.duplicate(true)
	merged_options["as_relative"] = true
	return tween(target, property_name, scale_delta, duration, merged_options)


## 创建旋转到目标值的 Tween 动作。
## @param target: 目标对象。
## @param rotation_value: 目标旋转值。
## @param duration: 持续时间。
## @param property_name: 旋转属性路径。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func rotate_to(
	target: Object,
	rotation_value: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"rotation",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, property_name, rotation_value, duration, options)


## 创建相对旋转 Tween 动作。
## @param target: 目标对象。
## @param rotation_delta: 相对旋转偏移。
## @param duration: 持续时间。
## @param property_name: 旋转属性路径。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func rotate_by(
	target: Object,
	rotation_delta: Variant,
	duration: float = 0.2,
	property_name: NodePath = ^"rotation",
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	var merged_options := options.duplicate(true)
	merged_options["as_relative"] = true
	return tween(target, property_name, rotation_delta, duration, merged_options)


## 创建透明度 Tween 动作。
## @param target: 目标对象，通常为 CanvasItem。
## @param alpha: 目标 alpha。
## @param duration: 持续时间。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func fade_to(
	target: Object,
	alpha: float,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, ^"modulate:a", alpha, duration, options)


## 创建整体颜色 Tween 动作。
## @param target: 目标对象，通常为 CanvasItem。
## @param color: 目标颜色。
## @param duration: 持续时间。
## @param options: 可选 Tween 配置。
## @return 配置化 Tween 动作。
static func colorize(
	target: Object,
	color: Color,
	duration: float = 0.2,
	options: Dictionary = {}
) -> GFConfiguredTweenAction:
	return tween(target, ^"modulate", color, duration, options)


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
