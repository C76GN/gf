## 验证 GF 核心层级依赖边界。
extends GutTest


# --- 常量 ---

const KERNEL_ROOT: String = "res://addons/gf/kernel"
const KERNEL_EDITOR_ROOT: String = "res://addons/gf/kernel/editor"
const STANDARD_ROOT: String = "res://addons/gf/standard"
const OFFICIAL_PACKAGES_ROOT: String = "res://addons/gf/packages/official"
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
	"gf.official.capability",
	"GFCapability",
	"GFNodeCapability",
	"GFNode2DCapability",
	"GFNode3DCapability",
	"GFControlCapability",
	"GFNodeState",
	"GFNodeStateMachine",
]
const STANDARD_FORBIDDEN_PACKAGE_PATHS: Array[String] = [
	"res://addons/gf/packages/official",
	"addons/gf/packages/official",
]


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


func test_kernel_does_not_reference_standard_or_official_package_classes() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_ROOT, files)
	var forbidden_class_names := _collect_class_names(STANDARD_ROOT)
	forbidden_class_names.append_array(_collect_class_names(OFFICIAL_PACKAGES_ROOT))

	var issues := _collect_forbidden_class_reference_issues(files, forbidden_class_names)

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel` 不能直接引用 standard 或官方包的具体 class_name；需要共享的最小契约必须上移到 kernel。"
	)


func test_kernel_editor_does_not_hardcode_official_package_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_EDITOR_ROOT, files)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		if source.contains("gf.official."):
			issues.append("%s contains gf.official." % path)

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel/editor` 不能硬编码可选官方包 ID；包级编辑器能力应由 manifest 注入。"
	)


func test_kernel_does_not_hardcode_official_package_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(KERNEL_ROOT, files)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		if source.contains("gf.official."):
			issues.append("%s contains gf.official." % path)

	assert_eq(
		issues,
		[],
		"`addons/gf/kernel` 不能硬编码可选官方包 ID；包能力必须由 package 侧通过 manifest 或通用扩展点贡献。"
	)


func test_standard_does_not_hard_depend_on_official_package_paths_or_classes() -> void:
	var files: Array[String] = []
	_collect_gd_files(STANDARD_ROOT, files)
	var package_class_names := _collect_class_names(OFFICIAL_PACKAGES_ROOT)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		for forbidden_path: String in STANDARD_FORBIDDEN_PACKAGE_PATHS:
			if source.contains(forbidden_path):
				issues.append("%s contains %s" % [path, forbidden_path])
		for package_class_name: String in package_class_names:
			if _contains_identifier(source, package_class_name):
				issues.append("%s references official package class %s" % [path, package_class_name])

	assert_eq(
		issues,
		[],
		"`addons/gf/standard` 不能硬 preload、硬路径引用或直接类型引用可选官方包；需要联动时由包侧向 standard 的通用注册入口贡献能力。"
	)


func test_standard_does_not_reference_official_package_ids() -> void:
	var files: Array[String] = []
	_collect_gd_files(STANDARD_ROOT, files)

	var issues: Array[String] = []
	for path: String in files:
		var source := _read_text(path)
		if source.contains("gf.official."):
			issues.append("%s contains gf.official." % path)

	assert_eq(
		issues,
		[],
		"`standard` 不能按包 ID 主动探测官方包；可选包联动必须由 package 侧注册贡献。"
	)


func test_official_packages_only_reference_declared_official_dependencies() -> void:
	var package_names := _collect_immediate_directory_names(OFFICIAL_PACKAGES_ROOT)
	var manifest_by_package_name := _collect_official_manifest_by_package_name(package_names)
	var issues: Array[String] = []
	for package_name: String in package_names:
		var package_root := OFFICIAL_PACKAGES_ROOT.path_join(package_name)
		var allowed_package_names := _get_declared_official_dependency_names(
			package_name,
			manifest_by_package_name
		)
		var files: Array[String] = []
		_collect_gd_files(package_root, files)
		for path: String in files:
			var source := _read_text(path)
			for other_package_name: String in package_names:
				if other_package_name == package_name:
					continue
				var other_package_path := "addons/gf/packages/official/%s" % other_package_name
				var other_package_id := "gf.official.%s" % other_package_name
				if source.contains(other_package_path) and not allowed_package_names.has(other_package_name):
					issues.append("%s references %s" % [path, other_package_path])
				if source.contains(other_package_id) and not allowed_package_names.has(other_package_name):
					issues.append("%s references %s" % [path, other_package_id])

	assert_eq(
		issues,
		[],
		"官方包之间只能硬引用 manifest.dependencies 中声明的官方依赖；可选协作应使用协议、显式注册或 bridge 包。"
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


func _collect_official_manifest_by_package_name(package_names: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for package_name: String in package_names:
		var manifest_path := OFFICIAL_PACKAGES_ROOT.path_join(package_name).path_join("gf_package.json")
		var manifest_data := _read_json_dictionary(manifest_path)
		if manifest_data.is_empty():
			continue
		result[package_name] = manifest_data
	return result


func _get_declared_official_dependency_names(
	package_name: String,
	manifest_by_package_name: Dictionary
) -> Array[String]:
	var result: Array[String] = []
	var manifest_data := manifest_by_package_name.get(package_name, {}) as Dictionary
	if manifest_data == null:
		return result

	var dependencies := manifest_data.get("dependencies", []) as Array
	if dependencies == null:
		return result

	for dependency_variant: Variant in dependencies:
		var dependency_id := String(dependency_variant)
		for other_package_name: String in manifest_by_package_name.keys():
			var other_data := manifest_by_package_name[other_package_name] as Dictionary
			if other_data == null:
				continue
			if String(other_data.get("id", "")) == dependency_id:
				result.append(other_package_name)
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
