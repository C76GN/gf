## GFProjectileSpawnPattern2D: 2D 发射体生成点模式基类。
##
## 模式只返回全局 Transform2D 列表，不实例化节点，也不解释伤害、弹药或阵营。
class_name GFProjectileSpawnPattern2D
extends Resource


# --- 公共方法 ---

## 计算本次发射的全局生成变换。
## @param emitter: 发射器节点。
## @param projectile_context: 本次发射上下文。
## @param emit_count: 调用方请求的数量；小于等于 0 时由模式自行决定。
## @return 全局 Transform2D 列表。
func get_spawn_transforms(
	emitter: Node2D,
	projectile_context: Dictionary = {},
	emit_count: int = -1
) -> Array[Transform2D]:
	return _get_spawn_transforms(emitter, projectile_context, emit_count)


# --- 虚方法（由子类重写） ---

## 生成点计算扩展点。
func _get_spawn_transforms(
	emitter: Node2D,
	_projectile_context: Dictionary = {},
	_emit_count: int = -1
) -> Array[Transform2D]:
	if emitter == null:
		return []
	return [emitter.global_transform]


# --- 私有/辅助方法 ---

func _resolve_count(default_count: int, emit_count: int) -> int:
	if emit_count > 0:
		return emit_count
	return maxi(default_count, 1)
