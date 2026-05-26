# System 与 Utility 心跳

在 GF 架构下，核心系统不需要继承 `Node`，也不存在于场景树中。核心业务逻辑更新由架构集中管理，可统一处理暂停、时间缩放和调试诊断。

全局 AutoLoad `Gf` 持有对 Godot `_process` 和 `_physics_process` 的监听。收到帧调用后，它会转发给 `GFArchitecture`，再由架构遍历参与 `tick()` / `physics_tick()` 的 `GFSystem` 与 `GFUtility`。

`Gf` 会把自身 `process_mode` 设置为 `PROCESS_MODE_ALWAYS`，因此即使项目临时使用 Godot 原生 `SceneTree.paused`，框架层的时间工具、暂停逻辑和明确声明忽略暂停的模块仍有机会继续收敛状态。

```gdscript
class_name CooldownSystem extends GFSystem

var _combat_model: CombatModel

func ready() -> void:
	_combat_model = get_model(CombatModel) as CombatModel

func tick(delta: float) -> void:
	if _combat_model != null and not _combat_model.is_combat_paused:
		_combat_model.decrease_cooldown_timers(delta)
```

`GFSystem` 基类保留空模板方法用于兼容，但架构只会把真实声明了对应方法的子类加入 tick 缓存，不会因为基类空模板让所有 System 每帧空转。旧项目中已经重写 `tick()` / `physics_tick()` 的模块无需改动；如果确实需要让未重写模板方法的 System 显式进入缓存，可以设置 `tick_enabled = true` 或 `physics_tick_enabled = true`。

`GFUtility` 需要实现对应方法才会被驱动，显式标记只负责让能力声明和缓存刷新更直接。这些标记在注册前或注册后设置都可以，已注入架构的模块会自动刷新 tick 缓存。

在 `tick()` / `physics_tick()` 这类热路径里，推荐在 `ready()` 或初始化阶段缓存长期依赖的 Model、System、Utility 引用。`get_model()` / `get_system()` / `get_utility()` 适合表达依赖入口，但每帧重复查找没有必要；只有当项目会动态替换某个模块实例时，才需要在替换完成后刷新缓存。

## Tick 与 Physics Tick

- `tick(delta)`：对应渲染帧，适合视觉队列、UI 数据动态演算、不涉及物理碰撞引擎参与的高频逻辑。
- `physics_tick(delta)`：对应固定逻辑帧，适合移动插值前置、碰撞检测参数传递和状态机物理更新。
