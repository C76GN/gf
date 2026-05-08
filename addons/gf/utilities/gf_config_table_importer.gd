## GFConfigTableImporter: 通用导表文本解析与 schema 校验入口。
##
## 提供 JSON 与 CSV 的轻量解析，适合编辑器工具或 CI 在进入项目 Provider 前做结构检查。
class_name GFConfigTableImporter
extends RefCounted


# --- 公共方法 ---

## 解析 JSON 表文本。
## @param text: JSON 文本。
## @return 结果字典，包含 success、data 与 error。
static func parse_json_table(text: String) -> Dictionary:
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		return {
			"success": false,
			"data": null,
			"error": "JSON parse failed: %s" % json.get_error_message(),
		}

	return {
		"success": true,
		"data": json.data,
		"error": "",
	}


## 解析 CSV 表文本。
## @param text: CSV 文本。
## @param options: 可选参数，支持 delimiter、trim_cells、skip_empty_lines。
## @return 结果字典，包含 success、data 与 error。
static func parse_csv_table(text: String, options: Dictionary = {}) -> Dictionary:
	var delimiter := str(options.get("delimiter", ","))
	if delimiter.is_empty():
		delimiter = ","
	var trim_cells := bool(options.get("trim_cells", true))
	var skip_empty_lines := bool(options.get("skip_empty_lines", true))
	var rows := _parse_csv_rows(text, delimiter.substr(0, 1), trim_cells)
	if rows.is_empty():
		return {
			"success": true,
			"data": [],
			"error": "",
		}

	var header := rows[0] as PackedStringArray
	var records: Array[Dictionary] = []
	for row_index: int in range(1, rows.size()):
		var row := rows[row_index] as PackedStringArray
		if skip_empty_lines and _csv_row_is_empty(row):
			continue

		var record: Dictionary = {}
		for column_index: int in range(header.size()):
			var key := StringName(header[column_index])
			if key == &"":
				continue
			record[key] = row[column_index] if column_index < row.size() else ""
		records.append(record)

	return {
		"success": true,
		"data": records,
		"error": "",
	}


## 解析并校验 JSON 表文本。
## @param text: JSON 文本。
## @param schema: 表结构声明。
## @return 校验报告；解析失败时返回失败报告。
static func validate_json_table(text: String, schema: GFConfigTableSchema) -> Dictionary:
	if schema == null:
		return _make_error_report(&"", "missing_schema", "schema 为空。")

	var parsed := parse_json_table(text)
	if not bool(parsed.get("success", false)):
		return _make_error_report(schema.get_table_key(), "parse_failed", str(parsed.get("error", "")))
	return schema.validate_table(parsed.get("data"))


## 解析并校验 CSV 表文本。
## @param text: CSV 文本。
## @param schema: 表结构声明。
## @param options: 可选参数，支持 delimiter、trim_cells、skip_empty_lines。
## @return 校验报告；解析失败时返回失败报告。
static func validate_csv_table(text: String, schema: GFConfigTableSchema, options: Dictionary = {}) -> Dictionary:
	if schema == null:
		return _make_error_report(&"", "missing_schema", "schema 为空。")

	var parsed := parse_csv_table(text, options)
	if not bool(parsed.get("success", false)):
		return _make_error_report(schema.get_table_key(), "parse_failed", str(parsed.get("error", "")))
	return schema.validate_table(parsed.get("data"))


# --- 私有/辅助方法 ---

static func _parse_csv_rows(text: String, delimiter: String, trim_cells: bool) -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	var row := PackedStringArray()
	var cell := ""
	var in_quotes := false
	var index := 0

	while index < text.length():
		var ch := text.substr(index, 1)
		if in_quotes:
			if ch == "\"":
				if index + 1 < text.length() and text.substr(index + 1, 1) == "\"":
					cell += "\""
					index += 1
				else:
					in_quotes = false
			else:
				cell += ch
		else:
			if ch == "\"":
				in_quotes = true
			elif ch == delimiter:
				row.append(cell.strip_edges() if trim_cells else cell)
				cell = ""
			elif ch == "\n":
				row.append(cell.strip_edges() if trim_cells else cell)
				rows.append(row)
				row = PackedStringArray()
				cell = ""
			elif ch != "\r":
				cell += ch
		index += 1

	row.append(cell.strip_edges() if trim_cells else cell)
	if row.size() > 1 or not _csv_row_is_empty(row):
		rows.append(row)
	return rows


static func _csv_row_is_empty(row: PackedStringArray) -> bool:
	for cell: String in row:
		if not cell.strip_edges().is_empty():
			return false
	return true


static func _make_error_report(table_name: StringName, code: String, message: String) -> Dictionary:
	return {
		"ok": false,
		"table_name": table_name,
		"row_count": 0,
		"error_count": 1,
		"warning_count": 0,
		"issues": [{
			"severity": "error",
			"code": code,
			"table_name": table_name,
			"row_key": null,
			"field": &"",
			"message": message,
		}],
	}
