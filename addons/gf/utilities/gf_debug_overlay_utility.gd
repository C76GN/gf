# addons/gf/utilities/gf_debug_overlay_utility.gd
class_name GFDebugOverlayUtility
extends GFUtility


## GFDebugOverlayUtility: 框架内部 Debugger 控制台。
##
## 纯代码驱动的悬浮监控面板，可以通过快捷键（默认 `~`）呼出。
## 实时利用反射遍历架构中所有注册的 GFModel，在屏幕角落打印其数据变量。


# --- 公共变量 ---

## 呼出/隐藏面板的快捷键。默认为 KEY_QUOTELEFT (`~` 键)。
var toggle_key: Key = KEY_QUOTELEFT


# --- 私有变量 ---

var _overlay_gui: _GFDebugGUI


# --- Godot 生命周期方法 ---

func init() -> void:
	_overlay_gui = _GFDebugGUI.new()
	_overlay_gui.name = "GFDebugOverlay"
	_overlay_gui.toggle_key = toggle_key
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.call_deferred("add_child", _overlay_gui)


func dispose() -> void:
	if is_instance_valid(_overlay_gui):
		_overlay_gui.queue_free()


# --- 公共方法 ---

## 更新快捷键绑定
## @param key: 新的触发按键
func set_toggle_key(key: Key) -> void:
	toggle_key = key
	if is_instance_valid(_overlay_gui):
		_overlay_gui.toggle_key = key


# --- 内部 GUI 类 ---

class _GFDebugGUI extends CanvasLayer:
	var _container: VBoxContainer
	var _label: RichTextLabel
	var toggle_key: Key
	
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
				get_viewport().set_input_as_handled()


	func _process(_delta: float) -> void:
		if not visible:
			return
			
		var text := ""
		if not Gf.has_method("get_architecture"):
			_label.text = "Error: Gf does not have architecture."
			return
			
		var arch: Object = Gf.get_architecture()
		if arch == null:
			_label.text = "Wait: Architecture is null."
			return
			
		var models := arch.get("_models") as Dictionary
		if models == null or models.is_empty():
			_label.text = "No GFModels registered."
			return
			
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
				
			text += "[color=yellow]=== %s ===[/color]\n" % class_title
			
			var prop_list := model.get_property_list()
			for prop: Dictionary in prop_list:
				var usage: int = prop.usage
				# 过滤 Godot 内置变量，只显示脚本中声明的用户变量
				if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
					var var_name: String = prop.name
					var var_val: Variant = model.get(var_name)
					text += "  [color=lightblue]%s[/color]: %s\n" % [var_name, str(var_val)]
			
			text += "\n"
			
		if _label.text != text:
			_label.text = text
