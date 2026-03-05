# addons/gf/base/gf_model.gd
class_name GFModel


## GFModel: 数据层抽象基类。
##
## 负责管理应用数据和业务状态。
## 子类可以实现 'init'、'async_init'、'ready'、'dispose' 来管理其生命周期。
##
## 三阶段初始化约定：
##   - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。
##   - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。
##   - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。


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


## 销毁模型。子类可以重写此方法。
func dispose() -> void:
	pass


## 将此模型的状态序列化为字典，用于存档、状态快照等。
## 子类应重写此方法以包含所有需要持久化的字段。
## @return 包含模型状态数据的字典。
func to_dict() -> Dictionary:
	return {}


## 从字典反序列化并恢复此模型的状态。
## 子类应重写此方法以恢复所有相关字段。
## @param _data: 包含状态数据的字典（通常来自 to_dict() 的结果）。
func from_dict(_data: Dictionary) -> void:
	pass


# --- 公共方法 ---

## 通过类型获取 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	return Gf.get_architecture().get_utility(utility_type)


## 向架构发送事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	Gf.get_architecture().send_event(event_instance)


## 发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	Gf.get_architecture().send_simple_event(event_id, payload)
