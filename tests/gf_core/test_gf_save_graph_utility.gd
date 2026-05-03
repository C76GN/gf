## 测试 GFSaveGraphUtility 的通用 Scope/Source 编排。
extends GutTest


# --- 常量 ---

const GFSaveGraphUtilityBase = preload("res://addons/gf/extensions/save/gf_save_graph_utility.gd")
const GFSavePipelineStepBase = preload("res://addons/gf/extensions/save/gf_save_pipeline_step.gd")
const GFSaveScopeBase = preload("res://addons/gf/extensions/save/gf_save_scope.gd")
const GFSaveSourceBase = preload("res://addons/gf/extensions/save/gf_save_source.gd")


# --- 辅助类 ---

class MetadataPipelineStep extends GFSavePipelineStep:
	func after_gather_scope(_scope: GFSaveScope, payload: Dictionary, _context: Dictionary = {}) -> Variant:
		payload["pipeline_marker"] = "applied"
		return payload


# --- 私有变量 ---

var _utility: GFSaveGraphUtilityBase
var _scope: GFSaveScopeBase


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFSaveGraphUtilityBase.new()
	_scope = GFSaveScopeBase.new()
	_scope.name = "RootScope"
	_scope.scope_key = &"root"
	get_tree().root.add_child(_scope)


func after_each() -> void:
	if is_instance_valid(_scope):
		_scope.queue_free()
	_scope = null
	_utility = null
	await get_tree().process_frame


# --- 测试方法 ---

## 验证默认 Transform2D 序列化器可采集并恢复节点状态。
func test_gather_and_apply_transform_2d_source() -> void:
	var target := Node2D.new()
	target.name = "Target"
	target.position = Vector2(12.0, -3.0)
	target.rotation = 0.75
	target.scale = Vector2(2.0, 3.0)
	_scope.add_child(target)

	var source := _make_source(&"target_state", NodePath("../Target"))
	_scope.add_child(source)

	var payload := _utility.gather_scope(_scope)
	target.position = Vector2.ZERO
	target.rotation = 0.0
	target.scale = Vector2.ONE

	var result := _utility.apply_scope(_scope, payload)

	assert_true(bool(result["ok"]), "应用存档图应成功。")
	assert_eq(target.position, Vector2(12.0, -3.0), "Transform2D position 应被恢复。")
	assert_almost_eq(target.rotation, 0.75, 0.001, "Transform2D rotation 应被恢复。")
	assert_eq(target.scale, Vector2(2.0, 3.0), "Transform2D scale 应被恢复。")


## 验证子 Scope 会独立写入嵌套载荷。
func test_nested_scope_is_gathered_separately() -> void:
	var child_scope := GFSaveScopeBase.new()
	child_scope.name = "ChildScope"
	child_scope.scope_key = &"child"
	_scope.add_child(child_scope)

	var target := Node2D.new()
	target.name = "ChildTarget"
	target.position = Vector2(5.0, 6.0)
	child_scope.add_child(target)
	child_scope.add_child(_make_source(&"child_state", NodePath("../ChildTarget")))

	var payload := _utility.gather_scope(_scope)

	assert_true((payload["scopes"] as Dictionary).has("child"), "子 Scope 应写入 scopes 字典。")
	var child_payload := (payload["scopes"] as Dictionary)["child"] as Dictionary
	assert_true((child_payload["sources"] as Dictionary).has("child_state"), "子 Scope 内的 Source 应写入子载荷。")


## 验证默认 UI 序列化器可采集并恢复 Control/Range 通用状态。
func test_default_ui_serializers_restore_control_and_range_state() -> void:
	var slider := HSlider.new()
	slider.name = "Slider"
	slider.value = 42.0
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.visible = false
	slider.offset_left = 12.0
	_scope.add_child(slider)

	var source := _make_source(&"slider_state", NodePath("../Slider"))
	_scope.add_child(source)

	var payload := _utility.gather_scope(_scope)
	slider.value = 0.0
	slider.visible = true
	slider.offset_left = 0.0

	var result := _utility.apply_scope(_scope, payload)

	assert_true(bool(result["ok"]), "应用 UI 存档图应成功。")
	assert_almost_eq(slider.value, 42.0, 0.001, "Range value 应恢复。")
	assert_false(slider.visible, "CanvasItem visible 应恢复。")
	assert_almost_eq(slider.offset_left, 12.0, 0.001, "Control offset 应恢复。")


