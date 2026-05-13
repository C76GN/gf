## GFConfigTableMergeTools: 配置表补丁合并工具。
##
## 提供 Array[Dictionary] 与 Dictionary 表的通用补丁合并，适合导表后处理、
## 编辑器工具或项目自己的配置包流程使用。
class_name GFConfigTableMergeTools
extends RefCounted


# --- 公共方法 ---

## 合并 base 表与 patch 表。
## @param base_table: Array[Dictionary] 或 Dictionary 形式的基础表。
## @param patch_table: Array[Dictionary] 或 Dictionary 形式的补丁表。
## @param policy: 可选合并策略；为空时使用默认策略。
## @return 结果字典，包含 ok、data、issues 与统计信息。
static func merge_tables(
	base_table: Variant,
	patch_table: Variant,
	policy: GFConfigTableMergePolicy = null
) -> Dictionary:
	var resolved_policy := policy if policy != null else GFConfigTableMergePolicy.new()
	var base_rows_variant: Variant = _normalize_table(base_table)
	var patch_rows_variant: Variant = _normalize_table(patch_table)
	var report := _make_result(_is_dictionary_table(base_table), base_table)
	if base_rows_variant == null:
		_add_issue(report, "error", "invalid_base_table", null, "base_table 必须是 Array[Dictionary] 或 Dictionary。")
		_finalize_result(report)
		return report
	if patch_rows_variant == null:
		_add_issue(report, "error", "invalid_patch_table", null, "patch_table 必须是 Array[Dictionary] 或 Dictionary。")
		_finalize_result(report)
		return report

	var state := _build_base_state(base_rows_variant as Array[Dictionary], resolved_policy, report)
	_apply_patch_rows(state, patch_rows_variant as Array[Dictionary], resolved_policy, report)
	report["data"] = _build_output_data(state, bool(report.get("dictionary_output", false)), resolved_policy)
	_finalize_result(report)
	return report


# --- 私有/辅助方法 ---

static func _normalize_table(table_data: Variant) -> Variant:
	var rows: Array[Dictionary] = []
	if table_data is Array:
		var array_table := table_data as Array
		for index: int in range(array_table.size()):
			var row_variant: Variant = array_table[index]
			if not (row_variant is Dictionary):
				return null
			rows.append({
				"outer_key": index,
				"record": (row_variant as Dictionary).duplicate(true),
			})
		return rows
	if table_data is Dictionary:
		var dictionary_table := table_data as Dictionary
		for key: Variant in dictionary_table.keys():
			var row_variant: Variant = dictionary_table[key]
			if not (row_variant is Dictionary):
				return null
			rows.append({
				"outer_key": key,
				"record": (row_variant as Dictionary).duplicate(true),
			})
		return rows
	return null


static func _is_dictionary_table(table_data: Variant) -> bool:
	return table_data is Dictionary


static func _make_result(dictionary_output: bool, base_table: Variant) -> Dictionary:
	return {
		"ok": true,
		"data": {} if dictionary_output else [],
		"dictionary_output": dictionary_output,
		"base_count": (base_table as Dictionary).size() if base_table is Dictionary else (base_table as Array).size() if base_table is Array else 0,
		"inserted_count": 0,
		"updated_count": 0,
		"deleted_count": 0,
		"error_count": 0,
		"warning_count": 0,
		"issues": [],
	}


static func _build_base_state(rows: Array[Dictionary], policy: GFConfigTableMergePolicy, report: Dictionary) -> Dictionary:
	var state := {
		"order": [],
		"records": {},
		"outer_keys": {},
		"removed": {},
	}
	var order := state["order"] as Array
	var records := state["records"] as Dictionary
	var outer_keys := state["outer_keys"] as Dictionary
	for row_entry: Dictionary in rows:
		var record := row_entry["record"] as Dictionary
		var key := policy.make_record_key(record, row_entry.get("outer_key"))
		if key.is_empty():
			_add_issue(report, "error", "missing_base_key", row_entry.get("outer_key"), "基础记录缺少合并键。")
			continue
		if records.has(key):
			_add_issue(report, "error", "duplicate_base_key", row_entry.get("outer_key"), "基础记录合并键重复。")
			continue
		order.append(key)
		records[key] = record
		outer_keys[key] = row_entry.get("outer_key")
	return state


