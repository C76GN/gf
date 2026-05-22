## GFResultDictionary: 通用结果字典常量与轻量工厂。
##
## 用于统一 `ok`、`data`、`metadata`、`error` 等常见结果字典字段，
## 便于运行时服务和底层模块逐步收敛返回结构，同时保持字典兼容。
## [br]
## @api public
## [br]
## @category value_object
## [br]
## @since 3.17.0
class_name GFResultDictionary
extends RefCounted


# --- 常量 ---

## 操作是否成功字段名。
## [br]
## @api public
const KEY_OK: String = "ok"

## 结果数据字段名。
## [br]
## @api public
const KEY_DATA: String = "data"

## 元数据字段名。
## [br]
## @api public
const KEY_METADATA: String = "metadata"

## 单个错误字段名。
## [br]
## @api public
const KEY_ERROR: String = "error"

## 多个错误字段名。
## [br]
## @api public
const KEY_ERRORS: String = "errors"

## 完整性校验结果字段名。
## [br]
## @api public
const KEY_INTEGRITY_VALID: String = "integrity_valid"


# --- 公共方法 ---

## 创建结果字典，并写入 ok 字段。
## [br]
## @api public
## [br]
## @param ok: 操作是否成功。
## [br]
## @param fields: 需要合并到结果中的附加字段。
## [br]
## @return 新结果字典。
## [br]
## @schema fields: Dictionary fields copied into the result.
## [br]
## @schema return: Dictionary with ok plus caller-provided fields.
static func make(ok: bool, fields: Dictionary = {}) -> Dictionary:
	var result := fields.duplicate(false)
	result[KEY_OK] = ok
	return result


## 创建成功结果字典。
## [br]
## @api public
## [br]
## @param fields: 需要合并到结果中的附加字段。
## [br]
## @return 新结果字典。
## [br]
## @schema fields: Dictionary fields copied into the result.
## [br]
## @schema return: Dictionary with ok set to true plus caller-provided fields.
static func make_success(fields: Dictionary = {}) -> Dictionary:
	return make(true, fields)


## 创建失败结果字典，并写入 error 字段。
## [br]
## @api public
## [br]
## @param error: 错误说明。
## [br]
## @param fields: 需要合并到结果中的附加字段。
## [br]
## @return 新结果字典。
## [br]
## @schema fields: Dictionary fields copied into the result.
## [br]
## @schema return: Dictionary with ok set to false, error, and caller-provided fields.
static func make_failure(error: String = "", fields: Dictionary = {}) -> Dictionary:
	var result := make(false, fields)
	result[KEY_ERROR] = error
	return result
