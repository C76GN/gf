# 导表、分析、远程缓存与请求 Outbox

这些工具面向配置表读取、分析事件、远程文本/JSON 缓存和离线请求 Outbox。

## 静态导表数据适配器 (`GFConfigProvider`)

**应用场景：** 当项目使用 JSON、CSV 或自定义导表流水线时，可以继承 `GFConfigProvider` 提供统一读取入口，并把具体加载和查询逻辑留在项目侧实现。

**如何使用：**
```gdscript
class_name JSONConfigProvider
extends GFConfigProvider

var _configs: Dictionary = {}

func async_init() -> void:
	# 异步加载你的表...
	pass

func get_record(table_name: StringName, id: Variant) -> Variant:
	if _configs.has(table_name) and _configs[table_name].has(id):
		return _configs[table_name][id]
	return null

func get_table(table_name: StringName) -> Variant:
	return _configs.get(table_name)
```

`GFConfigProvider` 是抽象适配器，本身不存数据；默认实现会报错并返回 `null`。返回类型保持 `Variant` 是为了兼容不同导表方案：可以返回 `Dictionary`、`Resource`、自定义记录对象，或整张表容器。框架内调用方会按自己的需求解释返回值，例如 `GFLevelUtility` 会接受字典记录，或带 `to_dict()` 方法的记录对象。

建议子类在 `async_init()` 或 `init()` 阶段完成加载，并在 `get_record()` 中返回只读数据或副本，避免业务代码直接改坏导表缓存。表名建议使用稳定 `StringName`，记录 ID 可保持项目导表原始类型。`register_schema()` 会保存 schema 副本，`get_schema()` 也返回副本，调用方修改返回值不会污染 Provider 内部校验规则。

导表结构可以用 `GFConfigTableColumn` 和 `GFConfigTableSchema` 独立声明，再注册到 Provider 上做导入期或运行时校验。它们只描述字段类型、必填、空值、默认值和额外字段策略，不规定表名含义、ID 规则或项目业务枚举：

```gdscript
var id_column := GFConfigTableColumn.new()
id_column.field_name = &"id"
id_column.value_type = GFConfigTableColumn.ValueType.INT
id_column.required = true
id_column.allow_null = false

var name_column := GFConfigTableColumn.new()
name_column.field_name = &"name"
name_column.value_type = GFConfigTableColumn.ValueType.STRING
name_column.required = true

var schema := GFConfigTableSchema.new()
schema.table_name = &"items"
schema.columns = [id_column, name_column]
schema.allow_extra_fields = false
schema.coerce_values = true
schema.fail_on_coerce_error = true
schema.require_unique_id = true

register_schema(schema)
var report := validate_table(&"items", get_table(&"items"))
```

`coerce_values` 是“导入期宽松转换 + 校验报告”，不是无条件吞错。`GFConfigTableColumn.try_coerce_value()` 会返回转换状态；`GFConfigTableSchema.fail_on_coerce_error` 默认开启，非法 int/float、无法解析的 Vector/Color/Array/Dictionary 等转换会记录 `coerce_failed`。如果项目确实需要旧式宽松导入，可以显式关闭 `fail_on_coerce_error`，但 CI 和正式导表建议保持开启。Array 表需要检测重复 ID 时，开启 `require_unique_id`。

需要更细的导入校验时，可以给字段、记录或整表挂载 `GFConfigValidationRule`。标准库提供的内置规则包括 `GFConfigRangeValidationRule`、`GFConfigRegexValidationRule`、`GFConfigSetValidationRule`、`GFConfigSizeValidationRule`、`GFConfigNotDefaultValidationRule`、`GFConfigResourcePathValidationRule` 和 `GFConfigLocalizationKeyValidationRule`。它们只表达通用约束：数值范围、字符串格式、白名单、数量、非默认值、Godot 资源路径和文本 key 是否存在；具体枚举、资源分类和语言表来源仍由项目声明：

