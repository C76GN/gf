## GFMutationBatch: 通用变更批次。
##
## 把一组 Callable 作为可提交、可回滚的批次执行。它只管理执行顺序、
## 结果归一化和回滚栈，不绑定资源、存档、网络或编辑器事务。
class_name GFMutationBatch
extends RefCounted


# --- 信号 ---

## 操作加入批次后发出。
## @param operation_id: 操作标识。
signal operation_added(operation_id: int)

## 单个操作提交成功后发出。
## @param operation_id: 操作标识。
## @param result: 操作结果。
signal operation_committed(operation_id: int, result: Dictionary)

## 批次提交结束后发出。
## @param summary: 提交摘要。
signal batch_committed(summary: Dictionary)

## 已提交操作回滚结束后发出。
## @param summary: 回滚摘要。
signal batch_rolled_back(summary: Dictionary)

## 批次清空后发出。
signal cleared


# --- 公共变量 ---

## 提交遇到失败时是否停止后续操作。
var stop_on_error: bool = true

## 全部提交成功后是否自动清空 committed 栈。
var auto_clear_committed_on_success: bool = false


# --- 私有变量 ---

var _pending_operations: Array[Dictionary] = []
var _committed_operations: Array[Dictionary] = []
var _next_operation_id: int = 1


# --- 公共方法 ---

## 添加一个批次操作。
## @param operation: 提交回调。
## @param rollback: 可选回滚回调。
## @param metadata: 操作元数据。
## @return 操作标识；失败返回 -1。
func add_operation(operation: Callable, rollback: Callable = Callable(), metadata: Dictionary = {}) -> int:
	if not operation.is_valid():
		return -1

	var operation_id := _next_operation_id
	_next_operation_id += 1
	_pending_operations.append({
		"operation_id": operation_id,
		"operation": operation,
		"rollback": rollback,
		"metadata": metadata.duplicate(true),
	})
	operation_added.emit(operation_id)
	return operation_id


## 提交待处理操作。
## @param max_operations: 最多提交数量；小于 0 表示处理全部。
## @return 提交摘要。
func commit(max_operations: int = -1) -> Dictionary:
	var committed_count := 0
	var failed_count := 0
	var errors: Array[Dictionary] = []
	while not _pending_operations.is_empty() and (max_operations < 0 or committed_count + failed_count < max_operations):
		var entry := _pending_operations[0] as Dictionary
		var operation: Callable = entry.get("operation", Callable())
		var operation_result := _normalize_operation_result(operation.call(), entry)
		if bool(operation_result.get("ok", false)):
			_pending_operations.remove_at(0)
			_committed_operations.append(entry)
			committed_count += 1
			operation_committed.emit(int(entry.get("operation_id", -1)), operation_result)
			continue

		failed_count += 1
		errors.append(operation_result)
		if stop_on_error:
			break
		_pending_operations.remove_at(0)

	var summary := _make_commit_summary(committed_count, failed_count, errors)
	if bool(summary.get("ok", false)) and auto_clear_committed_on_success:
		_committed_operations.clear()
	batch_committed.emit(summary)
	return summary


## 回滚已提交操作。
## @param max_operations: 最多回滚数量；小于 0 表示回滚全部。
## @return 回滚摘要。
func rollback_committed(max_operations: int = -1) -> Dictionary:
	var rolled_back_count := 0
	var failed_count := 0
	var skipped_count := 0
	var errors: Array[Dictionary] = []
	while not _committed_operations.is_empty() and (max_operations < 0 or rolled_back_count + failed_count + skipped_count < max_operations):
		var entry := _committed_operations.pop_back() as Dictionary
		var rollback: Callable = entry.get("rollback", Callable())
		if not rollback.is_valid():
			skipped_count += 1
			continue

		var rollback_result := _normalize_operation_result(rollback.call(), entry)
		if bool(rollback_result.get("ok", false)):
			rolled_back_count += 1
		else:
			failed_count += 1
			errors.append(rollback_result)
			if stop_on_error:
				_committed_operations.append(entry)
				break

	var summary := {
		"ok": failed_count == 0,
		"rolled_back_count": rolled_back_count,
		"failed_count": failed_count,
		"skipped_count": skipped_count,
		"pending_count": _pending_operations.size(),
		"committed_count": _committed_operations.size(),
		"errors": errors,
	}
	batch_rolled_back.emit(summary)
	return summary


## 清空批次。
func clear() -> void:
	_pending_operations.clear()
	_committed_operations.clear()
	cleared.emit()


## 获取待处理操作数量。
## @return 待处理操作数量。
func get_pending_count() -> int:
	return _pending_operations.size()


## 获取已提交操作数量。
## @return 已提交操作数量。
func get_committed_count() -> int:
	return _committed_operations.size()


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"pending_count": _pending_operations.size(),
		"committed_count": _committed_operations.size(),
		"next_operation_id": _next_operation_id,
		"stop_on_error": stop_on_error,
		"auto_clear_committed_on_success": auto_clear_committed_on_success,
	}


# --- 私有/辅助方法 ---

func _normalize_operation_result(raw_result: Variant, entry: Dictionary) -> Dictionary:
	var metadata := (entry.get("metadata", {}) as Dictionary).duplicate(true) if entry.get("metadata", {}) is Dictionary else {}
	if raw_result is Dictionary:
		var data := raw_result as Dictionary
		if data.has("ok"):
			return {
				"ok": bool(data.get("ok", false)),
				"operation_id": int(entry.get("operation_id", -1)),
				"value": data.get("value", data.get("data", null)),
				"error": String(data.get("error", "")),
				"metadata": metadata,
			}
	return {
		"ok": true,
		"operation_id": int(entry.get("operation_id", -1)),
		"value": raw_result,
		"error": "",
		"metadata": metadata,
	}


func _make_commit_summary(committed_count: int, failed_count: int, errors: Array[Dictionary]) -> Dictionary:
	return {
		"ok": failed_count == 0,
		"committed_count": committed_count,
		"failed_count": failed_count,
		"pending_count": _pending_operations.size(),
		"stored_committed_count": _committed_operations.size(),
		"errors": errors,
	}
