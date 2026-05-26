# 完整性校验

需要更严格的存档维护时，可以启用 codec 元信息、checksum 和版本迁移。

```gdscript
storage.include_storage_metadata = true
storage.use_integrity_checksum = true
storage.require_integrity_checksum = true
storage.save_version = 2
storage.default_values_for_new_keys = {
	"settings": {
		"assist_mode": false,
	},
}

storage.data_integrity_failed.connect(func(file_name: String, error: String) -> void:
	push_warning("%s failed integrity check: %s" % [file_name, error])
)
```

`use_integrity_checksum` 会在新写入载荷中写入 `_meta.checksum` 并在读取时校验。

从 `2.0.0` 起，启用完整性校验时默认要求载荷必须包含 checksum，缺失 checksum 会被视为读取失败。

迁移旧存档时可临时把 `GFStorageUtility.require_integrity_checksum` 或 `GFStorageCodec.require_integrity_checksum` 设为 `false`，读出旧数据后再用新设置写回。

JSON checksum 输入会按写盘后的 JSON 语义归一化，避免 64 位整数或 `StringName` 键经过 Godot JSON 往返后把合法载荷误判为损坏。

这不会改变 `decode()` 或 `load_data()` 返回的数据类型，也不会让 JSON 自动精确保留任意 64 位整数。

需要精确保存大整数时，应在业务 schema 中使用字符串、使用 `GFVariantJsonCodec` 的类型化 JSON 值，或改用 Binary 格式。
