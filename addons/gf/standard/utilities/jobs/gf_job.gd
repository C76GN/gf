## GFJob: 通用异步/分帧任务记录。
##
## 只保存任务状态、进度、输入数据、结果和错误文本，不绑定具体业务。
class_name GFJob
extends RefCounted


# --- 枚举 ---

enum Status {
	WAITING,
	ACTIVE,
	COMPLETED,
	FAILED,
	CANCELLED,
}


# --- 公共变量 ---

## 任务 ID。
var job_id: StringName = &""

## 队列名。
var queue_name: StringName = &"default"

## 当前状态。
var status: Status = Status.WAITING

## 任务输入数据。框架不解释该字段。
var data: Variant = null

## 任务结果。框架不解释该字段。
var result: Variant = null

## 错误文本。
var error_message: String = ""

## 进度，范围建议为 0.0 到 1.0。
var progress: float = 0.0

## 项目自定义元数据。框架不解释该字段。
var metadata: Dictionary = {}

## 创建时间。
var created_msec: int = 0

## 开始时间。
var started_msec: int = 0

## 结束时间。
var finished_msec: int = 0


# --- 公共方法 ---

## 当前任务是否已经进入终态。
## @return 已完成、失败或取消时返回 true。
func is_finished() -> bool:
	return status == Status.COMPLETED or status == Status.FAILED or status == Status.CANCELLED


## 转换为 Dictionary。
## @return 任务字典。
func to_dict() -> Dictionary:
	return {
		"job_id": String(job_id),
		"queue_name": String(queue_name),
		"status": status,
		"status_name": status_name(status),
		"progress": progress,
		"error_message": error_message,
		"metadata": metadata.duplicate(true),
		"created_msec": created_msec,
		"started_msec": started_msec,
		"finished_msec": finished_msec,
		"has_result": result != null,
	}


## 获取状态名称。
## @param value: 状态枚举值。
## @return 状态名称。
static func status_name(value: Status) -> String:
	match value:
		Status.WAITING:
			return "waiting"
		Status.ACTIVE:
			return "active"
		Status.COMPLETED:
			return "completed"
		Status.FAILED:
			return "failed"
		Status.CANCELLED:
			return "cancelled"
	return "unknown"
