# 08. 实用工具箱 (Utility Toolkit)

GF Framework 的核心极具克制，但针对实际 Godot 开发中屡屡遇到的通用需求问题，在 `addons/gf/utilities/` 下提供了一组被广泛验证过的 "开箱即用" 的原生工具组件。

工具在使用前需确保在启动时被注册进了主容器： `Gf.register_utility(...)`。

---

## 1. 异步按需加载缓存池 (`GFAssetUtility`)

**应用场景：** 当你要按需实例化特效，加载图标，为了防止卡顿，你决定拥抱 `ResourceLoader` 放在子线程里做。但是管理起来由于各种竞态条件导致异常崩溃。

**如何使用：**

```gdscript
var assets := Gf.get_utility(GFAssetUtility) as GFAssetUtility

# 异步加载一个带路径的资源（例如怪物Prefab）。如果缓存已有直接吐出，
# 如果正在被别人加载，则一起等待那一个完成；如果没有，在无阻塞线程中拉起请求。
var monster_scene = await assets.load_asset_async("res://enemies/goblin.tscn")
```
它内置了 LRU （最近最少使用）算法上限，当缓存过大时会自动清理长期未被提取引用的资源。

## 2. 脱离时间的独立定时器 (`GFTimerUtility`)

**应用场景：** Node 自带的 `get_tree().create_timer(1.0).timeout` 是与场景绑定的。如果在等待中更换了场景树，通常会导致意想不到的内存泄露或报错。如果你需要一个受 `GFTimeUtility` (见下条) 控制的、可以在任何代码纯纯等待周期的定时器，请用它。

**如何使用：**
```gdscript
var timer_util := Gf.get_utility(GFTimerUtility) as GFTimerUtility

# 完全纯代码、与场景节点无关的安全等待
await timer_util.delay(1.5)
print("1.5秒真实时间后触发")
```

## 3. 动态时间缩放流 (`GFTimeUtility`)

**应用场景：** 实现子弹时间、暂停特定组内的系统、在受击时定帧 (Hit Stop)。

**如何使用：**
```gdscript
var time_scale_util := Gf.get_utility(GFTimeUtility) as GFTimeUtility
# 将包含战斗组标签的系统帧率全部放慢 10 倍！
time_scale_util.set_time_scale_by_group("CombatSystems", 0.1) 
```

## 4. 节点对象池 (`GFObjectPoolUtility`)

**应用场景：** 子弹、伤害飘字、特效。不要频繁的进行性能极其昂贵的 `queue_free()` 和 `instantiate()`。

```gdscript
var pool := Gf.get_utility(GFObjectPoolUtility) as GFObjectPoolUtility

# 借出一个实例
var bullet = pool.get_instance(bullet_scene) as Node2D

# 归还它进入休眠
pool.return_instance(bullet_scene, bullet)
```

## 5. 存档管理器 (`GFStorageUtility`)

内置跨段存档系统（支持 PC 上的二进制与文件写入以及 HTML5 的本地 localStorage 隔离）。能够将 `Model` 直接转化为字典后序列化至磁盘，安全地加载回来。

## 6. 输入与土狼时间 (`GFInputUtility`)

通过引入 Action 缓冲池，让动作游戏的连招手感倍增。允许玩家在硬直动作快结束前提早按下按钮，动作结束后立即顺滑接续。

## 7. 逻辑四叉树 (`GFQuadTreeUtility`)

抛开需要碰撞体积的 Godot Area2D 体系；对于上千同屏单位仅仅用于查询范围索敌时，可以使用这个纯代码的二维空间分桶查询算法加速！
