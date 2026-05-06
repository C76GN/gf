## GFSavePipelineContext: 存档图流程上下文。
##
## 在一次 gather/apply 操作中收集通用事件、警告、错误与共享数据。
## 上下文通过调用者传入的 context 字典传播，不要求存档载荷写死任何字段。
class_name GFSavePipelineContext
extends RefCounted


# --- 常量 ---

const GFSavePipelineEventBase = preload("res://addons/gf/extensions/save/gf_save_pipeline_event.gd")


# --- 公共变量 ---

## 当前操作类型，如 gather 或 apply。
var operation: StringName = &""

## 根 Scope key。
var root_scope_key: StringName = &""

## 流程共享数据。项目层可写入自己的临时状态。
var shared: Dictionary = {}

## 流程事件列表。
var events: Array[GFSavePipelineEventBase] = []

## 通用警告信息。
var warnings: PackedStringArray = PackedStringArray()

## 通用错误信息。
var errors: PackedStringArray = PackedStringArray()

## 开始时间。
var started_at_msec: int = 0

## 结束时间。
var finished_at_msec: int = 0


# --- Godot 生命周期方法 ---

func _init(
	p_operation: StringName = &"",
	p_root_scope_key: StringName = &"",
	p_shared: Dictionary = {}
) -> void:
	begin_operation(p_operation, p_root_scope_key, p_shared)


# --- 公共方法 ---

## 开始一次流程操作。
## @param p_operation: 操作类型。
## @param p_root_scope_key: 根 Scope key。
## @param p_shared: 初始共享数据。
## @return 当前上下文。
func begin_operation(
	p_operation: StringName,
	p_root_scope_key: StringName = &"",
	p_shared: Dictionary = {}
) -> GFSavePipelineContext:
	operation = p_operation
	root_scope_key = p_root_scope_key
	shared = p_shared.duplicate(true)
	events.clear()
	warnings.clear()
	errors.clear()
	started_at_msec = Time.get_ticks_msec()
	finished_at_msec = 0
	return self


## 记录流程事件。
## @param stage: 阶段标识。
## @param scope: 可选 Scope。
## @param source: 可选 Source。
## @param message: 调试消息。
## @param payload: 附加载荷。
## @param severity: 严重级别。
## @return 新事件。
func record_event(
	stage: StringName,
	scope: Object = null,
	source: Object = null,
	message: String = "",
	payload: Dictionary = {},
	severity: StringName = &"info"
) -> GFSavePipelineEventBase:
	var event := GFSavePipelineEventBase.new().configure(stage, scope, source, message, payload, severity)
	events.append(event)
	return event


## 记录警告并同步生成 warning 事件。
## @param message: 警告内容。
## @param payload: 附加载荷。
func add_warning(message: String, payload: Dictionary = {}) -> void:
	warnings.append(message)
	record_event(&"pipeline_warning", null, null, message, payload, &"warning")


## 记录错误并同步生成 error 事件。
## @param message: 错误内容。
## @param payload: 附加载荷。
func add_error(message: String, payload: Dictionary = {}) -> void:
	errors.append(message)
	record_event(&"pipeline_error", null, null, message, payload, &"error")


## 标记流程结束。
func finish() -> void:
	finished_at_msec = Time.get_ticks_msec()


## 当前流程是否已结束。
## @return 已结束返回 true。
func is_finished() -> bool:
	return finished_at_msec > 0


## 获取耗时毫秒。
## @return 耗时。
func get_elapsed_msec() -> int:
	var end_msec := finished_at_msec if finished_at_msec > 0 else Time.get_ticks_msec()
	return maxi(end_msec - started_at_msec, 0)


## 转换为 Dictionary。
## @param include_events: 是否包含事件列表。
## @return 上下文字典。
func to_dict(include_events: bool = true) -> Dictionary:
	var result := {
		"operation": operation,
		"root_scope_key": root_scope_key,
		"shared": shared.duplicate(true),
		"warnings": warnings,
		"errors": errors,
		"started_at_msec": started_at_msec,
		"finished_at_msec": finished_at_msec,
		"elapsed_msec": get_elapsed_msec(),
		"event_count": events.size(),
	}
	if include_events:
		var event_dicts: Array[Dictionary] = []
		for event: GFSavePipelineEventBase in events:
			if event != null:
				event_dicts.append(event.to_dict())
		result["events"] = event_dicts
	return result
