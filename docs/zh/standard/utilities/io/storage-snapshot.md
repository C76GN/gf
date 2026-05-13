# 本地存储、编码、同步与快照

本页聚焦标准库的本地读写、编码、同步和快照历史。场景树存档图属于官方 Save 扩展。
## 本地存档管理器 (`GFStorageUtility`)

`GFStorageUtility` 是基于 Godot `user://` 的本地持久化工具。它负责把字典、槽位元数据和 `Resource` 文件写入项目可写目录，并在读取时执行 codec 解码、完整性校验、事务恢复和版本迁移；它不负责云同步、业务 schema 设计、玩家账号隔离或安全加密。

槽位存储会把核心数据和展示用 Metadata 分开，读档列表 UI 可以只读取 Metadata 与修改时间，不必加载完整存档载荷。`GFStorageCodec` 提供 JSON/Binary 编码、可选压缩、SHA-256 完整性校验、轻量 XOR 混淆和 `_meta` 版本信息。这里的混淆只用于降低误编辑概率，不能用于保护敏感数据。

同时原生支持 Godot 的 `Resource` 类型（如 `.tres` 或 `.res`）直接存取。

**如何使用：**
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

除槽位和字典读写外，`ensure_directory()`、`list_files()` 与 `delete_file()` 可用于管理同一存储根目录下的通用文件，例如列出本地缩略图、缓存 manifest 或项目自定义资源文件。它们复用 `GFStorageUtility` 的路径安全策略：默认拒绝绝对路径并阻止 `..` 跨目录；纯字典读写 API 会直接拒绝空 `file_name`，而不是写入内部兜底文件名。枚举结果返回存储相对路径，适合交给 `load_data()`、`load_resource()` 或项目自己的读取流程继续处理。槽位列表仍应优先使用 `list_slots()`，避免把内部事务文件、备份文件或项目临时文件混入读档 UI。

`GFStorageUtility` 的本地写入路径、文件操作和事务提交/恢复共用同一套内部策略，因此槽位存档、纯字典存档和异步纯字典存档会遵循一致的路径规整、目录创建、临时文件、备份文件与事务标记规则。项目层不应依赖 `.tmp`、`.bak`、`.txn` 这些内部文件，恢复流程会在下次读取、写入或槽位检查时自动收敛。

需要更严格的存档维护时，可以启用 codec 元信息、checksum 和版本迁移：

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

`use_integrity_checksum` 会在新写入载荷中写入 `_meta.checksum` 并在读取时校验；从 `2.0.0` 起，启用完整性校验时默认要求载荷必须包含 checksum，缺失 checksum 会被视为读取失败。迁移旧存档时可临时把 `GFStorageUtility.require_integrity_checksum` 或 `GFStorageCodec.require_integrity_checksum` 设为 `false`，读出旧数据后再用新设置写回。JSON checksum 输入会稳定规范化整数字面量，避免不同 Godot JSON 解析结果把合法载荷误判为损坏；这不会改变 `decode()` 或 `load_data()` 返回的数据类型。2.0 也默认关闭旧版纯 JSON 回退：当项目已经配置混淆、压缩或 Binary 格式时，解码失败不会再自动尝试按未混淆 JSON 读取原始 bytes；迁移旧文件时可临时启用 `allow_legacy_plain_json_fallback`。JSON 读取默认保留解析出的数字类型；如果旧存档列表或元数据依赖把接近整数的 float 归一为 int，可临时开启 `GFStorageUtility.normalize_json_numbers` 或 `GFStorageCodec.normalize_json_numbers` 后读出并重写。`allow_absolute_paths` 默认关闭，绝对路径会收敛回 `user://<save_dir_name>/` 下的同名文件；只有可信编辑器工具或迁移脚本确实需要写入外部路径时，才应显式设为 `true`。

`save_slot()` 只接受大于等于 0 的整数槽位；`load_slot_result()` / `load_slot_meta_result()` 可区分“合法空字典”和“文件缺失、非法槽位或解码失败”。异步 `save_data_async()` / `load_data_async()` 会按文件串行和线程预算调度；如果同一路径需要混合同步和异步读写，先调用 `wait_for_async_tasks()` 收敛已入队任务顺序，再执行同步 `save_data()` / `load_data()`。`dispose()` 会等待已开始的线程结束并发出对应完成信号，对尚未开始的队列任务发出失败结果，避免调用方一直等待完成通知。

项目如需复杂迁移，可继承 `GFStorageUtility` 并重写 `migrate_data(data, from_version, to_version)`；如果迁移只是按版本分段的小步骤，也可以用 `register_migration(from_version, to_version, callback)` 注册迁移链：

