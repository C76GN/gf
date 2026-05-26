# 能力 Hook 与依赖

能力实例可选择实现以下方法：

```gdscript
func on_gf_capability_added(receiver: Object) -> void:
	pass

func on_gf_capability_removed(receiver: Object) -> void:
	pass

func on_gf_capability_active_changed(receiver: Object, active: bool) -> void:
	pass

func get_dependency_removal_policy() -> int:
	return GFCapabilityUtility.DependencyRemovalPolicy.REMOVE_AUTO_DEPENDENCIES

func inject_dependencies(architecture: GFArchitecture) -> void:
	pass
```

依赖声明不是 Hook，优先写入 `required_capabilities`。基类的 `get_required_capabilities()` 默认会返回这个数组。

只有确实需要运行时动态依赖时，才建议重写 `get_required_capabilities()`；编辑器 Inspector 不会调用该方法。

继承 `GFCapability`、`GFNodeCapability`、`GFNode2DCapability`、`GFNode3DCapability` 或 `GFControlCapability` 时这些方法已有默认实现。

自定义 Node 能力不强制继承特定基类，只要实现需要的 Hook 也能被运行时识别；但需要编辑器添加与统一补全时，推荐继承最匹配的 GF 能力基类。
