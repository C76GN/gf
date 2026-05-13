@tool

## GF Audio Bank Inspector: 在 Inspector 中辅助检查音频集合。
extends EditorInspectorPlugin


# --- 常量 ---

const GF_AUDIO_BANK_BASE := preload("res://addons/gf/standard/utilities/audio/gf_audio_bank.gd")
const GF_AUDIO_BANK_TOOLS := preload("res://addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd")


# --- Godot 回调方法 ---

func _can_handle(object: Object) -> bool:
	return object is GF_AUDIO_BANK_BASE


func _parse_begin(object: Object) -> void:
	var bank := object as GFAudioBank
	if bank == null:
		return

	var root := VBoxContainer.new()
	root.name = "GFAudioBankInspector"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(root)

	var header := Label.new()
	header.text = "GF Audio Bank"
	header.modulate = Color(0.4, 0.8, 1.0)
	root.add_child(header)

	var validate_button := Button.new()
	validate_button.text = "验证播放配置"
	validate_button.tooltip_text = "检查音频片段、资源路径和音频总线。"
	root.add_child(validate_button)

	var report_label := Label.new()
	report_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	report_label.modulate = Color(0.8, 0.8, 0.8)
	root.add_child(report_label)
	validate_button.pressed.connect(_on_validate_pressed.bind(report_label, bank), CONNECT_DEFERRED)


# --- 私有/辅助方法 ---

func _update_validation_report(label: Label, bank: GFAudioBank) -> void:
	if label == null or bank == null:
		return

	var report := GF_AUDIO_BANK_TOOLS.validate_bank_playback(bank, {
		"check_resource_exists": true,
		"check_bus_exists": true,
	})
	label.text = report.make_summary("GFAudioBank")
	label.tooltip_text = _format_report_tooltip(report)
	if report.get_error_count() > 0:
		label.modulate = Color(1.0, 0.45, 0.35)
	elif report.get_warning_count() > 0:
		label.modulate = Color(1.0, 0.78, 0.35)
	else:
		label.modulate = Color(0.45, 0.9, 0.55)


func _format_report_tooltip(report: RefCounted) -> String:
	var lines := PackedStringArray()
	var issues := report.get("issues") as Array
	for issue: RefCounted in issues:
		if issue == null:
			continue
		var issue_dict := issue.call("to_dict") as Dictionary
		var kind := String(issue_dict.get("kind", "unknown"))
		var message := String(issue_dict.get("message", ""))
		lines.append("%s: %s" % [kind, message])
		if lines.size() >= 8:
			lines.append("...")
			break
	return "\n".join(lines)


# --- 信号处理函数 ---

func _on_validate_pressed(label: Label, bank: GFAudioBank) -> void:
	_update_validation_report(label, bank)