## 验证默认 Timer 序列化器可恢复计时器通用状态。
func test_default_timer_serializer_restores_timer_state() -> void:
	var timer := Timer.new()
	timer.name = "Timer"
	timer.wait_time = 2.5
	timer.one_shot = true
	timer.autostart = false
	timer.paused = true
	_scope.add_child(timer)

	var source := _make_source(&"timer_state", NodePath("../Timer"))
	_scope.add_child(source)

	var payload := _utility.gather_scope(_scope)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.paused = false

	var result := _utility.apply_scope(_scope, payload)

	assert_true(bool(result["ok"]), "应用 Timer 存档图应成功。")
	assert_almost_eq(timer.wait_time, 2.5, 0.001, "Timer wait_time 应恢复。")
	assert_true(timer.one_shot, "Timer one_shot 应恢复。")
	assert_true(timer.paused, "Timer paused 应恢复。")


## 验证默认 AudioStreamPlayer 序列化器可恢复播放参数。
func test_default_audio_stream_player_serializer_restores_audio_state() -> void:
	var player := AudioStreamPlayer.new()
	player.name = "Audio"
	player.stream = AudioStreamGenerator.new()
	player.volume_db = -12.0
	player.pitch_scale = 1.25
	_scope.add_child(player)
	player.play()
	player.stream_paused = true

	var source := _make_source(&"audio_state", NodePath("../Audio"))
	_scope.add_child(source)

	var payload := _utility.gather_scope(_scope)
	player.volume_db = 0.0
	player.pitch_scale = 1.0
	player.stream_paused = false

	var result := _utility.apply_scope(_scope, payload)

	assert_true(bool(result["ok"]), "应用 AudioStreamPlayer 存档图应成功。")
	assert_almost_eq(player.volume_db, -12.0, 0.001, "Audio volume_db 应恢复。")
	assert_almost_eq(player.pitch_scale, 1.25, 0.001, "Audio pitch_scale 应恢复。")
	assert_true(player.stream_paused, "Audio stream_paused 应恢复。")


## 验证存档 pipeline 可在采集后追加通用载荷。
func test_pipeline_step_can_modify_gathered_payload() -> void:
	_utility.add_pipeline_step(MetadataPipelineStep.new())

	var payload := _utility.gather_scope(_scope)

	assert_eq(payload.get("pipeline_marker", ""), "applied", "pipeline step 应能修改采集载荷。")


## 验证 Scope 诊断会报告同作用域重复 Source key。
func test_inspect_scope_reports_duplicate_source_keys() -> void:
	var target_a := Node2D.new()
	target_a.name = "TargetA"
	_scope.add_child(target_a)
	var target_b := Node2D.new()
	target_b.name = "TargetB"
	_scope.add_child(target_b)
	_scope.add_child(_make_source(&"state", NodePath("../TargetA")))
	_scope.add_child(_make_source(&"state", NodePath("../TargetB")))

	var report := _utility.inspect_scope(_scope)

	assert_false(bool(report["ok"]), "重复 Source key 应使诊断报告失败。")
	assert_true(_has_issue(report, "duplicate_source_key"), "诊断报告应包含 duplicate_source_key。")


## 验证载荷校验会报告当前 Scope 中不存在的 Source。
func test_validate_payload_for_scope_reports_missing_source() -> void:
	var payload := {
		"format": GFSaveGraphUtilityBase.FORMAT_ID,
		"format_version": GFSaveGraphUtilityBase.FORMAT_VERSION,
		"scope": {},
		"sources": {
			"missing": {
				"descriptor": {},
				"data": {},
			},
		},
		"scopes": {},
	}

	var report := _utility.validate_payload_for_scope(_scope, payload, true)

	assert_false(bool(report["ok"]), "strict 校验下缺失 Source 应失败。")
	assert_true(_has_issue(report, "missing_source"), "诊断报告应包含 missing_source。")


# --- 私有/辅助方法 ---

func _make_source(source_key: StringName, target_path: NodePath) -> GFSaveSourceBase:
	var source := GFSaveSourceBase.new()
	source.name = String(source_key)
	source.source_key = source_key
	source.target_node_path = target_path
	source.use_registry_serializers = true
	return source


func _has_issue(report: Dictionary, kind: String) -> bool:
	for issue_variant: Variant in report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null and String(issue.get("kind", "")) == kind:
			return true
	return false