```gdscript
var icon_column := GFConfigTableColumn.new()
icon_column.field_name = &"icon_path"
icon_column.value_type = GFConfigTableColumn.ValueType.STRING

var path_rule := GFConfigResourcePathValidationRule.new()
path_rule.allowed_extensions = PackedStringArray(["png", "webp"])
icon_column.validation_rules.append(path_rule)

var power_column := GFConfigTableColumn.new()
power_column.field_name = &"power"
power_column.value_type = GFConfigTableColumn.ValueType.FLOAT

var power_rule := GFConfigRangeValidationRule.new()
power_rule.has_minimum = true
power_rule.minimum = 0.0
power_column.validation_rules.append(power_rule)

var table_size := GFConfigSizeValidationRule.new()
table_size.has_maximum_size = true
table_size.maximum_size = 500
schema.table_validation_rules.append(table_size)
```

字段规则在类型校验通过后执行；记录规则放在 `GFConfigTableSchema.record_validation_rules`，表规则放在 `table_validation_rules`。校验上下文会写入 `table_name`、`row_key`、`field`、`rule_id`，并在导入器提供来源信息时附带 `source`、`line`、`column`，方便编辑器工具或 CI 精确定位错误。自定义规则继承 `GFConfigValidationRule`，只需要重写 `_validate_value()`、`_validate_record()` 或 `_validate_table()`，并通过 `_add_issue()` 写入稳定错误码。

`GFConfigTableImporter` 提供轻量 JSON/CSV 文本解析、`validate_json_table()` / `validate_csv_table()` 和 `export_csv_table()` 入口，适合编辑器导入按钮、CI 检查或项目自定义导表流水线在写入缓存前做统一报告。CSV 解析会去掉 UTF-8 BOM，默认拒绝重复表头，并在引号字段未闭合时返回带行列位置的 `unclosed_quote` 问题，而不是把后续整段文本静默吞进一个单元格；导出会按 schema 列顺序或显式 `columns` 输出，并对包含分隔符、换行或引号的单元格做 CSV 转义。传入 `{ "source": "res://..." }` 后，CSV 校验报告会尽量附带行列位置；JSON 解析失败会附带解析行号。它仍是轻量解析器，只取 `delimiter` 的第一个字符，空表头会跳过，复杂 Excel、多 sheet 或编码探测仍建议交给项目导表流水线。校验报告固定包含 `ok`、`row_count`、`error_count`、`warning_count` 和 `issues`，项目工具可以直接把 `issues` 渲染成表格或控制台输出。

需要表达唯一键或跨表关系时，可以在 `GFConfigTableSchema.indexes` 中加入 `GFConfigTableIndexDefinition`，在 `references` 中加入 `GFConfigTableReference`。唯一索引会参与单表校验；跨表引用由 `GFConfigReferenceResolver.validate_tables()` 在多表上下文中检查，`resolve_record_references()` 可把一条记录的引用解析为目标记录副本。GF 只理解字段、复合键和报告结构，不解释外键背后的业务含义：

```gdscript
var unique_index := GFConfigTableIndexDefinition.new()
unique_index.index_id = &"item_variant"
unique_index.field_names = PackedStringArray(["item_id", "variant"])
unique_index.unique = true
item_schema.indexes.append(unique_index)

var reference := GFConfigTableReference.new()
reference.source_fields = PackedStringArray(["item_id"])
reference.target_table_name = &"items"
reference.target_fields = PackedStringArray(["id"])
owner_schema.references.append(reference)

var report := GFConfigReferenceResolver.validate_tables({
	&"items": item_rows,
	&"owners": owner_rows,
}, [item_schema, owner_schema])
```

如果项目需要对基础表应用补丁表，可以使用 `GFConfigTableMergePolicy` 和 `GFConfigTableMergeTools`。默认策略按 `id` 生成记录键，支持插入、更新、删除标记和嵌套 Dictionary 字段合并；项目可以改用复合 key、Dictionary 外层 key、整条替换或禁用插入/删除。它只处理通用表结构，不决定补丁来自热更、编辑器覆盖、模组还是构建步骤：

```gdscript
var policy := GFConfigTableMergePolicy.new()
policy.key_fields = PackedStringArray(["id"])
policy.update_mode = GFConfigTableMergePolicy.UpdateMode.MERGE_FIELDS

var merged := GFConfigTableMergeTools.merge_tables(base_rows, patch_rows, policy)
if merged["ok"]:
	rows = merged["data"]
```

