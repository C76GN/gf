## 测试 GFInputMapping / GFInputContext 资源上的查询与回退逻辑。
extends GutTest


func test_input_mapping_get_action_id_delegates_to_action() -> void:
	var action: GFInputAction = GFInputAction.new()
	action.action_id = &"fire"
	var mapping: GFInputMapping = GFInputMapping.new()
	mapping.action = action
	assert_eq(mapping.get_action_id(), &"fire")


func test_input_mapping_get_action_id_empty_without_action() -> void:
	var mapping: GFInputMapping = GFInputMapping.new()
	assert_eq(mapping.get_action_id(), &"")


func test_input_mapping_display_name_and_category_override_action() -> void:
	var action: GFInputAction = GFInputAction.new()
	action.action_id = &"jump"
	action.display_name = "动作默认名"
	action.display_category = "动作分类"
	var mapping: GFInputMapping = GFInputMapping.new()
	mapping.action = action
	mapping.display_name = "映射覆盖名"
	mapping.display_category = "映射分类"
	assert_eq(mapping.get_display_name(), "映射覆盖名")
	assert_eq(mapping.get_display_category(), "映射分类")


func test_input_mapping_display_fallback_to_action() -> void:
	var action: GFInputAction = GFInputAction.new()
	action.display_name = "仅动作名"
	var mapping: GFInputMapping = GFInputMapping.new()
	mapping.action = action
	assert_eq(mapping.get_display_name(), "仅动作名")
	assert_eq(mapping.get_display_category(), "")


func test_input_mapping_default_display_name_when_no_action() -> void:
	var mapping: GFInputMapping = GFInputMapping.new()
	assert_eq(mapping.get_display_name(), "Input Mapping")


func test_input_context_get_context_id_prefers_exported_id() -> void:
	var context: GFInputContext = GFInputContext.new()
	context.context_id = &"gameplay"
	assert_eq(context.get_context_id(), &"gameplay")


func test_input_context_get_display_name_prefers_exported_name() -> void:
	var context: GFInputContext = GFInputContext.new()
	context.context_id = &"menu"
	context.display_name = "主菜单"
	assert_eq(context.get_display_name(), "主菜单")


func test_input_context_get_display_name_falls_back_to_context_id_string() -> void:
	var context: GFInputContext = GFInputContext.new()
	context.context_id = &"dialogue"
	assert_eq(context.get_display_name(), "dialogue")


func test_input_context_get_context_id_falls_back_to_resource_path() -> void:
	var context: GFInputContext = GFInputContext.new()
	context.take_over_path("res://tests/gf_core/input_context_unit.tres")
	assert_eq(context.get_context_id(), StringName("res://tests/gf_core/input_context_unit.tres"))


func test_input_context_display_name_falls_back_to_resource_basename() -> void:
	var context: GFInputContext = GFInputContext.new()
	context.take_over_path("res://tests/gf_core/gameplay_input.tres")
	assert_eq(context.get_display_name(), "Gameplay Input")
