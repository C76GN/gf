# Variant 深拷贝与 JSON 转换

通用 Variant 基础件分为两个明确职责：`GFVariantData` 负责深拷贝、字典 / metadata 合并、options 读取、默认值合并和 Resource 可选复制；`GFVariantJsonCodec` 负责 JSON 友好的 Godot 类型转换。

它们都不依赖 `GFArchitecture`，适合存档、配置、校验报告、网络消息、命中上下文等需要复制集合但保留标量语义，或把 Godot 值转成纯数据的地方。

## 深拷贝与默认值

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
```

`GFVariantData.duplicate_variant()` 默认只深拷贝 `Dictionary` 和 `Array`，其他值保持原样返回；如果值中包含 `Object` 或 `Resource`，仍是引用语义。需要复制资源值时，可显式传入 `duplicate_variant(value, true, true)`。

## Metadata 与 Options

项目自定义 `metadata` 应保持普通 `Dictionary`，框架只复制、合并和透传，不解释业务键。需要合并时优先使用 `merge_metadata()`，避免不同模块手写深拷贝和嵌套合并规则：

```gdscript
var metadata := GFVariantData.duplicate_metadata(base_metadata)
GFVariantData.merge_metadata(metadata, {
	"source": "importer",
	"tags": ["preview"],
})
```

公共 API 的 `options` 字典应使用稳定字段名，并通过 `get_option_bool()`、`get_option_int()`、`get_option_float()`、`get_option_dictionary()` 等读取。读取器支持 `String` 与 `StringName` 键互查，集合返回副本，避免调用方和框架共享内部状态。

## JSON 兼容转换

```gdscript
var saved_position := GFVariantJsonCodec.vector2_to_array(Vector2(12.0, 4.0))
var position := GFVariantJsonCodec.array_to_vector2(saved_position)

var json_payload := GFVariantJsonCodec.variant_to_json_compatible({
	"position": Vector3(1.0, 2.0, 3.0),
	"tags": PackedStringArray(["state.ready"]),
})
var restored := GFVariantJsonCodec.json_compatible_to_variant(
	JSON.parse_string(JSON.stringify(json_payload))
) as Dictionary

var pretty_json := GFVariantJsonCodec.format_json_text("{\"b\":2,\"a\":1}", "  ", true)
var compact_json := GFVariantJsonCodec.compact_json_text(pretty_json)
```

`GFVariantJsonCodec.variant_to_json_compatible()` 会为 `Vector2/3/4`、整数向量、`Color`、`Rect2`、`Transform2D/3D`、`Basis`、`Quaternion`、`AABB`、`Plane`、`NodePath`、`StringName` 和常见 PackedArray 写入专用 `__gf_variant__` 类型标记，再由 `json_compatible_to_variant()` 恢复。

`parse_json_text()`、`format_json_text()` 和 `compact_json_text()` 面向已经是 JSON 文本的输入：它们先通过 Godot JSON 解析器确认文本有效，再返回解析值、格式化文本或去除非必要空白后的文本。解析失败时返回调用方提供的 fallback，不会把无效输入静默改写成空集合。

## 使用边界

普通整数在 JSON 安全范围内仍保持数字；超出 JSON 安全范围的 64 位整数会自动写成 `Int64` 类型标记，避免 Godot JSON 往返后丢失精度。只有 `__gf_variant__` 标记是字典唯一字段时才会被解码为 Godot 类型，因此普通业务字典里的 `type`、`value`、`_gf_type` 等字段会按普通数据保留。

默认普通 Dictionary 仍使用字符串键；如果确实需要保留非字符串键，可传 `{ "encode_dictionary_keys": true }`。JSON codec 遇到不支持的对象默认写成 `null`；需要持久化对象时，应在项目层先转换成资源路径、ID 或纯数据字典。
