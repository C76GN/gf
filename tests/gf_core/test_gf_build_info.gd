## 测试 GFBuildInfo 与 GFBuildInfoUtility 的构建信息快照。
extends GutTest


func test_build_info_roundtrip_deep_copies_metadata() -> void:
	var info := GFBuildInfo.new()
	info.project_name = "GF Test"
	info.project_version = "1.0.0"
	info.framework_version = "1.27.1"
	info.commit_hash = "abc123"
	info.branch = "main"
	info.tag = "v1.0.0"
	info.commit_count = 12
	info.is_dirty = true
	info.metadata = {
		"channel": "test",
		"nested": {
			"value": 1,
		},
	}

	var copy := GFBuildInfo.from_dict(info.to_dict())
	(copy.metadata["nested"] as Dictionary)["value"] = 2

	assert_eq(copy.project_name, "GF Test", "构建信息应可从字典恢复。")
	assert_eq(copy.tag, "v1.0.0", "构建标签应参与序列化。")
	assert_eq(copy.commit_count, 12, "提交数量应参与序列化。")
	assert_true(copy.is_dirty, "工作区 dirty 标记应参与序列化。")
	assert_eq((info.metadata["nested"] as Dictionary)["value"], 1, "metadata 应深拷贝，避免外部修改原始对象。")


func test_build_info_collect_reads_framework_and_engine_version() -> void:
	var info := GFBuildInfo.collect()

	assert_false(info.framework_version.is_empty(), "应能从 plugin.cfg 读取 GF 版本。")
	assert_false(info.engine_version.is_empty(), "应能读取 Godot 引擎版本。")
	assert_false(info.platform_name.is_empty(), "应能读取运行平台。")


func test_build_info_utility_returns_copy_and_debug_snapshot() -> void:
	var info := GFBuildInfo.new()
	info.project_name = "GF Test"
	info.project_version = "1.0.0"
	info.framework_version = "1.27.1"
	info.build_id = "42"
	var utility := GFBuildInfoUtility.new()

	utility.set_build_info(info)
	var copy := utility.get_build_info()
	copy.project_name = "Changed"
	var snapshot := utility.get_debug_snapshot()

	assert_eq(utility.get_build_info(false).project_name, "GF Test", "默认返回副本，不应允许调用方改内部状态。")
	assert_true(bool(snapshot["available"]), "调试快照应报告构建信息可用。")
	assert_true(String(snapshot["summary"]).contains("GF Test"), "摘要应包含项目名。")
