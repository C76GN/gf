## GFDebugOverlayUtility: 框架内部 Debugger 控制台。
##
## 纯代码驱动的悬浮监控面板，可以通过快捷键（默认 `~`）呼出。
## 实时利用反射遍历架构中所有注册的 GFModel，也可显示项目主动注册的轻量运行时观察值。
class_name GFDebugOverlayUtility
extends GFUtility


# --- 公共变量 ---

## 呼出/隐藏面板的快捷键。默认为 KEY_QUOTELEFT (`~` 键)。
var toggle_key: Key = KEY_QUOTELEFT

## 可见时刷新模型反射数据的间隔（秒）。设为 0 时每帧刷新。
var refresh_interval_seconds: float = 0.25

## 是否把 GFDiagnosticsUtility 的监控预设合并显示到 Watch 区。
var include_diagnostics_monitors: bool = true

## Overlay 默认读取的诊断监控预设。
var diagnostics_monitor_preset: StringName = &"overlay"


# --- 私有变量 ---

var _overlay_gui: _GFDebugGUI
var _watches: Dictionary = {}
var _watch_order_counter: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	_overlay_gui = _GFDebugGUI.new()
	_overlay_gui.name = "GFDebugOverlay"
	_overlay_gui.toggle_key = toggle_key
	_overlay_gui.refresh_interval_seconds = refresh_interval_seconds
	_overlay_gui.architecture_provider = Callable(self, "_get_architecture_or_null")
	_overlay_gui.watch_snapshot_provider = Callable(self, "get_watch_snapshot")
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.call_deferred("add_child", _overlay_gui)


func dispose() -> void:
	if is_instance_valid(_overlay_gui):
		_overlay_gui.visible = false
		_overlay_gui.set_process(false)
		_overlay_gui.set_process_input(false)
		_overlay_gui.architecture_provider = Callable()
		_overlay_gui.watch_snapshot_provider = Callable()
		_overlay_gui.queue_free()
	_overlay_gui = null
	clear_watches()


# --- 公共方法 ---

## 更新快捷键绑定
## @param key: 新的触发按键
func set_toggle_key(key: Key) -> void:
	toggle_key = key
	if is_instance_valid(_overlay_gui):
		_overlay_gui.toggle_key = key


## 设置可见时的刷新间隔。
## @param seconds: 刷新间隔；小于等于 0 时每帧刷新。
func set_refresh_interval(seconds: float) -> void:
	refresh_interval_seconds = maxf(seconds, 0.0)
	if is_instance_valid(_overlay_gui):
		_overlay_gui.refresh_interval_seconds = refresh_interval_seconds


## 设置 Overlay 使用的诊断监控预设。
## @param preset_id: 诊断监控预设标识；为空时采集全部可见监控项。
func set_diagnostics_monitor_preset(preset_id: StringName) -> void:
	diagnostics_monitor_preset = preset_id


