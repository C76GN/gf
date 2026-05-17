## GFBackgroundWorkTask: 后台工作记录。
##
## 保存后台工作状态、进度、输入数据、结果、错误文本和应用回调。
## 任务本身不直接启动线程；执行由 GFBackgroundWorkUtility 统一协调。
class_name GFBackgroundWorkTask
extends RefCounted


# --- 枚举 ---

enum Kind {
	CPU,
	IO,
	RESOURCE,
}

enum Status {
	QUEUED,
	RUNNING,
	APPLYING,
	COMPLETED,
	FAILED,
	CANCELLED,
}


# --- 公共变量 ---

## 工作 ID。
var work_id: StringName = &""

## 工作类型。
var kind: Kind = Kind.CPU

## 当前状态。
var status: Status = Status.QUEUED

## 优先级，数值越大越早从等待队列启动。
var priority: int = 0

## 工作输入数据。默认应只包含纯 Variant 数据。
var input_data: Variant = null

## 工作结果。线程任务返回值或资源加载结果会写入该字段。
var result: Variant = null

## 主线程应用回调的返回值。
var apply_result: Variant = null

## 错误文本。
var error_message: String = ""

## 进度，范围建议为 0.0 到 1.0。
var progress: float = 0.0

## 项目自定义元数据。框架不解释该字段。
var metadata: Dictionary = {}

## 资源加载路径，仅 RESOURCE 任务使用。
var resource_path: String = ""

## 资源类型提示，仅 RESOURCE 任务使用。
var resource_type_hint: String = ""

## 是否已请求取消。正在执行的线程任务不会被强行终止，只会在返回后转入取消终态。
var cancel_requested: bool = false

## 创建时间。
var created_msec: int = 0

## 开始时间。
var started_msec: int = 0

## 结束时间。
var finished_msec: int = 0


# --- 私有变量 ---

var _worker_callback: Callable = Callable()
var _apply_callback: Callable = Callable()


# --- 公共方法 ---

## 当前工作是否已经进入终态。
## @return 已完成、失败或取消时返回 true。
func is_finished() -> bool:
	return status == Status.COMPLETED or status == Status.FAILED or status == Status.CANCELLED


## 转换为 Dictionary。
## @return 工作字典。
func to_dict() -> Dictionary:
	return {
		"work_id": String(work_id),
		"kind": kind,
		"kind_name": kind_name(kind),
		"status": status,
		"status_name": status_name(status),
		"priority": priority,
		"progress": progress,
		"error_message": error_message,
		"metadata": metadata.duplicate(true),
		"resource_path": resource_path,
		"resource_type_hint": resource_type_hint,
		"cancel_requested": cancel_requested,
		"created_msec": created_msec,
		"started_msec": started_msec,
		"finished_msec": finished_msec,
		"has_result": result != null,
		"has_apply_result": apply_result != null,
	}


## 获取工作类型名称。
## @param value: 工作类型枚举值。
## @return 工作类型名称。
static func kind_name(value: Kind) -> String:
	match value:
		Kind.CPU:
			return "cpu"
		Kind.IO:
			return "io"
		Kind.RESOURCE:
			return "resource"
	return "unknown"


## 获取状态名称。
## @param value: 状态枚举值。
## @return 状态名称。
static func status_name(value: Status) -> String:
	match value:
		Status.QUEUED:
			return "queued"
		Status.RUNNING:
			return "running"
		Status.APPLYING:
			return "applying"
		Status.COMPLETED:
			return "completed"
		Status.FAILED:
			return "failed"
		Status.CANCELLED:
			return "cancelled"
	return "unknown"
