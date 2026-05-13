## 验证 Read the Docs / MkDocs 文档结构保持稳定。
extends GutTest


# --- 常量 ---

const DOCS_ROOT: String = "res://docs/zh"
const WIKI_ROOT: String = "res://docs/wiki"
const MKDOCS_CONFIG_PATH: String = "res://mkdocs.yml"
const README_EN_PATH: String = "res://README.md"
const README_ZH_PATH: String = "res://README.zh.md"
const ADDON_README_PATH: String = "res://addons/gf/README.md"
const READTHEDOCS_URL: String = "https://gf-framework.readthedocs.io/"
const WIKI_ENTRY_FILES := ["Home.md", "_Sidebar.md", "_Footer.md"]
const DOCS_TOP_LEVEL_FILES := ["index.md", "faq.md", "changelog.md"]
const DOCS_TOP_LEVEL_DIRECTORIES := [
	"overview",
	"kernel",
	"standard",
	"extensions",
	"editor",
	"maintenance",
]


# --- 测试用例 ---

func test_mkdocs_nav_mentions_every_chinese_doc_page() -> void:
	var docs_paths := _collect_markdown_files(DOCS_ROOT)
	var mkdocs_source := _read_text(MKDOCS_CONFIG_PATH)

	var issues: Array[String] = []
	for path: String in docs_paths:
		var relative_path := path.trim_prefix(DOCS_ROOT + "/")
		if not mkdocs_source.contains(relative_path):
			issues.append("%s is not mentioned in mkdocs.yml" % relative_path)

	assert_eq(issues, [], "`docs/zh` 中的正式页面应挂入 mkdocs.yml 导航：\n%s" % _join_lines(issues))


func test_mkdocs_nav_paths_exist() -> void:
	var mkdocs_source := _read_text(MKDOCS_CONFIG_PATH)
	var nav_paths := _collect_markdown_paths_from_text(mkdocs_source)

	var issues: Array[String] = []
	for relative_path: String in nav_paths:
		var docs_path := DOCS_ROOT.path_join(relative_path)
		if not FileAccess.file_exists(docs_path):
			issues.append("%s points to missing file" % relative_path)

	assert_eq(issues, [], "`mkdocs.yml` 导航中引用的页面必须存在：\n%s" % _join_lines(issues))


func test_docs_use_semantic_directories_matching_navigation() -> void:
	var dir := DirAccess.open(DOCS_ROOT)
	assert_not_null(dir, "应能打开 docs/zh。")
	if dir == null:
		return

	var issues: Array[String] = []
	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		if dir.current_is_dir():
			if _is_numbered_slug(entry):
				issues.append("%s should be renamed to semantic layer directory" % entry)
			elif not DOCS_TOP_LEVEL_DIRECTORIES.has(entry):
				issues.append("%s is not an allowed docs/zh top-level directory" % entry)
		elif entry.ends_with(".md") and not DOCS_TOP_LEVEL_FILES.has(entry):
			issues.append("%s should live under a semantic docs directory" % entry)
		entry = dir.get_next()
	dir.list_dir_end()

	assert_eq(issues, [], "docs/zh 顶层必须保持语义目录，并与 Read the Docs 导航分组一致：\n%s" % _join_lines(issues))


func test_doc_directories_have_index_pages() -> void:
	var dirs := _collect_directories(DOCS_ROOT)

	var issues: Array[String] = []
	for dir_path: String in dirs:
		var index_path := dir_path.path_join("index.md")
		if not FileAccess.file_exists(index_path):
			issues.append("%s has no index.md" % dir_path.trim_prefix(DOCS_ROOT + "/"))

	assert_eq(issues, [], "每个文档目录都应提供 index.md 作为该组导读：\n%s" % _join_lines(issues))


