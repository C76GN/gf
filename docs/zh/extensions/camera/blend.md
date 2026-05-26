# 过渡资源

进入某个 Rig 时，Director 会优先使用该 Rig 的 `blend`；如果为空，则使用 Director 的 `default_blend`。

`GFCameraBlend` 只保存持续时间、Tween transition 和 ease，并通过 `sample_weight(elapsed_seconds)` 返回 `0..1` 权重。

```gdscript
var blend := GFCameraBlend.new()
blend.duration_seconds = 0.35
blend.transition_type = Tween.TRANS_SINE
blend.ease_type = Tween.EASE_IN_OUT

director.default_blend = blend
```

Blend 不绑定具体相机节点、目标选择规则、反馈效果或场景业务。
