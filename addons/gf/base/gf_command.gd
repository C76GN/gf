class_name GFCommand


## GFCommand: 命令抽象基类。
##
## 子类必须实现 'execute' 方法来定义命令逻辑。
## 'execute' 可返回 null（同步命令）或一个 Signal（异步命令）。
## 调用方可使用 'await send_command(MyCommand.new())' 等待异步命令完成。
## 提供对 Model、System、Utility 的访问以及发送命令和事件的能力。


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- 公共方法 ---

## 注入当前命令执行所在的架构实例。
## @param architecture: 当前执行命令的架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 执行命令逻辑。子类必须重写此方法。
## @return 同步命令返回 null；异步命令可返回一个 Signal 供外部 await。
func execute() -> Variant:
	return null


## 通过类型获取 Model 实例。
## @param model_type: 模型的脚本类型。
## @return 模型实例。
func get_model(model_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type)


## 通过类型获取 System 实例。
## @param system_type: 系统的脚本类型。
## @return 系统实例。
func get_system(system_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type)


## 通过类型获取 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例。
func get_utility(utility_type: Script) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type)


## 向架构发送命令。支持 await：'await send_command(MyCommand.new())'。
## @param command: 要发送的命令实例。
## @return 命令的执行结果（null 或 Signal）。
func send_command(command: Object) -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.send_command(command)


## 向架构发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_event(event_instance)


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
	return Gf.get_architecture()


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	if Gf.has_architecture():
		return Gf.get_architecture()
	return null