多目标构建可以用 `GFConfigBuildProfile` 按 metadata 中的 groups/tags 过滤 schema 和记录。GF 不内置任何分端含义，`include_groups`、`exclude_groups`、`include_tags` 和 `exclude_tags` 的命名都由项目自己决定；记录级 metadata 默认读取 `_metadata` 字段，字段、索引和引用则读取各自的 `metadata`：

```gdscript
var profile := GFConfigBuildProfile.new()
profile.include_groups = PackedStringArray(["runtime"])
profile.exclude_tags = PackedStringArray(["internal_only"])

var runtime_schema := profile.filter_schema(schema)
var runtime_rows := profile.filter_records(rows)
```

已有样本数据但暂时没有 schema 时，可以用 `GFConfigTableSchema.infer_from_records()` 从 `Array[Dictionary]` 或 `Dictionary` 表推导字段和值类型，再由项目层人工校正必填、默认值、枚举或业务约束：

```gdscript
var inferred_schema := GFConfigTableSchema.infer_from_records(&"items", rows, {
	"required_if_present_in_all_rows": true,
})

var exported := GFConfigTableImporter.export_csv_table(rows, inferred_schema)
if exported["success"]:
	print(exported["text"])
```

如果项目希望减少散落的表名字符串，可以用 `GFConfigAccessGenerator` 根据 schema 生成静态访问器。生成结果只是对 provider 的 `get_record()` / `get_table()` 的轻量访问封装，不改变 Provider 协议，也不把具体表结构写入框架：

```gdscript
var generator := GFConfigAccessGenerator.new()
generator.generate(
	[items_schema, levels_schema],
	"res://gf/generated/gf_config_access.gd",
	true,
	"GFConfigAccess",
	"Gf.get_utility(GFConfigProvider) as GFConfigProvider"
)

# 生成后项目代码可以通过 IDE 补全调用：
var item := GFConfigAccess.get_items_record(1001)
var levels := GFConfigAccess.get_levels_table()
```

生成器位于 kernel/editor，因此不会默认硬引用标准库的 `GFConfigProvider`；如果希望生成的访问器能在不显式传 provider 时工作，需要像上面这样传入项目自己的 `provider_accessor`。也可以在调用点显式传入 provider：`GFConfigAccess.get_items_record(1001, provider)`。访问器适合稳定表名、团队协作和重构检查；原始 `GFConfigProvider` 仍适合动态表名、热更新表包或项目自定义导表运行时。生成器只输出 GDScript，可用 `method_name_style`、`constant_prefix`、`record_method_pattern`、`table_method_pattern` 和 `include_schema_comments` 微调命名与注释，不生成其他语言代码。

开发期如果需要做 Resource 批量检查或表格式编辑，可以复用 `GFResourceTableEditor` 和 `GFEditorValueField`。前者负责扫描 `.tres` / `.res`、从 Resource export 推导列、提交单元格值并广播变更；默认只修改内存中的 Resource，不接管完整 UndoRedo 工作流；如果资源已有 `resource_path` 且项目希望提交后立即写盘，可以开启 `auto_save_committed_resources` 并监听 `resource_save_failed`。后者负责按 Godot 属性类型创建基础输入控件；Array/Dictionary JSON 输入解析失败时会发出 `value_parse_failed` 并保留旧值，不会把错误输入静默提交成空容器。它们是编辑器通用控件，不保存业务表结构，也不替项目决定资源分类、校验规则或提交工作流。


## 通用分析事件 (`GFAnalyticsUtility`)

**应用场景：** 当你需要在项目内统一记录调试指标、玩家流程节点或运行时事件，并希望先在本地 dry-run，之后再按需接入 HTTP 端点时，可以使用该工具。

`GFAnalyticsUtility` 默认不会在 endpoint 为空时访问网络，`flush()` 会以 dry-run 成功完成，便于测试和本地开发保持同一套调用路径。它会为设备生成并持久化匿名 client id，同时每次运行生成新的 session id。

