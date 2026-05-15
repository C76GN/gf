## 架构依赖作用域共享实现。
##
## 该脚本供 GFModel、GFSystem、GFUtility、GFCommand 与 GFQuery 复用，
## 用于保持注入架构、释放状态和全局回退规则一致。
extends RefCounted


# --- 私有/辅助方法 ---

static func _make_scope() -> Dictionary:
	return {
		"architecture_ref": null,
		"was_bound": false,
		"released": false,
	}


static func _bind_scope(scope: Dictionary, architecture: GFArchitecture) -> void:
	if architecture == null:
		_release_scope(scope)
		return

	scope["was_bound"] = true
	scope["released"] = false
	scope["architecture_ref"] = weakref(architecture)


static func _release_scope(scope: Dictionary) -> void:
	scope["architecture_ref"] = null
	if bool(scope.get("was_bound", false)):
		scope["released"] = true


static func _get_architecture_or_null(scope: Dictionary, owner_label: String) -> GFArchitecture:
	if bool(scope.get("released", false)):
		push_error("[%s] 依赖作用域已释放，无法继续访问架构。" % owner_label)
		return null

	var architecture_ref := scope.get("architecture_ref") as WeakRef
	if architecture_ref != null:
		var architecture := architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
		if bool(scope.get("was_bound", false)):
			push_error("[%s] 注入的架构已失效，无法回退到全局架构。" % owner_label)
			return null
	return GFAutoload.get_architecture_or_null()


static func _get_architecture_or_global(scope: Dictionary, owner_label: String) -> GFArchitecture:
	var architecture := _get_architecture_or_null(scope, owner_label)
	if architecture != null:
		return architecture
	if bool(scope.get("was_bound", false)) or bool(scope.get("released", false)):
		return null
	return GFAutoload.get_architecture()


static func _get_bound_architecture_or_null(scope: Dictionary) -> GFArchitecture:
	var architecture_ref := scope.get("architecture_ref") as WeakRef
	if architecture_ref == null:
		return null
	return architecture_ref.get_ref() as GFArchitecture
