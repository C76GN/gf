## 测试 GFInputProfileBank 的命名重映射配置管理行为。
extends GutTest


# --- 常量 ---

const GFInputProfileBankBase = preload("res://addons/gf/input/gf_input_profile_bank.gd")
const GFInputRemapConfigBase = preload("res://addons/gf/input/gf_input_remap_config.gd")


# --- 测试方法 ---

## 验证设置 profile 时默认保存配置副本。
func test_set_profile_stores_config_copy() -> void:
	var bank := GFInputProfileBankBase.new()
	var config := GFInputRemapConfigBase.new()
	config.set_binding(&"gameplay", &"jump", 0, _make_key_event(KEY_SPACE, true))

	bank.set_profile(&"keyboard", config)
	config.clear_binding(&"gameplay", &"jump", 0)
	var stored := bank.get_profile(&"keyboard")

	assert_true(stored.has_binding(&"gameplay", &"jump", 0), "profile bank 应保存配置副本，避免外部修改污染。")
	assert_eq(bank.active_profile_id, &"keyboard", "首个 profile 应自动成为 active profile。")


## 验证 profile ID 会排序返回，active profile 可切换。
func test_profile_ids_are_sorted_and_active_profile_switches() -> void:
	var bank := GFInputProfileBankBase.new()
	bank.set_profile(&"zeta", GFInputRemapConfigBase.new())
	bank.set_profile(&"alpha", GFInputRemapConfigBase.new())

	var ids := bank.get_profile_ids()
	var switched := bank.set_active_profile(&"alpha")

	assert_eq(ids[0], "alpha", "profile ID 应按字典序返回。")
	assert_eq(ids[1], "zeta", "profile ID 应按字典序返回。")
	assert_true(switched, "存在的 profile 应允许设为 active。")
	assert_eq(bank.active_profile_id, &"alpha", "active profile ID 应更新。")


## 验证从资源反序列化来的 String 键也能按 StringName 查询。
func test_string_profile_keys_are_accepted() -> void:
	var bank := GFInputProfileBankBase.new()
	bank.profiles["keyboard"] = GFInputRemapConfigBase.new()

	assert_true(bank.has_profile(&"keyboard"), "String 键 profile 应可用 StringName 查询。")
	assert_true(bank.remove_profile(&"keyboard"), "String 键 profile 应可用 StringName 移除。")
	assert_false(bank.has_profile(&"keyboard"), "移除后 profile 不应继续存在。")


## 验证 active profile 可返回副本。
func test_get_active_profile_can_return_copy() -> void:
	var bank := GFInputProfileBankBase.new()
	var config := bank.ensure_profile(&"keyboard")
	config.set_binding(&"gameplay", &"jump", 0, _make_key_event(KEY_SPACE, true))

	var duplicate_config := bank.get_active_profile(true)
	duplicate_config.clear_binding(&"gameplay", &"jump", 0)

	assert_true(
		bank.get_active_profile().has_binding(&"gameplay", &"jump", 0),
		"请求副本时修改返回值不应影响 bank 内部配置。"
	)


## 验证移除 active profile 后会选择剩余 profile。
func test_remove_active_profile_selects_remaining_profile() -> void:
	var bank := GFInputProfileBankBase.new()
	bank.set_profile(&"first", GFInputRemapConfigBase.new())
	bank.set_profile(&"second", GFInputRemapConfigBase.new())

	var removed := bank.remove_profile(&"first")

	assert_true(removed, "存在的 profile 应可移除。")
	assert_eq(bank.active_profile_id, &"second", "移除 active profile 后应选择剩余 profile。")


# --- 私有/辅助方法 ---

func _make_key_event(key: Key, pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	return event
