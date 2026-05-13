# 逻辑空间查询与相关包

标准库提供纯逻辑四叉树用于轻量空间查询；流程、任务和行为树能力位于对应官方包页面。

## 逻辑四叉树 (`GFQuadTreeUtility`)

抛开需要碰撞体积的 Godot `Area2D` 体系；对于上千同屏单位仅仅用于查询范围索敌、视野扫描或邻居列表时，可以使用这个纯代码二维空间索引加速。它只保存 `entity_id -> Rect2` 的映射，调用方仍要自己维护实体表、坐标更新和最终业务过滤。

```gdscript
var quad_tree := Gf.get_utility(GFQuadTreeUtility) as GFQuadTreeUtility

# 初始化世界边界、最大深度和单节点容量。
quad_tree.setup(Rect2(Vector2.ZERO, Vector2(4096, 4096)), 8, 8)

# entity_id 由项目层自己管理，Rect2 是实体的轴对齐包围盒。
quad_tree.insert(1001, Rect2(Vector2(128, 256), Vector2(32, 32)))
quad_tree.update(1001, Rect2(Vector2(160, 260), Vector2(32, 32)))

var nearby_ids := quad_tree.query_radius(Vector2(160, 260), 96.0)
var visible_ids := quad_tree.query_rect(Rect2(Vector2(0, 0), Vector2(512, 512)))

quad_tree.remove(1001)
```

`query_rect()` 返回与查询矩形相交的实体 ID，`query_radius()` 会先按圆的外接矩形找候选，再按矩形到圆心的最近点做二次过滤。它不会替代 Godot 物理检测，也不会自动跟踪节点移动；实体离开世界边界、跨多个象限或需要精确形状判定时，项目层需要在查询结果上继续处理。

---


## 相关官方包

`GFLevelUtility`、`GFQuestUtility` 和 `GFBehaviorTree` 的完整说明见 [Level、BehaviorTree 与 Quest](../../packages/level-behaviortree-quest/index.md)。标准库页面只交叉引用这些包能力，避免同一概念在多个页面重复维护。
