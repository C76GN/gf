# 稳定 Key

`GFGridKey3D` 用有限范围 bit packing 把 `Vector3i` 格坐标和 `0..63` 的方向编号打包成稳定非负整数 key，避免项目层重复拼接字符串 key 或混用临时 hash。

默认坐标范围为 `-262144..262143`，超出范围会返回 `INVALID_KEY`。调用方可以按项目地图规模选择是否使用它。

```gdscript
var key := GFGridKey3D.pack_cell(Vector3i(-12, 4, 18), 3)
if key != GFGridKey3D.INVALID_KEY:
	var cell := GFGridKey3D.unpack_cell(key)
	var orientation := GFGridKey3D.unpack_orientation(key)

var position_key := GFGridKey3D.pack_position(
	unit_position,
	Vector3(2.0, 1.0, 2.0),
	Vector3.ZERO,
	facing_index
)
```
