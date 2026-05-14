# Foundation 标签、公式、集合、序列化与结果报告

这些 Foundation 能力用于标签查询、公式规则、值索引、变更批次、Variant 处理、校验报告和结果字典等通用数据流程。

## `GFTagSet` / `GFTagQuery` / `GFTagSourceAdapter`

这组三个类提供 Foundation 级标签查询原语，适合在技能条件、AI 感知、配置校验、编辑器过滤或任意项目对象上复用。它们只处理 `StringName` 标签、层数和 all/any/none 查询，不维护全局标签表，也不规定标签命名语义。

```gdscript
var tags := GFTagSet.new()
tags.add_tag(&"state.burning", 2)
tags.add_tag(&"team.enemy")

var query := GFTagQuery.new()
query.all_tags = [&"state"]
query.any_tags = [&"team.enemy", &"team.ally"]
query.none_tags = [&"state.frozen"]
query.include_child_tags = true

if query.matches(tags):
	# 项目层自行决定匹配后的行为。
	pass
```

`GFTagSourceAdapter` 可读取 `GFTagSet`、`Array`、`PackedStringArray`、`Dictionary`，也可读取实现了 `has_tag()` / `get_tag_count()` / `get_tags()` 的对象。层级匹配只使用点号前缀，例如查询 `state` 时可匹配 `state.burning`；是否采用这种命名规范由项目层决定。


## `GFBlackboardEntry` / `GFBlackboardSchema`

黑板 Schema 用于给运行时字典提供轻量字段契约：字段键、类型、必填性、空值策略、默认值和元数据。它适合状态机、行为树、任务流程、编辑器工具或项目自己的 AI/流程系统共享同一套字典校验逻辑，但不规定字段含义。

```gdscript
var hp := GFBlackboardEntry.new()
hp.key = &"hp"
hp.value_type = GFBlackboardEntry.ValueType.INT
hp.required = true
hp.allow_null = false

var schema := GFBlackboardSchema.new()
schema.entries = [hp]
schema.coerce_values = true

var values := schema.apply_defaults({ "hp": "10" })
var report := schema.validate_values(values)
print(report["ok"]) # true
```

`GFBlackboardSchema` 默认允许额外字段，便于渐进接入；需要严格资源或导入校验时可关闭 `allow_extra_keys`。类型转换只做通用 Variant 转换，不做业务范围、权限、冷却、目标合法性或状态机规则判断。


## `GFBudgetLedger`

`GFBudgetLedger` 是通用资源预算账本，用于记录一组抽象资源的容量、可用量、消费结果和释放。它不规定资源含义：可以用于体力、行动点、并发额度、构建预算、编辑器批处理配额或任何项目自定义资源。

```gdscript
var ledger := GFBudgetLedger.new()
ledger.set_capacity(&"energy", 10.0)

var result := ledger.consume(&"energy", 3.0, {
	"source": "dash",
})
if result["ok"]:
	print(ledger.get_available(&"energy")) # 7.0

ledger.release(&"energy", 1.0)
ledger.reset(&"energy")
```

`consume()` 返回统一结果字典，包含 `ok`、`budget_id`、`amount`、`reason`、`available`、`capacity` 和调用方传入的 `metadata`。预算不足、负数请求和缺失预算都会被拒绝并发出 `budget_rejected`；成功消费会发出 `budget_consumed` 与 `budget_changed`。GF 只维护账本，不决定何时恢复、如何显示、是否允许透支或哪个玩法系统拥有预算。


## `GFValueIndex` / `GFMutationBatch`

`GFValueIndex` 是轻量多字段索引：调用方把任意 `item_id`、值和字段字典写进去，再按字段值查询匹配条目。字段值可以是单值、`Array` 或 `PackedStringArray`；索引只维护查找结构，不解释字段语义，也不持有全局注册表。

```gdscript
var index := GFValueIndex.new()
index.set_item(&"entry_a", { "score": 1 }, {
	"tag": ["fast", "visible"],
	"tier": 1,
})

var fast_ids := index.query(&"tag", "fast")
var tier_ids := index.query_many({
	"tag": "fast",
	"tier": 1,
})
```

`GFMutationBatch` 把一组 `Callable` 作为可提交、可回滚的批次执行。它适合编辑器工具、导入流程、资源批处理或项目自己的事务边界；框架只管理顺序、结果归一化和反向回滚，不知道操作修改的是资源、存档、场景还是内存模型。

```gdscript
var batch := GFMutationBatch.new()
batch.add_operation(
	func() -> Dictionary:
		model["value"] = 10
		return { "ok": true },
	func() -> void:
		model["value"] = 0
)

var result := batch.commit()
if not result["ok"]:
	batch.rollback_committed()
```

