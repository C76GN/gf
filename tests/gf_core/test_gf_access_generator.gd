extends GutTest


# --- 常量 ---

const GF_ACCESS_GENERATOR_BASE := preload("res://addons/gf/editor/gf_access_generator.gd")
const GF_NODE_2D_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_node_2d_capability.gd")
const GF_NODE_3D_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_node_3d_capability.gd")
const GF_CONTROL_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_control_capability.gd")


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
		{
			"class_name": "HealthCapability",
			"path": "res://health_capability.gd",
			"kind": GF_ACCESS_GENERATOR_BASE.TargetKind.CAPABILITY,
		},
	])

	assert_true(source.contains("static func get_player_model(architecture: GFArchitecture = null) -> PlayerModel:"), "应生成 Model 强类型访问器。")
	assert_true(source.contains("return resolved_architecture.get_system(BattleSystem) as BattleSystem"), "应生成 System 查询。")
	assert_true(source.contains("static func get_storage_utility(architecture: GFArchitecture = null) -> StorageUtility:"), "应生成 Utility 强类型访问器。")
	assert_true(source.contains("static func create_deal_damage_command(architecture: GFArchitecture = null) -> DealDamageCommand:"), "应生成 Command 创建入口。")
	assert_true(source.contains("static func get_health_capability(receiver: Object, architecture: GFArchitecture = null) -> HealthCapability:"), "应生成能力查询入口。")
	assert_true(source.contains("static func add_health_capability(receiver: Object, architecture: GFArchitecture = null) -> HealthCapability:"), "应生成能力添加入口。")
	assert_true(source.contains("static func if_has_health_capability(receiver: Object, callback: Callable, architecture: GFArchitecture = null) -> Variant:"), "应生成能力条件回调入口。")
	assert_true(source.contains("instance.call(\"_gf_set_dependency_scope\", architecture)"), "fallback new() 的对象应先绑定内部依赖作用域。")


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


func test_resolve_kind_accepts_spatial_node_capability_bases() -> void:
	var generator: Variant = GF_ACCESS_GENERATOR_BASE.new()

	assert_eq(generator._resolve_kind(GF_NODE_2D_CAPABILITY_BASE), GF_ACCESS_GENERATOR_BASE.TargetKind.CAPABILITY, "GFNode2DCapability 应识别为能力。")
	assert_eq(generator._resolve_kind(GF_NODE_3D_CAPABILITY_BASE), GF_ACCESS_GENERATOR_BASE.TargetKind.CAPABILITY, "GFNode3DCapability 应识别为能力。")
	assert_eq(generator._resolve_kind(GF_CONTROL_CAPABILITY_BASE), GF_ACCESS_GENERATOR_BASE.TargetKind.CAPABILITY, "GFControlCapability 应识别为能力。")


func test_build_project_source_generates_layer_input_and_setting_constants() -> void:
	var generator: Variant = GF_ACCESS_GENERATOR_BASE.new()
	var source: String = generator.build_project_source({
		"layers": [
			{
				"group": "2d_physics",
				"name": "Player",
				"index": 3,
			},
		],
		"input_actions": [&"jump"],
		"settings": ["gf/project/installers"],
	})

	assert_true(source.contains("class_name GFProjectAccess"), "应生成项目常量访问器类。")
	assert_true(source.contains("const PHYSICS_2D_PLAYER_LAYER: int = 3"), "应生成层序号常量。")
	assert_true(source.contains("const PHYSICS_2D_PLAYER_BIT: int = 4"), "应生成层 bit 常量。")
	assert_true(source.contains("const JUMP: StringName = &\"jump\""), "应生成输入动作常量。")
	assert_true(source.contains("const GF_PROJECT_INSTALLERS: String = \"gf/project/installers\""), "应生成设置键常量。")
