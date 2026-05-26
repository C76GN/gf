# 动态属性包

`GFPropertyBagCapability` 提供轻量键值属性存取，适合原型、调试或少量临时运行时数据。

```gdscript
var bag := capabilities.add_capability(enemy, GFPropertyBagCapability) as GFPropertyBagCapability
bag.set_property_value(&"rarity", "elite")
bag.set_property_value(&"score", 100)
```

`get_int()`、`get_float()`、`get_bool()`、`get_string()`、`get_vector2()` 和 `get_color()` 只在值符合对应类型时返回属性值。

缺失或类型不匹配会返回调用方传入的默认值。

长期核心状态仍应放在 `GFModel` 或配置资源中，避免把属性包变成隐藏数据模型。
