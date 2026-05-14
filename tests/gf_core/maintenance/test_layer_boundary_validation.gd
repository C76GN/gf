## 验证 GF 核心层级依赖边界。
extends GutTest


# --- 常量 ---

const KERNEL_ROOT: String = "res://addons/gf/kernel"
const KERNEL_EDITOR_ROOT: String = "res://addons/gf/kernel/editor"
const STANDARD_ROOT: String = "res://addons/gf/standard"
const EXTENSIONS_ROOT: String = "res://addons/gf/extensions"
const KERNEL_FORBIDDEN_TEXTS: Array[String] = [
	"res://addons/gf/standard",
	"addons/gf/standard",
	"GFTimeUtility",
	"GFCommandHistoryUtility",
	"GFStandardEditorExtensionsBase",
	"GFValidationIssue",
	"GFValidationReport",
	"GFValidationReportDictionary",
	"GFResultDictionary",
	"GFCapability",
	"GFNodeCapability",
	"GFNode2DCapability",
	"GFNode3DCapability",
	"GFControlCapability",
	"GFNodeState",
	"GFNodeStateMachine",
]
const STANDARD_FORBIDDEN_EXTENSION_PATHS: Array[String] = [
	"res://addons/gf/extensions/",
	"addons/gf/extensions/",
]
const EXTENSION_ALLOWED_DEPENDENCIES: Array[String] = [
	"gf.kernel",
	"gf.standard",
]
const EXTENSION_FORBIDDEN_MANIFEST_FIELDS: Array[String] = [
	"optional_dependencies",
]
const EXTENSION_FORBIDDEN_SOFT_REFERENCES: Dictionary = {
	"interaction": [
		"capability_provider",
		"with_capability_provider",
		"get_capability(",
		"get_receivers_in_group",
		"sender_as",
		"target_as",
		"GFCapability",
	],
	"feedback": [
		"GFShakeAction",
		"GFActionQueueSystem",
		"GFVisualAction",
		"ActionQueue",
		"action_queue",
		"should_wait_for_result",
	],
}


# --- 测试用例 ---

func test_kernel_does_not_depend_on_standard_layer() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_ROOT, files)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for forbidden_text: String in KERNEL_FORBIDDEN_TEXTS:
			if source.contains(forbidden_text):
				issues.append("%s contains %s" % [path, forbidden_text])

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel` 不能直接依赖 `addons/gf/standard`；需要内核识别的契约必须放在 kernel。"
	)


func test_kernel_does_not_reference_standard_or_extension_classes() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_ROOT, files)
	var forbidden_class_names := _collect_class_names(STANDARD_ROOT)
	forbidden_class_names.append_array(_collect_class_names(EXTENSIONS_ROOT))

	var issues := _collect_forbidden_class_reference_issues(files, forbidden_class_names)

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel` 不能直接引用 standard 或可选扩展的具体 class_name；需要共享的最小契约必须上移到 kernel。"
	)


func test_kernel_editor_does_not_hardcode_extension_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_EDITOR_ROOT, files)
	var extension_ids := _collect_extension_ids()

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for extension_id: String in extension_ids:
			if source.contains(extension_id):
				issues.append("%s contains %s" % [path, extension_id])

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel/editor` 不能硬编码可选扩展 ID；扩展级编辑器能力应由 manifest 注入。"
	)


func test_kernel_does_not_hardcode_extension_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_ROOT, files)
	var extension_ids := _collect_extension_ids()

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for extension_id: String in extension_ids:
			if source.contains(extension_id):
				issues.append("%s contains %s" % [path, extension_id])

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel` 不能硬编码可选扩展 ID；扩展能力必须由扩展侧通过 manifest 或通用扩展点贡献。"
	)


