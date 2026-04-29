@tool

## GFThumbnailRenderer: 编辑器缩略图渲染辅助节点。
##
## 使用独立 SubViewport 渲染 Node3D 或 Mesh，供项目自定义编辑器工具复用。
class_name GFThumbnailRenderer
extends Node


# --- 私有变量 ---

var _viewport: SubViewport
var _world_root: Node3D
var _camera: Camera3D
var _key_light: DirectionalLight3D
var _fill_light: DirectionalLight3D


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_ensure_viewport()


func _exit_tree() -> void:
	if is_instance_valid(_viewport):
		_viewport.queue_free()
	_viewport = null
	_world_root = null
	_camera = null
	_key_light = null
	_fill_light = null


# --- 公共方法 ---

## 渲染一个 3D 节点缩略图。
## @param source: 要渲染的 3D 节点，会被复制后放入内部 Viewport。
## @param size: 输出尺寸。
## @param transparent: 是否透明背景。
## @return 渲染出的 Image；失败时返回 null。
func render_node3d(source: Node3D, size: Vector2i = Vector2i(256, 256), transparent: bool = true) -> Image:
	if source == null:
		return null

	_ensure_viewport()
	_clear_world_root()

	var instance := source.duplicate() as Node3D
	if instance == null:
		return null

	_world_root.add_child(instance)
	_prepare_instance(instance)
	_render_prepare(size, transparent, _get_combined_aabb(instance))

	await RenderingServer.frame_post_draw
	return _viewport.get_texture().get_image()


## 渲染一个 3D 节点缩略图纹理。
## @param source: 要渲染的 3D 节点。
## @param size: 输出尺寸。
## @param transparent: 是否透明背景。
## @return 渲染出的 ImageTexture；失败时返回 null。
func render_node3d_texture(
	source: Node3D,
	size: Vector2i = Vector2i(256, 256),
	transparent: bool = true
) -> ImageTexture:
	var image: Image = await render_node3d(source, size, transparent)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


## 渲染一个 Mesh 缩略图。
## @param mesh: 要渲染的 Mesh。
## @param size: 输出尺寸。
## @param transparent: 是否透明背景。
## @return 渲染出的 Image；失败时返回 null。
func render_mesh(mesh: Mesh, size: Vector2i = Vector2i(256, 256), transparent: bool = true) -> Image:
	if mesh == null:
		return null

	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var image: Image = await render_node3d(instance, size, transparent)
	instance.free()
	return image


## 渲染一个 Mesh 缩略图纹理。
## @param mesh: 要渲染的 Mesh。
## @param size: 输出尺寸。
## @param transparent: 是否透明背景。
## @return 渲染出的 ImageTexture；失败时返回 null。
func render_mesh_texture(
	mesh: Mesh,
	size: Vector2i = Vector2i(256, 256),
	transparent: bool = true
) -> ImageTexture:
	var image: Image = await render_mesh(mesh, size, transparent)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


## 为 MeshLibrary 批量生成条目预览。
## @param mesh_library: 目标 MeshLibrary。
## @param size: 预览尺寸。
## @param overwrite_existing: 是否覆盖已有预览。
## @return 成功生成的预览数量。
func render_mesh_library_previews(
	mesh_library: MeshLibrary,
	size: Vector2i = Vector2i(128, 128),
	overwrite_existing: bool = true
) -> int:
	if mesh_library == null:
		return 0

	var generated_count := 0
	var was_blocking := mesh_library.is_blocking_signals()
	mesh_library.set_block_signals(true)
	for item_id: int in mesh_library.get_item_list():
		if not overwrite_existing and mesh_library.get_item_preview(item_id) != null:
			continue

		var mesh := mesh_library.get_item_mesh(item_id)
		if mesh == null:
			continue

		var texture: ImageTexture = await render_mesh_texture(mesh, size, true)
		if texture != null:
			mesh_library.set_item_preview(item_id, texture)
			generated_count += 1

	mesh_library.set_block_signals(was_blocking)
	if generated_count > 0:
		mesh_library.emit_changed()
	return generated_count


# --- 私有/辅助方法 ---

