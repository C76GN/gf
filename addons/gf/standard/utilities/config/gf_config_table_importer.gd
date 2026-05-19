## GFConfigTableImporter: 通用导表文本解析与 schema 校验入口。
##
## 提供 JSON 与 CSV 的轻量解析，适合编辑器工具或 CI 在进入项目 Provider 前做结构检查。
class_name GFConfigTableImporter
extends RefCounted


# --- 常量 ---

const _CONFIG_VALIDATION_REPORT = preload("res://addons/gf/standard/utilities/config/gf_config_validation_report.gd")


# --- 公共方法 ---

## 解析 JSON 表文本。
## @param text: JSON 文本。
## @param options: 可选参数，支持 source。
## @return 结果字典，包含 success、data、error、error_line 与 source。
static func parse_json_table(text: String, options: Dictionary = {}) -> Dictionary:
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		return {
			"success": false,
			"data": null,
			"error": "JSON parse failed: %s" % json.get_error_message(),
			"error_line": json.get_error_line(),
			"source": String(options.get("source", "")),
		}

	return {
		"success": true,
		"data": json.data,
		"error": "",
		"error_line": 0,
		"source": String(options.get("source", "")),
	}


## 解析 CSV 表文本。
## @param text: CSV 文本。
## @param options: 可选参数，支持 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers、source。
## @return 结果字典，包含 success、data、row_locations 与 error。
static func parse_csv_table(text: String, options: Dictionary = {}) -> Dictionary:
	var delimiter := str(options.get("delimiter", ","))
	if delimiter.is_empty():
		delimiter = ","
	var trim_cells := bool(options.get("trim_cells", true))
	var skip_empty_lines := bool(options.get("skip_empty_lines", true))
	var reject_duplicate_headers := bool(options.get("reject_duplicate_headers", true))
	var source := String(options.get("source", ""))
	var parse_result := _parse_csv_rows(_normalize_csv_text(text), delimiter.substr(0, 1), trim_cells)
	if not bool(parse_result.get("success", false)):
		return {
			"success": false,
			"data": null,
			"row_locations": [],
			"error": String(parse_result.get("error", "")),
			"error_line": int(parse_result.get("error_line", 0)),
			"error_column": int(parse_result.get("error_column", 0)),
			"source": source,
		}

	var rows := parse_result.get("rows", []) as Array
	if rows.is_empty():
		return {
			"success": true,
			"data": [],
			"row_locations": [],
			"error": "",
			"error_line": 0,
			"error_column": 0,
			"source": source,
	}

	var header := rows[0] as PackedStringArray
	var header_error := _validate_csv_header(header, reject_duplicate_headers)
	if not header_error.is_empty():
		return {
			"success": false,
			"data": null,
			"row_locations": [],
			"error": header_error,
			"error_line": 1,
			"error_column": 1,
			"source": source,
		}

	var records: Array[Dictionary] = []
	var row_locations: Array[Dictionary] = []
	for row_index: int in range(1, rows.size()):
		var row := rows[row_index] as PackedStringArray
		if skip_empty_lines and _csv_row_is_empty(row):
			continue

		var record: Dictionary = {}
		var row_location := _make_csv_row_location(source, row_index + 1, header)
		for column_index: int in range(header.size()):
			var key := StringName(header[column_index])
			if key == &"":
				continue
			record[key] = row[column_index] if column_index < row.size() else ""
		records.append(record)
		row_locations.append(row_location)

	return {
		"success": true,
		"data": records,
		"row_locations": row_locations,
		"error": "",
		"error_line": 0,
		"error_column": 0,
		"source": source,
	}


## 解析并校验 JSON 表文本。
## @param text: JSON 文本。
## @param schema: 表结构声明。
## @param options: 可选参数，支持 source。
## @return 校验报告；解析失败时返回失败报告。
static func validate_json_table(text: String, schema: GFConfigTableSchema, options: Dictionary = {}) -> Dictionary:
	if schema == null:
		return _make_error_report(&"", "missing_schema", "schema 为空。")

	var parsed := parse_json_table(text, options)
	if not bool(parsed.get("success", false)):
		return _make_error_report(schema.get_table_key(), "parse_failed", str(parsed.get("error", "")), {
			"source": parsed.get("source", ""),
			"line": parsed.get("error_line", 0),
		})
	return schema.validate_table(parsed.get("data"), _make_validation_options(options, parsed))


