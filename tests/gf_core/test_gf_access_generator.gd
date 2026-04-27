extends GutTest


# --- 常量 ---

const GF_ACCESS_GENERATOR_BASE := preload("res://addons/gf/editor/gf_access_generator.gd")


# --- 测试用例 ---

func test_build_source_generates_typed_accessors() -> void:
	var generator: Variant = GF_ACCESS_GENERATOR_BASE.new()
	var source: String = generator.build_source([
		{
			"class_name": "PlayerModel",
			"path": "res://player_model.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.MODEL,
		},
		{
			"class_name": "BattleSystem",
			"path": "res://battle_system.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.SYSTEM,
		},
		{
			"class_name": "StorageUtility",
			"path": "res://storage_utility.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.UTILITY,
		},
		{
			"class_name": "DealDamageCommand",
			"path": "res://deal_damage_command.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.COMMAND,
		},
	])

	assert_true(source.contains("static func get_player_model(architecture: GFArchitecture = null) -> PlayerModel:"), "应生成 Model 强类型访问器。")
	assert_true(source.contains("return resolved_architecture.get_system(BattleSystem) as BattleSystem"), "应生成 System 查询。")
	assert_true(source.contains("static func get_storage_utility(architecture: GFArchitecture = null) -> StorageUtility:"), "应生成 Utility 强类型访问器。")
	assert_true(source.contains("static func create_deal_damage_command(architecture: GFArchitecture = null) -> DealDamageCommand:"), "应生成 Command 创建入口。")


func test_build_source_skips_duplicate_function_names() -> void:
	var generator: Variant = GF_ACCESS_GENERATOR_BASE.new()
	var source: String = generator.build_source([
		{
			"class_name": "PlayerModel",
			"path": "res://a.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.MODEL,
		},
		{
			"class_name": "Player",
			"path": "res://b.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.MODEL,
		},
	])

	assert_eq(source.count("static func get_player_model"), 1, "重复函数名应只保留一个。")
	assert_push_warning("[GFAccessGenerator] 函数名重复，已跳过：get_player_model")
