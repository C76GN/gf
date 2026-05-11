## GFDownloadTask: 通用下载任务描述。
##
## 只记录下载 URL、目标路径、校验信息和运行状态，不假设下载内容的业务语义。
class_name GFDownloadTask
extends RefCounted


# --- 枚举 ---

## 下载任务状态。
enum Status {
	## 已加入队列。
	QUEUED,
	## 正在下载。
	RUNNING,
	## 已暂停，等待恢复。
	PAUSED,
	## 已完成。
	COMPLETED,
	## 已失败。
	FAILED,
	## 已取消。
	CANCELLED,
}


# --- 公共变量 ---

## 任务句柄。
var task_id: int = 0

## 下载 URL。
var url: String = ""

## 最终写入路径。
var target_path: String = ""

## 临时文件路径。
var temp_path: String = ""

## 分段续传文件路径。
var segment_path: String = ""

## HTTP 请求头。
var headers: PackedStringArray = PackedStringArray()

## 期望 SHA-256 校验值。为空时不校验。
var expected_sha256: String = ""

## 是否允许从临时文件续传。
var resume: bool = true

## 目标文件已存在时是否覆盖。
var overwrite: bool = true

## 项目层可附加的任务元数据。
var metadata: Dictionary = {}

## 当前任务状态。
var status: Status = Status.QUEUED

## 已接收字节数。
var received_bytes: int = 0

## 总字节数；未知时为 -1。
var total_bytes: int = -1

## 最近一次 HTTP 响应码。
var response_code: int = 0

## 失败或取消原因。
var error: String = ""


# --- 公共方法 ---

## 创建同内容拷贝。
## @return 新任务。
func duplicate_task() -> GFDownloadTask:
	var task: GFDownloadTask = GFDownloadTask.new()
	task.task_id = task_id
	task.url = url
	task.target_path = target_path
	task.temp_path = temp_path
	task.segment_path = segment_path
	task.headers = headers.duplicate()
	task.expected_sha256 = expected_sha256
	task.resume = resume
	task.overwrite = overwrite
	task.metadata = metadata.duplicate(true)
	task.status = status
	task.received_bytes = received_bytes
	task.total_bytes = total_bytes
	task.response_code = response_code
	task.error = error
	return task


## 导出任务状态字典。
## @return 任务字典。
func to_dict() -> Dictionary:
	return {
		"task_id": task_id,
		"url": url,
		"target_path": target_path,
		"temp_path": temp_path,
		"segment_path": segment_path,
		"headers": headers.duplicate(),
		"expected_sha256": expected_sha256,
		"resume": resume,
		"overwrite": overwrite,
		"metadata": metadata.duplicate(true),
		"status": status,
		"status_name": get_status_name(status),
		"received_bytes": received_bytes,
		"total_bytes": total_bytes,
		"response_code": response_code,
		"error": error,
	}


## 获取任务状态名称。
## @param value: 任务状态。
## @return 状态名称。
static func get_status_name(value: Status) -> String:
	match value:
		Status.RUNNING:
			return "running"
		Status.PAUSED:
			return "paused"
		Status.COMPLETED:
			return "completed"
		Status.FAILED:
			return "failed"
		Status.CANCELLED:
			return "cancelled"
		_:
			return "queued"
