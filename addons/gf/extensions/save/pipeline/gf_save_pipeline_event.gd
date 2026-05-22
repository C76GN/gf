## GFSavePipelineEvent: 存档图流程事件。
##
## 用于描述 GFSaveGraphUtility 在采集/应用过程中的通用阶段、Scope、Source
## 与诊断信息。事件本身不携带业务字段，项目层可通过 payload 扩展。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFSavePipelineEvent
extends RefCounted


# --- 公共变量 ---

## 流程阶段标识。
## [br]
## @api public
var stage: StringName = &""

## 事件严重级别，建议使用 info/warning/error。
## [br]
## @api public
var severity: StringName = &"info"

## 事件关联的作用域键。
## [br]
## @api public
var scope_key: StringName = &""

## 事件关联的来源键。
## [br]
## @api public
var source_key: StringName = &""

## 事件关联节点路径。
## [br]
## @api public
var node_path: String = ""

## 面向调试的短消息。
## [br]
## @api public
var message: String = ""

## 附加通用载荷。
## [br]
## @api public
## [br]
## @schema payload: Dictionary，项目或流程步骤附加的诊断字段。
var payload: Dictionary = {}

## 事件创建时间。
## [br]
## @api public
var timestamp_msec: int = 0


# --- 公共方法 ---

## 配置事件内容并返回自身。
## [br]
## @api public
## [br]
## @param p_stage: 流程阶段。
## [br]
## @param scope: 可选 Scope 或节点对象。
## [br]
## @param source: 可选 Source 或节点对象。
## [br]
## @param p_message: 调试消息。
## [br]
## @param p_payload: 附加载荷。
## [br]
## @param p_severity: 严重级别。
## [br]
## @return 当前事件。
## [br]
## @schema p_payload: Dictionary，项目或流程步骤附加的诊断字段。
func configure(
	p_stage: StringName,
	scope: Object = null,
	source: Object = null,
	p_message: String = "",
	p_payload: Dictionary = {},
	p_severity: StringName = &"info"
) -> GFSavePipelineEvent:
	stage = p_stage
	severity = p_severity
	message = p_message
	payload = p_payload.duplicate(true)
	timestamp_msec = Time.get_ticks_msec()

	_apply_scope(scope)
	_apply_source(source)
	return self


## 转换为 Dictionary，便于日志、存档或测试断言。
## [br]
## @api public
## [br]
## @return 事件字典。
## [br]
## @schema return: Dictionary，包含 stage、severity、scope_key、source_key、node_path、message、payload 与 timestamp_msec。
func to_dict() -> Dictionary:
	return {
		"stage": stage,
		"severity": severity,
		"scope_key": scope_key,
		"source_key": source_key,
		"node_path": node_path,
		"message": message,
		"payload": payload.duplicate(true),
		"timestamp_msec": timestamp_msec,
	}


## 从 Dictionary 恢复事件。
## [br]
## @api public
## [br]
## @param data: 事件字典。
## [br]
## @return 新事件。
## [br]
## @schema data: Dictionary，可包含 stage、severity、scope_key、source_key、node_path、message、payload 与 timestamp_msec。
static func from_dict(data: Dictionary) -> GFSavePipelineEvent:
	var event := GFSavePipelineEvent.new()
	event.stage = StringName(data.get("stage", &""))
	event.severity = StringName(data.get("severity", &"info"))
	event.scope_key = StringName(data.get("scope_key", &""))
	event.source_key = StringName(data.get("source_key", &""))
	event.node_path = String(data.get("node_path", ""))
	event.message = String(data.get("message", ""))
	var payload_data := data.get("payload", {}) as Dictionary
	event.payload = payload_data.duplicate(true) if payload_data != null else {}
	event.timestamp_msec = int(data.get("timestamp_msec", 0))
	return event


# --- 私有/辅助方法 ---

func _apply_scope(scope: Object) -> void:
	if scope == null:
		return
	if scope.has_method("get_scope_key"):
		scope_key = StringName(scope.call("get_scope_key"))
	if scope is Node:
		node_path = _get_node_path(scope as Node)


func _apply_source(source: Object) -> void:
	if source == null:
		return
	if source.has_method("get_source_key"):
		source_key = StringName(source.call("get_source_key"))
	if source is Node:
		node_path = _get_node_path(source as Node)


func _get_node_path(node: Node) -> String:
	if node.is_inside_tree():
		return String(node.get_path())
	return node.name
