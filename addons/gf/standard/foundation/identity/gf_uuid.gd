## GFUuid: 通用 UUID 生成与校验工具。
##
## 只处理 RFC 4122 形态的字符串标识，不绑定存档、分析、网络请求或编辑器资源语义。
## v4 适合匿名随机标识，v7 适合需要大致按生成时间排序的标识。
## [br]
## @api public
## [br]
## @category value_object
## [br]
## @since 3.19.0
class_name GFUuid
extends RefCounted


# --- 常量 ---

## UUID 字节长度。
## [br]
## @api public
const BYTE_COUNT: int = 16

## UUID 规范字符串长度。
## [br]
## @api public
const CANONICAL_LENGTH: int = 36

const _HEX_CHARS: String = "0123456789abcdef"
const _MAX_UNIX_TIME_MSEC: int = 281474976710655


# --- 公共方法 ---

## 生成随机 UUID v4。
## [br]
## @api public
## [br]
## @return 小写 canonical UUID 字符串。
static func generate_v4() -> String:
	var bytes: PackedByteArray = _generate_random_bytes()
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	return _format_uuid_bytes(bytes)


## 生成时间有序 UUID v7。
## [br]
## @api public
## [br]
## @param unix_time_msec: Unix epoch 毫秒；小于 0 时使用系统当前时间。
## [br]
## @return 小写 canonical UUID 字符串。
static func generate_v7(unix_time_msec: int = -1) -> String:
	var timestamp_msec: int = _resolve_unix_time_msec(unix_time_msec)
	var bytes: PackedByteArray = _generate_random_bytes()
	bytes[0] = (timestamp_msec >> 40) & 0xff
	bytes[1] = (timestamp_msec >> 32) & 0xff
	bytes[2] = (timestamp_msec >> 24) & 0xff
	bytes[3] = (timestamp_msec >> 16) & 0xff
	bytes[4] = (timestamp_msec >> 8) & 0xff
	bytes[5] = timestamp_msec & 0xff
	bytes[6] = (bytes[6] & 0x0f) | 0x70
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	return _format_uuid_bytes(bytes)


## 判断字符串是否为 canonical UUID。
## [br]
## @api public
## [br]
## @param value: 待校验字符串。
## [br]
## @param version: 可选版本过滤；0 表示接受任意版本。
## [br]
## @return 字符串符合 canonical UUID 形态且版本匹配时返回 true。
static func is_valid(value: String, version: int = 0) -> bool:
	var normalized: String = value.strip_edges().to_lower()
	if normalized.length() != CANONICAL_LENGTH:
		return false
	if version < 0 or version > 15:
		return false
	if normalized.substr(8, 1) != "-":
		return false
	if normalized.substr(13, 1) != "-":
		return false
	if normalized.substr(18, 1) != "-":
		return false
	if normalized.substr(23, 1) != "-":
		return false

	for index: int in range(CANONICAL_LENGTH):
		if [8, 13, 18, 23].has(index):
			continue
		if not _is_hex_char(normalized.substr(index, 1)):
			return false

	if version > 0 and normalized.substr(14, 1) != _hex_nibble(version):
		return false

	var variant: String = normalized.substr(19, 1)
	return ["8", "9", "a", "b"].has(variant)


# --- 私有/辅助方法 ---

static func _generate_random_bytes() -> PackedByteArray:
	var crypto: Crypto = Crypto.new()
	return crypto.generate_random_bytes(BYTE_COUNT)


static func _resolve_unix_time_msec(unix_time_msec: int) -> int:
	if unix_time_msec < 0:
		return GFVariantData.to_int(floor(Time.get_unix_time_from_system() * 1000.0))
	if unix_time_msec > _MAX_UNIX_TIME_MSEC:
		return _MAX_UNIX_TIME_MSEC
	return unix_time_msec


static func _format_uuid_bytes(bytes: PackedByteArray) -> String:
	var hex: String = bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12),
	]


static func _is_hex_char(character: String) -> bool:
	return _HEX_CHARS.find(character) >= 0


static func _hex_nibble(value: int) -> String:
	return _HEX_CHARS.substr(value & 0x0f, 1)
