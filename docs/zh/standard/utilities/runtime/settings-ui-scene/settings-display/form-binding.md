# 表单控件绑定

设置界面可以使用 `GFControlValueAdapter` 和 `GFFormBinder` 读写常见 `Control` 值，避免每个设置页重复判断 `LineEdit`、`CheckBox`、`Slider`、`OptionButton` 等控件类型。

```gdscript
var binder := GFFormBinder.new()
binder.bind_field(&"player_name", %NameEdit)
binder.bind_field(&"fullscreen", %FullscreenCheck)
binder.bind_field(&"master_volume", %MasterVolumeSlider)

binder.write_values(settings.to_dict(false))
binder.field_changed.connect(func(key: StringName, value: Variant) -> void:
	settings.set_value(key, value)
)
```

`GFFormBinder.bind_field()` 会在重复绑定同一字段前清理旧连接，`unbind_field()` / `clear()` 也会断开由 `GFControlValueAdapter` 创建的值变化监听。

需要自己管理连接生命周期时，可使用 `connect_value_changed_with_handles()` 和 `disconnect_value_changed_handles()`。
