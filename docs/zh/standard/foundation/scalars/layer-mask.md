# 层名与 Bitmask

`GFLayerMaskUtility` 把按索引排列的层名表和整数 bitmask 互相转换。它适合消除碰撞、射线、命中检测、编辑器配置或调试报告里的魔法数字，但不会替项目写入 `collision_layer`、`collision_mask` 或任何节点属性。

## 名称到掩码

```gdscript
var layer_names := ["Player", "Enemy", "World", "Projectile"]

var mask := GFLayerMaskUtility.names_to_mask(
	["Player", "World"],
	layer_names
)
```

数组索引就是零基层索引：`layer_names[0]` 对应第 1 层，`layer_names[31]` 对应第 32 层。未知名称会被忽略；需要给编辑器或 CI 显示问题时，可先调用 `get_missing_names()`。

```gdscript
var missing := GFLayerMaskUtility.get_missing_names(
	["Player", "Boss"],
	layer_names
)
```

## 掩码到名称

```gdscript
var names := GFLayerMaskUtility.mask_to_names(mask, layer_names)
```

`mask_to_names()` 按层索引稳定返回名称。`include_unnamed` 为 `true` 时，未命名但启用的层会返回 `Layer N`，适合调试输出；正式配置和存档通常应使用项目自己的命名表。

## Godot 项目层名

```gdscript
var physics_2d_names := GFLayerMaskUtility.get_project_physics_layer_names(2)
var physics_3d_names := GFLayerMaskUtility.get_project_physics_layer_names(3)
```

该入口只读取 Project Settings 中的 2D / 3D Physics Layer Names，并返回 32 个槽位。它不缓存设置，也不创建 ProjectSettings 项；编辑器工具可以在需要时读取，运行时系统也可以改用项目自己的层名表来避免隐式依赖项目设置。

## 使用边界

`GFLayerMaskUtility` 只处理名称、索引和整数 bitmask。是否把 mask 用于射线、碰撞对象、命中盒、保存数据或网络同步，仍由项目层决定。
