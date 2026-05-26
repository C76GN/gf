# 本地存档管理器

`GFStorageUtility` 是基于 Godot `user://` 的本地持久化工具。它负责把字典、槽位元数据和 `Resource` 文件写入项目可写目录，并在读取时执行 codec 解码、完整性校验、事务恢复和版本迁移。

槽位存储会把核心数据和展示用 Metadata 分开，读档列表 UI 可以只读取 Metadata 与修改时间，不必加载完整存档载荷。

`GFStorageCodec` 提供 JSON/Binary 编码、可选压缩、SHA-256 完整性校验、轻量 XOR 混淆和框架存储元信息。若业务载荷根字典本身已有 `_meta` 字段，codec 会把框架元信息写入独立 envelope，读取时仍还原用户自己的 `_meta`，避免存档格式和业务数据抢同一个键。这里的混淆只用于降低误编辑概率，不能用于保护敏感数据。

同时原生支持 Godot 的 `Resource` 类型直接存取，例如 `.tres` 或 `.res`。

## 基础用法

```gdscript
var storage := Gf.get_utility(GFStorageUtility) as GFStorageUtility

# -- 字典与槽位存档 --
# 保存槽位，后一个字典是高层预览专用的 Metadata
storage.save_slot(1, {"player_hp": 100}, {"play_time": "12:00", "level": 5})

# 在读档选单展示
var meta := storage.load_slot_meta(1)
print(meta.get("level"))

# 枚举所有有效槽位，只读取 metadata 和修改时间
for slot_info in storage.list_slots():
	print(slot_info["slot_id"], slot_info["metadata"])

# 正式进入游戏后再读取完整核心数据
var full_data := storage.load_slot(1)

# -- Resource 存档 --
var my_res := Resource.new()
storage.save_resource("my_custom_resource.tres", my_res)

var loaded_res := storage.load_resource("my_custom_resource.tres")
```

## 文件管理

除槽位和字典读写外，`ensure_directory()`、`list_files()` 与 `delete_file()` 可用于管理同一存储根目录下的通用文件，例如列出本地缩略图、缓存 manifest 或项目自定义资源文件。

它们复用 `GFStorageUtility` 的路径安全策略：默认拒绝绝对路径并阻止 `..` 跨目录；纯字典读写 API 会直接拒绝空 `file_name`，而不是写入内部兜底文件名。

递归枚举默认限制深度和返回数量，可通过 `list_files(..., { "max_scan_depth": 64, "max_file_count": 20000 })` 调整。枚举结果返回存储相对路径，适合交给 `load_data()`、`load_resource()` 或项目自己的读取流程继续处理。

槽位列表仍应优先使用 `list_slots()`，避免把内部事务文件、备份文件或项目临时文件混入读档 UI。
