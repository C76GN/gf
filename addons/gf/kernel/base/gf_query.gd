## GFQuery: 查询抽象基类。
##
## 用于从架构中查询数据。子类必须返回结果。
## 子类必须实现 'execute' 方法来定义查询逻辑。
class_name GFQuery


# --- 常量 ---

const _DEPENDENCY_SCOPE_SUPPORT: Script = preload("res://addons/gf/kernel/base/gf_dependency_scope_support.gd")


# --- 私有变量 ---

var _dependency_scope: Dictionary = _DEPENDENCY_SCOPE_SUPPORT._make_scope()


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
	_DEPENDENCY_SCOPE_SUPPORT._bind_scope(_dependency_scope, architecture)


func _get_architecture() -> GFArchitecture:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		return architecture
	return GFAutoload.get_architecture()


func _release_dependency_scope() -> void:
	_DEPENDENCY_SCOPE_SUPPORT._release_scope(_dependency_scope)


func _get_architecture_or_null() -> GFArchitecture:
	return _DEPENDENCY_SCOPE_SUPPORT._get_architecture_or_null(_dependency_scope, "GFQuery") as GFArchitecture
