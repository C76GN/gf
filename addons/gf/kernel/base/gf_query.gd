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


## 检查查询所属架构生命周期是否仍可安全继续异步写回。
## @return 所属架构仍处于活动生命周期时返回 true。
func is_lifecycle_active() -> bool:
	var architecture := _get_architecture_or_null()
	return architecture != null and architecture.is_lifecycle_active()


## 通过类型获取 Model 实例。
## @param model_type: 模型的脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 模型实例。
func get_model(model_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type, require_ready)


## 通过类型获取 System 实例。
## @param system_type: 系统的脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 系统实例。
func get_system(system_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type, require_ready)


## 通过类型获取 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 工具实例。
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type, require_ready)


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