```gdscript
var analytics := Gf.get_utility(GFAnalyticsUtility) as GFAnalyticsUtility
analytics.config.auto_capture_context = true
analytics.config.batch_size = 20

analytics.identify("client-id")
analytics.track(&"screen_opened", {
	"screen": "inventory",
})

# endpoint_url 为空时为本地 dry-run；配置后会按 JSON 批量 POST
analytics.config.endpoint_url = "https://example.com/events"
analytics.flush()
```

如果项目需要接入自定义 SDK 或不同服务端协议，可以使用传输 hook，而不是修改工具内部：

```gdscript
analytics.payload_builder = func(batch: Array) -> Dictionary:
	return {
		"events": batch,
		"schema": "v1",
	}

analytics.transport_callback = func(payload: Dictionary) -> Dictionary:
	# 项目层自行发送 payload，也可以只写入本地调试管线。
	return { "success": true, "accepted": (payload["events"] as Array).size() }
```

配置项放在 `GFAnalyticsConfig` 中，包括 `endpoint_url`、`headers`、`batch_size`、`max_queue_size`、`flush_interval_seconds`、`app_version`、`persist_client_id`、`client_id_storage_path` 和 `flush_on_shutdown`。自定义 `headers` 会过滤空 header 名和包含 CR/LF 的键值，避免把外部字符串直接拼成非法 HTTP 头。`transport_callback` 是同步 hook，必须直接返回结果字典；如需异步 SDK，应在项目层做缓冲，再把 GF 队列视为本地入口。项目层仍然负责决定事件命名、字段规范和隐私策略。

flush 失败时，本批事件会按原顺序放回队列前端，并发出 `flush_failed` / `flush_completed`；失败回灌后仍会重新执行 `max_queue_size` 限制，避免离线或接口故障时无限占用内存。正常 `track()` 超过上限时会丢弃最早事件；失败批次回灌超过上限时会优先保留刚失败的批次。关闭时的 `flush_on_shutdown` 是尽力触发，不会等待 HTTP 请求完成；关键埋点应由项目层在重要流程点主动 `flush()` 并监听结果。`capture_context()` 只采集平台、Godot 版本、屏幕尺寸、语言和时区等通用信息，涉及账号、设备指纹或隐私字段的内容必须由项目层显式添加。


## 远程文本与 JSON 缓存 (`GFRemoteCacheUtility`)

**应用场景：** 当项目需要拉取公告、轻量配置、远程索引或工具数据时，可以使用该工具统一处理 HTTP 请求、本地 TTL 缓存和失败回退。它只处理通用文本/JSON，不绑定具体业务结构。

```gdscript
var remote_cache := Gf.get_utility(GFRemoteCacheUtility) as GFRemoteCacheUtility
remote_cache.default_ttl_seconds = 3600

remote_cache.fetch_json("https://example.com/config.json", func(result: Dictionary) -> void:
	if not bool(result["success"]):
		push_warning(result["error"])
		return

	var data := result["data"] as Dictionary
	print(data)
)
```

`fetch_text()` 与 `fetch_json()` 的回调都接收统一结果字典：`success`、`url`、`content`、`data`、`from_cache`、`stale`、`response_code` 和 `error`。当强制刷新失败但本地仍有旧缓存时，结果会以 `success = true`、`from_cache = true`、`stale = true` 返回，项目层可以自行决定是否展示旧内容或提示网络状态。

缓存文件位于 `user://<cache_dir_name>/`，文件名由 URL、请求格式和 headers 组合出的缓存 key 的 MD5 派生，写入时会先提交到临时文件，再替换最终缓存文件，避免刷新中断污染旧缓存。超过 `max_cache_entries` 后按修改时间删除最旧条目。项目可以用 `has_valid_cache()` / `get_cached_text()` 只读文本缓存，用 `remove_cache()` 清理单个缓存 key，用 `clear_cache()` 清空整个缓存目录；需要语言、账号态或 AB 分组等自定义维度时，可以提供 `cache_key_builder`。JSON 请求会先解析成功再写入缓存，避免远程服务短暂返回坏 JSON 后污染 TTL 缓存；强制刷新失败或新 JSON 解析失败但本地有可用旧缓存时，仍可返回 `stale = true` 的旧内容。

