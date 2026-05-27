# Dialogue API

Module: `extensions/dialogue`

## Classes

- [`GFDialogueContext`](#gfdialoguecontext)
- [`GFDialogueLine`](#gfdialogueline)
- [`GFDialogueResource`](#gfdialogueresource)
- [`GFDialogueResponse`](#gfdialogueresponse)
- [`GFDialogueRunner`](#gfdialoguerunner)

## GFDialogueContext

- Path: `addons/gf/extensions/dialogue/runtime/gf_dialogue_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFDialogueContext: 通用对话运行上下文。 上下文保存运行时值，并把条件判断、mutation 和文本解析委托给项目提供的 Callable。框架只负责规范调用与结果包装。

### Properties

#### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

运行时值表。字段含义由项目决定。

Schemas:

- `values`: 项目自定义运行时值 Dictionary；键通常为 StringName，值由项目决定。

#### `condition_handler`

- API: `public`

```gdscript
var condition_handler: Callable = Callable()
```

条件处理器，建议签名为 func(condition_id, payload, subject, context) -> Variant。

#### `mutation_handler`

- API: `public`

```gdscript
var mutation_handler: Callable = Callable()
```

mutation 处理器，建议签名为 func(mutation_id, payload, subject, context) -> Variant。

#### `text_resolver`

- API: `public`

```gdscript
var text_resolver: Callable = Callable()
```

文本解析器，建议签名为 func(text, subject, context) -> String。

### Methods

#### `set_architecture`

- API: `public`

```gdscript
func set_architecture(architecture: GFArchitecture) -> GFDialogueContext:
```

设置架构引用。

Parameters:

| Name | Description |
|---|---|
| `architecture` | 架构实例。 |

Returns: 当前上下文。

#### `get_architecture`

- API: `public`

```gdscript
func get_architecture() -> GFArchitecture:
```

获取架构引用。

Returns: 架构实例；不存在时返回 null。

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> GFDialogueContext:
```

写入上下文值。

Parameters:

| Name | Description |
|---|---|
| `key` | 值键。 |
| `value` | 值。 |

Returns: 当前上下文。

Schemas:

- `value`: 要写入 values 的任意项目值。

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取上下文值。

Parameters:

| Name | Description |
|---|---|
| `key` | 值键。 |
| `default_value` | 默认值。 |

Returns: 当前值或默认值。

Schemas:

- `default_value`: key 缺失时返回的任意默认值。
- `return`: values 中的项目值，或传入的 default_value。

#### `check_condition`

- API: `public`

```gdscript
func check_condition(condition_id: StringName, payload: Variant = null, subject: Variant = null) -> Dictionary:
```

检查条件。

Parameters:

| Name | Description |
|---|---|
| `condition_id` | 条件 ID。 |
| `payload` | 条件载荷。 |
| `subject` | 触发条件的行、响应或项目对象。 |

Returns: 结构化结果。

Schemas:

- `payload`: 条件处理器接收的任意项目载荷；框架只透传。
- `subject`: GFDialogueLine、GFDialogueResponse 或项目传入的任意条件主体。
- `return`: 包含 ok、reason 和 value 等字段的 Dictionary；当处理器返回 Dictionary 时会保留调用方字段。

#### `apply_mutation`

- API: `public`

```gdscript
func apply_mutation(mutation_id: StringName, payload: Variant = null, subject: Variant = null) -> Dictionary:
```

请求执行 mutation。

Parameters:

| Name | Description |
|---|---|
| `mutation_id` | mutation ID。 |
| `payload` | mutation 载荷。 |
| `subject` | 触发 mutation 的行、响应或项目对象。 |

Returns: 结构化结果。

Schemas:

- `payload`: mutation 处理器接收的任意项目载荷；框架只透传。
- `subject`: GFDialogueLine、GFDialogueResponse 或项目传入的任意 mutation 主体。
- `return`: 包含 ok、reason 和 value 等字段的 Dictionary；当处理器返回 Dictionary 时会保留调用方字段。

#### `resolve_text`

- API: `public`

```gdscript
func resolve_text(text: String, subject: Variant = null) -> String:
```

解析文本。

Parameters:

| Name | Description |
|---|---|
| `text` | 原始文本或文本键。 |
| `subject` | 文本所属行、响应或项目对象。 |

Returns: 解析后的文本。

Schemas:

- `subject`: GFDialogueLine、GFDialogueResponse 或项目传入的任意文本主体。

#### `serialize_values`

- API: `public`

```gdscript
func serialize_values() -> Dictionary:
```

序列化运行值。

Returns: 值表副本。

Schemas:

- `return`: values 的深拷贝 Dictionary。

#### `deserialize_values`

- API: `public`

```gdscript
func deserialize_values(data: Dictionary) -> void:
```

恢复运行值。

Parameters:

| Name | Description |
|---|---|
| `data` | 值表。 |

Schemas:

- `data`: serialize_values() 返回的运行时值 Dictionary。

## GFDialogueLine

- Path: `addons/gf/extensions/dialogue/resources/gf_dialogue_line.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFDialogueLine: 通用对话流程行。 行可以表示可展示文本、跳转、mutation 请求或结束点。它不规定剧本语法、 对话框 UI、角色表或项目状态字段。

### Enums

#### `LineKind`

- API: `public`

```gdscript
enum LineKind { ## 可展示文本行。 TEXT, ## 请求执行上下文 mutation 后继续。 MUTATION, ## 直接跳转到另一行。 JUMP, ## 结束当前对话。 END, }
```

对话行类型。

### Properties

#### `line_id`

- API: `public`

```gdscript
var line_id: StringName = &""
```

行 ID。

#### `kind`

- API: `public`

```gdscript
var kind: LineKind = LineKind.TEXT
```

行类型。

#### `speaker_id`

- API: `public`

```gdscript
var speaker_id: StringName = &""
```

说话者 ID 或项目自定义主体键。

#### `text`

- API: `public`

```gdscript
var text: String = ""
```

文本或项目自定义文本键。

#### `next_line_id`

- API: `public`

```gdscript
var next_line_id: StringName = &""
```

默认后继行 ID。

#### `jump_line_id`

- API: `public`

```gdscript
var jump_line_id: StringName = &""
```

跳转行 ID。`kind == JUMP` 时优先使用。

#### `condition_id`

- API: `public`

```gdscript
var condition_id: StringName = &""
```

条件 ID。为空表示不需要条件判断。

#### `condition_payload`

- API: `public`

```gdscript
var condition_payload: Variant = null
```

条件载荷。框架只透传给上下文处理器。

Schemas:

- `condition_payload`: 条件处理器接收的任意项目载荷；框架只透传，不解释其中结构。

#### `fallback_line_id`

- API: `public`

```gdscript
var fallback_line_id: StringName = &""
```

条件不通过时的后继行 ID。为空时由 Runner 按策略跳过或结束。

#### `mutation_id`

- API: `public`

```gdscript
var mutation_id: StringName = &""
```

mutation ID。`kind == MUTATION` 时由 Runner 请求上下文处理。

#### `mutation_payload`

- API: `public`

```gdscript
var mutation_payload: Variant = null
```

mutation 载荷。框架只透传给上下文处理器。

Schemas:

- `mutation_payload`: mutation 处理器接收的任意项目载荷；框架只透传，不解释其中结构。

#### `responses`

- API: `public`

```gdscript
var responses: Array[GFDialogueResponse] = []
```

响应选项。

#### `tags`

- API: `public`

```gdscript
var tags: PackedStringArray = PackedStringArray()
```

语义标签。框架不解释标签含义。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `has_responses`

- API: `public`

```gdscript
func has_responses() -> bool:
```

检查行是否有响应。

Returns: 存在响应时返回 true。

#### `get_available_responses`

- API: `public`

```gdscript
func get_available_responses(context: GFDialogueContext = null) -> Array[GFDialogueResponse]:
```

获取可用响应。

Parameters:

| Name | Description |
|---|---|
| `context` | 对话上下文。 |

Returns: 可用响应列表。

#### `get_response`

- API: `public`

```gdscript
func get_response(response_id: StringName) -> GFDialogueResponse:
```

按 ID 获取响应。

Parameters:

| Name | Description |
|---|---|
| `response_id` | 响应 ID。 |

Returns: 响应；不存在时返回 null。

#### `can_enter`

- API: `public`

```gdscript
func can_enter(context: GFDialogueContext) -> bool:
```

检查行是否可进入。

Parameters:

| Name | Description |
|---|---|
| `context` | 对话上下文。 |

Returns: 可进入时返回 true。

#### `get_default_next_line_id`

- API: `public`

```gdscript
func get_default_next_line_id() -> StringName:
```

获取默认后继行 ID。

Returns: 后继行 ID。

#### `duplicate_line`

- API: `public`

```gdscript
func duplicate_line() -> GFDialogueLine:
```

创建深拷贝。

Returns: 行副本。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 行快照。

Schemas:

- `return`: 包含 line_id、kind、speaker_id、text、next_line_id、jump_line_id、condition_id、condition_payload、fallback_line_id、mutation_id、mutation_payload、responses、tags 和 metadata 字段的 Dictionary。

## GFDialogueResource

- Path: `addons/gf/extensions/dialogue/resources/gf_dialogue_resource.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFDialogueResource: 通用对话资源。 资源只保存对话行集合、起始行和自定义元数据。导入格式、剧本 DSL、 本地化表和编辑器 UI 均由项目或独立插件决定。

### Properties

#### `start_line_id`

- API: `public`

```gdscript
var start_line_id: StringName = &""
```

默认起始行 ID。

#### `lines`

- API: `public`

```gdscript
var lines: Array[GFDialogueLine] = []
```

对话行集合。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `set_line`

- API: `public`

```gdscript
func set_line(line: GFDialogueLine) -> void:
```

设置或追加对话行。

Parameters:

| Name | Description |
|---|---|
| `line` | 对话行。 |

#### `get_line`

- API: `public`

```gdscript
func get_line(line_id: StringName) -> GFDialogueLine:
```

获取对话行。

Parameters:

| Name | Description |
|---|---|
| `line_id` | 行 ID。 |

Returns: 对话行；不存在时返回 null。

#### `get_start_line`

- API: `public`

```gdscript
func get_start_line(override_line_id: StringName = &"") -> GFDialogueLine:
```

获取起始行。

Parameters:

| Name | Description |
|---|---|
| `override_line_id` | 可选覆盖起点。 |

Returns: 起始行；不存在时返回 null。

#### `get_line_ids`

- API: `public`

```gdscript
func get_line_ids() -> PackedStringArray:
```

获取全部行 ID。

Returns: 行 ID 列表。

#### `validate_resource`

- API: `public`

```gdscript
func validate_resource() -> Dictionary:
```

校验资源结构。

Returns: 兼容 GFValidationReportDictionary 的报告字典。

Schemas:

- `return`: GFValidationReportDictionary.finalize_report() 生成的 Dictionary，包含 ok、healthy、summary、issues、next_action、error_count、warning_count 和 issue_count 等字段。

#### `duplicate_dialogue`

- API: `public`

```gdscript
func duplicate_dialogue() -> GFDialogueResource:
```

创建深拷贝。

Returns: 对话资源副本。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 资源快照。

Schemas:

- `return`: 包含 start_line_id、lines 和 metadata 字段的 Dictionary；lines 为行快照字典数组。

## GFDialogueResponse

- Path: `addons/gf/extensions/dialogue/resources/gf_dialogue_response.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFDialogueResponse: 通用对话响应选项。 响应只描述玩家或系统可选择的一条后继路径，不决定 UI 样式、 输入方式、角色关系或业务副作用。

### Properties

#### `response_id`

- API: `public`

```gdscript
var response_id: StringName = &""
```

响应 ID。

#### `text`

- API: `public`

```gdscript
var text: String = ""
```

响应文本或项目自定义文本键。

#### `next_line_id`

- API: `public`

```gdscript
var next_line_id: StringName = &""
```

选择后跳转到的行 ID。为空时使用当前行的默认后继。

#### `condition_id`

- API: `public`

```gdscript
var condition_id: StringName = &""
```

条件 ID。为空表示不需要条件判断。

#### `condition_payload`

- API: `public`

```gdscript
var condition_payload: Variant = null
```

条件载荷。框架只透传给上下文处理器。

Schemas:

- `condition_payload`: 条件处理器接收的任意项目载荷；框架只透传，不解释其中结构。

#### `mutation_id`

- API: `public`

```gdscript
var mutation_id: StringName = &""
```

选择该响应时请求执行的通用 mutation ID。为空表示无副作用请求。

#### `mutation_payload`

- API: `public`

```gdscript
var mutation_payload: Variant = null
```

mutation 载荷。框架只透传给上下文处理器。

Schemas:

- `mutation_payload`: mutation 处理器接收的任意项目载荷；框架只透传，不解释其中结构。

#### `tags`

- API: `public`

```gdscript
var tags: PackedStringArray = PackedStringArray()
```

语义标签。框架不解释标签含义。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。

### Methods

#### `is_available`

- API: `public`

```gdscript
func is_available(context: GFDialogueContext) -> bool:
```

检查响应是否可用。

Parameters:

| Name | Description |
|---|---|
| `context` | 对话上下文。 |

Returns: 可用时返回 true。

#### `duplicate_response`

- API: `public`

```gdscript
func duplicate_response() -> GFDialogueResponse:
```

创建深拷贝。

Returns: 响应副本。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 响应快照。

Schemas:

- `return`: 包含 response_id、text、next_line_id、condition_id、condition_payload、mutation_id、mutation_payload、tags 和 metadata 字段的 Dictionary。

## GFDialogueRunner

- Path: `addons/gf/extensions/dialogue/runtime/gf_dialogue_runner.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDialogueRunner: 通用对话资源执行器。 Runner 只沿 GFDialogueResource 的行、响应、跳转、条件和 mutation 推进， 并发出结构化事件。显示、输入、存档和业务状态由项目层决定。

### Signals

#### `dialogue_started`

- API: `public`

```gdscript
signal dialogue_started(resource: GFDialogueResource)
```

对话开始时发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 对话资源。 |

#### `line_reached`

- API: `public`

```gdscript
signal line_reached(line: GFDialogueLine)
```

到达可展示文本行时发出。

Parameters:

| Name | Description |
|---|---|
| `line` | 当前行。 |

#### `mutation_requested`

- API: `public`

```gdscript
signal mutation_requested(mutation_id: StringName, payload: Variant, line: GFDialogueLine)
```

请求执行 mutation 时发出。

Parameters:

| Name | Description |
|---|---|
| `mutation_id` | mutation ID。 |
| `payload` | mutation 载荷。 |
| `line` | 当前行。 |

Schemas:

- `payload`: mutation 处理器接收的任意项目载荷；框架只透传。

#### `dialogue_ended`

- API: `public`

```gdscript
signal dialogue_ended(resource: GFDialogueResource)
```

对话结束时发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 对话资源。 |

#### `line_blocked`

- API: `public`

```gdscript
signal line_blocked(line_id: StringName, reason: StringName)
```

推进被阻止时发出。

Parameters:

| Name | Description |
|---|---|
| `line_id` | 被阻止的行 ID。 |
| `reason` | 原因。 |

### Properties

#### `max_steps_per_advance`

- API: `public`

```gdscript
var max_steps_per_advance: int = 1024
```

最多连续推进的非展示行数量，避免错误资源无限循环。

#### `skip_blocked_lines`

- API: `public`

```gdscript
var skip_blocked_lines: bool = true
```

条件不通过且没有 fallback 时，是否尝试跳到默认后继。

### Methods

#### `start`

- API: `public`

```gdscript
func start( resource: GFDialogueResource, start_line_id: StringName = &"", context: GFDialogueContext = null ) -> GFDialogueLine:
```

开始对话。

Parameters:

| Name | Description |
|---|---|
| `resource` | 对话资源。 |
| `start_line_id` | 可选起始行 ID。 |
| `context` | 可选上下文。 |

Returns: 到达的第一条可展示行；结束或失败时返回 null。

#### `advance`

- API: `public`

```gdscript
func advance(response_id: StringName = &"") -> GFDialogueLine:
```

推进对话。

Parameters:

| Name | Description |
|---|---|
| `response_id` | 可选响应 ID；非空时从当前行选择响应后推进。 |

Returns: 到达的下一条可展示行；结束或失败时返回 null。

#### `choose_response`

- API: `public`

```gdscript
func choose_response(response_id: StringName) -> GFDialogueLine:
```

选择当前行响应并推进。

Parameters:

| Name | Description |
|---|---|
| `response_id` | 响应 ID。 |

Returns: 到达的下一条可展示行；结束或失败时返回 null。

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

结束当前对话。

#### `get_current_line`

- API: `public`

```gdscript
func get_current_line() -> GFDialogueLine:
```

获取当前行。

Returns: 当前可展示行；没有时返回 null。

#### `get_available_responses`

- API: `public`

```gdscript
func get_available_responses() -> Array[GFDialogueResponse]:
```

获取当前可用响应。

Returns: 响应列表。

#### `is_running`

- API: `public`

```gdscript
func is_running() -> bool:
```

检查是否正在运行。

Returns: 运行中返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取运行快照。

Returns: 调试快照。

Schemas:

- `return`: 包含 is_running、current_line_id、has_resource 和 context_values 字段的 Dictionary。

