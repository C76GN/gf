## GFBuildInfoUtility: 构建信息访问工具。
##
## 在运行时提供稳定的构建信息副本，供诊断、日志、存档元数据或项目 UI 查询。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFBuildInfoUtility
extends GFUtility


# --- 公共变量 ---

## 当前构建信息。
## [br]
## @api public
var build_info: GFBuildInfo = null


# --- GF 生命周期方法 ---

## 采集当前运行环境的构建信息。
## [br]
## @api public
func init() -> void:
	var _refresh_result_28: Variant = refresh()


# --- 公共方法 ---

## 重新采集当前运行环境的构建信息。
## [br]
## @api public
## [br]
## @return: 更新后的构建信息副本。
func refresh() -> GFBuildInfo:
	build_info = GFBuildInfo.collect()
	return get_build_info()


## 手动设置构建信息。
## [br]
## @api public
## [br]
## @param info: 构建信息；为空时会清空当前值。
func set_build_info(info: GFBuildInfo) -> void:
	build_info = info.duplicate_info() if info != null else null


## 获取构建信息。
## [br]
## @api public
## [br]
## @param copy: 为 true 时返回深拷贝，避免调用方修改内部状态。
## [br]
## @return: 构建信息。
func get_build_info(copy: bool = true) -> GFBuildInfo:
	if build_info == null:
		return null
	return build_info.duplicate_info() if copy else build_info


## 获取构建信息字典。
## [br]
## @api public
## [br]
## @return: 构建信息字典。
## [br]
## @schema return: Dictionary，包含 GFBuildInfo.to_dict() 输出的字段；无构建信息时为空 Dictionary。
func get_build_info_dict() -> Dictionary:
	if build_info == null:
		return {}
	return build_info.to_dict()


## 获取简短版本摘要。
## [br]
## @api public
## [br]
## @return: 构建信息摘要。
func get_summary() -> String:
	if build_info == null:
		return ""

	var parts: PackedStringArray = PackedStringArray()
	if not build_info.project_name.is_empty():
		var _append_result_89: Variant = parts.append(build_info.project_name)
	if not build_info.project_version.is_empty():
		var _append_result_91: Variant = parts.append(build_info.project_version)
	if not build_info.framework_version.is_empty():
		var _append_result_93: Variant = parts.append("GF %s" % build_info.framework_version)
	if not build_info.build_id.is_empty():
		var _append_result_95: Variant = parts.append("build %s" % build_info.build_id)
	if not build_info.commit_hash.is_empty():
		var _append_result_97: Variant = parts.append(build_info.commit_hash)
	return " | ".join(parts)


## 获取调试快照。
## [br]
## @api public
## [br]
## @return: 调试快照。
## [br]
## @schema return: Dictionary，包含 available、summary 和 info 字段。
func get_debug_snapshot() -> Dictionary:
	return {
		"available": build_info != null,
		"summary": get_summary(),
		"info": get_build_info_dict(),
	}
