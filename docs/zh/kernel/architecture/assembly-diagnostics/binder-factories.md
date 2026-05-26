# 声明式装配与工厂

从 `1.9.1` 起，Installer 与 NodeContext 可以使用声明式装配器。

```gdscript
func install_bindings(binder: Variant) -> void:
	binder.bind_model(PlayerModel).as_singleton()
	binder.bind_utility(JSONConfigProvider).with_alias(GFConfigProvider).as_singleton()
	binder.bind_factory(DealDamageCommand).from_factory(func() -> Object:
		return DealDamageCommand.new()
	).as_transient()
```

声明式装配不会替代原有 `register_model_instance()`、`register_system_instance()`、`register_utility_instance()`。它只是把“绑定来源、别名和生命周期”集中写清楚，适合大型项目或插件式模块。

声明式装配器由 `GFBinder` 和 `GFBindBuilder` 提供：`GFBinder` 是传给 Installer 的入口对象，负责创建 `bind_model()`、`bind_system()`、`bind_utility()`、`bind_factory()` 这些绑定链；`GFBindBuilder` 则承接 `.from_factory()`、`.from_instance()`、`.with_alias()`、`.as_singleton()`、`.as_transient()` 等声明。

`Model`、`System`、`Utility` 都是生命周期模块，只支持单例式注册；`as_transient()` 只适合短生命周期工厂对象，`.with_alias()` 也只对生命周期模块生效。

对于不需要进入生命周期的短生命周期对象，`GFArchitecture` 提供轻量工厂能力。详细注册、生命周期和父子架构回退规则见 [生命周期、装配与依赖](../../lifecycle/index.md)。

工厂适合 Command、Query、技能执行载体等一次性对象，不建议用于需要参与 `init()`、`tick()`、`dispose()` 的长期模块。

当子架构回退到父级工厂时，transient 工厂创建的对象会注入发起解析的子架构，从而优先访问当前局部上下文。

singleton 工厂仍由拥有该绑定的架构持有和注入，并在工厂替换、注销或架构销毁时清理缓存实例的 owner 事件监听、调用 `dispose()`（如果存在）和释放依赖作用域。
