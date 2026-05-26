# Pattern2D 与 Steering

本组页面覆盖资源化二维格子模式和 steering 运动计算原语。GF 只计算模式、目标、加速度和组合结果，不移动 Godot 节点，也不定义 AI、阵营、路径点来源或碰撞响应。

## 阅读入口

- [Pattern2D](pattern-2d.md)：`GFPattern2D` 的格子模式、尺寸、去重、边界过滤和 Inspector 编辑。
- [Steering 算法](steering-math.md)：`GFSteeringAgent`、`GFSteeringAcceleration` 和 `GFSteeringMath`。
- [资源化 Steering 组合](steering-resources.md)：`GFSteeringBehaviorResource` 与 `GFSteeringBehaviorStack`。

## 使用边界

Pattern2D 和 Steering 只输出格子候选、目标方向或加速度建议。实际节点移动、碰撞避让、AI 决策、阵营规则和动画表现仍由项目逻辑负责。
