# 2D 曲线与折线

`GFCurve2DMath` 提供围绕 `Curve2D` 与 `PackedVector2Array` 的纯算法辅助，适合复用在导入器、编辑器工具、路径预览、轨迹采样、虚线预处理和 UI/玩法之间的几何预处理。

## 定位

这个工具只处理几何数据本身：折线长度、按归一化比例采样、按最小点距简化、按 dash/gap 切出可见线段、闭合多边形圆角化，以及生成闭合矩形或椭圆曲线。它不负责绘制、碰撞、导航、多边形布尔运算、SVG 解析或节点创建。

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
var dashed := GFCurve2DMath.make_dashed_polyline_segments(points, 12.0, 6.0)
var rounded := GFCurve2DMath.round_polygon_points(points, 8.0, 6)
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

`make_dashed_polyline_segments()` 返回可见线段数据，每项都是两个点组成的 `PackedVector2Array`。函数会让 dash/gap 相位沿整条折线连续推进，并在折线顶点处拆分线段，避免渲染方把转角连成斜线。它不采样颜色、宽度、材质或动画状态；这些仍由调用方根据自己的绘制方式处理。

`round_polygon_points()` 只返回新的 `PackedVector2Array`，不改写 `Polygon2D`、`CollisionPolygon2D`、`Curve2D` 或材质数据。输入多边形不需要重复末点；如果传入了重复闭合点，函数会先忽略它，再按相邻边长度限制每个顶点的圆角半径。
