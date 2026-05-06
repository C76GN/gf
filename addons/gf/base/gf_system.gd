## GFSystem: 逻辑层抽象基类。
##
## 负责实现核心业务逻辑。
## 子类可以实现 'init'、'async_init'、'ready'、'dispose' 来管理其生命周期。
##
## 三阶段初始化约定：
##   - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。
##   - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。
##   - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。
class_name GFSystem


# --- 公共变量 ---

## 是否忽略全局暂停。为 true 时，即使 GFTimeUtility.is_paused 为 true，
## 该 System 仍会接收到原始（未缩放）的 delta 值。
## 典型场景：暂停菜单动画、设置界面过渡效果等。
var ignore_pause: bool = false

## 是否忽略 GFTimeUtility.time_scale。为 true 且未全局暂停时，
## 该 System 的 tick / physics_tick 会接收到原始 delta。
var ignore_time_scale: bool = false


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

## 第一阶段初始化。子类可以重写此方法。
## 约束：只允许初始化自身内部变量，不得跨模块获取依赖。
func init() -> void:
	pass


## 异步初始化阶段。子类可以重写此方法并在其中使用 await。
## Godot 4 支持在 void 函数内部使用 await，框架的 Gf.init() 会串行且安全地 await 每个模块的 async_init()，不再需要返回 Signal。
## 约束：在 init() 之后、ready() 之前执行。
func async_init() -> void:
	pass


## 第三阶段初始化。子类可以重写此方法。
## 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。
func ready() -> void:
	pass


## 销毁系统。子类可以重写此方法。
func dispose() -> void:
	pass


## 每帧更新回调。子类可以重写此方法以实现帧逻辑。
## 由架构在 _process 中统一驱动，无需 System 继承 Node。
## @param _delta: 距上一帧的时间（秒）。
func tick(_delta: float) -> void:
	pass


## 物理帧更新回调。子类可以重写此方法以实现物理帧逻辑。
## 由架构在 _physics_process 中统一驱动，无需 System 继承 Node。
## @param _delta: 距上一物理帧的时间（秒）。
func physics_tick(_delta: float) -> void:
	pass


# --- 获取方法 ---

## 注入当前模块所属的架构实例。由 GFArchitecture 在注册模块时自动调用。
## @param architecture: 当前注册该模块的架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 通过类型获取 Model 实例。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type)


## 通过类型获取 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type)


## 通过类型获取 System 实例。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type)


# --- 事件系统 ---

## 注册类型事件监听器。
## @param event_type: 要监听的脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_event_owned(self, event_type, callback, priority)


## 注销类型事件监听器。
## @param event_type: 要注销的脚本类型。
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.unregister_event(event_type, callback)


## 注册可赋值类型事件监听器。
## @param base_event_type: 要监听的基类脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_assignable_event(base_event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_assignable_event_owned(self, base_event_type, callback, priority)


## 注销可赋值类型事件监听器。
## @param base_event_type: 注册时使用的基类脚本类型。
## @param callback: 要移除的回调函数。
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.unregister_assignable_event(base_event_type, callback)


## 向架构发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_event(event_instance)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_simple_event_owned(self, event_id, callback)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.unregister_simple_event(event_id, callback)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_simple_event(event_id, payload)


# --- 私有/辅助方法 ---

func _get_architecture() -> GFArchitecture:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		return architecture
	return GFAutoload.get_architecture()


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()
