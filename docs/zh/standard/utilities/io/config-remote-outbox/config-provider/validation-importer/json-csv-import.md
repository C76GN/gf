# JSON 与 CSV 导入

`GFConfigTableImporter` 提供轻量 JSON/CSV 文本解析、`validate_json_table()`、`validate_csv_table()` 和 `export_csv_table()` 入口，适合编辑器导入按钮、CI 检查或项目自定义导表流水线在写入缓存前做统一报告。

CSV 解析会去掉 UTF-8 BOM，默认拒绝重复表头，并在引号字段未闭合时返回带行列位置的 `unclosed_quote` 问题，而不是把后续整段文本静默吞进一个单元格。

导出会按 schema 列顺序或显式 `columns` 输出，并对包含分隔符、换行或引号的单元格做 CSV 转义。

传入 `{ "source": "res://..." }` 后，CSV 校验报告会尽量附带行列位置；JSON 解析失败会附带解析行号。

它仍是轻量解析器，只取 `delimiter` 的第一个字符，空表头会跳过，复杂 Excel、多 sheet 或编码探测仍建议交给项目导表流水线。

校验报告固定包含 `ok`、`row_count`、`error_count`、`warning_count` 和 `issues`。

项目工具可以直接把 `issues` 渲染成表格或控制台输出；项目自定义导入工具或校验规则若需要创建同形状报告，可以复用 `GFConfigValidationReport`。
