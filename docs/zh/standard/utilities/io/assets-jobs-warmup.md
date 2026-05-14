# 资源加载、下载、任务队列与预热

这些 Utility 覆盖资源生命周期、下载队列、任务队列和渲染预热等 IO 与后台工作流程。

## 异步按需加载缓存池 (`GFAssetUtility`)

**应用场景：** 当项目需要按需加载特效、图标、UI 面板或关卡资源，并希望统一处理缓存、并发请求、取消和调试快照时，可以使用 `GFAssetUtility`。

**如何使用：**

```gdscript
var assets := Gf.get_utility(GFAssetUtility) as GFAssetUtility

# 异步加载一个带路径的资源。缓存命中时直接返回，
# 如果已有相同请求，则共用同一次加载；如果没有，则发起新的 threaded request。
assets.load_async("res://actors/runtime_actor.tscn", func(res: Resource) -> void:
	var actor_scene := res as PackedScene
	if actor_scene != null:
		add_child(actor_scene.instantiate())
)
```
它内置了 LRU （最近最少使用）算法上限，当缓存过大时会自动清理长期未被提取引用的资源。`max_cache_size = 0` 会禁用并清空缓存；`pin_cache(path)` 会用引用计数锁定关键资源，重复 pin 需要对应次数 `unpin_cache(path)` 后才会重新参与 LRU 淘汰。

```gdscript
assets.max_cache_size = 128
assets.load_async("res://ui/inventory_panel.tscn", _on_panel_loaded, "PackedScene")

if assets.is_loading("res://ui/inventory_panel.tscn", "PackedScene"):
	assets.cancel("res://ui/inventory_panel.tscn", "PackedScene")

assets.pin_cache("res://ui/common_icons.tres")
```

同一路径的并发加载会合并到同一个 threaded request；如果已存在请求或缓存的资源类型与新的 `type_hint` 明显不兼容，回调会收到 `null`。命中缓存时回调会同步执行。`cancel()` 只取消 GF 侧的回调分发并把请求标记为已取消，不会中止 Godot 已发起的 `ResourceLoader` 线程请求；如果资源随后成功完成，工具仍会把它写入缓存，方便后续请求复用。`get_debug_snapshot()` 会报告缓存、pending、pinned 路径、引用计数和资源分组数量，便于诊断面板或测试读取。工具只管理 `ResourceLoader` 请求、回调分发和内存缓存，不负责实例化节点、引用计数之外的资源生命周期或远程下载。

当资源会被多个短生命周期对象持有时，可以用 `GFAssetHandle` 表达所有权。句柄会增加路径引用计数并锁定缓存，`release()` 后才允许 LRU 淘汰；如果传入 owner，`release_owner(owner)` 或 Node 退出树时会释放该 owner 的引用。资源分组适合 UI 包、关卡包或主题包这类“成组预热、成组卸载”的通用流程，不要求项目把业务语义写进工具层。

```gdscript
assets.load_handle_async(
	"res://ui/inventory_panel.tscn",
	func(handle: GFAssetHandle) -> void:
		if handle == null:
			return
		var scene := handle.get_resource() as PackedScene
		add_child(scene.instantiate())
		handle.release(),
	"PackedScene",
	self,
	&"inventory_ui"
)

assets.preload_group_async(
	&"battle_ui",
	[
		{ "path": "res://ui/battle_hud.tscn", "type_hint": "PackedScene" },
		{ "path": "res://ui/skill_icon_atlas.tres", "type_hint": "Resource" },
	],
	func(report: Dictionary) -> void:
		print(report["ok"])
)
```

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
	}
)
```

`enqueue_download()` 返回任务 ID；`cancel(id, delete_temp)` 可取消等待中或进行中的任务，`pause()` / `resume()` 会暂停启动新任务并把当前任务保留到队首。每个任务由 `GFDownloadTask` 描述，结果字典会包含 `status`、`status_name`、`received_bytes`、`total_bytes`、`response_code`、`error` 和项目传入的 `metadata`。下载成功后先写入临时文件，再提交到目标路径；如果启用 `resume` 且临时文件存在，会追加 `Range` 请求头并在服务器返回 `206` 时合并分段文件。`get_debug_snapshot()` 可被 `GFDiagnosticsUtility` 聚合到运行时工具快照中。

当目标文件已存在且任务设置 `overwrite = false` 时，下载器不会直接把已有文件视为成功。如果任务提供了 `expected_sha256`，会先校验目标文件；校验通过才返回 `from_existing_file` 结果，校验失败则进入失败状态并保留原文件。未提供 checksum 时，已有目标文件仍按“不可覆盖的已完成文件”处理。

### 通用任务队列 (`GFJobQueueUtility` / `GFJob`)

`GFJobQueueUtility` 适合承载“先排队，稍后由项目系统消费”的通用任务，例如导入、批处理、后台计算、生成预览或任意需要进度反馈的工作。它只管理等待、执行中、完成、失败、取消、暂停和调试快照，不内置线程模型、下载协议或业务含义：

```gdscript
var jobs := Gf.get_utility(GFJobQueueUtility) as GFJobQueueUtility

