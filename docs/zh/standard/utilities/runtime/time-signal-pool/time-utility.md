# 动态时间缩放

`GFTimeUtility` 用于实现子弹时间、暂停特定组内的系统、在受击时定帧。

## 基础用法

```gdscript
var time_scale_util := Gf.get_utility(GFTimeUtility) as GFTimeUtility

# 全局逻辑时间放慢 10 倍
time_scale_util.time_scale = 0.1

# 或暂停某个自定义组，并在系统内主动获取该组 delta
time_scale_util.set_group_paused(&"CombatSystems", true)
```

`max_scaled_delta` 可限制单帧传入普通 `tick()` 的最大缩放步长，避免掉帧或极端加速造成逻辑跳变。

物理逻辑可通过 `physics_substep_max_delta` 和 `max_physics_substeps` 把一次 `physics_tick` 拆成多个子步。

全局暂停会让未标记 `ignore_pause` 的系统收到 `0.0`，分组暂停则需要系统或项目代码使用 `get_group_scaled_delta()` 主动读取对应组的 delta。
