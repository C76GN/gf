# 3D 相机编排

3D 用法保持同一套语义。`GFCameraRig3D` 可以用 `target_path` 跟随目标位置和旋转，也可以开启 `look_at_enabled` 并设置 `look_at_target_path`，让期望 Transform 朝向另一个节点。

```gdscript
var rig := GFCameraRig3D.new()
rig.priority = 20
rig.target_path = rig.get_path_to(anchor)
rig.offset = Vector3(0.0, 3.0, 7.0)
rig.offset_follows_rotation = true
rig.look_at_enabled = true
rig.look_at_target_path = rig.get_path_to(subject)
```

3D Rig 只计算期望 Camera Transform。碰撞避让、遮挡处理、锁定目标、镜头摇臂或关卡脚本仍由项目层组合。