var job := jobs.enqueue(&"build", { "path": "res://data/items.json" }, { "kind": "import" })
var active := jobs.start_next_job(&"build")
if active != null:
	jobs.update_job_progress(active.job_id, 0.5, "half")
	jobs.complete_job(active.job_id, { "count": 120 })
```

如果项目希望同步消费一项任务，可以使用 `run_next_job(queue_name, processor)`，回调返回 `false` 或 `{ "ok": false, "error": "..." }` 时会进入失败状态。`pause_queue()` / `resume_queue()` 只影响后续 `start_next_job()`，不会取消已经开始的任务；需要真正中止外部工作时，项目层应在自己的处理器里响应取消状态。`get_debug_snapshot()` 会报告队列数量、等待任务、完成和失败保留数量，适合诊断面板读取。

当任务需要由场景节点持续消费时，可以挂一个 `GFJobWorker`。它通过 `queue_utility` 或全局架构找到 `GFJobQueueUtility`，按 `batch_size` 调用项目提供的 `processor`，并把返回值写回完成或失败状态：

```gdscript
var worker := GFJobWorker.new()
worker.queue_name = &"import"
worker.batch_size = 4
worker.set_processor(func(job: GFJob) -> Dictionary:
	return { "ok": true, "result": job.data }
)
add_child(worker)
```

`GFJobWorker` 不创建线程，也不解释任务数据；如果处理器返回 Signal，Worker 会等待信号发出，并把信号结果按同步返回值同样写回完成或失败状态。信号不携带结果时视为完成。这个模式适合桥接项目自己的异步导入、下载、预览生成或工具流程。

### 渲染资源预热 (`GFRenderWarmupManifest` / `GFRenderWarmupUtility`)

当项目希望在切场景、打开复杂 UI 或进入高负载玩法前提前触碰材质、Mesh、Texture 或 Shader 资源时，可以把这些资源写入 `GFRenderWarmupManifest`，再交给 `GFRenderWarmupUtility` 按帧预算处理。它只负责加载和触碰渲染资源 RID，不创建业务对象、不规定关卡流程，也不替项目决定预热时机。

```gdscript
var manifest := GFRenderWarmupManifest.new()
manifest.manifest_id = &"battle_intro"
manifest.add_resource_path("res://characters/hero_material.tres", &"material", "Material")
manifest.add_resource_path("res://ui/battle_icons.png", &"texture", "Texture2D")

var warmup := Gf.get_utility(GFRenderWarmupUtility) as GFRenderWarmupUtility
warmup.default_entries_per_tick = 2
warmup.queue_manifest(manifest)
```

如果资源已经在场景树中，可以从节点树收集通用渲染资源：

```gdscript
var manifest := warmup.build_manifest_from_tree(get_tree().current_scene, {
	"manifest_id": &"current_scene",
	"include_meshes": true,
	"include_materials": true,
	"include_textures": true,
})
warmup.warmup_manifest_now(manifest)
```

如果资源来自场景文件，也可以用 `build_manifest_from_scene()` 或 `build_manifest_from_scene_path()` 创建清单；这只扫描实例化后的通用渲染资源，并在扫描完成后释放临时场景。预热执行支持 `max_seconds` 时间预算，队列和立即预热都会在预算耗尽时返回 `stopped_by_budget`，方便项目把预热拆到多个帧或多个加载阶段。

默认 `touch_mode` 只加载资源并触碰 RID。需要让材质或 Mesh 参与一次离屏渲染时，可传 `GFRenderWarmupUtility.TouchMode.TEMPORARY_RENDER_NODES`，并按需指定 `temporary_parent` 与 `temporary_viewport_size`；预热工具会创建 `SubViewport` 临时节点，下一次 `tick()` 或显式 `release_temporary_render_nodes()` 会清理它们。这个模式仍然只处理通用渲染准备，不实例化业务对象，也不承诺完全消除驱动层 shader 编译。

外部工具如果需要先清洗或检查条目字典，可以调用 `GFRenderWarmupManifest.normalize_entry(entry)`，得到包含 `resource_path`、`resource`、`kind`、`type_hint` 和独立 `metadata` 副本的规范化结构；预热队列内部也使用同一套规则。

`keep_resources_cached` 默认会保留已加载资源引用，避免刚预热完就被释放；需要释放时调用 `release_cached_resources()`。`instantiate_packed_scenes` 默认关闭，因为实例化场景可能触发项目脚本副作用；只有当项目明确需要扫描 PackedScene 内部渲染资源时才开启。预热工具不保证消除所有驱动层 shader 编译成本，它提供的是一个稳定、可诊断、可分批的资源准备边界。
