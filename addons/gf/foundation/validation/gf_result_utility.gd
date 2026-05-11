## GFResultUtility: 通用结果字典常量与轻量工厂。
##
## 用于统一 `ok`、`data`、`metadata`、`error` 等常见结果字典字段，
## 便于 Utility 和底层服务逐步收敛返回结构，同时保持字典兼容。
class_name GFResultUtility
extends RefCounted


# --- 常量 ---

const KEY_OK: String = "ok"
const KEY_DATA: String = "data"
const KEY_METADATA: String = "metadata"
const KEY_ERROR: String = "error"
const KEY_ERRORS: String = "errors"
const KEY_INTEGRITY_VALID: String = "integrity_valid"


# --- 公共方法 ---

## 创建结果字典，并写入 ok 字段。
## @param ok: 操作是否成功。
## @param fields: 需要合并到结果中的附加字段。
## @return 新结果字典。
static func make(ok: bool, fields: Dictionary = {}) -> Dictionary:
	var result := fields.duplicate(false)
	result[KEY_OK] = ok
	return result


## 创建成功结果字典。
## @param fields: 需要合并到结果中的附加字段。
## @return 新结果字典。
static func make_success(fields: Dictionary = {}) -> Dictionary:
	return make(true, fields)


## 创建失败结果字典，并写入 error 字段。
## @param error: 错误说明。
## @param fields: 需要合并到结果中的附加字段。
## @return 新结果字典。
static func make_failure(error: String = "", fields: Dictionary = {}) -> Dictionary:
	var result := make(false, fields)
	result[KEY_ERROR] = error
	return result