func _ensure_viewport() -> void:
	if is_instance_valid(_viewport):
		return

	_viewport = SubViewport.new()
	_viewport.name = "GFThumbnailViewport"
	_viewport.transparent_bg = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.world_3d = World3D.new()
	_viewport.world_3d.environment = Environment.new()
	add_child(_viewport)

	_world_root = Node3D.new()
	_viewport.add_child(_world_root)

	_camera = Camera3D.new()
	_camera.current = true
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.near = 0.01
	_camera.far = 1000.0
	_world_root.add_child(_camera)

	_key_light = DirectionalLight3D.new()
	_key_light.light_energy = 2.0
	_key_light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
	_world_root.add_child(_key_light)

	_fill_light = DirectionalLight3D.new()
	_fill_light.light_energy = 0.75
	_fill_light.rotation_degrees = Vector3(35.0, 145.0, 0.0)
	_world_root.add_child(_fill_light)


func _clear_world_root() -> void:
	for child: Node in _world_root.get_children():
		if child != _camera and child != _key_light and child != _fill_light:
			_world_root.remove_child(child)
			child.free()


func _prepare_instance(instance: Node3D) -> void:
	instance.transform = Transform3D.IDENTITY
	var bounds := _get_combined_aabb(instance)
	var largest := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if largest > 0.0001:
		instance.scale *= 2.0 / largest
	bounds = _get_combined_aabb(instance)
	var center := bounds.position + bounds.size * 0.5
	instance.global_position -= center


func _render_prepare(size: Vector2i, transparent: bool, bounds: AABB) -> void:
	_viewport.size = size
	_viewport.transparent_bg = transparent
	var environment := _viewport.world_3d.environment
	environment.background_mode = Environment.BG_CLEAR_COLOR if transparent else Environment.BG_COLOR

	var center := bounds.position + bounds.size * 0.5
	var largest := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if largest < 0.01:
		largest = 1.0
	var camera_direction := Vector3(0.45, 0.4, 1.0).normalized()
	_camera.position = center + camera_direction * largest * 4.0
	_camera.look_at(center, Vector3.UP)
	_camera.size = _calculate_orthographic_size_for_aabb(bounds, _camera) * 1.08
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	RenderingServer.force_draw()


func _get_combined_aabb(root: Node) -> AABB:
	var combined := AABB()
	var has_bounds := false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current := stack.pop_back()
		if current is MeshInstance3D:
			var mesh_instance := current as MeshInstance3D
			if mesh_instance.mesh != null:
				var aabb := mesh_instance.get_aabb()
				var transform := mesh_instance.global_transform
				var corners := [
					transform * aabb.position,
					transform * (aabb.position + Vector3(aabb.size.x, 0.0, 0.0)),
					transform * (aabb.position + Vector3(0.0, aabb.size.y, 0.0)),
					transform * (aabb.position + Vector3(0.0, 0.0, aabb.size.z)),
					transform * (aabb.position + Vector3(aabb.size.x, aabb.size.y, 0.0)),
					transform * (aabb.position + Vector3(aabb.size.x, 0.0, aabb.size.z)),
					transform * (aabb.position + Vector3(0.0, aabb.size.y, aabb.size.z)),
					transform * (aabb.position + aabb.size),
				]
				for point: Vector3 in corners:
					if not has_bounds:
						combined = AABB(point, Vector3.ZERO)
						has_bounds = true
					else:
						combined = combined.expand(point)
		for child: Node in current.get_children():
			stack.append(child)

	if not has_bounds:
		return AABB(Vector3(-0.5, -0.5, -0.5), Vector3.ONE)
	return combined


func _calculate_orthographic_size_for_aabb(bounds: AABB, camera: Camera3D) -> float:
	var camera_transform := camera.global_transform
	var camera_right := camera_transform.basis.x.normalized()
	var camera_up := camera_transform.basis.y.normalized()
	var corners := [
		bounds.position,
		bounds.position + Vector3(bounds.size.x, 0.0, 0.0),
		bounds.position + Vector3(0.0, bounds.size.y, 0.0),
		bounds.position + Vector3(0.0, 0.0, bounds.size.z),
		bounds.position + Vector3(bounds.size.x, bounds.size.y, 0.0),
		bounds.position + Vector3(bounds.size.x, 0.0, bounds.size.z),
		bounds.position + Vector3(0.0, bounds.size.y, bounds.size.z),
		bounds.position + bounds.size,
	]

	var min_u := INF
	var max_u := -INF
	var min_v := INF
	var max_v := -INF
	for corner: Vector3 in corners:
		var offset := corner - camera.global_position
		var u := offset.dot(camera_right)
		var v := offset.dot(camera_up)
		min_u = minf(min_u, u)
		max_u = maxf(max_u, u)
		min_v = minf(min_v, v)
		max_v = maxf(max_v, v)

	return maxf(max_u - min_u, max_v - min_v)
