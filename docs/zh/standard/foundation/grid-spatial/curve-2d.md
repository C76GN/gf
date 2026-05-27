# 2D 曲线与折线

`GFCurve2DMath` 提供围绕 `Curve2D` 与 `PackedVector2Array` 的纯算法辅助，适合复用在导入器、编辑器工具、路径预览、轨迹采样和 UI/玩法之间的几何预处理。

## 定位

这个工具只处理几何数据本身：折线长度、按归一化比例采样、按最小点距简化，以及生成闭合矩形或椭圆曲线。它不负责绘制、碰撞、导航、多边形布尔运算、SVG 解析或节点创建。

## 常见流程

```gdscript
var points := PackedVector2Array([
	Vector2(0, 0),
	Vector2(64, 0),
	Vector2(64, 48),
])

var length := GFCurve2DMath.get_polyline_length(points)
var midpoint := GFCurve2DMath.sample_polyline(points, 0.5, length)
var compact := GFCurve2DMath.simplify_polyline_by_distance(points, 4.0)
```

基础闭合形状可以直接生成，也可以复用已有 `Curve2D`：

```gdscript
var rect_curve := GFCurve2DMath.create_rect_curve(Vector2(128, 64), Vector2(12, 12))
var ellipse_curve := Curve2D.new()
GFCurve2DMath.set_ellipse_curve(ellipse_curve, Vector2(64, 64), Vector2(32, 32))
```

## 使用边界

`sample_curve()` 基于 `Curve2D` 的 baked 路径长度采样，适合运行时取点、预览和轻量工具。需要严格曲线拟合、SVG path 完整导入、拓扑清理或碰撞轮廓生成时，应在项目工具层或专门扩展中实现。

`simplify_polyline_by_distance()` 只按点距过滤，不会进行 Douglas-Peucker、曲率保持或贝塞尔拟合。它的目标是稳定、可预测地减少密集采样点，而不是生成最少控制点。
