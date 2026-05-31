# 架构依赖作用域共享实现。
#
# 该脚本供 GFModel、GFSystem、GFUtility、GFCommand 与 GFQuery 复用，
# 用于保持注入架构、释放状态和全局回退规则一致。
extends RefCounted


# --- 常量 ---

const _GF_VARIANT_ACCESS_SCRIPT = preload("res://addons/gf/kernel/core/gf_variant_access.gd")


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
	if _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(scope, "was_bound"):
		scope["released"] = true


static func _get_architecture_or_null(scope: Dictionary, owner_label: String) -> GFArchitecture:
	if _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(scope, "released"):
		push_error("[%s] 依赖作用域已释放，无法继续访问架构。" % owner_label)
		return null

	var architecture_ref: WeakRef = _get_scope_architecture_ref_or_null(scope)
	if architecture_ref != null:
		var architecture: GFArchitecture = _get_architecture_from_ref_or_null(architecture_ref)
		if architecture != null:
			return architecture
		if _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(scope, "was_bound"):
			push_error("[%s] 注入的架构已失效，无法回退到全局架构。" % owner_label)
			return null
	return GFAutoload.get_architecture_or_null()


static func _get_architecture_or_global(scope: Dictionary, owner_label: String) -> GFArchitecture:
	var architecture: GFArchitecture = _get_architecture_or_null(scope, owner_label)
	if architecture != null:
		return architecture
	if (
		_GF_VARIANT_ACCESS_SCRIPT.get_option_bool(scope, "was_bound")
		or _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(scope, "released")
	):
		return null
	return GFAutoload.get_architecture()


static func _get_bound_architecture_or_null(scope: Dictionary) -> GFArchitecture:
	var architecture_ref: WeakRef = _get_scope_architecture_ref_or_null(scope)
	if architecture_ref == null:
		return null
	return _get_architecture_from_ref_or_null(architecture_ref)


static func _get_scope_architecture_ref_or_null(scope: Dictionary) -> WeakRef:
	var raw_ref: Variant = _GF_VARIANT_ACCESS_SCRIPT.get_option_value(scope, "architecture_ref")
	if raw_ref is WeakRef:
		return raw_ref
	return null


static func _get_architecture_from_ref_or_null(architecture_ref: WeakRef) -> GFArchitecture:
	var raw_architecture: Variant = architecture_ref.get_ref()
	if raw_architecture is GFArchitecture:
		var architecture: GFArchitecture = raw_architecture
		return architecture
	return null
