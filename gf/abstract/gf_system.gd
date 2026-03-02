# addons/gf/abstract/gf_system.gd
class_name GFSystem


## GFSystem: 逻辑层抽象基类。
##
## 负责实现核心业务逻辑。
## 子类可以实现 'init'、'ready'、'dispose' 来管理其生命周期。
##
## 两阶段初始化约定：
##   - 'init'  阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。
##   - 'ready' 阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。


# --- 私有变量 ---

## 懒加载缓存字典，存储本 System 首次获取过的 Model/System/Utility 实例。
## Key 为 Script 类型，Value 为对应实例。避免高频跨类哈希查找。
var _cache: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化。子类可以重写此方法。
## 约束：只允许初始化自身内部变量，不得跨模块获取依赖。
func init() -> void:
	pass


## 第二阶段初始化。子类可以重写此方法。
## 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。
func ready() -> void:
	pass


## 销毁系统。子类可以重写此方法。
func dispose() -> void:
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
func register_event(event_type: Script, callback: Callable) -> void:
	Gf.get_architecture().register_event(event_type, callback)


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
