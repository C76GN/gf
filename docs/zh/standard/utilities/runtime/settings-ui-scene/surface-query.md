# 3D 表面材质查询

本页覆盖 `GFSurfaceUtility` 的碰撞 face 到 Mesh surface 或材质映射。它只提供查询和缓存，不内置脚步声、弹孔、命中特效或地形标签规则。

## 3D 表面材质查询 (`GFSurfaceUtility`)

**应用场景：** 当 RayCast3D 命中了 `ConcavePolygonShape3D` 或由 Mesh 生成的碰撞面，你拿到的是 face index，但脚步声、弹孔、命中特效等通常想按 Mesh surface 或材质分发。

```gdscript
var surfaces := Gf.get_utility(GFSurfaceUtility) as GFSurfaceUtility
var face_index := ray_cast.get_collision_face_index()
var collider := ray_cast.get_collider()

var material := surfaces.get_active_material(collider, face_index)
var surface_index := surfaces.get_surface_index(collider, face_index)
```

`GFSurfaceUtility` 会尝试从命中的 `MeshInstance3D`、父节点、子节点或相邻节点解析 Mesh，并缓存每个 surface 的 face 数量。它只完成 face 到 surface/material 的映射，不内置“泥地”“金属”“水面”等业务标签。

`get_base_material()` 返回 Mesh surface 上的基础材质，`get_surface_override_material()` 返回 `MeshInstance3D` 的 surface override，`get_active_material()` 返回 Godot 最终用于渲染的 active material。缓存以 Mesh RID 为键；默认 `cache_mode` 为 `AUTOMATIC`，会按 `auto_cache_size` 做自动裁剪。需要避免首次命中时计算 surface 面数，可在加载阶段调用 `cache_mesh_surface(mesh_or_mesh_instance)` 预热；需要完全手动管理时可切到 `MANUAL`，需要排查动态 Mesh 变化时可切到 `DISABLED`。运行时替换 Mesh 或动态修改 surface 结构后，可调用 `erase_cached_mesh()` 或 `clear_cache()` 重新计算。
