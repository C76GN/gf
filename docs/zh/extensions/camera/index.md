# Camera 通用相机编排

本页聚焦 Camera 扩展中的通用 Rig、Director 和 Blend 资源。

## 相机 Rig、Director 与过渡资源

Camera 扩展位于 `addons/gf/extensions/camera/`，提供 `GFCameraRig2D`、`GFCameraRig3D`、`GFCameraDirector2D`、`GFCameraDirector3D` 和 `GFCameraBlend`。它只负责把“候选视角、优先级、过渡方式”抽象出来，不读取输入、不绑定角色控制器、不解释剧情状态，也不规定相机抖动、碰撞避让、锁定目标或关卡脚本。

`GFCameraRig2D` 和 `GFCameraRig3D` 是期望相机姿态的提供者。它们可以直接使用自身全局姿态，也可以通过 `target_path` 跟随任意 `Node2D` / `Node3D`，并通过 `priority`、`active`、`offset`、`rotation_degrees_offset` 和 `blend` 描述通用选择与过渡信息。

`GFCameraDirector2D` 和 `GFCameraDirector3D` 从显式 `rig_paths` 或 Rig 自动加入的分组中收集候选，按优先级选择当前可用 Rig，再把插值后的姿态应用到指定 Camera。默认分组分别是 `gf_camera_rig_2d` 与 `gf_camera_rig_3d`；项目也可以关闭分组收集，只使用显式路径。

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

进入某个 Rig 时，Director 会优先使用该 Rig 的 `blend`；如果为空，则使用 Director 的 `default_blend`。`GFCameraBlend` 只保存持续时间、Tween transition 和 ease，并通过 `sample_weight(elapsed_seconds)` 返回 0..1 权重：

```gdscript
var blend := GFCameraBlend.new()
blend.duration_seconds = 0.35
blend.transition_type = Tween.TRANS_SINE
blend.ease_type = Tween.EASE_IN_OUT

director.default_blend = blend
```

3D 用法保持同一套语义。`GFCameraRig3D` 可以用 `target_path` 跟随目标位置和旋转，也可以开启 `look_at_enabled` 并设置 `look_at_target_path`，让期望 Transform 朝向另一个节点：

```gdscript
var rig := GFCameraRig3D.new()
rig.priority = 20
rig.target_path = rig.get_path_to(anchor)
rig.offset = Vector3(0.0, 3.0, 7.0)
rig.offset_follows_rotation = true
rig.look_at_enabled = true
rig.look_at_target_path = rig.get_path_to(subject)
```

Camera 扩展不接管项目的镜头状态机。常见做法是让项目 System、场景 Controller、状态机或关卡脚本只调整 Rig 的 `active`、`priority`、`target_path` 和配置资源；Director 继续只负责选择和应用当前最佳姿态。这样镜头规则可以按玩法、UI、过场、编辑器工具或调试视角自由组合，而不会把业务条件写进框架层。

---
