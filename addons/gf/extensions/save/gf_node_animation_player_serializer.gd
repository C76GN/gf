## GFNodeAnimationPlayerSerializer: AnimationPlayer 通用播放状态序列化器。
##
## 保存当前动画、播放位置与速度缩放等通用播放状态，不保存动画资源内容。
class_name GFNodeAnimationPlayerSerializer
extends GFNodeSerializer


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.animation_player"
	display_name = "Animation Player"


# --- 公共方法 ---

func supports_node(node: Node) -> bool:
	return node is AnimationPlayer


func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	var player := node as AnimationPlayer
	if player == null:
		return {}

	return {
		"current_animation": player.current_animation,
		"assigned_animation": player.assigned_animation,
		"current_animation_position": player.current_animation_position,
		"speed_scale": player.speed_scale,
		"playing": player.is_playing(),
		"active": player.active,
	}


func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	var player := node as AnimationPlayer
	if player == null:
		return make_result(false, "Node is not AnimationPlayer.")

	if payload.has("speed_scale"):
		player.speed_scale = float(payload["speed_scale"])
	if payload.has("active"):
		player.active = bool(payload["active"])
	if payload.has("assigned_animation"):
		var assigned_animation := StringName(payload["assigned_animation"])
		if assigned_animation == &"" or player.has_animation(assigned_animation):
			player.assigned_animation = assigned_animation

	var animation_name := StringName(payload.get("current_animation", &""))
	var position := float(payload.get("current_animation_position", 0.0))
	var should_play := bool(payload.get("playing", false))
	if animation_name != &"" and player.has_animation(animation_name):
		player.play(animation_name)
		player.seek(maxf(position, 0.0), true)
		if not should_play:
			player.stop(false)
	elif not should_play:
		player.stop(false)

	return make_result(true)
