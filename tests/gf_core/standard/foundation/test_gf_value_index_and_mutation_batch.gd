## 测试 GFValueIndex 与 GFMutationBatch 的通用集合行为。
extends GutTest


# --- 常量 ---

const GFMutationBatchBase = preload("res://addons/gf/standard/foundation/collections/gf_mutation_batch.gd")
const GFValueIndexBase = preload("res://addons/gf/standard/foundation/collections/gf_value_index.gd")


# --- 测试方法 ---

## 验证值索引可按字段单查和多条件查询。
func test_value_index_queries_by_fields() -> void:
	var index: GFValueIndexBase = GFValueIndexBase.new()

	assert_true(index.set_item(&"a", { "score": 1 }, {
		"tag": ["red", "fast"],
		"tier": 1,
	}), "有效条目应写入索引。")
	assert_true(index.set_item(&"b", { "score": 2 }, {
		"tag": ["blue", "fast"],
		"tier": 2,
	}), "第二个条目应写入索引。")

	assert_eq(index.query(&"tag", "fast"), PackedStringArray(["a", "b"]), "单字段查询应返回匹配条目。")
	assert_eq(index.query_many({ "tag": "fast", "tier": 2 }), PackedStringArray(["b"]), "多条件交集应返回共同匹配项。")
	assert_eq((index.get_item(&"a") as Dictionary).get("score"), 1, "索引应保留条目值。")


## 验证值索引替换条目时会清理旧字段。
func test_value_index_replaces_old_fields() -> void:
	var index: GFValueIndexBase = GFValueIndexBase.new()

	index.set_item(&"a", "old", { "tag": "red" })
	index.set_item(&"a", "new", { "tag": "blue" })

	assert_eq(index.query(&"tag", "red"), PackedStringArray(), "替换条目后旧字段索引应清理。")
	assert_eq(index.query(&"tag", "blue"), PackedStringArray(["a"]), "替换条目后新字段索引应可查。")


## 验证变更批次可提交并按反向顺序回滚。
func test_mutation_batch_commits_and_rolls_back() -> void:
	var batch: GFMutationBatchBase = GFMutationBatchBase.new()
	var values: Array[String] = []
	var commit_one := func() -> Dictionary:
		values.append("one")
		return { "ok": true, "value": "one" }
	var rollback_one := func() -> void:
		values.append("undo_one")
	var commit_two := func() -> void:
		values.append("two")
	var rollback_two := func() -> void:
		values.append("undo_two")

	batch.add_operation(commit_one, rollback_one)
	batch.add_operation(commit_two, rollback_two)

	var commit_report := batch.commit()
	var rollback_report := batch.rollback_committed()

	assert_true(bool(commit_report["ok"]), "全部操作成功时提交报告应成功。")
	assert_eq(int(commit_report["committed_count"]), 2, "提交报告应统计成功数量。")
	assert_true(bool(rollback_report["ok"]), "有效回滚应成功。")
	assert_eq(values, ["one", "two", "undo_two", "undo_one"], "回滚应按提交反向顺序执行。")


## 验证变更批次默认在失败时保留待处理操作。
func test_mutation_batch_stops_on_failure() -> void:
	var batch: GFMutationBatchBase = GFMutationBatchBase.new()
	var blocked_operation := func() -> Dictionary:
		return { "ok": false, "error": "blocked" }

	batch.add_operation(blocked_operation)

	var report := batch.commit()

	assert_false(bool(report["ok"]), "操作失败时提交报告应失败。")
	assert_eq(int(report["failed_count"]), 1, "提交报告应统计失败数量。")
	assert_eq(batch.get_pending_count(), 1, "默认停止失败时应保留待处理操作。")