## 解析并校验 CSV 表文本。
## @param text: CSV 文本。
## @param schema: 表结构声明。
## @param options: 可选参数，支持 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers、source。
## @return 校验报告；解析失败时返回失败报告。
static func validate_csv_table(text: String, schema: GFConfigTableSchema, options: Dictionary = {}) -> Dictionary:
	if schema == null:
		return _make_error_report(&"", "missing_schema", "schema 为空。")

	var parsed := parse_csv_table(text, options)
	if not bool(parsed.get("success", false)):
		return _make_error_report(schema.get_table_key(), "parse_failed", str(parsed.get("error", "")), {
			"source": parsed.get("source", ""),
			"line": parsed.get("error_line", 0),
			"column": parsed.get("error_column", 0),
		})
	return schema.validate_table(parsed.get("data"), _make_validation_options(options, parsed))


## 导出 CSV 表文本。
## @param table_data: Array[Dictionary] 或 Dictionary 形式的表数据。
## @param schema: 可选 schema；提供时默认按 schema.columns 排列列。
## @param options: 可选参数，支持 delimiter、columns、include_header、coerce_values。
## @return 结果字典，包含 success、text 与 error。
static func export_csv_table(
	table_data: Variant,
	schema: GFConfigTableSchema = null,
	options: Dictionary = {}
) -> Dictionary:
	var rows_variant: Variant = _normalize_table_rows(table_data)
	if rows_variant == null:
		return {
			"success": false,
			"text": "",
			"error": "table_data must be Array[Dictionary] or Dictionary.",
		}
	var rows := rows_variant as Array[Dictionary]

	var delimiter := str(options.get("delimiter", ","))
	if delimiter.is_empty():
		delimiter = ","
	delimiter = delimiter.substr(0, 1)
	var columns := _resolve_export_columns(rows, schema, options)
	var lines := PackedStringArray()
	if bool(options.get("include_header", true)):
		lines.append(_join_csv_row(columns, delimiter))

	var coerce_values := bool(options.get("coerce_values", schema != null and schema.coerce_values))
	for row: Dictionary in rows:
		var record := schema.coerce_record(row) if coerce_values and schema != null else row
		var cells := PackedStringArray()
		for column_name: String in columns:
			cells.append(_format_csv_cell(record.get(StringName(column_name), ""), delimiter))
		lines.append(delimiter.join(cells))

	return {
		"success": true,
		"text": "\n".join(lines),
		"error": "",
	}


# --- 私有/辅助方法 ---

static func _parse_csv_rows(text: String, delimiter: String, trim_cells: bool) -> Dictionary:
	var rows: Array[PackedStringArray] = []
	var row := PackedStringArray()
	var cell := ""
	var in_quotes := false
	var quote_start_line := 1
	var quote_start_column := 1
	var index := 0
	var line := 1
	var column := 1

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
				if ch == "\n":
					line += 1
					column = 0
		else:
			if ch == "\"":
				in_quotes = true
				quote_start_line = line
				quote_start_column = column
			elif ch == delimiter:
				row.append(cell.strip_edges() if trim_cells else cell)
				cell = ""
			elif ch == "\n":
				row.append(cell.strip_edges() if trim_cells else cell)
				rows.append(row)
				row = PackedStringArray()
				cell = ""
				line += 1
				column = 0
			elif ch != "\r":
				cell += ch
		index += 1
		column += 1

	if in_quotes:
		return {
			"success": false,
			"rows": rows,
			"error": "CSV parse failed: unclosed_quote",
			"error_line": quote_start_line,
			"error_column": quote_start_column,
		}

	row.append(cell.strip_edges() if trim_cells else cell)
	if row.size() > 1 or not _csv_row_is_empty(row):
		rows.append(row)
	return {
		"success": true,
		"rows": rows,
		"error": "",
		"error_line": 0,
		"error_column": 0,
	}