`GFMutationBatch` 默认在失败时停止并保留失败操作，便于调用方修正后重试；如果项目希望失败后继续处理后续操作，可关闭 `stop_on_error`。回滚只调用已提交操作的 rollback，不假设操作具备天然可逆性，因此可逆边界应由调用方显式提供。


## `GFTimedTextEntry` / `GFTimedTextTrack` / `GFTimedTextImporter`

时间段文本轨道用于保存“某段时间显示某段文本”的通用数据。它可以服务字幕、对白、教程提示、歌词、时间轴注释或项目自己的媒体标记，但不绑定任何 UI 控件或具体格式。

```gdscript
var parsed := GFTimedTextImporter.parse_srt(srt_text, &"caption")
var track := parsed["track"] as GFTimedTextTrack

var current_text := track.get_text_at_time(12.5)
var nearby_entries := track.get_entries_in_range(10.0, 15.0)
```

`GFTimedTextEntry` 只保存 `start_time`、`end_time`、`text` 和元数据；`GFTimedTextTrack` 负责排序、按时间查询、范围查询、总时长和字典转换；`GFTimedTextImporter` 只提供 SRT、WebVTT 和 LRC 的轻量解析入口。复杂字幕样式、富文本清洗、语音同步、动画注入和本地化选择仍应放在项目层或专门扩展里。


## `GFFormula` / `GFFormulaParameter` / `GFFormulaSet`

资源化公式适合把“可替换的计算策略”从 `System`、`Command` 或配置驱动流程中抽离出来。GF 只提供抽象容器，不规定伤害、命中、价格、评分等具体语义。

```gdscript
class_name ScoreFormula
extends GFFormula


func calculate(parameter: GFFormulaParameter = null) -> Variant:
	if parameter == null:
		return fallback_value

	var base := float(parameter.get_value(&"base", 0.0))
	var multiplier := float(parameter.get_value(&"multiplier", 1.0))
	return base * multiplier
```

```gdscript
var formulas := GFFormulaSet.new()
formulas.set_formula(&"score", ScoreFormula.new())

var parameter := GFFormulaParameter.new()
parameter.set_value(&"base", 10.0)
parameter.set_value(&"multiplier", 2.5)

var result := formulas.calculate(&"score", parameter, 0.0)
```

`calculate_float()`、`calculate_int()`、`calculate_bool()` 提供稳定的类型兜底，适合项目层在读取用户配置或可编辑资源时降低防御代码噪声。字符串转 float 会先检查 `is_valid_float()`，非法数字文本会返回传入的 fallback，而不会静默变成 `0.0`。


## `GFVariantData` / `GFVariantJsonCodec`

通用 Variant 基础件分为两个明确职责：`GFVariantData` 负责深拷贝、默认值合并和 Resource 可选复制；`GFVariantJsonCodec` 负责 JSON 友好的 Godot 类型转换。它们都不依赖 `GFArchitecture`，适合存档、配置、校验报告、网络消息、命中上下文等需要“复制集合但保留标量语义”或“把 Godot 值转成纯数据”的地方。

```gdscript
var payload := {
	"stats": {
		"hp": 10,
	},
}
var copy := GFVariantData.duplicate_variant(payload) as Dictionary

var settings := {
	"audio": {
		"volume": 0.8,
	},
}
GFVariantData.deep_merge_defaults(settings, {
	"audio": {
		"mute": false,
	},
	"language": "zh",
})

var saved_position := GFVariantJsonCodec.vector2_to_array(Vector2(12.0, 4.0))
var position := GFVariantJsonCodec.array_to_vector2(saved_position)

var json_payload := GFVariantJsonCodec.variant_to_json_compatible({
	"position": Vector3(1.0, 2.0, 3.0),
	"tags": PackedStringArray(["state.ready"]),
})
var restored := GFVariantJsonCodec.json_compatible_to_variant(
	JSON.parse_string(JSON.stringify(json_payload))
) as Dictionary
```

`GFVariantJsonCodec.variant_to_json_compatible()` 会为 `Vector2/3/4`、整数向量、`Color`、`Rect2`、`Transform2D/3D`、`Basis`、`Quaternion`、`AABB`、`Plane`、`NodePath`、`StringName` 和常见 PackedArray 写入轻量类型标记，再由 `json_compatible_to_variant()` 恢复。默认普通 Dictionary 仍使用字符串键；如果确实需要保留非字符串键，可传 `{ "encode_dictionary_keys": true }`。

