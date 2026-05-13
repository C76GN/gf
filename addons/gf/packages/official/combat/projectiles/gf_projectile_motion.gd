## GFProjectileMotion: 发射体移动策略基类。
##
## 移动策略只负责根据 delta 推进节点位置。需要跨帧保存的数据应写入
## projectile_context，避免共享 Resource 在多个发射体之间串状态。
class_name GFProjectileMotion
extends Resource


# --- 公共方法 ---

## 发射体启动时调用。
## @param projectile: 发射体节点。
## @param projectile_context: 本次发射的上下文字典。
func setup(projectile: Node, projectile_context: Dictionary = {}) -> void:
	_setup(projectile, projectile_context)


## 推进一帧移动。
## @param projectile: 发射体节点。
## @param delta: 物理帧间隔。
## @param projectile_context: 本次发射的上下文字典。
func step(projectile: Node, delta: float, projectile_context: Dictionary = {}) -> void:
	_step(projectile, delta, projectile_context)


# --- 虚方法（由子类重写） ---

## 发射体启动扩展点。
func _setup(_projectile: Node, _projectile_context: Dictionary = {}) -> void:
	pass


## 发射体移动扩展点。
func _step(_projectile: Node, _delta: float, _projectile_context: Dictionary = {}) -> void:
	pass
