# addons/gf/base/gf_system.gd
class_name GFSystem


## GFSystem: 逻辑层抽象基类。
##
## 负责实现核心业务逻辑。
## 子类可以实现 'init'、'async_init'、'ready'、'dispose' 来管理其生命周期。
##
## 三阶段初始化约定：
##   - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。
##   - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。
##   - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。


# --- 公共变量 ---

## 是否忽略全局暂停。为 true 时，即使 GFTimeUtility.is_paused 为 true，
## 该 System 仍会接收到原始（未缩放）的 delta 值。
## 典型场景：暂停菜单动画、设置界面过渡效果等。
var ignore_pause: bool = false


# --- 私有变量 ---

## 懒加载缓存字典，存储本 System 首次获取过的 Model/System/Utility 实例。
## Key 为 Script 类型，Value 为对应实例。避免高频跨类哈希查找。
var _cache: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化。子类可以重写此方法。
## 约束：只允许初始化自身内部变量，不得跨模块获取依赖。
func init() -> void:
	pass


## 异步初始化阶段。子类可以重写此方法并在其中使用 await。
## 约束：在 init() 之后、ready() 之前执行。
func async_init() -> void:
	pass


## 第二阶段初始化。子类可以重写此方法。
## 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。
func ready() -> void:
	pass


## 销毁系统。子类可以重写此方法。
func dispose() -> void:
	pass


## 每帧更新回调。子类可以重写此方法以实现帧逻辑。
## 由架构在 _process 中统一驱动，无需 System 继承 Node。
## @param delta: 距上一帧的时间（秒）。
func tick(_delta: float) -> void:
	pass


## 物理帧更新回调。子类可以重写此方法以实现物理帧逻辑。
## 由架构在 _physics_process 中统一驱动，无需 System 继承 Node。
## @param delta: 距上一物理帧的时间（秒）。
func physics_tick(_delta: float) -> void:
	pass


# --- 获取方法 (懒加载缓存) ---

## 通过类型获取 Model 实例。首次调用后结果将缓存于本地。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	if not _cache.has(model_type):
		_cache[model_type] = Gf.get_architecture().get_model(model_type)
	return _cache[model_type]


## 通过类型获取 Utility 实例。首次调用后结果将缓存于本地。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	if not _cache.has(utility_type):
		_cache[utility_type] = Gf.get_architecture().get_utility(utility_type)
	return _cache[utility_type]


## 通过类型获取 System 实例。首次调用后结果将缓存于本地。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	if not _cache.has(system_type):
		_cache[system_type] = Gf.get_architecture().get_system(system_type)
	return _cache[system_type]


# --- 事件系统 ---

## 注册类型事件监听器。
## @param event_type: 要监听的脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
	Gf.get_architecture().register_event(event_type, callback, priority)


## 注销类型事件监听器。
## @param event_type: 要注销的脚本类型。
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	Gf.get_architecture().unregister_event(event_type, callback)


## 向架构发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	Gf.get_architecture().send_event(event_instance)


## 注册轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, callback: Callable) -> void:
	Gf.get_architecture().register_simple_event(event_id, callback)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	Gf.get_architecture().unregister_simple_event(event_id, callback)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	Gf.get_architecture().send_simple_event(event_id, payload)