```gdscript
storage.save_version = 3
storage.register_migration(1, 2, func(data: Dictionary, _from: int, _to: int) -> Dictionary:
	data["settings"] = data.get("settings", {})
	return data
)
storage.register_migration(2, 3, func(data: Dictionary, _from: int, _to: int) -> Dictionary:
	data["profile_version"] = 3
	return data
)
```

如果已经注册了分段迁移，旧存档版本到当前 `save_version` 必须能解析出完整链路；缺失某一段时读取会失败并发出 `data_integrity_failed`，不会把旧结构伪标记成当前版本。只依赖 `default_values_for_new_keys` 补齐字段、且没有注册迁移步骤的项目仍可继续使用默认迁移路径。需要把“没有迁移步骤但版本升高”也视为失败时，设置 `strict_schema_migrations = true`。

`GFStorageBackend` 是可选的后端扩展接口，默认不参与 `GFStorageUtility` 的本地读写流程，避免把云同步、平台 SDK 或账号体系写进框架核心。项目需要多端同步时，可以继承后端接口并在自己的存储系统里组合使用；遇到本地/远端字段冲突时，用 `GFStorageConflictReport` 描述 `file_name`、`key`、本地值、远端值、解决结果和元数据。

需要把两个后端做一次通用字典同步时，可以注册或直接创建 `GFStorageSyncUtility`。它只读取 `GFStorageBackend.load_data()`、调用 `save_data()` 写回，并按策略处理文件级冲突；默认策略会根据元数据中的 revision 或 timestamp 判断较新记录，无法判断时保留冲突并返回结构化报告。项目可以显式选择本地优先、远端优先、手动处理，或提供 resolver 回调生成合并结果：

```gdscript
var sync := Gf.get_utility(GFStorageSyncUtility) as GFStorageSyncUtility
var result := sync.sync_data("profile.json", local_backend, remote_backend, {
	"strategy": GFStorageSyncUtility.ConflictStrategy.USE_NEWEST,
})

if not result["ok"] and result["status_name"] == &"conflict":
	print(result["conflicts"])

var merged := sync.sync_data("profile.json", local_backend, remote_backend, {
	"strategy": GFStorageSyncUtility.ConflictStrategy.CUSTOM,
	"resolver": func(_report: GFStorageConflictReport, local_record: Dictionary, remote_record: Dictionary, _options: Dictionary) -> Dictionary:
		return {
			"data": local_record["data"],
			"metadata": local_record["metadata"],
			"resolution": GFStorageConflictReport.Resolution.MERGED,
		}
})
```

同步器不枚举账号、不自动触发保存、不接入平台云服务，也不理解业务字段。后端元数据的 revision/timestamp 由项目写入；若没有可比较的元数据，应显式选择策略或使用自定义 resolver，避免框架替项目猜测数据所有权。

需要做“状态快照级别”的撤回、回滚或编辑器预览恢复时，可以注册 `GFSnapshotHistoryUtility`。它默认使用所属 `GFArchitecture.get_global_snapshot()` / `restore_global_snapshot()` 捕获和恢复已注册 Model 及可选命令历史，也可以通过回调接入任意项目自定义状态：

```gdscript
var snapshots := Gf.get_utility(GFSnapshotHistoryUtility) as GFSnapshotHistoryUtility
snapshots.max_history_size = 32
snapshots.capture({ "reason": "before_preview" })

# 修改项目状态后恢复上一份快照
snapshots.step_back()
```

如果状态不在 `GFArchitecture` 里，使用 `configure(capture_callback, restore_callback, options)` 明确传入捕获和恢复逻辑。`push_snapshot(data, metadata)` 可把外部已经生成的状态压入历史；`restore_index()` / `restore_snapshot_id()` 可按位置或稳定 ID 恢复；`get_debug_snapshot()` 会报告当前索引、可前进/后退状态和保留的 ID 列表。该工具只管理快照栈和深拷贝，不替代 `GFCommandHistoryUtility` 的逐命令 undo/redo，也不替代 `GFStorageUtility` 的持久化写盘。恢复快照涉及业务对象重建、命令反序列化或远端同步时，仍应由项目层提供对应 builder 或回调。

插件启用后也会在底部 `GF` 工作区中提供 `GF Save Viewer` 页面。它由标准库中的 `GFStorageViewerDock` 承载，用于按 codec 选项查看本地存档内容、校验状态并复制 JSON，方便调试而不绑定任何项目业务结构。

如果需要采集和恢复场景树节点状态，使用官方 Save 扩展的 `GFSaveGraphUtility` / `GFSaveScope`。标准库文档聚焦本地读写、编码、同步和快照能力；SaveGraph 的节点序列化器、槽位工作流和 pipeline trace 见 [Save 场景存档图](../../../extensions/save-graph/index.md)。
