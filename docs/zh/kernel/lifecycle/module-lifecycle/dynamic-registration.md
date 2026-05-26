# 初始化后的动态注册

自 `1.6.0` 起，如果架构已经完成 `Gf.init()`，之后再注册新的 Model、System 或 Utility，框架会为新模块自动补跑完整生命周期：

```text
init() -> async_init() -> ready()
```

这适合运行时加载关卡专属系统、DLC 模块、调试工具或临时玩法模块。

```gdscript
await Gf.init()

var battle_system := BattleSystem.new()
await Gf.register_system(battle_system)
# battle_system 会自动完成三阶段生命周期，随后参与 tick / physics_tick。
```

如果动态模块在 `async_init()` 中等待资源或网络流程，而调用点需要确认它已经完全 ready，可以直接使用底层架构方法并 `await`：

```gdscript
await Gf.get_architecture().register_utility_instance(RuntimeConfigProvider.new())
```

动态注册仍应遵守依赖边界。长期跨场景服务应在项目 Installer 中注册；关卡专属或临时模块应在卸载时明确注销，或通过场景切换瞬态清理机制处理。
