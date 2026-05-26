# 逻辑空间查询与相关扩展

标准库提供纯逻辑四叉树用于轻量空间查询；流程、任务和行为树能力位于对应 GF 内置扩展页面。

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
var clicked_ids := quad_tree.query_point(Vector2(172, 272))

quad_tree.remove(1001)
```

`query_rect()` 返回与查询矩形相交的实体 ID，`query_radius()` 会先按圆的外接矩形找候选，再按矩形到圆心的最近点做二次过滤。`query_point()` 适合点击、悬停或逻辑拾取；默认先用实体 AABB 粗筛，再执行项目通过 `set_entity_hit_test()` 或 `insert_with_hit_test()` 注册的精确命中测试。命中测试只接收 `(entity_id, point, rect)`，GF 不规定形状类型、节点来源或业务含义。需要只看 AABB 粗筛结果时，可传入 `query_point(point, false)`。

四叉树会归一化负尺寸矩形、限制无效深度和容量，并在缺少根节点时惰性重建；负半径查询直接返回空数组。重复 `insert()` 同一个 `entity_id` 会替换旧矩形，`update()` 会保留已注册的命中测试，`compact()` 可在大量移动或删除后显式重建节点结构。它不会替代 Godot 物理检测，也不会自动跟踪节点移动；实体离开世界边界、跨多个象限或需要精确形状判定时，项目层需要继续维护实体表和命中测试。

---


## 相关 GF 内置扩展

`GFLevelUtility` 与 `GFQuestUtility` 的完整说明见 [Domain 通用领域模型](../../extensions/domain/index.md)，`GFBehaviorTree` 的完整说明见 [BehaviorTree 纯代码行为树](../../extensions/behavior-tree/index.md)。标准库页面只交叉引用这些扩展能力，避免同一概念在多个页面重复维护。
