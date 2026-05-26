# 项目级 Installer

如果希望把启动装配从 boot 脚本中抽离，可以继承 `GFInstaller`。

```gdscript
class_name GameInstaller
extends GFInstaller


func install(architecture: GFArchitecture) -> void:
	await architecture.register_model_instance(PlayerModel.new())
	await architecture.register_utility_instance(GFStorageUtility.new())
	await architecture.register_system_instance(BattleSystem.new())
```

从 `1.9.1` 起，也可以把绑定来源、别名和短生命周期工厂写到声明式装配入口。

```gdscript
func install_bindings(binder: Variant) -> void:
	binder.bind_model(PlayerModel).as_singleton()
	binder.bind_utility(JSONConfigProvider).with_alias(GFConfigProvider).as_singleton()
	binder.bind_system(BattleSystem).as_singleton()
	binder.bind_factory(DealDamageCommand).from_factory(func() -> Object:
		return DealDamageCommand.new()
	).as_transient()
```

`from_instance()` 适合把项目已经持有的对象暴露为单例语义。如果工厂需要每次创建新对象，使用 `from_factory(...).as_transient()`。`from_instance().as_transient()` 会被拒绝，避免已有实例被误当成短生命周期对象。

然后在 `Project Settings > gf/project/installers` 中加入安装器脚本路径。之后 `await Gf.init()` 会按数组顺序逐个执行 Installer：每个 Installer 先执行 `install(architecture)`，再执行 `install_bindings(binder)`，所有 Installer 完成后才进入 `init()`、`async_init()`、`ready()` 三阶段。

`install()` 和 `install_bindings()` 都可以在内部使用 `await`。