static func _apply_patch_rows(
	state: Dictionary,
	rows: Array[Dictionary],
	policy: GFConfigTableMergePolicy,
	report: Dictionary
) -> void:
	for row_entry: Dictionary in rows:
		var record := row_entry["record"] as Dictionary
		var key := policy.make_record_key(record, row_entry.get("outer_key"))
		if key.is_empty():
			_add_issue(report, "error", "missing_patch_key", row_entry.get("outer_key"), "补丁记录缺少合并键。")
			continue
		if policy.is_delete_record(record):
			_apply_delete(state, key, row_entry.get("outer_key"), policy, report)
		elif (state["records"] as Dictionary).has(key):
			_apply_update(state, key, record, row_entry.get("outer_key"), policy, report)
		else:
			_apply_insert(state, key, record, row_entry.get("outer_key"), policy, report)


static func _apply_delete(
	state: Dictionary,
	key: String,
	row_key: Variant,
	policy: GFConfigTableMergePolicy,
	report: Dictionary
) -> void:
	if not policy.allow_delete:
		_add_issue(report, "error", "delete_not_allowed", row_key, "当前合并策略不允许删除记录。")
		return
	var records := state["records"] as Dictionary
	if not records.has(key):
		_add_issue(report, "warning", "delete_missing_record", row_key, "删除标记没有命中已有记录。")
		return
	records.erase(key)
	(state["removed"] as Dictionary)[key] = true
	report["deleted_count"] = int(report["deleted_count"]) + 1


static func _apply_update(
	state: Dictionary,
	key: String,
	record: Dictionary,
	row_key: Variant,
	policy: GFConfigTableMergePolicy,
	report: Dictionary
) -> void:
	if not policy.allow_update:
		_add_issue(report, "error", "update_not_allowed", row_key, "当前合并策略不允许更新记录。")
		return
	var records := state["records"] as Dictionary
	records[key] = policy.merge_record(records[key] as Dictionary, record)
	report["updated_count"] = int(report["updated_count"]) + 1


static func _apply_insert(
	state: Dictionary,
	key: String,
	record: Dictionary,
	row_key: Variant,
	policy: GFConfigTableMergePolicy,
	report: Dictionary
) -> void:
	if not policy.allow_insert:
		_add_issue(report, "error", "insert_not_allowed", row_key, "当前合并策略不允许插入记录。")
		return
	(state["records"] as Dictionary)[key] = record.duplicate(true)
	(state["outer_keys"] as Dictionary)[key] = row_key
	if not (state["order"] as Array).has(key):
		(state["order"] as Array).append(key)
	report["inserted_count"] = int(report["inserted_count"]) + 1


static func _build_output_data(state: Dictionary, dictionary_output: bool, policy: GFConfigTableMergePolicy) -> Variant:
	var records := state["records"] as Dictionary
	var order := state["order"] as Array
	if dictionary_output:
		var result: Dictionary = {}
		for key: String in _ordered_keys(order, records, policy.preserve_base_order):
			var outer_key: Variant = (state["outer_keys"] as Dictionary).get(key, key)
			result[outer_key] = (records[key] as Dictionary).duplicate(true)
		return result

	var result: Array[Dictionary] = []
	for key: String in _ordered_keys(order, records, policy.preserve_base_order):
		result.append((records[key] as Dictionary).duplicate(true))
	return result


static func _ordered_keys(order: Array, records: Dictionary, preserve_base_order: bool) -> PackedStringArray:
	var result := PackedStringArray()
	if preserve_base_order:
		for key_variant: Variant in order:
			var key := String(key_variant)
			if records.has(key):
				result.append(key)
		for key_variant: Variant in records.keys():
			var key := String(key_variant)
			if not result.has(key):
				result.append(key)
	else:
		for key_variant: Variant in records.keys():
			result.append(String(key_variant))
		result.sort()
	return result


static func _add_issue(report: Dictionary, severity: String, code: String, row_key: Variant, message: String) -> void:
	var issues := report["issues"] as Array
	issues.append({
		"severity": severity,
		"code": code,
		"row_key": row_key,
		"message": message,
	})
	if severity == "warning":
		report["warning_count"] = int(report["warning_count"]) + 1
	else:
		report["error_count"] = int(report["error_count"]) + 1
		report["ok"] = false


static func _finalize_result(report: Dictionary) -> void:
	report["ok"] = int(report.get("error_count", 0)) == 0
