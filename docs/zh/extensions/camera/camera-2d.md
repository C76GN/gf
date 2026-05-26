# 2D 相机编排

2D Director 从候选 Rig 中选择当前姿态，并把结果应用到 `Camera2D`。

```gdscript
var director := GFCameraDirector2D.new()
director.camera_path = director.get_path_to(camera_2d)
director.update_mode = GFCameraDirector2D.UpdateMode.MANUAL

var overview := GFCameraRig2D.new()
overview.priority = 1
overview.global_position = Vector2(0.0, 0.0)
overview.zoom = Vector2(1.2, 1.2)

var focus := GFCameraRig2D.new()
focus.priority = 10
focus.target_path = focus.get_path_to(player)
focus.offset = Vector2(0.0, -64.0)

director.rig_paths = [
	director.get_path_to(overview),
	director.get_path_to(focus),
]
director.process_camera(delta)
```

项目可以用多个 Rig 表达总览、玩家跟随、剧情焦点或调试视角。Director 只负责选择和应用当前最佳姿态。