static func _normalize_csv_text(text: String) -> String:
	return text.trim_prefix("\ufeff")


static func _validate_csv_header(header: PackedStringArray, reject_duplicate_headers: bool) -> String:
	if not reject_duplicate_headers:
		return ""

	var seen: Dictionary = {}
	for column_name: String in header:
		if column_name.is_empty():
			continue
		if seen.has(column_name):
			return "CSV header has duplicate column: %s" % column_name
		seen[column_name] = true
	return ""


static func _csv_row_is_empty(row: PackedStringArray) -> bool:
	for cell: String in row:
		if not cell.strip_edges().is_empty():
			return false
	return true


static func _make_csv_row_location(source: String, line_number: int, header: PackedStringArray) -> Dictionary:
	var fields: Dictionary = {}
	for column_index: int in range(header.size()):
		var key := StringName(header[column_index])
		if key == &"":
			continue
		var field_location := {
			"line": line_number,
			"column": column_index + 1,
			"column_index": column_index,
		}
		if not source.is_empty():
			field_location["source"] = source
		fields[key] = field_location
		fields[String(key)] = field_location

	var row_location := {
		"line": line_number,
		"row_index": line_number - 2,
		"fields": fields,
	}
	if not source.is_empty():
		row_location["source"] = source
	return row_location


static func _make_error_report(
	table_name: StringName,
	kind: String,
	message: String,
	context: Dictionary = {}
) -> Dictionary:
	return _CONFIG_VALIDATION_REPORT.new().make_error_report(table_name, kind, message, context)


static func _make_validation_options(options: Dictionary, parsed: Dictionary) -> Dictionary:
	var result := options.duplicate(true)
	if parsed.has("source") and not String(parsed.get("source", "")).is_empty():
		result["source"] = parsed.get("source")
	if parsed.has("row_locations"):
		result["row_locations"] = parsed.get("row_locations")
	return result


static func _normalize_table_rows(table_data: Variant) -> Variant:
	var rows: Array[Dictionary] = []
	if table_data is Array:
		for row_variant: Variant in table_data:
			if not (row_variant is Dictionary):
				return null
			rows.append((row_variant as Dictionary).duplicate(true))
		return rows
	if table_data is Dictionary:
		var table := table_data as Dictionary
		var keys := table.keys()
		keys.sort()
		for key: Variant in keys:
			var row_variant: Variant = table[key]
			if not (row_variant is Dictionary):
				return null
			rows.append((row_variant as Dictionary).duplicate(true))
		return rows
	return null


static func _resolve_export_columns(
	rows: Array[Dictionary],
	schema: GFConfigTableSchema,
	options: Dictionary
) -> PackedStringArray:
	if options.has("columns"):
		return _to_packed_string_array(options["columns"])
	if schema != null:
		var schema_columns := schema.get_column_names()
		if not schema_columns.is_empty():
			return schema_columns

	var seen: Dictionary = {}
	for row: Dictionary in rows:
		for key: Variant in row.keys():
			seen[String(key)] = true
	var result := PackedStringArray()
	for key_text: String in seen.keys():
		result.append(key_text)
	result.sort()
	return result


static func _to_packed_string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		for item: Variant in value:
			result.append(String(item))
	return result


static func _join_csv_row(cells: PackedStringArray, delimiter: String) -> String:
	var escaped := PackedStringArray()
	for cell: String in cells:
		escaped.append(_format_csv_cell(cell, delimiter))
	return delimiter.join(escaped)


static func _format_csv_cell(value: Variant, delimiter: String) -> String:
	var text := str(value)
	var needs_quotes := text.contains(delimiter) or text.contains("\n") or text.contains("\r") or text.contains("\"")
	text = text.replace("\"", "\"\"")
	return "\"%s\"" % text if needs_quotes else text