func test_standard_does_not_hard_depend_on_extension_paths_or_classes() -> void:
	var files: Array[String] = []
	_collect_gd_files(STANDARD_ROOT, files)
	var extension_class_names := _collect_class_names(EXTENSIONS_ROOT)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for forbidden_path: String in STANDARD_FORBIDDEN_EXTENSION_PATHS:
			if source.contains(forbidden_path):
				issues.append("%s contains %s" % [path, forbidden_path])
		for extension_class_name: String in extension_class_names:
			if _contains_identifier(source, extension_class_name):
				issues.append("%s references extension class %s" % [path, extension_class_name])

	assert_eq(
		issues,
		[],
		"`addons/gf/standard` 不能硬 preload、硬路径引用或直接类型引用可选扩展；需要联动时由扩展侧向 standard 的通用注册入口贡献能力。"
	)


func test_standard_does_not_reference_extension_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(STANDARD_ROOT, files)
	var extension_ids := _collect_extension_ids()

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for extension_id: String in extension_ids:
			if source.contains(extension_id):
				issues.append("%s contains %s" % [path, extension_id])

	assert_eq(
		issues,
		[],
		"`standard` 不能按扩展 ID 主动探测可选扩展；可选扩展联动必须由扩展侧注册贡献。"
	)


func test_bundled_extension_manifests_are_atomic() -> void:
	var extension_names := _collect_immediate_directory_names(EXTENSIONS_ROOT)
	var manifest_by_extension_name := _collect_manifest_by_extension_name(extension_names)
	var issues: Array[String] = []
	for extension_name: String in extension_names:
		var manifest_data := manifest_by_extension_name.get(extension_name, {}) as Dictionary
		if manifest_data == null:
			issues.append("%s missing manifest" % extension_name)
			continue

		if not manifest_data.has("extension_version"):
			issues.append("%s missing extension_version" % extension_name)

		var dependencies := manifest_data.get("dependencies", []) as Array
		if dependencies == null:
			dependencies = []
		for dependency_variant: Variant in dependencies:
			var dependency_id := String(dependency_variant)
			if not EXTENSION_ALLOWED_DEPENDENCIES.has(dependency_id):
				issues.append("%s declares dependency %s" % [extension_name, dependency_id])

		for field_name: String in EXTENSION_FORBIDDEN_MANIFEST_FIELDS:
			if manifest_data.has(field_name):
				issues.append("%s declares unsupported manifest field %s" % [extension_name, field_name])

	assert_eq(
		issues,
		[],
		"GF 内置扩展必须保持原子化：只能依赖 gf.kernel 与 gf.standard，不能声明其他内置扩展硬依赖或软协作字段；组合属于项目或外部插件。"
	)


func test_bundled_extensions_do_not_reference_other_bundled_extensions() -> void:
	var extension_names := _collect_immediate_directory_names(EXTENSIONS_ROOT)
	var class_root_by_name := _collect_extension_class_root_by_name()
	var issues: Array[String] = []
	for extension_name: String in extension_names:
		var extension_root := EXTENSIONS_ROOT.path_join(extension_name)
		var files: Array[String] = []
		_collect_gd_files(extension_root, files)
		for path: String in files:
			var source := _read_text(path)
			for other_extension_name: String in extension_names:
				if other_extension_name == extension_name:
					continue
				var other_extension_path := "addons/gf/extensions/%s" % other_extension_name
				var other_extension_id := "gf.%s" % other_extension_name
				if source.contains(other_extension_path):
					issues.append("%s references %s" % [path, other_extension_path])
				if source.contains(other_extension_id):
					issues.append("%s references %s" % [path, other_extension_id])
			for class_name_variant: Variant in class_root_by_name.keys():
				var class_name_text := String(class_name_variant)
				var class_root := String(class_root_by_name[class_name_text])
				if class_root != extension_root and _contains_identifier(source, class_name_text):
					issues.append("%s references extension class %s" % [path, class_name_text])

	assert_eq(
		issues,
		[],
		"GF 内置扩展之间不能通过路径或扩展 ID 互相引用；跨扩展组合应留给项目或外部插件。"
	)


