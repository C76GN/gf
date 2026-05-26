# 派生属性、组合副作用与绑定边界

这一页说明多个绑定属性如何组合成派生值或局部副作用，以及绑定属性和全局事件系统的职责边界。

## 数据绑定的局限性与设计哲学

## 派生属性与组合副作用

当 UI 或 Controller 需要同时依赖多个 `GFBindableProperty` 时，不必把它升级成全局事件，也不需要把计算结果写死在某个业务 Model 中。`GFReactiveEffect` 可监听一组来源属性并执行回调；`GFComputedProperty` 则把多个来源派生成一个只读属性。

```gdscript
var first_name := GFBindableProperty.new("Ada")
var last_name := GFBindableProperty.new("Lovelace")

var full_name := GFComputedProperty.new(
	[first_name, last_name],
	func() -> String:
		return "%s %s" % [first_name.get_value(), last_name.get_value()],
	""
)

full_name.bind_to(self, func(_old_value: Variant, new_value: Variant) -> void:
	%NameLabel.text = new_value
)
```

`GFReactiveEffect` 适合处理“多个值变化后刷新一段表现”的场景，并可绑定 `Node` 生命周期：

```gdscript
var effect := GFReactiveEffect.new(
	[player_model.hp, player_model.max_hp],
	func() -> void:
		%HpBar.value = float(player_model.hp.get_value()) / float(player_model.max_hp.get_value()),
	self
)
```

这两者都只服务局部响应式组合，不替代 `GFModel` 的数据归属，也不规定属性字段含义。无 owner 的 `GFReactiveEffect` 或 `GFComputedProperty` 需要由持有方在生命周期结束时调用 `stop()` 或 `dispose()`；传入 owner 时会随该节点退出树自动停止。

如果某个对象需要把属性暴露给 UI 读取和订阅，但不希望外部调用方直接 `set_value()`，可以返回 `GFReadOnlyBindableProperty` 或由宿主对象封装只读视图。它复用 `GFBindableProperty` 的读取、`value_changed` 信号和 `bind_to()` 生命周期绑定能力，但外部写入和原地修改 helper 都会报错；真正的值更新应由宿主对象内部完成。对于 `Array` / `Dictionary` 等引用值，普通 `GFBindableProperty` 的原地修改不会自动触发变更信号；需要通知监听者时应重新 `set_value()` 一个副本，或在明确接受引用语义时调用 `force_emit()`、`mutate()`、`append_to_array()`、`set_dictionary_value()` 等辅助方法。

你可能会思考一个问题：如果局部 `value_changed` 这么好用，为什么不把全局事件框架全部改用它代替？

- **数据绑定适合于：单一流向的状态展示。** 例如 UI 显示血条数值、冷却读条刻度、金币数量显示。
- **全局事件系统适合：多路业务交错。** 例如成就系统关注战斗系统中的某类行为，并需要触发跨模块结算时，`GFPayload` 是承载计算上下文信息的必要载体。

**经验法则：**
*如果你是为了把数据"显示在屏幕上"，请使用 `GFBindableProperty` 订阅；如果你想表示"发生了一个业务动作导致其他系统也要开始运算"，发送 `Gf.send_event(...)`。*
