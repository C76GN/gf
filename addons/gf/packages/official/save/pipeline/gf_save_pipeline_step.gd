## GFSavePipelineStep: 存档图流程步骤基类。
##
## 用于在 GFSaveGraphUtility 的 Scope 采集/应用流程前后插入通用处理。
## 步骤只接收 scope、payload、context 和 result，不绑定任何业务字段。
class_name GFSavePipelineStep
extends Resource


# --- 导出变量 ---

## 步骤标识，便于调试与项目层开关。
@export var step_id: StringName = &""

## 是否启用该步骤。
@export var enabled: bool = true


# --- 公共方法 ---

## 采集 Scope 前调用。
## @param _scope: 当前 Scope。
## @param _context: 调用上下文字典。
func before_gather_scope(_scope: GFSaveScope, _context: Dictionary = {}) -> void:
	pass


## 采集 Scope 后调用。返回 Dictionary 时会替换当前 payload。
## @param _scope: 当前 Scope。
## @param payload: 当前 Scope 载荷。
## @param _context: 调用上下文字典。
## @return 可返回 null 或替换后的 Dictionary。
func after_gather_scope(_scope: GFSaveScope, payload: Dictionary, _context: Dictionary = {}) -> Variant:
	return payload


## 应用 Scope 前调用。返回 Dictionary 时会替换当前 payload。
## @param _scope: 当前 Scope。
## @param payload: 当前 Scope 载荷。
## @param _context: 调用上下文字典。
## @return 可返回 null 或替换后的 Dictionary。
func before_apply_scope(_scope: GFSaveScope, payload: Dictionary, _context: Dictionary = {}) -> Variant:
	return payload


## 应用 Scope 后调用。返回 Dictionary 时会替换当前 result。
## @param _scope: 当前 Scope。
## @param _payload: 当前 Scope 载荷。
## @param result: 当前应用结果。
## @param _context: 调用上下文字典。
## @return 可返回 null 或替换后的 Dictionary。
func after_apply_scope(
	_scope: GFSaveScope,
	_payload: Dictionary,
	result: Dictionary,
	_context: Dictionary = {}
) -> Variant:
	return result
