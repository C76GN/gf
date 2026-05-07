## GFQuery: 查询抽象基类。
##
## 用于从架构中查询数据。子类必须返回结果。
## 子类必须实现 'execute' 方法来定义查询逻辑。
class_name GFQuery


# --- 私有变量 ---

var _architecture_ref: WeakRef = null
var _dependency_scope_was_bound: bool = false
var _dependency_scope_released: bool = false


# --- 公共方法 ---

## 注入当前查询执行所在的架构实例。
## @param architecture: 当前执行查询的架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_gf_set_dependency_scope(architecture)


## 执行查询并返回结果。子类必须重写此方法。
## @return 查询结果。
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


# --- 私有/辅助方法 ---

func _gf_set_dependency_scope(architecture: GFArchitecture) -> void:
	if architecture == null:
		_release_dependency_scope()
		return

	_dependency_scope_was_bound = true
	_dependency_scope_released = false
	_architecture_ref = weakref(architecture)


func _get_architecture() -> GFArchitecture:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		return architecture
	return GFAutoload.get_architecture()


func _release_dependency_scope() -> void:
	_architecture_ref = null
	if _dependency_scope_was_bound:
		_dependency_scope_released = true


func _get_architecture_or_null() -> GFArchitecture:
	if _dependency_scope_released:
		push_error("[GFQuery] 依赖作用域已释放，无法继续访问架构。")
		return null
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
		if _dependency_scope_was_bound:
			push_error("[GFQuery] 注入的架构已失效，无法回退到全局架构。")
			return null
	return GFAutoload.get_architecture_or_null()
