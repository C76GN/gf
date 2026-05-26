# 通用文件下载队列

这一页说明 `GFDownloadUtility` 如何下载远程文件、写入临时文件、提交目标文件，并处理续传、校验、暂停、取消和重试。

### 通用文件下载队列 (`GFDownloadUtility`)

`GFDownloadUtility` 面向补丁包、远程资源包、配置包或编辑器工具下载这类“写入本地文件”的通用流程。它和 `GFRemoteCacheUtility` 的边界不同：前者负责文件落盘、临时文件提交、可选续传、SHA-256 校验、暂停和取消；后者只负责轻量文本/JSON 请求和 TTL 缓存。

```gdscript
var downloads := Gf.get_utility(GFDownloadUtility) as GFDownloadUtility

downloads.enqueue_download(
	"https://example.com/catalog.zip",
	"user://catalog.zip",
	func(result: Dictionary) -> void:
		if bool(result["success"]):
			print("downloaded: ", result["target_path"])
	,
	{
		"resume": true,
		"expected_sha256": "",
		"max_retries": 2,
		"retry_delay_seconds": 0.5,
	}
)
```

`enqueue_download()` 返回任务 ID；`cancel(id, delete_temp)` 可取消等待中或进行中的任务，`pause()` / `resume()` 会暂停启动新任务并把当前任务保留到队首。每个任务由 `GFDownloadTask` 描述，结果字典会包含 `status`、`status_name`、`received_bytes`、`total_bytes`、`response_code`、`error`、`retry_count` 和项目传入的 `metadata`。下载成功后先写入临时文件，再提交到目标路径；如果启用 `resume` 且临时文件存在，会追加 `Range` 请求头并在服务器返回 `206` 时合并分段文件。`get_debug_snapshot()` 可被 `GFDiagnosticsUtility` 聚合到运行时工具快照中。

如果下载面向不稳定网络，可以在任务选项中设置 `max_retries` 和 `retry_delay_seconds`。下载器只会重试传输失败、无响应码、`408`、`425`、`429` 或 `5xx` 这类通常可恢复的失败；`4xx` 权限、缺失资源、校验失败、提交失败等不会被盲目重试。重试期间不会发出最终完成/失败信号，只有任务最终成功、失败或取消时才写入结果。

当目标文件已存在且任务设置 `overwrite = false` 时，下载器不会直接把已有文件视为成功。如果任务提供了 `expected_sha256`，会先校验目标文件；校验通过才返回 `from_existing_file` 结果，校验失败则进入失败状态并保留原文件。未提供 checksum 时，已有目标文件仍按“不可覆盖的已完成文件”处理。
