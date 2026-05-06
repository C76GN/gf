## 测试 GFSaveGraphUtility 的通用 Scope/Source 编排。
extends GutTest


# --- 常量 ---

const GFSaveGraphUtilityBase = preload("res://addons/gf/extensions/save/gf_save_graph_utility.gd")
const GFSavePipelineContextBase = preload("res://addons/gf/extensions/save/gf_save_pipeline_context.gd")
const GFSavePipelineStepBase = preload("res://addons/gf/extensions/save/gf_save_pipeline_step.gd")
const GFSaveScopeBase = preload("res://addons/gf/extensions/save/gf_save_scope.gd")
const GFSaveSourceBase = preload("res://addons/gf/extensions/save/gf_save_source.gd")
const GFSaveSlotWorkflowBase = preload("res://addons/gf/extensions/save/gf_save_slot_workflow.gd")


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


## 验证存档流程可按需输出通用 trace。
func test_gather_scope_can_include_pipeline_trace() -> void:
	var payload := _utility.gather_scope(_scope, { "include_pipeline_trace": true })
	var trace := payload.get("pipeline_trace", {}) as Dictionary

	assert_false(trace.is_empty(), "启用 include_pipeline_trace 时应写入流程 trace。")
	assert_eq(trace.get("operation"), &"gather", "trace 应记录 gather 操作。")
	assert_gt(int(trace.get("event_count", 0)), 0, "trace 应包含流程事件。")
	assert_true(_has_trace_stage(trace, &"gather_scope_finished"), "trace 应记录 Scope 完成阶段。")


## 验证调用方也可以显式传入流程上下文并在外部读取。
func test_pipeline_context_can_be_shared_by_caller() -> void:
	var pipeline_context := _utility.create_pipeline_context(&"gather", _scope, { "source": "test" })

	_utility.gather_scope(_scope, { "pipeline_context": pipeline_context })

	assert_eq(pipeline_context.operation, &"gather", "外部上下文应保留操作类型。")
	assert_eq(pipeline_context.shared.get("source", ""), "test", "外部上下文应保留共享数据。")
	assert_gt(pipeline_context.events.size(), 0, "外部上下文应收集流程事件。")


## 验证通用槽位工作流能构建元数据和卡片。
func test_save_slot_workflow_builds_metadata_and_card() -> void:
	var workflow := GFSaveSlotWorkflowBase.new()
	workflow.active_slot_index = 2
	workflow.slot_role = &"manual"

	var metadata := workflow.build_active_metadata("", { "score": 10 })
	var summary := {
		"slot_id": 2,
		"metadata": metadata.to_dict(true),
		"modified_time": 123,
	}
	var card := workflow.build_card_for_index(2, summary)

	assert_eq(metadata.slot_id, &"slot_2", "槽位元数据应按模板生成逻辑标识。")
	assert_eq(metadata.display_name, "Slot 2", "槽位元数据应有通用兜底展示名。")
	assert_eq(metadata.custom_metadata.get("score"), 10, "槽位元数据应保留项目自定义字段。")
	assert_eq(metadata.custom_metadata.get("slot_role"), &"manual", "槽位角色应写入自定义元数据。")
	assert_false(card.is_empty, "已有摘要应生成非空卡片。")
	assert_true(card.is_active, "当前槽位卡片应标记为 active。")


## 验证槽位工作流可从逻辑 slot_id 反推索引。
func test_save_slot_workflow_indexes_string_slot_ids() -> void:
	var workflow := GFSaveSlotWorkflowBase.new()
	var metadata := workflow.build_slot_metadata(3, "Slot 3")
	var summaries := [{
		"slot_id": metadata.slot_id,
		"metadata": metadata.to_dict(true),
		"modified_time": 123,
	}]

	var cards := workflow.build_cards_for_indices([3], summaries)
	var auto_cards := workflow.build_cards_for_indices([], summaries)

	assert_eq(cards.size(), 1, "显式索引应能命中字符串 slot_id 摘要。")
	assert_false(cards[0].is_empty, "字符串 slot_id 摘要不应被误判为空槽。")
	assert_eq(auto_cards.size(), 0, "空索引入口应由 build_cards_from_storage 负责从 storage 推导。")


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


## 验证采集重复 Source key 会失败，避免产生无法回放的 key#2 载荷。
func test_gather_scope_rejects_duplicate_source_keys() -> void:
	var target_a := Node2D.new()
	target_a.name = "TargetA"
	_scope.add_child(target_a)
	var target_b := Node2D.new()
	target_b.name = "TargetB"
	_scope.add_child(target_b)
	_scope.add_child(_make_source(&"state", NodePath("../TargetA")))
	_scope.add_child(_make_source(&"state", NodePath("../TargetB")))

	var payload := _utility.gather_scope(_scope)

	assert_true(payload.is_empty(), "重复 Source key 不应生成存档载荷。")
	assert_push_error("[GFSaveGraphUtility] gather_scope 失败：同一 Scope 内存在重复 Source key：state")


## 验证空载荷应用会显式失败。
func test_apply_scope_rejects_empty_payload() -> void:
	var result := _utility.apply_scope(_scope, {})

	assert_false(bool(result["ok"]), "空载荷不应被视为成功应用。")
	assert_true((result["errors"] as Array).has("Save payload is empty."), "空载荷应返回明确错误。")


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


func _has_trace_stage(trace: Dictionary, stage: StringName) -> bool:
	for event_variant: Variant in trace.get("events", []):
		var event := event_variant as Dictionary
		if event != null and StringName(event.get("stage", &"")) == stage:
			return true
	return false
