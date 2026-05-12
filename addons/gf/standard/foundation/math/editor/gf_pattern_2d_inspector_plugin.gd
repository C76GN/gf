@tool

## GF Pattern2D Inspector: 为 GFPattern2D 提供网格化 cells 编辑器。
extends EditorInspectorPlugin


# --- 常量 ---

const GF_PATTERN_2D_BASE := preload("res://addons/gf/standard/foundation/math/gf_pattern_2d.gd")
const GF_PATTERN_2D_EDITOR_PROPERTY := preload("res://addons/gf/standard/foundation/math/editor/gf_pattern_2d_editor_property.gd")


# --- Godot 回调方法 ---

func _can_handle(object: Object) -> bool:
	return object is GF_PATTERN_2D_BASE


func _parse_property(
	_object: Object,
	_type: Variant.Type,
	name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	_usage_flags: int,
	_wide: bool
) -> bool:
	if name != "cells":
		return false

	add_property_editor("cells", GF_PATTERN_2D_EDITOR_PROPERTY.new())
	return true