func test_legacy_wiki_entry_files_point_to_readthedocs() -> void:
	var issues: Array[String] = []
	for file_name: String in WIKI_ENTRY_FILES:
		var path := WIKI_ROOT.path_join(file_name)
		if not FileAccess.file_exists(path):
			issues.append("%s is missing" % path)
			continue

		var text := _read_text(path)
		if not text.contains(READTHEDOCS_URL):
			issues.append("%s must link to Read the Docs" % path)

	assert_eq(issues, [], "旧 GitHub Wiki 入口文件必须指向 Read the Docs：\n%s" % _join_lines(issues))


func test_legacy_wiki_contains_only_entry_files() -> void:
	var wiki_paths := _collect_markdown_files(WIKI_ROOT)
	var issues: Array[String] = []
	for path: String in wiki_paths:
		if not WIKI_ENTRY_FILES.has(path.get_file()):
			issues.append("%s should be removed; legacy Wiki keeps entry files only" % path)

	assert_eq(issues, [], "旧 GitHub Wiki 只保留 Home、Sidebar 和 Footer，不再保留章节兼容页：\n%s" % _join_lines(issues))


func test_readme_language_switches_and_doc_links_are_present() -> void:
	var english_readme := _read_text(README_EN_PATH)
	var chinese_readme := _read_text(README_ZH_PATH)
	var addon_readme := _read_text(ADDON_README_PATH)

	var issues: Array[String] = []
	if not english_readme.contains("English | [简体中文](README.zh.md)"):
		issues.append("README.md must link to README.zh.md")
	if not chinese_readme.contains("[English](README.md) | 简体中文"):
		issues.append("README.zh.md must link back to README.md")
	if not addon_readme.contains("../../README.md") or not addon_readme.contains("../../README.zh.md"):
		issues.append("addons/gf/README.md must point to both root README languages")

	var required_fragments := [
		READTHEDOCS_URL,
		"addons/gf/kernel",
		"addons/gf/standard",
		"addons/gf/extensions/official",
		"GF Extensions",
		"tests/gf_core/maintenance",
	]
	for fragment: String in required_fragments:
		if not english_readme.contains(fragment):
			issues.append("README.md is missing `%s`" % fragment)
		if not chinese_readme.contains(fragment):
			issues.append("README.zh.md is missing `%s`" % fragment)

	assert_eq(issues, [], "README 中英文入口、分层说明和正式文档链接必须保持同步：\n%s" % _join_lines(issues))


# --- 私有/辅助方法 ---

func _collect_markdown_files(root_path: String) -> Array[String]:
	var result: Array[String] = []
	_collect_markdown_files_recursive(root_path, result)
	result.sort()
	return result


func _collect_directories(root_path: String) -> Array[String]:
	var result: Array[String] = []
	_collect_directories_recursive(root_path, result)
	result.sort()
	return result


func _collect_markdown_files_recursive(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var child_path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_markdown_files_recursive(child_path, result)
		elif entry.ends_with(".md"):
			result.append(child_path)
		entry = dir.get_next()
	dir.list_dir_end()


func _collect_directories_recursive(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if dir.current_is_dir() and not entry.begins_with("."):
			var child_path := root_path.path_join(entry)
			result.append(child_path)
			_collect_directories_recursive(child_path, result)
		entry = dir.get_next()
	dir.list_dir_end()


func _collect_markdown_paths_from_text(text: String) -> Array[String]:
	var result: Array[String] = []
	var regex := RegEx.new()
	regex.compile("([A-Za-z0-9_./-]+\\.md)")
	for match_result: RegExMatch in regex.search_all(text):
		var path := match_result.get_string(1)
		if not result.has(path):
			result.append(path)
	result.sort()
	return result


func _is_numbered_slug(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^\\d\\d-[a-z0-9-]+$")
	return regex.search(value) != null


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _join_lines(values: Array[String]) -> String:
	if values.is_empty():
		return ""

	var packed := PackedStringArray()
	for value: String in values:
		packed.append(value)
	return "\n".join(packed)