## 注册一个由回调即时读取的运行时观察值。
## @param id: 观察值唯一标识。
## @param provider: 无参数回调；Overlay 刷新时调用并显示返回值。
## @param options: 可选显示参数，支持 label、group、visible。
## @return 注册成功返回 true；id 为空或 provider 无效时返回 false。
func watch_value(id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
	if id == &"" or not provider.is_valid():
		return false

	_upsert_watch_entry(id, &"provider", provider, options)
	return true


## 推送一个由调用方主动更新的运行时观察值。
## @param id: 观察值唯一标识。
## @param value: 要显示的当前值。
## @param options: 可选显示参数，支持 label、group、visible。
## @return 注册成功返回 true；id 为空时返回 false。
func push_watch_value(id: StringName, value: Variant, options: Dictionary = {}) -> bool:
	if id == &"":
		return false

	_upsert_watch_entry(id, &"value", value, options)
	return true


## 移除一个运行时观察值。
## @param id: 要移除的观察值标识。
func remove_watch(id: StringName) -> void:
	_watches.erase(id)


## 清空所有运行时观察值。
func clear_watches() -> void:
	_watches.clear()
	_watch_order_counter = 0


## 检查运行时观察值是否已注册。
## @param id: 要检查的观察值标识。
## @return 已注册时返回 true。
func has_watch(id: StringName) -> bool:
	return _watches.has(id)


## 读取当前运行时观察值快照。
## @param include_hidden: 为 true 时同时返回 visible=false 的观察值。
## @return 按注册顺序排列的观察值字典数组。
func get_watch_snapshot(include_hidden: bool = false) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for id: StringName in _watches:
		var source_entry: Dictionary = _watches[id]
		var is_visible: bool = source_entry.get("visible", true)
		if not include_hidden and not is_visible:
			continue

		var entry := source_entry.duplicate()
		entry["id"] = id
		entries.append(entry)

	entries.sort_custom(_sort_watch_entries)

	var snapshot: Array[Dictionary] = []
	for entry: Dictionary in entries:
		var evaluated := _evaluate_watch_entry(entry)
		snapshot.append({
			"id": entry.get("id", &""),
			"label": String(entry.get("label", String(entry.get("id", &"")))),
			"group": String(entry.get("group", "Runtime")),
			"value": evaluated.get("value", null),
			"valid": evaluated.get("valid", true),
		})

	if include_diagnostics_monitors:
		_append_diagnostics_watch_snapshot(snapshot, include_hidden)
	return snapshot


# --- 私有/辅助方法 ---

func _upsert_watch_entry(id: StringName, mode: StringName, payload: Variant, options: Dictionary) -> void:
	var entry: Dictionary = {}
	if _watches.has(id):
		entry = (_watches[id] as Dictionary).duplicate()
	else:
		entry = {
			"label": String(id),
			"group": "Runtime",
			"visible": true,
			"order": _watch_order_counter,
		}
		_watch_order_counter += 1

	entry["mode"] = mode
	if mode == &"provider":
		entry["provider"] = payload
		entry.erase("value")
	else:
		entry["value"] = payload
		entry.erase("provider")

	_apply_watch_options(entry, id, options)
	_watches[id] = entry


func _apply_watch_options(entry: Dictionary, id: StringName, options: Dictionary) -> void:
	if not entry.has("label") or String(entry["label"]).is_empty():
		entry["label"] = String(id)
	if not entry.has("group") or String(entry["group"]).is_empty():
		entry["group"] = "Runtime"
	if not entry.has("visible"):
		entry["visible"] = true

	if options.has("label"):
		var label := str(options["label"])
		if not label.is_empty():
			entry["label"] = label
	if options.has("group"):
		var group := str(options["group"])
		if not group.is_empty():
			entry["group"] = group
	if options.has("visible") and options["visible"] is bool:
		entry["visible"] = options["visible"]


func _evaluate_watch_entry(entry: Dictionary) -> Dictionary:
	var mode: StringName = entry.get("mode", &"value")
	if mode == &"provider":
		var provider: Callable = entry.get("provider", Callable())
		if not provider.is_valid():
			return {
				"value": "<invalid watch provider>",
				"valid": false,
			}
		return {
			"value": provider.call(),
			"valid": true,
		}

	return {
		"value": entry.get("value", null),
		"valid": true,
	}


func _sort_watch_entries(left: Dictionary, right: Dictionary) -> bool:
	var left_order: int = left.get("order", 0)
	var right_order: int = right.get("order", 0)
	if left_order != right_order:
		return left_order < right_order
	return String(left.get("id", &"")) < String(right.get("id", &""))


func _append_diagnostics_watch_snapshot(snapshot: Array[Dictionary], include_hidden: bool) -> void:
	var diagnostics := get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
	if diagnostics == null:
		return

	var monitor_snapshot: Dictionary = {}
	if diagnostics_monitor_preset != &"":
		monitor_snapshot = diagnostics.collect_monitor_preset(diagnostics_monitor_preset, include_hidden)
	else:
		monitor_snapshot = diagnostics.collect_monitor_snapshot(PackedStringArray(), include_hidden)
	var monitors := monitor_snapshot.get("monitors", {}) as Dictionary
	if monitors == null or monitors.is_empty():
		return

	var ids := PackedStringArray()
	for monitor_id: Variant in monitors.keys():
		ids.append(String(monitor_id))
	ids.sort()
	for id_text: String in ids:
		var monitor := monitors[StringName(id_text)] as Dictionary
		if monitor == null:
			continue
		snapshot.append({
			"id": StringName(id_text),
			"label": String(monitor.get("label", id_text)),
			"group": String(monitor.get("group", "Diagnostics")),
			"value": monitor.get("value", null),
			"valid": bool(monitor.get("valid", false)),
		})


# --- 内部 GUI 类 ---

class _GFDebugGUI extends CanvasLayer:
	var _container: VBoxContainer
	var _label: RichTextLabel
	var toggle_key: Key
	var refresh_interval_seconds: float = 0.25
	var architecture_provider: Callable
	var watch_snapshot_provider: Callable
	var _refresh_elapsed: float = 0.25
	
	func _init() -> void:
		layer = 120 # 确保在所有 UI 之上
		visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS # 即使主游戏暂停也能工作
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(margin)
		
		var panel := PanelContainer.new()
		panel.self_modulate = Color(0, 0, 0, 0.6)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_child(panel)
		
		_container = VBoxContainer.new()
		panel.add_child(_container)
		
		var header := Label.new()
		header.text = "[ GF Debug Overlay ]"
		header.modulate = Color(0.4, 0.8, 1.0)
		_container.add_child(header)
		
		_label = RichTextLabel.new()
		_label.fit_content = true
		_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.custom_minimum_size = Vector2(300, 0)
		_label.bbcode_enabled = true
		_container.add_child(_label)


	func _input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == toggle_key:
				visible = not visible
				if visible:
					_refresh_elapsed = refresh_interval_seconds
				get_viewport().set_input_as_handled()


	func _process(delta: float) -> void:
		if not visible:
			_refresh_elapsed = refresh_interval_seconds
			return

		if refresh_interval_seconds > 0.0:
			_refresh_elapsed += delta
			if _refresh_elapsed < refresh_interval_seconds:
				return
			_refresh_elapsed = 0.0

		var text := _build_debug_text()
		if _label.text != text:
			_label.text = text


	func _build_debug_text() -> String:
		var watch_text := _build_watch_text()
		var arch: Object = null
		if architecture_provider.is_valid():
			arch = architecture_provider.call()
		if arch == null:
			if watch_text.is_empty():
				return "Wait: Architecture is null."
			return watch_text

		var model_text := _build_model_text(arch)
		if watch_text.is_empty() and model_text.is_empty():
			return "No GFModels registered."
		if watch_text.is_empty():
			return model_text
		if model_text.is_empty():
			return watch_text
		return "%s\n%s" % [watch_text, model_text]


	func _build_watch_text() -> String:
		if not watch_snapshot_provider.is_valid():
			return ""

		var snapshot_result: Variant = watch_snapshot_provider.call()
		if not (snapshot_result is Array):
			return ""

		var snapshot: Array = snapshot_result
		if snapshot.is_empty():
			return ""

		var group_order: PackedStringArray = []
		var groups: Dictionary = {}
		for watch_variant: Variant in snapshot:
			var watch := watch_variant as Dictionary
			if watch == null:
				continue

			var group := String(watch.get("group", "Runtime"))
			if group.is_empty():
				group = "Runtime"
			if not groups.has(group):
				groups[group] = []
				group_order.append(group)
			groups[group].append(watch)

		var text := ""
		for group: String in group_order:
			if not text.is_empty():
				text += "\n"
			text += "[color=yellow]=== Watches: %s ===[/color]\n" % _escape_bbcode(group)

			var watches: Array = groups[group]
			for watch_variant: Variant in watches:
				var watch := watch_variant as Dictionary
				var label := String(watch.get("label", String(watch.get("id", "watch"))))
				if label.is_empty():
					label = String(watch.get("id", "watch"))
				var is_valid: bool = watch.get("valid", true)
				var value: Variant = watch.get("value", null)
				var value_text := str(value)
				if not is_valid:
					value_text = "<invalid>"
				text += "  [color=lightblue]%s[/color]: %s\n" % [
					_escape_bbcode(label),
					_escape_bbcode(value_text),
				]

		return text


	func _build_model_text(arch: Object) -> String:
		var models := arch.get("_models") as Dictionary
		if models == null or models.is_empty():
			return ""
			
		var text := ""
		for script_cls: Script in models:
			var model: Object = models[script_cls]
			var class_title := ""
			
			var global_name := script_cls.get_global_name()
			if global_name != &"":
				class_title = String(global_name)
			else:
				class_title = script_cls.resource_path.get_file().get_basename()
				if class_title.is_empty():
					class_title = "AnonymousModel"
				else:
					class_title = class_title.capitalize().replace(" ", "")
				
			text += "[color=yellow]=== %s ===[/color]\n" % _escape_bbcode(class_title)
			
			var prop_list := model.get_property_list()
			for prop: Dictionary in prop_list:
				var usage: int = prop.usage
				# 过滤 Godot 内置变量，只显示脚本中声明的用户变量
				if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
					var var_name: String = prop.name
					var var_val: Variant = model.get(var_name)
					text += "  [color=lightblue]%s[/color]: %s\n" % [
						_escape_bbcode(var_name),
						_escape_bbcode(str(var_val)),
					]
			
			text += "\n"

		return text


	func _escape_bbcode(text: String) -> String:
		var escaped := PackedStringArray()
		for index: int in range(text.length()):
			var character := text.substr(index, 1)
			if character == "[":
				escaped.append("[lb]")
			elif character == "]":
				escaped.append("[rb]")
			else:
				escaped.append(character)
		return "".join(escaped)
