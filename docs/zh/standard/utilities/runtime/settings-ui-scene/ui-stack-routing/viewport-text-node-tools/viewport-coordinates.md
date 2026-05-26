# 视口与坐标转换

如果项目需要本地多人分屏、每玩家相机或简单的编辑器预览布局，可以使用 `GFViewportUtility`。它只创建和维护 `SubViewportContainer` / `SubViewport` 结构，并提供按索引挂载相机与后处理材质的 API，不接管玩家、镜头规则或场景生命周期。

```gdscript
var viewport_util := GFViewportUtility.new()
var viewports := viewport_util.setup_split_screen(%Root, 2, {
	"viewport_size": Vector2i(640, 360),
})
viewport_util.set_viewport_camera(0, $Camera2D)
```

默认情况下，`viewport_size` 会保持 SubViewport 的渲染尺寸，`viewport_resolution_scale` 会按比例缩放该尺寸；需要让 SubViewport 跟随容器大小时，可在 options 中传入 `"stretch": true`。`clear_split_screen()` 会立即把旧 `GridContainer` 和已挂载相机从当前树上移除，再按参数决定是否释放相机，便于同一帧重建布局或切换分屏配置。

同一个工具还提供少量不绑定输入来源的坐标辅助。`screen_to_world_ray_3d(camera, screen_position, length)` 可从 Camera3D 和 Viewport 坐标生成射线，`raycast_from_screen_3d()` 在此基础上执行物理射线检测，`world_to_screen_3d()` 做 3D 投影；2D 侧可用 `world_to_screen_2d(canvas_item, world_position)` 与 `screen_to_world_2d(canvas_item, screen_position)` 在 CanvasItem 世界坐标和屏幕坐标之间转换。

这些方法不读取鼠标、不选择玩家、不决定命中对象含义，只提供稳定几何转换。