func test_known_extension_soft_collaboration_protocols_do_not_return() -> void:
	var issues: Array[String] = []
	for extension_name_variant: Variant in EXTENSION_FORBIDDEN_SOFT_REFERENCES.keys():
		var extension_name := String(extension_name_variant)
		var extension_root := EXTENSIONS_ROOT.path_join(extension_name)
		var files: Array[String] = []
		_collect_gd_files(extension_root, files)
		var forbidden_texts := EXTENSION_FORBIDDEN_SOFT_REFERENCES[extension_name] as Array
		for path: String in files:
			var source := _read_text(path)
			for forbidden_text_variant: Variant in forbidden_texts:
				var forbidden_text := String(forbidden_text_variant)
				if source.contains(forbidden_text):
					issues.append("%s contains soft collaboration marker %s" % [path, forbidden_text])

	assert_eq(
		issues,
		[],
		"已移除的内置扩展软协作协议不能回到 GF 扩展层；组合应放在项目或外部插件。"
	)


# --- 私有/辅助方法 ---

func _collect_gd_files(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_gd_files(path, result)
		elif entry.ends_with(".gd"):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


func _collect_immediate_directory_names(root_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(root_path)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if dir.current_is_dir() and not entry.begins_with("."):
			result.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	result.sort()
	return result


func _collect_extension_ids() -> Array[String]:
	var result: Array[String] = []
	for extension_name: String in _collect_immediate_directory_names(EXTENSIONS_ROOT):
		result.append("gf.%s" % extension_name)
	return result


func _collect_manifest_by_extension_name(extension_names: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for extension_name: String in extension_names:
		var manifest_path := EXTENSIONS_ROOT.path_join(extension_name).path_join("gf_extension.json")
		var manifest_data := _read_json_dictionary(manifest_path)
		if manifest_data.is_empty():
			continue
		result[extension_name] = manifest_data
	return result


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _read_json_dictionary(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		return parsed
	return {}


func _collect_class_names(root_path: String) -> Array[String]:
	var files: Array[String] = []
	_collect_gd_files(root_path, files)

	var result: Array[String] = []
	var regex := RegEx.new()
	regex.compile("(?m)^\\s*class_name\\s+([A-Za-z_]\\w*)")
	for path: String in files:
		var source := _read_text(path)
		for match_result: RegExMatch in regex.search_all(source):
			var discovered_class_name := match_result.get_string(1)
			if not result.has(discovered_class_name):
				result.append(discovered_class_name)
	result.sort()
	return result


func _collect_extension_class_root_by_name() -> Dictionary:
	var files: Array[String] = []
	_collect_gd_files(EXTENSIONS_ROOT, files)

	var result: Dictionary = {}
	var regex := RegEx.new()
	regex.compile("(?m)^\\s*class_name\\s+([A-Za-z_]\\w*)")
	for path: String in files:
		var extension_root := _get_extension_root(path)
		var source := _read_text(path)
		for match_result: RegExMatch in regex.search_all(source):
			result[match_result.get_string(1)] = extension_root
	return result


func _get_extension_root(path: String) -> String:
	var marker := EXTENSIONS_ROOT + "/"
	if not path.begins_with(marker):
		return ""

	var slash_index := path.find("/", marker.length())
	if slash_index == -1:
		return ""
	return path.substr(0, slash_index)


func _collect_forbidden_class_reference_issues(
	files: Array[String],
	forbidden_class_names: Array[String]
) -> Array[String]:
	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for forbidden_class_name: String in forbidden_class_names:
			if _contains_identifier(source, forbidden_class_name):
				issues.append("%s references %s" % [path, forbidden_class_name])
	return issues


func _contains_identifier(source: String, identifier: String) -> bool:
	var regex := RegEx.new()
	regex.compile("(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % identifier)
	return regex.search(source) != null