该工具串行处理内部请求队列，适合轻量公告和配置拉取，不适合作为大文件下载器或实时 API 客户端。相同缓存 key 的并发请求会合并到同一个 HTTP 请求；`max_pending_requests` 限制等待队列长度，`cancel(url, headers, format)` 可取消匹配请求，`cancel_all()` 可清空等待和当前请求。`get_debug_snapshot()` 会报告缓存目录、TTL、队列上限、队列数量和当前 active URL，便于和 `GFDiagnosticsUtility` 一起定位远程配置刷新问题。缓存写入仍使用同步 `FileAccess`，项目不应把它用于大文件下载或每帧高频刷新。


## 通用 HTTP 请求构建 (`GFHttpRequestBuilder` / `GFHttpResponse` / `GFAsyncBatch`)

当项目需要轻量构建 HTTP 请求，但不希望把具体 API、鉴权、账号或服务端字段写进框架时，可以用 `GFHttpRequestBuilder` 整理 URL、query、headers、body、timeout 和响应解析策略。它既能输出普通请求字典，供项目自己的传输层使用，也能用 Godot `HTTPRequest` 直接执行：

```gdscript
var builder := GFHttpRequestBuilder.new()
builder.set_url("https://example.com/config")
builder.add_query_parameter("locale", "zh-CN")
builder.set_header("Accept", "application/json")
builder.set_parse_mode(GFHttpRequestBuilder.ParseMode.JSON)

var response := builder.execute(get_tree().root)
response.completed.connect(func(result: GFHttpResponse) -> void:
	if not result.is_successful():
		push_warning(result.error)
		return
	print(result.data)
)
```

`GFHttpResponse` 统一表达 pending、completed、failed 和 cancelled 状态，并保留状态码、headers、文本、原始 bytes、解析数据、错误和 metadata。`GFAsyncBatch` 可等待一组响应或手动标记的异步条目完成，适合编辑器工具、配置刷新、轻量诊断命令或项目自己的 SDK 包装层聚合结果。GF 不内置任何远端服务、重试策略、签名、分页或业务 DTO；这些策略应放在项目层或可选扩展中。


## 通用请求 Outbox (`GFRequestEnvelope` / `GFRequestOutboxUtility`)

当项目需要把失败请求先落到本地、稍后再由自己的网络层或平台 SDK 重放时，可以注册 `GFRequestOutboxUtility`。它只负责请求描述、持久化、重试次数、重试延迟和失败列表，不内置任何账号、排行榜、云存档、鉴权或业务协议。

```gdscript
var outbox := Gf.get_utility(GFRequestOutboxUtility) as GFRequestOutboxUtility
outbox.transport_callback = func(envelope: GFRequestEnvelope) -> Dictionary:
	# 项目层自行发送 envelope，可以走 HTTP、平台 SDK 或本地工具桥。
	return { "ok": true }

outbox.enqueue_request(HTTPClient.METHOD_POST, "https://example.com/api/events", {
	"event": "checkpoint",
	"position": Vector2(12.0, 4.0),
})

await outbox.replay()
```

`GFRequestEnvelope` 保存 `method`、`url`、`body`、`headers`、`idempotency_key`、`attempt_count`、`max_attempts`、`last_error` 和 `metadata`。队列写入 `storage_path` 时会使用 `GFVariantJsonCodec` 的类型化 JSON codec，因此 `Vector2`、`Color`、PackedArray 等常见 Godot 值可以作为普通载荷保存。`transport_callback` 可以同步返回结果，也可以返回会发出结果值的 `Signal`；结果为 `{ "ok": true }` 或 `{ "success": true }` 时请求会从等待队列移除；失败时按 `retry_delays_msec` 安排下一次尝试，耗尽次数后可进入失败列表。

这个工具适合做“通用离线 outbox”边界，例如分析事件、自定义远程配置写入、轻量状态提交或编辑器工具请求。它不替项目决定哪些请求可重放、是否幂等、如何签名、如何脱敏、如何处理冲突；这些策略应放在项目自己的 `transport_callback`、`replay_filter` 或更高层同步系统中。
