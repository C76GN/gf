# 弹簧平滑数学

`GFSpringMath` 提供通用二阶弹簧步进。它只接收当前值、当前速度、目标值、时间步长和弹簧参数，然后返回下一帧的 `value` 与 `velocity`；调用方保存返回速度并在下一帧继续传入即可。

这个能力适合需要“有惯性地靠近目标”的纯数值场景，例如相机偏移、UI 指示器、输入缓冲值、反馈强度或任意项目自定义状态。GF 不提供节点跟随器，不创建 Tween，也不决定目标来源、归一化角度、碰撞或动画播放。

```gdscript
var state: Dictionary = GFSpringMath.step_vector2(
	current_offset,
	current_velocity,
	target_offset,
	delta,
	4.0,
	1.0
)
current_offset = GFVariantData.get_option_vector2(state, "value")
current_velocity = GFVariantData.get_option_vector2(state, "velocity")
```

## 核心入口

- `step_float()`：标量弹簧步进。
- `step_angle()`：弧度角弹簧步进，会先按最短角度方向调整目标；返回值不自动归一化。
- `step_vector2()`：逐分量处理 `Vector2`。
- `step_vector3()`：逐分量处理 `Vector3`。

## 参数语义

- `frequency_hz` 越大，靠近目标越快；小于等于 0 的值会按极小正数处理，避免不稳定除零。
- `damping_ratio` 控制阻尼；`1.0` 接近临界阻尼，`0.0` 表示无阻尼，小于 0 的值会按 0 处理。
- `response` 控制目标速度前馈；不需要跟随移动目标速度时保持默认 `0.0`。
- `target_velocity` 是目标自身速度，只有在 `response` 非零时才会影响结果。

## 使用边界

`GFSpringMath` 是无状态纯算法。它不保存速度、不访问节点、不处理单位换算，也不替项目决定何时认为“已经到达”。需要在节点、相机或 UI 上使用时，应由项目或扩展把返回的 `value` 写回目标属性，并自行管理速度变量生命周期。
