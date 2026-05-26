# 存储后端与同步

`GFStorageBackend` 是可选的后端扩展接口，默认不参与 `GFStorageUtility` 的本地读写流程，避免把云同步、平台 SDK 或账号体系写进框架核心。

项目需要多端同步时，可以继承后端接口并在自己的存储系统里组合使用；遇到本地/远端字段冲突时，用 `GFStorageConflictReport` 描述 `file_name`、`key`、本地值、远端值、解决结果和元数据。

## 字典同步

需要把两个后端做一次通用字典同步时，可以注册或直接创建 `GFStorageSyncUtility`。它只读取 `GFStorageBackend.load_data()`、调用 `save_data()` 写回，并按策略处理文件级冲突。

默认策略会根据元数据中的 revision 或 timestamp 判断较新记录，无法判断时保留冲突并返回结构化报告。项目可以显式选择本地优先、远端优先、手动处理，或提供 resolver 回调生成合并结果：

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

未解决冲突是独立的终止状态：同步器会发出 `sync_conflict_detected` 和 `sync_conflict_unresolved`，结果中的 `status_name` 为 `conflict`，不会再发出 `sync_completed` 或 `sync_failed`。这样调用方可以明确区分“需要人工或项目策略处理的数据冲突”和“后端读写失败”。