`GFVariantData.duplicate_variant()` 默认只深拷贝 `Dictionary` 和 `Array`，其他值保持原样返回；如果值中包含 `Object` 或 `Resource`，仍是引用语义。需要复制资源值时，可显式传入 `duplicate_variant(value, true, true)`，框架内部的权重表复制会使用这个模式保留资源化候选项的深拷贝语义。JSON codec 遇到不支持的对象默认写成 `null`，需要持久化对象时，应在项目层先转换成资源路径、ID 或纯数据字典。


## `GFSourceSpan` / `GFValidationIssue` / `GFValidationReport` / `GFValidationReportDictionary`

通用校验基础件用于统一表达“某个数据、资源或节点结构有什么问题”。它们不绑定配置表、存档、能力、网络或编辑器工具的具体语义，只提供问题条目、报告聚合、统计、摘要和字典兼容辅助。

```gdscript
var report := GFValidationReport.new("Item table")
report.add_warning(&"missing_optional", "Optional field is missing.", "row_1")
report.add_error(&"invalid_value", "Value is invalid.", "row_2")

var data := report.to_dict({}, {
	"next_actions": {
		"invalid_value": "Fix the invalid value before importing.",
	},
})

print(data["ok"]) # false
print(data["summary"]) # Item table has 1 error(s) and 1 warning(s).
```

需要把问题定位到源码、配置表、导入文本或资源片段时，可以使用 `GFSourceSpan`。行列约定为 1-based，`0` 表示未知；`source` 字典字段会作为 `source_path` 的兼容别名读取，方便旧字典报告逐步迁移：

```gdscript
var span := GFSourceSpan.make("res://data/items.csv", 8, 4, 3)
var report := GFValidationReport.new("Item table")
report.add_source_error(&"invalid_value", "Value is invalid.", span)

var issue_data := report.to_dict()["issues"][0]
print(issue_data["source_path"]) # res://data/items.csv
print(issue_data["line"]) # 8
print(issue_data["source_span"]["column"]) # 4
```

`GFValidationDiagnosticAdapter` 把 `GFValidationIssue`、`GFValidationReport` 或兼容字典转换为纯诊断字典，不创建 Dock、Inspector 或具体控件。编辑器面板、导入器、CI 输出和项目自定义工具都可以消费同一份数据，再自行决定如何展示：

```gdscript
var diagnostics := GFValidationDiagnosticAdapter.report_to_diagnostics(report, {
	"include_positionless": false,
})
var line_records := GFValidationDiagnosticAdapter.make_line_records(diagnostics)
```

诊断记录会包含 `severity`、`kind`、`message`、`source_path`、`line`、`column`、0-based 的 `line_index` / `column_index`、`display_text`、`tooltip` 和 `source_span`。这些字段只表达通用定位信息，不规定点击行为、修复命令、表格 schema 或业务校验规则。

已有模块如果仍返回字典报告，可以先使用 `GFValidationReportDictionary.append_issue()` 和 `GFValidationReportDictionary.finalize_report()` 统一统计字段，而不必立刻迁移成对象式报告：

```gdscript
var legacy_report := {
	"row_count": 2,
	"issues": [],
}

GFValidationReportDictionary.append_source_issue(
	legacy_report,
	"warning",
	&"missing_optional",
	"Optional field is missing.",
	{ "source": "res://data/items.csv", "line": 10 },
	{ "row_key": 1 }
)
GFValidationReportDictionary.finalize_report(legacy_report, "Config table")
```

推荐把 `kind` / `code` 设计成稳定、抽象的 snake_case 标识，把具体修复策略放在调用方传入的 `next_actions` 映射中。这样框架层只负责报告结构和统计，不把项目业务规则写死进基础件。


## `GFResultDictionary`

`GFResultDictionary` 是更轻量的结果字典辅助，只统一常见字段名和基础构造，不负责统计问题或表达校验报告。它适合 `ok` / `data` / `metadata` / `error` 这类底层 Utility 返回值，尤其是存储、导入导出、异步任务等需要保持字典兼容的场景。

```gdscript
var result := GFResultDictionary.make_success({
	GFResultDictionary.KEY_DATA: { "coins": 10 },
	GFResultDictionary.KEY_METADATA: { "version": 2 },
})

if result[GFResultDictionary.KEY_OK]:
	print(result[GFResultDictionary.KEY_DATA])
```

如果返回结构需要问题列表、严重级别、摘要和下一步建议，应使用 `GFValidationIssue` / `GFValidationReport` / `GFValidationReportDictionary`；如果只是表达一次操作的成功、失败和载荷，优先复用 `GFResultDictionary` 的 key 常量和轻量工厂，避免不同模块手写字段名漂移。
