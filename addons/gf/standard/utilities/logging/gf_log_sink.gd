## GFLogSink: 日志输出 sink 基类。
##
## 项目可以继承该类，把 GFLogUtility 的结构化日志条目写入 JSONL、
## 远端采集、编辑器面板或其他自定义目标。Sink 不拥有日志工具生命周期，
## 只响应 init/write/flush/shutdown 钩子。
class_name GFLogSink
extends RefCounted


# --- 公共方法 ---

## 初始化 sink。
## @param _owner: 持有该 sink 的日志工具。
func init(_owner: Object) -> void:
	pass


## 写入一条结构化日志。
## @param _entry: 日志条目字典。
func write(_entry: Dictionary) -> void:
	pass


## 刷新尚未写出的缓冲。
func flush() -> void:
	pass


## 关闭 sink 并释放内部资源。
func shutdown() -> void:
	pass
