# Standard API

Module: `standard`

## Classes

- [`GFAnalyticsConfig`](#gfanalyticsconfig)
- [`GFAnalyticsUtility`](#gfanalyticsutility)
- [`GFAssetHandle`](#gfassethandle)
- [`GFAssetUtility`](#gfassetutility)
- [`GFAsyncBatch`](#gfasyncbatch)
- [`GFAudioBackend`](#gfaudiobackend)
- [`GFAudioBackendCapability`](#gfaudiobackendcapability)
- [`GFAudioBank`](#gfaudiobank)
- [`GFAudioBankMounter`](#gfaudiobankmounter)
- [`GFAudioBankTools`](#gfaudiobanktools)
- [`GFAudioCatalogProvider`](#gfaudiocatalogprovider)
- [`GFAudioClip`](#gfaudioclip)
- [`GFAudioEmitterHandle`](#gfaudioemitterhandle)
- [`GFAudioEvent`](#gfaudioevent)
- [`GFAudioParameter`](#gfaudioparameter)
- [`GFAudioSpatialSettings`](#gfaudiospatialsettings)
- [`GFAudioState`](#gfaudiostate)
- [`GFAudioSwitch`](#gfaudioswitch)
- [`GFAudioUtility`](#gfaudioutility)
- [`GFBackgroundWorkTask`](#gfbackgroundworktask)
- [`GFBackgroundWorkUtility`](#gfbackgroundworkutility)
- [`GFBatchedLogSink`](#gfbatchedlogsink)
- [`GFBigNumber`](#gfbignumber)
- [`GFBlackboardEntry`](#gfblackboardentry)
- [`GFBlackboardSchema`](#gfblackboardschema)
- [`GFBudgetLedger`](#gfbudgetledger)
- [`GFBuildInfo`](#gfbuildinfo)
- [`GFBuildInfoExportPlugin`](#gfbuildinfoexportplugin)
- [`GFBuildInfoUtility`](#gfbuildinfoutility)
- [`GFCallableTargetRef`](#gfcallabletargetref)
- [`GFCommandHistoryUtility`](#gfcommandhistoryutility)
- [`GFCommandSequence`](#gfcommandsequence)
- [`GFConfigBuildProfile`](#gfconfigbuildprofile)
- [`GFConfigLocalizationKeyValidationRule`](#gfconfiglocalizationkeyvalidationrule)
- [`GFConfigNotDefaultValidationRule`](#gfconfignotdefaultvalidationrule)
- [`GFConfigProvider`](#gfconfigprovider)
- [`GFConfigRangeValidationRule`](#gfconfigrangevalidationrule)
- [`GFConfigReferenceResolver`](#gfconfigreferenceresolver)
- [`GFConfigRegexValidationRule`](#gfconfigregexvalidationrule)
- [`GFConfigResourcePathValidationRule`](#gfconfigresourcepathvalidationrule)
- [`GFConfigSetValidationRule`](#gfconfigsetvalidationrule)
- [`GFConfigSizeValidationRule`](#gfconfigsizevalidationrule)
- [`GFConfigTableColumn`](#gfconfigtablecolumn)
- [`GFConfigTableImporter`](#gfconfigtableimporter)
- [`GFConfigTableIndexDefinition`](#gfconfigtableindexdefinition)
- [`GFConfigTableMergePolicy`](#gfconfigtablemergepolicy)
- [`GFConfigTableMergeTools`](#gfconfigtablemergetools)
- [`GFConfigTableReference`](#gfconfigtablereference)
- [`GFConfigTableSchema`](#gfconfigtableschema)
- [`GFConfigValidationReport`](#gfconfigvalidationreport)
- [`GFConfigValidationRule`](#gfconfigvalidationrule)
- [`GFConsoleCommandDefinition`](#gfconsolecommanddefinition)
- [`GFConsoleUtility`](#gfconsoleutility)
- [`GFControlValueAdapter`](#gfcontrolvalueadapter)
- [`GFCurve2DMath`](#gfcurve2dmath)
- [`GFDebugDrawUtility`](#gfdebugdrawutility)
- [`GFDebugOverlayUtility`](#gfdebugoverlayutility)
- [`GFDiagnosticsDock`](#gfdiagnosticsdock)
- [`GFDiagnosticsUtility`](#gfdiagnosticsutility)
- [`GFDisplaySettingsUtility`](#gfdisplaysettingsutility)
- [`GFDownloadTask`](#gfdownloadtask)
- [`GFDownloadUtility`](#gfdownloadutility)
- [`GFDragDropUtility`](#gfdragdroputility)
- [`GFDragSession`](#gfdragsession)
- [`GFDropZone`](#gfdropzone)
- [`GFFixedDecimal`](#gffixeddecimal)
- [`GFFormBinder`](#gfformbinder)
- [`GFFormula`](#gfformula)
- [`GFFormulaParameter`](#gfformulaparameter)
- [`GFFormulaSet`](#gfformulaset)
- [`GFGraphLayoutUtility`](#gfgraphlayoututility)
- [`GFGraphMath`](#gfgraphmath)
- [`GFGrid3DMath`](#gfgrid3dmath)
- [`GFGridGenerationPipeline2D`](#gfgridgenerationpipeline2d)
- [`GFGridGenerationStep2D`](#gfgridgenerationstep2d)
- [`GFGridKey3D`](#gfgridkey3d)
- [`GFGridMath`](#gfgridmath)
- [`GFGridOccupancy`](#gfgridoccupancy)
- [`GFGridPlaneMapper3D`](#gfgridplanemapper3d)
- [`GFGridSelection2D`](#gfgridselection2d)
- [`GFHexGridMath`](#gfhexgridmath)
- [`GFHttpRequestBuilder`](#gfhttprequestbuilder)
- [`GFHttpResponse`](#gfhttpresponse)
- [`GFInputAction`](#gfinputaction)
- [`GFInputAssistUtility`](#gfinputassistutility)
- [`GFInputBinding`](#gfinputbinding)
- [`GFInputChordTrigger`](#gfinputchordtrigger)
- [`GFInputConflictAnalyzer`](#gfinputconflictanalyzer)
- [`GFInputContext`](#gfinputcontext)
- [`GFInputCurveModifier`](#gfinputcurvemodifier)
- [`GFInputDeadzoneModifier`](#gfinputdeadzonemodifier)
- [`GFInputDetector`](#gfinputdetector)
- [`GFInputDeviceAssignment`](#gfinputdeviceassignment)
- [`GFInputDeviceTextProvider`](#gfinputdevicetextprovider)
- [`GFInputDeviceUtility`](#gfinputdeviceutility)
- [`GFInputDirectionHistory`](#gfinputdirectionhistory)
- [`GFInputFormatter`](#gfinputformatter)
- [`GFInputHoldTrigger`](#gfinputholdtrigger)
- [`GFInputIconAtlasProvider`](#gfinputiconatlasprovider)
- [`GFInputIconProvider`](#gfinputiconprovider)
- [`GFInputMagnitudeModifier`](#gfinputmagnitudemodifier)
- [`GFInputMapRangeModifier`](#gfinputmaprangemodifier)
- [`GFInputMapping`](#gfinputmapping)
- [`GFInputMappingDock`](#gfinputmappingdock)
- [`GFInputMappingUtility`](#gfinputmappingutility)
- [`GFInputModifier`](#gfinputmodifier)
- [`GFInputNormalizeModifier`](#gfinputnormalizemodifier)
- [`GFInputPlayback`](#gfinputplayback)
- [`GFInputPressedTrigger`](#gfinputpressedtrigger)
- [`GFInputProfileBank`](#gfinputprofilebank)
- [`GFInputPulseTrigger`](#gfinputpulsetrigger)
- [`GFInputRecording`](#gfinputrecording)
- [`GFInputReleasedTrigger`](#gfinputreleasedtrigger)
- [`GFInputRemapConfig`](#gfinputremapconfig)
- [`GFInputScaleModifier`](#gfinputscalemodifier)
- [`GFInputSequenceBranch`](#gfinputsequencebranch)
- [`GFInputSequenceStep`](#gfinputsequencestep)
- [`GFInputSequenceTrigger`](#gfinputsequencetrigger)
- [`GFInputSignClampModifier`](#gfinputsignclampmodifier)
- [`GFInputSwizzleModifier`](#gfinputswizzlemodifier)
- [`GFInputTapTrigger`](#gfinputtaptrigger)
- [`GFInputTextProvider`](#gfinputtextprovider)
- [`GFInputTrigger`](#gfinputtrigger)
- [`GFInputVirtualCursorModifier`](#gfinputvirtualcursormodifier)
- [`GFJob`](#gfjob)
- [`GFJobQueueUtility`](#gfjobqueueutility)
- [`GFJobWorker`](#gfjobworker)
- [`GFJsonLineLogSink`](#gfjsonlinelogsink)
- [`GFLogSink`](#gflogsink)
- [`GFLogUtility`](#gflogutility)
- [`GFModalAction`](#gfmodalaction)
- [`GFModalConfig`](#gfmodalconfig)
- [`GFModalResult`](#gfmodalresult)
- [`GFMutationBatch`](#gfmutationbatch)
- [`GFNodeState`](#gfnodestate)
- [`GFNodeStateBehavior`](#gfnodestatebehavior)
- [`GFNodeStateCondition`](#gfnodestatecondition)
- [`GFNodeStateGroup`](#gfnodestategroup)
- [`GFNodeStateMachine`](#gfnodestatemachine)
- [`GFNodeStateMachineConfig`](#gfnodestatemachineconfig)
- [`GFNodeStateMachineDock`](#gfnodestatemachinedock)
- [`GFNodeStateMachineValidator`](#gfnodestatemachinevalidator)
- [`GFNodeTreeOps`](#gfnodetreeops)
- [`GFNotificationUtility`](#gfnotificationutility)
- [`GFNumberFormatter`](#gfnumberformatter)
- [`GFObjectPoolUtility`](#gfobjectpoolutility)
- [`GFPattern2D`](#gfpattern2d)
- [`GFPointerActivityUtility`](#gfpointeractivityutility)
- [`GFProgressionMath`](#gfprogressionmath)
- [`GFQuadTreeUtility`](#gfquadtreeutility)
- [`GFRefCountedPool`](#gfrefcountedpool)
- [`GFRegionMap2D`](#gfregionmap2d)
- [`GFRegionMap3D`](#gfregionmap3d)
- [`GFRemoteCacheUtility`](#gfremotecacheutility)
- [`GFRenderWarmupManifest`](#gfrenderwarmupmanifest)
- [`GFRenderWarmupUtility`](#gfrenderwarmuputility)
- [`GFReplayTimeline`](#gfreplaytimeline)
- [`GFRequestEnvelope`](#gfrequestenvelope)
- [`GFRequestOutboxUtility`](#gfrequestoutboxutility)
- [`GFResultDictionary`](#gfresultdictionary)
- [`GFRichTextFormatter`](#gfrichtextformatter)
- [`GFRuntimeInspectorUtility`](#gfruntimeinspectorutility)
- [`GFRuntimeTunableProperty`](#gfruntimetunableproperty)
- [`GFScenePreloadEntry`](#gfscenepreloadentry)
- [`GFScenePreloadMap`](#gfscenepreloadmap)
- [`GFSceneTransitionConfig`](#gfscenetransitionconfig)
- [`GFSceneUtility`](#gfsceneutility)
- [`GFSeedUtility`](#gfseedutility)
- [`GFSequenceContext`](#gfsequencecontext)
- [`GFSequenceStep`](#gfsequencestep)
- [`GFSettingDefinition`](#gfsettingdefinition)
- [`GFSettingsUtility`](#gfsettingsutility)
- [`GFSignalBridge`](#gfsignalbridge)
- [`GFSignalBridgeBinding`](#gfsignalbridgebinding)
- [`GFSignalConnection`](#gfsignalconnection)
- [`GFSignalGraphDock`](#gfsignalgraphdock)
- [`GFSignalRuntimeProbe`](#gfsignalruntimeprobe)
- [`GFSignalSourceRef`](#gfsignalsourceref)
- [`GFSignalUtility`](#gfsignalutility)
- [`GFSnapshotHistoryUtility`](#gfsnapshothistoryutility)
- [`GFSourceSpan`](#gfsourcespan)
- [`GFSpatialHash3D`](#gfspatialhash3d)
- [`GFState`](#gfstate)
- [`GFStateMachine`](#gfstatemachine)
- [`GFSteeringAcceleration`](#gfsteeringacceleration)
- [`GFSteeringAgent`](#gfsteeringagent)
- [`GFSteeringBehaviorResource`](#gfsteeringbehaviorresource)
- [`GFSteeringBehaviorStack`](#gfsteeringbehaviorstack)
- [`GFSteeringMath`](#gfsteeringmath)
- [`GFStorageBackend`](#gfstoragebackend)
- [`GFStorageCodec`](#gfstoragecodec)
- [`GFStorageConflictReport`](#gfstorageconflictreport)
- [`GFStorageSyncUtility`](#gfstoragesyncutility)
- [`GFStorageUtility`](#gfstorageutility)
- [`GFStorageViewerDock`](#gfstorageviewerdock)
- [`GFSupportReportUtility`](#gfsupportreportutility)
- [`GFSurfaceUtility`](#gfsurfaceutility)
- [`GFTagExpression`](#gftagexpression)
- [`GFTagQuery`](#gftagquery)
- [`GFTagSet`](#gftagset)
- [`GFTagSourceAdapter`](#gftagsourceadapter)
- [`GFTextAutoFit`](#gftextautofit)
- [`GFTextFitter`](#gftextfitter)
- [`GFTileMapCache`](#gftilemapcache)
- [`GFTileMetadataLayer`](#gftilemetadatalayer)
- [`GFTileRuleSet`](#gftileruleset)
- [`GFTimeUtility`](#gftimeutility)
- [`GFTimedTextEntry`](#gftimedtextentry)
- [`GFTimedTextImporter`](#gftimedtextimporter)
- [`GFTimedTextTrack`](#gftimedtexttrack)
- [`GFTimerUtility`](#gftimerutility)
- [`GFTouchButton`](#gftouchbutton)
- [`GFTouchJoystick`](#gftouchjoystick)
- [`GFUIRoute`](#gfuiroute)
- [`GFUIRouterUtility`](#gfuirouterutility)
- [`GFUIUtility`](#gfuiutility)
- [`GFUndoableCommand`](#gfundoablecommand)
- [`GFUuid`](#gfuuid)
- [`GFValidationDiagnosticAdapter`](#gfvalidationdiagnosticadapter)
- [`GFValidationIssue`](#gfvalidationissue)
- [`GFValidationJUnitExporter`](#gfvalidationjunitexporter)
- [`GFValidationReport`](#gfvalidationreport)
- [`GFValidationReportDictionary`](#gfvalidationreportdictionary)
- [`GFValidationRule`](#gfvalidationrule)
- [`GFValidationRunner`](#gfvalidationrunner)
- [`GFValidationSuite`](#gfvalidationsuite)
- [`GFValueIndex`](#gfvalueindex)
- [`GFVariantData`](#gfvariantdata)
- [`GFVariantJsonCodec`](#gfvariantjsoncodec)
- [`GFViewportUtility`](#gfviewportutility)
- [`GFVirtualInputSource`](#gfvirtualinputsource)
- [`GFWaitSequenceStep`](#gfwaitsequencestep)
- [`GFWeightedEntry`](#gfweightedentry)
- [`GFWeightedTable`](#gfweightedtable)

## GFAnalyticsConfig

- Path: `addons/gf/standard/utilities/analytics/gf_analytics_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFAnalyticsConfig: 通用事件分析配置。 默认不开启网络依赖；若未配置 endpoint，flush 会以 dry-run 成功完成， 便于项目在本地或测试环境中保持同一套调用路径。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用事件收集。

#### `endpoint_url`

- API: `public`

```gdscript
var endpoint_url: String = ""
```

HTTP 上报地址。为空时不会发起网络请求。

#### `flush_interval_seconds`

- API: `public`

```gdscript
var flush_interval_seconds: float = 5.0:
```

上报间隔，单位秒。小于等于 0 时不自动上报。

#### `batch_size`

- API: `public`

```gdscript
var batch_size: int = 20:
```

单批最大事件数。

#### `max_queue_size`

- API: `public`

```gdscript
var max_queue_size: int = 1000:
```

本地队列最大事件数。

#### `auto_capture_context`

- API: `public`

```gdscript
var auto_capture_context: bool = true
```

是否自动附加运行环境上下文。

#### `app_version`

- API: `public`

```gdscript
var app_version: String = ""
```

可选应用版本。

#### `persist_client_id`

- API: `public`

```gdscript
var persist_client_id: bool = true
```

是否持久化匿名 client id。

#### `client_id_storage_path`

- API: `public`

```gdscript
var client_id_storage_path: String = "user://gf_analytics_client.cfg"
```

client id 持久化文件路径。

#### `flush_on_shutdown`

- API: `public`

```gdscript
var flush_on_shutdown: bool = true
```

应用关闭通知到来时是否尝试 flush 剩余事件。

#### `compress_payload`

- API: `public`
- Since: `3.20.0`

```gdscript
var compress_payload: bool = false
```

是否使用 gzip 压缩 HTTP 上报请求体。

#### `headers`

- API: `public`

```gdscript
var headers: Dictionary = {}
```

自定义 HTTP Header。

Schemas:

- `headers`: Dictionary[String, String] mapping header names to header values.

### Methods

#### `build_headers`

- API: `public`

```gdscript
func build_headers() -> PackedStringArray:
```

构建 HTTP Header 数组。

Returns: Header 字符串数组。

## GFAnalyticsUtility

- Path: `addons/gf/standard/utilities/analytics/gf_analytics_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAnalyticsUtility: 通用事件分析与批量上报工具。 负责事件排队、环境上下文采集、批量 flush 与失败重排。 endpoint 为空时不会访问网络，可作为本地事件汇聚或测试通道使用。

### Signals

#### `event_tracked`

- API: `public`

```gdscript
signal event_tracked(event_name: StringName, event_data: Dictionary)
```

事件进入队列时发出。

Parameters:

| Name | Description |
|---|---|
| `event_name` | 事件名。 |
| `event_data` | 已入队事件数据。 |

Schemas:

- `event_data`: Dictionary with `event`, `client_id`, `session_id`, `timestamp`, `properties`, and optional `context`.

#### `flush_started`

- API: `public`

```gdscript
signal flush_started(batch: Array)
```

开始 flush 时发出。

Parameters:

| Name | Description |
|---|---|
| `batch` | 本次 flush 的事件批次。 |

Schemas:

- `batch`: Array[Dictionary] of queued analytics events.

#### `flush_completed`

- API: `public`

```gdscript
signal flush_completed(result: Dictionary)
```

flush 完成时发出。失败结果也会通过该信号通知。

Parameters:

| Name | Description |
|---|---|
| `result` | flush 结果。 |

Schemas:

- `result`: Dictionary with at least `success: bool`; may include `accepted`, `error`, `dry_run`, or transport-specific fields.

#### `flush_failed`

- API: `public`

```gdscript
signal flush_failed(result: Dictionary)
```

flush 失败时额外发出。

Parameters:

| Name | Description |
|---|---|
| `result` | 失败结果。 |

Schemas:

- `result`: Dictionary with `success: false` and an optional `error` field.

### Properties

#### `config`

- API: `public`

```gdscript
var config: GFAnalyticsConfig = GFAnalyticsConfig.new()
```

当前配置。

#### `payload_builder`

- API: `public`

```gdscript
var payload_builder: Callable = Callable()
```

可选载荷构建回调。签名为 func(batch: Array) -> Dictionary。

#### `transport_callback`

- API: `public`

```gdscript
var transport_callback: Callable = Callable()
```

可选自定义传输回调。签名为 func(payload: Dictionary) -> Dictionary。

#### `response_parser`

- API: `public`

```gdscript
var response_parser: Callable = Callable()
```

可选响应解析回调。签名为 func(response_code: int, body: PackedByteArray, fallback_accepted: int) -> Dictionary。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化事件队列、会话 ID 和关闭监听。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放事件队列、HTTP 节点和关闭监听。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `configure`

- API: `public`

```gdscript
func configure(analytics_config: GFAnalyticsConfig) -> void:
```

替换分析配置。

Parameters:

| Name | Description |
|---|---|
| `analytics_config` | 新配置。 |

#### `identify`

- API: `public`

```gdscript
func identify(client_id: String) -> void:
```

设置稳定客户端标识。

Parameters:

| Name | Description |
|---|---|
| `client_id` | 客户端标识。 |

#### `track`

- API: `public`

```gdscript
func track(event_name: StringName, properties: Dictionary = {}) -> void:
```

记录一个事件。

Parameters:

| Name | Description |
|---|---|
| `event_name` | 事件名。 |
| `properties` | 事件属性。 |

Schemas:

- `properties`: Dictionary[String, Variant] copied into the queued event properties.

#### `flush`

- API: `public`

```gdscript
func flush() -> void:
```

立即上报一批事件。

#### `shutdown`

- API: `public`

```gdscript
func shutdown(flush_remaining: bool = true) -> void:
```

停止继续接收事件，并可选 flush 当前队列。

Parameters:

| Name | Description |
|---|---|
| `flush_remaining` | 是否尝试 flush 剩余事件。 |

#### `get_queue_size`

- API: `public`

```gdscript
func get_queue_size() -> int:
```

获取当前队列长度。

Returns: 队列长度。

#### `get_session_id`

- API: `public`

```gdscript
func get_session_id() -> String:
```

获取当前会话标识。

Returns: 会话标识。

#### `get_client_id`

- API: `public`

```gdscript
func get_client_id() -> String:
```

获取当前客户端标识。

Returns: 客户端标识。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue() -> void:
```

清空本地事件队列。

#### `capture_context`

- API: `public`

```gdscript
func capture_context() -> Dictionary:
```

采集通用运行环境上下文。

Returns: 上下文字典。

Schemas:

- `return`: Dictionary with platform, engine, engine_version, screen size, locale, and timezone fields.

## GFAssetHandle

- Path: `addons/gf/standard/utilities/assets/gf_asset_handle.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFAssetHandle: GFAssetUtility 创建的资源所有权句柄。 句柄只表达“某个调用方正在持有某个资源路径”，不规定资源业务语义。 调用 release() 会把引用归还给 GFAssetUtility；句柄释放前，对应缓存路径不会被 LRU 淘汰。

### Properties

#### `path`

- API: `public`

```gdscript
var path: String = ""
```

资源路径。

#### `type_hint`

- API: `public`

```gdscript
var type_hint: String = ""
```

请求时使用的类型提示。

#### `group_id`

- API: `public`

```gdscript
var group_id: StringName = &""
```

可选资源分组。

#### `resource`

- API: `public`

```gdscript
var resource: Resource = null
```

资源实例。

### Methods

#### `get_resource`

- API: `public`

```gdscript
func get_resource() -> Resource:
```

获取资源实例。

Returns: 资源实例；句柄已释放时返回 null。

#### `get_owner_id`

- API: `public`

```gdscript
func get_owner_id() -> int:
```

获取拥有者实例 ID。

Returns: 拥有者实例 ID；未绑定 owner 时为 0。

#### `is_released`

- API: `public`

```gdscript
func is_released() -> bool:
```

检查句柄是否已释放。

Returns: 已释放返回 true。

#### `is_valid`

- API: `public`

```gdscript
func is_valid() -> bool:
```

检查句柄当前是否仍能访问资源。

Returns: 可访问资源返回 true。

#### `release`

- API: `public`

```gdscript
func release() -> bool:
```

释放句柄持有的资源引用。

Returns: 成功释放返回 true。

## GFAssetUtility

- Path: `addons/gf/standard/utilities/assets/gf_asset_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAssetUtility: 异步资源加载管理器，带 LRU 缓存。 封装 Godot 的 threaded `ResourceLoader` 请求， 用于避免大资源同步加载阻塞主线程，并在完成后统一分发回调与维护缓存。

### Signals

#### `asset_handle_acquired`

- API: `public`

```gdscript
signal asset_handle_acquired(handle: GFAssetHandle)
```

创建资源句柄时发出。

Parameters:

| Name | Description |
|---|---|
| `handle` | 新创建的资源句柄。 |

#### `asset_handle_released`

- API: `public`

```gdscript
signal asset_handle_released(path: String, reference_count: int)
```

资源句柄释放时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `reference_count` | 剩余引用数量。 |

#### `asset_group_preloaded`

- API: `public`

```gdscript
signal asset_group_preloaded(group_id: StringName, report: Dictionary)
```

资源分组预加载完成时发出。

Parameters:

| Name | Description |
|---|---|
| `group_id` | 分组标识。 |
| `report` | 预加载报告。 |

Schemas:

- `report`: Dictionary with `ok: bool`, `group_id: StringName`, `paths: PackedStringArray`, `failed_paths: PackedStringArray`, `total: int`, and `completed: int`.

### Properties

#### `max_cache_size`

- API: `public`

```gdscript
var max_cache_size: int:
```

LRU 缓存最大容量；设为 `0` 时表示禁用缓存。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化资源加载工具的运行时状态。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放资源加载工具持有的运行时状态。

#### `load_async`

- API: `public`

```gdscript
func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
```

发起异步资源加载。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标资源路径。 |
| `on_loaded` | 加载完成后的回调。 |
| `type_hint` | 可选资源类型提示。 |

#### `load_handle_async`

- API: `public`

```gdscript
func load_handle_async( path: String, on_loaded: Callable, type_hint: String = "", owner: Object = null, group_id: StringName = &"" ) -> void:
```

异步加载资源并在成功后返回所有权句柄。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标资源路径。 |
| `on_loaded` | 加载完成回调，签名为 func(handle: GFAssetHandle)；失败时传入 null。 |
| `type_hint` | 可选资源类型提示。 |
| `owner` | 可选拥有者。若为 Node，会在退出树时自动释放其持有的句柄引用。 |
| `group_id` | 可选资源分组。 |

#### `acquire_handle`

- API: `public`

```gdscript
func acquire_handle( path: String, owner: Object = null, group_id: StringName = &"", type_hint: String = "", resource_override: Resource = null ) -> GFAssetHandle:
```

为已缓存或指定资源创建所有权句柄。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `owner` | 可选拥有者。若为 Node，会在退出树时自动释放其持有的句柄引用。 |
| `group_id` | 可选资源分组。 |
| `type_hint` | 可选资源类型提示。 |
| `resource_override` | 可选资源实例；为空时使用当前缓存。 |

Returns: 成功时返回句柄；资源不可用时返回 null。

#### `release_handle`

- API: `public`

```gdscript
func release_handle(handle: GFAssetHandle) -> bool:
```

释放资源句柄。

Parameters:

| Name | Description |
|---|---|
| `handle` | 要释放的资源句柄。 |

Returns: 释放成功返回 true。

#### `release_owner`

- API: `public`

```gdscript
func release_owner(owner: Object) -> int:
```

释放指定 owner 持有的所有资源引用。

Parameters:

| Name | Description |
|---|---|
| `owner` | 拥有者对象。 |

Returns: 释放的引用数量。

#### `get_asset_reference_count`

- API: `public`

```gdscript
func get_asset_reference_count(path: String) -> int:
```

获取指定资源路径当前句柄引用数量。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

Returns: 引用数量。

#### `register_group_path`

- API: `public`

```gdscript
func register_group_path(group_id: StringName, path: String, pin: bool = false) -> void:
```

注册资源路径到分组。

Parameters:

| Name | Description |
|---|---|
| `group_id` | 分组标识。 |
| `path` | 资源路径。 |
| `pin` | 是否以分组名义锁定缓存，避免 LRU 淘汰。 |

#### `get_group_paths`

- API: `public`

```gdscript
func get_group_paths(group_id: StringName) -> PackedStringArray:
```

获取分组中的资源路径。

Parameters:

| Name | Description |
|---|---|
| `group_id` | 分组标识。 |

Returns: 路径列表。

#### `preload_group_async`

- API: `public`

```gdscript
func preload_group_async( group_id: StringName, entries: Array, on_completed: Callable = Callable(), options: Dictionary = {} ) -> void:
```

异步预加载资源分组。

Parameters:

| Name | Description |
|---|---|
| `group_id` | 分组标识。 |
| `entries` | 路径字符串，或包含 path/type_hint 字段的字典数组。 |
| `on_completed` | 完成回调，签名为 func(report: Dictionary)。 |
| `options` | 可选参数，支持 pin_cache。 |

Schemas:

- `entries`: Array[String|Dictionary] where dictionary entries may contain `path: String` and `type_hint: String`.
- `options`: Dictionary with optional `pin_cache: bool`.

#### `unload_group`

- API: `public`

```gdscript
func unload_group(group_id: StringName, remove_unreferenced_cache: bool = false) -> void:
```

卸载资源分组。

Parameters:

| Name | Description |
|---|---|
| `group_id` | 分组标识。 |
| `remove_unreferenced_cache` | 是否移除没有句柄引用的缓存项。 |

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float = 0.0) -> void:
```

驱动异步加载轮询。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 为兼容统一 tick 签名而保留的参数。 |

#### `get_cached`

- API: `public`

```gdscript
func get_cached(path: String) -> Resource:
```

获取缓存中的资源。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

Returns: 命中缓存时返回资源，否则返回 `null`。

#### `is_loading`

- API: `public`

```gdscript
func is_loading(path: String, type_hint: String = "") -> bool:
```

检查指定路径是否正在加载中。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `type_hint` | 可选资源类型提示；为空时只检查路径。 |

Returns: 正在加载时返回 `true`。

#### `is_cached`

- API: `public`

```gdscript
func is_cached(path: String) -> bool:
```

检查指定路径是否已缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

Returns: 已缓存时返回 `true`。

#### `cancel`

- API: `public`

```gdscript
func cancel(path: String, type_hint: String = "") -> void:
```

取消指定路径的异步加载请求。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `type_hint` | 可选资源类型提示；为空时取消该路径的当前请求。 |

#### `put_cache`

- API: `public`

```gdscript
func put_cache(path: String, resource: Resource) -> void:
```

手动写入缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `resource` | 要缓存的资源实例。 |

#### `remove_cache`

- API: `public`

```gdscript
func remove_cache(path: String) -> void:
```

手动移除缓存项。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

#### `clear_cache`

- API: `public`

```gdscript
func clear_cache() -> void:
```

清空全部缓存。

#### `get_cache_count`

- API: `public`

```gdscript
func get_cache_count() -> int:
```

获取当前缓存数量。

Returns: 当前缓存中的资源数。

#### `pin_cache`

- API: `public`

```gdscript
func pin_cache(path: String) -> void:
```

锁定指定缓存路径，使其不参与 LRU 淘汰。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

#### `unpin_cache`

- API: `public`

```gdscript
func unpin_cache(path: String) -> void:
```

解除指定缓存路径的 LRU 锁定。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

#### `is_cache_pinned`

- API: `public`

```gdscript
func is_cache_pinned(path: String) -> bool:
```

检查指定缓存路径是否已被锁定。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |

Returns: 已锁定返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取资源加载工具诊断快照。

Returns: 诊断快照字典。

Schemas:

- `return`: Dictionary with cache, pending, pinned, reference count, and group count diagnostic fields.

## GFAsyncBatch

- Path: `addons/gf/standard/utilities/io/gf_async_batch.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFAsyncBatch: 通用异步结果批处理器。 用于等待一组 GFHttpResponse 或手动标记的异步任务完成，并统一汇总结果。 它不负责调度具体任务，只观察任务何时完成。

### Signals

#### `item_completed`

- API: `public`

```gdscript
signal item_completed(key: Variant, result: Variant)
```

单个条目完成后发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 条目标识。 |
| `result` | 条目结果。 |

Schemas:

- `key`: Variant，调用方持有的条目标识，会作为结果字典的键。
- `result`: Variant，已完成条目的结果。

#### `completed`

- API: `public`

```gdscript
signal completed(results: Dictionary)
```

全部条目完成后发出。

Parameters:

| Name | Description |
|---|---|
| `results` | 批处理结果字典。 |

Schemas:

- `results`: Dictionary，将每个被等待的 key 映射到对应完成结果。

### Methods

#### `add_item`

- API: `public`

```gdscript
func add_item(key: Variant, metadata: Dictionary = {}) -> bool:
```

添加一个等待条目。

Parameters:

| Name | Description |
|---|---|
| `key` | 条目标识。 |
| `metadata` | 条目元数据。 |

Returns: 是否添加成功。

Schemas:

- `key`: Variant，调用方持有的条目标识，会作为结果字典的键。
- `metadata`: Dictionary，调用方持有并关联到该条目的元数据。

#### `watch_response`

- API: `public`

```gdscript
func watch_response(response: GFHttpResponse, key: Variant = null) -> bool:
```

监听 GFHttpResponse。

Parameters:

| Name | Description |
|---|---|
| `response` | 响应对象。 |
| `key` | 条目标识；为空时使用响应 URL。 |

Returns: 是否开始监听。

Schemas:

- `key`: Variant，调用方持有的条目标识；为 null 时使用 response.url。

#### `mark_completed`

- API: `public`

```gdscript
func mark_completed(key: Variant, result: Variant = null) -> bool:
```

手动标记条目完成。

Parameters:

| Name | Description |
|---|---|
| `key` | 条目标识。 |
| `result` | 条目结果。 |

Returns: 是否成功标记。

Schemas:

- `key`: Variant，调用方持有的条目标识，会作为结果字典的键。
- `result`: Variant，已完成条目的结果。

#### `is_completed`

- API: `public`

```gdscript
func is_completed() -> bool:
```

是否所有条目都已完成。

Returns: 所有条目完成时返回 true。

#### `get_count`

- API: `public`

```gdscript
func get_count() -> int:
```

获取条目数量。

Returns: 当前批处理中的条目数量。

#### `get_completed_count`

- API: `public`

```gdscript
func get_completed_count() -> int:
```

获取已完成条目数量。

Returns: 已完成条目的数量。

#### `get_results`

- API: `public`

```gdscript
func get_results() -> Dictionary:
```

获取结果字典。

Returns: key -> result 的字典副本。

Schemas:

- `return`: Dictionary，将每个被等待的 key 映射到对应完成结果或 null。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空批处理。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 count、completed_count、completed 和 keys。

## GFAudioBackend

- Path: `addons/gf/standard/utilities/audio/gf_audio_backend.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFAudioBackend: GFAudioUtility 的可插拔音频后端协议。 默认实现不处理任何请求。项目或扩展可继承它，把部分音频事件转交给 外部中间件、平台接口或自定义混音系统；未声明可处理的请求会回退到 Godot 默认播放器。

### Properties

#### `capabilities`

- API: `public`

```gdscript
var capabilities: GFAudioBackendCapability = GFAudioBackendCapability.new()
```

后端能力声明。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放后端状态。

#### `get_host`

- API: `public`

```gdscript
func get_host() -> Object:
```

获取宿主音频工具。

Returns: 宿主对象；不存在时返回 null。

#### `get_capabilities`

- API: `public`

```gdscript
func get_capabilities() -> GFAudioBackendCapability:
```

获取后端能力声明副本。

Returns: 后端能力声明。

#### `has_capability`

- API: `public`

```gdscript
func has_capability(capability_id: StringName) -> bool:
```

检查后端是否声明了指定能力。

Parameters:

| Name | Description |
|---|---|
| `capability_id` | 能力标识。 |

Returns: 支持返回 true。

#### `can_handle_path`

- API: `public`

```gdscript
func can_handle_path(_path: String, _channel: StringName, _context: Dictionary = {}) -> bool:
```

判断后端是否可处理指定资源路径。

Parameters:

| Name | Description |
|---|---|
| `_path` | 音频资源路径或后端事件路径。 |
| `_channel` | 通道标识，如 bgm、sfx、ambient。 |
| `_context` | 请求上下文。 |

Returns: 可处理时返回 true。

Schemas:

- `_context`: 请求上下文 Dictionary；键和值由 GFAudioUtility 或具体后端约定。

#### `can_handle_clip`

- API: `public`

```gdscript
func can_handle_clip(_clip: GFAudioClip, _channel: StringName, _context: Dictionary = {}) -> bool:
```

判断后端是否可处理指定音频片段。

Parameters:

| Name | Description |
|---|---|
| `_clip` | 音频片段配置。 |
| `_channel` | 通道标识，如 bgm、sfx、ambient。 |
| `_context` | 请求上下文。 |

Returns: 可处理时返回 true。

Schemas:

- `_context`: 请求上下文 Dictionary；键和值由 GFAudioUtility 或具体后端约定。

#### `play_bgm_path`

- API: `public`

```gdscript
func play_bgm_path(_path: String, _options: Dictionary = {}) -> bool:
```

播放 BGM 路径。

Parameters:

| Name | Description |
|---|---|
| `_path` | 音频资源路径或后端事件路径。 |
| `_options` | 请求选项。 |

Returns: 已处理返回 true。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、fade_seconds、loop 和 metadata。

#### `play_bgm_clip`

- API: `public`

```gdscript
func play_bgm_clip(_clip: GFAudioClip, _options: Dictionary = {}) -> bool:
```

播放 BGM Clip。

Parameters:

| Name | Description |
|---|---|
| `_clip` | 音频片段配置。 |
| `_options` | 请求选项。 |

Returns: 已处理返回 true。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、fade_seconds、loop 和 metadata。

#### `stop_bgm`

- API: `public`

```gdscript
func stop_bgm(_fade_seconds: float = 0.0) -> bool:
```

停止 BGM。

Parameters:

| Name | Description |
|---|---|
| `_fade_seconds` | 淡出秒数。 |

Returns: 已处理返回 true。

#### `pause_bgm`

- API: `public`

```gdscript
func pause_bgm(_fade_seconds: float = 0.0) -> bool:
```

暂停 BGM。

Parameters:

| Name | Description |
|---|---|
| `_fade_seconds` | 淡出到暂停的秒数。 |

Returns: 已处理返回 true。

#### `resume_bgm`

- API: `public`

```gdscript
func resume_bgm(_from_position: float = -1.0, _fade_seconds: float = 0.0) -> bool:
```

恢复 BGM。

Parameters:

| Name | Description |
|---|---|
| `_from_position` | 大于等于 0 时从指定秒数恢复。 |
| `_fade_seconds` | 淡入秒数。 |

Returns: 已处理返回 true。

#### `seek_bgm`

- API: `public`

```gdscript
func seek_bgm(_position_seconds: float) -> bool:
```

跳转当前 BGM 播放位置。

Parameters:

| Name | Description |
|---|---|
| `_position_seconds` | 目标秒数。 |

Returns: 已处理返回 true。

#### `get_bgm_playback_position`

- API: `public`

```gdscript
func get_bgm_playback_position() -> float:
```

获取当前 BGM 播放位置。

Returns: 播放秒数；负数表示后端不处理该查询。

#### `is_bgm_paused`

- API: `public`

```gdscript
func is_bgm_paused() -> bool:
```

查询 BGM 是否暂停。

Returns: 已暂停返回 true。

#### `play_ambient_path`

- API: `public`

```gdscript
func play_ambient_path(_path: String, _channel: StringName = &"default", _options: Dictionary = {}) -> bool:
```

播放环境音路径。

Parameters:

| Name | Description |
|---|---|
| `_path` | 音频资源路径或后端事件路径。 |
| `_channel` | 环境音通道。 |
| `_options` | 请求选项。 |

Returns: 已处理返回 true。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、fade_seconds 和 metadata。

#### `play_ambient_clip`

- API: `public`

```gdscript
func play_ambient_clip(_clip: GFAudioClip, _channel: StringName = &"default", _options: Dictionary = {}) -> bool:
```

播放环境音 Clip。

Parameters:

| Name | Description |
|---|---|
| `_clip` | 音频片段配置。 |
| `_channel` | 环境音通道。 |
| `_options` | 请求选项。 |

Returns: 已处理返回 true。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、fade_seconds 和 metadata。

#### `stop_ambient`

- API: `public`

```gdscript
func stop_ambient(_channel: StringName = &"default", _fade_seconds: float = 0.0) -> bool:
```

停止环境音通道。

Parameters:

| Name | Description |
|---|---|
| `_channel` | 环境音通道。 |
| `_fade_seconds` | 淡出秒数。 |

Returns: 已处理返回 true。

#### `stop_all_ambient`

- API: `public`

```gdscript
func stop_all_ambient(_fade_seconds: float = 0.0) -> bool:
```

停止全部环境音。

Parameters:

| Name | Description |
|---|---|
| `_fade_seconds` | 淡出秒数。 |

Returns: 已处理返回 true。

#### `is_ambient_playing`

- API: `public`

```gdscript
func is_ambient_playing(_channel: StringName = &"default") -> bool:
```

查询环境音通道是否播放中。

Parameters:

| Name | Description |
|---|---|
| `_channel` | 环境音通道。 |

Returns: 后端通道正在播放时返回 true。

#### `play_sfx_path`

- API: `public`

```gdscript
func play_sfx_path(_path: String, _options: Dictionary = {}) -> GFAudioEmitterHandle:
```

播放 SFX 路径。

Parameters:

| Name | Description |
|---|---|
| `_path` | 音频资源路径或后端事件路径。 |
| `_options` | 请求选项。 |

Returns: 控制句柄；未处理返回 null。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、owner、channel 和 metadata。

#### `play_sfx_clip`

- API: `public`

```gdscript
func play_sfx_clip(_clip: GFAudioClip, _options: Dictionary = {}) -> GFAudioEmitterHandle:
```

播放 SFX Clip。

Parameters:

| Name | Description |
|---|---|
| `_clip` | 音频片段配置。 |
| `_options` | 请求选项。 |

Returns: 控制句柄；未处理返回 null。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、owner、channel 和 metadata。

#### `stop_all_sfx`

- API: `public`

```gdscript
func stop_all_sfx(_fade_seconds: float = 0.0) -> bool:
```

停止全部 SFX。

Parameters:

| Name | Description |
|---|---|
| `_fade_seconds` | 淡出秒数。 |

Returns: 已处理返回 true。

#### `play_spatial_sfx_clip`

- API: `public`

```gdscript
func play_spatial_sfx_clip( _clip: GFAudioClip, _source: Node, _follow_source: bool = false, _options: Dictionary = {} ) -> GFAudioEmitterHandle:
```

播放空间 SFX Clip。

Parameters:

| Name | Description |
|---|---|
| `_clip` | 音频片段配置。 |
| `_source` | 2D 或 3D 声源节点。 |
| `_follow_source` | 是否跟随声源。 |
| `_options` | 请求选项。 |

Returns: 控制句柄；未处理返回 null。

Schemas:

- `_options`: 请求选项 Dictionary；常见字段包含 volume_db、pitch_scale、owner、channel、follow_source、spatial_settings 和 metadata。

#### `can_handle_event`

- API: `public`

```gdscript
func can_handle_event(_event: GFAudioEvent, _options: Dictionary = {}) -> bool:
```

判断后端是否可处理资源化音频事件。

Parameters:

| Name | Description |
|---|---|
| `_event` | 音频事件。 |
| `_options` | 请求选项。 |

Returns: 可处理时返回 true。

Schemas:

- `_options`: 请求选项 Dictionary；键和值由 GFAudioUtility 或具体后端约定。

#### `post_event`

- API: `public`

```gdscript
func post_event(_event: GFAudioEvent, _options: Dictionary = {}) -> GFAudioEmitterHandle:
```

发布资源化音频事件。

Parameters:

| Name | Description |
|---|---|
| `_event` | 音频事件。 |
| `_options` | 请求选项。 |

Returns: 控制句柄；未处理返回 null。

Schemas:

- `_options`: 请求选项 Dictionary；键和值由 GFAudioUtility 或具体后端约定。

#### `set_parameter`

- API: `public`

```gdscript
func set_parameter(_parameter: GFAudioParameter) -> bool:
```

设置音频参数。

Parameters:

| Name | Description |
|---|---|
| `_parameter` | 参数请求。 |

Returns: 已处理返回 true。

#### `set_state`

- API: `public`

```gdscript
func set_state(_state: GFAudioState) -> bool:
```

设置音频状态。

Parameters:

| Name | Description |
|---|---|
| `_state` | 状态请求。 |

Returns: 已处理返回 true。

#### `set_switch`

- API: `public`

```gdscript
func set_switch(_switch: GFAudioSwitch) -> bool:
```

设置音频开关。

Parameters:

| Name | Description |
|---|---|
| `_switch` | 开关请求。 |

Returns: 已处理返回 true。

#### `set_bus_volume`

- API: `public`

```gdscript
func set_bus_volume(_bus_name: String, _volume_linear: float) -> bool:
```

设置总线音量。

Parameters:

| Name | Description |
|---|---|
| `_bus_name` | 总线名或后端通道名。 |
| `_volume_linear` | 线性音量。 |

Returns: 已处理返回 true。

#### `get_bus_volume`

- API: `public`

```gdscript
func get_bus_volume(_bus_name: String) -> float:
```

获取总线音量。返回负数表示未处理。

Parameters:

| Name | Description |
|---|---|
| `_bus_name` | 总线名或后端通道名。 |

Returns: 线性音量；负数表示后端不处理该总线。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取后端调试快照。

Returns: 调试数据。

Schemas:

- `return`: 调试快照 Dictionary；键和值由具体后端约定。

## GFAudioBackendCapability

- Path: `addons/gf/standard/utilities/audio/gf_audio_backend_capability.gd`
- Extends: `Resource`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFAudioBackendCapability: 音频后端能力声明。 用布尔能力与元数据描述一个后端能处理哪些通用音频请求。

### Properties

#### `supports_bgm`

- API: `public`

```gdscript
var supports_bgm: bool = false
```

是否支持 BGM。

#### `supports_sfx`

- API: `public`

```gdscript
var supports_sfx: bool = false
```

是否支持 SFX。

#### `supports_ambient`

- API: `public`

```gdscript
var supports_ambient: bool = false
```

是否支持环境音。

#### `supports_spatial_sfx`

- API: `public`

```gdscript
var supports_spatial_sfx: bool = false
```

是否支持空间音效。

#### `supports_events`

- API: `public`

```gdscript
var supports_events: bool = false
```

是否支持资源化事件。

#### `supports_parameters`

- API: `public`

```gdscript
var supports_parameters: bool = false
```

是否支持参数写入。

#### `supports_states`

- API: `public`

```gdscript
var supports_states: bool = false
```

是否支持状态写入。

#### `supports_switches`

- API: `public`

```gdscript
var supports_switches: bool = false
```

是否支持开关写入。

#### `supports_listeners`

- API: `public`

```gdscript
var supports_listeners: bool = false
```

是否支持监听器。

#### `supports_async_loading`

- API: `public`

```gdscript
var supports_async_loading: bool = false
```

是否支持异步加载或卸载。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目层或调试面板展示。

Schemas:

- `metadata`: 后端能力元数据 Dictionary；键和值由具体后端或项目工具约定。

### Methods

#### `has_capability`

- API: `public`

```gdscript
func has_capability(capability_id: StringName) -> bool:
```

检查能力是否存在。

Parameters:

| Name | Description |
|---|---|
| `capability_id` | 能力标识。 |

Returns: 支持返回 true。

#### `duplicate_capability`

- API: `public`

```gdscript
func duplicate_capability() -> GFAudioBackendCapability:
```

创建同内容拷贝。

Returns: 新能力声明。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 能力字典。

Schemas:

- `return`: 能力 Dictionary，包含 bgm、sfx、ambient、spatial_sfx、events、parameters、states、switches、listeners、async_loading 和 metadata 字段。

## GFAudioBank

- Path: `addons/gf/standard/utilities/audio/gf_audio_bank.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFAudioBank: 音频片段配置集合。 用 StringName 管理一组 `GFAudioClip`，便于 UI、表现动作或项目配置 通过稳定 ID 播放音频。单个 ID 可保存一个片段或多个候选片段。

### Enums

#### `LifecycleState`

- API: `public`

```gdscript
enum LifecycleState { ## 尚未加载。 UNLOADED, ## 正在加载。 LOADING, ## 已加载。 LOADED, ## 加载失败。 FAILED, }
```

音频集合加载状态。

### Properties

#### `clips`

- API: `public`

```gdscript
var clips: Dictionary = {}
```

音频片段表。

Schemas:

- `clips`: Key 为 StringName 片段 ID，Value 为 GFAudioClip 或 GFAudioClip 数组。

#### `fallback_separator`

- API: `public`

```gdscript
var fallback_separator: String = "+"
```

分层事件 ID 的回退分隔符。例如 `ui+confirm+primary` 可回退到 `ui+confirm` 再到 `ui`。

#### `lifecycle_state`

- API: `public`

```gdscript
var lifecycle_state: LifecycleState = LifecycleState.UNLOADED
```

加载状态。框架只记录状态，不假设具体加载后端。

#### `lifecycle_reason`

- API: `public`

```gdscript
var lifecycle_reason: StringName = &""
```

最近一次加载或卸载结果原因。

### Methods

#### `set_clip`

- API: `public`

```gdscript
func set_clip(clip_id: StringName, clip: GFAudioClip) -> void:
```

设置一个音频片段。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |
| `clip` | 片段配置。 |

#### `set_clips`

- API: `public`

```gdscript
func set_clips(clip_id: StringName, clip_list: Array[GFAudioClip]) -> void:
```

设置一个音频片段候选列表。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |
| `clip_list` | 片段候选列表。 |

Schemas:

- `clip_list`: GFAudioClip 候选数组。

#### `get_clip`

- API: `public`

```gdscript
func get_clip(clip_id: StringName) -> GFAudioClip:
```

获取音频片段。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |

Returns: 片段配置；多个候选时返回第一个有效片段，不存在时返回 null。

#### `get_clips`

- API: `public`

```gdscript
func get_clips(clip_id: StringName) -> Array[GFAudioClip]:
```

获取音频片段候选列表。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |

Returns: 片段候选列表。

Schemas:

- `return`: GFAudioClip 候选数组。

#### `get_weighted_clip`

- API: `public`

```gdscript
func get_weighted_clip(clip_id: StringName, rng: RandomNumberGenerator = null) -> GFAudioClip:
```

按候选权重获取片段。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |
| `rng` | 可选随机数生成器；为空时返回第一个有效片段。 |

Returns: 片段配置；不存在时返回 null。

#### `get_clip_with_fallback`

- API: `public`

```gdscript
func get_clip_with_fallback(clip_id: StringName, rng: RandomNumberGenerator = null) -> GFAudioClip:
```

按 ID 获取片段；找不到时按 fallback_separator 逐级回退。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |
| `rng` | 可选随机数生成器。 |

Returns: 片段配置；不存在时返回 null。

#### `resolve_clip`

- API: `public`

```gdscript
func resolve_clip(clip_id: StringName, rng: RandomNumberGenerator = null) -> Dictionary:
```

解析片段并返回诊断报告。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |
| `rng` | 可选随机数生成器。 |

Returns: 解析报告。

Schemas:

- `return`: Dictionary，包含 ok、requested_id、resolved_id、fallback_used、attempted_ids 和 clip 字段。

#### `has_clip`

- API: `public`

```gdscript
func has_clip(clip_id: StringName) -> bool:
```

检查是否存在指定片段。

Parameters:

| Name | Description |
|---|---|
| `clip_id` | 片段标识。 |

Returns: 存在时返回 true。

#### `get_clip_ids`

- API: `public`

```gdscript
func get_clip_ids() -> PackedStringArray:
```

获取全部片段 ID。

Returns: 按字典序排列的片段 ID。

#### `set_lifecycle_state`

- API: `public`

```gdscript
func set_lifecycle_state(state: LifecycleState, reason: StringName = &"") -> void:
```

设置音频集合加载状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 新状态。 |
| `reason` | 可选原因。 |

#### `get_lifecycle_snapshot`

- API: `public`

```gdscript
func get_lifecycle_snapshot() -> Dictionary:
```

获取加载状态快照。

Returns: 状态快照字典。

Schemas:

- `return`: Dictionary，包含 state、reason 和 clip_count 字段。

#### `validate_bank`

- API: `public`

```gdscript
func validate_bank(check_resource_exists: bool = false) -> GFValidationReport:
```

校验音频集合。

Parameters:

| Name | Description |
|---|---|
| `check_resource_exists` | 是否检查 path 指向的资源存在。 |

Returns: 校验报告。

## GFAudioBankMounter

- Path: `addons/gf/standard/utilities/audio/gf_audio_bank_mounter.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFAudioBankMounter: 场景生命周期驱动的音频集合挂载节点。 进入树时把 `GFAudioBank` 注册到 `GFAudioUtility`，退出树时按需恢复或卸载， 让场景、UI 或模块可以拥有自己的音频事件集合而不写全局业务逻辑。

### Signals

#### `bank_mounted`

- API: `public`

```gdscript
signal bank_mounted(bank_id: StringName)
```

音频集合挂载完成时发出。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |

#### `bank_unmounted`

- API: `public`

```gdscript
signal bank_unmounted(bank_id: StringName)
```

音频集合卸载完成时发出。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |

### Properties

#### `bank_id`

- API: `public`

```gdscript
var bank_id: StringName = &""
```

音频集合标识。

#### `bank`

- API: `public`

```gdscript
var bank: GFAudioBank = null
```

音频集合资源。

#### `mount_on_ready`

- API: `public`

```gdscript
var mount_on_ready: bool = true
```

ready 后是否自动挂载。

#### `unmount_on_exit`

- API: `public`

```gdscript
var unmount_on_exit: bool = true
```

退出树时是否自动卸载。

#### `restore_previous_bank`

- API: `public`

```gdscript
var restore_previous_bank: bool = true
```

卸载时是否恢复同 ID 的旧音频集合。

#### `audio_utility`

- API: `public`

```gdscript
var audio_utility: GFAudioUtility = null
```

可选音频工具实例；为空时从全局架构查询。

### Methods

#### `set_audio_utility`

- API: `public`

```gdscript
func set_audio_utility(utility: GFAudioUtility) -> void:
```

设置音频工具实例。

Parameters:

| Name | Description |
|---|---|
| `utility` | 音频工具实例。 |

#### `mount`

- API: `public`

```gdscript
func mount() -> bool:
```

挂载音频集合。

Returns: 挂载成功返回 true。

#### `unmount`

- API: `public`

```gdscript
func unmount() -> bool:
```

卸载音频集合。

Returns: 卸载成功返回 true。

#### `is_mounted`

- API: `public`

```gdscript
func is_mounted() -> bool:
```

检查音频集合是否已挂载。

Returns: 已挂载返回 true。

## GFAudioBankTools

- Path: `addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAudioBankTools: 音频集合扫描、导入和校验辅助。 面向编辑器工具和构建脚本复用；它只生成 `GFAudioBank` / `GFAudioClip` 配置，不接管运行时播放策略。

### Enums

#### `ClipIdMode`

- API: `public`

```gdscript
enum ClipIdMode { ## 使用文件名，不包含扩展名。 BASENAME, ## 使用相对 base_path 的路径，不包含扩展名。 RELATIVE_PATH, ## 使用完整资源路径，不包含扩展名。 FULL_PATH, }
```

从音频路径生成片段 ID 的方式。

### Constants

#### `AUDIO_EXTENSIONS`

- API: `public`

```gdscript
const AUDIO_EXTENSIONS: PackedStringArray = ["wav", "ogg", "mp3", "opus"]
```

默认音频扩展名白名单，不包含点号。

#### `DEFAULT_EXCLUDED_PATHS`

- API: `public`

```gdscript
const DEFAULT_EXCLUDED_PATHS: PackedStringArray = ["res://addons"]
```

默认排除的扫描路径。

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认递归扫描深度上限。

#### `DEFAULT_MAX_AUDIO_PATHS`

- API: `public`

```gdscript
const DEFAULT_MAX_AUDIO_PATHS: int = 10000
```

默认单次扫描收集的音频路径数量上限。

### Methods

#### `is_audio_path`

- API: `public`

```gdscript
static func is_audio_path(path: String, extensions: PackedStringArray = AUDIO_EXTENSIONS) -> bool:
```

判断路径是否指向 GF 默认支持的音频扩展名。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或文件名。 |
| `extensions` | 可选扩展名白名单，不包含点号。 |

Returns: 是音频路径时返回 true。

#### `scan_audio_paths`

- API: `public`

```gdscript
static func scan_audio_paths(root_path: String = "res://", options: Dictionary = {}) -> PackedStringArray:
```

递归扫描音频路径。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扫描起点，通常是 res:// 下的目录。 |
| `options` | 可选项，支持 recursive、include_addons、excluded_paths、extensions、max_scan_depth 与 max_audio_paths。 |

Returns: 按字典序排序的音频路径。

Schemas:

- `options`: Dictionary，可包含 recursive、include_addons、excluded_paths、extensions、max_scan_depth 和 max_audio_paths 字段。

#### `create_bank_from_paths`

- API: `public`

```gdscript
static func create_bank_from_paths(paths: PackedStringArray, options: Dictionary = {}) -> GFAudioBank:
```

从路径列表创建新的音频集合。

Parameters:

| Name | Description |
|---|---|
| `paths` | 音频资源路径列表。 |
| `options` | 可选项，支持 id_mode、base_path、path_separator、strip_extension、bus_name、volume_db、pitch_scale。 |

Returns: 新建的音频集合。

Schemas:

- `options`: Dictionary，可包含 id_mode、base_path、path_separator、strip_extension、bus_name、volume_db、pitch_scale 和 overwrite 字段。

#### `create_bank_from_scan`

- API: `public`

```gdscript
static func create_bank_from_scan(root_path: String = "res://", options: Dictionary = {}) -> GFAudioBank:
```

扫描目录并创建新的音频集合。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扫描起点，通常是 res://audio。 |
| `options` | 可选项，同时传给 scan_audio_paths() 与 create_bank_from_paths()。 |

Returns: 新建的音频集合。

Schemas:

- `options`: Dictionary，可同时包含扫描选项和片段导入选项。

#### `add_paths_to_bank`

- API: `public`

```gdscript
static func add_paths_to_bank( bank: GFAudioBank, paths: PackedStringArray, options: Dictionary = {} ) -> GFValidationReport:
```

将路径列表加入音频集合。

Parameters:

| Name | Description |
|---|---|
| `bank` | 要写入的音频集合。 |
| `paths` | 音频资源路径列表。 |
| `options` | 可选项，支持 id_mode、base_path、path_separator、strip_extension、overwrite、bus_name、volume_db、pitch_scale。 |

Returns: 导入报告。

Schemas:

- `options`: Dictionary，可包含 id_mode、base_path、path_separator、strip_extension、overwrite、bus_name、volume_db 和 pitch_scale 字段。

#### `sync_bank_from_scan`

- API: `public`

```gdscript
static func sync_bank_from_scan( bank: GFAudioBank, root_path: String = "res://", options: Dictionary = {} ) -> GFValidationReport:
```

扫描目录并同步到已有音频集合。

Parameters:

| Name | Description |
|---|---|
| `bank` | 要写入的音频集合。 |
| `root_path` | 扫描起点，通常是 res://audio。 |
| `options` | 可选项，同时传给 scan_audio_paths() 与 add_paths_to_bank()。 |

Returns: 导入报告。

Schemas:

- `options`: Dictionary，可同时包含扫描选项和片段导入选项。

#### `validate_bank_playback`

- API: `public`

```gdscript
static func validate_bank_playback(bank: GFAudioBank, options: Dictionary = {}) -> GFValidationReport:
```

校验音频集合是否适合交给 GFAudioUtility 播放。

Parameters:

| Name | Description |
|---|---|
| `bank` | 要校验的音频集合。 |
| `options` | 可选项，支持 check_resource_exists、check_bus_exists、extensions。 |

Returns: 校验报告。

Schemas:

- `options`: Dictionary，可包含 check_resource_exists、check_bus_exists 和 extensions 字段。

#### `make_clip_id`

- API: `public`

```gdscript
static func make_clip_id(path: String, options: Dictionary = {}) -> StringName:
```

按选项从路径生成稳定片段 ID。

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源路径。 |
| `options` | 可选项，支持 id_mode、base_path、path_separator、strip_extension。 |

Returns: 片段 ID。

Schemas:

- `options`: Dictionary，可包含 id_mode、base_path、path_separator 和 strip_extension 字段。

## GFAudioCatalogProvider

- Path: `addons/gf/standard/utilities/audio/gf_audio_catalog_provider.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAudioCatalogProvider: 通用音频目录提供器。 为编辑器选择器或构建工具提供事件、参数、状态和开关 ID 查询入口。

### Properties

#### `events`

- API: `public`

```gdscript
var events: Dictionary = {}
```

事件目录。

Schemas:

- `events`: 事件目录 Dictionary，键为事件 ID，值为条目元数据 Dictionary。

#### `parameters`

- API: `public`

```gdscript
var parameters: Dictionary = {}
```

参数目录。

Schemas:

- `parameters`: 参数目录 Dictionary，键为参数 ID，值为条目元数据 Dictionary。

#### `states`

- API: `public`

```gdscript
var states: Dictionary = {}
```

状态目录。

Schemas:

- `states`: 状态目录 Dictionary，键为状态 ID，值为条目元数据 Dictionary。

#### `switches`

- API: `public`

```gdscript
var switches: Dictionary = {}
```

开关目录。

Schemas:

- `switches`: 开关目录 Dictionary，键为开关 ID，值为条目元数据 Dictionary。

### Methods

#### `set_entry`

- API: `public`

```gdscript
func set_entry(catalog_id: StringName, entry_id: StringName, metadata: Dictionary = {}) -> void:
```

设置目录条目。

Parameters:

| Name | Description |
|---|---|
| `catalog_id` | 目录标识，如 events、parameters、states、switches。 |
| `entry_id` | 条目标识。 |
| `metadata` | 条目元数据。 |

Schemas:

- `metadata`: 条目元数据 Dictionary；键和值由目录提供器或项目工具约定。

#### `remove_entry`

- API: `public`

```gdscript
func remove_entry(catalog_id: StringName, entry_id: StringName) -> void:
```

移除目录条目。

Parameters:

| Name | Description |
|---|---|
| `catalog_id` | 目录标识。 |
| `entry_id` | 条目标识。 |

#### `get_ids`

- API: `public`

```gdscript
func get_ids(catalog_id: StringName) -> PackedStringArray:
```

获取目录 ID 列表。

Parameters:

| Name | Description |
|---|---|
| `catalog_id` | 目录标识。 |

Returns: 排序后的条目 ID。

#### `describe_entry`

- API: `public`

```gdscript
func describe_entry(catalog_id: StringName, entry_id: StringName) -> Dictionary:
```

获取目录条目描述。

Parameters:

| Name | Description |
|---|---|
| `catalog_id` | 目录标识。 |
| `entry_id` | 条目标识。 |

Returns: 条目元数据副本。

Schemas:

- `return`: 条目元数据 Dictionary；键和值由目录提供器或项目工具约定。

#### `describe_catalog`

- API: `public`

```gdscript
func describe_catalog() -> Dictionary:
```

获取完整目录快照。

Returns: 目录快照字典。

Schemas:

- `return`: 目录快照 Dictionary，包含 events、parameters、states 和 switches 字段。

## GFAudioClip

- Path: `addons/gf/standard/utilities/audio/gf_audio_clip.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFAudioClip: 可资源化的音频播放配置。 支持直接引用 `AudioStream`，也支持提供资源路径交给 `GFAudioUtility` 按需加载。

### Properties

#### `path`

- API: `public`

```gdscript
var path: String = ""
```

音频资源路径。`stream` 为空时使用该路径加载。

#### `stream`

- API: `public`

```gdscript
var stream: AudioStream
```

音频流资源。

#### `bus_name`

- API: `public`

```gdscript
var bus_name: String = ""
```

音频总线。为空时由播放方法使用默认 BGM/SFX 总线。

#### `volume_db`

- API: `public`

```gdscript
var volume_db: float = 0.0
```

播放音量，单位 dB。

#### `pitch_scale`

- API: `public`

```gdscript
var pitch_scale: float = 1.0
```

播放音高。

#### `weight`

- API: `public`

```gdscript
var weight: float = 1.0
```

在同一片段 ID 存在多个候选时的抽取权重；小于等于 0 表示不参与随机抽取。

#### `pitch_random_min`

- API: `public`

```gdscript
var pitch_random_min: float = 1.0
```

播放音高随机下限，会乘到 pitch_scale 上。

#### `pitch_random_max`

- API: `public`

```gdscript
var pitch_random_max: float = 1.0
```

播放音高随机上限，会乘到 pitch_scale 上。

#### `spatial_settings`

- API: `public`

```gdscript
var spatial_settings: Resource = null
```

可选空间播放设置。为空时空间 SFX 使用 Godot 播放器默认空间参数。

Schemas:

- `spatial_settings`: GFAudioSpatialSettings or compatible Resource with apply_to_2d/apply_to_3d methods.

### Methods

#### `has_source`

- API: `public`

```gdscript
func has_source() -> bool:
```

检查该配置是否有可播放来源。

Returns: 有 stream 或 path 时返回 true。

#### `resolve_bus`

- API: `public`

```gdscript
func resolve_bus(default_bus: String) -> String:
```

解析实际总线名称。

Parameters:

| Name | Description |
|---|---|
| `default_bus` | 默认总线。 |

Returns: 实际总线名称。

#### `resolve_pitch`

- API: `public`

```gdscript
func resolve_pitch(rng: RandomNumberGenerator = null) -> float:
```

解析本次播放使用的实际音高。

Parameters:

| Name | Description |
|---|---|
| `rng` | 可选随机数生成器；为空时使用确定性的 pitch_scale。 |

Returns: 实际播放音高。

## GFAudioEmitterHandle

- Path: `addons/gf/standard/utilities/audio/gf_audio_emitter_handle.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFAudioEmitterHandle: 一次音频播放的轻量控制句柄。 句柄只包装底层 AudioStreamPlayer 节点的通用生命周期和播放属性， 不规定音频事件、混音策略或业务含义。

### Signals

#### `player_attached`

- API: `public`

```gdscript
signal player_attached(handle: GFAudioEmitterHandle, player: Node)
```

句柄绑定到底层播放器时发出。

Parameters:

| Name | Description |
|---|---|
| `handle` | 当前句柄。 |
| `player` | 绑定的播放器节点。 |

#### `stopped`

- API: `public`

```gdscript
signal stopped(handle: GFAudioEmitterHandle)
```

句柄主动停止并释放绑定时发出。

Parameters:

| Name | Description |
|---|---|
| `handle` | 当前句柄。 |

### Properties

#### `channel`

- API: `public`

```gdscript
var channel: StringName = &""
```

可选通道标识。框架不解释该字段。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: 句柄元数据 Dictionary；键和值由调用方或后端约定。

### Methods

#### `set_player`

- API: `public`

```gdscript
func set_player(player: Node) -> void:
```

绑定底层播放器。

Parameters:

| Name | Description |
|---|---|
| `player` | 要绑定的播放器节点。 |

#### `set_release_callback`

- API: `public`

```gdscript
func set_release_callback(release_callback: Callable) -> void:
```

设置释放回调。

Parameters:

| Name | Description |
|---|---|
| `release_callback` | 停止完成时调用的释放回调。 |

#### `bind_to_owner`

- API: `public`

```gdscript
func bind_to_owner(owner: Node, fade_seconds: float = 0.0) -> void:
```

绑定一个拥有者节点，节点退出树时自动停止当前播放。

Parameters:

| Name | Description |
|---|---|
| `owner` | 生命周期拥有者。 |
| `fade_seconds` | 自动停止时使用的淡出秒数。 |

#### `unbind_owner`

- API: `public`

```gdscript
func unbind_owner() -> void:
```

取消拥有者生命周期绑定。

#### `get_player`

- API: `public`

```gdscript
func get_player() -> Node:
```

获取底层播放器。

Returns: 播放器节点；不存在或已释放时返回 null。

#### `is_valid`

- API: `public`

```gdscript
func is_valid() -> bool:
```

检查句柄是否仍绑定有效播放器。

Returns: 有效时返回 true。

#### `is_stop_requested`

- API: `public`

```gdscript
func is_stop_requested() -> bool:
```

检查该句柄是否已经收到停止请求。

Returns: 已请求停止时返回 true。

#### `is_playing`

- API: `public`

```gdscript
func is_playing() -> bool:
```

检查播放器是否正在播放。

Returns: 正在播放时返回 true。

#### `stop`

- API: `public`

```gdscript
func stop(fade_seconds: float = 0.0) -> void:
```

停止播放；传入淡出秒数时先淡出再释放。

Parameters:

| Name | Description |
|---|---|
| `fade_seconds` | 淡出秒数。 |

#### `fade_to`

- API: `public`

```gdscript
func fade_to(volume_db: float, fade_seconds: float) -> void:
```

淡入淡出到指定音量。

Parameters:

| Name | Description |
|---|---|
| `volume_db` | 目标音量，单位 dB。 |
| `fade_seconds` | 淡入淡出秒数。 |

#### `set_volume_db`

- API: `public`

```gdscript
func set_volume_db(volume_db: float) -> void:
```

设置当前音量。

Parameters:

| Name | Description |
|---|---|
| `volume_db` | 音量，单位 dB。 |

#### `get_volume_db`

- API: `public`

```gdscript
func get_volume_db() -> float:
```

获取当前音量。

Returns: 音量，单位 dB；无播放器时返回 0。

#### `set_pitch_scale`

- API: `public`

```gdscript
func set_pitch_scale(pitch_scale: float) -> void:
```

设置当前音高。

Parameters:

| Name | Description |
|---|---|
| `pitch_scale` | 音高缩放。 |

#### `get_pitch_scale`

- API: `public`

```gdscript
func get_pitch_scale() -> float:
```

获取当前音高。

Returns: 音高缩放；无播放器时返回 1。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照。

Schemas:

- `return`: 调试快照 Dictionary，包含 valid、playing、channel、volume_db、pitch_scale、owner_valid 和 metadata 字段。

## GFAudioEvent

- Path: `addons/gf/standard/utilities/audio/gf_audio_event.gd`
- Extends: `Resource`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFAudioEvent: 通用资源化音频事件。 描述一个可以交给 `GFAudioUtility` 或音频后端处理的事件请求。

### Properties

#### `event_id`

- API: `public`

```gdscript
var event_id: StringName = &""
```

事件稳定标识。

#### `channel`

- API: `public`

```gdscript
var channel: StringName = &"sfx"
```

事件通道，例如 bgm、sfx、ambient。

#### `bank_id`

- API: `public`

```gdscript
var bank_id: StringName = &""
```

可选音频集合标识。

#### `path`

- API: `public`

```gdscript
var path: String = ""
```

可选资源路径或后端事件路径。

#### `clip`

- API: `public`

```gdscript
var clip: GFAudioClip = null
```

可选音频片段。

#### `ambient_channel`

- API: `public`

```gdscript
var ambient_channel: StringName = &"default"
```

可选环境音通道。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: 音频事件元数据 Dictionary；键和值由后端或项目逻辑约定。

### Methods

#### `has_request`

- API: `public`

```gdscript
func has_request() -> bool:
```

检查事件是否有可请求内容。

Returns: 有事件 ID、路径或片段时返回 true。

#### `to_request_options`

- API: `public`

```gdscript
func to_request_options(extra_options: Dictionary = {}) -> Dictionary:
```

转换为请求选项。

Parameters:

| Name | Description |
|---|---|
| `extra_options` | 额外选项。 |

Returns: 请求选项字典。

Schemas:

- `extra_options`: 额外请求选项 Dictionary；键和值由后端或调用方约定，同名键会覆盖 metadata 中的值。
- `return`: 请求选项 Dictionary，包含 metadata 与 extra_options 合并后的字段，并追加 event_id、channel、bank_id、path 和 ambient_channel 字段。

## GFAudioParameter

- Path: `addons/gf/standard/utilities/audio/gf_audio_parameter.gd`
- Extends: `Resource`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFAudioParameter: 通用音频参数请求。 表示可写入音频后端的全局或对象级数值参数。

### Properties

#### `parameter_id`

- API: `public`

```gdscript
var parameter_id: StringName = &""
```

参数稳定标识。

#### `value`

- API: `public`

```gdscript
var value: float = 0.0
```

参数值。

#### `scope_id`

- API: `public`

```gdscript
var scope_id: StringName = &""
```

可选作用域标识。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: 音频参数元数据 Dictionary；键和值由后端或项目逻辑约定。

### Methods

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为请求字典。

Returns: 请求字典。

Schemas:

- `return`: 参数请求 Dictionary，包含 parameter_id、value、scope_id 和 metadata 字段。

## GFAudioSpatialSettings

- Path: `addons/gf/standard/utilities/audio/gf_audio_spatial_settings.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.19.0`

GFAudioSpatialSettings: 空间音效播放器参数。 只描述 Godot 2D/3D 空间播放器的通用衰减、距离、区域、复音和播放类型参数。 该资源可挂到 `GFAudioClip.spatial_settings`，仅在空间 SFX 播放路径中应用。

### Properties

#### `max_polyphony`

- API: `public`

```gdscript
var max_polyphony: int = 1
```

最大同时复音数量。

#### `panning_strength`

- API: `public`

```gdscript
var panning_strength: float = 1.0
```

声像强度。

#### `playback_type`

- API: `public`

```gdscript
var playback_type: int = 0
```

播放类型。0 为 Default，1 为 Stream，2 为 Sample。

#### `area_mask_2d`

- API: `public`

```gdscript
var area_mask_2d: int = 1
```

2D 音频区域掩码。

#### `max_distance_2d`

- API: `public`

```gdscript
var max_distance_2d: float = 2000.0
```

2D 最大传播距离，单位像素。

#### `attenuation_2d`

- API: `public`

```gdscript
var attenuation_2d: float = 1.0
```

2D 衰减强度。

#### `attenuation_model_3d`

- API: `public`

```gdscript
var attenuation_model_3d: int = 0
```

3D 衰减模型。0 为 Inverse，1 为 Inverse Square，2 为 Logarithmic，3 为 Disabled。

#### `area_mask_3d`

- API: `public`

```gdscript
var area_mask_3d: int = 1
```

3D 音频区域掩码。

#### `unit_size_3d`

- API: `public`

```gdscript
var unit_size_3d: float = 10.0
```

3D 单位尺寸。

#### `max_db_3d`

- API: `public`

```gdscript
var max_db_3d: float = 3.0
```

3D 最大增益，单位 dB。

#### `max_distance_3d`

- API: `public`

```gdscript
var max_distance_3d: float = 0.0
```

3D 最大传播距离，0 表示不限制。

#### `emission_angle_enabled_3d`

- API: `public`

```gdscript
var emission_angle_enabled_3d: bool = false
```

是否启用 3D 发射角过滤。

#### `emission_angle_degrees_3d`

- API: `public`

```gdscript
var emission_angle_degrees_3d: float = 45.0
```

3D 发射角角度。

#### `emission_angle_filter_attenuation_db_3d`

- API: `public`

```gdscript
var emission_angle_filter_attenuation_db_3d: float = -12.0
```

3D 发射角外的衰减，单位 dB。

#### `attenuation_filter_cutoff_hz_3d`

- API: `public`

```gdscript
var attenuation_filter_cutoff_hz_3d: float = 5000.0
```

3D 距离衰减滤波截止频率。

#### `attenuation_filter_db_3d`

- API: `public`

```gdscript
var attenuation_filter_db_3d: float = -24.0
```

3D 距离衰减滤波增益，单位 dB。

#### `doppler_tracking_3d`

- API: `public`

```gdscript
var doppler_tracking_3d: int = 0
```

3D 多普勒追踪模式。0 为 Disabled，1 为 Idle，2 为 Physics。

### Methods

#### `apply_to_2d`

- API: `public`

```gdscript
func apply_to_2d(player: AudioStreamPlayer2D) -> bool:
```

将设置应用到 2D 空间播放器。

Parameters:

| Name | Description |
|---|---|
| `player` | 目标 2D 空间播放器。 |

Returns: 成功应用时返回 true。

#### `apply_to_3d`

- API: `public`

```gdscript
func apply_to_3d(player: AudioStreamPlayer3D) -> bool:
```

将设置应用到 3D 空间播放器。

Parameters:

| Name | Description |
|---|---|
| `player` | 目标 3D 空间播放器。 |

Returns: 成功应用时返回 true。

## GFAudioState

- Path: `addons/gf/standard/utilities/audio/gf_audio_state.gd`
- Extends: `Resource`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFAudioState: 通用音频状态请求。 表示一个状态组和值，不解释其具体混音或播放含义。

### Properties

#### `group_id`

- API: `public`

```gdscript
var group_id: StringName = &""
```

状态组标识。

#### `state_id`

- API: `public`

```gdscript
var state_id: StringName = &""
```

状态值标识。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: 音频状态元数据 Dictionary；键和值由后端或项目逻辑约定。

### Methods

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为请求字典。

Returns: 请求字典。

Schemas:

- `return`: 状态请求 Dictionary，包含 group_id、state_id 和 metadata 字段。

## GFAudioSwitch

- Path: `addons/gf/standard/utilities/audio/gf_audio_switch.gd`
- Extends: `Resource`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFAudioSwitch: 通用音频开关请求。 表示某个对象或作用域上的开关组和值。

### Properties

#### `group_id`

- API: `public`

```gdscript
var group_id: StringName = &""
```

开关组标识。

#### `switch_id`

- API: `public`

```gdscript
var switch_id: StringName = &""
```

开关值标识。

#### `scope_id`

- API: `public`

```gdscript
var scope_id: StringName = &""
```

可选作用域标识。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: 音频开关元数据 Dictionary；键和值由后端或项目逻辑约定。

### Methods

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为请求字典。

Returns: 请求字典。

Schemas:

- `return`: 开关请求 Dictionary，包含 group_id、switch_id、scope_id 和 metadata 字段。

## GFAudioUtility

- Path: `addons/gf/standard/utilities/audio/gf_audio_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFAudioUtility: 全局音频管理器。 管理 BGM 和 SFX 的播放与音量。 注册 GFObjectPoolUtility 时会复用 AudioStreamPlayer，未注册时使用普通播放器。 支持通过 GFAssetUtility 异步加载音频资源。

### Signals

#### `bgm_finished`

- API: `public`

```gdscript
signal bgm_finished(history_key: String)
```

当前 BGM 自然播放结束时发出。

Parameters:

| Name | Description |
|---|---|
| `history_key` | 播放请求记录的 BGM key。 |

### Enums

#### `SFXOverflowPolicy`

- API: `public`

```gdscript
enum SFXOverflowPolicy { ## 跳过新的 SFX 请求。 SKIP_NEW, ## 停止最早播放的 SFX，并播放新的请求。 STOP_OLDEST, }
```

SFX 超出并发上限时的处理策略。

### Constants

#### `BGM_BUS_NAME`

- API: `public`

```gdscript
const BGM_BUS_NAME: String = "BGM"
```

默认 BGM 音频总线名。

#### `SFX_BUS_NAME`

- API: `public`

```gdscript
const SFX_BUS_NAME: String = "SFX"
```

默认 SFX 音频总线名。

### Properties

#### `max_sfx_players`

- API: `public`

```gdscript
var max_sfx_players: int = 32
```

同时播放的 SFX 数量上限；小于等于 0 表示不限制。

#### `sfx_overflow_policy`

- API: `public`

```gdscript
var sfx_overflow_policy: SFXOverflowPolicy = SFXOverflowPolicy.SKIP_NEW
```

SFX 超出并发上限时采用的处理策略。

#### `bgm_crossfade_seconds`

- API: `public`

```gdscript
var bgm_crossfade_seconds: float = 0.0
```

默认 BGM 淡入淡出秒数。单次播放传入负数时使用该值。

#### `max_bgm_history`

- API: `public`

```gdscript
var max_bgm_history: int = 16
```

BGM 历史记录最大数量。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化音频播放器、运行时状态和默认播放根节点。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放播放器、后端、环境音和 SFX 运行时状态。

#### `play_bgm`

- API: `public`

```gdscript
func play_bgm(path: String, crossfade_seconds: float = -1.0) -> void:
```

播放 BGM（背景音乐）

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源的路径 |
| `crossfade_seconds` | 淡入淡出秒数；小于 0 时使用默认值。 |

#### `play_bgm_with_options`

- API: `public`

```gdscript
func play_bgm_with_options(path: String, options: Dictionary = {}) -> void:
```

使用选项播放 BGM。

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源路径或后端事件路径。 |
| `options` | 支持 crossfade_seconds、history_key、loop、bus_name、volume_db 和 pitch_scale。 |

Schemas:

- `options`: Dictionary，可包含 crossfade_seconds、history_key、loop、bus_name、volume_db 和 pitch_scale 字段。

#### `play_bgm_clip`

- API: `public`

```gdscript
func play_bgm_clip(clip: GFAudioClip, crossfade_seconds: float = -1.0) -> void:
```

播放资源化 BGM 配置。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `crossfade_seconds` | 淡入淡出秒数；小于 0 时使用默认值。 |

#### `play_bgm_from_bank`

- API: `public`

```gdscript
func play_bgm_from_bank(bank: GFAudioBank, clip_id: StringName, crossfade_seconds: float = -1.0) -> void:
```

从音频集合播放 BGM。

Parameters:

| Name | Description |
|---|---|
| `bank` | 音频集合。 |
| `clip_id` | 片段标识。 |
| `crossfade_seconds` | 淡入淡出秒数；小于 0 时使用默认值。 |

#### `play_bgm_event`

- API: `public`

```gdscript
func play_bgm_event( event_id: StringName, bank_id: StringName = &"", crossfade_seconds: float = -1.0 ) -> void:
```

按事件 ID 播放注册音频集合中的 BGM。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `crossfade_seconds` | 淡入淡出秒数；小于 0 时使用默认值。 |

#### `stop_bgm`

- API: `public`

```gdscript
func stop_bgm(fade_seconds: float = 0.0) -> void:
```

停止当前 BGM。

Parameters:

| Name | Description |
|---|---|
| `fade_seconds` | 淡出秒数。 |

#### `pause_bgm`

- API: `public`

```gdscript
func pause_bgm(fade_seconds: float = 0.0) -> bool:
```

暂停当前 BGM。

Parameters:

| Name | Description |
|---|---|
| `fade_seconds` | 淡出到暂停的秒数。 |

Returns: 成功暂停或后端已处理时返回 true。

#### `resume_bgm`

- API: `public`

```gdscript
func resume_bgm(from_position: float = -1.0, fade_seconds: float = 0.0) -> bool:
```

恢复当前 BGM。

Parameters:

| Name | Description |
|---|---|
| `from_position` | 大于等于 0 时从指定秒数恢复。 |
| `fade_seconds` | 淡入秒数。 |

Returns: 成功恢复或后端已处理时返回 true。

#### `seek_bgm`

- API: `public`

```gdscript
func seek_bgm(position_seconds: float) -> bool:
```

跳转当前 BGM 播放位置。

Parameters:

| Name | Description |
|---|---|
| `position_seconds` | 目标秒数。 |

Returns: 成功跳转或后端已处理时返回 true。

#### `get_bgm_playback_position`

- API: `public`

```gdscript
func get_bgm_playback_position() -> float:
```

获取当前 BGM 播放位置。

Returns: 当前播放秒数；无可查询播放器时返回 0。

#### `is_bgm_paused`

- API: `public`

```gdscript
func is_bgm_paused() -> bool:
```

查询当前 BGM 是否暂停。

Returns: 暂停时返回 true。

#### `get_bgm_history`

- API: `public`

```gdscript
func get_bgm_history() -> PackedStringArray:
```

获取 BGM 播放历史。

Returns: 从旧到新的历史 key。

#### `get_current_bgm_key`

- API: `public`

```gdscript
func get_current_bgm_key() -> String:
```

获取当前 BGM key。

Returns: 当前 BGM key；无播放时为空。

#### `clear_bgm_history`

- API: `public`

```gdscript
func clear_bgm_history() -> void:
```

清空 BGM 历史。

#### `register_audio_bank`

- API: `public`

```gdscript
func register_audio_bank(bank_id: StringName, bank: GFAudioBank) -> void:
```

注册一个全局音频集合，供事件式播放接口使用。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |
| `bank` | 音频集合。 |

#### `unregister_audio_bank`

- API: `public`

```gdscript
func unregister_audio_bank(bank_id: StringName) -> void:
```

移除一个全局音频集合。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |

#### `clear_audio_banks`

- API: `public`

```gdscript
func clear_audio_banks() -> void:
```

清空全局音频集合注册表。

#### `mount_audio_bank`

- API: `public`

```gdscript
func mount_audio_bank( bank_id: StringName, bank: GFAudioBank, restore_previous_bank: bool = true ) -> int:
```

挂载一个临时音频集合，并返回用于卸载的挂载令牌。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |
| `bank` | 音频集合。 |
| `restore_previous_bank` | 卸载顶层挂载时是否恢复同 ID 的上一层音频集合。 |

Returns: 挂载令牌；失败时返回 0。

#### `unmount_audio_bank`

- API: `public`

```gdscript
func unmount_audio_bank(bank_id: StringName, mount_token: int) -> bool:
```

卸载由 mount_audio_bank() 创建的临时音频集合。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |
| `mount_token` | mount_audio_bank() 返回的挂载令牌。 |

Returns: 找到并卸载对应挂载时返回 true。

#### `get_audio_bank`

- API: `public`

```gdscript
func get_audio_bank(bank_id: StringName) -> GFAudioBank:
```

获取全局音频集合。

Parameters:

| Name | Description |
|---|---|
| `bank_id` | 音频集合标识。 |

Returns: 音频集合；不存在时返回 null。

#### `set_audio_backend`

- API: `public`

```gdscript
func set_audio_backend(backend: GFAudioBackend) -> void:
```

设置可插拔音频后端。传入 null 时恢复默认 Godot 播放路径。

Parameters:

| Name | Description |
|---|---|
| `backend` | 音频后端。 |

#### `get_audio_backend`

- API: `public`

```gdscript
func get_audio_backend() -> GFAudioBackend:
```

获取当前音频后端。

Returns: 音频后端；未设置时返回 null。

#### `clear_audio_backend`

- API: `public`

```gdscript
func clear_audio_backend(dispose_backend: bool = true) -> void:
```

清除当前音频后端。

Parameters:

| Name | Description |
|---|---|
| `dispose_backend` | 是否调用后端 dispose()。 |

#### `post_audio_event`

- API: `public`

```gdscript
func post_audio_event(event: GFAudioEvent, options: Dictionary = {}) -> GFAudioEmitterHandle:
```

发布资源化音频事件。

Parameters:

| Name | Description |
|---|---|
| `event` | 音频事件资源。 |
| `options` | 请求选项。 |

Returns: 控制句柄；不需要或无法返回句柄时返回 null。

Schemas:

- `options`: Dictionary，作为事件请求附加选项，会与 GFAudioEvent.to_request_options() 的结果合并。

#### `set_audio_parameter`

- API: `public`

```gdscript
func set_audio_parameter(parameter: GFAudioParameter) -> bool:
```

写入音频参数。

Parameters:

| Name | Description |
|---|---|
| `parameter` | 参数请求。 |

Returns: 后端已处理返回 true。

#### `set_audio_state`

- API: `public`

```gdscript
func set_audio_state(state: GFAudioState) -> bool:
```

写入音频状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 状态请求。 |

Returns: 后端已处理返回 true。

#### `set_audio_switch`

- API: `public`

```gdscript
func set_audio_switch(audio_switch: GFAudioSwitch) -> bool:
```

写入音频开关。

Parameters:

| Name | Description |
|---|---|
| `audio_switch` | 开关请求。 |

Returns: 后端已处理返回 true。

#### `play_ambient`

- API: `public`

```gdscript
func play_ambient(path: String, channel: StringName = &"default", fade_seconds: float = 0.0) -> void:
```

播放环境音。

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源路径。 |
| `channel` | 环境音通道。 |
| `fade_seconds` | 淡入秒数。 |

#### `play_ambient_clip`

- API: `public`

```gdscript
func play_ambient_clip( clip: GFAudioClip, channel: StringName = &"default", fade_seconds: float = 0.0 ) -> void:
```

播放资源化环境音配置。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `channel` | 环境音通道。 |
| `fade_seconds` | 淡入秒数。 |

#### `play_ambient_from_bank`

- API: `public`

```gdscript
func play_ambient_from_bank( bank: GFAudioBank, clip_id: StringName, channel: StringName = &"default", fade_seconds: float = 0.0 ) -> void:
```

从音频集合播放环境音。

Parameters:

| Name | Description |
|---|---|
| `bank` | 音频集合。 |
| `clip_id` | 片段标识。 |
| `channel` | 环境音通道。 |
| `fade_seconds` | 淡入秒数。 |

#### `play_ambient_event`

- API: `public`

```gdscript
func play_ambient_event( event_id: StringName, channel: StringName = &"default", bank_id: StringName = &"", fade_seconds: float = 0.0 ) -> void:
```

按事件 ID 播放注册音频集合中的环境音。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `channel` | 环境音通道。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `fade_seconds` | 淡入秒数。 |

#### `stop_ambient`

- API: `public`

```gdscript
func stop_ambient(channel: StringName = &"default", fade_seconds: float = 0.0) -> void:
```

停止指定环境音通道。

Parameters:

| Name | Description |
|---|---|
| `channel` | 环境音通道。 |
| `fade_seconds` | 淡出秒数。 |

#### `stop_all_ambient`

- API: `public`

```gdscript
func stop_all_ambient(fade_seconds: float = 0.0) -> void:
```

停止所有环境音通道。

Parameters:

| Name | Description |
|---|---|
| `fade_seconds` | 淡出秒数。 |

#### `is_ambient_playing`

- API: `public`

```gdscript
func is_ambient_playing(channel: StringName = &"default") -> bool:
```

检查环境音通道是否正在播放。

Parameters:

| Name | Description |
|---|---|
| `channel` | 环境音通道。 |

Returns: 正在播放时返回 true。

#### `stop_all_sfx`

- API: `public`

```gdscript
func stop_all_sfx(fade_seconds: float = 0.0) -> void:
```

停止全部普通 SFX 与空间 SFX。

Parameters:

| Name | Description |
|---|---|
| `fade_seconds` | 淡出秒数。 |

#### `play_sfx`

- API: `public`

```gdscript
func play_sfx(path: String) -> void:
```

播放 SFX（音效），自动从池中分配播放器

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源的路径 |

#### `play_sfx_handle`

- API: `public`

```gdscript
func play_sfx_handle(path: String) -> GFAudioEmitterHandle:
```

播放 SFX 并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `path` | 音频资源的路径。 |

Returns: 控制句柄；路径为空时返回 null。

#### `play_sfx_clip`

- API: `public`

```gdscript
func play_sfx_clip(clip: GFAudioClip) -> void:
```

播放资源化 SFX 配置。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |

#### `play_sfx_clip_handle`

- API: `public`

```gdscript
func play_sfx_clip_handle(clip: GFAudioClip) -> GFAudioEmitterHandle:
```

播放资源化 SFX 配置并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |

Returns: 控制句柄；片段无播放来源时返回 null。

#### `play_sfx_from_bank`

- API: `public`

```gdscript
func play_sfx_from_bank(bank: GFAudioBank, clip_id: StringName) -> void:
```

从音频集合播放 SFX。

Parameters:

| Name | Description |
|---|---|
| `bank` | 音频集合。 |
| `clip_id` | 片段标识。 |

#### `play_sfx_from_bank_handle`

- API: `public`

```gdscript
func play_sfx_from_bank_handle(bank: GFAudioBank, clip_id: StringName) -> GFAudioEmitterHandle:
```

从音频集合播放 SFX 并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `bank` | 音频集合。 |
| `clip_id` | 片段标识。 |

Returns: 控制句柄；无法播放时返回 null。

#### `play_sfx_event`

- API: `public`

```gdscript
func play_sfx_event(event_id: StringName, bank_id: StringName = &"") -> void:
```

按事件 ID 播放注册音频集合中的 SFX。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |

#### `play_sfx_event_handle`

- API: `public`

```gdscript
func play_sfx_event_handle(event_id: StringName, bank_id: StringName = &"") -> GFAudioEmitterHandle:
```

按事件 ID 播放注册音频集合中的 SFX 并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |

Returns: 控制句柄；无法播放时返回 null。

#### `play_sfx_event_2d`

- API: `public`

```gdscript
func play_sfx_event_2d( event_id: StringName, source: Node2D, bank_id: StringName = &"", follow_source: bool = false ) -> AudioStreamPlayer2D:
```

按事件 ID 在 2D 节点位置播放注册音频集合中的 SFX。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `source` | 2D 声源节点。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 创建的播放器；无法播放时返回 null。

#### `play_sfx_event_2d_handle`

- API: `public`

```gdscript
func play_sfx_event_2d_handle( event_id: StringName, source: Node2D, bank_id: StringName = &"", follow_source: bool = false ) -> GFAudioEmitterHandle:
```

按事件 ID 在 2D 节点位置播放注册音频集合中的 SFX，并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `source` | 2D 声源节点。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 控制句柄；无法播放时返回 null。

#### `play_sfx_event_3d`

- API: `public`

```gdscript
func play_sfx_event_3d( event_id: StringName, source: Node3D, bank_id: StringName = &"", follow_source: bool = false ) -> AudioStreamPlayer3D:
```

按事件 ID 在 3D 节点位置播放注册音频集合中的 SFX。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `source` | 3D 声源节点。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 创建的播放器；无法播放时返回 null。

#### `play_sfx_event_3d_handle`

- API: `public`

```gdscript
func play_sfx_event_3d_handle( event_id: StringName, source: Node3D, bank_id: StringName = &"", follow_source: bool = false ) -> GFAudioEmitterHandle:
```

按事件 ID 在 3D 节点位置播放注册音频集合中的 SFX，并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 音频事件标识。 |
| `source` | 3D 声源节点。 |
| `bank_id` | 音频集合标识；为空时搜索全部注册集合。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 控制句柄；无法播放时返回 null。

#### `play_sfx_clip_2d`

- API: `public`

```gdscript
func play_sfx_clip_2d( clip: GFAudioClip, source: Node2D, follow_source: bool = false ) -> AudioStreamPlayer2D:
```

在 2D 节点位置播放资源化 SFX 配置。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `source` | 2D 声源节点。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 创建的播放器；无法播放时返回 null。

#### `play_sfx_clip_2d_handle`

- API: `public`

```gdscript
func play_sfx_clip_2d_handle( clip: GFAudioClip, source: Node2D, follow_source: bool = false ) -> GFAudioEmitterHandle:
```

在 2D 节点位置播放资源化 SFX 配置，并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `source` | 2D 声源节点。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 控制句柄；无法播放时返回 null。

#### `play_sfx_clip_3d`

- API: `public`

```gdscript
func play_sfx_clip_3d( clip: GFAudioClip, source: Node3D, follow_source: bool = false ) -> AudioStreamPlayer3D:
```

在 3D 节点位置播放资源化 SFX 配置。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `source` | 3D 声源节点。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 创建的播放器；无法播放时返回 null。

#### `play_sfx_clip_3d_handle`

- API: `public`

```gdscript
func play_sfx_clip_3d_handle( clip: GFAudioClip, source: Node3D, follow_source: bool = false ) -> GFAudioEmitterHandle:
```

在 3D 节点位置播放资源化 SFX 配置，并返回控制句柄。

Parameters:

| Name | Description |
|---|---|
| `clip` | 音频片段配置。 |
| `source` | 3D 声源节点。 |
| `follow_source` | 为 true 时播放器会作为 source 子节点跟随移动。 |

Returns: 控制句柄；无法播放时返回 null。

#### `get_ambient_handle`

- API: `public`

```gdscript
func get_ambient_handle(channel: StringName = &"default") -> GFAudioEmitterHandle:
```

获取环境音通道的控制句柄。

Parameters:

| Name | Description |
|---|---|
| `channel` | 环境音通道。 |

Returns: 控制句柄；通道不存在时返回 null。

#### `set_bus_volume`

- API: `public`

```gdscript
func set_bus_volume(bus_name: String, volume_linear: float) -> void:
```

设置音频总线音量

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 总线名称，如 "Master", "BGM", "SFX" |
| `volume_linear` | 线性音量 (0.0 到 1.0) |

#### `get_bus_volume`

- API: `public`

```gdscript
func get_bus_volume(bus_name: String) -> float:
```

获取音频总线音量

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 总线名称 |

Returns: 线性音量 (0.0 到 1.0)

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取音频工具调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 backend、backend_snapshot、backend_capabilities、current_bgm_key、current_bgm_loop、bgm_paused、bgm_position、bgm_history、active_sfx_count、active_spatial_sfx_count、max_sfx_players、ambient_channels 和 audio_bank_count 字段。

## GFBackgroundWorkTask

- Path: `addons/gf/standard/utilities/jobs/gf_background_work_task.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFBackgroundWorkTask: 后台工作记录。 保存后台工作状态、进度、输入数据、结果、错误文本和应用回调。 任务本身不直接启动线程；执行由 GFBackgroundWorkUtility 统一协调。

### Enums

#### `Kind`

- API: `public`

```gdscript
enum Kind { ## CPU 计算型线程任务。 CPU, ## IO 型线程任务。 IO, ## ResourceLoader 线程资源加载任务。 RESOURCE, }
```

后台工作类型。

#### `Status`

- API: `public`

```gdscript
enum Status { ## 已入队，等待启动。 QUEUED, ## 正在后台运行或等待资源加载。 RUNNING, ## 正在等待主线程应用回调。 APPLYING, ## 已成功完成。 COMPLETED, ## 已失败。 FAILED, ## 已取消。 CANCELLED, }
```

后台工作生命周期状态。

### Properties

#### `work_id`

- API: `public`

```gdscript
var work_id: StringName = &""
```

工作 ID。

#### `kind`

- API: `public`

```gdscript
var kind: Kind = Kind.CPU
```

工作类型。

#### `status`

- API: `public`

```gdscript
var status: Status = Status.QUEUED
```

当前状态。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

优先级，数值越大越早从等待队列启动。

#### `input_data`

- API: `public`

```gdscript
var input_data: Variant = null
```

工作输入数据。默认应只包含纯 Variant 数据。

Schemas:

- `input_data`: Variant，复制到工作线程的纯数据载荷；显式允许对象载荷时除外。

#### `result`

- API: `public`

```gdscript
var result: Variant = null
```

工作结果。线程任务返回值或资源加载结果会写入该字段。

Schemas:

- `result`: Variant，工作线程结果、资源加载结果或失败载荷。

#### `apply_result`

- API: `public`

```gdscript
var apply_result: Variant = null
```

主线程应用回调的返回值。

Schemas:

- `apply_result`: Variant，由可选主线程 apply 回调返回。

#### `error_message`

- API: `public`

```gdscript
var error_message: String = ""
```

错误文本。

#### `progress`

- API: `public`

```gdscript
var progress: float = 0.0
```

进度，范围建议为 0.0 到 1.0。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，复制到后台任务中的项目侧元数据。

#### `resource_path`

- API: `public`

```gdscript
var resource_path: String = ""
```

资源加载路径，仅 RESOURCE 任务使用。

#### `resource_type_hint`

- API: `public`

```gdscript
var resource_type_hint: String = ""
```

资源类型提示，仅 RESOURCE 任务使用。

#### `cancel_requested`

- API: `public`

```gdscript
var cancel_requested: bool = false
```

是否已请求取消。正在执行的线程任务不会被强行终止，只会在返回后转入取消终态。

#### `created_msec`

- API: `public`

```gdscript
var created_msec: int = 0
```

创建时间。

#### `started_msec`

- API: `public`

```gdscript
var started_msec: int = 0
```

开始时间。

#### `finished_msec`

- API: `public`

```gdscript
var finished_msec: int = 0
```

结束时间。

### Methods

#### `is_finished`

- API: `public`

```gdscript
func is_finished() -> bool:
```

当前工作是否已经进入终态。

Returns: 已完成、失败或取消时返回 true。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary。

Returns: 工作字典。

Schemas:

- `return`: Dictionary，包含 work_id、kind、kind_name、status、status_name、priority、progress、error_message、metadata、资源字段、cancel_requested、时间戳和结果标记。

#### `kind_name`

- API: `public`

```gdscript
static func kind_name(value: Kind) -> String:
```

获取工作类型名称。

Parameters:

| Name | Description |
|---|---|
| `value` | 工作类型枚举值。 |

Returns: 工作类型名称。

#### `status_name`

- API: `public`

```gdscript
static func status_name(value: Status) -> String:
```

获取状态名称。

Parameters:

| Name | Description |
|---|---|
| `value` | 状态枚举值。 |

Returns: 状态名称。

## GFBackgroundWorkUtility

- Path: `addons/gf/standard/utilities/jobs/gf_background_work_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFBackgroundWorkUtility: 纯数据后台工作协调器。 统一协调 CPU/IO 线程工作、ResourceLoader 线程加载和主线程应用回调。 默认只允许纯 Variant 输入数据，避免后台线程直接触碰 Node、Resource 或 Callable。

### Signals

#### `work_queued`

- API: `public`

```gdscript
signal work_queued(task: GFBackgroundWorkTask)
```

工作进入等待队列时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

#### `work_started`

- API: `public`

```gdscript
signal work_started(task: GFBackgroundWorkTask)
```

工作开始执行时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

#### `work_progressed`

- API: `public`

```gdscript
signal work_progressed(task: GFBackgroundWorkTask, progress: float, message: String)
```

工作进度变化时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |
| `progress` | 当前进度。 |
| `message` | 进度说明。 |

#### `work_completed`

- API: `public`

```gdscript
signal work_completed(task: GFBackgroundWorkTask)
```

工作完成时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

#### `work_failed`

- API: `public`

```gdscript
signal work_failed(task: GFBackgroundWorkTask)
```

工作失败时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

#### `work_cancelled`

- API: `public`

```gdscript
signal work_cancelled(task: GFBackgroundWorkTask)
```

工作取消时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

#### `work_applied`

- API: `public`

```gdscript
signal work_applied(task: GFBackgroundWorkTask)
```

工作结果已在主线程应用时发出。

Parameters:

| Name | Description |
|---|---|
| `task` | 工作记录。 |

### Properties

#### `max_threaded_tasks`

- API: `public`

```gdscript
var max_threaded_tasks: int = 2:
```

同时运行的 CPU/IO 线程任务上限。

#### `max_apply_per_tick`

- API: `public`

```gdscript
var max_apply_per_tick: int = 8:
```

单帧最多执行多少个主线程应用回调。

#### `max_apply_seconds_per_tick`

- API: `public`

```gdscript
var max_apply_seconds_per_tick: float = 0.0:
```

单帧主线程应用回调的最大秒数。小于等于 0 时不启用时间预算；启用时每帧仍至少尝试一个应用回调。

#### `max_finished_tasks`

- API: `public`

```gdscript
var max_finished_tasks: int = 128:
```

最多保留多少个终态任务用于调试快照；设为 0 时不保留历史。

#### `allow_object_payloads`

- API: `public`

```gdscript
var allow_object_payloads: bool = false
```

是否默认允许 Object、Resource、Callable、Signal 或 RID 进入线程 payload。 仅迁移旧项目或明确自行保证线程安全时才建议开启。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化后台工作协调器并启用暂停无关处理。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float = 0.0) -> void:
```

推进后台工作完成检查与主线程应用。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 为兼容统一 tick 签名而保留的参数。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

取消未完成工作、等待线程结束并清理运行时状态。

#### `submit_cpu_work`

- API: `public`

```gdscript
func submit_cpu_work( worker: Callable, input_data: Variant = null, apply_callback: Callable = Callable(), options: Dictionary = {} ) -> GFBackgroundWorkTask:
```

提交 CPU 纯数据后台工作。

Parameters:

| Name | Description |
|---|---|
| `worker` | 后台线程回调，签名推荐为 func(input_data: Variant) -> Variant。 |
| `input_data` | 输入数据。默认只允许纯 Variant 容器和值。 |
| `apply_callback` | 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。 |
| `options` | 可选配置，支持 id、priority、metadata、front、allow_object_payloads。 |

Returns: 工作记录；参数无效时返回 failed 状态任务。

Schemas:

- `input_data`: Variant，复制到工作线程的纯数据载荷；显式允许对象载荷时除外。
- `options`: Dictionary，包含 id: StringName/String、priority: int、metadata: Dictionary、front: bool 和 allow_object_payloads: bool。

#### `submit_io_work`

- API: `public`

```gdscript
func submit_io_work( worker: Callable, input_data: Variant = null, apply_callback: Callable = Callable(), options: Dictionary = {} ) -> GFBackgroundWorkTask:
```

提交 IO 纯数据后台工作。

Parameters:

| Name | Description |
|---|---|
| `worker` | 后台线程回调，签名推荐为 func(input_data: Variant) -> Variant。 |
| `input_data` | 输入数据。默认只允许纯 Variant 容器和值。 |
| `apply_callback` | 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。 |
| `options` | 可选配置，支持 id、priority、metadata、front、allow_object_payloads。 |

Returns: 工作记录；参数无效时返回 failed 状态任务。

Schemas:

- `input_data`: Variant，复制到工作线程的纯数据载荷；显式允许对象载荷时除外。
- `options`: Dictionary，包含 id: StringName/String、priority: int、metadata: Dictionary、front: bool 和 allow_object_payloads: bool。

#### `submit_resource_load`

- API: `public`

```gdscript
func submit_resource_load( path: String, type_hint: String = "", apply_callback: Callable = Callable(), options: Dictionary = {} ) -> GFBackgroundWorkTask:
```

提交 ResourceLoader 后台资源加载。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径。 |
| `type_hint` | 可选资源类型提示。 |
| `apply_callback` | 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。 |
| `options` | 可选配置，支持 id、priority、metadata。 |

Returns: 工作记录；参数无效或请求失败时返回 failed 状态任务。

Schemas:

- `options`: Dictionary，包含 id: StringName/String、priority: int 和 metadata: Dictionary。

#### `cancel_work`

- API: `public`

```gdscript
func cancel_work(work_id: StringName) -> bool:
```

取消指定工作。

Parameters:

| Name | Description |
|---|---|
| `work_id` | 工作 ID。 |

Returns: 取消成功返回 true。

#### `cancel_all`

- API: `public`

```gdscript
func cancel_all() -> void:
```

取消全部未完成工作。

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停启动新的 CPU/IO 线程工作；已运行和资源加载中的工作会继续推进。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复启动新的 CPU/IO 线程工作。

#### `is_paused`

- API: `public`

```gdscript
func is_paused() -> bool:
```

检查是否暂停。

Returns: 暂停时返回 true。

#### `update_work_progress`

- API: `public`

```gdscript
func update_work_progress(work_id: StringName, progress: float, message: String = "") -> bool:
```

更新工作进度。

Parameters:

| Name | Description |
|---|---|
| `work_id` | 工作 ID。 |
| `progress` | 当前进度。 |
| `message` | 进度说明。 |

Returns: 更新成功返回 true。

#### `get_task`

- API: `public`

```gdscript
func get_task(work_id: StringName) -> GFBackgroundWorkTask:
```

获取工作。

Parameters:

| Name | Description |
|---|---|
| `work_id` | 工作 ID。 |

Returns: 工作记录；不存在时返回 null。

#### `clear_finished_tasks`

- API: `public`

```gdscript
func clear_finished_tasks() -> void:
```

清理已完成的历史工作记录。

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清空全部工作。调用前应确保不再需要正在执行的线程结果。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含任务计数、queued_ids、running_thread_ids、resource_paths、apply_ids、finished_ids、暂停状态和 apply 时间预算。

## GFBatchedLogSink

- Path: `addons/gf/standard/utilities/logging/gf_batched_log_sink.gd`
- Extends: `GFLogSink`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFBatchedLogSink: 结构化日志批量转发 sink。 该 sink 只负责清洗、缓冲和分批，把实际传输交给 sender_callback 或 batch_ready 信号。 它不绑定任何远端服务、HTTP 协议或业务字段。

### Signals

#### `batch_ready`

- API: `public`

```gdscript
signal batch_ready(batch: Array[Dictionary])
```

批次准备好时发出。

Parameters:

| Name | Description |
|---|---|
| `batch` | 日志批次数组。 |

Schemas:

- `batch`: Array[Dictionary] of sanitized log entries.

### Properties

#### `batch_size`

- API: `public`

```gdscript
var batch_size: int = 20:
```

每批最多包含的日志条数。

#### `max_queue_size`

- API: `public`

```gdscript
var max_queue_size: int = 500:
```

队列最多保留的日志条数，超出时丢弃最旧条目。

#### `flush_interval_msec`

- API: `public`

```gdscript
var flush_interval_msec: int = 1000:
```

自动 flush 间隔。设为 0 时只按 batch_size 或显式 flush。

#### `omit_formatted_text`

- API: `public`

```gdscript
var omit_formatted_text: bool = false
```

是否在转发前移除 text 字段，减少重复载荷。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

发送时附加到批次外层的元数据。

Schemas:

- `metadata`: Dictionary[String, Variant] copied into each outgoing payload.

#### `sender_callback`

- API: `public`

```gdscript
var sender_callback: Callable = Callable()
```

项目提供的发送回调，签名建议为 func(payload: Dictionary) -> Dictionary。

### Methods

#### `init`

- API: `public`

```gdscript
func init(_owner: Object) -> void:
```

初始化 sink。

Parameters:

| Name | Description |
|---|---|
| `_owner` | 持有该 sink 的日志工具。 |

#### `write`

- API: `public`

```gdscript
func write(entry: Dictionary) -> void:
```

写入一条结构化日志。

Parameters:

| Name | Description |
|---|---|
| `entry` | 日志条目字典。 |

Schemas:

- `entry`: Dictionary log entry produced by GFLogUtility.

#### `flush`

- API: `public`

```gdscript
func flush() -> void:
```

发送当前队列中的一批日志。

#### `shutdown`

- API: `public`

```gdscript
func shutdown() -> void:
```

关闭 sink 并尽力 flush。

#### `get_pending_count`

- API: `public`

```gdscript
func get_pending_count() -> int:
```

获取队列中的日志数量。

Returns: 待发送日志数量。

#### `get_dropped_count`

- API: `public`

```gdscript
func get_dropped_count() -> int:
```

获取因队列上限丢弃的日志数量。

Returns: 丢弃数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: sink 状态字典。

Schemas:

- `return`: Dictionary with pending_count, dropped_count, batch_size, max_queue_size, flush_interval_msec, and has_sender_callback.

## GFBigNumber

- Path: `addons/gf/standard/foundation/numeric/gf_big_number.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFBigNumber: 面向挂机/放置场景的近似大数值对象。 使用科学计数法的尾数 + 指数表示任意量级的数值， 适合做超出原生 int/float 直观显示范围后的比较、加减乘除与格式化输入。

### Properties

#### `mantissa`

- API: `public`

```gdscript
var mantissa: float = 0.0
```

归一化后的尾数。非零时其绝对值始终落在 [1, 10) 区间内。

#### `exponent`

- API: `public`

```gdscript
var exponent: int = 0
```

以 10 为底的指数。

### Methods

#### `zero`

- API: `public`

```gdscript
static func zero() -> GFBigNumber:
```

创建一个值为 0 的大数。

Returns: 零值实例。

#### `one`

- API: `public`

```gdscript
static func one() -> GFBigNumber:
```

创建一个值为 1 的大数。

Returns: 一值实例。

#### `from_int`

- API: `public`

```gdscript
static func from_int(value: int) -> GFBigNumber:
```

从 int 构建大数。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始整数。 |

Returns: 归一化后的大数实例。

#### `from_float`

- API: `public`

```gdscript
static func from_float(value: float) -> GFBigNumber:
```

从 float 构建大数。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始浮点数。 |

Returns: 归一化后的大数实例。

#### `from_string`

- API: `public`

```gdscript
static func from_string(value: String) -> GFBigNumber:
```

从字符串构建大数，支持普通写法与科学计数法。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始字符串，如 "12345"、"1.23e8"。 |

Returns: 解析后的大数实例。

#### `from_variant`

- API: `public`

```gdscript
static func from_variant(value: Variant) -> GFBigNumber:
```

从任意支持的 Variant 构建大数。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |

Returns: 对应的大数实例。

Schemas:

- `value`: Variant numeric value accepted by GFBigNumber.

#### `clone`

- API: `public`

```gdscript
func clone() -> GFBigNumber:
```

克隆当前大数。

Returns: 内容相同的新实例。

#### `is_zero`

- API: `public`

```gdscript
func is_zero() -> bool:
```

当前值是否为零。

Returns: 为零时返回 true。

#### `is_negative`

- API: `public`

```gdscript
func is_negative() -> bool:
```

当前值是否为负数。

Returns: 为负时返回 true。

#### `abs_value`

- API: `public`

```gdscript
func abs_value() -> GFBigNumber:
```

获取绝对值。

Returns: 新的大数实例。

#### `negated`

- API: `public`

```gdscript
func negated() -> GFBigNumber:
```

获取相反数。

Returns: 新的大数实例。

#### `compare_to`

- API: `public`

```gdscript
func compare_to(other: GFBigNumber) -> int:
```

比较当前值与另一个大数。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个大数实例。 |

Returns: 当前值大于 other 返回 1，小于返回 -1，相等返回 0。

#### `add`

- API: `public`

```gdscript
func add(other: GFBigNumber) -> GFBigNumber:
```

与另一个大数相加。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个大数实例。 |

Returns: 相加结果。

#### `subtract`

- API: `public`

```gdscript
func subtract(other: GFBigNumber) -> GFBigNumber:
```

与另一个大数相减。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个大数实例。 |

Returns: 相减结果。

#### `multiply`

- API: `public`

```gdscript
func multiply(other: GFBigNumber) -> GFBigNumber:
```

与另一个大数相乘。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个大数实例。 |

Returns: 相乘结果。

#### `divide`

- API: `public`

```gdscript
func divide(other: GFBigNumber) -> GFBigNumber:
```

与另一个大数相除。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个大数实例。 |

Returns: 相除结果。

#### `powi`

- API: `public`

```gdscript
func powi(power: int) -> GFBigNumber:
```

将当前大数提升到整数次幂。

Parameters:

| Name | Description |
|---|---|
| `power` | 幂指数。 |

Returns: 幂运算结果。

#### `powf`

- API: `public`

```gdscript
func powf(power: float) -> GFBigNumber:
```

将当前大数提升到浮点次幂。

Parameters:

| Name | Description |
|---|---|
| `power` | 幂指数。 |

Returns: 幂运算结果。

#### `to_float`

- API: `public`

```gdscript
func to_float() -> float:
```

将当前值转换为 float。

Returns: 可表达时返回浮点值，超出范围时返回 +/-INF。

#### `to_plain_string`

- API: `public`

```gdscript
func to_plain_string(decimal_places: int = _DEFAULT_PLAIN_DECIMALS, trim_zeroes: bool = true) -> String:
```

在量级适中时输出普通十进制字符串，过大时会回退到科学计数法。

Parameters:

| Name | Description |
|---|---|
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |

Returns: 普通字符串表示。

#### `to_scientific_string`

- API: `public`

```gdscript
func to_scientific_string( decimal_places: int = 2, trim_zeroes: bool = true, use_truncation: bool = false ) -> String:
```

输出科学计数法字符串。

Parameters:

| Name | Description |
|---|---|
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |

Returns: 科学计数法字符串。

## GFBlackboardEntry

- Path: `addons/gf/standard/foundation/blackboard/gf_blackboard_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFBlackboardEntry: 通用黑板字段声明。 只描述字段键、类型、必填性、空值策略和默认值，不绑定行为树、AI 或具体玩法。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 不做类型约束。 ANY, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Vector2。 VECTOR2, ## Vector2i。 VECTOR2I, ## Vector3。 VECTOR3, ## Vector3i。 VECTOR3I, ## Color。 COLOR, ## Dictionary。 DICTIONARY, ## Array。 ARRAY, ## Object。 OBJECT, }
```

黑板字段值类型。

### Properties

#### `key`

- API: `public`

```gdscript
var key: StringName = &""
```

字段键。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.ANY
```

字段值类型。

#### `required`

- API: `public`

```gdscript
var required: bool = false
```

是否必须出现在黑板数据中。

#### `allow_null`

- API: `public`

```gdscript
var allow_null: bool = true
```

是否允许 null 值。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

默认值。`GFBlackboardSchema.apply_defaults()` 会在缺字段时使用。

Schemas:

- `default_value`: Variant default blackboard value.

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供编辑器、调试器或项目工具使用。

Schemas:

- `metadata`: Dictionary metadata for editor, debugger, or project tooling.

### Methods

#### `get_key`

- API: `public`

```gdscript
func get_key() -> StringName:
```

获取稳定字段键。

Returns: 字段键。

#### `is_value_valid`

- API: `public`

```gdscript
func is_value_valid(value: Variant) -> bool:
```

检查输入值是否符合字段声明。

Parameters:

| Name | Description |
|---|---|
| `value` | 待检查值。 |

Returns: 符合声明时返回 true。

Schemas:

- `value`: Variant value to validate.

#### `coerce_value`

- API: `public`

```gdscript
func coerce_value(value: Variant) -> Variant:
```

将输入值转换为字段要求的类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 转换后的值。

Schemas:

- `value`: Variant value to coerce.
- `return`: Variant coerced value.

#### `try_coerce_value`

- API: `public`

```gdscript
func try_coerce_value(value: Variant) -> Dictionary:
```

尝试转换输入值并返回转换报告。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 包含 ok、value、message 的转换报告。

Schemas:

- `value`: Variant value to coerce.
- `return`: Dictionary with ok, value, and message.

#### `duplicate_entry`

- API: `public`

```gdscript
func duplicate_entry() -> GFBlackboardEntry:
```

创建同内容拷贝，避免运行时修改污染共享 Resource。

Returns: 新字段声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出字段声明摘要。

Returns: 字段声明字典。

Schemas:

- `return`: Dictionary entry description.

#### `value_type_to_name`

- API: `public`

```gdscript
static func value_type_to_name(type_id: ValueType) -> String:
```

将字段类型转换为可读名称。

Parameters:

| Name | Description |
|---|---|
| `type_id` | 字段类型。 |

Returns: 类型名称。

## GFBlackboardSchema

- Path: `addons/gf/standard/foundation/blackboard/gf_blackboard_schema.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFBlackboardSchema: 通用黑板数据结构声明与校验器。 用于为行为树、状态机、任务系统或项目自定义运行时字典提供可复用字段契约。

### Properties

#### `schema_id`

- API: `public`

```gdscript
var schema_id: StringName = &""
```

Schema 标识。为空时可由调用方自行决定命名。

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFBlackboardEntry] = []
```

字段声明列表。

#### `allow_extra_keys`

- API: `public`

```gdscript
var allow_extra_keys: bool = true
```

是否允许包含 schema 未声明的字段。

#### `coerce_values`

- API: `public`

```gdscript
var coerce_values: bool = false
```

是否在校验前按字段声明尝试类型转换。

#### `fail_on_coerce_error`

- API: `public`

```gdscript
var fail_on_coerce_error: bool = true
```

启用 coerce_values 时，转换失败是否作为校验错误。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供编辑器、调试器或项目工具使用。

Schemas:

- `metadata`: Dictionary metadata for editor, debugger, or project tooling.

### Methods

#### `get_schema_key`

- API: `public`

```gdscript
func get_schema_key() -> StringName:
```

获取稳定 schema 键。

Returns: Schema 标识。

#### `get_entry`

- API: `public`

```gdscript
func get_entry(entry_key: StringName) -> GFBlackboardEntry:
```

获取字段声明。

Parameters:

| Name | Description |
|---|---|
| `entry_key` | 字段键。 |

Returns: 找到时返回字段声明，否则返回 null。

#### `has_entry`

- API: `public`

```gdscript
func has_entry(entry_key: StringName) -> bool:
```

检查字段声明是否存在。

Parameters:

| Name | Description |
|---|---|
| `entry_key` | 字段键。 |

Returns: 存在返回 true。

#### `get_entry_keys`

- API: `public`

```gdscript
func get_entry_keys() -> PackedStringArray:
```

获取当前 schema 的字段键列表。

Returns: 排序后的字段键。

#### `build_defaults`

- API: `public`

```gdscript
func build_defaults(include_optional: bool = true) -> Dictionary:
```

创建默认黑板数据。

Parameters:

| Name | Description |
|---|---|
| `include_optional` | 为 true 时包含非必填字段。 |

Returns: 默认数据字典。

Schemas:

- `return`: Dictionary default blackboard values.

#### `apply_defaults`

- API: `public`

```gdscript
func apply_defaults(values: Dictionary, include_optional: bool = true, should_coerce: bool = true) -> Dictionary:
```

为输入数据补齐默认值。

Parameters:

| Name | Description |
|---|---|
| `values` | 输入黑板数据。 |
| `include_optional` | 为 true 时补齐非必填字段。 |
| `should_coerce` | 为 true 时按字段声明转换已有值与默认值。 |

Returns: 补齐后的新字典。

Schemas:

- `values`: Dictionary source blackboard values.
- `return`: Dictionary normalized blackboard values.

#### `coerce_dictionary`

- API: `public`

```gdscript
func coerce_dictionary(values: Dictionary, include_defaults: bool = true) -> Dictionary:
```

按字段声明转换黑板数据。

Parameters:

| Name | Description |
|---|---|
| `values` | 输入黑板数据。 |
| `include_defaults` | 为 true 时同时补默认值。 |

Returns: 转换后的新字典。

Schemas:

- `values`: Dictionary source blackboard values.
- `return`: Dictionary coerced blackboard values.

#### `validate_values`

- API: `public`

```gdscript
func validate_values(values: Dictionary) -> Dictionary:
```

校验黑板数据。

Parameters:

| Name | Description |
|---|---|
| `values` | 输入黑板数据。 |

Returns: 校验报告字典。

Schemas:

- `values`: Dictionary source blackboard values.
- `return`: Dictionary validation report.

#### `duplicate_schema`

- API: `public`

```gdscript
func duplicate_schema() -> GFBlackboardSchema:
```

创建同内容拷贝，避免运行时修改污染共享 Resource。

Returns: 新 schema。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出 schema 摘要。

Returns: schema 字典。

Schemas:

- `return`: Dictionary schema description.

## GFBudgetLedger

- Path: `addons/gf/standard/foundation/budget/gf_budget_ledger.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFBudgetLedger: 通用资源预算账本。 用于记录一组抽象资源的容量、可用量和消耗结果。 资源含义由项目决定，框架只提供预算检查、消费、释放和快照。

### Signals

#### `budget_changed`

- API: `public`

```gdscript
signal budget_changed(budget_id: StringName, available: float, capacity: float)
```

资源预算变化后发出。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `available` | 当前可用量。 |
| `capacity` | 当前容量。 |

#### `budget_consumed`

- API: `public`

```gdscript
signal budget_consumed(budget_id: StringName, amount: float)
```

资源消费成功后发出。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `amount` | 消费数量。 |

#### `budget_rejected`

- API: `public`

```gdscript
signal budget_rejected(budget_id: StringName, amount: float, reason: String)
```

资源消费被拒绝后发出。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `amount` | 请求数量。 |
| `reason` | 拒绝原因。 |

### Methods

#### `set_capacity`

- API: `public`

```gdscript
func set_capacity(budget_id: StringName, capacity: float, reset_available: bool = true) -> void:
```

设置预算容量，并可选重置可用量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `capacity` | 容量。 |
| `reset_available` | 是否把可用量重置为容量。 |

#### `set_available`

- API: `public`

```gdscript
func set_available(budget_id: StringName, available: float) -> void:
```

设置当前可用量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `available` | 可用量。 |

#### `get_capacity`

- API: `public`

```gdscript
func get_capacity(budget_id: StringName) -> float:
```

获取容量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |

Returns: 容量；不存在时返回 0。

#### `get_available`

- API: `public`

```gdscript
func get_available(budget_id: StringName) -> float:
```

获取可用量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |

Returns: 可用量；不存在时返回 0。

#### `can_consume`

- API: `public`

```gdscript
func can_consume(budget_id: StringName, amount: float) -> bool:
```

是否有足够预算。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `amount` | 请求数量。 |

Returns: 预算足够时返回 true。

#### `consume`

- API: `public`

```gdscript
func consume(budget_id: StringName, amount: float, metadata: Dictionary = {}) -> Dictionary:
```

尝试消费预算。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `amount` | 消费数量。 |
| `metadata` | 调用方附加信息。 |

Returns: 消费结果字典。

Schemas:

- `metadata`: Dictionary copied into the consume result.
- `return`: Dictionary with ok, budget_id, amount, reason, available, capacity, and metadata.

#### `release`

- API: `public`

```gdscript
func release(budget_id: StringName, amount: float) -> void:
```

释放预算，可用量不会超过容量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识。 |
| `amount` | 释放数量。 |

#### `reset`

- API: `public`

```gdscript
func reset(budget_id: StringName = &"") -> void:
```

将一个或全部预算重置为容量。

Parameters:

| Name | Description |
|---|---|
| `budget_id` | 预算标识；为空时重置全部。 |

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有预算。

#### `get_snapshot`

- API: `public`

```gdscript
func get_snapshot() -> Dictionary:
```

获取预算快照。

Returns: 预算字典副本。

Schemas:

- `return`: Dictionary from budget id to capacity and available values.

## GFBuildInfo

- Path: `addons/gf/standard/utilities/debug/gf_build_info.gd`
- Extends: `Resource`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFBuildInfo: 运行时构建信息快照。 用统一 Resource 承载项目版本、GF 版本、构建号、提交号和运行平台信息， 便于诊断、日志、存档元数据或项目自己的版本界面复用。

### Constants

#### `BUILD_ID_SETTING`

- API: `public`

```gdscript
const BUILD_ID_SETTING: String = "gf/build/id"
```

构建标识 ProjectSettings 键。

#### `COMMIT_HASH_SETTING`

- API: `public`

```gdscript
const COMMIT_HASH_SETTING: String = "gf/build/commit_hash"
```

提交哈希 ProjectSettings 键。

#### `BRANCH_SETTING`

- API: `public`

```gdscript
const BRANCH_SETTING: String = "gf/build/branch"
```

分支名 ProjectSettings 键。

#### `TAG_SETTING`

- API: `public`

```gdscript
const TAG_SETTING: String = "gf/build/tag"
```

标签名 ProjectSettings 键。

#### `COMMIT_COUNT_SETTING`

- API: `public`

```gdscript
const COMMIT_COUNT_SETTING: String = "gf/build/commit_count"
```

提交数量 ProjectSettings 键。

#### `IS_DIRTY_SETTING`

- API: `public`

```gdscript
const IS_DIRTY_SETTING: String = "gf/build/is_dirty"
```

工作区 dirty 状态 ProjectSettings 键。

#### `TIME_UTC_SETTING`

- API: `public`

```gdscript
const TIME_UTC_SETTING: String = "gf/build/time_utc"
```

构建 UTC 时间 ProjectSettings 键。

#### `METADATA_SETTING`

- API: `public`

```gdscript
const METADATA_SETTING: String = "gf/build/metadata"
```

项目自定义构建元数据 ProjectSettings 键。

#### `PROJECT_NAME_SETTING`

- API: `public`

```gdscript
const PROJECT_NAME_SETTING: String = "application/config/name"
```

项目名称 ProjectSettings 键。

#### `PROJECT_VERSION_SETTING`

- API: `public`

```gdscript
const PROJECT_VERSION_SETTING: String = "application/config/version"
```

项目版本 ProjectSettings 键。

### Properties

#### `project_name`

- API: `public`

```gdscript
var project_name: String = ""
```

项目名称。

#### `project_version`

- API: `public`

```gdscript
var project_version: String = ""
```

项目版本。

#### `framework_version`

- API: `public`

```gdscript
var framework_version: String = ""
```

GF Framework 版本。

#### `build_id`

- API: `public`

```gdscript
var build_id: String = ""
```

构建流水线或发行流程写入的构建标识。

#### `commit_hash`

- API: `public`

```gdscript
var commit_hash: String = ""
```

构建对应的提交哈希。

#### `branch`

- API: `public`

```gdscript
var branch: String = ""
```

构建对应的分支名。

#### `tag`

- API: `public`

```gdscript
var tag: String = ""
```

构建对应的标签名。

#### `commit_count`

- API: `public`

```gdscript
var commit_count: int = 0
```

构建对应的提交数量或流水线序号。

#### `is_dirty`

- API: `public`

```gdscript
var is_dirty: bool = false
```

构建来源工作区是否存在未提交改动。

#### `build_time_utc`

- API: `public`

```gdscript
var build_time_utc: String = ""
```

构建时间，建议使用 UTC ISO 文本。

#### `engine_version`

- API: `public`

```gdscript
var engine_version: String = ""
```

当前运行的 Godot 引擎版本文本。

#### `platform_name`

- API: `public`

```gdscript
var platform_name: String = ""
```

当前运行平台名称。

#### `is_debug_build`

- API: `public`

```gdscript
var is_debug_build: bool = false
```

当前运行扩展是否为 debug build。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义构建元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义构建元数据。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary。

Returns: 构建信息字典。

Schemas:

- `return`: Dictionary，包含 project_name、project_version、framework_version、build_id、commit_hash、branch、tag、commit_count、is_dirty、build_time_utc、engine_version、platform_name、is_debug_build 和 metadata 字段。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 构建信息字典。 |

Schemas:

- `data`: Dictionary，可包含 project_name、project_version、framework_version、build_id、commit_hash、branch、tag、commit_count、is_dirty、build_time_utc、engine_version、platform_name、is_debug_build 和 metadata 字段。

#### `collect`

- API: `public`

```gdscript
static func collect() -> GFBuildInfo:
```

创建当前运行环境的构建信息。

Returns: 构建信息快照。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFBuildInfo:
```

从 Dictionary 创建构建信息。

Parameters:

| Name | Description |
|---|---|
| `data` | 构建信息字典。 |

Returns: 新构建信息。

Schemas:

- `data`: Dictionary，可包含 GFBuildInfo.to_dict() 输出的字段。

#### `collect_git_metadata`

- API: `public`

```gdscript
static func collect_git_metadata(work_dir: String = "res://") -> Dictionary:
```

从当前 Git 工作区收集构建元数据。该方法通常由导出脚本或编辑器工具调用。

Parameters:

| Name | Description |
|---|---|
| `work_dir` | Git 工作区目录；支持 `res://`、`user://` 或原生路径。 |

Returns: Git 构建元数据。

Schemas:

- `return`: Dictionary，包含 commit_hash、branch、tag、commit_count、is_dirty 和 build_time_utc 字段。

#### `write_git_metadata_to_project_settings`

- API: `public`

```gdscript
static func write_git_metadata_to_project_settings( work_dir: String = "res://", extra_metadata: Dictionary = {}, save_settings: bool = false ) -> Dictionary:
```

把 Git 构建元数据写入 ProjectSettings，供 collect() 在运行时读取。

Parameters:

| Name | Description |
|---|---|
| `work_dir` | Git 工作区目录；支持 `res://`、`user://` 或原生路径。 |
| `extra_metadata` | 项目自定义构建元数据。 |
| `save_settings` | 是否立即保存 ProjectSettings。 |

Returns: 写入的构建元数据。

Schemas:

- `extra_metadata`: Dictionary，保存项目自定义构建元数据。
- `return`: Dictionary，包含已写入的 Git 构建元数据。

#### `duplicate_info`

- API: `public`

```gdscript
func duplicate_info() -> GFBuildInfo:
```

复制构建信息。

Returns: 深拷贝后的构建信息。

## GFBuildInfoExportPlugin

- Path: `addons/gf/standard/utilities/debug/editor/gf_build_info_export_plugin.gd`
- Extends: `EditorExportPlugin`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFBuildInfoExportPlugin: 导出时写入构建元数据的可选编辑器插件。 只负责把通用 Git 构建字段写入 ProjectSettings，项目仍可决定是否保存、 是否恢复旧值以及如何展示这些字段。

### Constants

#### `ENABLED_SETTING`

- API: `public`

```gdscript
const ENABLED_SETTING: String = "gf/build/export/write_git_metadata"
```

是否在导出开始时写入 Git 构建元数据的 ProjectSettings 键。

#### `RESTORE_PREVIOUS_SETTING`

- API: `public`

```gdscript
const RESTORE_PREVIOUS_SETTING: String = "gf/build/export/restore_previous_settings"
```

导出结束后是否恢复旧构建元数据的 ProjectSettings 键。

#### `SAVE_PROJECT_SETTINGS_SETTING`

- API: `public`

```gdscript
const SAVE_PROJECT_SETTINGS_SETTING: String = "gf/build/export/save_project_settings"
```

写入或恢复后是否立即保存 ProjectSettings 的设置键。

#### `EXTRA_METADATA_SETTING`

- API: `public`

```gdscript
const EXTRA_METADATA_SETTING: String = "gf/build/export/metadata"
```

导出时附加到构建信息中的自定义元数据 ProjectSettings 键。

## GFBuildInfoUtility

- Path: `addons/gf/standard/utilities/debug/gf_build_info_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFBuildInfoUtility: 构建信息访问工具。 在运行时提供稳定的构建信息副本，供诊断、日志、存档元数据或项目 UI 查询。

### Properties

#### `build_info`

- API: `public`

```gdscript
var build_info: GFBuildInfo = null
```

当前构建信息。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

采集当前运行环境的构建信息。

#### `refresh`

- API: `public`

```gdscript
func refresh() -> GFBuildInfo:
```

重新采集当前运行环境的构建信息。

Returns: 更新后的构建信息副本。

#### `set_build_info`

- API: `public`

```gdscript
func set_build_info(info: GFBuildInfo) -> void:
```

手动设置构建信息。

Parameters:

| Name | Description |
|---|---|
| `info` | 构建信息；为空时会清空当前值。 |

#### `get_build_info`

- API: `public`

```gdscript
func get_build_info(copy: bool = true) -> GFBuildInfo:
```

获取构建信息。

Parameters:

| Name | Description |
|---|---|
| `copy` | 为 true 时返回深拷贝，避免调用方修改内部状态。 |

Returns: 构建信息。

#### `get_build_info_dict`

- API: `public`

```gdscript
func get_build_info_dict() -> Dictionary:
```

获取构建信息字典。

Returns: 构建信息字典。

Schemas:

- `return`: Dictionary，包含 GFBuildInfo.to_dict() 输出的字段；无构建信息时为空 Dictionary。

#### `get_summary`

- API: `public`

```gdscript
func get_summary() -> String:
```

获取简短版本摘要。

Returns: 构建信息摘要。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 available、summary 和 info 字段。

## GFCallableTargetRef

- Path: `addons/gf/standard/utilities/signals/bridge/gf_callable_target_ref.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFCallableTargetRef: 可资源化的 Callable 目标引用。 该资源只描述相对于某个根节点的目标节点、方法名和默认参数。 它不决定调用时机，也不解释方法的业务含义。

### Properties

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath = NodePath("")
```

目标节点路径。为空时使用传入的根节点。

#### `method_name`

- API: `public`

```gdscript
var method_name: StringName = &""
```

要调用的方法名。

#### `default_args`

- API: `public`

```gdscript
var default_args: Array = []
```

每次调用时追加到末尾的默认参数。

Schemas:

- `default_args`: Array，追加在动态信号桥接参数后的额外参数。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，关联到 callable 目标引用的项目侧元数据。

### Methods

#### `resolve_target`

- API: `public`

```gdscript
func resolve_target(root: Node) -> Object:
```

解析调用目标。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 目标对象；无法解析时返回 null。

#### `get_callable`

- API: `public`

```gdscript
func get_callable(root: Node) -> Callable:
```

创建目标 Callable。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 有效 Callable；无法解析时返回空 Callable。

#### `is_valid_for`

- API: `public`

```gdscript
func is_valid_for(root: Node) -> bool:
```

检查调用目标是否有效。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 有效时返回 true。

#### `call_with_args`

- API: `public`

```gdscript
func call_with_args(root: Node, args: Array = []) -> Dictionary:
```

调用目标方法。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |
| `args` | 动态参数。 |

Returns: 结构化调用结果。

Schemas:

- `args`: Array，传入 default_args 之前的动态参数。
- `return`: Dictionary，包含 ok、reason 和 value。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为调试字典。

Returns: 目标快照。

Schemas:

- `return`: Dictionary，包含 target_path、method_name、default_args 和 metadata。

## GFCommandHistoryUtility

- Path: `addons/gf/standard/utilities/history/gf_command_history_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCommandHistoryUtility: 可撤销命令历史管理器。 负责维护 `GFUndoableCommand` 的撤销栈与重做栈， 并提供同步/异步重放与历史序列化能力。

### Properties

#### `max_history_size`

- API: `public`

```gdscript
var max_history_size: int:
```

撤销栈的最大容量；为 0 时表示不限制。

#### `undo_count`

- API: `public`

```gdscript
var undo_count: int:
```

当前撤销栈深度。

#### `redo_count`

- API: `public`

```gdscript
var redo_count: int:
```

当前重做栈深度。

#### `async_timeout_seconds`

- API: `public`

```gdscript
var async_timeout_seconds: float = 30.0
```

异步命令等待超时时间（秒）。小于等于 0 时表示不启用超时。

#### `is_processing_async`

- API: `public`

```gdscript
var is_processing_async: bool:
```

当前是否正在等待一条异步命令完成。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化命令历史并清空撤销、重做栈。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放命令历史并取消等待中的异步历史操作。

#### `record`

- API: `public`

```gdscript
func record(cmd: GFUndoableCommand) -> void:
```

记录一条已经执行完成的命令。

Parameters:

| Name | Description |
|---|---|
| `cmd` | 已执行的命令实例。 |

#### `execute_command`

- API: `public`

```gdscript
func execute_command(cmd: GFUndoableCommand) -> Variant:
```

执行命令并自动记录到撤销栈。

Parameters:

| Name | Description |
|---|---|
| `cmd` | 要执行的命令实例。 |

Returns: `execute()` 的原始返回值；异步命令可由调用方自行 `await`。

Schemas:

- `return`: Variant returned by GFUndoableCommand.execute(), including null or Signal.

#### `undo_last`

- API: `public`

```gdscript
func undo_last() -> bool:
```

撤销最后一条命令。

Returns: 成功撤销时返回 `true`。

#### `undo_last_async`

- API: `public`

```gdscript
func undo_last_async() -> bool:
```

异步撤销最后一条命令。

Returns: 成功撤销时返回 `true`。

#### `redo`

- API: `public`

```gdscript
func redo() -> bool:
```

重做最近被撤销的命令。

Returns: 成功重做时返回 `true`。

#### `redo_async`

- API: `public`

```gdscript
func redo_async() -> bool:
```

异步重做最近被撤销的命令。

Returns: 成功重做时返回 `true`。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有历史记录。

#### `can_undo`

- API: `public`

```gdscript
func can_undo() -> bool:
```

检查当前是否允许撤销。

Returns: 有可撤销命令时返回 `true`。

#### `can_redo`

- API: `public`

```gdscript
func can_redo() -> bool:
```

检查当前是否允许重做。

Returns: 有可重做命令时返回 `true`。

#### `get_undo_history`

- API: `public`

```gdscript
func get_undo_history() -> Array[GFUndoableCommand]:
```

获取撤销栈副本。

Returns: 撤销历史的浅拷贝。

#### `get_redo_history`

- API: `public`

```gdscript
func get_redo_history() -> Array[GFUndoableCommand]:
```

获取重做栈副本。

Returns: 重做历史的浅拷贝。

#### `serialize_history`

- API: `public`

```gdscript
func serialize_history() -> Array[Dictionary]:
```

将撤销栈序列化为纯数据数组。

Returns: 适合持久化的历史数据。

Schemas:

- `return`: Array[Dictionary] serialized command snapshots produced by command serialize() or get_snapshot().

#### `serialize_full_history`

- API: `public`

```gdscript
func serialize_full_history() -> Dictionary:
```

将完整命令历史序列化为纯数据字典。 包含 `undo` 与 `redo` 两个栈，可用于全量运行时快照恢复。

Returns: 适合持久化的完整历史数据。

Schemas:

- `return`: Dictionary with undo and redo Array[Dictionary] stacks.

#### `deserialize_history`

- API: `public`

```gdscript
func deserialize_history(data_array: Array, command_builder: Callable) -> void:
```

通过构造器从纯数据恢复撤销栈。

Parameters:

| Name | Description |
|---|---|
| `data_array` | 历史数据数组。 |
| `command_builder` | 负责反序列化命令实例的构造器。 |

Schemas:

- `data_array`: Array[Dictionary] serialized command snapshots produced by serialize_history().

#### `deserialize_full_history`

- API: `public`

```gdscript
func deserialize_full_history(data: Dictionary, command_builder: Callable) -> void:
```

通过构造器从完整历史数据恢复撤销栈与重做栈。

Parameters:

| Name | Description |
|---|---|
| `data` | 由 `serialize_full_history()` 生成的字典数据。 |
| `command_builder` | 负责反序列化命令实例的构造器。 |

Schemas:

- `data`: Dictionary with undo and redo Array[Dictionary] stacks.

## GFCommandSequence

- Path: `addons/gf/standard/sequence/gf_command_sequence.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFCommandSequence: 通用顺序指令执行器。 可运行 `GFSequenceStep`、`GFCommand` 或任何实现 `execute()` / `resolve()` 的对象。它只负责顺序、等待和架构注入，不规定具体业务语义。

### Signals

#### `sequence_started`

- API: `public`

```gdscript
signal sequence_started
```

序列开始执行时发出。

#### `step_started`

- API: `public`

```gdscript
signal step_started(index: int, step: Variant)
```

步骤开始执行时发出。

Parameters:

| Name | Description |
|---|---|
| `index` | 步骤索引。 |
| `step` | 步骤对象、命令或 Callable。 |

Schemas:

- `step`: Variant sequence step value.

#### `step_completed`

- API: `public`

```gdscript
signal step_completed(index: int, step: Variant)
```

步骤执行完毕时发出。

Parameters:

| Name | Description |
|---|---|
| `index` | 步骤索引。 |
| `step` | 步骤对象、命令或 Callable。 |

Schemas:

- `step`: Variant sequence step value.

#### `step_failed`

- API: `public`

```gdscript
signal step_failed(index: int, step: Variant, error: String)
```

步骤报告失败时发出。

Parameters:

| Name | Description |
|---|---|
| `index` | 步骤索引。 |
| `step` | 步骤对象、命令或 Callable。 |
| `error` | 错误消息。 |

Schemas:

- `step`: Variant sequence step value.

#### `sequence_completed`

- API: `public`

```gdscript
signal sequence_completed
```

序列全部执行完成时发出。

#### `sequence_failed`

- API: `public`

```gdscript
signal sequence_failed(report: Dictionary)
```

序列因步骤失败而停止时发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 运行报告。 |

Schemas:

- `report`: Dictionary run report.

#### `sequence_cancelled`

- API: `public`

```gdscript
signal sequence_cancelled
```

序列被取消时发出。

### Properties

#### `steps`

- API: `public`

```gdscript
var steps: Array = []
```

默认步骤列表。

Schemas:

- `steps`: Array of GFSequenceStep, GFCommand, Callable, or objects with execute()/resolve().

#### `context`

- API: `public`

```gdscript
var context: GFSequenceContext
```

序列上下文。

#### `is_running`

- API: `public`

```gdscript
var is_running: bool = false
```

当前是否正在执行。

#### `signal_timeout_seconds`

- API: `public`

```gdscript
var signal_timeout_seconds: float = 30.0
```

等待步骤 Signal 的超时时间（秒）。小于等于 0 时表示不启用超时。

#### `signal_timeout_respects_time_scale`

- API: `public`

```gdscript
var signal_timeout_respects_time_scale: bool = true
```

Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。

#### `stop_on_error`

- API: `public`

```gdscript
var stop_on_error: bool = false
```

步骤返回失败结果时是否停止后续步骤。

#### `rollback_on_failure`

- API: `public`

```gdscript
var rollback_on_failure: bool = false
```

stop_on_error 生效后，是否对已完成且实现 undo() 的步骤逆序回滚。

#### `last_run_report`

- API: `public`

```gdscript
var last_run_report: Dictionary = {}
```

最近一次运行报告。

Schemas:

- `last_run_report`: Dictionary run report from the most recent run().

### Methods

#### `run`

- API: `public`

```gdscript
func run(p_steps: Array = []) -> void:
```

运行序列。

Parameters:

| Name | Description |
|---|---|
| `p_steps` | 可选临时步骤列表；为空时使用 `steps`。 |

Schemas:

- `p_steps`: Array of GFSequenceStep, GFCommand, Callable, or objects with execute()/resolve().

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

请求取消序列。当前步骤实现取消入口时会先收到取消请求，正在等待的 Signal 会在下一帧取消检查后停止。

#### `with_signal_timeout`

- API: `public`

```gdscript
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFCommandSequence:
```

设置等待 Signal 的超时时间，并返回自身以便链式调用。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 超时时间；小于等于 0 时表示不启用超时。 |
| `respect_time_scale` | 是否跟随 GFTimeUtility 的暂停与 time_scale。 |

Returns: 当前序列。

#### `with_failure_policy`

- API: `public`

```gdscript
func with_failure_policy( should_stop_on_error: bool = true, should_rollback_on_failure: bool = false ) -> GFCommandSequence:
```

设置失败处理策略，并返回自身以便链式调用。

Parameters:

| Name | Description |
|---|---|
| `should_stop_on_error` | 是否在失败结果后停止。 |
| `should_rollback_on_failure` | 是否逆序调用已完成步骤 undo()。 |

Returns: 当前序列。

## GFConfigBuildProfile

- Path: `addons/gf/standard/utilities/config/gf_config_build_profile.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigBuildProfile: 配置表构建过滤配置。 用 groups 与 tags 描述一组通用过滤条件，可用于导出前裁剪 schema 或记录。 具体分组名称由项目决定，GF 不内置 client、server 或 editor 语义。

### Properties

#### `profile_id`

- API: `public`

```gdscript
var profile_id: StringName = &""
```

Profile 稳定标识。

#### `include_groups`

- API: `public`

```gdscript
var include_groups: PackedStringArray = PackedStringArray()
```

为空时不限制包含分组；非空时 metadata 至少命中一个分组才通过。

#### `exclude_groups`

- API: `public`

```gdscript
var exclude_groups: PackedStringArray = PackedStringArray()
```

命中任意排除分组时过滤。

#### `include_tags`

- API: `public`

```gdscript
var include_tags: PackedStringArray = PackedStringArray()
```

为空时不限制包含标签；非空时 metadata 至少命中一个标签才通过。

#### `exclude_tags`

- API: `public`

```gdscript
var exclude_tags: PackedStringArray = PackedStringArray()
```

命中任意排除标签时过滤。

#### `default_include`

- API: `public`

```gdscript
var default_include: bool = true
```

metadata 缺少 groups/tags 时是否默认保留。

#### `record_metadata_field`

- API: `public`

```gdscript
var record_metadata_field: StringName = &"_metadata"
```

记录中存放元数据的字段名。

#### `groups_key`

- API: `public`

```gdscript
var groups_key: StringName = &"groups"
```

metadata 中表示分组的键。

#### `tags_key`

- API: `public`

```gdscript
var tags_key: StringName = &"tags"
```

metadata 中表示标签的键。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目工具扩展使用。

Schemas:

- `metadata`: Dictionary，保存项目工具附加到当前构建 Profile 的元数据。

### Methods

#### `allows_metadata`

- API: `public`

```gdscript
func allows_metadata(source_metadata: Dictionary) -> bool:
```

判断一份 metadata 是否通过当前 Profile。

Parameters:

| Name | Description |
|---|---|
| `source_metadata` | 待检查元数据。 |

Returns: 通过时返回 true。

Schemas:

- `source_metadata`: Dictionary，包含可选 groups_key / tags_key 条目，值可为字符串或字符串数组。

#### `filter_schema`

- API: `public`

```gdscript
func filter_schema(schema: GFConfigTableSchema) -> GFConfigTableSchema:
```

过滤 schema，返回 schema 副本。

Parameters:

| Name | Description |
|---|---|
| `schema` | 原 schema。 |

Returns: 过滤后的 schema；schema 为空时返回 null。

#### `filter_records`

- API: `public`

```gdscript
func filter_records(table_data: Variant) -> Variant:
```

过滤表记录。

Parameters:

| Name | Description |
|---|---|
| `table_data` | Array[Dictionary] 或 Dictionary 表。 |

Returns: 与输入同形状的过滤结果；输入无效时返回原值副本。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary]、Dictionary 表；其他值会按原形复制返回。
- `return`: Variant，过滤后的表数据；有效表会保持输入容器形态。

#### `duplicate_profile`

- API: `public`

```gdscript
func duplicate_profile() -> GFConfigBuildProfile:
```

创建同内容拷贝。

Returns: 新 Profile。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出 Profile 摘要。

Returns: Profile 摘要字典。

Schemas:

- `return`: Dictionary，包含 profile_id、分组/标签过滤器、元数据键设置和 metadata。

## GFConfigLocalizationKeyValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_localization_key_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigLocalizationKeyValidationRule: 文本 key 校验规则。 用于检查配置字段中的本地化 key 是否存在于显式 key 列表、字典或 Godot 翻译表中。

### Properties

#### `allow_empty`

- API: `public`

```gdscript
var allow_empty: bool = true
```

空字符串是否直接视为通过。

#### `known_keys`

- API: `public`

```gdscript
var known_keys: PackedStringArray = PackedStringArray()
```

显式允许的文本 key。

#### `text_map`

- API: `public`

```gdscript
var text_map: Dictionary = {}
```

可选文本字典。只检查 key 是否存在，不解释 value。

Schemas:

- `text_map`: Dictionary，将本地化 key 映射到项目自有文本值。

#### `use_translation_server`

- API: `public`

```gdscript
var use_translation_server: bool = true
```

是否尝试通过 TranslationServer 判断 key。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段和本地化 key 来源设置。

## GFConfigNotDefaultValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_not_default_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigNotDefaultValidationRule: 非默认值校验规则。 用于要求字段显式填写有效值。默认值可以按类型推导，也可以由项目指定。

### Properties

#### `use_type_default`

- API: `public`

```gdscript
var use_type_default: bool = true
```

是否按输入值类型推导默认值。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

use_type_default 为 false 时使用的默认值。

Schemas:

- `default_value`: Variant，use_type_default 为 false 时被当前规则拒绝的显式默认值。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段、use_type_default 和 default_value。

## GFConfigProvider

- Path: `addons/gf/standard/utilities/config/gf_config_provider.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFConfigProvider: 通用的静态导表数据适配器基类。 为了让框架无缝衔接不同项目的导表工具（JSON、CSV 或自定义流水线），提供统一的读取接口。 具体项目应该继承此基类，并实现其数据加载和查询逻辑。

### Methods

#### `get_record`

- API: `public`

```gdscript
func get_record(_table_name: StringName, _id: Variant) -> Variant:
```

根据表名和 ID 获取单条记录。

Parameters:

| Name | Description |
|---|---|
| `_table_name` | 表名。 |
| `_id` | 记录的唯一标识符。 |

Returns: 返回对应的记录数据，默认返回 null 并报错。

Schemas:

- `_id`: Variant，项目配置表使用的记录键，通常为 String、StringName 或 int。
- `return`: Variant，子类通常返回记录 Dictionary 或项目自定义记录对象；未命中时可返回 null。

#### `get_table`

- API: `public`

```gdscript
func get_table(_table_name: StringName) -> Variant:
```

根据表名获取整张表的数据。

Parameters:

| Name | Description |
|---|---|
| `_table_name` | 表名。 |

Returns: 返回整张表的数据，默认返回 null 并报错。

Schemas:

- `return`: Variant，子类通常返回 Array[Dictionary]、Dictionary 或项目自定义表容器；未命中时可返回 null。

#### `register_schema`

- API: `public`

```gdscript
func register_schema(schema: GFConfigTableSchema) -> bool:
```

注册导表结构声明。

Parameters:

| Name | Description |
|---|---|
| `schema` | 表结构声明。 |

Returns: 注册成功返回 true。

#### `unregister_schema`

- API: `public`

```gdscript
func unregister_schema(table_name: StringName) -> void:
```

注销导表结构声明。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |

#### `has_schema`

- API: `public`

```gdscript
func has_schema(table_name: StringName) -> bool:
```

检查是否注册了导表结构声明。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |

Returns: 已注册返回 true。

#### `get_schema`

- API: `public`

```gdscript
func get_schema(table_name: StringName) -> GFConfigTableSchema:
```

获取导表结构声明。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |

Returns: 已注册时返回 schema 拷贝，否则返回 null。

#### `get_schema_ids`

- API: `public`

```gdscript
func get_schema_ids() -> PackedStringArray:
```

获取已注册的导表结构标识。

Returns: 表名列表。

#### `validate_record`

- API: `public`

```gdscript
func validate_record( table_name: StringName, record: Dictionary, row_key: Variant = null, options: Dictionary = {} ) -> Dictionary:
```

使用已注册 schema 校验单条记录。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |
| `record` | 记录字典。 |
| `row_key` | 可选行标识。 |
| `options` | 可选校验上下文。 |

Returns: 校验报告字典。

Schemas:

- `record`: Dictionary，待校验的配置记录，键为字段名，值为字段数据。
- `row_key`: Variant，写入校验报告 issue 的行标识。
- `options`: Dictionary，可包含 source、line、column、row_index、column_index 和 row_locations。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_table`

- API: `public`

```gdscript
func validate_table(table_name: StringName, table_data: Variant = null, options: Dictionary = {}) -> Dictionary:
```

使用已注册 schema 校验整张表。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |
| `table_data` | 可选表数据；为 null 时调用 get_table()。 |
| `options` | 可选校验上下文。 |

Returns: 校验报告字典。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary]、Dictionary 或 null。
- `options`: Dictionary，可包含 source、line、column、row_index、column_index 和 row_locations。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `coerce_record`

- API: `public`

```gdscript
func coerce_record(table_name: StringName, record: Dictionary) -> Dictionary:
```

使用已注册 schema 转换单条记录。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |
| `record` | 记录字典。 |

Returns: 转换后的新记录；缺少 schema 时返回记录拷贝。

Schemas:

- `record`: Dictionary，待转换的配置记录，键为字段名，值为字段数据。
- `return`: Dictionary，转换后的记录副本。

## GFConfigRangeValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_range_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigRangeValidationRule: 数值范围校验规则。 用于声明字段数值上下限。上下限可以单独启用，比较方式可选择是否包含边界。

### Properties

#### `has_minimum`

- API: `public`

```gdscript
var has_minimum: bool = false
```

是否检查最小值。

#### `minimum`

- API: `public`

```gdscript
var minimum: float = 0.0
```

最小值。

#### `inclusive_minimum`

- API: `public`

```gdscript
var inclusive_minimum: bool = true
```

最小值是否包含边界。

#### `has_maximum`

- API: `public`

```gdscript
var has_maximum: bool = false
```

是否检查最大值。

#### `maximum`

- API: `public`

```gdscript
var maximum: float = 0.0
```

最大值。

#### `inclusive_maximum`

- API: `public`

```gdscript
var inclusive_maximum: bool = true
```

最大值是否包含边界。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段和数值范围设置。

## GFConfigReferenceResolver

- Path: `addons/gf/standard/utilities/config/gf_config_reference_resolver.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFConfigReferenceResolver: 通用导表引用校验与解析工具。 在多张表加载后统一检查引用、构建复合索引，并可把记录中的引用解析为目标记录副本。

### Methods

#### `build_index`

- API: `public`

```gdscript
static func build_index(table_data: Variant, field_names: PackedStringArray) -> Dictionary:
```

构建表数据索引。

Parameters:

| Name | Description |
|---|---|
| `table_data` | Array[Dictionary] 或 Dictionary 形式的表数据。 |
| `field_names` | 参与索引的字段名。 |

Returns: 索引字典，key 为复合键，value 为记录数组。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `return`: Dictionary，键为复合索引字符串，值为匹配记录副本组成的 Array[Dictionary]。

#### `validate_tables`

- API: `public`

```gdscript
static func validate_tables( tables_by_name: Dictionary, schemas: Array[GFConfigTableSchema], options: Dictionary = {} ) -> Dictionary:
```

校验多张表的 schema 与引用关系。

Parameters:

| Name | Description |
|---|---|
| `tables_by_name` | 表名到表数据的字典。 |
| `schemas` | schema 列表。 |
| `options` | 可选参数，当前支持 validate_schema。 |

Returns: 聚合校验报告字典。

Schemas:

- `tables_by_name`: Dictionary，键为表名 StringName，值为 Array[Dictionary] 或 Dictionary 表数据。
- `schemas`: Array[GFConfigTableSchema]，参与校验的表结构声明。
- `options`: Dictionary，可包含 validate_schema。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `resolve_record_references`

- API: `public`

```gdscript
static func resolve_record_references( record: Dictionary, schema: GFConfigTableSchema, tables_by_name: Dictionary, schemas_by_name: Dictionary = {} ) -> Dictionary:
```

解析单条记录的引用目标。

Parameters:

| Name | Description |
|---|---|
| `record` | 来源记录。 |
| `schema` | 来源 schema。 |
| `tables_by_name` | 表名到表数据的字典。 |
| `schemas_by_name` | 可选 schema 字典。 |

Returns: 引用 ID 到目标记录副本的字典。

Schemas:

- `record`: Dictionary，来源配置记录。
- `tables_by_name`: Dictionary，键为表名 StringName，值为 Array[Dictionary] 或 Dictionary 表数据。
- `schemas_by_name`: Dictionary，键为表名 StringName，值为 GFConfigTableSchema。
- `return`: Dictionary，键为 reference_id，值为解析出的目标记录 Dictionary 副本。

## GFConfigRegexValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_regex_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigRegexValidationRule: 字符串正则校验规则。 用于检查字符串字段是否匹配给定表达式，可选择部分匹配或完整匹配。

### Properties

#### `pattern`

- API: `public`

```gdscript
var pattern: String = ""
```

正则表达式。

#### `require_full_match`

- API: `public`

```gdscript
var require_full_match: bool = false
```

是否要求整个字符串都匹配。

#### `allow_empty`

- API: `public`

```gdscript
var allow_empty: bool = true
```

空字符串是否直接视为通过。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段、pattern、require_full_match 和 allow_empty。

## GFConfigResourcePathValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_resource_path_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigResourcePathValidationRule: Godot 资源路径校验规则。 用于检查配置字段中的 `res://` 路径是否存在，并可按扩展名限制资源类型。

### Properties

#### `allow_empty`

- API: `public`

```gdscript
var allow_empty: bool = true
```

空字符串是否直接视为通过。

#### `require_resource_prefix`

- API: `public`

```gdscript
var require_resource_prefix: bool = true
```

是否要求路径以 res:// 开头。

#### `allowed_extensions`

- API: `public`

```gdscript
var allowed_extensions: PackedStringArray = PackedStringArray()
```

允许的扩展名。为空时不限制扩展名，可写 png 或 .png。

#### `use_resource_loader`

- API: `public`

```gdscript
var use_resource_loader: bool = true
```

是否使用 ResourceLoader.exists() 检查导入资源。

#### `use_file_access_fallback`

- API: `public`

```gdscript
var use_file_access_fallback: bool = true
```

ResourceLoader 检查失败时是否再用 FileAccess.file_exists() 检查原始文件。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段和资源路径校验设置。

## GFConfigSetValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_set_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigSetValidationRule: 值集合校验规则。 用于限制字段值必须出现在一个显式白名单中，不解释白名单背后的业务含义。

### Properties

#### `allowed_values`

- API: `public`

```gdscript
var allowed_values: Array = []
```

允许出现的值列表。

Schemas:

- `allowed_values`: Array，包含当前规则允许的 Variant 值。

#### `case_sensitive`

- API: `public`

```gdscript
var case_sensitive: bool = true
```

字符串比较是否区分大小写。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段、allowed_values 和 case_sensitive。

## GFConfigSizeValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_size_validation_rule.gd`
- Extends: `GFConfigValidationRule`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigSizeValidationRule: 长度或数量校验规则。 用于校验 String、Array、Dictionary、PackedArray 字段，或整表记录数量。

### Properties

#### `has_minimum_size`

- API: `public`

```gdscript
var has_minimum_size: bool = false
```

是否检查最小数量。

#### `minimum_size`

- API: `public`

```gdscript
var minimum_size: int = 0
```

最小数量。

#### `has_maximum_size`

- API: `public`

```gdscript
var has_maximum_size: bool = false
```

是否检查最大数量。

#### `maximum_size`

- API: `public`

```gdscript
var maximum_size: int = 0
```

最大数量。

### Methods

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含基础规则字段和数量边界设置。

## GFConfigTableColumn

- Path: `addons/gf/standard/utilities/config/gf_config_table_column.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigTableColumn: 导表字段声明。 只描述字段名、值类型、必填性、空值策略和默认值，不绑定任何具体业务表。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 不做类型约束。 ANY, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Vector2。 VECTOR2, ## Vector2i。 VECTOR2I, ## Color。 COLOR, ## Dictionary。 DICTIONARY, ## Array。 ARRAY, }
```

导表字段值类型，用于导入与运行时校验。

### Properties

#### `field_name`

- API: `public`

```gdscript
var field_name: StringName = &""
```

字段名。建议和导表列名保持一致。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.ANY
```

字段值类型。

#### `required`

- API: `public`

```gdscript
var required: bool = false
```

是否必须出现在记录中。

#### `allow_null`

- API: `public`

```gdscript
var allow_null: bool = true
```

是否允许 null 值。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

字段缺省值。`GFConfigTableSchema.coerce_record()` 会在缺字段时使用。

Schemas:

- `default_value`: Variant，字段缺失时复制到记录中的默认值。

#### `validation_rules`

- API: `public`

```gdscript
var validation_rules: Array[GFConfigValidationRule] = []
```

字段级校验规则。只作用于当前字段值，不绑定具体业务枚举。

Schemas:

- `validation_rules`: Array，包含作用于当前字段的 GFConfigValidationRule 资源。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供编辑器、导入器或项目层扩展使用。

Schemas:

- `metadata`: Dictionary，保存编辑器、导入器或项目层附加到当前字段的元数据。

### Methods

#### `get_field_key`

- API: `public`

```gdscript
func get_field_key() -> StringName:
```

获取稳定字段键。

Returns: 字段名。

#### `coerce_value`

- API: `public`

```gdscript
func coerce_value(value: Variant) -> Variant:
```

将输入值转换为当前列要求的类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 转换后的值。

Schemas:

- `value`: Variant，按 value_type 转换的输入字段值。
- `return`: Variant，按当前 value_type 转换后的值。

#### `try_coerce_value`

- API: `public`

```gdscript
func try_coerce_value(value: Variant) -> Dictionary:
```

尝试将输入值转换为当前列要求的类型，并返回转换报告。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 包含 ok、value 与 message 的转换报告。

Schemas:

- `value`: Variant，按 value_type 尝试转换的输入字段值。
- `return`: Dictionary，包含 ok、value 和 message 字段。

#### `is_value_valid`

- API: `public`

```gdscript
func is_value_valid(value: Variant) -> bool:
```

检查输入值是否符合当前列声明。

Parameters:

| Name | Description |
|---|---|
| `value` | 待检查值。 |

Returns: 符合声明时返回 true。

Schemas:

- `value`: Variant，按 value_type 与 allow_null 检查的字段值。

#### `duplicate_column`

- API: `public`

```gdscript
func duplicate_column() -> GFConfigTableColumn:
```

创建同内容拷贝，避免运行时修改污染共享 Resource。

Returns: 新字段声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出字段声明摘要。

Returns: 字段声明字典。

Schemas:

- `return`: Dictionary，包含 field_name、value_type、required、allow_null、default_value、validation_rules 和 metadata。

## GFConfigTableImporter

- Path: `addons/gf/standard/utilities/config/gf_config_table_importer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFConfigTableImporter: 通用导表文本解析与 schema 校验入口。 提供 JSON 与 CSV 的轻量解析，适合编辑器工具或 CI 在进入项目 Provider 前做结构检查。

### Methods

#### `parse_json_table`

- API: `public`

```gdscript
static func parse_json_table(text: String, options: Dictionary = {}) -> Dictionary:
```

解析 JSON 表文本。

Parameters:

| Name | Description |
|---|---|
| `text` | JSON 文本。 |
| `options` | 可选参数，支持 source。 |

Returns: 结果字典，包含 success、data、error、error_line 与 source。

Schemas:

- `options`: Dictionary，可包含 source。
- `return`: Dictionary，包含 success、data、error、error_line 和 source。

#### `parse_csv_table`

- API: `public`

```gdscript
static func parse_csv_table(text: String, options: Dictionary = {}) -> Dictionary:
```

解析 CSV 表文本。

Parameters:

| Name | Description |
|---|---|
| `text` | CSV 文本。 |
| `options` | 可选参数，支持 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers、source。 |

Returns: 结果字典，包含 success、data、row_locations 与 error。

Schemas:

- `options`: Dictionary，可包含 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers 和 source。
- `return`: Dictionary，包含 success、data、row_locations、error、error_line、error_column 和 source。

#### `validate_json_table`

- API: `public`

```gdscript
static func validate_json_table(text: String, schema: GFConfigTableSchema, options: Dictionary = {}) -> Dictionary:
```

解析并校验 JSON 表文本。

Parameters:

| Name | Description |
|---|---|
| `text` | JSON 文本。 |
| `schema` | 表结构声明。 |
| `options` | 可选参数，支持 source。 |

Returns: 校验报告；解析失败时返回失败报告。

Schemas:

- `options`: Dictionary，可包含 source。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_csv_table`

- API: `public`

```gdscript
static func validate_csv_table(text: String, schema: GFConfigTableSchema, options: Dictionary = {}) -> Dictionary:
```

解析并校验 CSV 表文本。

Parameters:

| Name | Description |
|---|---|
| `text` | CSV 文本。 |
| `schema` | 表结构声明。 |
| `options` | 可选参数，支持 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers、source。 |

Returns: 校验报告；解析失败时返回失败报告。

Schemas:

- `options`: Dictionary，可包含 delimiter、trim_cells、skip_empty_lines、reject_duplicate_headers 和 source。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `export_csv_table`

- API: `public`

```gdscript
static func export_csv_table( table_data: Variant, schema: GFConfigTableSchema = null, options: Dictionary = {} ) -> Dictionary:
```

导出 CSV 表文本。

Parameters:

| Name | Description |
|---|---|
| `table_data` | Array[Dictionary] 或 Dictionary 形式的表数据。 |
| `schema` | 可选 schema；提供时默认按 schema.columns 排列列。 |
| `options` | 可选参数，支持 delimiter、columns、include_header、coerce_values。 |

Returns: 结果字典，包含 success、text 与 error。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `options`: Dictionary，可包含 delimiter、columns、include_header 和 coerce_values。
- `return`: Dictionary，包含 success、text 和 error。

## GFConfigTableIndexDefinition

- Path: `addons/gf/standard/utilities/config/gf_config_table_index_definition.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigTableIndexDefinition: 导表索引声明。 描述一组字段如何组成查询键或唯一键，不绑定任何具体业务表。

### Properties

#### `index_id`

- API: `public`

```gdscript
var index_id: StringName = &""
```

索引稳定标识。为空时会根据字段名生成。

#### `field_names`

- API: `public`

```gdscript
var field_names: PackedStringArray = PackedStringArray()
```

参与索引的字段名，顺序会影响复合键。

#### `unique`

- API: `public`

```gdscript
var unique: bool = false
```

为 true 时校验表数据中该复合键唯一。

#### `allow_null_values`

- API: `public`

```gdscript
var allow_null_values: bool = true
```

是否允许索引键中出现 null 值。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供导入器、编辑器或项目层扩展使用。

Schemas:

- `metadata`: Dictionary，保存导入器、编辑器或项目层附加到当前索引的元数据。

### Methods

#### `get_index_id`

- API: `public`

```gdscript
func get_index_id() -> StringName:
```

获取稳定索引标识。

Returns: 索引标识。

#### `is_valid_definition`

- API: `public`

```gdscript
func is_valid_definition() -> bool:
```

检查索引声明是否有效。

Returns: 有效返回 true。

#### `make_key`

- API: `public`

```gdscript
func make_key(record: Dictionary) -> String:
```

根据记录构建索引键。

Parameters:

| Name | Description |
|---|---|
| `record` | 记录数据。 |

Returns: 索引键；字段缺失或 null 不允许时返回空字符串。

Schemas:

- `record`: Dictionary，用于构建索引键的配置记录。

#### `duplicate_index`

- API: `public`

```gdscript
func duplicate_index() -> GFConfigTableIndexDefinition:
```

创建同内容拷贝。

Returns: 新索引声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出索引声明摘要。

Returns: 索引声明字典。

Schemas:

- `return`: Dictionary，包含 index_id、field_names、unique、allow_null_values 和 metadata。

## GFConfigTableMergePolicy

- Path: `addons/gf/standard/utilities/config/gf_config_table_merge_policy.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigTableMergePolicy: 配置表补丁合并策略。 描述如何识别记录、覆盖记录和处理删除标记。它只定义通用合并规则， 不绑定热更、模组、DLC 或任意项目业务语义。

### Enums

#### `UpdateMode`

- API: `public`

```gdscript
enum UpdateMode { ## patch 记录整体替换 base 记录。 REPLACE_RECORD, ## patch 记录与 base 记录按字段合并，嵌套 Dictionary 递归合并。 MERGE_FIELDS, }
```

记录更新方式。

### Properties

#### `key_fields`

- API: `public`

```gdscript
var key_fields: PackedStringArray = PackedStringArray(["id"])
```

用于生成记录键的字段。为空时 Dictionary 表会优先使用外层 key。

#### `update_mode`

- API: `public`

```gdscript
var update_mode: UpdateMode = UpdateMode.MERGE_FIELDS
```

更新已有记录时采用的合并方式。

#### `allow_insert`

- API: `public`

```gdscript
var allow_insert: bool = true
```

是否允许 patch 插入新记录。

#### `allow_update`

- API: `public`

```gdscript
var allow_update: bool = true
```

是否允许 patch 更新已有记录。

#### `allow_delete`

- API: `public`

```gdscript
var allow_delete: bool = true
```

是否允许 patch 删除已有记录。

#### `delete_marker_field`

- API: `public`

```gdscript
var delete_marker_field: StringName = &"_delete"
```

删除标记字段。为空时不启用删除标记。

#### `delete_marker_value`

- API: `public`

```gdscript
var delete_marker_value: Variant = true
```

删除标记需要匹配的值。

Schemas:

- `delete_marker_value`: Variant，与删除标记字段比较的目标值。

#### `preserve_base_order`

- API: `public`

```gdscript
var preserve_base_order: bool = true
```

Array 表输出时是否保留 base 原有顺序，并把新增记录追加到末尾。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目工具扩展使用。

Schemas:

- `metadata`: Dictionary，保存项目层附加到当前合并策略的元数据。

### Methods

#### `is_delete_record`

- API: `public`

```gdscript
func is_delete_record(record: Dictionary) -> bool:
```

检查记录是否带有删除标记。

Parameters:

| Name | Description |
|---|---|
| `record` | 记录。 |

Returns: 带有删除标记时返回 true。

Schemas:

- `record`: Dictionary，用于检查删除标记字段的配置记录。

#### `make_record_key`

- API: `public`

```gdscript
func make_record_key(record: Dictionary, outer_key: Variant = null) -> String:
```

根据记录生成稳定合并键。

Parameters:

| Name | Description |
|---|---|
| `record` | 记录。 |
| `outer_key` | Dictionary 表外层 key。 |

Returns: 合并键，字段缺失时返回空字符串。

Schemas:

- `record`: Dictionary，用于构建合并键的配置记录。
- `outer_key`: Variant，key_fields 为空时用于构建合并键的外层 key。

#### `merge_record`

- API: `public`

```gdscript
func merge_record(base_record: Dictionary, patch_record: Dictionary) -> Dictionary:
```

合并两条记录。

Parameters:

| Name | Description |
|---|---|
| `base_record` | 原始记录。 |
| `patch_record` | 补丁记录。 |

Returns: 合并后的记录。

Schemas:

- `base_record`: Dictionary，原始记录。
- `patch_record`: Dictionary，补丁记录。
- `return`: Dictionary，合并后的记录。

#### `duplicate_policy`

- API: `public`

```gdscript
func duplicate_policy() -> GFConfigTableMergePolicy:
```

创建同内容拷贝。

Returns: 新合并策略。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出策略摘要。

Returns: 策略摘要字典。

Schemas:

- `return`: Dictionary，包含 key_fields、update_mode、权限开关、删除标记设置、preserve_base_order 和 metadata。

## GFConfigTableMergeTools

- Path: `addons/gf/standard/utilities/config/gf_config_table_merge_tools.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFConfigTableMergeTools: 配置表补丁合并工具。 提供 Array[Dictionary] 与 Dictionary 表的通用补丁合并，适合导表后处理、 编辑器工具或项目自己的配置包流程使用。

### Methods

#### `merge_tables`

- API: `public`

```gdscript
static func merge_tables( base_table: Variant, patch_table: Variant, policy: GFConfigTableMergePolicy = null ) -> Dictionary:
```

合并 base 表与 patch 表。

Parameters:

| Name | Description |
|---|---|
| `base_table` | Array[Dictionary] 或 Dictionary 形式的基础表。 |
| `patch_table` | Array[Dictionary] 或 Dictionary 形式的补丁表。 |
| `policy` | 可选合并策略；为空时使用默认策略。 |

Returns: 结果字典，包含 ok、data、issues 与统计信息。

Schemas:

- `base_table`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `patch_table`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `return`: GFConfigValidationReport 兼容 Dictionary，额外包含 data、dictionary_output、base_count、inserted_count、updated_count 和 deleted_count。

## GFConfigTableReference

- Path: `addons/gf/standard/utilities/config/gf_config_table_reference.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigTableReference: 导表跨表引用声明。 描述当前记录的一组字段如何指向另一张表的一组字段。

### Properties

#### `reference_id`

- API: `public`

```gdscript
var reference_id: StringName = &""
```

引用稳定标识。为空时会根据来源字段和目标表生成。

#### `source_fields`

- API: `public`

```gdscript
var source_fields: PackedStringArray = PackedStringArray()
```

当前表中参与引用的字段名。

#### `target_table_name`

- API: `public`

```gdscript
var target_table_name: StringName = &""
```

目标表名。

#### `target_fields`

- API: `public`

```gdscript
var target_fields: PackedStringArray = PackedStringArray()
```

目标表中参与匹配的字段名。为空时由目标 schema 的 id_field 补齐。

#### `required`

- API: `public`

```gdscript
var required: bool = true
```

为 true 时，非空引用必须能在目标表中找到。

#### `allow_null_values`

- API: `public`

```gdscript
var allow_null_values: bool = true
```

是否允许来源字段值为 null。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供导入器、编辑器或项目层扩展使用。

Schemas:

- `metadata`: Dictionary，保存导入器、编辑器或项目层附加到当前引用的元数据。

### Methods

#### `get_reference_id`

- API: `public`

```gdscript
func get_reference_id() -> StringName:
```

获取稳定引用标识。

Returns: 引用标识。

#### `is_valid_definition`

- API: `public`

```gdscript
func is_valid_definition() -> bool:
```

检查引用声明是否有效。

Returns: 有效返回 true。

#### `get_target_fields`

- API: `public`

```gdscript
func get_target_fields(target_schema: GFConfigTableSchema = null) -> PackedStringArray:
```

获取目标字段名。

Parameters:

| Name | Description |
|---|---|
| `target_schema` | 可选目标 schema。 |

Returns: 目标字段列表。

#### `make_source_key`

- API: `public`

```gdscript
func make_source_key(record: Dictionary) -> String:
```

根据来源记录构建引用键。

Parameters:

| Name | Description |
|---|---|
| `record` | 来源记录。 |

Returns: 引用键；字段缺失或 null 不允许时返回空字符串。

Schemas:

- `record`: Dictionary，用于构建引用键的来源配置记录。

#### `make_target_key`

- API: `public`

```gdscript
func make_target_key(record: Dictionary, target_schema: GFConfigTableSchema = null) -> String:
```

根据目标记录构建引用键。

Parameters:

| Name | Description |
|---|---|
| `record` | 目标记录。 |
| `target_schema` | 可选目标 schema。 |

Returns: 引用键；字段缺失或 null 不允许时返回空字符串。

Schemas:

- `record`: Dictionary，用于构建引用键的目标配置记录。

#### `duplicate_reference`

- API: `public`

```gdscript
func duplicate_reference() -> GFConfigTableReference:
```

创建同内容拷贝。

Returns: 新引用声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出引用声明摘要。

Returns: 引用声明字典。

Schemas:

- `return`: Dictionary，包含 reference_id、source_fields、target_table_name、target_fields、required、allow_null_values 和 metadata。

## GFConfigTableSchema

- Path: `addons/gf/standard/utilities/config/gf_config_table_schema.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConfigTableSchema: 通用导表结构声明与校验器。 用于在导入期或运行时校验表数据结构，保持数据工具链可替换且不绑定业务表。

### Properties

#### `table_name`

- API: `public`

```gdscript
var table_name: StringName = &""
```

表名。为空时可由调用方自行决定表标识。

#### `id_field`

- API: `public`

```gdscript
var id_field: StringName = &"id"
```

记录 ID 字段。为空时不检查记录 ID。

#### `columns`

- API: `public`

```gdscript
var columns: Array[GFConfigTableColumn] = []
```

字段声明列表。

Schemas:

- `columns`: Array[GFConfigTableColumn]，定义当前表允许的字段和字段级校验规则。

#### `allow_extra_fields`

- API: `public`

```gdscript
var allow_extra_fields: bool = true
```

是否允许记录包含 schema 未声明的字段。

#### `coerce_values`

- API: `public`

```gdscript
var coerce_values: bool = false
```

是否在校验前按字段声明尝试类型转换。

#### `fail_on_coerce_error`

- API: `public`

```gdscript
var fail_on_coerce_error: bool = true
```

启用 coerce_values 时，转换失败是否作为校验错误。

#### `require_unique_id`

- API: `public`

```gdscript
var require_unique_id: bool = false
```

校验整表时是否要求 id_field 唯一。

#### `indexes`

- API: `public`

```gdscript
var indexes: Array[GFConfigTableIndexDefinition] = []
```

可选复合索引声明。唯一索引会参与表级校验。

Schemas:

- `indexes`: Array[GFConfigTableIndexDefinition]，定义当前表的复合索引和唯一性约束。

#### `references`

- API: `public`

```gdscript
var references: Array[GFConfigTableReference] = []
```

可选跨表引用声明。引用目标由 `GFConfigReferenceResolver` 在多表上下文中校验。

Schemas:

- `references`: Array[GFConfigTableReference]，定义当前表到其他表的引用关系。

#### `record_validation_rules`

- API: `public`

```gdscript
var record_validation_rules: Array[GFConfigValidationRule] = []
```

可选记录级校验规则。规则会在字段结构校验后作用于整条记录。

Schemas:

- `record_validation_rules`: Array[GFConfigValidationRule]，包含作用于单条记录的校验规则。

#### `table_validation_rules`

- API: `public`

```gdscript
var table_validation_rules: Array[GFConfigValidationRule] = []
```

可选表级校验规则。规则会在行结构、唯一 ID 和索引校验后作用于整表。

Schemas:

- `table_validation_rules`: Array[GFConfigValidationRule]，包含作用于整张表的校验规则。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供导入器、编辑器或项目层扩展使用。

Schemas:

- `metadata`: Dictionary，保存导入器、编辑器或项目层附加到当前 schema 的元数据。

### Methods

#### `infer_from_records`

- API: `public`

```gdscript
static func infer_from_records( inferred_table_name: StringName, table_data: Variant, options: Dictionary = {} ) -> GFConfigTableSchema:
```

从记录样本推导通用 schema。

Parameters:

| Name | Description |
|---|---|
| `inferred_table_name` | 推导出的表名。 |
| `table_data` | Array[Dictionary] 或 Dictionary 形式的表数据。 |
| `options` | 可选参数，支持 id_field、required_if_present_in_all_rows、allow_extra_fields、coerce_values。 |

Returns: 推导出的 schema；数据无效时返回空 schema。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `options`: Dictionary，可包含 id_field、required_if_present_in_all_rows、allow_extra_fields 和 coerce_values。

#### `get_table_key`

- API: `public`

```gdscript
func get_table_key() -> StringName:
```

获取稳定表键。

Returns: 表名。

#### `get_column`

- API: `public`

```gdscript
func get_column(field_name: StringName) -> GFConfigTableColumn:
```

获取字段声明。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |

Returns: 找到时返回字段声明，否则返回 null。

#### `has_column`

- API: `public`

```gdscript
func has_column(field_name: StringName) -> bool:
```

检查字段声明是否存在。

Parameters:

| Name | Description |
|---|---|
| `field_name` | 字段名。 |

Returns: 存在返回 true。

#### `get_index`

- API: `public`

```gdscript
func get_index(index_id: StringName) -> GFConfigTableIndexDefinition:
```

获取索引声明。

Parameters:

| Name | Description |
|---|---|
| `index_id` | 索引标识。 |

Returns: 找到时返回索引声明，否则返回 null。

#### `has_index`

- API: `public`

```gdscript
func has_index(index_id: StringName) -> bool:
```

检查索引声明是否存在。

Parameters:

| Name | Description |
|---|---|
| `index_id` | 索引标识。 |

Returns: 存在返回 true。

#### `get_reference`

- API: `public`

```gdscript
func get_reference(reference_id: StringName) -> GFConfigTableReference:
```

获取引用声明。

Parameters:

| Name | Description |
|---|---|
| `reference_id` | 引用标识。 |

Returns: 找到时返回引用声明，否则返回 null。

#### `has_reference`

- API: `public`

```gdscript
func has_reference(reference_id: StringName) -> bool:
```

检查引用声明是否存在。

Parameters:

| Name | Description |
|---|---|
| `reference_id` | 引用标识。 |

Returns: 存在返回 true。

#### `get_column_names`

- API: `public`

```gdscript
func get_column_names() -> PackedStringArray:
```

获取当前 schema 的字段名列表。

Returns: 字段名列表。

#### `validate_definition`

- API: `public`

```gdscript
func validate_definition(options: Dictionary = {}) -> Dictionary:
```

校验 schema 自身声明是否完整、一致。

Parameters:

| Name | Description |
|---|---|
| `options` | 可选上下文，支持 source。 |

Returns: 校验报告字典。

Schemas:

- `options`: Dictionary，可包含 source、line、column、row_index、column_index 和 row_locations。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_record`

- API: `public`

```gdscript
func validate_record(record: Dictionary, row_key: Variant = null, options: Dictionary = {}) -> Dictionary:
```

校验单条记录。

Parameters:

| Name | Description |
|---|---|
| `record` | 记录字典。 |
| `row_key` | 可选行标识，用于错误报告。 |
| `options` | 可选上下文，支持 source、line、row_index、row_locations。 |

Returns: 校验报告字典。

Schemas:

- `record`: Dictionary，待校验的配置记录，键为字段名，值为字段数据。
- `row_key`: Variant，写入校验报告 issue 的行标识。
- `options`: Dictionary，可包含 source、line、column、row_index、column_index 和 row_locations。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_table`

- API: `public`

```gdscript
func validate_table(table_data: Variant, options: Dictionary = {}) -> Dictionary:
```

校验整张表。

Parameters:

| Name | Description |
|---|---|
| `table_data` | Array[Dictionary] 或 Dictionary 形式的表数据。 |
| `options` | 可选上下文，支持 source、row_locations。 |

Returns: 校验报告字典。

Schemas:

- `table_data`: Variant，支持 Array[Dictionary] 或 Dictionary，记录值必须为 Dictionary。
- `options`: Dictionary，可包含 source、line、column、row_index、column_index 和 row_locations。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `coerce_record`

- API: `public`

```gdscript
func coerce_record(record: Dictionary) -> Dictionary:
```

按字段声明转换单条记录。

Parameters:

| Name | Description |
|---|---|
| `record` | 输入记录。 |

Returns: 转换后的新记录。

Schemas:

- `record`: Dictionary，待转换的配置记录，键为字段名，值为字段数据。
- `return`: Dictionary，转换后的记录副本。

#### `build_empty_record`

- API: `public`

```gdscript
func build_empty_record(include_optional: bool = true) -> Dictionary:
```

创建空记录模板。

Parameters:

| Name | Description |
|---|---|
| `include_optional` | 为 true 时包含非必填字段。 |

Returns: 新记录字典。

Schemas:

- `return`: Dictionary，键为字段名，值为字段默认值转换后的结果。

#### `duplicate_schema`

- API: `public`

```gdscript
func duplicate_schema() -> GFConfigTableSchema:
```

创建同内容拷贝，避免运行时修改污染共享 Resource。

Returns: 新 schema。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出 schema 摘要。

Returns: schema 字典。

Schemas:

- `return`: Dictionary，包含 table_name、id_field、columns、allow_extra_fields、coerce_values、fail_on_coerce_error、require_unique_id、indexes、references、record_validation_rules、table_validation_rules 和 metadata。

## GFConfigValidationReport

- Path: `addons/gf/standard/utilities/config/gf_config_validation_report.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFConfigValidationReport: 配置表校验报告构建工具。 统一创建、合并和补全配置表校验报告，保证 schema、导入器、引用解析和补丁合并使用相同问题结构。

### Constants

#### `CONTEXT_FIELDS`

- API: `public`

```gdscript
const CONTEXT_FIELDS: Array[String] = [
```

从校验上下文复制到单条 issue 的字段名。

### Methods

#### `make_report`

- API: `public`

```gdscript
func make_report(table_name: StringName = &"", row_count: int = 0) -> Dictionary:
```

创建空校验报告。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |
| `row_count` | 记录数量。 |

Returns: 校验报告字典。

Schemas:

- `return`: GFConfigValidationReport 兼容 Dictionary，包含 ok、table_name、row_count、error_count、warning_count 和 issues。

#### `make_error_report`

- API: `public`

```gdscript
func make_error_report( table_name: StringName, kind: String, message: String, context: Dictionary = {} ) -> Dictionary:
```

创建单错误校验报告。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 表名。 |
| `kind` | 稳定问题类型。 |
| `message` | 问题描述。 |
| `context` | 可选上下文。 |

Returns: 校验报告字典。

Schemas:

- `context`: Dictionary，可包含 row_key、field、source、line、column、row_index、column_index 和 rule_id 字段。
- `return`: GFConfigValidationReport 兼容 Dictionary，包含一条 error issue。

#### `add_issue`

- API: `public`

```gdscript
func add_issue( report: Dictionary, severity: String, kind: String, table_name: StringName, row_key: Variant, field_name: StringName, message: String, context: Dictionary = {} ) -> void:
```

向报告写入一条问题。

Parameters:

| Name | Description |
|---|---|
| `report` | 目标校验报告。 |
| `severity` | severity 字符串，支持 error 或 warning。 |
| `kind` | 稳定问题类型。 |
| `table_name` | 表名。 |
| `row_key` | 行标识。 |
| `field_name` | 字段名。 |
| `message` | 问题描述。 |
| `context` | 可选上下文。 |

Schemas:

- `report`: GFConfigValidationReport 兼容 Dictionary，会被当前方法修改。
- `row_key`: Variant，复制到 issue 中的行标识。
- `context`: Dictionary，可包含 source、line、column、row_index、column_index 和 rule_id 字段。

#### `merge_report`

- API: `public`

```gdscript
func merge_report(target: Dictionary, source: Dictionary, include_row_count: bool = false) -> void:
```

合并一份校验报告。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标报告。 |
| `source` | 来源报告。 |
| `include_row_count` | 为 true 时累加 row_count。 |

Schemas:

- `target`: GFConfigValidationReport 兼容 Dictionary，会被当前方法修改。
- `source`: GFConfigValidationReport 兼容 Dictionary，会复制合并到 target。

#### `finalize_report`

- API: `public`

```gdscript
func finalize_report(report: Dictionary) -> void:
```

根据 error_count 补全 ok 字段。

Parameters:

| Name | Description |
|---|---|
| `report` | 校验报告。 |

Schemas:

- `report`: GFConfigValidationReport 兼容 Dictionary，会被当前方法修改。

## GFConfigValidationRule

- Path: `addons/gf/standard/utilities/config/validation/gf_config_validation_rule.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFConfigValidationRule: 导表校验规则基类。 用于把字段、记录或整表校验拆成可组合 Resource，便于项目按需声明范围、 正则、资源路径或本地化 key 等规则，而不把业务表结构写进框架。

### Enums

#### `IssueSeverity`

- API: `public`

```gdscript
enum IssueSeverity { ## 警告，不阻止报告通过。 WARNING, ## 错误，会让报告失败。 ERROR, }
```

校验问题严重级别。

### Properties

#### `rule_id`

- API: `public`

```gdscript
var rule_id: StringName = &""
```

规则稳定标识。为空时使用规则类型默认标识。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用当前规则。

#### `severity`

- API: `public`

```gdscript
var severity: IssueSeverity = IssueSeverity.ERROR
```

规则触发时写入报告的严重级别。

#### `allow_null`

- API: `public`

```gdscript
var allow_null: bool = true
```

值为 null 时是否直接跳过值校验。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供编辑器或项目工具扩展使用。

Schemas:

- `metadata`: Dictionary，保存编辑器或项目层附加到当前规则的元数据。

### Methods

#### `get_rule_id`

- API: `public`

```gdscript
func get_rule_id() -> StringName:
```

获取稳定规则标识。

Returns: 规则标识。

#### `validate_value`

- API: `public`

```gdscript
func validate_value(value: Variant, context: Dictionary = {}) -> Dictionary:
```

校验单个字段值。

Parameters:

| Name | Description |
|---|---|
| `value` | 待校验值。 |
| `context` | 可选上下文，支持 table_name、row_key、field、source、line、column。 |

Returns: 校验报告字典。

Schemas:

- `value`: Variant，来自配置表或项目导入器的字段值。
- `context`: Dictionary，可包含 table_name、row_key、field、source、line 和 column 字段。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_record`

- API: `public`

```gdscript
func validate_record(record: Dictionary, context: Dictionary = {}) -> Dictionary:
```

校验单条记录。

Parameters:

| Name | Description |
|---|---|
| `record` | 待校验记录。 |
| `context` | 可选上下文，支持 table_name、row_key、source、line。 |

Returns: 校验报告字典。

Schemas:

- `record`: Dictionary，正在校验的配置记录。
- `context`: Dictionary，可包含 table_name、row_key、source 和 line 字段。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `validate_table`

- API: `public`

```gdscript
func validate_table(rows: Array[Dictionary], context: Dictionary = {}) -> Dictionary:
```

校验整张表。

Parameters:

| Name | Description |
|---|---|
| `rows` | 规范化行列表，每项通常包含 row_key、record 和 row_index。 |
| `context` | 可选上下文，支持 table_name、source。 |

Returns: 校验报告字典。

Schemas:

- `rows`: Array[Dictionary]，元素通常包含 row_key、record 和 row_index。
- `context`: Dictionary，可包含 table_name 和 source 字段。
- `return`: GFConfigValidationReport 兼容 Dictionary。

#### `duplicate_rule`

- API: `public`

```gdscript
func duplicate_rule() -> GFConfigValidationRule:
```

创建同内容拷贝。

Returns: 新规则。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出规则摘要。

Returns: 规则摘要字典。

Schemas:

- `return`: Dictionary，包含 rule_id、enabled、severity、allow_null、metadata 和 script_path。

## GFConsoleCommandDefinition

- Path: `addons/gf/standard/utilities/debug/gf_console_command_definition.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFConsoleCommandDefinition: 控制台命令资源定义。 只保存命令名称、别名、描述和元数据，执行逻辑仍由注册时传入的 Callable 提供。

### Properties

#### `command_name`

- API: `public`

```gdscript
var command_name: String = ""
```

主命令名。

#### `aliases`

- API: `public`

```gdscript
var aliases: PackedStringArray = PackedStringArray()
```

命令别名。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

命令描述。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，保存项目自定义命令元数据。

### Methods

#### `get_all_names`

- API: `public`

```gdscript
func get_all_names() -> PackedStringArray:
```

获取所有命令名。

Returns: 主命令和别名。

## GFConsoleUtility

- Path: `addons/gf/standard/utilities/debug/gf_console_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFConsoleUtility: 运行时开发者控制台。 提供命令注册、解析与执行能力，并在初始化时构建覆盖全屏的调试 GUI。 默认通过快捷键呼出，同时会消费 `GFLogUtility` 的日志信号进行彩色输出。

### Enums

#### `CommandTier`

- API: `public`

```gdscript
enum CommandTier { ## 只读观察类命令。 OBSERVE, ## 会改变运行时状态的控制类命令。 CONTROL, ## 删档、跳关、重连等高风险命令。 DANGER, }
```

控制台命令风险等级。

### Constants

#### `DANGER_CONFIRMATION_ARGUMENT`

- API: `public`

```gdscript
const DANGER_CONFIRMATION_ARGUMENT: String = "--confirm"
```

DANGER 命令的确认参数。

### Properties

#### `toggle_key`

- API: `public`

```gdscript
var toggle_key: Key = KEY_F1
```

呼出或隐藏控制台的快捷键；默认为 `KEY_F1`。

#### `max_output_lines`

- API: `public`

```gdscript
var max_output_lines: int = 1000:
```

控制台最多保留的输出行数，避免高频日志无限增长。

#### `max_history_size`

- API: `public`

```gdscript
var max_history_size: int = 100:
```

控制台最多保留的历史命令数量。

#### `background_alpha`

- API: `public`

```gdscript
var background_alpha: float = 0.85:
```

控制台背景透明度，范围 0 到 1。

#### `windowed`

- API: `public`

```gdscript
var windowed: bool = false:
```

是否使用可拖拽、可缩放的窗口模式。默认 false 保持全屏覆盖。

#### `initial_window_size_ratio`

- API: `public`

```gdscript
var initial_window_size_ratio: Vector2 = Vector2(0.72, 0.55):
```

窗口模式初始尺寸相对视口比例。

#### `minimum_window_size`

- API: `public`

```gdscript
var minimum_window_size: Vector2 = Vector2(360.0, 220.0):
```

窗口模式最小尺寸。

#### `keep_topmost`

- API: `public`

```gdscript
var keep_topmost: bool = true:
```

是否把控制台放在较高 CanvasLayer 层级。

#### `debug_only`

- API: `public`

```gdscript
var debug_only: bool = true
```

是否只在 debug 构建中创建控制台 GUI。发布构建需要显式关闭此项才会创建控制台。

#### `max_command_tier`

- API: `public`

```gdscript
var max_command_tier: CommandTier = CommandTier.CONTROL
```

允许执行的最高命令风险等级。

#### `require_danger_confirmation`

- API: `public`

```gdscript
var require_danger_confirmation: bool = true
```

执行 DANGER 命令时是否要求传入 `--confirm` 参数。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化控制台命令表和运行时 GUI。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

连接日志工具信号。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放 GUI 并断开日志信号。

#### `register_command`

- API: `public`

```gdscript
func register_command(cmd_name: String, callback: Callable, description: String, metadata: Dictionary = {}) -> void:
```

注册控制台命令。

Parameters:

| Name | Description |
|---|---|
| `cmd_name` | 指令名称。 |
| `callback` | 指令回调，签名为 `func(args: PackedStringArray) -> void`。 |
| `description` | 指令说明文本。 |
| `metadata` | 项目自定义元数据。 |

Schemas:

- `metadata`: Dictionary，支持 tier 等项目自定义命令元数据。

#### `register_command_definition`

- API: `public`

```gdscript
func register_command_definition(definition: GFConsoleCommandDefinition, callback: Callable) -> void:
```

注册资源化控制台命令。

Parameters:

| Name | Description |
|---|---|
| `definition` | 命令资源定义。 |
| `callback` | 指令回调，签名为 `func(args: PackedStringArray) -> void`。 |

#### `unregister_command`

- API: `public`

```gdscript
func unregister_command(cmd_name: String) -> void:
```

注销控制台命令。

Parameters:

| Name | Description |
|---|---|
| `cmd_name` | 指令名称。 |

#### `has_command`

- API: `public`

```gdscript
func has_command(cmd_name: String) -> bool:
```

检查控制台命令是否已注册。

Parameters:

| Name | Description |
|---|---|
| `cmd_name` | 指令名称。 |

Returns: 已注册返回 true。

#### `get_command_names`

- API: `public`

```gdscript
func get_command_names() -> PackedStringArray:
```

获取当前已注册命令名称。

Returns: 排序后的命令名称数组。

#### `get_command_catalog`

- API: `public`

```gdscript
func get_command_catalog() -> Dictionary:
```

获取控制台命令目录。

Returns: 命令元数据字典。

Schemas:

- `return`: Dictionary[String, Dictionary]，每个值包含 description、metadata 和 tier。

#### `suggest_commands`

- API: `public`

```gdscript
func suggest_commands(prefix: String) -> PackedStringArray:
```

根据前缀获取命令补全候选。

Parameters:

| Name | Description |
|---|---|
| `prefix` | 命令名前缀。 |

Returns: 排序后的候选命令名数组。

#### `suggest_similar_commands`

- API: `public`

```gdscript
func suggest_similar_commands(cmd_name: String, limit: int = 3, threshold: float = 0.5) -> PackedStringArray:
```

根据字符串相似度获取可能的命令名，用于未知命令诊断。

Parameters:

| Name | Description |
|---|---|
| `cmd_name` | 用户输入的命令名。 |
| `limit` | 最多返回的候选数量。 |
| `threshold` | 最低相似度，范围 0 到 1。 |

Returns: 按相似度降序排列的候选命令名。

#### `execute_command`

- API: `public`

```gdscript
func execute_command(raw_input: String) -> bool:
```

解析并执行一条原始输入。

Parameters:

| Name | Description |
|---|---|
| `raw_input` | 用户输入的完整字符串。 |

Returns: 找到并成功执行命令时返回 `true`。

#### `append_output_line`

- API: `public`

```gdscript
func append_output_line(bbcode_line: String) -> void:
```

向控制台输出追加一行 BBCode 文本。

Parameters:

| Name | Description |
|---|---|
| `bbcode_line` | 要追加的一行 BBCode 文本。 |

#### `append_output_lines`

- API: `public`

```gdscript
func append_output_lines(bbcode_lines: PackedStringArray) -> void:
```

向控制台输出追加多行 BBCode 文本。

Parameters:

| Name | Description |
|---|---|
| `bbcode_lines` | 要追加的 BBCode 文本行列表。 |

#### `clear_output`

- API: `public`

```gdscript
func clear_output() -> void:
```

清空控制台输出。

#### `flush_output`

- API: `public`

```gdscript
func flush_output() -> void:
```

立即刷新待追加的控制台输出。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取控制台调试快照。

Returns: 控制台命令、GUI 和配置状态。

Schemas:

- `return`: Dictionary，包含 command_count、command_names、command_catalog、has_console_gui、gui、配置字段。

## GFControlValueAdapter

- Path: `addons/gf/standard/utilities/ui/gf_control_value_adapter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFControlValueAdapter: 常见 Control 节点的值读写适配器。 用于表单、设置页和编辑工具中统一读写控件值，不持有状态。

### Methods

#### `get_value`

- API: `public`

```gdscript
static func get_value(control: Control, fallback: Variant = null) -> Variant:
```

从控件读取值。

Parameters:

| Name | Description |
|---|---|
| `control` | 控件节点。 |
| `fallback` | 不支持读取时返回的值。 |

Returns: 控件值。

Schemas:

- `fallback`: Variant，控件无效或不支持读取时返回的回退值。
- `return`: Variant，控件当前值；无法读取时返回 fallback。

#### `set_value`

- API: `public`

```gdscript
static func set_value(control: Control, value: Variant) -> bool:
```

向控件写入值。

Parameters:

| Name | Description |
|---|---|
| `control` | 控件节点。 |
| `value` | 值。 |

Returns: 成功写入时返回 true。

Schemas:

- `value`: Variant，要写入控件的值，具体类型取决于控件类型。

#### `connect_value_changed`

- API: `public`

```gdscript
static func connect_value_changed(control: Control, callback: Callable) -> bool:
```

连接控件值变化信号。

Parameters:

| Name | Description |
|---|---|
| `control` | 控件节点。 |
| `callback` | 值变化后调用的回调，不接收参数。 |

Returns: 成功连接时返回 true。

#### `connect_value_changed_with_handles`

- API: `public`

```gdscript
static func connect_value_changed_with_handles(control: Control, callback: Callable) -> Array[Dictionary]:
```

连接控件值变化信号并返回可断开的连接句柄。

Parameters:

| Name | Description |
|---|---|
| `control` | 控件节点。 |
| `callback` | 值变化后调用的回调，不接收参数。 |

Returns: 连接句柄数组，可传给 disconnect_value_changed_handles()。

Schemas:

- `return`: Array[Dictionary]，每个条目包含 control_ref、signal_name 和 callable。

#### `disconnect_value_changed_handles`

- API: `public`

```gdscript
static func disconnect_value_changed_handles(connections: Array) -> void:
```

断开 connect_value_changed_with_handles() 返回的连接句柄。

Parameters:

| Name | Description |
|---|---|
| `connections` | 连接句柄数组。 |

Schemas:

- `connections`: Array，包含 connect_value_changed_with_handles() 返回的连接句柄 Dictionary。

## GFCurve2DMath

- Path: `addons/gf/standard/foundation/math/gf_curve_2d_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.19.0`

GFCurve2DMath: Curve2D 与折线的纯算法辅助。 提供路径长度、归一化采样、点距简化和基础闭合形状生成，不持有节点状态， 也不解释碰撞、渲染或编辑器交互语义。

### Constants

#### `CIRCLE_BEZIER_KAPPA`

- API: `public`

```gdscript
const CIRCLE_BEZIER_KAPPA: float = 0.5522847498307936
```

圆弧贝塞尔控制点近似系数。

### Methods

#### `get_polyline_length`

- API: `public`

```gdscript
static func get_polyline_length(points: PackedVector2Array) -> float:
```

计算折线总长度。

Parameters:

| Name | Description |
|---|---|
| `points` | 折线点序列。 |

Returns: 折线长度；少于两个点时返回 0。

#### `sample_polyline`

- API: `public`

```gdscript
static func sample_polyline( points: PackedVector2Array, ratio: float, total_length: float = -1.0 ) -> Vector2:
```

按 0 到 1 的比例采样折线。

Parameters:

| Name | Description |
|---|---|
| `points` | 折线点序列。 |
| `ratio` | 归一化采样位置；会被限制在 0 到 1。 |
| `total_length` | 可选预计算长度；小于 0 时内部计算。 |

Returns: 采样点；空折线返回 Vector2.ZERO。

#### `sample_curve`

- API: `public`

```gdscript
static func sample_curve(curve: Curve2D, ratio: float, cubic: bool = false) -> Vector2:
```

按 0 到 1 的比例采样 Curve2D 的 baked 路径。

Parameters:

| Name | Description |
|---|---|
| `curve` | 目标曲线。 |
| `ratio` | 归一化采样位置；会被限制在 0 到 1。 |
| `cubic` | 是否使用 Curve2D.sample_baked() 的三次插值。 |

Returns: 采样点；曲线为空或无点时返回 Vector2.ZERO。

#### `simplify_polyline_by_distance`

- API: `public`

```gdscript
static func simplify_polyline_by_distance( points: PackedVector2Array, min_distance: float, keep_last: bool = true ) -> PackedVector2Array:
```

按最小点距简化折线，适合压缩手绘、采样或导入得到的密集点。

Parameters:

| Name | Description |
|---|---|
| `points` | 原始折线点序列。 |
| `min_distance` | 相邻保留点的最小距离；小于等于 0 时返回原始副本。 |
| `keep_last` | 是否始终保留末点。 |

Returns: 简化后的折线点序列。

#### `create_rect_curve`

- API: `public`

```gdscript
static func create_rect_curve( size: Vector2, radius: Vector2 = Vector2.ZERO, offset: Vector2 = Vector2.ZERO, rotation: float = 0.0 ) -> Curve2D:
```

创建闭合矩形 Curve2D。

Parameters:

| Name | Description |
|---|---|
| `size` | 矩形尺寸。 |
| `radius` | 圆角半径；会限制到尺寸的一半。 |
| `offset` | 曲线中心偏移。 |
| `rotation` | 曲线旋转弧度。 |

Returns: 新建的 Curve2D。

#### `set_rect_curve`

- API: `public`

```gdscript
static func set_rect_curve( curve: Curve2D, size: Vector2, radius: Vector2 = Vector2.ZERO, offset: Vector2 = Vector2.ZERO, rotation: float = 0.0 ) -> Curve2D:
```

将已有 Curve2D 改写为闭合矩形。

Parameters:

| Name | Description |
|---|---|
| `curve` | 要写入的曲线；为空时会创建新曲线。 |
| `size` | 矩形尺寸。 |
| `radius` | 圆角半径；会限制到尺寸的一半。 |
| `offset` | 曲线中心偏移。 |
| `rotation` | 曲线旋转弧度。 |

Returns: 写入后的 Curve2D。

#### `create_ellipse_curve`

- API: `public`

```gdscript
static func create_ellipse_curve( size: Vector2, offset: Vector2 = Vector2.ZERO, rotation: float = 0.0 ) -> Curve2D:
```

创建闭合椭圆 Curve2D。

Parameters:

| Name | Description |
|---|---|
| `size` | 椭圆外接框尺寸。 |
| `offset` | 曲线中心偏移。 |
| `rotation` | 曲线旋转弧度。 |

Returns: 新建的 Curve2D。

#### `set_ellipse_curve`

- API: `public`

```gdscript
static func set_ellipse_curve( curve: Curve2D, size: Vector2, offset: Vector2 = Vector2.ZERO, rotation: float = 0.0 ) -> Curve2D:
```

将已有 Curve2D 改写为闭合椭圆。

Parameters:

| Name | Description |
|---|---|
| `curve` | 要写入的曲线；为空时会创建新曲线。 |
| `size` | 椭圆外接框尺寸。 |
| `offset` | 曲线中心偏移。 |
| `rotation` | 曲线旋转弧度。 |

Returns: 写入后的 Curve2D。

## GFDebugDrawUtility

- Path: `addons/gf/standard/utilities/debug/gf_debug_draw_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDebugDrawUtility: 通用调试绘制命令缓冲。 收集 2D/3D 线段、矩形、圆、文本等即时调试绘制命令。 Utility 只维护抽象命令和生命周期，具体渲染可由项目层 Overlay/Viewport 适配。

### Signals

#### `items_changed`

- API: `public`

```gdscript
signal items_changed
```

绘制命令发生变化时发出。

### Enums

#### `PrimitiveType`

- API: `public`

```gdscript
enum PrimitiveType { ## 2D 线段命令。 LINE_2D, ## 2D 矩形命令。 RECT_2D, ## 2D 圆形命令。 CIRCLE_2D, ## 2D 文本命令。 TEXT_2D, ## 3D 线段命令。 LINE_3D, ## 3D AABB 盒命令。 BOX_3D, ## 3D 文本命令。 TEXT_3D, ## 项目自定义命令。 CUSTOM, }
```

调试绘制命令类型。

### Properties

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用调试绘制。

#### `default_lifetime_seconds`

- API: `public`

```gdscript
var default_lifetime_seconds: float = 0.0
```

默认生命周期。小于 0 表示永久保留，0 表示等待下一次 tick 后清理。

#### `max_items`

- API: `public`

```gdscript
var max_items: int = 2048
```

最大命令数量。小于等于 0 表示不限制。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化调试绘制缓冲。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放并清空调试绘制命令。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `draw_line_2d`

- API: `public`

```gdscript
func draw_line_2d( from: Vector2, to: Vector2, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", width: float = 1.0 ) -> int:
```

绘制 2D 线段。

Parameters:

| Name | Description |
|---|---|
| `from` | 起点位置。 |
| `to` | 终点位置。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `width` | 绘制线宽。 |

Returns: 绘制命令 id。

#### `draw_rect_2d`

- API: `public`

```gdscript
func draw_rect_2d( rect: Rect2, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", filled: bool = false, width: float = 1.0 ) -> int:
```

绘制 2D 矩形。

Parameters:

| Name | Description |
|---|---|
| `rect` | 矩形区域。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `filled` | 是否填充绘制图形。 |
| `width` | 绘制线宽。 |

Returns: 绘制命令 id。

#### `draw_circle_2d`

- API: `public`

```gdscript
func draw_circle_2d( center: Vector2, radius: float, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", filled: bool = false, width: float = 1.0 ) -> int:
```

绘制 2D 圆。

Parameters:

| Name | Description |
|---|---|
| `center` | 要绘制圆形的中心点。 |
| `radius` | 圆形半径。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `filled` | 是否填充绘制图形。 |
| `width` | 绘制线宽。 |

Returns: 绘制命令 id。

#### `draw_text_2d`

- API: `public`

```gdscript
func draw_text_2d( position: Vector2, text: String, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", font_size: int = 16 ) -> int:
```

绘制 2D 文本。

Parameters:

| Name | Description |
|---|---|
| `position` | 绘制文本的位置。 |
| `text` | 要绘制或输出的文本。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `font_size` | 绘制文本字号。 |

Returns: 绘制命令 id。

#### `draw_line_3d`

- API: `public`

```gdscript
func draw_line_3d( from: Vector3, to: Vector3, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", width: float = 1.0 ) -> int:
```

绘制 3D 线段。

Parameters:

| Name | Description |
|---|---|
| `from` | 起点位置。 |
| `to` | 终点位置。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `width` | 绘制线宽。 |

Returns: 绘制命令 id。

#### `draw_box_3d`

- API: `public`

```gdscript
func draw_box_3d( box: AABB, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", filled: bool = false, width: float = 1.0 ) -> int:
```

绘制 3D AABB。

Parameters:

| Name | Description |
|---|---|
| `box` | 要绘制的 3D 包围盒。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `filled` | 是否填充绘制图形。 |
| `width` | 绘制线宽。 |

Returns: 绘制命令 id。

#### `draw_text_3d`

- API: `public`

```gdscript
func draw_text_3d( position: Vector3, text: String, color: Color = Color.WHITE, lifetime_seconds: float = -1.0, channel: StringName = &"default", font_size: int = 16 ) -> int:
```

绘制 3D 文本。

Parameters:

| Name | Description |
|---|---|
| `position` | 绘制文本的位置。 |
| `text` | 要绘制或输出的文本。 |
| `color` | 绘制颜色。 |
| `lifetime_seconds` | 调试绘制命令保留时间（秒）。 |
| `channel` | 调试绘制频道。 |
| `font_size` | 绘制文本字号。 |

Returns: 绘制命令 id。

#### `push_item`

- API: `public`

```gdscript
func push_item(item: Dictionary) -> int:
```

推入自定义调试绘制命令。

Parameters:

| Name | Description |
|---|---|
| `item` | 命令字典。 |

Returns: 命令 id。

Schemas:

- `item`: Dictionary，至少可包含 type、channel、lifetime_seconds 以及项目自定义绘制载荷。

#### `clear`

- API: `public`

```gdscript
func clear(channel: StringName = &"") -> void:
```

清理命令。

Parameters:

| Name | Description |
|---|---|
| `channel` | 指定频道；为空时清空全部。 |

#### `set_channel_enabled`

- API: `public`

```gdscript
func set_channel_enabled(channel: StringName, channel_enabled: bool) -> void:
```

设置频道启用状态。

Parameters:

| Name | Description |
|---|---|
| `channel` | 频道。 |
| `channel_enabled` | 是否启用。 |

#### `is_channel_enabled`

- API: `public`

```gdscript
func is_channel_enabled(channel: StringName) -> bool:
```

检查频道是否启用。

Parameters:

| Name | Description |
|---|---|
| `channel` | 频道。 |

Returns: 启用返回 true。

#### `get_items`

- API: `public`

```gdscript
func get_items(channel: StringName = &"", include_disabled: bool = false) -> Array[Dictionary]:
```

获取绘制命令。

Parameters:

| Name | Description |
|---|---|
| `channel` | 指定频道；为空时返回全部频道。 |
| `include_disabled` | 是否包含已禁用频道或全局禁用状态下的命令。 |

Returns: 命令副本列表。

Schemas:

- `return`: Array[Dictionary]，每个元素为调试绘制命令，包含 id、type、channel、created_at_msec、lifetime_seconds、remaining_seconds 和图元载荷。

#### `get_item_count`

- API: `public`

```gdscript
func get_item_count(channel: StringName = &"") -> int:
```

获取命令数量。

Parameters:

| Name | Description |
|---|---|
| `channel` | 指定频道；为空时返回全部。 |

Returns: 数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 快照字典。

Schemas:

- `return`: Dictionary，包含 enabled、item_count、channels、primitive_types 和 max_items。

## GFDebugOverlayUtility

- Path: `addons/gf/standard/utilities/debug/gf_debug_overlay_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDebugOverlayUtility: 开发期运行时观察覆盖层。 提供 watch / panel 注册、轻量运行时快照和可选调试 GUI。默认只在 debug 构建中创建 GUI。 发布构建如确实需要显示，必须显式关闭 debug_only 并自行确认可见性与数据脱敏策略。

### Properties

#### `toggle_key`

- API: `public`

```gdscript
var toggle_key: Key = KEY_QUOTELEFT
```

呼出/隐藏面板的快捷键。默认为 KEY_QUOTELEFT (`~` 键)。

#### `refresh_interval_seconds`

- API: `public`

```gdscript
var refresh_interval_seconds: float = 0.25
```

可见时刷新模型反射数据的间隔（秒）。设为 0 时每帧刷新。

#### `include_diagnostics_monitors`

- API: `public`

```gdscript
var include_diagnostics_monitors: bool = true
```

是否把 GFDiagnosticsUtility 的监控预设合并显示到 Watch 区。

#### `diagnostics_monitor_preset`

- API: `public`

```gdscript
var diagnostics_monitor_preset: StringName = &"overlay"
```

Overlay 默认读取的诊断监控预设。

#### `include_recent_logs`

- API: `public`

```gdscript
var include_recent_logs: bool = true
```

是否在 Overlay 中附加最近日志面板。

#### `recent_log_count`

- API: `public`

```gdscript
var recent_log_count: int = 12
```

最近日志面板读取的日志数量。

#### `debug_only`

- API: `public`

```gdscript
var debug_only: bool = true
```

是否只在 debug 构建中创建 Overlay GUI。发布构建需要显式关闭此项才会创建 GUI。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化调试覆盖层 GUI。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放调试覆盖层 GUI 和所有 watch / panel 注册。

#### `set_toggle_key`

- API: `public`

```gdscript
func set_toggle_key(key: Key) -> void:
```

更新快捷键绑定

Parameters:

| Name | Description |
|---|---|
| `key` | 新的触发按键 |

#### `set_refresh_interval`

- API: `public`

```gdscript
func set_refresh_interval(seconds: float) -> void:
```

设置可见时的刷新间隔。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 刷新间隔；小于等于 0 时每帧刷新。 |

#### `set_diagnostics_monitor_preset`

- API: `public`

```gdscript
func set_diagnostics_monitor_preset(preset_id: StringName) -> void:
```

设置 Overlay 使用的诊断监控预设。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 诊断监控预设标识；为空时采集全部可见监控项。 |

#### `set_overlay_visible`

- API: `public`

```gdscript
func set_overlay_visible(visible: bool) -> void:
```

设置 Overlay GUI 可见性。

Parameters:

| Name | Description |
|---|---|
| `visible` | 为 true 时显示 Overlay GUI。 |

#### `is_overlay_visible`

- API: `public`

```gdscript
func is_overlay_visible() -> bool:
```

检查 Overlay GUI 是否可见。

Returns: 可见时返回 true。

#### `refresh_overlay`

- API: `public`

```gdscript
func refresh_overlay() -> void:
```

立即刷新 Overlay GUI 文本。

#### `watch_value`

- API: `public`

```gdscript
func watch_value(id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
```

注册一个由回调即时读取的运行时观察值。

Parameters:

| Name | Description |
|---|---|
| `id` | 观察值唯一标识。 |
| `provider` | 无参数回调；Overlay 刷新时调用并显示返回值。 |
| `options` | 可选显示参数，支持 label、group、visible。 |

Returns: 注册成功返回 true；id 为空或 provider 无效时返回 false。

Schemas:

- `options`: Dictionary，支持 label、group 和 visible。

#### `push_watch_value`

- API: `public`

```gdscript
func push_watch_value(id: StringName, value: Variant, options: Dictionary = {}) -> bool:
```

推送一个由调用方主动更新的运行时观察值。

Parameters:

| Name | Description |
|---|---|
| `id` | 观察值唯一标识。 |
| `value` | 要显示的当前值。 |
| `options` | 可选显示参数，支持 label、group、visible。 |

Returns: 注册成功返回 true；id 为空时返回 false。

Schemas:

- `value`: Variant，可为任意可显示值。
- `options`: Dictionary，支持 label、group 和 visible。

#### `remove_watch`

- API: `public`

```gdscript
func remove_watch(id: StringName) -> void:
```

移除一个运行时观察值。

Parameters:

| Name | Description |
|---|---|
| `id` | 要移除的观察值标识。 |

#### `clear_watches`

- API: `public`

```gdscript
func clear_watches() -> void:
```

清空所有运行时观察值。

#### `has_watch`

- API: `public`

```gdscript
func has_watch(id: StringName) -> bool:
```

检查运行时观察值是否已注册。

Parameters:

| Name | Description |
|---|---|
| `id` | 要检查的观察值标识。 |

Returns: 已注册时返回 true。

#### `get_watch_snapshot`

- API: `public`

```gdscript
func get_watch_snapshot(include_hidden: bool = false) -> Array[Dictionary]:
```

读取当前运行时观察值快照。

Parameters:

| Name | Description |
|---|---|
| `include_hidden` | 为 true 时同时返回 visible=false 的观察值。 |

Returns: 按注册顺序排列的观察值字典数组。

Schemas:

- `return`: Array[Dictionary]，每个元素包含 id、label、group、value 和 valid。

#### `register_panel`

- API: `public`

```gdscript
func register_panel(panel_id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
```

注册一个由回调生成内容的 Overlay 面板。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | 面板唯一标识。 |
| `provider` | 无参数回调；返回 String、Dictionary、Array 或其他可转字符串值。 |
| `options` | 可选显示参数，支持 label、group、visible。 |

Returns: 注册成功返回 true。

Schemas:

- `options`: Dictionary，支持 label、group 和 visible。

#### `push_panel_text`

- API: `public`

```gdscript
func push_panel_text(panel_id: StringName, content: String, options: Dictionary = {}) -> bool:
```

推送一个静态 Overlay 面板文本。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | 面板唯一标识。 |
| `content` | 面板内容。 |
| `options` | 可选显示参数，支持 label、group、visible。 |

Returns: 注册成功返回 true。

Schemas:

- `options`: Dictionary，支持 label、group 和 visible。

#### `remove_panel`

- API: `public`

```gdscript
func remove_panel(panel_id: StringName) -> void:
```

移除一个 Overlay 面板。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | 面板唯一标识。 |

#### `clear_panels`

- API: `public`

```gdscript
func clear_panels() -> void:
```

清空 Overlay 面板注册表。

#### `has_panel`

- API: `public`

```gdscript
func has_panel(panel_id: StringName) -> bool:
```

检查 Overlay 面板是否已注册。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | 面板唯一标识。 |

Returns: 已注册时返回 true。

#### `get_panel_snapshot`

- API: `public`

```gdscript
func get_panel_snapshot(include_hidden: bool = false) -> Array[Dictionary]:
```

读取当前 Overlay 面板快照。

Parameters:

| Name | Description |
|---|---|
| `include_hidden` | 为 true 时同时返回 visible=false 的面板。 |

Returns: 面板快照数组。

Schemas:

- `return`: Array[Dictionary]，每个元素包含 id、label、group、content 和 valid。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取 Overlay 运行时调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 debug_only、watch_count、panel_count、include_diagnostics_monitors、include_recent_logs、recent_log_count、diagnostics_monitor_preset 和 gui 分区。

## GFDiagnosticsDock

- Path: `addons/gf/standard/utilities/debug/editor/gf_diagnostics_dock.gd`
- Extends: `Control`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFDiagnosticsDock: GF 诊断工作区页面。 采集通用运行时、性能、监控和场景树诊断快照，供编辑器内只读查看。

### Methods

#### `collect_snapshot`

- API: `public`

```gdscript
func collect_snapshot() -> void:
```

采集诊断快照。

#### `get_last_snapshot`

- API: `public`

```gdscript
func get_last_snapshot() -> Dictionary:
```

获取最近一次诊断快照。

Returns: 快照副本。

Schemas:

- `return`: Dictionary，包含 GFDiagnosticsUtility.collect_snapshot() 返回的诊断分区。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取面板调试快照。

Returns: 面板调试快照。

Schemas:

- `return`: Dictionary，包含 last_snapshot、summary_text、details_text 和 ui 分区。

## GFDiagnosticsUtility

- Path: `addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDiagnosticsUtility: 运行时诊断聚合工具。 提供架构生命周期、事件系统、性能、日志和外部贡献诊断的统一快照。 诊断命令、监控项和快照分区通过 Callable 注册，框架只负责调度和包装结果，不解释项目业务数据。

### Signals

#### `snapshot_collected`

- API: `public`

```gdscript
signal snapshot_collected(snapshot: Dictionary)
```

采集快照后发出。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 刚采集到的诊断快照。 |

Schemas:

- `snapshot`: Dictionary，包含 collect_snapshot() 返回的顶层诊断分区。

#### `diagnostic_command_executed`

- API: `public`

```gdscript
signal diagnostic_command_executed(command_name: StringName, result: Dictionary)
```

执行诊断命令后发出。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 已执行的诊断命令名。 |
| `result` | 命令执行结果。 |

Schemas:

- `result`: Dictionary，包含 ok、value、error、metadata 等字段。

#### `monitor_sampled`

- API: `public`

```gdscript
signal monitor_sampled(monitor_id: StringName, sample: Dictionary)
```

采样诊断监控项后发出。

Parameters:

| Name | Description |
|---|---|
| `monitor_id` | 监控项标识。 |
| `sample` | 采样结果。 |

Schemas:

- `sample`: Dictionary，包含 id、label、group、value、valid、error、metadata 和 sampled_at_unix。

### Enums

#### `CommandTier`

- API: `public`

```gdscript
enum CommandTier { ## 只读取状态。 OBSERVE, ## 修改调试输入或临时过滤条件。 INPUT, ## 控制运行时行为。 CONTROL, ## 可能破坏状态、存档或远端连接。 DANGER, }
```

诊断命令风险等级。

### Properties

#### `include_performance_monitors`

- API: `public`

```gdscript
var include_performance_monitors: bool = true
```

是否采集 Godot Performance 监视器。

#### `default_recent_log_count`

- API: `public`

```gdscript
var default_recent_log_count: int = 20
```

快照中默认包含的最近日志数量。

#### `max_command_tier`

- API: `public`

```gdscript
var max_command_tier: CommandTier = CommandTier.OBSERVE
```

当前允许执行的最高命令等级。

#### `require_auth_token`

- API: `public`

```gdscript
var require_auth_token: bool = false
```

是否要求命令参数提供 auth_token 或 _auth_token。

#### `auth_token`

- API: `public`

```gdscript
var auth_token: String = ""
```

诊断命令认证 token。为空时无法通过认证。

#### `allow_danger_commands`

- API: `public`

```gdscript
var allow_danger_commands: bool = false
```

是否允许执行 DANGER 等级命令。即使 max_command_tier 足够，也需要显式开启。

#### `encode_command_results_for_json`

- API: `public`

```gdscript
var encode_command_results_for_json: bool = false
```

是否把诊断命令结果转换为 JSON 兼容 Variant。

#### `default_scene_tree_max_depth`

- API: `public`

```gdscript
var default_scene_tree_max_depth: int = 4
```

场景树快照默认递归深度。

#### `default_scene_tree_max_nodes`

- API: `public`

```gdscript
var default_scene_tree_max_nodes: int = 128
```

场景树快照默认最多采集节点数。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化内置诊断命令和监控项。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

绑定控制台诊断命令。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放诊断注册表并解绑控制台命令。

#### `register_command`

- API: `public`

```gdscript
func register_command( command_name: StringName, callback: Callable, description: String = "", tier: CommandTier = CommandTier.OBSERVE, options: Dictionary = {} ) -> void:
```

注册诊断命令。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |
| `callback` | 回调，签名建议为 func(args: Dictionary) -> Variant。 |
| `description` | 描述文本。 |
| `tier` | 命令风险等级。 |
| `options` | 可选元数据，支持 parameters、metadata、enabled。 |

Schemas:

- `options`: Dictionary，支持 parameters、metadata 和 enabled。

#### `unregister_command`

- API: `public`

```gdscript
func unregister_command(command_name: StringName) -> void:
```

注销诊断命令。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |

#### `has_command`

- API: `public`

```gdscript
func has_command(command_name: StringName) -> bool:
```

检查诊断命令是否存在。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |

Returns: 存在返回 true。

#### `set_command_parameter_schema`

- API: `public`

```gdscript
func set_command_parameter_schema(command_name: StringName, parameters: Variant) -> bool:
```

设置诊断命令参数 schema。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |
| `parameters` | 参数 schema，可为数组或按参数名索引的字典。 |

Returns: 设置成功返回 true。

Schemas:

- `parameters`: Variant，支持 Array[Dictionary] 或 Dictionary 形式的参数 schema。

#### `set_command_enabled`

- API: `public`

```gdscript
func set_command_enabled(command_name: StringName, enabled: bool) -> bool:
```

设置诊断命令是否启用。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |
| `enabled` | 是否启用。 |

Returns: 命令存在时返回 true。

#### `set_all_commands_enabled`

- API: `public`

```gdscript
func set_all_commands_enabled( enabled: bool, command_names: PackedStringArray = PackedStringArray() ) -> int:
```

批量设置命令是否启用。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 是否启用。 |
| `command_names` | 指定命令；为空时作用于全部已注册命令。 |

Returns: 实际处理的命令数量。

#### `is_command_enabled`

- API: `public`

```gdscript
func is_command_enabled(command_name: StringName) -> bool:
```

检查命令是否启用。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |

Returns: 命令存在且启用时返回 true。

#### `get_command_descriptions`

- API: `public`

```gdscript
func get_command_descriptions() -> Dictionary:
```

获取诊断命令描述。

Returns: 命令名到描述的字典。

Schemas:

- `return`: Dictionary[StringName, String]，以命令名为键。

#### `get_command_catalog`

- API: `public`

```gdscript
func get_command_catalog() -> Dictionary:
```

获取诊断命令目录。

Returns: 命令名到命令元数据的字典。

Schemas:

- `return`: Dictionary[StringName, Dictionary]，每个值包含 description、tier、tier_name、enabled、parameters 和 metadata。

#### `register_monitor`

- API: `public`

```gdscript
func register_monitor(monitor_id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
```

注册诊断监控项。

Parameters:

| Name | Description |
|---|---|
| `monitor_id` | 监控项唯一标识。 |
| `provider` | 无参数采样回调。 |
| `options` | 可选元数据，支持 label、group、visible、metadata、min_interval_seconds。 |

Returns: 注册成功返回 true。

Schemas:

- `options`: Dictionary，支持 label、group、visible、metadata 和 min_interval_seconds。

#### `unregister_monitor`

- API: `public`

```gdscript
func unregister_monitor(monitor_id: StringName) -> void:
```

注销诊断监控项。

Parameters:

| Name | Description |
|---|---|
| `monitor_id` | 监控项唯一标识。 |

#### `has_monitor`

- API: `public`

```gdscript
func has_monitor(monitor_id: StringName) -> bool:
```

检查诊断监控项是否存在。

Parameters:

| Name | Description |
|---|---|
| `monitor_id` | 监控项唯一标识。 |

Returns: 存在返回 true。

#### `get_monitor_catalog`

- API: `public`

```gdscript
func get_monitor_catalog() -> Dictionary:
```

获取诊断监控项目录。

Returns: 监控项元数据字典。

Schemas:

- `return`: Dictionary[StringName, Dictionary]，每个值包含 label、group、visible、metadata 和 min_interval_seconds。

#### `register_monitor_preset`

- API: `public`

```gdscript
func register_monitor_preset( preset_id: StringName, monitor_ids: PackedStringArray, options: Dictionary = {} ) -> bool:
```

注册诊断监控预设。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 预设唯一标识。 |
| `monitor_ids` | 预设包含的监控项标识。 |
| `options` | 可选元数据，支持 label、metadata。 |

Returns: 注册成功返回 true。

Schemas:

- `options`: Dictionary，支持 label 和 metadata。

#### `add_monitor_to_preset`

- API: `public`

```gdscript
func add_monitor_to_preset(preset_id: StringName, monitor_id: StringName) -> bool:
```

将一个监控项追加到已有预设；预设不存在时会创建。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 预设唯一标识。 |
| `monitor_id` | 监控项唯一标识。 |

Returns: 追加成功返回 true。

#### `unregister_monitor_preset`

- API: `public`

```gdscript
func unregister_monitor_preset(preset_id: StringName) -> void:
```

注销诊断监控预设。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 预设唯一标识。 |

#### `has_monitor_preset`

- API: `public`

```gdscript
func has_monitor_preset(preset_id: StringName) -> bool:
```

检查诊断监控预设是否存在。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 预设唯一标识。 |

Returns: 存在返回 true。

#### `get_monitor_preset_ids`

- API: `public`

```gdscript
func get_monitor_preset_ids() -> PackedStringArray:
```

获取诊断监控预设列表。

Returns: 预设标识列表。

#### `register_snapshot_section_provider`

- API: `public`

```gdscript
func register_snapshot_section_provider(section_id: StringName, provider: Callable) -> bool:
```

注册快照分区 provider。用于扩展或项目把自己的诊断数据贡献到 collect_snapshot() 顶层字段。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 快照顶层字段名。 |
| `provider` | 无参数采样回调，建议返回 Dictionary。 |

Returns: 注册成功返回 true。

#### `unregister_snapshot_section_provider`

- API: `public`

```gdscript
func unregister_snapshot_section_provider(section_id: StringName) -> void:
```

注销快照分区 provider。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 快照顶层字段名。 |

#### `has_snapshot_section_provider`

- API: `public`

```gdscript
func has_snapshot_section_provider(section_id: StringName) -> bool:
```

检查快照分区 provider 是否存在。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 快照顶层字段名。 |

Returns: 存在返回 true。

#### `register_tool_snapshot_provider`

- API: `public`

```gdscript
func register_tool_snapshot_provider(tool_id: StringName, provider: Callable) -> bool:
```

注册工具快照 provider。用于扩展或项目把 get_debug_snapshot() 风格数据贡献到 tools 字段。

Parameters:

| Name | Description |
|---|---|
| `tool_id` | tools 内部字段名。 |
| `provider` | 无参数采样回调，建议返回 Dictionary。 |

Returns: 注册成功返回 true。

#### `unregister_tool_snapshot_provider`

- API: `public`

```gdscript
func unregister_tool_snapshot_provider(tool_id: StringName) -> void:
```

注销工具快照 provider。

Parameters:

| Name | Description |
|---|---|
| `tool_id` | tools 内部字段名。 |

#### `has_tool_snapshot_provider`

- API: `public`

```gdscript
func has_tool_snapshot_provider(tool_id: StringName) -> bool:
```

检查工具快照 provider 是否存在。

Parameters:

| Name | Description |
|---|---|
| `tool_id` | tools 内部字段名。 |

Returns: 存在返回 true。

#### `collect_monitor_snapshot`

- API: `public`

```gdscript
func collect_monitor_snapshot( monitor_ids: PackedStringArray = PackedStringArray(), include_hidden: bool = false ) -> Dictionary:
```

采集诊断监控快照。

Parameters:

| Name | Description |
|---|---|
| `monitor_ids` | 指定监控项；为空时采集全部可见监控项。 |
| `include_hidden` | 为 true 时包含 visible=false 的监控项。 |

Returns: 监控快照字典。

Schemas:

- `return`: Dictionary，包含 timestamp_unix、monitor_count 和 monitors。

#### `collect_monitor_preset`

- API: `public`

```gdscript
func collect_monitor_preset(preset_id: StringName, include_hidden: bool = false) -> Dictionary:
```

按预设采集诊断监控快照。

Parameters:

| Name | Description |
|---|---|
| `preset_id` | 预设唯一标识。 |
| `include_hidden` | 为 true 时包含 visible=false 的监控项。 |

Returns: 监控快照字典。

Schemas:

- `return`: Dictionary，包含 collect_monitor_snapshot() 字段以及 preset_id、preset_label、preset_metadata。

#### `export_monitor_snapshot`

- API: `public`

```gdscript
func export_monitor_snapshot(snapshot: Dictionary, format: StringName = &"json") -> String:
```

导出诊断监控快照。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | collect_monitor_snapshot() 或 collect_monitor_preset() 返回值。 |
| `format` | 导出格式，支持 json、text、csv。 |

Returns: 导出文本。

Schemas:

- `snapshot`: Dictionary，collect_monitor_snapshot() 或 collect_monitor_preset() 返回结构。

#### `set_auth_token`

- API: `public`

```gdscript
func set_auth_token(token: String, required: bool = true) -> void:
```

设置诊断认证 token。

Parameters:

| Name | Description |
|---|---|
| `token` | token 文本。 |
| `required` | 是否立即启用 token 校验。 |

#### `execute_command`

- API: `public`

```gdscript
func execute_command(command_name: StringName, args: Dictionary = {}) -> Dictionary:
```

执行诊断命令。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |
| `args` | 命令参数。 |

Returns: 统一结果字典。

Schemas:

- `args`: Dictionary，命令参数；可包含 auth_token 以及该命令 parameter_schema 定义的字段。
- `return`: Dictionary，包含 ok、value、error、metadata。

#### `execute_command_json_safe`

- API: `public`

```gdscript
func execute_command_json_safe(command_name: StringName, args: Dictionary = {}) -> Dictionary:
```

执行诊断命令并返回 JSON 兼容结果。

Parameters:

| Name | Description |
|---|---|
| `command_name` | 命令名。 |
| `args` | 命令参数。 |

Returns: JSON 兼容结果字典。

Schemas:

- `args`: Dictionary，命令参数；可包含 auth_token 以及该命令 parameter_schema 定义的字段。
- `return`: Dictionary，包含 JSON 兼容的 ok、value、error、metadata。

#### `command_result_to_json_compatible`

- API: `public`

```gdscript
func command_result_to_json_compatible(result: Dictionary, options: Dictionary = {}) -> Dictionary:
```

将命令结果转换为 JSON 兼容字典。

Parameters:

| Name | Description |
|---|---|
| `result` | execute_command() 返回的结果。 |
| `options` | 传给 GFVariantJsonCodec.variant_to_json_compatible() 的选项。 |

Returns: JSON 兼容结果字典。

Schemas:

- `result`: Dictionary，execute_command() 返回结构。
- `options`: Dictionary，传给 GFVariantJsonCodec.variant_to_json_compatible() 的编码选项。
- `return`: Dictionary，JSON 兼容命令结果。

#### `collect_snapshot`

- API: `public`

```gdscript
func collect_snapshot(options: Dictionary = {}) -> Dictionary:
```

采集运行时诊断快照。

Parameters:

| Name | Description |
|---|---|
| `options` | 可选参数，支持 recent_log_count、include_recent_logs、include_scene_tree、scene_tree_options、include_signal_graph、signal_graph_options。 |

Returns: 快照字典。

Schemas:

- `options`: Dictionary，支持 recent_log_count、include_recent_logs、include_scene_tree、scene_tree_options、include_signal_graph、signal_graph_options、include_monitors、monitor_preset、monitor_ids、include_hidden_monitors。
- `return`: Dictionary，包含 timestamp_unix、engine、build、architecture、event_system、performance、logs、network、tools，可选 scene_tree、signal_graph、monitors 和注册分区。

#### `collect_performance_snapshot`

- API: `public`

```gdscript
func collect_performance_snapshot() -> Dictionary:
```

采集性能监视器快照。

Returns: 性能数据字典。

Schemas:

- `return`: Dictionary，包含 fps、process_time、physics_process_time、static_memory、object_count、node_count、resource_count。

#### `collect_log_snapshot`

- API: `public`

```gdscript
func collect_log_snapshot(recent_log_count: int = 20, include_recent_logs: bool = true) -> Dictionary:
```

采集日志缓存快照。

Parameters:

| Name | Description |
|---|---|
| `recent_log_count` | 最近日志数量。 |
| `include_recent_logs` | 是否包含日志条目。 |

Returns: 日志数据字典。

Schemas:

- `return`: Dictionary，包含 available、memory_count、dropped_count、recent。

#### `collect_scene_tree_snapshot`

- API: `public`

```gdscript
func collect_scene_tree_snapshot(root: Node = null, options: Dictionary = {}) -> Dictionary:
```

采集只读场景树快照。

Parameters:

| Name | Description |
|---|---|
| `root` | 可选根节点；为空时优先使用当前场景，再回退到 Viewport root。 |
| `options` | 可选参数，支持 max_depth、max_nodes、include_groups、include_owner_path、include_script_path、include_internal。 |

Returns: 场景树快照字典。

Schemas:

- `options`: Dictionary，支持 max_depth、max_nodes、include_groups、include_owner_path、include_script_path、include_internal、root_path、prefer_current_scene。
- `return`: Dictionary，包含 available、node_count、truncated、root_path、root。

#### `collect_signal_graph_snapshot`

- API: `public`

```gdscript
func collect_signal_graph_snapshot(root: Node = null, options: Dictionary = {}) -> Dictionary:
```

采集只读信号连接图快照。

Parameters:

| Name | Description |
|---|---|
| `root` | 可选根节点；为空时优先使用当前场景，再回退到 Viewport root。 |
| `options` | 可选参数，支持 include_internal、persistent_only、include_empty_signals、include_external_targets、include_index。 |

Returns: 信号图快照字典。

Schemas:

- `options`: Dictionary，支持 include_internal、persistent_only、include_empty_signals、include_external_targets、include_index、root_path、prefer_current_scene。
- `return`: Dictionary，包含 ok、root_path、node_count、signal_count、connection_count、nodes、signals、connections，可选 index。

## GFDisplaySettingsUtility

- Path: `addons/gf/standard/utilities/display/gf_display_settings_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDisplaySettingsUtility: 通用显示、语言与音频总线设置应用器。 该工具把抽象设置值应用到 Godot 引擎层。设置值本身由 GFSettingsUtility 管理； 未注册 GFSettingsUtility 时，也可以直接作为运行时应用器使用。

### Signals

#### `display_setting_applied`

- API: `public`

```gdscript
signal display_setting_applied(key: StringName, value: Variant)
```

某个引擎设置应用完成时发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `value` | 已应用的值。 |

Schemas:

- `value`: Variant，与设置键匹配的值，例如 int、Vector2i、String 或 float。

### Constants

#### `WINDOW_MODE_KEY`

- API: `public`

```gdscript
const WINDOW_MODE_KEY: StringName = &"display/window_mode"
```

窗口模式设置键。

#### `WINDOW_SIZE_KEY`

- API: `public`

```gdscript
const WINDOW_SIZE_KEY: StringName = &"display/window_size"
```

窗口尺寸设置键。

#### `VSYNC_MODE_KEY`

- API: `public`

```gdscript
const VSYNC_MODE_KEY: StringName = &"display/vsync_mode"
```

垂直同步模式设置键。

#### `LOCALE_KEY`

- API: `public`

```gdscript
const LOCALE_KEY: StringName = &"display/locale"
```

语言设置键。

### Properties

#### `register_defaults_on_ready`

- API: `public`

```gdscript
var register_defaults_on_ready: bool = true
```

ready() 时是否注册默认设置定义。

#### `apply_on_ready`

- API: `public`

```gdscript
var apply_on_ready: bool = true
```

ready() 时是否立刻应用当前设置。

#### `auto_apply_setting_changes`

- API: `public`

```gdscript
var auto_apply_setting_changes: bool = true
```

GFSettingsUtility 中相关设置变化时是否自动应用。

#### `persist_changes`

- API: `public`

```gdscript
var persist_changes: bool = true
```

设置变化时是否写入 GFSettingsUtility。

#### `audio_setting_prefix`

- API: `public`

```gdscript
var audio_setting_prefix: StringName = &"audio"
```

音频设置键前缀。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化显示设置应用器的时间与暂停策略。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

注册默认设置、连接设置变化并按配置应用当前值。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放设置连接并清空运行时缓存。

#### `register_default_settings`

- API: `public`

```gdscript
func register_default_settings() -> void:
```

注册显示相关默认设置定义。

#### `apply_all`

- API: `public`

```gdscript
func apply_all() -> void:
```

应用所有当前已知显示设置。

#### `set_window_mode`

- API: `public`

```gdscript
func set_window_mode(mode: DisplayServer.WindowMode) -> void:
```

设置窗口模式并应用。

Parameters:

| Name | Description |
|---|---|
| `mode` | 目标窗口模式。 |

#### `get_window_mode`

- API: `public`

```gdscript
func get_window_mode() -> DisplayServer.WindowMode:
```

获取窗口模式设置。

Returns: 窗口模式。

#### `set_fullscreen`

- API: `public`

```gdscript
func set_fullscreen(enabled: bool) -> void:
```

设置是否全屏。

Parameters:

| Name | Description |
|---|---|
| `enabled` | true 时切换到全屏，false 时切回窗口模式。 |

#### `toggle_fullscreen`

- API: `public`

```gdscript
func toggle_fullscreen() -> void:
```

切换全屏状态。

#### `apply_window_mode`

- API: `public`

```gdscript
func apply_window_mode() -> void:
```

应用窗口模式设置。

#### `set_window_size`

- API: `public`

```gdscript
func set_window_size(size: Vector2i) -> void:
```

设置窗口尺寸并应用。

Parameters:

| Name | Description |
|---|---|
| `size` | 窗口尺寸。 |

#### `get_window_size`

- API: `public`

```gdscript
func get_window_size() -> Vector2i:
```

获取窗口尺寸设置。

Returns: 窗口尺寸。

#### `apply_window_size`

- API: `public`

```gdscript
func apply_window_size() -> void:
```

应用窗口尺寸设置。

#### `set_vsync_mode`

- API: `public`

```gdscript
func set_vsync_mode(mode: DisplayServer.VSyncMode) -> void:
```

设置垂直同步模式并应用。

Parameters:

| Name | Description |
|---|---|
| `mode` | VSync 模式。 |

#### `get_vsync_mode`

- API: `public`

```gdscript
func get_vsync_mode() -> DisplayServer.VSyncMode:
```

获取垂直同步模式设置。

Returns: VSync 模式。

#### `apply_vsync_mode`

- API: `public`

```gdscript
func apply_vsync_mode() -> void:
```

应用垂直同步设置。

#### `set_locale`

- API: `public`

```gdscript
func set_locale(locale: String) -> void:
```

设置语言并应用。

Parameters:

| Name | Description |
|---|---|
| `locale` | 语言代码，例如 "en" 或 "zh_CN"。 |

#### `get_locale`

- API: `public`

```gdscript
func get_locale() -> String:
```

获取当前语言设置。

Returns: 语言代码。

#### `apply_locale`

- API: `public`

```gdscript
func apply_locale() -> void:
```

应用语言设置。

#### `register_audio_bus_volume`

- API: `public`

```gdscript
func register_audio_bus_volume(bus_name: String, default_linear: float = 1.0) -> void:
```

注册一个音频总线音量设置。

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 音频总线名。 |
| `default_linear` | 默认线性音量，范围 0 到 1。 |

#### `set_audio_bus_volume`

- API: `public`

```gdscript
func set_audio_bus_volume(bus_name: String, volume_linear: float) -> void:
```

设置音频总线音量并应用。

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 音频总线名。 |
| `volume_linear` | 线性音量，范围 0 到 1。 |

#### `get_audio_bus_volume`

- API: `public`

```gdscript
func get_audio_bus_volume(bus_name: String, fallback: float = 1.0) -> float:
```

获取音频总线音量。

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 音频总线名。 |
| `fallback` | 设置缺失时的回退值。 |

Returns: 线性音量。

#### `apply_audio_bus_volume`

- API: `public`

```gdscript
func apply_audio_bus_volume(bus_name: String) -> void:
```

应用指定音频总线音量。

Parameters:

| Name | Description |
|---|---|
| `bus_name` | 音频总线名。 |

#### `apply_registered_audio_bus_volumes`

- API: `public`

```gdscript
func apply_registered_audio_bus_volumes() -> void:
```

应用所有已注册音频总线音量设置。

## GFDownloadTask

- Path: `addons/gf/standard/utilities/io/gf_download_task.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFDownloadTask: 通用下载任务描述。 只记录下载 URL、目标路径、校验信息和运行状态，不假设下载内容的业务语义。

### Enums

#### `Status`

- API: `public`

```gdscript
enum Status { ## 已加入队列。 QUEUED, ## 正在下载。 RUNNING, ## 已暂停，等待恢复。 PAUSED, ## 已完成。 COMPLETED, ## 已失败。 FAILED, ## 已取消。 CANCELLED, }
```

下载任务状态。

### Properties

#### `task_id`

- API: `public`

```gdscript
var task_id: int = 0
```

任务句柄。

#### `url`

- API: `public`

```gdscript
var url: String = ""
```

下载 URL。

#### `target_path`

- API: `public`

```gdscript
var target_path: String = ""
```

最终写入路径。

#### `temp_path`

- API: `public`

```gdscript
var temp_path: String = ""
```

临时文件路径。

#### `segment_path`

- API: `public`

```gdscript
var segment_path: String = ""
```

分段续传文件路径。

#### `headers`

- API: `public`

```gdscript
var headers: PackedStringArray = PackedStringArray()
```

HTTP 请求头。

#### `expected_sha256`

- API: `public`

```gdscript
var expected_sha256: String = ""
```

期望 SHA-256 校验值。为空时不校验。

#### `resume`

- API: `public`

```gdscript
var resume: bool = true
```

是否允许从临时文件续传。

#### `overwrite`

- API: `public`

```gdscript
var overwrite: bool = true
```

目标文件已存在时是否覆盖。

#### `max_retries`

- API: `public`

```gdscript
var max_retries: int = 0
```

最大重试次数。

#### `retry_count`

- API: `public`

```gdscript
var retry_count: int = 0
```

已执行重试次数。

#### `retry_delay_seconds`

- API: `public`

```gdscript
var retry_delay_seconds: float = 0.0
```

每次重试前等待的秒数。

#### `retry_not_before_msec`

- API: `public`

```gdscript
var retry_not_before_msec: int = 0
```

下次可重试的时间戳，单位毫秒。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目层可附加的任务元数据。

Schemas:

- `metadata`: Dictionary，复制到下载任务中的项目侧元数据。

#### `status`

- API: `public`

```gdscript
var status: Status = Status.QUEUED
```

当前任务状态。

#### `received_bytes`

- API: `public`

```gdscript
var received_bytes: int = 0
```

已接收字节数。

#### `total_bytes`

- API: `public`

```gdscript
var total_bytes: int = -1
```

总字节数；未知时为 -1。

#### `response_code`

- API: `public`

```gdscript
var response_code: int = 0
```

最近一次 HTTP 响应码。

#### `error`

- API: `public`

```gdscript
var error: String = ""
```

失败或取消原因。

### Methods

#### `duplicate_task`

- API: `public`

```gdscript
func duplicate_task() -> GFDownloadTask:
```

创建同内容拷贝。

Returns: 新任务。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

导出任务状态字典。

Returns: 任务字典。

Schemas:

- `return`: Dictionary，包含任务标识、路径、请求头、重试设置、metadata、状态、字节计数、响应码和错误信息。

#### `get_status_name`

- API: `public`

```gdscript
static func get_status_name(value: Status) -> String:
```

获取任务状态名称。

Parameters:

| Name | Description |
|---|---|
| `value` | 任务状态。 |

Returns: 状态名称。

## GFDownloadUtility

- Path: `addons/gf/standard/utilities/io/gf_download_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDownloadUtility: 通用文件下载队列。 提供顺序下载、临时文件提交、可选续传、SHA-256 校验、暂停、取消和诊断快照。

### Signals

#### `download_started`

- API: `public`

```gdscript
signal download_started(task_id: int, task: GFDownloadTask)
```

下载任务开始时发出。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 下载任务句柄。 |
| `task` | 下载任务快照。 |

#### `download_progressed`

- API: `public`

```gdscript
signal download_progressed(task_id: int, received_bytes: int, total_bytes: int)
```

下载进度更新时发出。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 下载任务句柄。 |
| `received_bytes` | 已接收字节数。 |
| `total_bytes` | 总字节数；未知时为 -1。 |

#### `download_completed`

- API: `public`

```gdscript
signal download_completed(task_id: int, result: Dictionary)
```

下载任务成功完成时发出。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 下载任务句柄。 |
| `result` | 下载结果字典。 |

Schemas:

- `result`: Dictionary，包含任务字段、success、cancelled 和可选完成元数据。

#### `download_failed`

- API: `public`

```gdscript
signal download_failed(task_id: int, result: Dictionary)
```

下载任务失败时发出。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 下载任务句柄。 |
| `result` | 下载结果字典。 |

Schemas:

- `result`: Dictionary，包含任务字段、success、cancelled 和错误详情。

#### `download_cancelled`

- API: `public`

```gdscript
signal download_cancelled(task_id: int, result: Dictionary)
```

下载任务被取消时发出。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 下载任务句柄。 |
| `result` | 下载结果字典。 |

Schemas:

- `result`: Dictionary，包含任务字段、success、cancelled 和取消详情。

### Properties

#### `timeout_seconds`

- API: `public`

```gdscript
var timeout_seconds: float = 30.0
```

HTTP 请求超时时间，单位秒。

#### `default_temp_suffix`

- API: `public`

```gdscript
var default_temp_suffix: String = ".download"
```

临时文件后缀。

#### `default_segment_suffix`

- API: `public`

```gdscript
var default_segment_suffix: String = ".segment"
```

分段续传临时文件后缀。

#### `overwrite_existing`

- API: `public`

```gdscript
var overwrite_existing: bool = true
```

目标文件已存在时默认是否覆盖。

#### `emit_progress_interval_seconds`

- API: `public`

```gdscript
var emit_progress_interval_seconds: float = 0.1
```

进度信号最小间隔，单位秒。

#### `default_max_retries`

- API: `public`

```gdscript
var default_max_retries: int = 0
```

默认最大重试次数。

#### `default_retry_delay_seconds`

- API: `public`

```gdscript
var default_retry_delay_seconds: float = 0.0
```

默认重试等待秒数。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化下载队列运行时状态并启用暂停无关处理。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

取消下载、释放 HTTPRequest 并清理运行时状态。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float = 0.0) -> void:
```

驱动下载进度采样。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 为兼容统一 tick 签名而保留的参数。 |

#### `enqueue_download`

- API: `public`

```gdscript
func enqueue_download( url: String, target_path: String, callback: Callable = Callable(), options: Dictionary = {} ) -> int:
```

将下载任务加入队列。

Parameters:

| Name | Description |
|---|---|
| `url` | 下载 URL。 |
| `target_path` | 最终写入路径。 |
| `callback` | 完成、失败或取消时执行的回调，签名为 func(result: Dictionary)。 |
| `options` | 可选参数，支持 headers、resume、overwrite、expected_sha256、metadata、temp_path、segment_path、max_retries、retry_delay_seconds。 |

Returns: 任务句柄；输入无效时返回 0。

Schemas:

- `options`: Dictionary，可包含 headers、resume、overwrite、expected_sha256、metadata、temp_path、segment_path、max_retries 和 retry_delay_seconds。

#### `cancel`

- API: `public`

```gdscript
func cancel(task_id: int, delete_temp: bool = false) -> bool:
```

取消下载任务。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 任务句柄。 |
| `delete_temp` | 是否删除临时文件。 |

Returns: 找到并取消任务时返回 true。

#### `set_paused`

- API: `public`

```gdscript
func set_paused(value: bool) -> void:
```

设置下载队列暂停状态。暂停时不会启动新任务，当前任务会保留临时文件并回到队首。

Parameters:

| Name | Description |
|---|---|
| `value` | 是否暂停。 |

#### `pause`

- API: `public`

```gdscript
func pause() -> void:
```

暂停下载队列。

#### `resume`

- API: `public`

```gdscript
func resume() -> void:
```

恢复下载队列。

#### `is_paused`

- API: `public`

```gdscript
func is_paused() -> bool:
```

检查下载队列是否暂停。

Returns: 暂停时返回 true。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue(cancel_active: bool = false, delete_temp: bool = false) -> void:
```

清空等待队列，可选取消当前任务。

Parameters:

| Name | Description |
|---|---|
| `cancel_active` | 是否取消当前任务。 |
| `delete_temp` | 是否删除临时文件。 |

#### `get_active_task`

- API: `public`

```gdscript
func get_active_task() -> GFDownloadTask:
```

获取当前正在下载的任务拷贝。

Returns: 当前任务；没有任务时返回 null。

#### `get_queued_task_ids`

- API: `public`

```gdscript
func get_queued_task_ids() -> PackedInt32Array:
```

获取等待队列中的任务 ID。

Returns: 任务 ID 列表。

#### `get_result`

- API: `public`

```gdscript
func get_result(task_id: int) -> Dictionary:
```

获取指定任务最近结果。

Parameters:

| Name | Description |
|---|---|
| `task_id` | 任务句柄。 |

Returns: 结果字典；不存在时返回空字典。

Schemas:

- `return`: Dictionary，包含最新任务结果；没有结果时为空字典。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取下载工具诊断快照。

Returns: 诊断快照字典。

Schemas:

- `return`: Dictionary，包含 paused、queued_count、queued_task_ids、active_task 和 result_count。

## GFDragDropUtility

- Path: `addons/gf/standard/input/drag_drop/gf_drag_drop_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFDragDropUtility: 通用拖拽会话与落点匹配工具。 该工具只管理拖拽生命周期、落点注册、命中排序和结果包装。 它不读取输入、不移动节点、不保存业务历史，也不规定具体 UI 或玩法语义。

### Signals

#### `drag_started`

- API: `public`

```gdscript
signal drag_started(session_id: int, drag_type: StringName)
```

拖拽开始时发出。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `drag_type` | 拖拽类型。 |

#### `drag_moved`

- API: `public`

```gdscript
signal drag_moved(session_id: int, position: Vector2, delta: Vector2)
```

拖拽位置更新时发出。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `position` | 当前位置。 |
| `delta` | 本次位移。 |

#### `drag_dropped`

- API: `public`

```gdscript
signal drag_dropped(session_id: int, zone_id: StringName, result: Dictionary)
```

拖拽成功释放到落点时发出。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `zone_id` | 落点 ID。 |
| `result` | 落点返回结果。 |

Schemas:

- `result`: Dictionary，由 drop() 规范化，包含 ok、session_id、zone_id、reason 和可选 value。

#### `drag_drop_rejected`

- API: `public`

```gdscript
signal drag_drop_rejected(session_id: int, reason: StringName)
```

拖拽释放被拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `reason` | 拒绝原因。 |

#### `drag_cancelled`

- API: `public`

```gdscript
signal drag_cancelled(session_id: int)
```

拖拽取消时发出。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |

#### `drop_zone_registered`

- API: `public`

```gdscript
signal drop_zone_registered(zone_id: StringName)
```

落点注册后发出。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |

#### `drop_zone_unregistered`

- API: `public`

```gdscript
signal drop_zone_unregistered(zone_id: StringName)
```

落点注销后发出。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放拖拽工具持有的会话与落点。

#### `register_zone`

- API: `public`

```gdscript
func register_zone(zone: GFDropZone) -> bool:
```

注册落点。

Parameters:

| Name | Description |
|---|---|
| `zone` | 落点规则。 |

Returns: 注册成功返回 true。

#### `register_rect_zone`

- API: `public`

```gdscript
func register_rect_zone( zone_id: StringName, rect: Rect2, accepted_types: PackedStringArray = PackedStringArray(), options: Dictionary = {} ) -> GFDropZone:
```

注册矩形落点。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |
| `rect` | 全局矩形区域。 |
| `accepted_types` | 可接收类型；为空表示不限制。 |
| `options` | 可选参数，支持 priority、enabled、metadata、can_accept、drop。 |

Returns: 注册成功时返回落点，否则返回 null。

Schemas:

- `options`: Dictionary，透传给 GFDropZone.from_rect()。

#### `register_control_zone`

- API: `public`

```gdscript
func register_control_zone( zone_id: StringName, control: Control, accepted_types: PackedStringArray = PackedStringArray(), options: Dictionary = {} ) -> GFDropZone:
```

注册 Control 全局矩形落点。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |
| `control` | 用于读取 get_global_rect() 的 Control。 |
| `accepted_types` | 可接收类型；为空表示不限制。 |
| `options` | 可选参数，支持 priority、enabled、metadata、can_accept、drop。 |

Returns: 注册成功时返回落点，否则返回 null。

Schemas:

- `options`: Dictionary，透传给 GFDropZone.from_control()。

#### `unregister_zone`

- API: `public`

```gdscript
func unregister_zone(zone_id: StringName) -> bool:
```

注销落点。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |

Returns: 找到并移除时返回 true。

#### `get_zone`

- API: `public`

```gdscript
func get_zone(zone_id: StringName) -> GFDropZone:
```

获取落点。

Parameters:

| Name | Description |
|---|---|
| `zone_id` | 落点 ID。 |

Returns: 落点；不存在时返回 null。

#### `clear_zones`

- API: `public`

```gdscript
func clear_zones() -> void:
```

清空落点。

#### `start_drag`

- API: `public`

```gdscript
func start_drag( drag_type: StringName, payload: Variant, position: Vector2, source: Object = null, metadata: Dictionary = {} ) -> int:
```

开始拖拽。

Parameters:

| Name | Description |
|---|---|
| `drag_type` | 拖拽类型。 |
| `payload` | 项目自定义载荷。 |
| `position` | 起始位置。 |
| `source` | 可选来源对象。 |
| `metadata` | 项目自定义元数据。 |

Returns: 会话 ID；失败时返回 -1。

Schemas:

- `payload`: Variant，透传给 drop zone 的项目侧拖拽载荷。
- `metadata`: Dictionary，复制到拖拽会话中的项目侧元数据。

#### `update_drag`

- API: `public`

```gdscript
func update_drag(session_id: int, position: Vector2) -> bool:
```

更新拖拽位置。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `position` | 当前位置。 |

Returns: 更新成功返回 true。

#### `drop`

- API: `public`

```gdscript
func drop(session_id: int, position: Vector2) -> Dictionary:
```

将拖拽释放到当前位置匹配到的最佳落点。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `position` | 释放位置。 |

Returns: 结构化结果字典。

Schemas:

- `return`: Dictionary，包含 ok、session_id、zone_id、reason 和可选 value。

#### `cancel_drag`

- API: `public`

```gdscript
func cancel_drag(session_id: int) -> bool:
```

取消拖拽。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |

Returns: 找到并取消时返回 true。

#### `get_session`

- API: `public`

```gdscript
func get_session(session_id: int) -> GFDragSession:
```

获取会话。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |

Returns: 会话；不存在时返回 null。

#### `has_active_session`

- API: `public`

```gdscript
func has_active_session(session_id: int) -> bool:
```

检查会话是否存在。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |

Returns: 存在时返回 true。

#### `get_drop_candidates`

- API: `public`

```gdscript
func get_drop_candidates( session_id: int, position: Vector2, only_accepting: bool = true ) -> Array[GFDropZone]:
```

获取当前位置命中的落点候选。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `position` | 要检查的位置。 |
| `only_accepting` | 为 true 时只返回当前可接收会话的落点。 |

Returns: 按优先级排序的落点列表。

#### `get_best_drop_zone`

- API: `public`

```gdscript
func get_best_drop_zone(session_id: int, position: Vector2) -> GFDropZone:
```

获取当前位置最佳落点。

Parameters:

| Name | Description |
|---|---|
| `session_id` | 会话 ID。 |
| `position` | 要检查的位置。 |

Returns: 最佳落点；没有可用落点时返回 null。

#### `clear_sessions`

- API: `public`

```gdscript
func clear_sessions() -> void:
```

清空拖拽会话。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 当前拖拽与落点状态。

Schemas:

- `return`: Dictionary，包含 active_session_count、zone_count、sessions: Array[Dictionary] 和 zones: Array[Dictionary]。

## GFDragSession

- Path: `addons/gf/standard/input/drag_drop/gf_drag_session.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFDragSession: 通用拖拽会话数据。 描述一次拖拽从开始到释放的稳定上下文，不绑定具体 UI、背包、棋盘、 关卡编辑器或任何业务对象。项目可把任意 payload 放入会话，再由落点规则解释。

### Properties

#### `session_id`

- API: `public`

```gdscript
var session_id: int = -1
```

会话 ID，由 GFDragDropUtility 分配。

#### `drag_type`

- API: `public`

```gdscript
var drag_type: StringName = &""
```

拖拽类型。落点可用它做通用接收过滤。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

项目自定义载荷。框架不解释该字段。

Schemas:

- `payload`: Variant，透传给 drop zone 的项目侧拖拽载荷。

#### `start_position`

- API: `public`

```gdscript
var start_position: Vector2 = Vector2.ZERO
```

起始位置，通常是屏幕或画布坐标。

#### `current_position`

- API: `public`

```gdscript
var current_position: Vector2 = Vector2.ZERO
```

当前指针位置。

#### `previous_position`

- API: `public`

```gdscript
var previous_position: Vector2 = Vector2.ZERO
```

上一次位置。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架只负责复制和透传。

Schemas:

- `metadata`: Dictionary，复制到拖拽会话中的项目侧元数据。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup( new_session_id: int, new_drag_type: StringName, new_payload: Variant, position: Vector2, source: Object = null, new_metadata: Dictionary = {} ) -> void:
```

初始化会话。

Parameters:

| Name | Description |
|---|---|
| `new_session_id` | 会话 ID。 |
| `new_drag_type` | 拖拽类型。 |
| `new_payload` | 项目自定义载荷。 |
| `position` | 起始位置。 |
| `source` | 可选来源对象。 |
| `new_metadata` | 项目自定义元数据。 |

Schemas:

- `new_payload`: Variant，透传给 drop zone 的项目侧拖拽载荷。
- `new_metadata`: Dictionary，复制到拖拽会话中的项目侧元数据。

#### `update_position`

- API: `public`

```gdscript
func update_position(position: Vector2) -> void:
```

更新当前拖拽位置。

Parameters:

| Name | Description |
|---|---|
| `position` | 新位置。 |

#### `get_delta`

- API: `public`

```gdscript
func get_delta() -> Vector2:
```

获取本次更新的位移。

Returns: 当前和上一次位置的差值。

#### `get_source`

- API: `public`

```gdscript
func get_source() -> Object:
```

获取来源对象。

Returns: 来源仍有效时返回对象，否则返回 null。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为调试字典。

Returns: 会话快照。

Schemas:

- `return`: Dictionary，包含 session_id、drag_type、start_position、current_position、previous_position、delta、has_source 和 metadata。

## GFDropZone

- Path: `addons/gf/standard/input/drag_drop/gf_drop_zone.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFDropZone: 通用拖拽落点规则。 落点只描述“某个位置是否命中、某个会话是否可接收、接收时如何返回结果”。 它不移动节点、不修改业务数据，也不规定任何具体 UI 或玩法语义。

### Properties

#### `zone_id`

- API: `public`

```gdscript
var zone_id: StringName = &""
```

落点 ID。

#### `accepted_types`

- API: `public`

```gdscript
var accepted_types: PackedStringArray = PackedStringArray()
```

可接收的拖拽类型。为空表示不限制类型。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

匹配优先级。数值越大越优先。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用。

#### `contains_callable`

- API: `public`

```gdscript
var contains_callable: Callable = Callable()
```

命中检测回调，签名为 func(position: Variant, session: GFDragSession) -> bool。

#### `can_accept_callable`

- API: `public`

```gdscript
var can_accept_callable: Callable = Callable()
```

可接收检测回调，签名为 func(session: GFDragSession, zone: GFDropZone) -> bool。

#### `drop_callable`

- API: `public`

```gdscript
var drop_callable: Callable = Callable()
```

接收回调，签名为 func(session: GFDragSession, zone: GFDropZone, position: Variant) -> Variant。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，关联到 drop zone 的项目侧元数据。

### Methods

#### `contains`

- API: `public`

```gdscript
func contains(position: Variant, session: GFDragSession) -> bool:
```

检查落点是否包含位置。

Parameters:

| Name | Description |
|---|---|
| `position` | 位置，通常是屏幕或画布坐标。 |
| `session` | 当前拖拽会话。 |

Returns: 命中时返回 true。

Schemas:

- `position`: Variant，zone contains 回调接受的位置值。

#### `can_accept`

- API: `public`

```gdscript
func can_accept(session: GFDragSession) -> bool:
```

检查落点是否接收会话。

Parameters:

| Name | Description |
|---|---|
| `session` | 当前拖拽会话。 |

Returns: 可接收时返回 true。

#### `drop`

- API: `public`

```gdscript
func drop(session: GFDragSession, position: Variant) -> Variant:
```

执行落点接收回调。

Parameters:

| Name | Description |
|---|---|
| `session` | 当前拖拽会话。 |
| `position` | 释放位置。 |

Returns: 回调返回值；未设置回调时返回成功字典。

Schemas:

- `position`: Variant release position passed to the drop callback.
- `return`: Variant，由 drop 回调返回；Dictionary 会由 GFDragDropUtility 规范化。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为调试字典。

Returns: 落点快照。

Schemas:

- `return`: Dictionary，包含 zone_id、accepted_types、priority、enabled、回调标记和 metadata。

#### `from_rect`

- API: `public`

```gdscript
static func from_rect( new_zone_id: StringName, rect: Rect2, new_accepted_types: PackedStringArray = PackedStringArray(), options: Dictionary = {} ) -> GFDropZone:
```

创建矩形落点。

Parameters:

| Name | Description |
|---|---|
| `new_zone_id` | 落点 ID。 |
| `rect` | 全局矩形区域。 |
| `new_accepted_types` | 可接收类型；为空表示不限制。 |
| `options` | 可选参数，支持 priority、enabled、metadata、can_accept、drop。 |

Returns: 新落点。

Schemas:

- `options`: Dictionary，包含 priority: int、enabled: bool、metadata: Dictionary、can_accept: Callable 和 drop: Callable。

#### `from_control`

- API: `public`

```gdscript
static func from_control( new_zone_id: StringName, control: Control, new_accepted_types: PackedStringArray = PackedStringArray(), options: Dictionary = {} ) -> GFDropZone:
```

创建 Control 全局矩形落点。

Parameters:

| Name | Description |
|---|---|
| `new_zone_id` | 落点 ID。 |
| `control` | 用于读取 get_global_rect() 的 Control。 |
| `new_accepted_types` | 可接收类型；为空表示不限制。 |
| `options` | 可选参数，支持 priority、enabled、metadata、can_accept、drop。 |

Returns: 新落点。

Schemas:

- `options`: Dictionary，包含 priority: int、enabled: bool、metadata: Dictionary、can_accept: Callable 和 drop: Callable。

## GFFixedDecimal

- Path: `addons/gf/standard/foundation/numeric/gf_fixed_decimal.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFFixedDecimal: 基于整数缩放的定点小数值对象。 适合处理货币、税率、经营数值等对“累计误差”敏感、 但又不需要无限精度十进制库的场景。

### Enums

#### `RoundingMode`

- API: `public`

```gdscript
enum RoundingMode { ## 四舍五入，0.5 始终朝绝对值更大的方向进位。 HALF_UP, ## 银行家舍入，0.5 时向最近的偶数靠拢。 HALF_EVEN, ## 向负无穷方向取整。 FLOOR, ## 向正无穷方向取整。 CEIL, ## 直接截断，朝 0 逼近。 TRUNCATE, }
```

缩放或除法时使用的舍入策略。

### Constants

#### `MAX_DECIMAL_PLACES`

- API: `public`

```gdscript
const MAX_DECIMAL_PLACES: int = 18
```

定点数可保留的小数位上限，避免整数缩放时溢出。

### Properties

#### `raw_value`

- API: `public`

```gdscript
var raw_value: int = 0
```

实际保存的整数值。

#### `decimal_places`

- API: `public`

```gdscript
var decimal_places: int = 2
```

小数位数。

### Methods

#### `from_int`

- API: `public`

```gdscript
static func from_int(value: int, p_decimal_places: int = 2) -> GFFixedDecimal:
```

从 int 构建定点数。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始整数。 |
| `p_decimal_places` | 目标小数位。 |

Returns: 定点数实例。

#### `from_float`

- API: `public`

```gdscript
static func from_float( value: float, p_decimal_places: int = 2, rounding_mode: RoundingMode = RoundingMode.HALF_UP ) -> GFFixedDecimal:
```

从 float 构建定点数。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始浮点数。 |
| `p_decimal_places` | 目标小数位。 |
| `rounding_mode` | 舍入策略。 |

Returns: 定点数实例。

#### `from_string`

- API: `public`

```gdscript
static func from_string( value: String, p_decimal_places: int = 2, rounding_mode: RoundingMode = RoundingMode.HALF_UP ) -> GFFixedDecimal:
```

从字符串构建定点数。

Parameters:

| Name | Description |
|---|---|
| `value` | 普通十进制字符串。 |
| `p_decimal_places` | 目标小数位。 |
| `rounding_mode` | 舍入策略。 |

Returns: 定点数实例。

#### `clone`

- API: `public`

```gdscript
func clone() -> GFFixedDecimal:
```

克隆当前定点数。

Returns: 内容相同的新实例。

#### `is_zero`

- API: `public`

```gdscript
func is_zero() -> bool:
```

当前值是否为零。

Returns: 为零时返回 true。

#### `abs_value`

- API: `public`

```gdscript
func abs_value() -> GFFixedDecimal:
```

获取绝对值。

Returns: 新的定点数实例。

#### `negated`

- API: `public`

```gdscript
func negated() -> GFFixedDecimal:
```

获取相反数。

Returns: 新的定点数实例。

#### `rescaled`

- API: `public`

```gdscript
func rescaled( target_decimal_places: int, rounding_mode: RoundingMode = RoundingMode.HALF_UP ) -> GFFixedDecimal:
```

重设小数位数。

Parameters:

| Name | Description |
|---|---|
| `target_decimal_places` | 目标小数位数。 |
| `rounding_mode` | 降位时的舍入策略。 |

Returns: 重设后的定点数实例。

#### `compare_to`

- API: `public`

```gdscript
func compare_to(other: GFFixedDecimal) -> int:
```

与另一个定点数比较大小。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个定点数。 |

Returns: 大于返回 1，小于返回 -1，相等返回 0。

#### `add`

- API: `public`

```gdscript
func add(other: GFFixedDecimal) -> GFFixedDecimal:
```

与另一个定点数相加。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个定点数。 |

Returns: 相加结果。

#### `subtract`

- API: `public`

```gdscript
func subtract(other: GFFixedDecimal) -> GFFixedDecimal:
```

与另一个定点数相减。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个定点数。 |

Returns: 相减结果。

#### `multiply`

- API: `public`

```gdscript
func multiply( other: GFFixedDecimal, target_decimal_places: int = -1, rounding_mode: RoundingMode = RoundingMode.HALF_UP ) -> GFFixedDecimal:
```

与另一个定点数相乘。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个定点数。 |
| `target_decimal_places` | 结果小数位；传 -1 时取两者较大值。 |
| `rounding_mode` | 结果降位时的舍入策略。 |

Returns: 相乘结果。

#### `divide`

- API: `public`

```gdscript
func divide( other: GFFixedDecimal, target_decimal_places: int = -1, rounding_mode: RoundingMode = RoundingMode.HALF_UP ) -> GFFixedDecimal:
```

与另一个定点数相除。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个定点数。 |
| `target_decimal_places` | 结果小数位；传 -1 时取两者较大值。 |
| `rounding_mode` | 除法舍入策略。 |

Returns: 相除结果。

#### `to_float`

- API: `public`

```gdscript
func to_float() -> float:
```

转换为 float。

Returns: 浮点值。

#### `to_big_number`

- API: `public`

```gdscript
func to_big_number() -> GFBigNumber:
```

转换为 GFBigNumber。

Returns: 对应的大数值对象。

#### `to_decimal_string`

- API: `public`

```gdscript
func to_decimal_string(trim_zeroes: bool = false) -> String:
```

转换为普通字符串。

Parameters:

| Name | Description |
|---|---|
| `trim_zeroes` | 是否裁掉尾部 0。 |

Returns: 十进制字符串。

## GFFormBinder

- Path: `addons/gf/standard/utilities/ui/gf_form_binder.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFFormBinder: 轻量 Control 表单读写绑定器。 将 StringName 字段映射到 Control 节点，提供批量 read/write 和变化信号。

### Signals

#### `field_changed`

- API: `public`

```gdscript
signal field_changed(key: StringName, value: Variant)
```

字段值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段键。 |
| `value` | 当前控件值。 |

Schemas:

- `value`: Variant，当前控件值，类型取决于绑定控件。

### Methods

#### `bind_field`

- API: `public`

```gdscript
func bind_field(key: StringName, control: Control, default_value: Variant = null) -> void:
```

绑定字段到控件。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段键。 |
| `control` | 控件节点。 |
| `default_value` | 控件失效或读取失败时的默认值。 |

Schemas:

- `default_value`: Variant，控件失效或读取失败时返回的默认值。

#### `unbind_field`

- API: `public`

```gdscript
func unbind_field(key: StringName) -> void:
```

解绑字段。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段键。 |

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有字段绑定。

#### `get_bound_fields`

- API: `public`

```gdscript
func get_bound_fields() -> Array[StringName]:
```

获取绑定字段列表。

Returns: 字段键数组。

#### `get_field_value`

- API: `public`

```gdscript
func get_field_value(key: StringName, fallback: Variant = null) -> Variant:
```

读取单个字段值。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段键。 |
| `fallback` | 回退值。 |

Returns: 字段值。

Schemas:

- `fallback`: Variant，字段未绑定或控件无法读取时返回的回退值。
- `return`: Variant，字段当前值；无法读取时返回 fallback。

#### `set_field_value`

- API: `public`

```gdscript
func set_field_value(key: StringName, value: Variant) -> bool:
```

写入单个字段值。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段键。 |
| `value` | 字段值。 |

Returns: 成功写入时返回 true。

Schemas:

- `value`: Variant，要写入绑定控件的字段值。

#### `read_values`

- API: `public`

```gdscript
func read_values() -> Dictionary:
```

读取全部字段值。

Returns: 字段值字典。

Schemas:

- `return`: Dictionary，键为字段 StringName，值为对应控件当前值。

#### `write_values`

- API: `public`

```gdscript
func write_values(data: Dictionary, ignore_missing_fields: bool = true) -> void:
```

批量写入字段值。

Parameters:

| Name | Description |
|---|---|
| `data` | 字段值字典。 |
| `ignore_missing_fields` | true 时忽略未绑定字段，false 时输出 warning。 |

Schemas:

- `data`: Dictionary，键为字段名，值为要写入绑定控件的字段值。

## GFFormula

- Path: `addons/gf/standard/foundation/formula/gf_formula.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFFormula: 资源化公式基类。 公式是纯计算策略，不持有运行时生命周期。 项目可继承并重写 `calculate()`，也可通过 `calculate_float()`、 `calculate_int()` 和 `calculate_bool()` 获得稳定的类型兜底。

### Properties

#### `fallback_value`

- API: `public`

```gdscript
var fallback_value: Variant = 0.0
```

当子类没有返回有效数值时使用的兜底结果。

Schemas:

- `fallback_value`: Variant default formula result.

### Methods

#### `calculate`

- API: `public`

```gdscript
func calculate(_parameter: GFFormulaParameter = null) -> Variant:
```

执行公式计算。

Parameters:

| Name | Description |
|---|---|
| `_parameter` | 公式参数容器。 |

Returns: 公式结果。子类应重写该方法。

Schemas:

- `return`: Variant formula result.

#### `calculate_float`

- API: `public`

```gdscript
func calculate_float(parameter: GFFormulaParameter = null, fallback: float = 0.0) -> float:
```

以 float 形式执行公式。

Parameters:

| Name | Description |
|---|---|
| `parameter` | 公式参数容器。 |
| `fallback` | 结果无法转为数字时使用的兜底值。 |

Returns: float 结果。

#### `calculate_int`

- API: `public`

```gdscript
func calculate_int(parameter: GFFormulaParameter = null, fallback: int = 0) -> int:
```

以 int 形式执行公式。

Parameters:

| Name | Description |
|---|---|
| `parameter` | 公式参数容器。 |
| `fallback` | 结果无法转为数字时使用的兜底值。 |

Returns: int 结果。

#### `calculate_bool`

- API: `public`

```gdscript
func calculate_bool(parameter: GFFormulaParameter = null, fallback: bool = false) -> bool:
```

以 bool 形式执行公式。

Parameters:

| Name | Description |
|---|---|
| `parameter` | 公式参数容器。 |
| `fallback` | 结果无法转为布尔语义时使用的兜底值。 |

Returns: bool 结果。

## GFFormulaParameter

- Path: `addons/gf/standard/foundation/formula/gf_formula_parameter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFFormulaParameter: 通用公式运行时参数容器。 用于把施放者、目标、上下文对象和临时数值传给资源化公式。 它不规定任何业务字段，项目可通过 `set_value()` 写入自己的参数。

### Properties

#### `source`

- API: `public`

```gdscript
var source: Object = null
```

公式发起者，例如攻击者、购买者、升级主体等。

#### `target`

- API: `public`

```gdscript
var target: Object = null
```

公式目标，例如受击者、被购买对象、被升级对象等。

#### `context`

- API: `public`

```gdscript
var context: Object = null
```

可选上下文对象，通常是系统、规则宿主或临时流程上下文。

#### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

额外参数表。Key 推荐使用 StringName。

Schemas:

- `values`: Dictionary keyed by StringName or String with caller-defined formula values.

### Methods

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> GFFormulaParameter:
```

写入一个参数值。

Parameters:

| Name | Description |
|---|---|
| `key` | 参数键。 |
| `value` | 参数值。 |

Returns: 当前参数容器，便于链式构造。

Schemas:

- `value`: Variant caller-defined formula value.

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取一个参数值。

Parameters:

| Name | Description |
|---|---|
| `key` | 参数键。 |
| `default_value` | 参数不存在时返回的默认值。 |

Returns: 参数值或默认值。

Schemas:

- `default_value`: Variant fallback value returned when key is absent.
- `return`: Variant formula value or fallback.

#### `has_value`

- API: `public`

```gdscript
func has_value(key: StringName) -> bool:
```

检查是否存在指定参数。

Parameters:

| Name | Description |
|---|---|
| `key` | 参数键。 |

Returns: 存在时返回 true。

#### `duplicate_parameter`

- API: `public`

```gdscript
func duplicate_parameter() -> GFFormulaParameter:
```

创建当前参数容器的深拷贝。

Returns: 新的参数容器实例。

## GFFormulaSet

- Path: `addons/gf/standard/foundation/formula/gf_formula_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFFormulaSet: 按键管理资源化公式的轻量集合。 适合把一组项目公式集中到配置资源里，再由 System 或 Utility 按 `StringName` 获取并计算。

### Properties

#### `formulas`

- API: `public`

```gdscript
var formulas: Dictionary = {}
```

公式表。Key 推荐为 StringName，Value 应为 GFFormula。

Schemas:

- `formulas`: Dictionary keyed by StringName or String with GFFormula resources.

### Methods

#### `set_formula`

- API: `public`

```gdscript
func set_formula(formula_id: StringName, formula: GFFormula) -> void:
```

注册或替换一个公式。

Parameters:

| Name | Description |
|---|---|
| `formula_id` | 公式标识。 |
| `formula` | 公式资源。 |

#### `get_formula`

- API: `public`

```gdscript
func get_formula(formula_id: StringName) -> GFFormula:
```

获取一个公式。

Parameters:

| Name | Description |
|---|---|
| `formula_id` | 公式标识。 |

Returns: 公式资源；不存在时返回 null。

#### `has_formula`

- API: `public`

```gdscript
func has_formula(formula_id: StringName) -> bool:
```

检查是否存在指定公式。

Parameters:

| Name | Description |
|---|---|
| `formula_id` | 公式标识。 |

Returns: 存在时返回 true。

#### `calculate`

- API: `public`

```gdscript
func calculate(formula_id: StringName, parameter: GFFormulaParameter = null, fallback: Variant = null) -> Variant:
```

计算指定公式。

Parameters:

| Name | Description |
|---|---|
| `formula_id` | 公式标识。 |
| `parameter` | 公式参数。 |
| `fallback` | 公式不存在时返回的结果。 |

Returns: 公式结果或 fallback。

Schemas:

- `fallback`: Variant result returned when formula_id is absent.
- `return`: Variant formula result or fallback.

## GFGraphLayoutUtility

- Path: `addons/gf/standard/foundation/math/gf_graph_layout_utility.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFGraphLayoutUtility: 通用图布局辅助。 根据节点标识和连接关系生成编辑器坐标。它只产出布局建议， 不依赖 GraphEdit、Resource 或具体业务图类型。

### Methods

#### `make_layered_layout`

- API: `public`

```gdscript
static func make_layered_layout( node_ids: PackedStringArray, connections: Array[Dictionary], options: Dictionary = {} ) -> Dictionary:
```

生成分层布局。

Parameters:

| Name | Description |
|---|---|
| `node_ids` | 节点标识列表。 |
| `connections` | 连接列表，默认读取 from_node_id 与 to_node_id。 |
| `options` | 选项，支持 x_spacing、y_spacing、origin、from_key 与 to_key。 |

Returns: node_id 字符串到 Vector2 的映射。

Schemas:

- `connections`: Array of Dictionary records containing source and target node ids.
- `options`: Dictionary layout options including x_spacing, y_spacing, origin, from_key, and to_key.
- `return`: Dictionary mapping node id strings to Vector2 positions.

#### `make_grid_layout`

- API: `public`

```gdscript
static func make_grid_layout(node_ids: PackedStringArray, options: Dictionary = {}) -> Dictionary:
```

生成简单网格布局。

Parameters:

| Name | Description |
|---|---|
| `node_ids` | 节点标识列表。 |
| `options` | 选项，支持 columns、x_spacing、y_spacing 与 origin。 |

Returns: node_id 字符串到 Vector2 的映射。

Schemas:

- `options`: Dictionary layout options including columns, x_spacing, y_spacing, and origin.
- `return`: Dictionary mapping node id strings to Vector2 positions.

## GFGraphMath

- Path: `addons/gf/standard/foundation/math/gf_graph_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFGraphMath: 面向任意节点类型的纯图搜索算法。 节点可以是 Vector、StringName、Resource、对象引用或项目自定义值。 图结构由回调提供，框架只负责遍历、代价累计和路径重建。

### Methods

#### `find_path_dijkstra`

- API: `public`

```gdscript
static func find_path_dijkstra( start: Variant, goal: Variant, get_neighbors: Callable, get_step_cost: Callable = Callable() ) -> Array[Variant]:
```

使用 Dijkstra 查找一条最低代价路径。

Parameters:

| Name | Description |
|---|---|
| `start` | 起点节点。 |
| `goal` | 终点节点。 |
| `get_neighbors` | 邻居回调，签名为 `func(node: Variant) -> Array`。 |
| `get_step_cost` | 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

Schemas:

- `start`: Variant graph node identity.
- `goal`: Variant graph node identity.
- `return`: Array graph node path from start to goal.

#### `find_path_a_star`

- API: `public`

```gdscript
static func find_path_a_star( start: Variant, goal: Variant, get_neighbors: Callable, get_step_cost: Callable = Callable(), heuristic: Callable = Callable() ) -> Array[Variant]:
```

使用 A* 查找一条低代价路径。

Parameters:

| Name | Description |
|---|---|
| `start` | 起点节点。 |
| `goal` | 终点节点。 |
| `get_neighbors` | 邻居回调，签名为 `func(node: Variant) -> Array`。 |
| `get_step_cost` | 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。 |
| `heuristic` | 可选启发回调，签名为 `func(node: Variant, goal: Variant) -> float`。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

Schemas:

- `start`: Variant graph node identity.
- `goal`: Variant graph node identity.
- `return`: Array graph node path from start to goal.

#### `build_distance_map`

- API: `public`

```gdscript
static func build_distance_map( start: Variant, get_neighbors: Callable, get_step_cost: Callable = Callable(), max_cost: float = INF ) -> Dictionary:
```

从起点生成距离图。

Parameters:

| Name | Description |
|---|---|
| `start` | 起点节点。 |
| `get_neighbors` | 邻居回调，签名为 `func(node: Variant) -> Array`。 |
| `get_step_cost` | 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。 |
| `max_cost` | 最大累计代价，超过后停止扩展。 |

Returns: 字典，键为可达节点，值为从起点到该节点的最低代价。

Schemas:

- `start`: Variant graph node identity.
- `return`: Dictionary mapping reachable graph nodes to lowest float costs.

#### `find_reachable`

- API: `public`

```gdscript
static func find_reachable( start: Variant, max_cost: float, get_neighbors: Callable, get_step_cost: Callable = Callable() ) -> Dictionary:
```

查找指定代价内可达的节点。

Parameters:

| Name | Description |
|---|---|
| `start` | 起点节点。 |
| `max_cost` | 最大累计代价。 |
| `get_neighbors` | 邻居回调，签名为 `func(node: Variant) -> Array`。 |
| `get_step_cost` | 可选代价回调，签名为 `func(from: Variant, to: Variant) -> float`；返回负数表示不可通行。 |

Returns: 字典，键为可达节点，值为从起点到该节点的最低代价。

Schemas:

- `start`: Variant graph node identity.
- `return`: Dictionary mapping reachable graph nodes to lowest float costs.

## GFGrid3DMath

- Path: `addons/gf/standard/foundation/math/gf_grid_3d_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFGrid3DMath: 3D 整数网格的纯算法工具。 提供边界判断、邻居枚举、A* 寻路、可达范围和台阶式表面邻居。 它不依赖 GridMap 或场景节点；可通行、代价和高度规则都由回调注入。

### Methods

#### `is_in_bounds`

- API: `public`

```gdscript
static func is_in_bounds(cell: Vector3i, grid_size: Vector3i) -> bool:
```

判断格子是否在 3D 网格范围内。

Parameters:

| Name | Description |
|---|---|
| `cell` | 待检测格子。 |
| `grid_size` | 网格尺寸，三个轴都必须大于 0。 |

Returns: 在范围内时返回 true。

#### `get_neighbors`

- API: `public`

```gdscript
static func get_neighbors( cell: Vector3i, grid_size: Vector3i, allow_diagonal: bool = false ) -> Array[Vector3i]:
```

获取 3D 网格邻居。

Parameters:

| Name | Description |
|---|---|
| `cell` | 中心格子。 |
| `grid_size` | 网格尺寸。 |
| `allow_diagonal` | 是否包含 26 邻域；否则只包含 6 个正交邻居。 |

Returns: 边界内邻居数组。

#### `get_surface_neighbors`

- API: `public`

```gdscript
static func get_surface_neighbors( cell: Vector3i, grid_size: Vector3i, is_walkable: Callable, max_step_up: int = 1, max_step_down: int = 1, horizontal_directions: Array[Vector3i] = [] ) -> Array[Vector3i]:
```

获取台阶式表面移动邻居。

Parameters:

| Name | Description |
|---|---|
| `cell` | 当前站立格。 |
| `grid_size` | 网格尺寸。 |
| `is_walkable` | 可站立回调，签名为 `func(cell: Vector3i) -> bool`。 |
| `max_step_up` | 单步最多上升高度。 |
| `max_step_down` | 单步最多下降高度。 |
| `horizontal_directions` | 可选水平移动方向；为空时使用 X/Z 四方向。 |

Returns: 可站立的相邻表面格。

#### `find_path_a_star`

- API: `public`

```gdscript
static func find_path_a_star( grid_size: Vector3i, start: Vector3i, goal: Vector3i, is_walkable: Callable, allow_diagonal: bool = false, step_cost: Callable = Callable(), heuristic: StringName = &"manhattan" ) -> Array[Vector3i]:
```

使用 A* 查找 3D 网格路径。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `goal` | 终点格子。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector3i) -> bool`。 |
| `allow_diagonal` | 是否允许 26 邻域移动。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。 |
| `heuristic` | 启发函数名称，支持 `manhattan`、`chebyshev`、`euclidean`。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

#### `find_reachable`

- API: `public`

```gdscript
static func find_reachable( grid_size: Vector3i, start: Vector3i, max_cost: float, is_walkable: Callable, allow_diagonal: bool = false, step_cost: Callable = Callable() ) -> Dictionary:
```

查找指定代价内可达的 3D 网格格子。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `max_cost` | 最大累计代价。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector3i) -> bool`。 |
| `allow_diagonal` | 是否允许 26 邻域移动。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。 |

Returns: 字典，键为可达格子，值为从起点到该格子的最低代价。

Schemas:

- `return`: Dictionary mapping reachable Vector3i cells to lowest float costs.

#### `find_surface_path_a_star`

- API: `public`

```gdscript
static func find_surface_path_a_star( grid_size: Vector3i, start: Vector3i, goal: Vector3i, is_walkable: Callable, max_step_up: int = 1, max_step_down: int = 1, step_cost: Callable = Callable(), heuristic: StringName = &"manhattan" ) -> Array[Vector3i]:
```

使用台阶式表面邻居查找路径。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点站立格。 |
| `goal` | 终点站立格。 |
| `is_walkable` | 可站立回调，签名为 `func(cell: Vector3i) -> bool`。 |
| `max_step_up` | 单步最多上升高度。 |
| `max_step_down` | 单步最多下降高度。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector3i, to: Vector3i) -> float`；返回负数表示不可通行。 |
| `heuristic` | 启发函数名称，支持 `manhattan`、`chebyshev`、`euclidean`。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

## GFGridGenerationPipeline2D

- Path: `addons/gf/standard/foundation/math/gf_grid_generation_pipeline_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFGridGenerationPipeline2D: 通用 2D 网格生成管线。 以候选格子为输入，按步骤输出 `Dictionary[Vector2i, Variant]`。 适合程序化生成的中间数据层，不绑定任何具体节点、资源或玩法类型。

### Properties

#### `steps`

- API: `public`

```gdscript
var steps: Array[GFGridGenerationStep2D] = []
```

生成步骤。

#### `fill_default_value`

- API: `public`

```gdscript
var fill_default_value: bool = false
```

是否在执行步骤前为全部候选格子写入默认值。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

默认值。

Schemas:

- `default_value`: Variant value written before steps when fill_default_value is enabled.

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

管线元数据。

Schemas:

- `metadata`: Dictionary extension metadata for the generation pipeline.

### Methods

#### `make_rect_candidates`

- API: `public`

```gdscript
static func make_rect_candidates(position: Vector2i, size: Vector2i) -> Array[Vector2i]:
```

从矩形范围生成候选格子。

Parameters:

| Name | Description |
|---|---|
| `position` | 范围起点。 |
| `size` | 范围尺寸。 |

Returns: 候选格子。

#### `generate`

- API: `public`

```gdscript
func generate(candidates: Array[Vector2i], context: Dictionary = {}) -> Dictionary:
```

执行生成管线。

Parameters:

| Name | Description |
|---|---|
| `candidates` | 候选格子。 |
| `context` | 项目自定义上下文。 |

Returns: 生成结果字典，key 为 Vector2i。

Schemas:

- `context`: Dictionary project-defined generation context.
- `return`: Dictionary mapping Vector2i cells to generated values.

#### `apply_to_grid`

- API: `public`

```gdscript
func apply_to_grid( grid: Dictionary, candidates: Array[Vector2i], context: Dictionary = {} ) -> Dictionary:
```

在已有网格上执行生成管线。

Parameters:

| Name | Description |
|---|---|
| `grid` | 目标网格字典，key 为 Vector2i。 |
| `candidates` | 候选格子。 |
| `context` | 项目自定义上下文。 |

Returns: 目标网格本身。

Schemas:

- `grid`: Dictionary mapping Vector2i cells to generated values; mutated in place.
- `context`: Dictionary project-defined generation context.
- `return`: Dictionary same grid instance passed to the method.

#### `add_step`

- API: `public`

```gdscript
func add_step(step: GFGridGenerationStep2D) -> void:
```

添加生成步骤。

Parameters:

| Name | Description |
|---|---|
| `step` | 生成步骤。 |

#### `clear_steps`

- API: `public`

```gdscript
func clear_steps() -> void:
```

清空生成步骤。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取诊断快照。

Returns: 诊断字典。

Schemas:

- `return`: Dictionary with step_count, fill_default_value, metadata, and steps.

## GFGridGenerationStep2D

- Path: `addons/gf/standard/foundation/math/gf_grid_generation_step_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFGridGenerationStep2D: 通用 2D 网格生成步骤。 将选择器命中的格子写入或移除一个 Variant 值。它只操作字典数据， 不绑定 TileMap、GridMap、房间、碰撞或具体玩法。

### Properties

#### `step_id`

- API: `public`

```gdscript
var step_id: StringName = &""
```

步骤标识。

#### `selection`

- API: `public`

```gdscript
var selection: GFGridSelection2D = null
```

格子选择器；为空时作用于全部候选格子。

#### `value`

- API: `public`

```gdscript
var value: Variant = true
```

要写入的值。

Schemas:

- `value`: Variant value written to selected cells.

#### `erase_cells`

- API: `public`

```gdscript
var erase_cells: bool = false
```

为 true 时移除选中格子，而不是写入值。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

步骤元数据。

Schemas:

- `metadata`: Dictionary extension metadata for the generation step.

#### `value_callback`

- API: `public`

```gdscript
var value_callback: Callable = Callable()
```

自定义值回调，签名为 func(cell: Vector2i, previous_value: Variant, context: Dictionary) -> Variant。

### Methods

#### `apply`

- API: `public`

```gdscript
func apply( grid: Dictionary, candidates: Array[Vector2i], context: Dictionary = {} ) -> int:
```

应用生成步骤。

Parameters:

| Name | Description |
|---|---|
| `grid` | 目标网格字典，key 为 Vector2i。 |
| `candidates` | 候选格子。 |
| `context` | 项目自定义上下文。 |

Returns: 被修改的格子数量。

Schemas:

- `grid`: Dictionary mapping Vector2i cells to generated values; mutated in place.
- `context`: Dictionary project-defined generation context.

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取步骤诊断快照。

Returns: 诊断字典。

Schemas:

- `return`: Dictionary with step_id, erase_cells, has_selection, has_value_callback, and metadata.

## GFGridKey3D

- Path: `addons/gf/standard/foundation/math/gf_grid_key_3d.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.18.0`

GFGridKey3D: 3D 网格坐标稳定整数键工具。 将有限范围内的 Vector3i 格坐标与方向编号打包成非负 int，并提供反解与 Vector3 位置量化。它只处理坐标编码，不绑定 TileMap、GridMap、渲染或存档格式。

### Constants

#### `COORDINATE_BITS`

- API: `public`

```gdscript
const COORDINATE_BITS: int = 19
```

每个坐标轴使用的位数。

#### `ORIENTATION_BITS`

- API: `public`

```gdscript
const ORIENTATION_BITS: int = 6
```

方向编号使用的位数。

#### `COORDINATE_MIN`

- API: `public`

```gdscript
const COORDINATE_MIN: int = -262144
```

可打包坐标最小值。

#### `COORDINATE_MAX`

- API: `public`

```gdscript
const COORDINATE_MAX: int = 262143
```

可打包坐标最大值。

#### `ORIENTATION_MIN`

- API: `public`

```gdscript
const ORIENTATION_MIN: int = 0
```

可打包方向编号最小值。

#### `ORIENTATION_MAX`

- API: `public`

```gdscript
const ORIENTATION_MAX: int = 63
```

可打包方向编号最大值。

#### `INVALID_KEY`

- API: `public`

```gdscript
const INVALID_KEY: int = -1
```

无效 key 哨兵值。

### Methods

#### `can_pack_cell`

- API: `public`

```gdscript
static func can_pack_cell(cell: Vector3i, orientation: int = 0) -> bool:
```

判断格坐标和方向编号是否能被打包。

Parameters:

| Name | Description |
|---|---|
| `cell` | 3D 格坐标。 |
| `orientation` | 方向编号，范围为 0..63。 |

Returns: 可打包时返回 true。

#### `pack_cell`

- API: `public`

```gdscript
static func pack_cell(cell: Vector3i, orientation: int = 0) -> int:
```

将格坐标和方向编号打包成非负整数 key。

Parameters:

| Name | Description |
|---|---|
| `cell` | 3D 格坐标。 |
| `orientation` | 方向编号，范围为 0..63。 |

Returns: 打包后的 key；输入超出范围时返回 INVALID_KEY。

#### `is_packed_key_valid`

- API: `public`

```gdscript
static func is_packed_key_valid(key: int) -> bool:
```

判断整数是否可能是 GFGridKey3D 生成的 key。

Parameters:

| Name | Description |
|---|---|
| `key` | 待检测 key。 |

Returns: 在有效整数范围内时返回 true。

#### `unpack_cell`

- API: `public`

```gdscript
static func unpack_cell(key: int) -> Vector3i:
```

从 key 反解格坐标。

Parameters:

| Name | Description |
|---|---|
| `key` | 打包 key。 |

Returns: 反解出的格坐标；key 无效时返回 Vector3i.ZERO。

#### `unpack_orientation`

- API: `public`

```gdscript
static func unpack_orientation(key: int) -> int:
```

从 key 反解方向编号。

Parameters:

| Name | Description |
|---|---|
| `key` | 打包 key。 |

Returns: 方向编号；key 无效时返回 -1。

#### `unpack_key`

- API: `public`

```gdscript
static func unpack_key(key: int) -> Dictionary:
```

从 key 反解完整数据字典。

Parameters:

| Name | Description |
|---|---|
| `key` | 打包 key。 |

Returns: Dictionary，包含 valid、cell 和 orientation。

Schemas:

- `return`: Dictionary with valid: bool, cell: Vector3i, and orientation: int.

#### `position_to_cell`

- API: `public`

```gdscript
static func position_to_cell( position: Vector3, cell_size: Vector3 = Vector3.ONE, origin: Vector3 = Vector3.ZERO ) -> Vector3i:
```

将世界位置量化为格坐标。

Parameters:

| Name | Description |
|---|---|
| `position` | 世界或局部位置。 |
| `cell_size` | 单格尺寸，各轴会被限制为正数。 |
| `origin` | 量化原点。 |

Returns: 量化后的格坐标。

#### `pack_position`

- API: `public`

```gdscript
static func pack_position( position: Vector3, cell_size: Vector3 = Vector3.ONE, origin: Vector3 = Vector3.ZERO, orientation: int = 0 ) -> int:
```

将世界位置量化并打包成整数 key。

Parameters:

| Name | Description |
|---|---|
| `position` | 世界或局部位置。 |
| `cell_size` | 单格尺寸，各轴会被限制为正数。 |
| `origin` | 量化原点。 |
| `orientation` | 方向编号，范围为 0..63。 |

Returns: 打包后的 key；量化坐标或方向编号超出范围时返回 INVALID_KEY。

## GFGridMath

- Path: `addons/gf/standard/foundation/math/gf_grid_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFGridMath: 网格类小游戏的纯算法工具。 提供一维索引与二维格坐标转换、邻居枚举、范围、外环、直线、视线、 泛洪搜索、BFS / A* 路径查找、Flow Field 生成以及连连看类“两折连线”判断。 它不依赖 GFArchitecture，可直接在 Model、System、Controller 或测试中静态调用。

### Methods

#### `cell_to_index`

- API: `public`

```gdscript
static func cell_to_index(cell: Vector2i, width: int) -> int:
```

将二维格坐标转换为一维索引。

Parameters:

| Name | Description |
|---|---|
| `cell` | 二维格坐标。 |
| `width` | 网格宽度。 |

Returns: 成功时返回一维索引；宽度无效时返回 -1。

#### `index_to_cell`

- API: `public`

```gdscript
static func index_to_cell(index: int, width: int) -> Vector2i:
```

将一维索引转换为二维格坐标。

Parameters:

| Name | Description |
|---|---|
| `index` | 一维索引。 |
| `width` | 网格宽度。 |

Returns: 成功时返回二维格坐标；参数无效时返回 Vector2i(-1, -1)。

#### `is_in_bounds`

- API: `public`

```gdscript
static func is_in_bounds(cell: Vector2i, grid_size: Vector2i) -> bool:
```

判断格坐标是否位于网格范围内。

Parameters:

| Name | Description |
|---|---|
| `cell` | 二维格坐标。 |
| `grid_size` | 网格尺寸。 |

Returns: 在范围内返回 true。

#### `get_neighbors`

- API: `public`

```gdscript
static func get_neighbors( cell: Vector2i, grid_size: Vector2i, include_diagonal: bool = false ) -> Array[Vector2i]:
```

获取指定格子的邻居。

Parameters:

| Name | Description |
|---|---|
| `cell` | 中心格子。 |
| `grid_size` | 网格尺寸。 |
| `include_diagonal` | 是否包含四个斜向邻居。 |

Returns: 位于网格范围内的邻居列表。

#### `get_rectangle_cells`

- API: `public`
- Since: `3.20.0`

```gdscript
static func get_rectangle_cells( from_cell: Vector2i, to_cell: Vector2i, grid_size: Vector2i = Vector2i(-1, -1) ) -> Array[Vector2i]:
```

获取两个端点之间的矩形格子。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 第一个端点。 |
| `to_cell` | 第二个端点。 |
| `grid_size` | 可选网格尺寸；任一轴小于 0 时不按边界过滤。 |

Returns: 矩形内坐标列表，包含两个端点，按 y/x 稳定顺序返回。

#### `get_range`

- API: `public`
- Since: `3.20.0`

```gdscript
static func get_range( center: Vector2i, radius: int, grid_size: Vector2i = Vector2i(-1, -1), include_diagonal: bool = false ) -> Array[Vector2i]:
```

获取指定半径内的所有格子。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心格子。 |
| `radius` | 半径。 |
| `grid_size` | 可选网格尺寸；任一轴小于 0 时不按边界过滤。 |
| `include_diagonal` | 为 false 时使用曼哈顿范围；为 true 时使用切比雪夫范围。 |

Returns: 半径内坐标列表，包含中心，按 y/x 稳定顺序返回。

#### `get_ring`

- API: `public`
- Since: `3.20.0`

```gdscript
static func get_ring( center: Vector2i, radius: int, grid_size: Vector2i = Vector2i(-1, -1), include_diagonal: bool = false ) -> Array[Vector2i]:
```

获取指定半径的外环格子。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心格子。 |
| `radius` | 半径；0 时返回中心。 |
| `grid_size` | 可选网格尺寸；任一轴小于 0 时不按边界过滤。 |
| `include_diagonal` | 为 false 时使用曼哈顿外环；为 true 时使用切比雪夫外环。 |

Returns: 外环坐标列表，按 y/x 稳定顺序返回。

#### `get_line`

- API: `public`
- Since: `3.20.0`

```gdscript
static func get_line(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
```

获取连接两个格子的 Bresenham 直线。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 起点格子。 |
| `to_cell` | 终点格子。 |

Returns: 坐标列表，包含起点与终点。

#### `has_line_of_sight`

- API: `public`
- Since: `3.20.0`

```gdscript
static func has_line_of_sight( from_cell: Vector2i, to_cell: Vector2i, is_blocking: Callable, include_endpoints: bool = false ) -> bool:
```

判断两格之间是否有视线。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 起点格子。 |
| `to_cell` | 终点格子。 |
| `is_blocking` | 阻挡回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `include_endpoints` | 是否检查起点与终点是否阻挡。 |

Returns: 没有阻挡时返回 true；阻挡回调无效时也返回 true。

#### `flood_fill`

- API: `public`

```gdscript
static func flood_fill( grid_size: Vector2i, start: Vector2i, is_match: Callable, include_diagonal: bool = false ) -> Array[Vector2i]:
```

从起点执行泛洪搜索，返回所有满足匹配条件且连通的格子。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `is_match` | 匹配回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `include_diagonal` | 是否允许斜向连通。 |

Returns: 连通格子列表。

#### `find_path_bfs`

- API: `public`

```gdscript
static func find_path_bfs( grid_size: Vector2i, start: Vector2i, goal: Vector2i, is_walkable: Callable, allow_diagonal: bool = false ) -> Array[Vector2i]:
```

使用 BFS 查找一条最短路径。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `goal` | 终点格子。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `allow_diagonal` | 是否允许斜向移动。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

#### `find_path_a_star`

- API: `public`

```gdscript
static func find_path_a_star( grid_size: Vector2i, start: Vector2i, goal: Vector2i, is_walkable: Callable, allow_diagonal: bool = false, step_cost: Callable = Callable(), heuristic: StringName = &"manhattan" ) -> Array[Vector2i]:
```

使用 A* 查找一条低代价路径。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `goal` | 终点格子。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `allow_diagonal` | 是否允许斜向移动。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector2i, to: Vector2i) -> float`；返回负数表示不可通行。 |
| `heuristic` | 启发函数名称，支持 `manhattan`、`chebyshev`、`octile`、`euclidean`。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

#### `build_flow_field`

- API: `public`

```gdscript
static func build_flow_field( grid_size: Vector2i, goals: Array[Vector2i], is_walkable: Callable, allow_diagonal: bool = false, step_cost: Callable = Callable() ) -> Dictionary:
```

从一个或多个目标格生成 Flow Field。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `goals` | 目标格列表。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `allow_diagonal` | 是否允许斜向移动。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector2i, to: Vector2i) -> float`；返回负数表示不可通行。 |

Returns: 包含 `costs`、`directions` 和 `goals` 的字典；`directions[cell]` 是下一步方向。

Schemas:

- `return`: Dictionary with `costs: Dictionary[Vector2i, float]`, `directions: Dictionary[Vector2i, Vector2i]`, and `goals: Array[Vector2i]`.

#### `can_connect_with_max_turns`

- API: `public`

```gdscript
static func can_connect_with_max_turns( grid_size: Vector2i, start: Vector2i, goal: Vector2i, is_walkable: Callable, max_turns: int = 2, allow_outer_border: bool = true ) -> bool:
```

判断两个格子是否能在指定转折次数内连通。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸。 |
| `start` | 起点格子。 |
| `goal` | 终点格子。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`；起点与终点可不通行。 |
| `max_turns` | 最大转折次数，连连看常用值为 2。 |
| `allow_outer_border` | 是否允许路径经过网格外一圈虚拟空格。 |

Returns: 可连通时返回 true。

## GFGridOccupancy

- Path: `addons/gf/standard/foundation/math/gf_grid_occupancy.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFGridOccupancy: 网格占用与预约数据结构。 适合格子移动、战棋、推箱子和解谜类玩法在 System 中跟踪运行时占用。 它不负责路径查找、碰撞或胜负规则。

### Signals

#### `cell_occupied`

- API: `public`

```gdscript
signal cell_occupied(receiver: Variant, cell: Vector2i)
```

接收者占用格子时发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `cell_released`

- API: `public`

```gdscript
signal cell_released(receiver: Variant, cell: Vector2i)
```

接收者释放格子时发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `cell_reserved`

- API: `public`

```gdscript
signal cell_reserved(receiver: Variant, cell: Vector2i)
```

接收者预约格子时发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `reservation_released`

- API: `public`

```gdscript
signal reservation_released(receiver: Variant, cell: Vector2i)
```

接收者释放预约时发出。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

### Properties

#### `grid_size`

- API: `public`

```gdscript
var grid_size: Vector2i = Vector2i.ZERO
```

网格尺寸。小于等于 0 的维度会让所有格子视为越界。

#### `max_occupants_per_cell`

- API: `public`

```gdscript
var max_occupants_per_cell: int = 1
```

单格允许的最大占用数量。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_grid_size: Vector2i, p_max_occupants_per_cell: int = 1) -> void:
```

设置网格参数并清空占用。

Parameters:

| Name | Description |
|---|---|
| `p_grid_size` | 网格尺寸。 |
| `p_max_occupants_per_cell` | 单格最大占用数量。 |

#### `is_in_bounds`

- API: `public`

```gdscript
func is_in_bounds(cell: Vector2i) -> bool:
```

检查格子是否在边界内。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 在边界内返回 true。

#### `can_occupy`

- API: `public`

```gdscript
func can_occupy(receiver: Variant, cell: Vector2i) -> bool:
```

检查接收者是否可以占用格子。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Returns: 可占用时返回 true。

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `occupy`

- API: `public`

```gdscript
func occupy(receiver: Variant, cell: Vector2i) -> bool:
```

占用格子。接收者若已占用其他格子，会先释放旧格子。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Returns: 成功时返回 true。

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `release`

- API: `public`

```gdscript
func release(receiver: Variant) -> void:
```

释放接收者当前占用。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `release_cell`

- API: `public`

```gdscript
func release_cell(cell: Vector2i) -> void:
```

释放指定格子的所有占用。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

#### `reserve_cell`

- API: `public`

```gdscript
func reserve_cell(receiver: Variant, cell: Vector2i) -> bool:
```

预约格子，防止其他接收者抢占。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |
| `cell` | 格子坐标。 |

Returns: 成功时返回 true。

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `confirm_reservation`

- API: `public`

```gdscript
func confirm_reservation(receiver: Variant) -> bool:
```

将接收者预约确认成占用。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |

Returns: 成功时返回 true。

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `release_reservation`

- API: `public`

```gdscript
func release_reservation(receiver: Variant) -> void:
```

释放接收者预约。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `is_cell_occupied`

- API: `public`

```gdscript
func is_cell_occupied(cell: Vector2i) -> bool:
```

检查格子是否有占用。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 有占用时返回 true。

#### `is_cell_reserved`

- API: `public`

```gdscript
func is_cell_reserved(cell: Vector2i) -> bool:
```

检查格子是否被预约。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 被预约时返回 true。

#### `get_cell_occupants`

- API: `public`

```gdscript
func get_cell_occupants(cell: Vector2i) -> Array[Variant]:
```

获取格子中的所有接收者。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 接收者数组。

Schemas:

- `return`: Array receiver values restored from occupancy records.

#### `get_cell_occupant`

- API: `public`

```gdscript
func get_cell_occupant(cell: Vector2i) -> Variant:
```

获取格子中的第一个接收者。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 接收者；不存在时返回 null。

Schemas:

- `return`: Variant receiver value restored from the occupancy record.

#### `get_receiver_cell`

- API: `public`

```gdscript
func get_receiver_cell(receiver: Variant) -> Vector2i:
```

获取接收者当前占用格。

Parameters:

| Name | Description |
|---|---|
| `receiver` | 接收者。 |

Returns: 格子坐标；未占用时返回 Vector2i(-1, -1)。

Schemas:

- `receiver`: Variant receiver identity stored by value or weak Object reference.

#### `prune_invalid_receivers`

- API: `public`

```gdscript
func prune_invalid_receivers() -> void:
```

清理已释放 Object 接收者。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空占用和预约。

## GFGridPlaneMapper3D

- Path: `addons/gf/standard/foundation/math/gf_grid_plane_mapper_3d.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.18.0`

GFGridPlaneMapper3D: 3D 轴对齐平面与 2D 邻域坐标映射工具。 将 axis-aligned 3D 表面上的格坐标映射为局部 2D 坐标，并可按 2D offset 采样邻域值。它只处理坐标和回调取值，不绑定 TileSet、GridMap、碰撞或玩法语义。

### Constants

#### `DEFAULT_CARDINAL_OFFSETS`

- API: `public`

```gdscript
const DEFAULT_CARDINAL_OFFSETS: Array[Vector2i] = [
```

默认四邻域 offset 顺序：上、右、下、左。

### Methods

#### `is_axis_aligned_normal`

- API: `public`

```gdscript
static func is_axis_aligned_normal(normal: Vector3i) -> bool:
```

判断 normal 是否能表示单轴方向。

Parameters:

| Name | Description |
|---|---|
| `normal` | 3D 平面法线。 |

Returns: normal 只有一个非零轴时返回 true。

#### `normalize_axis_normal`

- API: `public`

```gdscript
static func normalize_axis_normal(normal: Vector3i) -> Vector3i:
```

将单轴 normal 归一化为 -1/1 法线。

Parameters:

| Name | Description |
|---|---|
| `normal` | 3D 平面法线。 |

Returns: 归一化法线；无效 normal 返回 Vector3i.ZERO。

#### `get_plane_basis`

- API: `public`

```gdscript
static func get_plane_basis(normal: Vector3i) -> Dictionary:
```

获取轴对齐平面的局部基向量。

Parameters:

| Name | Description |
|---|---|
| `normal` | 3D 平面法线。 |

Returns: Dictionary，包含 valid、normal、u、v。

Schemas:

- `return`: Dictionary with valid: bool, normal: Vector3i, u: Vector3i, and v: Vector3i.

#### `map_cell_to_plane`

- API: `public`

```gdscript
static func map_cell_to_plane(cell: Vector3i, origin: Vector3i, normal: Vector3i) -> Vector2i:
```

将 3D 格坐标映射为平面局部 2D 坐标。

Parameters:

| Name | Description |
|---|---|
| `cell` | 3D 格坐标。 |
| `origin` | 平面局部原点。 |
| `normal` | 3D 平面法线。 |

Returns: 局部 2D 坐标；normal 无效时返回 Vector2i.ZERO。

#### `map_plane_to_cell`

- API: `public`

```gdscript
static func map_plane_to_cell( plane_cell: Vector2i, origin: Vector3i, normal: Vector3i, depth: int = 0 ) -> Vector3i:
```

将平面局部 2D 坐标映射为 3D 格坐标。

Parameters:

| Name | Description |
|---|---|
| `plane_cell` | 局部 2D 坐标。 |
| `origin` | 平面局部原点。 |
| `normal` | 3D 平面法线。 |
| `depth` | 沿 normal 的偏移层数。 |

Returns: 3D 格坐标；normal 无效时返回 origin。

#### `get_cell_depth`

- API: `public`

```gdscript
static func get_cell_depth(cell: Vector3i, origin: Vector3i, normal: Vector3i) -> int:
```

获取格坐标相对平面的深度。

Parameters:

| Name | Description |
|---|---|
| `cell` | 3D 格坐标。 |
| `origin` | 平面局部原点。 |
| `normal` | 3D 平面法线。 |

Returns: 沿 normal 的偏移层数；normal 无效时返回 0。

#### `get_neighbor_cells`

- API: `public`

```gdscript
static func get_neighbor_cells(center: Vector3i, normal: Vector3i, offsets: Array[Vector2i] = []) -> Array[Vector3i]:
```

按 2D offset 获取同一平面上的 3D 邻居格。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心 3D 格坐标。 |
| `normal` | 3D 平面法线。 |
| `offsets` | 局部 2D offset；为空时使用 DEFAULT_CARDINAL_OFFSETS。 |

Returns: 3D 邻居格列表。

#### `sample_neighbor_values`

- API: `public`

```gdscript
static func sample_neighbor_values( center: Vector3i, normal: Vector3i, value_getter: Callable, offsets: Array[Vector2i] = [], fallback_value: Variant = null ) -> Array:
```

按 2D offset 采样同一平面上的 3D 邻域值。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心 3D 格坐标。 |
| `normal` | 3D 平面法线。 |
| `value_getter` | 取值回调，签名为 func(cell: Vector3i) -> Variant。 |
| `offsets` | 局部 2D offset；为空时使用 DEFAULT_CARDINAL_OFFSETS。 |
| `fallback_value` | 回调无效时填充的值。 |

Returns: 邻域值列表。

Schemas:

- `fallback_value`: Variant used for each neighbor when value_getter is invalid.
- `return`: Array ordered neighbor values sampled from mapped 3D cells.

## GFGridSelection2D

- Path: `addons/gf/standard/foundation/math/gf_grid_selection_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFGridSelection2D: 通用 2D 网格格子选择器。 从候选格子中筛选一批坐标。可通过显式包含/排除、矩形边界、 自定义回调或子类重写组合出项目自己的生成规则。

### Properties

#### `included_cells`

- API: `public`

```gdscript
var included_cells: Array[Vector2i] = []
```

显式包含的格子；为空时不限制。

#### `excluded_cells`

- API: `public`

```gdscript
var excluded_cells: Array[Vector2i] = []
```

显式排除的格子。

#### `use_bounds`

- API: `public`

```gdscript
var use_bounds: bool = false
```

是否启用矩形边界过滤。

#### `bounds_position`

- API: `public`

```gdscript
var bounds_position: Vector2i = Vector2i.ZERO
```

边界起点。

#### `bounds_size`

- API: `public`

```gdscript
var bounds_size: Vector2i = Vector2i.ZERO
```

边界尺寸。

#### `invert`

- API: `public`

```gdscript
var invert: bool = false
```

是否反转最终选择结果。

#### `filter_callback`

- API: `public`

```gdscript
var filter_callback: Callable = Callable()
```

自定义过滤回调，签名为 func(cell: Vector2i, context: Dictionary) -> bool。

### Methods

#### `select_cells`

- API: `public`

```gdscript
func select_cells(candidates: Array[Vector2i], context: Dictionary = {}) -> Array[Vector2i]:
```

从候选格子中选择坐标。

Parameters:

| Name | Description |
|---|---|
| `candidates` | 候选格子。 |
| `context` | 项目自定义上下文。 |

Returns: 选中的格子。

Schemas:

- `context`: Dictionary project-defined selection context.

#### `matches_cell`

- API: `public`

```gdscript
func matches_cell(cell: Vector2i, context: Dictionary = {}) -> bool:
```

检查格子是否会被选择。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |
| `context` | 项目自定义上下文。 |

Returns: 会被选择时返回 true。

Schemas:

- `context`: Dictionary project-defined selection context.

## GFHexGridMath

- Path: `addons/gf/standard/foundation/math/gf_hex_grid_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFHexGridMath: 六边形网格的纯算法工具。 提供 offset / cube 坐标转换、邻居枚举、距离、范围、环、直线、视线、 A* 路径查找和 Flow Field 生成。它不依赖 GFArchitecture，可直接在 Model、System、Controller 或测试中静态调用。

### Enums

#### `OffsetLayout`

- API: `public`

```gdscript
enum OffsetLayout { ## 奇数行右偏移，常用于 pointy-top 横向行布局。 ODD_R, ## 偶数行右偏移，常用于 pointy-top 横向行布局。 EVEN_R, ## 奇数列下偏移，常用于 flat-top 纵向列布局。 ODD_Q, ## 偶数列下偏移，常用于 flat-top 纵向列布局。 EVEN_Q, }
```

Offset 坐标布局。

#### `HexOrientation`

- API: `public`

```gdscript
enum HexOrientation { ## 尖顶朝上。 POINTY_TOP, ## 平顶朝上。 FLAT_TOP, }
```

像素坐标换算时使用的六边形朝向。

### Constants

#### `SQRT_3`

- API: `public`

```gdscript
const SQRT_3: float = 1.7320508075688772
```

根号 3 的缓存值，用于六边形像素坐标换算。

#### `DEFAULT_HEX_SIZE`

- API: `public`

```gdscript
const DEFAULT_HEX_SIZE: float = 32.0
```

默认六边形外接圆半径。

### Methods

#### `is_in_bounds`

- API: `public`

```gdscript
static func is_in_bounds(cell: Vector2i, grid_size: Vector2i) -> bool:
```

判断 offset 坐标是否位于网格范围内。

Parameters:

| Name | Description |
|---|---|
| `cell` | offset 坐标。 |
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |

Returns: 在范围内返回 true。

#### `offset_to_cube`

- API: `public`

```gdscript
static func offset_to_cube(cell: Vector2i, layout: OffsetLayout = OffsetLayout.ODD_R) -> Vector3i:
```

将 offset 坐标转换为 cube 坐标。

Parameters:

| Name | Description |
|---|---|
| `cell` | offset 坐标。 |
| `layout` | offset 坐标布局。 |

Returns: cube 坐标；满足 x + y + z == 0。

#### `cube_to_offset`

- API: `public`

```gdscript
static func cube_to_offset(cube: Vector3i, layout: OffsetLayout = OffsetLayout.ODD_R) -> Vector2i:
```

将 cube 坐标转换为 offset 坐标。

Parameters:

| Name | Description |
|---|---|
| `cube` | cube 坐标。 |
| `layout` | offset 坐标布局。 |

Returns: offset 坐标。

#### `cube_round`

- API: `public`

```gdscript
static func cube_round(cube: Vector3) -> Vector3i:
```

四舍五入浮点 cube 坐标。

Parameters:

| Name | Description |
|---|---|
| `cube` | 浮点 cube 坐标。 |

Returns: 最近的整数 cube 坐标；满足 x + y + z == 0。

#### `offset_to_pixel`

- API: `public`

```gdscript
static func offset_to_pixel( cell: Vector2i, hex_size: float = DEFAULT_HEX_SIZE, layout: OffsetLayout = OffsetLayout.ODD_R, orientation: HexOrientation = HexOrientation.POINTY_TOP ) -> Vector2:
```

将 offset 坐标转换为像素中心点。

Parameters:

| Name | Description |
|---|---|
| `cell` | offset 坐标。 |
| `hex_size` | 六边形外接圆半径。 |
| `layout` | offset 坐标布局。 |
| `orientation` | 六边形朝向。 |

Returns: 像素中心点。

#### `pixel_to_offset`

- API: `public`

```gdscript
static func pixel_to_offset( pixel: Vector2, hex_size: float = DEFAULT_HEX_SIZE, layout: OffsetLayout = OffsetLayout.ODD_R, orientation: HexOrientation = HexOrientation.POINTY_TOP ) -> Vector2i:
```

将像素坐标转换为最近的 offset 坐标。

Parameters:

| Name | Description |
|---|---|
| `pixel` | 像素坐标。 |
| `hex_size` | 六边形外接圆半径。 |
| `layout` | offset 坐标布局。 |
| `orientation` | 六边形朝向。 |

Returns: 最近的 offset 坐标。

#### `cube_to_pixel`

- API: `public`

```gdscript
static func cube_to_pixel( cube: Vector3i, hex_size: float = DEFAULT_HEX_SIZE, orientation: HexOrientation = HexOrientation.POINTY_TOP ) -> Vector2:
```

将 cube 坐标转换为像素中心点。

Parameters:

| Name | Description |
|---|---|
| `cube` | cube 坐标。 |
| `hex_size` | 六边形外接圆半径。 |
| `orientation` | 六边形朝向。 |

Returns: 像素中心点。

#### `pixel_to_cube`

- API: `public`

```gdscript
static func pixel_to_cube( pixel: Vector2, hex_size: float = DEFAULT_HEX_SIZE, orientation: HexOrientation = HexOrientation.POINTY_TOP ) -> Vector3i:
```

将像素坐标转换为最近的 cube 坐标。

Parameters:

| Name | Description |
|---|---|
| `pixel` | 像素坐标。 |
| `hex_size` | 六边形外接圆半径。 |
| `orientation` | 六边形朝向。 |

Returns: 最近的 cube 坐标。

#### `get_polygon_points`

- API: `public`

```gdscript
static func get_polygon_points( hex_size: float = DEFAULT_HEX_SIZE, orientation: HexOrientation = HexOrientation.POINTY_TOP ) -> PackedVector2Array:
```

获取六边形顶点相对坐标。

Parameters:

| Name | Description |
|---|---|
| `hex_size` | 六边形外接圆半径。 |
| `orientation` | 六边形朝向。 |

Returns: 顶点数组，按顺时针排列。

#### `get_neighbors`

- API: `public`

```gdscript
static func get_neighbors( cell: Vector2i, grid_size: Vector2i = Vector2i(-1, -1), layout: OffsetLayout = OffsetLayout.ODD_R ) -> Array[Vector2i]:
```

获取指定 offset 坐标的邻居。

Parameters:

| Name | Description |
|---|---|
| `cell` | 中心坐标。 |
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `layout` | offset 坐标布局。 |

Returns: 位于网格范围内的邻居列表。

#### `distance`

- API: `public`

```gdscript
static func distance( from_cell: Vector2i, to_cell: Vector2i, layout: OffsetLayout = OffsetLayout.ODD_R ) -> int:
```

计算两个 offset 坐标之间的六边形距离。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 起点坐标。 |
| `to_cell` | 终点坐标。 |
| `layout` | offset 坐标布局。 |

Returns: 六边形步数距离。

#### `cube_distance`

- API: `public`

```gdscript
static func cube_distance(from_cube: Vector3i, to_cube: Vector3i) -> int:
```

计算两个 cube 坐标之间的六边形距离。

Parameters:

| Name | Description |
|---|---|
| `from_cube` | 起点 cube 坐标。 |
| `to_cube` | 终点 cube 坐标。 |

Returns: 六边形步数距离。

#### `get_range`

- API: `public`

```gdscript
static func get_range( center: Vector2i, radius: int, grid_size: Vector2i = Vector2i(-1, -1), layout: OffsetLayout = OffsetLayout.ODD_R ) -> Array[Vector2i]:
```

获取指定半径内的所有 offset 坐标。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心坐标。 |
| `radius` | 半径。 |
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `layout` | offset 坐标布局。 |

Returns: 半径内坐标列表，包含中心。

#### `get_ring`

- API: `public`

```gdscript
static func get_ring( center: Vector2i, radius: int, grid_size: Vector2i = Vector2i(-1, -1), layout: OffsetLayout = OffsetLayout.ODD_R ) -> Array[Vector2i]:
```

获取指定半径的外环坐标。

Parameters:

| Name | Description |
|---|---|
| `center` | 中心坐标。 |
| `radius` | 半径；0 时返回中心。 |
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `layout` | offset 坐标布局。 |

Returns: 外环坐标列表。

#### `get_line`

- API: `public`

```gdscript
static func get_line( from_cell: Vector2i, to_cell: Vector2i, layout: OffsetLayout = OffsetLayout.ODD_R ) -> Array[Vector2i]:
```

获取连接两个 offset 坐标的六边形直线。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 起点坐标。 |
| `to_cell` | 终点坐标。 |
| `layout` | offset 坐标布局。 |

Returns: 坐标列表，包含起点与终点。

#### `has_line_of_sight`

- API: `public`

```gdscript
static func has_line_of_sight( from_cell: Vector2i, to_cell: Vector2i, is_blocking: Callable, layout: OffsetLayout = OffsetLayout.ODD_R, include_endpoints: bool = false ) -> bool:
```

判断两点之间是否有视线。

Parameters:

| Name | Description |
|---|---|
| `from_cell` | 起点坐标。 |
| `to_cell` | 终点坐标。 |
| `is_blocking` | 阻挡回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `layout` | offset 坐标布局。 |
| `include_endpoints` | 是否检查起点与终点是否阻挡。 |

Returns: 没有阻挡时返回 true。

#### `find_path_a_star`

- API: `public`

```gdscript
static func find_path_a_star( grid_size: Vector2i, start: Vector2i, goal: Vector2i, is_walkable: Callable, layout: OffsetLayout = OffsetLayout.ODD_R, step_cost: Callable = Callable() ) -> Array[Vector2i]:
```

使用 A* 查找一条六边形路径。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `start` | 起点坐标。 |
| `goal` | 终点坐标。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `layout` | offset 坐标布局。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector2i, to: Vector2i) -> float`；返回负数表示不可通行。 |

Returns: 包含起点与终点的路径；无法到达时返回空数组。

#### `build_flow_field`

- API: `public`

```gdscript
static func build_flow_field( grid_size: Vector2i, goals: Array[Vector2i], is_walkable: Callable, layout: OffsetLayout = OffsetLayout.ODD_R, step_cost: Callable = Callable() ) -> Dictionary:
```

从一个或多个目标格生成六边形 Flow Field。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `goals` | 目标坐标列表。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `layout` | offset 坐标布局。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector2i, to: Vector2i) -> float`；返回负数表示不可通行。 |

Returns: 包含 `costs`、`directions` 和 `goals` 的字典；`directions[cell]` 是下一步 offset 方向。

Schemas:

- `return`: Dictionary with `costs: Dictionary[Vector2i, float]`, `directions: Dictionary[Vector2i, Vector2i]`, and `goals: Array[Vector2i]`.

#### `find_reachable`

- API: `public`

```gdscript
static func find_reachable( grid_size: Vector2i, start: Vector2i, max_cost: float, is_walkable: Callable, layout: OffsetLayout = OffsetLayout.ODD_R, step_cost: Callable = Callable() ) -> Dictionary:
```

查找移动代价限制内的可达坐标。

Parameters:

| Name | Description |
|---|---|
| `grid_size` | 网格尺寸；任一轴小于 0 时视为无限网格。 |
| `start` | 起点坐标。 |
| `max_cost` | 最大移动代价。 |
| `is_walkable` | 可通行回调，签名为 `func(cell: Vector2i) -> bool`。 |
| `layout` | offset 坐标布局。 |
| `step_cost` | 可选代价回调，签名为 `func(from: Vector2i, to: Vector2i) -> float`；返回负数表示不可通行。 |

Returns: 字典，key 为可达坐标，value 为从起点到该坐标的最低代价。

Schemas:

- `return`: Dictionary[Vector2i, float] mapping each reachable cell to its lowest travel cost from `start`.

## GFHttpRequestBuilder

- Path: `addons/gf/standard/utilities/io/gf_http_request_builder.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHttpRequestBuilder: 通用 HTTP 请求构建器。 负责整理 URL、query、headers、body、timeout 和响应解析策略。 它只封装 Godot HTTPRequest 的通用流程，不内置任何具体服务、鉴权或业务接口。

### Enums

#### `Method`

- API: `public`

```gdscript
enum Method { ## HTTP GET。 GET, ## HTTP POST。 POST, ## HTTP PUT。 PUT, ## HTTP PATCH。 PATCH, ## HTTP DELETE。 DELETE, ## HTTP HEAD。 HEAD, }
```

HTTP 请求方法。

#### `ParseMode`

- API: `public`

```gdscript
enum ParseMode { ## 不解析响应体。 NONE, ## 按 UTF-8 文本解析。 TEXT, ## 按 JSON 解析。 JSON, }
```

响应体解析模式。

### Properties

#### `url`

- API: `public`

```gdscript
var url: String = ""
```

请求 URL。

#### `method`

- API: `public`

```gdscript
var method: Method = Method.GET
```

HTTP 方法。

#### `parse_mode`

- API: `public`

```gdscript
var parse_mode: ParseMode = ParseMode.TEXT
```

响应解析模式。

#### `timeout_seconds`

- API: `public`

```gdscript
var timeout_seconds: float = 20.0
```

请求超时时间，单位秒。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据，会复制到 GFHttpResponse。

Schemas:

- `metadata`: Dictionary，复制到 GFHttpResponse 的调用方元数据。

### Methods

#### `set_url`

- API: `public`

```gdscript
func set_url(next_url: String) -> GFHttpRequestBuilder:
```

设置请求 URL。

Parameters:

| Name | Description |
|---|---|
| `next_url` | 新 URL。 |

Returns: 当前构建器。

#### `set_method`

- API: `public`

```gdscript
func set_method(next_method: Method) -> GFHttpRequestBuilder:
```

设置 HTTP 方法。

Parameters:

| Name | Description |
|---|---|
| `next_method` | HTTP 方法枚举。 |

Returns: 当前构建器。

#### `set_parse_mode`

- API: `public`

```gdscript
func set_parse_mode(next_parse_mode: ParseMode) -> GFHttpRequestBuilder:
```

设置响应解析模式。

Parameters:

| Name | Description |
|---|---|
| `next_parse_mode` | 解析模式。 |

Returns: 当前构建器。

#### `set_timeout`

- API: `public`

```gdscript
func set_timeout(seconds: float) -> GFHttpRequestBuilder:
```

设置请求超时时间。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 超时秒数。 |

Returns: 当前构建器。

#### `set_header`

- API: `public`

```gdscript
func set_header(key: String, value: String) -> GFHttpRequestBuilder:
```

设置或覆盖请求头。

Parameters:

| Name | Description |
|---|---|
| `key` | 请求头名称。 |
| `value` | 请求头值。 |

Returns: 当前构建器。

#### `remove_header`

- API: `public`

```gdscript
func remove_header(key: String) -> GFHttpRequestBuilder:
```

移除请求头。

Parameters:

| Name | Description |
|---|---|
| `key` | 请求头名称。 |

Returns: 当前构建器。

#### `add_query_parameter`

- API: `public`

```gdscript
func add_query_parameter(key: String, value: Variant) -> GFHttpRequestBuilder:
```

添加 query 参数。

Parameters:

| Name | Description |
|---|---|
| `key` | 参数名。 |
| `value` | 参数值。 |

Returns: 当前构建器。

Schemas:

- `value`: Variant，URI 编码前会转换为文本的查询参数值。

#### `set_text_body`

- API: `public`

```gdscript
func set_text_body(text: String, content_type: String = "text/plain; charset=utf-8") -> GFHttpRequestBuilder:
```

设置文本请求体。

Parameters:

| Name | Description |
|---|---|
| `text` | 请求体文本。 |
| `content_type` | 可选 Content-Type。 |

Returns: 当前构建器。

#### `set_json_body`

- API: `public`

```gdscript
func set_json_body(value: Variant) -> GFHttpRequestBuilder:
```

设置 JSON 请求体。

Parameters:

| Name | Description |
|---|---|
| `value` | 可被 JSON.stringify() 序列化的数据。 |

Returns: 当前构建器。

Schemas:

- `value`: Variant，兼容 JSON.stringify 的请求体载荷。

#### `build_url`

- API: `public`

```gdscript
func build_url() -> String:
```

构建最终 URL。

Returns: 拼接 query 后的 URL。

#### `build_headers`

- API: `public`

```gdscript
func build_headers() -> PackedStringArray:
```

构建 Godot HTTPRequest 可用的请求头数组。

Returns: Header 数组。

#### `build_request`

- API: `public`

```gdscript
func build_request() -> Dictionary:
```

构建普通请求字典，适合测试、日志或项目自定义传输层使用。

Returns: 请求快照。

Schemas:

- `return`: Dictionary，包含 url、method、method_name、headers、body、timeout_seconds、parse_mode、parse_mode_name 和 metadata。

#### `execute`

- API: `public`

```gdscript
func execute(parent: Node = null) -> GFHttpResponse:
```

使用 HTTPRequest 执行请求。

Parameters:

| Name | Description |
|---|---|
| `parent` | HTTPRequest 节点的父节点；为空时尝试挂到当前 SceneTree root。 |

Returns: 响应对象，可监听 completed。

#### `parse_body`

- API: `public`

```gdscript
func parse_body(body: PackedByteArray) -> Dictionary:
```

按当前 parse_mode 解析响应体。

Parameters:

| Name | Description |
|---|---|
| `body` | 响应 bytes。 |

Returns: 解析结果字典。

Schemas:

- `return`: Dictionary，包含 ok、text、data 和可选 error。

## GFHttpResponse

- Path: `addons/gf/standard/utilities/io/gf_http_response.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFHttpResponse: 通用 HTTP 请求结果。 以对象形式表达 pending、completed、failed、cancelled 等状态，便于请求构建器、 批处理器和项目侧工具统一观察异步结果。

### Signals

#### `completed`

- API: `public`

```gdscript
signal completed(response: GFHttpResponse)
```

响应完成、失败或取消时发出。

Parameters:

| Name | Description |
|---|---|
| `response` | 当前响应对象。 |

### Enums

#### `State`

- API: `public`

```gdscript
enum State { ## 请求仍在等待完成。 PENDING, ## 请求成功完成。 COMPLETED, ## 请求失败。 FAILED, ## 请求被取消。 CANCELLED, }
```

HTTP 响应句柄状态。

### Properties

#### `state`

- API: `public`

```gdscript
var state: State = State.PENDING
```

响应状态。

#### `url`

- API: `public`

```gdscript
var url: String = ""
```

原始 URL。

#### `status_code`

- API: `public`

```gdscript
var status_code: int = 0
```

HTTP 状态码。

#### `result_code`

- API: `public`

```gdscript
var result_code: int = HTTPRequest.RESULT_SUCCESS
```

Godot HTTPRequest 结果码。

#### `headers`

- API: `public`

```gdscript
var headers: PackedStringArray = PackedStringArray()
```

响应头。

#### `text`

- API: `public`

```gdscript
var text: String = ""
```

响应文本。

#### `body`

- API: `public`

```gdscript
var body: PackedByteArray = PackedByteArray()
```

响应原始 bytes。

#### `data`

- API: `public`

```gdscript
var data: Variant = null
```

解析后的数据，例如 JSON 结果。

Schemas:

- `data`: Variant，解析后的响应载荷，例如 JSON 数据、文本数据或 null。

#### `error`

- API: `public`

```gdscript
var error: String = ""
```

错误说明。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: Dictionary，从请求构建器复制的调用方元数据。

#### `cancel_callback`

- API: `public`

```gdscript
var cancel_callback: Callable = Callable()
```

取消请求时执行的底层取消回调。

### Methods

#### `is_pending`

- API: `public`

```gdscript
func is_pending() -> bool:
```

请求是否仍在等待。

Returns: 仍在等待时返回 true。

#### `is_successful`

- API: `public`

```gdscript
func is_successful() -> bool:
```

请求是否成功。

Returns: 请求以 2xx HTTP 状态码完成且没有错误时返回 true。

#### `is_finished`

- API: `public`

```gdscript
func is_finished() -> bool:
```

请求是否已结束。

Returns: 请求完成、失败或取消时返回 true。

#### `complete_success`

- API: `public`

```gdscript
func complete_success(fields: Dictionary = {}) -> void:
```

标记请求成功完成。

Parameters:

| Name | Description |
|---|---|
| `fields` | 需要写入响应对象的字段。 |

Schemas:

- `fields`: Dictionary，可包含 url、status_code、result_code、headers、text、body、data 和 metadata。

#### `complete_failure`

- API: `public`

```gdscript
func complete_failure(message: String, fields: Dictionary = {}) -> void:
```

标记请求失败。

Parameters:

| Name | Description |
|---|---|
| `message` | 错误说明。 |
| `fields` | 需要写入响应对象的字段。 |

Schemas:

- `fields`: Dictionary，可包含 url、status_code、result_code、headers、text、body、data 和 metadata。

#### `cancel`

- API: `public`

```gdscript
func cancel(reason: String = "cancelled") -> void:
```

取消请求。

Parameters:

| Name | Description |
|---|---|
| `reason` | 取消原因。 |

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转为普通字典。

Returns: 响应快照。

Schemas:

- `return`: Dictionary，包含响应状态、URL、HTTP 状态、解析数据、错误信息和 metadata。

## GFInputAction

- Path: `addons/gf/standard/input/mapping/gf_input_action.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputAction: 资源化输入动作描述。 只描述“项目想要读取的抽象动作”，不绑定具体按键、设备或玩法逻辑。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 开关型动作，例如确认、跳跃、攻击。 BOOL, ## 一维轴动作，例如水平移动或缩放。 AXIS_1D, ## 二维轴动作，例如移动方向、瞄准方向。 AXIS_2D, ## 三维轴动作，例如飞行移动、自由相机或六自由度控制。 AXIS_3D, }
```

动作输出值类型。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

动作稳定标识。建议使用不会随本地化变化的 snake_case 名称。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

显示名称，供设置界面或输入提示使用。

#### `display_category`

- API: `public`

```gdscript
var display_category: String = ""
```

显示分类，供设置界面分组使用。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.BOOL
```

动作输出值类型。

#### `remappable`

- API: `public`

```gdscript
var remappable: bool = true
```

是否允许玩家在项目层重绑定。

#### `block_lower_priority_actions`

- API: `public`

```gdscript
var block_lower_priority_actions: bool = true
```

同一输入事件命中多个动作时，较高优先级动作是否阻止低优先级动作。

#### `activation_threshold`

- API: `public`

```gdscript
var activation_threshold: float = 0.5
```

判断轴动作是否活跃的阈值。

### Methods

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取可显示名称。

Returns: 显示名称；为空时回退到动作标识或资源文件名。

#### `get_action_id`

- API: `public`

```gdscript
func get_action_id() -> StringName:
```

获取稳定动作标识。

Returns: 动作标识；未显式设置时尝试使用资源路径。

## GFInputAssistUtility

- Path: `addons/gf/standard/input/runtime/gf_input_assist_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputAssistUtility: 输入手感辅助工具。 负责动作意图缓冲和通用宽容窗口。它不读取 InputEvent、不处理重绑定、 不维护玩家设备，也不替代 GFInputMappingUtility；正式输入映射仍应由 GFInputMappingUtility 负责。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化输入辅助状态并让计时不受时间缩放影响。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

清理全部动作缓冲和宽容窗口。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

每帧驱动计时器递减。所有计时器归零后自动清除。

Parameters:

| Name | Description |
|---|---|
| `delta` | 帧间隔时间（秒）。 |

#### `buffer_action`

- API: `public`

```gdscript
func buffer_action(action_id: StringName, duration: float, player_index: int = -1) -> void:
```

缓冲一个动作意图，在 duration 秒内可被消费。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `duration` | 缓冲持续时间（秒）。 |
| `player_index` | 玩家索引；小于 0 时使用全局缓冲。 |

#### `consume_buffered_action`

- API: `public`

```gdscript
func consume_buffered_action(action_id: StringName, player_index: int = -1) -> bool:
```

尝试消费一个缓冲动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `player_index` | 玩家索引；小于 0 时使用全局缓冲。 |

Returns: 是否成功消费。

#### `has_buffered_action`

- API: `public`

```gdscript
func has_buffered_action(action_id: StringName, player_index: int = -1) -> bool:
```

查询指定动作是否有活跃的缓冲（不消费）。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `player_index` | 玩家索引；小于 0 时使用全局缓冲。 |

Returns: 是否有活跃缓冲。

#### `clear_buffered_action`

- API: `public`

```gdscript
func clear_buffered_action(action_id: StringName, player_index: int = -1) -> void:
```

清除指定动作缓冲。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `player_index` | 玩家索引；小于 0 时使用全局缓冲。 |

#### `start_grace_window`

- API: `public`

```gdscript
func start_grace_window(window_id: StringName, duration: float, player_index: int = -1) -> void:
```

开始一个通用宽容窗口。

Parameters:

| Name | Description |
|---|---|
| `window_id` | 窗口标识。 |
| `duration` | 宽容窗口持续时间（秒）。 |
| `player_index` | 玩家索引；小于 0 时使用全局窗口。 |

#### `is_grace_window_active`

- API: `public`

```gdscript
func is_grace_window_active(window_id: StringName, player_index: int = -1) -> bool:
```

查询指定宽容窗口是否活跃。

Parameters:

| Name | Description |
|---|---|
| `window_id` | 窗口标识。 |
| `player_index` | 玩家索引；小于 0 时使用全局窗口。 |

Returns: 是否在窗口内。

#### `cancel_grace_window`

- API: `public`

```gdscript
func cancel_grace_window(window_id: StringName, player_index: int = -1) -> void:
```

手动取消指定宽容窗口。

Parameters:

| Name | Description |
|---|---|
| `window_id` | 窗口标识。 |
| `player_index` | 玩家索引；小于 0 时使用全局窗口。 |

#### `clear_player`

- API: `public`

```gdscript
func clear_player(player_index: int) -> void:
```

清除指定玩家的全部输入辅助状态。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清除所有缓冲和宽容窗口状态。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 包含缓冲和宽容窗口剩余时间的字典。

Schemas:

- `return`: Dictionary，包含按 scoped action 或 window id 索引的 action_buffers 与 grace_windows 计时器快照。

## GFInputBinding

- Path: `addons/gf/standard/input/mapping/gf_input_binding.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputBinding: 把一个 Godot 输入事件映射到动作值贡献。 该资源只描述输入来源和数值方向，实际动作归属由 GFInputMapping 决定。

### Enums

#### `ValueTarget`

- API: `public`

```gdscript
enum ValueTarget { ## 根据动作值类型自动映射；二维/三维轴默认写入 X 分量，需要其他分量时使用显式 AXIS_* 目标。 AUTO, ## 只作为开关输入。 BOOL, ## 一维轴正向。 AXIS_1D_POSITIVE, ## 一维轴负向。 AXIS_1D_NEGATIVE, ## 二维轴 X 正向。 AXIS_2D_X_POSITIVE, ## 二维轴 X 负向。 AXIS_2D_X_NEGATIVE, ## 二维轴 Y 正向。 AXIS_2D_Y_POSITIVE, ## 二维轴 Y 负向。 AXIS_2D_Y_NEGATIVE, ## 三维轴 X 正向。 AXIS_3D_X_POSITIVE, ## 三维轴 X 负向。 AXIS_3D_X_NEGATIVE, ## 三维轴 Y 正向。 AXIS_3D_Y_POSITIVE, ## 三维轴 Y 负向。 AXIS_3D_Y_NEGATIVE, ## 三维轴 Z 正向。 AXIS_3D_Z_POSITIVE, ## 三维轴 Z 负向。 AXIS_3D_Z_NEGATIVE, }
```

输入值贡献目标。

### Properties

#### `input_event`

- API: `public`

```gdscript
var input_event: InputEvent
```

Godot 原生输入事件模板。

#### `value_target`

- API: `public`

```gdscript
var value_target: ValueTarget = ValueTarget.AUTO
```

当前绑定贡献到动作值的方向。

#### `deadzone`

- API: `public`

```gdscript
var deadzone: float = 0.2
```

轴输入死区。对按键和按钮输入无影响。

#### `scale`

- API: `public`

```gdscript
var scale: float = 1.0
```

输入贡献缩放。

#### `modifiers`

- API: `public`

```gdscript
var modifiers: Array[GFInputModifier] = []
```

绑定级输入修饰器，按顺序作用于该绑定产生的贡献值。

#### `match_device`

- API: `public`

```gdscript
var match_device: bool = false
```

是否按设备 ID 精确匹配。关闭时同类按键、鼠标按钮或手柄按钮可跨设备匹配。

#### `match_touch_index`

- API: `public`

```gdscript
var match_touch_index: bool = false
```

是否按触点 index 精确匹配 InputEventScreenTouch。 默认关闭，表示任意触点都可匹配该绑定。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

覆盖显示名称。

#### `remappable`

- API: `public`

```gdscript
var remappable: bool = true
```

该绑定是否可被玩家重绑。

### Methods

#### `duplicate_binding`

- API: `public`

```gdscript
func duplicate_binding() -> GFInputBinding:
```

创建深拷贝，避免运行时重映射污染原始资源。

Returns: 新绑定。

#### `matches_event`

- API: `public`

```gdscript
func matches_event(event: InputEvent) -> bool:
```

判断当前绑定是否匹配输入事件。

Parameters:

| Name | Description |
|---|---|
| `event` | 运行时输入事件。 |

Returns: 是否匹配。

#### `get_contribution`

- API: `public`

```gdscript
func get_contribution( event: InputEvent, action_value_type: GFInputAction.ValueType, deadzone_override: float = -1.0 ) -> Vector3:
```

计算该输入事件对动作值的贡献。

Parameters:

| Name | Description |
|---|---|
| `event` | 运行时输入事件。 |
| `action_value_type` | 动作值类型。 |
| `deadzone_override` | 可选死区覆盖；小于 0 时使用绑定自身 deadzone。 |

Returns: 三维向量贡献；布尔与一维轴使用 x 分量，二维轴使用 x/y 分量。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取显示名称。

Returns: 显示名称；为空时由输入事件格式化。

## GFInputChordTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_chord_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputChordTrigger: 组合动作触发器。 当前输入活跃且另一个动作也处于活跃状态时触发，不绑定具体按键。

### Properties

#### `required_action_id`

- API: `public`

```gdscript
var required_action_id: StringName = &""
```

需要同时保持活跃的动作标识。

#### `player_scoped`

- API: `public`

```gdscript
var player_scoped: bool = true
```

玩家级动作是否只检查同一玩家。

### Methods

#### `prepare_runtime`

- API: `public`

```gdscript
func prepare_runtime( _action_id: StringName, input_runtime: Object, player_index: int, state: Dictionary ) -> void:
```

准备输入动作运行时状态。

Parameters:

| Name | Description |
|---|---|
| `_action_id` | 当前输入动作标识，默认实现不直接使用。 |
| `input_runtime` | 输入映射运行时。 |
| `player_index` | 玩家索引。 |
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 input_runtime: Object 和 player_index: int。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 input_runtime: Object 和 player_index: int。

## GFInputConflictAnalyzer

- Path: `addons/gf/standard/input/rebinding/gf_input_conflict_analyzer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputConflictAnalyzer: 输入上下文冲突分析工具。 只读取输入资源与可选重映射配置，不参与运行时输入分发。适合设置界面、 编辑器工具或测试在应用重绑定前检查同一输入是否被多个抽象动作占用。

### Methods

#### `analyze_context`

- API: `public`

```gdscript
static func analyze_context( context: GFInputContext, remap_config: GFInputRemapConfig = null, include_non_remappable: bool = true ) -> Array[Dictionary]:
```

分析单个上下文内的绑定冲突。

Parameters:

| Name | Description |
|---|---|
| `context` | 输入上下文。 |
| `remap_config` | 可选重映射配置。 |
| `include_non_remappable` | 是否包含不可重绑动作或绑定。 |

Returns: 冲突列表。

Schemas:

- `return`: Array，包含冲突 Dictionary 记录，字段包括 context/action/binding id、other_* id、event_text、signature 和 items。

#### `analyze_contexts`

- API: `public`

```gdscript
static func analyze_contexts( contexts: Array[GFInputContext], remap_config: GFInputRemapConfig = null, include_cross_context: bool = false, include_non_remappable: bool = true ) -> Array[Dictionary]:
```

分析多个上下文的绑定冲突。

Parameters:

| Name | Description |
|---|---|
| `contexts` | 输入上下文列表。 |
| `remap_config` | 可选重映射配置。 |
| `include_cross_context` | 是否报告跨上下文冲突。 |
| `include_non_remappable` | 是否包含不可重绑动作或绑定。 |

Returns: 冲突列表。

Schemas:

- `contexts`: Array[GFInputContext] of contexts to analyze.
- `return`: Array，包含冲突 Dictionary 记录，字段包括 context/action/binding id、other_* id、event_text、signature 和 items。

#### `build_rebind_report`

- API: `public`

```gdscript
static func build_rebind_report( contexts: Array[GFInputContext], remap_config: GFInputRemapConfig = null, include_cross_context: bool = false, include_non_remappable: bool = true ) -> Dictionary:
```

构建重绑定诊断报告。

Parameters:

| Name | Description |
|---|---|
| `contexts` | 输入上下文列表。 |
| `remap_config` | 可选重映射配置。 |
| `include_cross_context` | 是否报告跨上下文冲突。 |
| `include_non_remappable` | 是否包含不可重绑动作或绑定。 |

Returns: 包含条目与冲突的报告。

Schemas:

- `contexts`: Array[GFInputContext] of contexts to analyze.
- `return`: Dictionary，包含 ok、context_count、item_count、conflict_count、items 和 conflicts。

#### `collect_binding_items`

- API: `public`

```gdscript
static func collect_binding_items( contexts: Array[GFInputContext], remap_config: GFInputRemapConfig = null, include_non_remappable: bool = true ) -> Array[Dictionary]:
```

收集上下文中的有效绑定条目。

Parameters:

| Name | Description |
|---|---|
| `contexts` | 输入上下文列表。 |
| `remap_config` | 可选重映射配置。 |
| `include_non_remappable` | 是否包含不可重绑动作或绑定。 |

Returns: 绑定条目列表。

Schemas:

- `contexts`: Array[GFInputContext] of contexts to inspect.
- `return`: Array，包含 item Dictionary 记录，字段包括 context/action/binding id、event、event_text、event_key、signature、device_scope 和 match_device。

#### `get_event_signature`

- API: `public`

```gdscript
static func get_event_signature(input_event: InputEvent, match_device: bool = false) -> String:
```

获取输入事件的稳定签名。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `match_device` | 是否把设备 ID 纳入签名。 |

Returns: 签名字符串；空事件返回空字符串。

#### `are_events_equivalent`

- API: `public`

```gdscript
static func are_events_equivalent( left_event: InputEvent, right_event: InputEvent, left_match_device: bool = false, right_match_device: bool = false ) -> bool:
```

判断两个输入事件是否会在绑定层互相冲突。

Parameters:

| Name | Description |
|---|---|
| `left_event` | 左侧输入事件。 |
| `right_event` | 右侧输入事件。 |
| `left_match_device` | 左侧是否要求设备精确匹配。 |
| `right_match_device` | 右侧是否要求设备精确匹配。 |

Returns: 冲突返回 true。

## GFInputContext

- Path: `addons/gf/standard/input/mapping/gf_input_context.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputContext: 资源化输入上下文。 上下文用于表示一组可启停的输入映射，例如 gameplay、menu、dialogue。

### Properties

#### `context_id`

- API: `public`

```gdscript
var context_id: StringName = &""
```

上下文稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

显示名称。

#### `mappings`

- API: `public`

```gdscript
var mappings: Array[GFInputMapping] = []
```

该上下文中的动作映射。

### Methods

#### `get_context_id`

- API: `public`

```gdscript
func get_context_id() -> StringName:
```

获取稳定上下文标识。

Returns: 上下文标识。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取显示名称。

Returns: 显示名称。

## GFInputCurveModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_curve_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputCurveModifier: 输入曲线修饰器。 对输入分量按 Curve 重新采样，适合摇杆灵敏度、扳机响应和虚拟指针速度曲线。

### Properties

#### `curve`

- API: `public`

```gdscript
var curve: Curve = null
```

输入曲线。采样区间为 0..1。

#### `preserve_sign`

- API: `public`

```gdscript
var preserve_sign: bool = true
```

是否保留输入符号，只用绝对值采样曲线。

#### `apply_x`

- API: `public`

```gdscript
var apply_x: bool = true
```

是否处理 X 分量。

#### `apply_y`

- API: `public`

```gdscript
var apply_y: bool = true
```

是否处理 Y 分量。

#### `apply_z`

- API: `public`

```gdscript
var apply_z: bool = true
```

是否处理 Z 分量。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 按曲线采样后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 按曲线采样后的三维输入值。

## GFInputDeadzoneModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_deadzone_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputDeadzoneModifier: 输入死区修饰器。 可对一维或二维轴值应用径向死区，并可选择把剩余范围重新映射到 0..1。

### Properties

#### `lower_threshold`

- API: `public`

```gdscript
var lower_threshold: float = 0.2:
```

低于该阈值的输入会被视为 0。

#### `upper_threshold`

- API: `public`

```gdscript
var upper_threshold: float = 1.0:
```

达到该阈值时视为满幅输入。

#### `rescale_after_deadzone`

- API: `public`

```gdscript
var rescale_after_deadzone: bool = true
```

是否把死区外的剩余范围重新映射到 0..1。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 应用死区后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 应用死区后的三维输入值。

## GFInputDetector

- Path: `addons/gf/standard/input/rebinding/gf_input_detector.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputDetector: 检测下一次输入事件的辅助节点。 可用于项目自己的改键界面。检测结果只返回 Godot InputEvent，冲突处理由项目层决定。

### Signals

#### `detection_started`

- API: `public`

```gdscript
signal detection_started
```

开始检测时发出。

#### `input_detected`

- API: `public`

```gdscript
signal input_detected(input_event: InputEvent)
```

检测结束时发出。input_event 为 null 表示取消或超时。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 检测到的输入事件；取消或超时时为 null。 |

### Enums

#### `DeviceType`

- API: `public`

```gdscript
enum DeviceType { ## 键盘输入。 KEYBOARD, ## 鼠标输入。 MOUSE, ## 手柄按钮或轴输入。 JOYPAD, ## 触屏输入。 TOUCH, }
```

设备过滤类型。

#### `DetectionState`

- API: `public`

```gdscript
enum DetectionState { ## 未检测。 IDLE, ## 倒计时中。 COUNTDOWN, ## 等待取消输入释放。 PRE_CLEAR, ## 正在接收候选输入。 DETECTING, ## 等待检测到的输入释放。 POST_CLEAR, }
```

检测阶段。

### Properties

#### `ignore_echo`

- API: `public`

```gdscript
var ignore_echo: bool = true
```

是否忽略键盘 echo 事件。

#### `minimum_axis_amplitude`

- API: `public`

```gdscript
var minimum_axis_amplitude: float = 0.25
```

轴输入检测阈值。

#### `countdown_seconds`

- API: `public`

```gdscript
var countdown_seconds: float = 0.0
```

正式接收输入前的倒计时。可用于改键界面避开确认按钮本身。

#### `timeout_seconds`

- API: `public`

```gdscript
var timeout_seconds: float = 0.0
```

检测超时时间。小于等于 0 表示不超时。

#### `abort_events`

- API: `public`

```gdscript
var abort_events: Array[InputEvent] = []
```

取消检测的输入事件列表。

Schemas:

- `abort_events`: Array[InputEvent] used to cancel detection or wait for release before accepting input.

#### `wait_for_clear_before_detection`

- API: `public`

```gdscript
var wait_for_clear_before_detection: bool = true
```

开始正式检测前，是否等待 abort_events 中仍按住的输入释放。

#### `wait_for_clear_after_detection`

- API: `public`

```gdscript
var wait_for_clear_after_detection: bool = false
```

检测到输入后，是否等待该输入释放再发出 input_detected。

### Methods

#### `begin_detection`

- API: `public`

```gdscript
func begin_detection(allowed_device_types: Array[int] = []) -> void:
```

开始检测下一次输入。

Parameters:

| Name | Description |
|---|---|
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `begin_detection_for_value_type`

- API: `public`

```gdscript
func begin_detection_for_value_type( value_type: GFInputAction.ValueType, allowed_device_types: Array[int] = [] ) -> void:
```

按动作值类型开始检测下一次输入。

Parameters:

| Name | Description |
|---|---|
| `value_type` | 期望的动作值类型。 |
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `begin_detection_for_action`

- API: `public`

```gdscript
func begin_detection_for_action( action: GFInputAction, allowed_device_types: Array[int] = [] ) -> void:
```

按动作资源开始检测下一次输入。

Parameters:

| Name | Description |
|---|---|
| `action` | 输入动作资源。 |
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `detect_bool`

- API: `public`

```gdscript
func detect_bool(allowed_device_types: Array[int] = []) -> void:
```

开始检测布尔输入。

Parameters:

| Name | Description |
|---|---|
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `detect_axis_1d`

- API: `public`

```gdscript
func detect_axis_1d(allowed_device_types: Array[int] = []) -> void:
```

开始检测一维轴输入。

Parameters:

| Name | Description |
|---|---|
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `detect_axis_2d`

- API: `public`

```gdscript
func detect_axis_2d(allowed_device_types: Array[int] = []) -> void:
```

开始检测二维轴输入。

Parameters:

| Name | Description |
|---|---|
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `detect_axis_3d`

- API: `public`

```gdscript
func detect_axis_3d(allowed_device_types: Array[int] = []) -> void:
```

开始检测三维轴输入。

Parameters:

| Name | Description |
|---|---|
| `allowed_device_types` | 允许的设备类型。空数组表示不限制。 |

Schemas:

- `allowed_device_types`: Array[int]，包含 DeviceType 枚举值；为空表示不过滤设备。

#### `get_countdown_remaining`

- API: `public`

```gdscript
func get_countdown_remaining() -> float:
```

获取正式接收输入前剩余的倒计时秒数。

Returns: 剩余秒数。

#### `get_detection_state`

- API: `public`

```gdscript
func get_detection_state() -> DetectionState:
```

获取当前检测阶段。

Returns: 检测阶段。

#### `is_accepting_input`

- API: `public`

```gdscript
func is_accepting_input() -> bool:
```

是否已经结束倒计时并正在接收候选输入。

Returns: 是否可接收输入。

#### `cancel_detection`

- API: `public`

```gdscript
func cancel_detection() -> void:
```

取消检测。

#### `is_detecting`

- API: `public`

```gdscript
func is_detecting() -> bool:
```

检查当前是否正在检测。

Returns: 是否正在检测。

## GFInputDeviceAssignment

- Path: `addons/gf/standard/input/runtime/gf_input_device_assignment.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputDeviceAssignment: 玩家与输入设备的通用映射。 仅描述设备归属，不绑定任何具体输入动作。

### Enums

#### `DeviceType`

- API: `public`

```gdscript
enum DeviceType { ## 键盘与鼠标作为一个本地输入设备。 KEYBOARD_MOUSE, ## Godot 手柄设备。 JOYPAD, ## 触控输入设备。 TOUCH, ## AI 或自动化输入来源。 AI, ## 项目自定义输入设备。 CUSTOM, }
```

输入设备类型。

### Properties

#### `player_index`

- API: `public`

```gdscript
var player_index: int = 0
```

玩家或本地席位索引。

#### `device_type`

- API: `public`

```gdscript
var device_type: DeviceType = DeviceType.KEYBOARD_MOUSE
```

设备类型。

#### `device_id`

- API: `public`

```gdscript
var device_id: int = 0
```

Godot 输入设备 ID。键鼠通常为 0，虚拟/AI 可使用 -1。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据。

Schemas:

- `metadata`: Dictionary，当前分配的项目侧元数据。

### Methods

#### `duplicate_assignment`

- API: `public`

```gdscript
func duplicate_assignment() -> GFInputDeviceAssignment:
```

创建一个浅拷贝。

Returns: 新的设备映射。

## GFInputDeviceTextProvider

- Path: `addons/gf/standard/input/formatting/gf_input_device_text_provider.gd`
- Extends: `GFInputTextProvider`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputDeviceTextProvider: 通用手柄输入文本 provider。 以抽象方位和轴名称描述 Joypad 输入，项目可通过字典覆盖为任意设备、平台或本地化文本。

### Properties

#### `button_labels`

- API: `public`

```gdscript
var button_labels: Dictionary = _DEFAULT_BUTTON_LABELS
```

Joypad 按钮标签表，Key 为 JoyButton int。

Schemas:

- `button_labels`: Dictionary，以 JoyButton int 或枚举值为键，值为 String 显示标签。

#### `axis_labels`

- API: `public`

```gdscript
var axis_labels: Dictionary = _DEFAULT_AXIS_LABELS
```

Joypad 轴标签表，Key 为 JoyAxis int。

Schemas:

- `axis_labels`: Dictionary，以 JoyAxis int 或枚举值为键，值为 String 显示标签。

#### `axis_positive_suffix`

- API: `public`

```gdscript
var axis_positive_suffix: String = "+"
```

正向轴后缀。

#### `axis_negative_suffix`

- API: `public`

```gdscript
var axis_negative_suffix: String = "-"
```

负向轴后缀。

#### `axis_direction_deadzone`

- API: `public`

```gdscript
var axis_direction_deadzone: float = 0.1
```

轴方向判断死区。

### Methods

#### `create_standard`

- API: `public`

```gdscript
static func create_standard(provider_priority: int = 0) -> GFInputDeviceTextProvider:
```

创建标准手柄文本 provider。

Parameters:

| Name | Description |
|---|---|
| `provider_priority` | provider 优先级。 |

Returns: 文本 provider。

#### `format_joypad_event`

- API: `public`

```gdscript
static func format_joypad_event(input_event: InputEvent, options: Dictionary = {}) -> String:
```

使用标准标签格式化 Joypad 输入事件。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 可选格式化参数。 |

Returns: 文本；非 Joypad 事件返回空字符串。

Schemas:

- `options`: Dictionary，可包含 joypad_button_labels、joypad_axis_labels、joypad_axis_deadzone、joypad_axis_positive_suffix 和 joypad_axis_negative_suffix。

#### `supports_event`

- API: `public`

```gdscript
func supports_event(input_event: InputEvent, _options: Dictionary = {}) -> bool:
```

判断是否支持指定输入事件。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `_options` | 调用选项。 |

Returns: 支持返回 true。

Schemas:

- `_options`: Dictionary，为 provider 接口兼容性接收的选项。

#### `get_event_text`

- API: `public`

```gdscript
func get_event_text(input_event: InputEvent, options: Dictionary = {}) -> String:
```

获取输入事件文本。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 文本；不支持时返回空字符串。

Schemas:

- `options`: Dictionary，可包含 joypad_button_labels、joypad_axis_labels、joypad_axis_deadzone、joypad_axis_positive_suffix 和 joypad_axis_negative_suffix。

## GFInputDeviceUtility

- Path: `addons/gf/standard/input/runtime/gf_input_device_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputDeviceUtility: 本地玩家输入设备分配工具。 负责维护玩家索引与键鼠、手柄、触控、AI 或自定义设备的映射。 它不消费输入事件，也不规定动作名。

### Signals

#### `assignments_changed`

- API: `public`

```gdscript
signal assignments_changed(assignments: Array[GFInputDeviceAssignment])
```

设备映射发生变化时发出。

Parameters:

| Name | Description |
|---|---|
| `assignments` | 当前设备映射副本。 |

#### `active_player_changed`

- API: `public`

```gdscript
signal active_player_changed(player_index: int)
```

最近产生输入的玩家变化时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

#### `active_device_changed`

- API: `public`

```gdscript
signal active_device_changed(player_index: int, assignment: GFInputDeviceAssignment, event: InputEvent)
```

最近产生输入的设备变化时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `assignment` | 活跃设备映射副本。 |
| `event` | 触发变化的输入事件副本；手动设置时可能为空。 |

#### `player_join_requested`

- API: `public`

```gdscript
signal player_join_requested(player_index: int, assignment: GFInputDeviceAssignment, event: InputEvent)
```

收到项目配置的加入输入时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `assignment` | 触发加入请求的设备映射副本。 |
| `event` | 触发加入请求的输入事件副本。 |

### Properties

#### `max_players`

- API: `public`

```gdscript
var max_players: int = 4:
```

允许的最大本地玩家数。

#### `include_keyboard_mouse`

- API: `public`

```gdscript
var include_keyboard_mouse: bool = true
```

是否为 0 号玩家自动分配键鼠。

#### `include_touch`

- API: `public`

```gdscript
var include_touch: bool = true
```

是否在移动平台自动添加触控设备。

#### `auto_assign_joypads_on_input`

- API: `public`

```gdscript
var auto_assign_joypads_on_input: bool = true
```

是否在收到未登记手柄输入时自动分配到空玩家席位。

#### `auto_assign_axis_threshold`

- API: `public`

```gdscript
var auto_assign_axis_threshold: float = 0.75
```

未登记手柄轴输入需要达到该幅度才会触发自动分配，避免漂移噪声抢占席位。

#### `active_player_axis_threshold`

- API: `public`

```gdscript
var active_player_axis_threshold: float = 0.2:
```

已登记手柄轴输入需要达到该幅度才会切换最近活跃玩家。

#### `join_events`

- API: `public`

```gdscript
var join_events: Array[InputEvent] = []
```

可触发本地玩家加入请求的输入事件模板。为空时不启用 join 检测。

#### `auto_assign_devices_on_join`

- API: `public`

```gdscript
var auto_assign_devices_on_join: bool = true
```

join 输入来自未登记设备时，是否自动分配到空玩家席位。

#### `active_player_index`

- API: `public`

```gdscript
var active_player_index: int = 0
```

当前最近活跃玩家索引。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化设备映射并订阅手柄连接变化。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

清理设备映射并取消手柄连接变化订阅。

#### `refresh_connected_devices`

- API: `public`

```gdscript
func refresh_connected_devices() -> void:
```

按当前硬件重新生成设备映射。

#### `create_assignment`

- API: `public`

```gdscript
func create_assignment( player_index: int, device_type: GFInputDeviceAssignment.DeviceType, device_id: int ) -> GFInputDeviceAssignment:
```

创建一个设备映射。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `device_type` | 设备类型。 |
| `device_id` | 设备 ID。 |

Returns: 新映射。

#### `set_assignment`

- API: `public`

```gdscript
func set_assignment(assignment: GFInputDeviceAssignment) -> void:
```

手动设置一个玩家的设备映射。

Parameters:

| Name | Description |
|---|---|
| `assignment` | 设备映射。 |

#### `remove_assignment`

- API: `public`

```gdscript
func remove_assignment(player_index: int) -> void:
```

移除指定玩家的设备映射。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

#### `get_assignment`

- API: `public`

```gdscript
func get_assignment(player_index: int) -> GFInputDeviceAssignment:
```

获取指定玩家的设备映射。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

Returns: 设备映射；不存在时返回 null。

#### `get_player_for_device`

- API: `public`

```gdscript
func get_player_for_device( device_type: GFInputDeviceAssignment.DeviceType, device_id: int ) -> int:
```

根据设备类型和设备 ID 获取玩家索引。

Parameters:

| Name | Description |
|---|---|
| `device_type` | 设备类型。 |
| `device_id` | 设备 ID。 |

Returns: 玩家索引；不存在时返回 -1。

#### `get_player_for_event`

- API: `public`

```gdscript
func get_player_for_event(event: InputEvent) -> int:
```

根据输入事件获取玩家索引，不产生自动分配。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: 玩家索引；无法匹配时返回 -1。

#### `handle_input_event`

- API: `public`

```gdscript
func handle_input_event(event: InputEvent) -> int:
```

处理输入事件并返回玩家索引。未登记手柄可按配置自动占位。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: 玩家索引；无法匹配时返回 -1。

#### `handle_join_input_event`

- API: `public`

```gdscript
func handle_join_input_event(event: InputEvent) -> int:
```

处理本地玩家加入输入。只有匹配 join_events 的输入会触发。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: 请求加入的玩家索引；未匹配或无可用席位时返回 -1。

#### `is_join_input_event`

- API: `public`

```gdscript
func is_join_input_event(event: InputEvent) -> bool:
```

检查输入事件是否匹配当前 join_events。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: 是否是加入输入。

#### `configure_default_join_events`

- API: `public`

```gdscript
func configure_default_join_events(include_keyboard: bool = true, include_joypad: bool = true) -> void:
```

使用常见本地多人加入输入填充 join_events。

Parameters:

| Name | Description |
|---|---|
| `include_keyboard` | 是否加入 Enter / 小键盘 Enter。 |
| `include_joypad` | 是否加入手柄确认 / 开始按钮。 |

#### `clear_join_events`

- API: `public`

```gdscript
func clear_join_events() -> void:
```

清空 join 输入模板。

#### `assign_device_to_next_player`

- API: `public`

```gdscript
func assign_device_to_next_player( device_type: GFInputDeviceAssignment.DeviceType, device_id: int ) -> int:
```

把设备分配给第一个空玩家席位。

Parameters:

| Name | Description |
|---|---|
| `device_type` | 设备类型。 |
| `device_id` | 设备 ID。 |

Returns: 分配到的玩家索引；无空位时返回 -1。

#### `set_active_player`

- API: `public`

```gdscript
func set_active_player(player_index: int) -> void:
```

设置最近活跃玩家。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

#### `set_player_deadzone`

- API: `public`

```gdscript
func set_player_deadzone(player_index: int, deadzone: float) -> void:
```

设置玩家级输入死区。小于 0 表示清除覆盖。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `deadzone` | 死区值。 |

#### `get_player_deadzone`

- API: `public`

```gdscript
func get_player_deadzone(player_index: int, fallback: float = -1.0) -> float:
```

获取玩家级输入死区覆盖。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `fallback` | 没有覆盖时返回的值。 |

Returns: 死区值。

#### `get_device_name`

- API: `public`

```gdscript
func get_device_name(player_index: int) -> String:
```

获取玩家设备显示名。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

Returns: 显示名。

#### `get_active_assignment`

- API: `public`

```gdscript
func get_active_assignment() -> GFInputDeviceAssignment:
```

获取当前活跃设备映射。

Returns: 活跃设备映射副本；不存在时返回 null。

#### `get_active_device_name`

- API: `public`

```gdscript
func get_active_device_name() -> String:
```

获取当前活跃设备显示名。

Returns: 活跃设备显示名。

#### `start_vibration_for_player`

- API: `public`

```gdscript
func start_vibration_for_player( player_index: int, weak_magnitude: float, strong_magnitude: float, duration_seconds: float = 0.0 ) -> bool:
```

启动指定玩家手柄震动。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `weak_magnitude` | 低频马达强度，范围 0 到 1。 |
| `strong_magnitude` | 高频马达强度，范围 0 到 1。 |
| `duration_seconds` | 持续时间，0 表示由引擎默认处理。 |

Returns: 成功转发到手柄设备时返回 true。

#### `stop_vibration_for_player`

- API: `public`

```gdscript
func stop_vibration_for_player(player_index: int) -> bool:
```

停止指定玩家手柄震动。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

Returns: 成功转发到手柄设备时返回 true。

#### `get_assignments`

- API: `public`

```gdscript
func get_assignments() -> Array[GFInputDeviceAssignment]:
```

获取所有设备映射的拷贝。

Returns: 映射数组。

#### `clear_assignments`

- API: `public`

```gdscript
func clear_assignments() -> void:
```

清空所有映射。

## GFInputDirectionHistory

- Path: `addons/gf/standard/input/history/gf_input_direction_history.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFInputDirectionHistory: 最后按下方向优先的输入历史。 维护动作 ID 到方向向量的按下顺序，适合网格移动、菜单导航或四方向角色控制。 它不读取 InputMap，也不规定动作命名。

### Methods

#### `press_action`

- API: `public`

```gdscript
func press_action(action_id: StringName, direction: Vector2i) -> void:
```

标记一个方向动作被按下。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `direction` | 方向。 |

#### `release_action`

- API: `public`

```gdscript
func release_action(action_id: StringName) -> void:
```

标记一个方向动作被释放。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

#### `press_direction`

- API: `public`

```gdscript
func press_direction(direction: Vector2i) -> void:
```

按方向值生成内部动作标识并标记按下。

Parameters:

| Name | Description |
|---|---|
| `direction` | 方向。 |

#### `release_direction`

- API: `public`

```gdscript
func release_direction(direction: Vector2i) -> void:
```

按方向值生成内部动作标识并标记释放。

Parameters:

| Name | Description |
|---|---|
| `direction` | 方向。 |

#### `update_action`

- API: `public`

```gdscript
func update_action(action_id: StringName, direction: Vector2i, pressed: bool) -> void:
```

根据 pressed 状态更新动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `direction` | 方向。 |
| `pressed` | 是否按下。 |

#### `get_current_direction`

- API: `public`

```gdscript
func get_current_direction() -> Vector2i:
```

获取当前优先方向。

Returns: 最近按下且尚未释放的方向；没有时返回 Vector2i.ZERO。

#### `get_current_action`

- API: `public`

```gdscript
func get_current_action() -> StringName:
```

获取当前优先动作。

Returns: 最近按下且尚未释放的动作；没有时返回空 StringName。

#### `get_history`

- API: `public`

```gdscript
func get_history() -> Array[StringName]:
```

获取按下历史副本。

Returns: 动作 ID 列表。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空历史。

## GFInputFormatter

- Path: `addons/gf/standard/input/formatting/gf_input_formatter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputFormatter: 输入事件与绑定的轻量文本格式化工具。

### Methods

#### `input_event_as_text`

- API: `public`

```gdscript
static func input_event_as_text(input_event: InputEvent, options: Dictionary = {}) -> String:
```

将 Godot 输入事件格式化为通用文本。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 可选格式化参数。 |

Returns: 可显示文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。

#### `input_event_as_rich_text`

- API: `public`

```gdscript
static func input_event_as_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
```

将 Godot 输入事件格式化为 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 可选格式化参数。 |

Returns: BBCode 文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。

#### `input_event_icon`

- API: `public`

```gdscript
static func input_event_icon(input_event: InputEvent, options: Dictionary = {}) -> Texture2D:
```

获取输入事件图标。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 可选格式化参数。 |

Returns: 图标资源。

Schemas:

- `options`: Dictionary，透传给已注册的图标 provider。

#### `binding_as_text`

- API: `public`

```gdscript
static func binding_as_text(binding: GFInputBinding, options: Dictionary = {}) -> String:
```

将绑定格式化为通用文本。

Parameters:

| Name | Description |
|---|---|
| `binding` | 输入绑定。 |
| `options` | 可选格式化参数。 |

Returns: 可显示文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。

#### `binding_as_rich_text`

- API: `public`

```gdscript
static func binding_as_rich_text(binding: GFInputBinding, options: Dictionary = {}) -> String:
```

将绑定格式化为 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `binding` | 输入绑定。 |
| `options` | 可选格式化参数。 |

Returns: BBCode 文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。

#### `mapping_as_text`

- API: `public`

```gdscript
static func mapping_as_text( mapping: GFInputMapping, context_id: StringName = &"", remap_config: GFInputRemapConfig = null, options: Dictionary = {} ) -> String:
```

将映射的当前有效绑定格式化为通用文本。

Parameters:

| Name | Description |
|---|---|
| `mapping` | 输入映射。 |
| `context_id` | 上下文标识。 |
| `remap_config` | 可选重映射配置。 |
| `options` | 可选格式化参数。 |

Returns: 可显示文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。

#### `mapping_as_rich_text`

- API: `public`

```gdscript
static func mapping_as_rich_text( mapping: GFInputMapping, context_id: StringName = &"", remap_config: GFInputRemapConfig = null, options: Dictionary = {} ) -> String:
```

将映射的当前有效绑定格式化为 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `mapping` | 输入映射。 |
| `context_id` | 上下文标识。 |
| `remap_config` | 可选重映射配置。 |
| `options` | 可选格式化参数。 |

Returns: BBCode 文本。

Schemas:

- `options`: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。

#### `add_text_provider`

- API: `public`

```gdscript
static func add_text_provider(provider: GFInputTextProvider) -> void:
```

注册文本 provider。

Parameters:

| Name | Description |
|---|---|
| `provider` | 文本 provider。 |

#### `remove_text_provider`

- API: `public`

```gdscript
static func remove_text_provider(provider: GFInputTextProvider) -> void:
```

移除文本 provider。

Parameters:

| Name | Description |
|---|---|
| `provider` | 文本 provider。 |

#### `clear_text_providers`

- API: `public`

```gdscript
static func clear_text_providers() -> void:
```

清空文本 provider。

#### `get_text_providers`

- API: `public`

```gdscript
static func get_text_providers() -> Array[GFInputTextProvider]:
```

获取已注册文本 provider。

Returns: provider 列表副本。

#### `add_icon_provider`

- API: `public`

```gdscript
static func add_icon_provider(provider: GFInputIconProvider) -> void:
```

注册图标 provider。

Parameters:

| Name | Description |
|---|---|
| `provider` | 图标 provider。 |

#### `remove_icon_provider`

- API: `public`

```gdscript
static func remove_icon_provider(provider: GFInputIconProvider) -> void:
```

移除图标 provider。

Parameters:

| Name | Description |
|---|---|
| `provider` | 图标 provider。 |

#### `clear_icon_providers`

- API: `public`

```gdscript
static func clear_icon_providers() -> void:
```

清空图标 provider。

#### `get_icon_providers`

- API: `public`

```gdscript
static func get_icon_providers() -> Array[GFInputIconProvider]:
```

获取已注册图标 provider。

Returns: provider 列表副本。

## GFInputHoldTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_hold_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputHoldTrigger: 长按触发器。 输入持续活跃达到 hold_seconds 后，动作才进入活跃状态。释放输入会重置计时。

### Properties

#### `hold_seconds`

- API: `public`

```gdscript
var hold_seconds: float = 0.25:
```

需要持续按住的秒数。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 elapsed: float。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `delta` | 本帧时间增量（秒）。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 elapsed: float。

## GFInputIconAtlasProvider

- Path: `addons/gf/standard/input/formatting/gf_input_icon_atlas_provider.gd`
- Extends: `GFInputIconProvider`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputIconAtlasProvider: 可配置输入图标图集 Provider。 将 InputEvent 归一化为通用图标键，再通过显式映射或路径模板解析 Texture2D / RichText 图标。 框架不附带图标资源，也不规定项目的美术风格或平台命名。

### Properties

#### `root_path`

- API: `public`

```gdscript
var root_path: String = ""
```

图标根目录。路径模板中的 {root} 会使用该值。

#### `style`

- API: `public`

```gdscript
var style: StringName = &"default"
```

图标风格名。路径模板中的 {style} 会使用该值。

#### `platform`

- API: `public`

```gdscript
var platform: StringName = &""
```

平台名。为空时使用 options.platform 或 fallback_platform。

#### `fallback_platform`

- API: `public`

```gdscript
var fallback_platform: StringName = &"generic"
```

平台回退名。

#### `path_pattern`

- API: `public`

```gdscript
var path_pattern: String = "{root}/{style}/{platform}/{icon}.png"
```

路径模板。可使用 {root}、{style}、{platform}、{icon}。

#### `icon_paths`

- API: `public`

```gdscript
var icon_paths: Dictionary = {}
```

显式路径映射，key 为 get_event_icon_candidates() 产生的图标键。

Schemas:

- `icon_paths`: Dictionary，以 StringName 或 String 图标键为键，值为 String Texture2D 资源路径。

#### `icon_textures`

- API: `public`

```gdscript
var icon_textures: Dictionary = {}
```

显式纹理映射，key 为 get_event_icon_candidates() 产生的图标键。

Schemas:

- `icon_textures`: Dictionary，以 StringName 或 String 图标键为键，值为 Texture2D。

#### `rich_text_separator`

- API: `public`

```gdscript
var rich_text_separator: String = " "
```

RichText 输出多个图标时使用的分隔文本。

#### `split_key_modifiers`

- API: `public`

```gdscript
var split_key_modifiers: bool = true
```

是否为带修饰键的键盘事件输出多个图标。

### Methods

#### `set_icon_path`

- API: `public`

```gdscript
func set_icon_path(icon_key: StringName, resource_path: String) -> void:
```

设置图标路径映射。

Parameters:

| Name | Description |
|---|---|
| `icon_key` | 图标键。 |
| `resource_path` | Texture2D 资源路径。 |

#### `set_icon_texture`

- API: `public`

```gdscript
func set_icon_texture(icon_key: StringName, texture: Texture2D) -> void:
```

设置图标纹理映射。

Parameters:

| Name | Description |
|---|---|
| `icon_key` | 图标键。 |
| `texture` | 图标纹理。 |

#### `clear_cache`

- API: `public`

```gdscript
func clear_cache() -> void:
```

清空已加载的纹理缓存。

#### `supports_event`

- API: `public`

```gdscript
func supports_event(input_event: InputEvent, options: Dictionary = {}) -> bool:
```

判断是否支持指定输入事件。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 支持返回 true。

Schemas:

- `options`: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。

#### `get_event_icon`

- API: `public`

```gdscript
func get_event_icon(input_event: InputEvent, options: Dictionary = {}) -> Texture2D:
```

获取输入事件图标。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 图标纹理；不存在时返回 null。

Schemas:

- `options`: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。

#### `get_event_rich_text`

- API: `public`

```gdscript
func get_event_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
```

获取输入事件 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: BBCode；无法解析时返回空字符串。

Schemas:

- `options`: Dictionary，可包含 allow_missing_paths、icon_size、rich_text_separator、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。

#### `get_event_icon_path`

- API: `public`

```gdscript
func get_event_icon_path(input_event: InputEvent, options: Dictionary = {}) -> String:
```

获取输入事件的首选图标路径。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 图标路径；无法解析时返回空字符串。

Schemas:

- `options`: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。

#### `resolve_event_icon_key`

- API: `public`

```gdscript
func resolve_event_icon_key(input_event: InputEvent, options: Dictionary = {}) -> StringName:
```

获取输入事件的首选图标键。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 图标键；无法解析时返回空 StringName。

Schemas:

- `options`: Dictionary，可包含 split_key_modifiers 和 include_key_modifier_combo。

#### `get_event_icon_candidates`

- API: `public`

```gdscript
func get_event_icon_candidates(input_event: InputEvent, options: Dictionary = {}) -> PackedStringArray:
```

获取输入事件可能使用的图标键列表。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: 图标键列表，按优先级排序。

Schemas:

- `options`: Dictionary，可包含 split_key_modifiers 和 include_key_modifier_combo。

## GFInputIconProvider

- Path: `addons/gf/standard/input/formatting/gf_input_icon_provider.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFInputIconProvider: 输入图标格式化扩展点。 项目可继承此资源，把输入事件映射为 Texture2D 或 RichTextLabel BBCode。

### Properties

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

优先级。数值越大越先尝试。

#### `icon_size`

- API: `public`

```gdscript
var icon_size: int = 24
```

BBCode 图标默认尺寸。小于等于 0 时不写尺寸。

### Methods

#### `get_priority`

- API: `public`

```gdscript
func get_priority() -> int:
```

获取优先级。

Returns: 优先级。

#### `supports_event`

- API: `public`

```gdscript
func supports_event(_input_event: InputEvent, _options: Dictionary = {}) -> bool:
```

判断是否支持指定输入事件。

Parameters:

| Name | Description |
|---|---|
| `_input_event` | 输入事件。 |
| `_options` | 调用选项。 |

Returns: 支持返回 true。

Schemas:

- `_options`: Dictionary，由 GFInputFormatter 传入，包含 provider 特定图标字段。

#### `get_event_icon`

- API: `public`

```gdscript
func get_event_icon(_input_event: InputEvent, _options: Dictionary = {}) -> Texture2D:
```

获取输入事件图标。

Parameters:

| Name | Description |
|---|---|
| `_input_event` | 输入事件。 |
| `_options` | 调用选项。 |

Returns: 图标资源；返回 null 会回退到后续 provider。

Schemas:

- `_options`: Dictionary，由 GFInputFormatter 传入，包含 provider 特定图标字段。

#### `get_event_rich_text`

- API: `public`

```gdscript
func get_event_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
```

获取输入事件 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `input_event` | 输入事件。 |
| `options` | 调用选项。 |

Returns: BBCode；返回空字符串会回退到文本格式化。

Schemas:

- `options`: Dictionary，可包含 icon_size 和 provider 特定富文本字段。

## GFInputMagnitudeModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_magnitude_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputMagnitudeModifier: 输入幅值投影修饰器。 将多轴输入转换为长度值，并按配置写回到指定分量。它只处理向量数值， 不解释这个幅值代表移动、视角、压力或其他业务含义。

### Properties

#### `output_x`

- API: `public`

```gdscript
var output_x: bool = true
```

输出幅值到 X 分量。

#### `output_y`

- API: `public`

```gdscript
var output_y: bool = false
```

输出幅值到 Y 分量。

#### `output_z`

- API: `public`

```gdscript
var output_z: bool = false
```

输出幅值到 Z 分量，仅用于三维输入。

#### `absolute_value`

- API: `public`

```gdscript
var absolute_value: bool = true
```

是否使用绝对值幅值。

#### `preserve_unselected_components`

- API: `public`

```gdscript
var preserve_unselected_components: bool = false
```

非输出分量是否保留原值。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 幅值投影后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 幅值投影后的三维输入值。

## GFInputMapRangeModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_map_range_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputMapRangeModifier: 输入范围映射修饰器。 将输入分量从一个数值范围线性映射到另一个范围，适合灵敏度曲线前后的 简单归一化处理。

### Properties

#### `input_min`

- API: `public`

```gdscript
var input_min: float = 0.0
```

输入最小值。

#### `input_max`

- API: `public`

```gdscript
var input_max: float = 1.0
```

输入最大值。

#### `output_min`

- API: `public`

```gdscript
var output_min: float = 0.0
```

输出最小值。

#### `output_max`

- API: `public`

```gdscript
var output_max: float = 1.0
```

输出最大值。

#### `clamp_output`

- API: `public`

```gdscript
var clamp_output: bool = true
```

是否限制输出到目标范围内。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 范围映射后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 范围映射后的三维输入值。

## GFInputMapping

- Path: `addons/gf/standard/input/mapping/gf_input_mapping.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputMapping: 单个动作的输入绑定集合。

### Properties

#### `action`

- API: `public`

```gdscript
var action: GFInputAction
```

抽象输入动作。

#### `bindings`

- API: `public`

```gdscript
var bindings: Array[GFInputBinding] = []
```

动作绑定列表。多个绑定会合并为同一个动作值。

#### `modifiers`

- API: `public`

```gdscript
var modifiers: Array[GFInputModifier] = []
```

映射级输入修饰器，按顺序作用于该动作聚合后的值。

#### `triggers`

- API: `public`

```gdscript
var triggers: Array[GFInputTrigger] = []
```

可选触发器，全部满足后动作才会被视为活跃。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

可选显示名称覆盖。

#### `display_category`

- API: `public`

```gdscript
var display_category: String = ""
```

可选显示分类覆盖。

### Methods

#### `get_action_id`

- API: `public`

```gdscript
func get_action_id() -> StringName:
```

获取动作标识。

Returns: 稳定动作标识。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取显示名称。

Returns: 显示名称。

#### `get_display_category`

- API: `public`

```gdscript
func get_display_category() -> String:
```

获取显示分类。

Returns: 显示分类。

## GFInputMappingDock

- Path: `addons/gf/standard/input/editor/gf_input_mapping_dock.gd`
- Extends: `Control`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFInputMappingDock: GF 输入映射工作区页面。 读取 GFInputContext 资源，展示动作、绑定与重绑定冲突诊断。

### Methods

#### `set_input_context`

- API: `public`

```gdscript
func set_input_context(context: GFInputContext) -> void:
```

载入输入上下文资源。

Parameters:

| Name | Description |
|---|---|
| `context` | 输入上下文资源。 |

#### `load_context_path`

- API: `public`

```gdscript
func load_context_path(path: String) -> Error:
```

从资源路径载入输入上下文。

Parameters:

| Name | Description |
|---|---|
| `path` | 输入上下文资源路径。 |

Returns: Godot 错误码。

#### `refresh`

- API: `public`

```gdscript
func refresh() -> void:
```

刷新当前上下文诊断。

#### `get_last_report`

- API: `public`

```gdscript
func get_last_report() -> Dictionary:
```

获取最近一次诊断报告。

Returns: 诊断报告副本。

Schemas:

- `return`: Dictionary，基于当前 GFInputContext 构建的校验报告，包含摘要、问题计数、冲突和后续动作。

## GFInputMappingUtility

- Path: `addons/gf/standard/input/runtime/gf_input_mapping_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputMappingUtility: 资源化输入上下文与动作映射运行时。 负责把 Godot InputEvent 转换为项目定义的抽象动作状态，并支持上下文优先级、 运行时重绑定、动作值查询和一次性触发消费。

### Signals

#### `contexts_changed`

- API: `public`

```gdscript
signal contexts_changed(contexts: Array[GFInputContext])
```

启用上下文变化后发出。

Parameters:

| Name | Description |
|---|---|
| `contexts` | 当前启用上下文，已按运行时处理顺序排序。 |

Schemas:

- `contexts`: Array[GFInputContext]，按有效优先级和激活时间戳排序。

#### `mappings_changed`

- API: `public`

```gdscript
signal mappings_changed
```

有效映射变化后发出。

#### `action_value_changed`

- API: `public`

```gdscript
signal action_value_changed(action_id: StringName, value: Variant)
```

动作值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 新动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `action_started`

- API: `public`

```gdscript
signal action_started(action_id: StringName, value: Variant)
```

动作从非活跃变为活跃时发出。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 激活时的动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `action_triggered`

- API: `public`

```gdscript
signal action_triggered(action_id: StringName, value: Variant)
```

动作活跃且收到匹配输入事件时发出。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 当前动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `action_completed`

- API: `public`

```gdscript
signal action_completed(action_id: StringName, value: Variant)
```

动作从活跃变为非活跃时发出。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 完成时的动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `player_action_value_changed`

- API: `public`

```gdscript
signal player_action_value_changed(player_index: int, action_id: StringName, value: Variant)
```

玩家动作值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |
| `value` | 新动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `player_action_started`

- API: `public`

```gdscript
signal player_action_started(player_index: int, action_id: StringName, value: Variant)
```

玩家动作从非活跃变为活跃时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |
| `value` | 激活时的动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `player_action_triggered`

- API: `public`

```gdscript
signal player_action_triggered(player_index: int, action_id: StringName, value: Variant)
```

玩家动作活跃且收到匹配输入事件时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |
| `value` | 当前动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

#### `player_action_completed`

- API: `public`

```gdscript
signal player_action_completed(player_index: int, action_id: StringName, value: Variant)
```

玩家动作从活跃变为非活跃时发出。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |
| `value` | 完成时的动作值。 |

Schemas:

- `value`: Variant，根据动作值类型使用 bool、float、Vector2 或 Vector3。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化输入映射运行时状态并挂载输入路由节点。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放输入路由节点并清理全部运行时状态。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `set_remap_config`

- API: `public`

```gdscript
func set_remap_config(config: GFInputRemapConfig) -> void:
```

设置重映射配置。

Parameters:

| Name | Description |
|---|---|
| `config` | 输入重映射配置；传 null 表示使用默认绑定。 |

#### `get_remap_config`

- API: `public`

```gdscript
func get_remap_config(create_if_missing: bool = false) -> GFInputRemapConfig:
```

获取当前重映射配置。若不存在且 create_if_missing 为 true，会自动创建。

Parameters:

| Name | Description |
|---|---|
| `create_if_missing` | 是否在缺失时创建。 |

Returns: 重映射配置。

#### `enable_context`

- API: `public`

```gdscript
func enable_context(context: GFInputContext, priority: int = 0) -> void:
```

启用输入上下文。

Parameters:

| Name | Description |
|---|---|
| `context` | 输入上下文资源。 |
| `priority` | 优先级，数值越大越先处理。 |

#### `disable_context`

- API: `public`

```gdscript
func disable_context(context: GFInputContext) -> void:
```

禁用输入上下文。

Parameters:

| Name | Description |
|---|---|
| `context` | 输入上下文资源。 |

#### `set_enabled_contexts`

- API: `public`

```gdscript
func set_enabled_contexts(contexts: Array[GFInputContext], priority: int = 0) -> void:
```

批量替换当前启用的上下文。

Parameters:

| Name | Description |
|---|---|
| `contexts` | 输入上下文数组。 |
| `priority` | 批量上下文默认优先级；数组越靠后，同优先级下越先处理。 |

Schemas:

- `contexts`: Array[GFInputContext]，作为新的活跃 context 集启用。

#### `clear_contexts`

- API: `public`

```gdscript
func clear_contexts() -> void:
```

清空所有启用上下文。

#### `is_context_enabled`

- API: `public`

```gdscript
func is_context_enabled(context: GFInputContext) -> bool:
```

检查上下文是否启用。

Parameters:

| Name | Description |
|---|---|
| `context` | 输入上下文资源。 |

Returns: 是否启用。

#### `get_enabled_contexts`

- API: `public`

```gdscript
func get_enabled_contexts() -> Array[GFInputContext]:
```

获取已启用上下文，按实际处理顺序返回。

Returns: 上下文数组。

Schemas:

- `return`: Array[GFInputContext]，按有效优先级和激活时间戳排序。

#### `handle_input_event`

- API: `public`

```gdscript
func handle_input_event(event: InputEvent) -> void:
```

手动处理输入事件。通常由内部路由节点自动调用，也可用于测试或自定义输入桥接。

Parameters:

| Name | Description |
|---|---|
| `event` | Godot 输入事件。 |

#### `create_virtual_source`

- API: `public`

```gdscript
func create_virtual_source( source_id: StringName = &"virtual", player_index: int = -1 ) -> GFVirtualInputSource:
```

创建可编程虚拟输入源。

Parameters:

| Name | Description |
|---|---|
| `source_id` | 虚拟输入源标识。 |
| `player_index` | 玩家索引；小于 0 时只写入全局动作状态。 |

Returns: 虚拟输入源。

#### `set_virtual_action_value`

- API: `public`

```gdscript
func set_virtual_action_value( action_id: StringName, value: Variant, source_id: StringName = &"virtual", player_index: int = -1 ) -> bool:
```

写入虚拟动作值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 动作值。 |
| `source_id` | 虚拟输入源标识。 |
| `player_index` | 玩家索引；小于 0 时只写入全局动作状态。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant，要转换为动作运行时向量贡献的 bool、float、Vector2 或 Vector3 值。

#### `clear_virtual_action`

- API: `public`

```gdscript
func clear_virtual_action( action_id: StringName, source_id: StringName = &"virtual", player_index: int = -1 ) -> bool:
```

清除虚拟动作值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `source_id` | 虚拟输入源标识。 |
| `player_index` | 玩家索引；小于 0 时只清除全局动作状态。 |

Returns: 清除成功返回 true。

#### `clear_virtual_source`

- API: `public`

```gdscript
func clear_virtual_source(source_id: StringName = &"virtual") -> void:
```

清除指定虚拟输入源的所有动作贡献。

Parameters:

| Name | Description |
|---|---|
| `source_id` | 虚拟输入源标识。 |

#### `get_virtual_source_snapshot`

- API: `public`

```gdscript
func get_virtual_source_snapshot(source_id: StringName = &"virtual") -> Dictionary:
```

获取虚拟输入源状态快照。

Parameters:

| Name | Description |
|---|---|
| `source_id` | 虚拟输入源标识。 |

Returns: 快照字典。

Schemas:

- `return`: Dictionary，包含 source_id 和 actions: Array[Dictionary]，action 条目包含 action_id 与 value。

#### `get_action_value`

- API: `public`

```gdscript
func get_action_value(action_id: StringName) -> Variant:
```

获取动作当前值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: bool、float、Vector2 或 Vector3，取决于动作值类型。

Schemas:

- `return`: Variant，根据动作值类型返回 bool、float、Vector2、Vector3 或 null。

#### `get_action_vector`

- API: `public`

```gdscript
func get_action_vector(action_id: StringName) -> Vector2:
```

获取动作当前二维向量值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 二维向量值；三维轴会返回 x/y 分量。

#### `get_action_vector3`

- API: `public`

```gdscript
func get_action_vector3(action_id: StringName) -> Vector3:
```

获取动作当前三维向量值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 三维向量值；非三维动作的 z 分量为 0。

#### `is_action_active`

- API: `public`

```gdscript
func is_action_active(action_id: StringName) -> bool:
```

检查动作是否活跃。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 是否活跃。

#### `was_action_just_started`

- API: `public`

```gdscript
func was_action_just_started(action_id: StringName) -> bool:
```

检查动作是否在当前帧刚刚开始。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 是否刚开始。

#### `was_action_just_completed`

- API: `public`

```gdscript
func was_action_just_completed(action_id: StringName) -> bool:
```

检查动作是否在当前帧刚刚结束。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 是否刚结束。

#### `get_last_completed_duration`

- API: `public`

```gdscript
func get_last_completed_duration(action_id: StringName) -> float:
```

获取动作最近一次结束前的持续活跃时间。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 持续秒数。

#### `consume_action`

- API: `public`

```gdscript
func consume_action(action_id: StringName) -> bool:
```

消费一次刚开始的动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 成功消费返回 true。

#### `get_action_value_for_player`

- API: `public`

```gdscript
func get_action_value_for_player(player_index: int, action_id: StringName) -> Variant:
```

获取指定玩家动作当前值。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: bool、float、Vector2 或 Vector3，取决于动作值类型。

Schemas:

- `return`: Variant，根据动作值类型返回 bool、float、Vector2、Vector3 或 null。

#### `get_action_vector_for_player`

- API: `public`

```gdscript
func get_action_vector_for_player(player_index: int, action_id: StringName) -> Vector2:
```

获取指定玩家动作当前二维向量值。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 二维向量值；三维轴会返回 x/y 分量。

#### `get_action_vector3_for_player`

- API: `public`

```gdscript
func get_action_vector3_for_player(player_index: int, action_id: StringName) -> Vector3:
```

获取指定玩家动作当前三维向量值。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 三维向量值；非三维动作的 z 分量为 0。

#### `is_action_active_for_player`

- API: `public`

```gdscript
func is_action_active_for_player(player_index: int, action_id: StringName) -> bool:
```

检查指定玩家动作是否活跃。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 是否活跃。

#### `was_action_just_started_for_player`

- API: `public`

```gdscript
func was_action_just_started_for_player(player_index: int, action_id: StringName) -> bool:
```

检查指定玩家动作是否在当前帧刚刚开始。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 是否刚开始。

#### `was_action_just_completed_for_player`

- API: `public`

```gdscript
func was_action_just_completed_for_player(player_index: int, action_id: StringName) -> bool:
```

检查指定玩家动作是否在当前帧刚刚结束。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 是否刚结束。

#### `get_last_completed_duration_for_player`

- API: `public`

```gdscript
func get_last_completed_duration_for_player(player_index: int, action_id: StringName) -> float:
```

获取指定玩家动作最近一次结束前的持续活跃时间。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 持续秒数。

#### `consume_action_for_player`

- API: `public`

```gdscript
func consume_action_for_player(player_index: int, action_id: StringName) -> bool:
```

消费指定玩家的一次刚开始动作。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |
| `action_id` | 动作标识。 |

Returns: 成功消费返回 true。

#### `set_binding_override`

- API: `public`

```gdscript
func set_binding_override( context_id: StringName, action_id: StringName, binding_index: int, input_event: InputEvent ) -> void:
```

设置某个绑定的运行时覆盖。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |
| `input_event` | 新输入事件。 |

#### `unbind`

- API: `public`

```gdscript
func unbind(context_id: StringName, action_id: StringName, binding_index: int) -> void:
```

显式解绑某个绑定。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

#### `clear_binding_override`

- API: `public`

```gdscript
func clear_binding_override(context_id: StringName, action_id: StringName, binding_index: int) -> void:
```

清除某个绑定覆盖。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

#### `get_remappable_items`

- API: `public`

```gdscript
func get_remappable_items( context_filter: StringName = &"", display_category_filter: String = "" ) -> Array[Dictionary]:
```

获取可重绑条目。

Parameters:

| Name | Description |
|---|---|
| `context_filter` | 可选上下文过滤。 |
| `display_category_filter` | 可选显示分类过滤。 |

Returns: 条目字典数组。

Schemas:

- `return`: Array[Dictionary]，包含 context、context_id、mapping、action、action_id、binding、binding_index、display_name、display_category 和 event 字段。

#### `clear_input_state`

- API: `public`

```gdscript
func clear_input_state() -> void:
```

清空所有动作运行时状态。

#### `clear_player_input_state`

- API: `public`

```gdscript
func clear_player_input_state(player_index: int) -> void:
```

清空指定玩家动作运行时状态。

Parameters:

| Name | Description |
|---|---|
| `player_index` | 玩家索引。 |

## GFInputModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_modifier.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFInputModifier: 输入值修饰器基类。 修饰器只处理输入值转换，不决定动作是否触发。可挂在 GFInputBinding 或 GFInputMapping 上，用于死区、缩放、归一化、范围映射等通用处理。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修饰输入贡献值。

Parameters:

| Name | Description |
|---|---|
| `value` | 当前二维贡献值；布尔与一维轴使用 x 分量。 |
| `_event` | 产生该贡献的原生输入事件，可能为 null。 |
| `_action` | 当前输入动作。 |

Returns: 修饰后的贡献值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, event: InputEvent = null, action: GFInputAction = null) -> Vector3:
```

修饰三维输入贡献值。 默认复用二维修饰逻辑处理 X/Y，并保留 Z 分量。

Parameters:

| Name | Description |
|---|---|
| `value` | 当前三维贡献值。 |
| `event` | 产生该贡献的原生输入事件，可能为 null。 |
| `action` | 当前输入动作。 |

Returns: 修饰后的三维贡献值。

#### `duplicate_modifier`

- API: `public`

```gdscript
func duplicate_modifier() -> GFInputModifier:
```

创建运行时副本。

Returns: 修饰器副本。

## GFInputNormalizeModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_normalize_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputNormalizeModifier: 输入归一化修饰器。 可避免多个方向叠加后超过单位长度，也可强制非零输入变成单位向量。

### Properties

#### `only_when_over_one`

- API: `public`

```gdscript
var only_when_over_one: bool = true
```

只在长度超过 1 时归一化；关闭后任何非零输入都会归一化。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 归一化后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 归一化后的三维输入值。

## GFInputPlayback

- Path: `addons/gf/standard/input/recording/gf_input_playback.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFInputPlayback: 抽象输入录制回放器。 按时间把 GFInputRecording 中的动作值写入 GFVirtualInputSource，适合测试、 复现、教程或 AI 控制桥接。它只回放抽象动作，不模拟具体键鼠或手柄事件。

### Signals

#### `playback_started`

- API: `public`

```gdscript
signal playback_started(recording: GFInputRecording)
```

回放开始。

Parameters:

| Name | Description |
|---|---|
| `recording` | 回放录制。 |

#### `playback_stopped`

- API: `public`

```gdscript
signal playback_stopped
```

回放停止。

#### `playback_finished`

- API: `public`

```gdscript
signal playback_finished
```

回放自然完成。

#### `event_applied`

- API: `public`

```gdscript
signal event_applied(event: Dictionary)
```

一个录制事件已被应用。

Parameters:

| Name | Description |
|---|---|
| `event` | 事件副本。 |

Schemas:

- `event`: Dictionary，包含 time_seconds、action_id、value、player_index、source_id 和 metadata。

### Properties

#### `recording`

- API: `public`

```gdscript
var recording: GFInputRecording = null
```

当前录制。

#### `source`

- API: `public`

```gdscript
var source: GFVirtualInputSource = null
```

目标虚拟输入源。

#### `speed`

- API: `public`

```gdscript
var speed: float = 1.0
```

回放速度倍率。

#### `loop`

- API: `public`

```gdscript
var loop: bool = false
```

到达末尾后是否循环。

#### `respect_recorded_player_index`

- API: `public`

```gdscript
var respect_recorded_player_index: bool = false
```

为 true 时，事件带 player_index 时会写入对应玩家。

#### `is_playing`

- API: `public`

```gdscript
var is_playing: bool = false
```

当前是否正在播放。

#### `elapsed_seconds`

- API: `public`

```gdscript
var elapsed_seconds: float = 0.0
```

当前回放时间，单位秒。

### Methods

#### `start`

- API: `public`

```gdscript
func start( next_recording: GFInputRecording, next_source: GFVirtualInputSource, restart: bool = true ) -> bool:
```

开始回放。

Parameters:

| Name | Description |
|---|---|
| `next_recording` | 要回放的录制。 |
| `next_source` | 目标虚拟输入源。 |
| `restart` | 是否从头开始。 |

Returns: 成功开始时返回 true。

#### `stop`

- API: `public`

```gdscript
func stop(clear_source: bool = false) -> void:
```

停止回放。

Parameters:

| Name | Description |
|---|---|
| `clear_source` | 是否清空目标虚拟输入源。 |

#### `reset`

- API: `public`

```gdscript
func reset() -> void:
```

重置到起点。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> int:
```

推进回放并应用到期事件。

Parameters:

| Name | Description |
|---|---|
| `delta` | 时间增量，单位秒。 |

Returns: 本次应用的事件数量。

#### `seek`

- API: `public`

```gdscript
func seek(time_seconds: float) -> void:
```

跳转到指定时间。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 目标时间，单位秒。 |

#### `is_finished`

- API: `public`

```gdscript
func is_finished() -> bool:
```

检查是否已到达末尾。

Returns: 到达末尾时返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 is_playing、elapsed_seconds、speed、loop、respect_recorded_player_index、next_event_index、event_count 和 source_id。

## GFInputPressedTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_pressed_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputPressedTrigger: 按下瞬间触发器。 只在输入从非活跃变为活跃的那一次更新中触发，适合确认、跳跃等一次性动作。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 was_active: bool。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 was_active: bool。

## GFInputProfileBank

- Path: `addons/gf/standard/input/mapping/gf_input_profile_bank.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputProfileBank: 命名输入重映射配置集合。 用于保存、切换和复制多个 GFInputRemapConfig。它只管理配置资源， 不规定玩家、存档槽位、UI 展示或项目业务语义。

### Properties

#### `profiles`

- API: `public`

```gdscript
var profiles: Dictionary = {}
```

命名重映射配置。结构为 profile_id -> GFInputRemapConfig。

Schemas:

- `profiles`: Dictionary，以 StringName 或 String profile id 为键，值为 GFInputRemapConfig。

#### `active_profile_id`

- API: `public`

```gdscript
var active_profile_id: StringName = &""
```

当前激活的配置 ID。为空表示尚未选择。

#### `custom_data`

- API: `public`

```gdscript
var custom_data: Dictionary = {}
```

项目自定义数据。框架不解释该字段。

Schemas:

- `custom_data`: Dictionary，项目持有的 UI、存档槽或平台元数据。

### Methods

#### `set_profile`

- API: `public`

```gdscript
func set_profile( profile_id: StringName, config: GFInputRemapConfig, duplicate_config: bool = true ) -> void:
```

设置一个命名配置。默认会深拷贝传入配置，避免外部继续修改污染 bank。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |
| `config` | 输入重映射配置；为 null 时移除该配置。 |
| `duplicate_config` | 是否保存配置副本。 |

#### `ensure_profile`

- API: `public`

```gdscript
func ensure_profile(profile_id: StringName) -> GFInputRemapConfig:
```

确保指定配置存在并返回它。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |

Returns: 现有或新建的重映射配置。

#### `get_profile`

- API: `public`

```gdscript
func get_profile(profile_id: StringName, duplicate_result: bool = false) -> GFInputRemapConfig:
```

获取指定命名配置。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |
| `duplicate_result` | 是否返回深拷贝。 |

Returns: 重映射配置；不存在时返回 null。

#### `has_profile`

- API: `public`

```gdscript
func has_profile(profile_id: StringName) -> bool:
```

检查指定配置是否存在。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |

Returns: 是否存在。

#### `remove_profile`

- API: `public`

```gdscript
func remove_profile(profile_id: StringName) -> bool:
```

移除指定配置。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |

Returns: 成功移除时返回 true。

#### `get_profile_ids`

- API: `public`

```gdscript
func get_profile_ids() -> PackedStringArray:
```

获取所有有效配置 ID。

Returns: 排序后的配置 ID。

#### `clear_profiles`

- API: `public`

```gdscript
func clear_profiles() -> void:
```

清空所有配置。

#### `set_active_profile`

- API: `public`

```gdscript
func set_active_profile(profile_id: StringName) -> bool:
```

设置当前激活配置。

Parameters:

| Name | Description |
|---|---|
| `profile_id` | 配置 ID。 |

Returns: 成功设置时返回 true。

#### `get_active_profile`

- API: `public`

```gdscript
func get_active_profile(duplicate_result: bool = false) -> GFInputRemapConfig:
```

获取当前激活配置。

Parameters:

| Name | Description |
|---|---|
| `duplicate_result` | 是否返回深拷贝。 |

Returns: 当前配置；未设置或不存在时返回 null。

#### `duplicate_bank`

- API: `public`

```gdscript
func duplicate_bank() -> GFInputProfileBank:
```

创建 bank 的深拷贝。

Returns: 新的配置集合。

## GFInputPulseTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_pulse_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputPulseTrigger: 周期脉冲触发器。 输入持续活跃时按固定间隔触发一次，可用于连发、菜单重复导航等通用场景。

### Properties

#### `interval_seconds`

- API: `public`

```gdscript
var interval_seconds: float = 0.1:
```

脉冲间隔秒数。

#### `trigger_immediately`

- API: `public`

```gdscript
var trigger_immediately: bool = true
```

输入首次变为活跃时是否立即触发。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 was_active: bool 和 elapsed: float。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `delta` | 本帧时间增量（秒）。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 was_active: bool 和 elapsed: float。

## GFInputRecording

- Path: `addons/gf/standard/input/recording/gf_input_recording.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFInputRecording: 抽象动作输入录制数据。 记录 action_id、时间、值、玩家索引和元数据，可交给 GFInputPlayback 通过 GFVirtualInputSource 回放。它不读取具体设备，也不绑定任何玩法语义。

### Properties

#### `recording_id`

- API: `public`

```gdscript
var recording_id: StringName = &""
```

录制标识。

#### `duration_seconds`

- API: `public`

```gdscript
var duration_seconds: float = 0.0
```

录制总时长，单位秒。

#### `events`

- API: `public`

```gdscript
var events: Array[Dictionary] = []
```

事件列表。每项包含 time_seconds、action_id、value、player_index、source_id 和 metadata。

Schemas:

- `events`: Array，包含 time_seconds: float、action_id: StringName、value: Variant、player_index: int、source_id: StringName 和 metadata: Dictionary 的 Dictionary 条目。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目持有的录制标签、工具或存档数据。

### Methods

#### `add_event`

- API: `public`

```gdscript
func add_event( action_id: StringName, value: Variant, time_seconds: float, player_index: int = -1, source_id: StringName = &"", event_metadata: Dictionary = {} ) -> Dictionary:
```

添加一个动作值事件。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 动作值。 |
| `time_seconds` | 事件时间，单位秒。 |
| `player_index` | 玩家索引；小于 0 表示不指定。 |
| `source_id` | 可选来源标识。 |
| `event_metadata` | 事件元数据。 |

Returns: 新增事件字典。

Schemas:

- `value`: Variant，要记录的动作值；常见值为 bool、float、Vector2、Vector3，或 GFVariantData 支持的项目自定义数据。
- `event_metadata`: Dictionary，复制到当前事件中供项目诊断或工具使用。
- `return`: Dictionary，包含 time_seconds、action_id、value、player_index、source_id 和 metadata。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空录制。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查录制是否为空。

Returns: 为空时返回 true。

#### `get_event_count`

- API: `public`

```gdscript
func get_event_count() -> int:
```

获取事件数量。

Returns: 事件数量。

#### `sort_events`

- API: `public`

```gdscript
func sort_events() -> void:
```

按事件时间排序。

#### `get_events`

- API: `public`

```gdscript
func get_events() -> Array[Dictionary]:
```

获取事件副本。

Returns: 事件副本数组。

Schemas:

- `return`: Array，包含 time_seconds、action_id、value、player_index、source_id 和 metadata 的 Dictionary 条目。

#### `duplicate_recording`

- API: `public`

```gdscript
func duplicate_recording() -> GFInputRecording:
```

复制录制。

Returns: 新录制。

#### `to_dict`

- API: `public`

```gdscript
func to_dict(json_compatible: bool = false) -> Dictionary:
```

转为字典。

Parameters:

| Name | Description |
|---|---|
| `json_compatible` | 为 true 时会把事件值与元数据转换为 JSON 兼容值。 |

Returns: 录制字典。

Schemas:

- `return`: Dictionary，包含 recording_id: String、duration_seconds: float、events: Array[Dictionary] 和 metadata: Dictionary。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary, json_compatible: bool = false) -> void:
```

从字典恢复录制。

Parameters:

| Name | Description |
|---|---|
| `data` | 录制字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Schemas:

- `data`: Dictionary，包含 recording_id、duration_seconds、events 和 metadata。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary, json_compatible: bool = false) -> GFInputRecording:
```

从字典创建录制。

Parameters:

| Name | Description |
|---|---|
| `data` | 录制字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Returns: 录制。

Schemas:

- `data`: Dictionary，包含 recording_id、duration_seconds、events 和 metadata。

## GFInputReleasedTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_released_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputReleasedTrigger: 释放瞬间触发器。 输入从活跃变为非活跃时触发一次，适合蓄力释放、松手确认等通用交互。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 was_active: bool。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 was_active: bool。

## GFInputRemapConfig

- Path: `addons/gf/standard/input/rebinding/gf_input_remap_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputRemapConfig: 输入重映射配置。 只保存玩家或项目层覆盖过的输入事件，默认绑定仍来自 GFInputContext。

### Properties

#### `remapped_events`

- API: `public`

```gdscript
var remapped_events: Dictionary = {}
```

重绑定输入。结构为 context_id -> action_id -> binding_index -> InputEvent 或 null。

Schemas:

- `remapped_events`: Dictionary，按 context_id、action_id、binding_index 分层索引，值为 InputEvent 或表示显式解绑的 null。

#### `custom_data`

- API: `public`

```gdscript
var custom_data: Dictionary = {}
```

项目自定义数据。框架不解释该字段。

Schemas:

- `custom_data`: Dictionary，项目持有的 profile 标签、设备元数据或 UI 状态。

### Methods

#### `set_binding`

- API: `public`

```gdscript
func set_binding( context_id: StringName, action_id: StringName, binding_index: int, input_event: InputEvent ) -> void:
```

设置绑定覆盖。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |
| `input_event` | 新输入事件；null 表示显式解绑。 |

#### `unbind`

- API: `public`

```gdscript
func unbind(context_id: StringName, action_id: StringName, binding_index: int) -> void:
```

显式解绑某个绑定。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

#### `clear_binding`

- API: `public`

```gdscript
func clear_binding(context_id: StringName, action_id: StringName, binding_index: int) -> void:
```

清除某个覆盖，使其回退到默认绑定。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

#### `has_binding`

- API: `public`

```gdscript
func has_binding(context_id: StringName, action_id: StringName, binding_index: int) -> bool:
```

检查是否存在覆盖记录。显式解绑也会返回 true。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

Returns: 是否存在覆盖。

#### `get_bound_event_or_null`

- API: `public`

```gdscript
func get_bound_event_or_null(context_id: StringName, action_id: StringName, binding_index: int) -> InputEvent:
```

获取覆盖输入事件。

Parameters:

| Name | Description |
|---|---|
| `context_id` | 上下文标识。 |
| `action_id` | 动作标识。 |
| `binding_index` | 绑定索引。 |

Returns: 覆盖事件；显式解绑或未覆盖时均可能返回 null，应先调用 has_binding() 区分。

#### `set_custom_data`

- API: `public`

```gdscript
func set_custom_data(key: Variant, value: Variant) -> void:
```

设置自定义数据。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `value` | 值。 |

Schemas:

- `key`: Variant，项目侧自定义数据键。
- `value`: Variant，项目侧自定义数据值。

#### `get_custom_data`

- API: `public`

```gdscript
func get_custom_data(key: Variant, default_value: Variant = null) -> Variant:
```

获取自定义数据。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `default_value` | 默认值。 |

Returns: 自定义数据。

Schemas:

- `key`: Variant，项目侧自定义数据键。
- `default_value`: Variant，key 不存在时返回的默认值。
- `return`: Variant，自定义数据值或 default_value。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为可写入 JSON/存档的 Dictionary。

Returns: 重映射配置字典。

Schemas:

- `return`: Dictionary，包含 remapped_events 和 custom_data；remapped_events 为 context_id -> action_id -> binding_index -> event record。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用由 to_dict() 生成的重映射配置。

Parameters:

| Name | Description |
|---|---|
| `data` | 重映射配置字典。 |

Schemas:

- `data`: Dictionary，包含 remapped_events 和 custom_data。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFInputRemapConfig:
```

从 Dictionary 创建重映射配置。

Parameters:

| Name | Description |
|---|---|
| `data` | 重映射配置字典。 |

Returns: 新重映射配置。

Schemas:

- `data`: Dictionary，包含 remapped_events 和 custom_data。

#### `duplicate_config`

- API: `public`

```gdscript
func duplicate_config() -> GFInputRemapConfig:
```

复制重映射配置。

Returns: 深拷贝后的重映射配置。

## GFInputScaleModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_scale_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputScaleModifier: 输入缩放修饰器。 适合统一调节轴灵敏度、反转某个方向或压低虚拟摇杆输出。

### Properties

#### `scale_x`

- API: `public`

```gdscript
var scale_x: float = 1.0
```

X 分量缩放。

#### `scale_y`

- API: `public`

```gdscript
var scale_y: float = 1.0
```

Y 分量缩放。

#### `scale_z`

- API: `public`

```gdscript
var scale_z: float = 1.0
```

Z 分量缩放，仅用于三维轴动作。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 缩放后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 缩放后的三维输入值。

## GFInputSequenceBranch

- Path: `addons/gf/standard/input/sequences/gf_input_sequence_branch.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputSequenceBranch: 输入序列触发器的一条可选分支。 多分支允许同一动作由不同抽象动作序列触发，适合格斗、快捷指令或可替代输入路径。

### Properties

#### `steps`

- API: `public`

```gdscript
var steps: Array[GFInputSequenceStep] = []
```

本分支的步骤列表。

#### `max_gap_seconds`

- API: `public`

```gdscript
var max_gap_seconds: float = -1.0:
```

本分支默认最大步骤间隔。小于 0 表示使用触发器默认值，0 表示不限制。

### Methods

#### `is_valid_branch`

- API: `public`

```gdscript
func is_valid_branch() -> bool:
```

检查分支是否至少包含一个有效动作步骤。

Returns: 有效返回 true。

#### `duplicate_branch`

- API: `public`

```gdscript
func duplicate_branch() -> GFInputSequenceBranch:
```

创建当前分支的深拷贝。

Returns: 分支副本。

#### `from_action_ids`

- API: `public`

```gdscript
static func from_action_ids( action_ids: Array[StringName], p_max_gap_seconds: float = -1.0 ) -> GFInputSequenceBranch:
```

从动作 ID 数组创建分支。

Parameters:

| Name | Description |
|---|---|
| `action_ids` | 动作 ID 数组。 |
| `p_max_gap_seconds` | 默认最大步骤间隔。 |

Returns: 新分支。

Schemas:

- `action_ids`: Array[StringName]，会复制到 GFInputSequenceStep 资源中。

## GFInputSequenceStep

- Path: `addons/gf/standard/input/sequences/gf_input_sequence_step.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputSequenceStep: 输入序列中的单个抽象动作步骤。 步骤只描述动作 ID、间隔和按住/释放条件，不绑定具体按键或业务语义。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

需要匹配的抽象动作 ID。

#### `max_gap_seconds`

- API: `public`

```gdscript
var max_gap_seconds: float = -1.0:
```

从上一完成步骤到本步骤开始允许的最大间隔。小于 0 表示使用分支或触发器默认值，0 表示不限制。

#### `min_hold_seconds`

- API: `public`

```gdscript
var min_hold_seconds: float = 0.0:
```

动作需要保持活跃的最短时间。

#### `trigger_on_release`

- API: `public`

```gdscript
var trigger_on_release: bool = false
```

是否在动作释放时完成本步骤。

### Methods

#### `duplicate_step`

- API: `public`

```gdscript
func duplicate_step() -> GFInputSequenceStep:
```

创建当前步骤的深拷贝。

Returns: 步骤副本。

#### `from_action_id`

- API: `public`

```gdscript
static func from_action_id(p_action_id: StringName) -> GFInputSequenceStep:
```

创建只包含动作 ID 的步骤。

Parameters:

| Name | Description |
|---|---|
| `p_action_id` | 动作 ID。 |

Returns: 新步骤。

## GFInputSequenceTrigger

- Path: `addons/gf/standard/input/sequences/gf_input_sequence_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputSequenceTrigger: 动作序列触发器。 按顺序观察一组前置动作的 just-started 状态，全部完成后当前输入活跃时触发。

### Properties

#### `required_action_ids`

- API: `public`

```gdscript
var required_action_ids: Array[StringName] = []
```

当前动作触发前必须依次开始的动作列表。

Schemas:

- `required_action_ids`: Array[StringName] of action ids that must start in order before this trigger can fire.

#### `branches`

- API: `public`

```gdscript
var branches: Array[GFInputSequenceBranch] = []
```

可选输入序列分支。非空时优先使用分支配置，required_action_ids 保持兼容旧资源。

#### `max_gap_seconds`

- API: `public`

```gdscript
var max_gap_seconds: float = 0.4:
```

相邻步骤允许的最大间隔。小于等于 0 表示不限制。

#### `player_scoped`

- API: `public`

```gdscript
var player_scoped: bool = true
```

玩家级动作是否只检查同一玩家。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 sequence_index、gap_elapsed、completed 和 branch_states。

#### `prepare_runtime`

- API: `public`

```gdscript
func prepare_runtime( _action_id: StringName, input_runtime: Object, player_index: int, state: Dictionary ) -> void:
```

准备输入动作运行时状态。

Parameters:

| Name | Description |
|---|---|
| `_action_id` | 当前输入动作标识，默认实现不直接使用。 |
| `input_runtime` | 输入映射运行时。 |
| `player_index` | 玩家索引。 |
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 input_runtime: Object 和 player_index: int。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `delta` | 本帧时间增量（秒）。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含分支进度字段。

## GFInputSignClampModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_sign_clamp_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputSignClampModifier: 输入符号方向限制修饰器。 用于只保留正向或负向输入分量，也可以把保留的负向分量重新映射为正值。

### Enums

#### `AllowedSign`

- API: `public`

```gdscript
enum AllowedSign { ## 只保留大于等于 0 的值。 POSITIVE, ## 只保留小于等于 0 的值。 NEGATIVE, }
```

允许通过的符号方向。

### Properties

#### `allowed_sign`

- API: `public`

```gdscript
var allowed_sign: AllowedSign = AllowedSign.POSITIVE
```

允许通过的符号方向。

#### `apply_x`

- API: `public`

```gdscript
var apply_x: bool = true
```

是否处理 X 分量。

#### `apply_y`

- API: `public`

```gdscript
var apply_y: bool = true
```

是否处理 Y 分量。

#### `apply_z`

- API: `public`

```gdscript
var apply_z: bool = true
```

是否处理 Z 分量。

#### `remap_to_positive`

- API: `public`

```gdscript
var remap_to_positive: bool = false
```

是否把保留的负向分量转为正值。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 符号过滤后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 符号过滤后的三维输入值。

## GFInputSwizzleModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_swizzle_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputSwizzleModifier: 输入分量重排修饰器。 用于把二维或三维输入轴按通用顺序重排，适合在不改绑定资源的情况下 调整轴方向约定。

### Enums

#### `SwizzleOrder`

- API: `public`

```gdscript
enum SwizzleOrder { ## 保持 X/Y/Z。 XYZ, ## 输出 X/Z/Y。 XZY, ## 输出 Y/X/Z。 YXZ, ## 输出 Y/Z/X。 YZX, ## 输出 Z/X/Y。 ZXY, ## 输出 Z/Y/X。 ZYX, }
```

分量重排顺序。

### Properties

#### `order`

- API: `public`

```gdscript
var order: SwizzleOrder = SwizzleOrder.XYZ
```

分量重排顺序。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 分量重排后的二维输入值。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, _event: InputEvent = null, _action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 分量重排后的三维输入值。

## GFInputTapTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_tap_trigger.gd`
- Extends: `GFInputTrigger`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputTapTrigger: 短按触发器。 输入按下后在指定时间窗口内释放时触发一次。

### Properties

#### `min_tap_seconds`

- API: `public`

```gdscript
var min_tap_seconds: float = 0.0:
```

最短按住时间。

#### `max_tap_seconds`

- API: `public`

```gdscript
var max_tap_seconds: float = 0.25:
```

最长按住时间。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置输入触发器运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 触发器运行时状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时持有，包含 was_active: bool 和 elapsed: float。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
```

更新运行时状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否处于激活状态。 |
| `_value` | 输入值，默认实现不直接使用。 |
| `delta` | 本帧时间增量（秒）。 |
| `state` | 触发器运行时状态字典。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `state`: Dictionary，由输入运行时持有，包含 was_active: bool 和 elapsed: float。

## GFInputTextProvider

- Path: `addons/gf/standard/input/formatting/gf_input_text_provider.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFInputTextProvider: 输入文本格式化扩展点。 项目可继承此资源，为特定设备、平台、本地化或图标字体提供自定义文本。

### Properties

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

优先级。数值越大越先尝试。

### Methods

#### `get_priority`

- API: `public`

```gdscript
func get_priority() -> int:
```

获取优先级。

Returns: 优先级。

#### `supports_event`

- API: `public`

```gdscript
func supports_event(_input_event: InputEvent, _options: Dictionary = {}) -> bool:
```

判断是否支持指定输入事件。

Parameters:

| Name | Description |
|---|---|
| `_input_event` | 输入事件。 |
| `_options` | 调用选项。 |

Returns: 支持返回 true。

Schemas:

- `_options`: Dictionary，由 GFInputFormatter 传入，包含 provider 特定格式化字段。

#### `get_event_text`

- API: `public`

```gdscript
func get_event_text(_input_event: InputEvent, _options: Dictionary = {}) -> String:
```

获取输入事件文本。

Parameters:

| Name | Description |
|---|---|
| `_input_event` | 输入事件。 |
| `_options` | 调用选项。 |

Returns: 文本；返回空字符串会回退到后续 provider 或默认格式化。

Schemas:

- `_options`: Dictionary，由 GFInputFormatter 传入，包含 provider 特定格式化字段。

## GFInputTrigger

- Path: `addons/gf/standard/input/triggers/gf_input_trigger.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFInputTrigger: 输入动作触发器基类。 触发器只决定“原始输入活跃后何时视为动作活跃”，不修改输入值。运行时状态由 GFInputMappingUtility 传入的 Dictionary 保存，因此同一资源可被多个上下文复用。

### Enums

#### `TriggerState`

- API: `public`

```gdscript
enum TriggerState { ## 输入未达到触发条件。 INACTIVE, ## 输入正在等待触发条件，例如长按计时中。 ONGOING, ## 输入已满足触发条件。 TRIGGERED, }
```

触发器本次更新后的动作状态。

### Methods

#### `reset_trigger_state`

- API: `public`

```gdscript
func reset_trigger_state(state: Dictionary) -> void:
```

重置运行时状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 由调用方保存的状态字典。 |

Schemas:

- `state`: Dictionary，由输入运行时为当前 trigger 实例持有。

#### `prepare_runtime`

- API: `public`

```gdscript
func prepare_runtime( _action_id: StringName, _input_runtime: Object, _player_index: int, _state: Dictionary ) -> void:
```

更新前注入运行时上下文。

Parameters:

| Name | Description |
|---|---|
| `_action_id` | 当前动作标识。 |
| `_input_runtime` | 输入映射运行时。 |
| `_player_index` | 玩家索引；全局动作传 -1。 |
| `_state` | 该触发器的运行时状态。 |

Schemas:

- `_state`: Dictionary，由输入运行时为当前 trigger 实例持有。

#### `update`

- API: `public`

```gdscript
func update(raw_active: bool, _value: Variant, _delta: float, _state: Dictionary) -> TriggerState:
```

更新触发器状态。

Parameters:

| Name | Description |
|---|---|
| `raw_active` | 原始输入是否活跃。 |
| `_value` | 当前动作值。 |
| `_delta` | 本次更新经过的秒数；事件驱动刷新时可能为 0。 |
| `_state` | 该触发器的运行时状态。 |

Returns: 触发状态。

Schemas:

- `_value`: Variant，由当前输入映射产生的动作值。
- `_state`: Dictionary，由输入运行时为当前 trigger 实例持有。

#### `duplicate_trigger`

- API: `public`

```gdscript
func duplicate_trigger() -> GFInputTrigger:
```

创建运行时副本。

Returns: 触发器副本。

## GFInputVirtualCursorModifier

- Path: `addons/gf/standard/input/modifiers/gf_input_virtual_cursor_modifier.gd`
- Extends: `GFInputModifier`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInputVirtualCursorModifier: 虚拟光标输入修饰器。 将二维输入视为速度并积分为一个位置值。它只维护抽象坐标，不访问 Viewport、 Control 或具体 UI 节点。

### Properties

#### `initial_position`

- API: `public`

```gdscript
var initial_position: Vector2 = Vector2(0.5, 0.5)
```

初始位置。

#### `speed`

- API: `public`

```gdscript
var speed: Vector2 = Vector2.ONE
```

每秒移动速度倍率。

#### `apply_delta_time`

- API: `public`

```gdscript
var apply_delta_time: bool = true
```

是否按真实经过时间缩放输入。

#### `clamp_to_rect`

- API: `public`

```gdscript
var clamp_to_rect: bool = true
```

是否将位置限制在 clamp_rect 内。

#### `clamp_rect`

- API: `public`

```gdscript
var clamp_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE)
```

可用位置范围。

#### `idle_threshold`

- API: `public`

```gdscript
var idle_threshold: float = 0.0
```

输入低于该长度时视为空闲。

#### `reset_when_idle`

- API: `public`

```gdscript
var reset_when_idle: bool = false
```

空闲时是否回到 initial_position。

#### `position`

- API: `public`

```gdscript
var position: Vector2 = Vector2(0.5, 0.5)
```

当前虚拟光标位置。

### Methods

#### `modify`

- API: `public`

```gdscript
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
```

修改二维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `_event` | 原始输入事件，默认实现不直接使用。 |
| `_action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 更新后的虚拟光标位置。

#### `modify_3d`

- API: `public`

```gdscript
func modify_3d(value: Vector3, event: InputEvent = null, action: GFInputAction = null) -> Vector3:
```

修改三维输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 要写入或修改的值。 |
| `event` | 原始输入事件，默认实现不直接使用。 |
| `action` | 当前输入动作配置，默认实现不直接使用。 |

Returns: 包含虚拟光标 X/Y 和原 Z 分量的三维值。

#### `reset_position`

- API: `public`

```gdscript
func reset_position() -> GFInputVirtualCursorModifier:
```

重置虚拟光标位置。

Returns: 当前修饰器。

#### `duplicate_modifier`

- API: `public`

```gdscript
func duplicate_modifier() -> GFInputModifier:
```

创建运行时副本。

Returns: 修饰器副本。

## GFJob

- Path: `addons/gf/standard/utilities/jobs/gf_job.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFJob: 通用异步/分帧任务记录。 只保存任务状态、进度、输入数据、结果和错误文本，不绑定具体业务。

### Enums

#### `Status`

- API: `public`

```gdscript
enum Status { ## 已入队，尚未开始执行。 WAITING, ## 正在执行。 ACTIVE, ## 已成功完成。 COMPLETED, ## 已失败。 FAILED, ## 已取消。 CANCELLED, }
```

任务生命周期状态。

### Properties

#### `job_id`

- API: `public`

```gdscript
var job_id: StringName = &""
```

任务 ID。

#### `queue_name`

- API: `public`

```gdscript
var queue_name: StringName = &"default"
```

队列名。

#### `status`

- API: `public`

```gdscript
var status: Status = Status.WAITING
```

当前状态。

#### `data`

- API: `public`

```gdscript
var data: Variant = null
```

任务输入数据。框架不解释该字段。

Schemas:

- `data`: Variant，项目侧任务输入载荷。

#### `result`

- API: `public`

```gdscript
var result: Variant = null
```

任务结果。框架不解释该字段。

Schemas:

- `result`: Variant，项目侧任务结果载荷。

#### `error_message`

- API: `public`

```gdscript
var error_message: String = ""
```

错误文本。

#### `progress`

- API: `public`

```gdscript
var progress: float = 0.0
```

进度，范围建议为 0.0 到 1.0。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，复制到任务中的项目侧元数据。

#### `created_msec`

- API: `public`

```gdscript
var created_msec: int = 0
```

创建时间。

#### `started_msec`

- API: `public`

```gdscript
var started_msec: int = 0
```

开始时间。

#### `finished_msec`

- API: `public`

```gdscript
var finished_msec: int = 0
```

结束时间。

### Methods

#### `is_finished`

- API: `public`

```gdscript
func is_finished() -> bool:
```

当前任务是否已经进入终态。

Returns: 已完成、失败或取消时返回 true。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary。

Returns: 任务字典。

Schemas:

- `return`: Dictionary，包含 job_id、queue_name、status、status_name、progress、error_message、metadata、时间戳和 has_result。

#### `status_name`

- API: `public`

```gdscript
static func status_name(value: Status) -> String:
```

获取状态名称。

Parameters:

| Name | Description |
|---|---|
| `value` | 状态枚举值。 |

Returns: 状态名称。

## GFJobQueueUtility

- Path: `addons/gf/standard/utilities/jobs/gf_job_queue_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFJobQueueUtility: 通用任务队列工具。 提供等待、激活、完成、失败、取消、进度和调试快照能力。 队列不绑定执行线程或业务语义，具体执行由调用方决定。

### Signals

#### `job_enqueued`

- API: `public`

```gdscript
signal job_enqueued(job: GFJob)
```

任务进入等待队列时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |

#### `job_started`

- API: `public`

```gdscript
signal job_started(job: GFJob)
```

任务开始执行时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |

#### `job_progressed`

- API: `public`

```gdscript
signal job_progressed(job: GFJob, progress: float, message: String)
```

任务进度变化时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |
| `progress` | 当前进度。 |
| `message` | 进度说明。 |

#### `job_completed`

- API: `public`

```gdscript
signal job_completed(job: GFJob)
```

任务完成时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |

#### `job_failed`

- API: `public`

```gdscript
signal job_failed(job: GFJob)
```

任务失败时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |

#### `job_cancelled`

- API: `public`

```gdscript
signal job_cancelled(job: GFJob)
```

任务取消时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 任务记录。 |

### Properties

#### `max_completed_jobs`

- API: `public`

```gdscript
var max_completed_jobs: int = 64
```

保留的完成任务数量。

#### `max_failed_jobs`

- API: `public`

```gdscript
var max_failed_jobs: int = 64
```

保留的失败任务数量。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化任务队列工具并清空运行时状态。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放任务队列工具持有的运行时状态。

#### `enqueue`

- API: `public`

```gdscript
func enqueue( queue_name: StringName = &"default", data: Variant = null, metadata: Dictionary = {}, front: bool = false ) -> GFJob:
```

追加一个等待任务。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |
| `data` | 任务输入数据。 |
| `metadata` | 项目自定义元数据。 |
| `front` | 是否插入到队列头部。 |

Returns: 新任务记录。

Schemas:

- `data`: Variant，项目侧任务输入载荷。
- `metadata`: Dictionary，复制到新建 GFJob 的元数据。

#### `start_next_job`

- API: `public`

```gdscript
func start_next_job(queue_name: StringName = &"default") -> GFJob:
```

从队列取出下一个等待任务并标记为执行中。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |

Returns: 任务记录；没有可执行任务时返回 null。

#### `run_next_job`

- API: `public`

```gdscript
func run_next_job(queue_name: StringName, processor: Callable) -> GFJob:
```

使用回调立即处理下一个等待任务。回调返回 false 或 ok=false 字典时标记失败。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |
| `processor` | 任务处理回调。 |

Returns: 被处理的任务；没有可执行任务时返回 null。

#### `update_job_progress`

- API: `public`

```gdscript
func update_job_progress(job_id: StringName, progress: float, message: String = "") -> bool:
```

更新任务进度。

Parameters:

| Name | Description |
|---|---|
| `job_id` | 任务 ID。 |
| `progress` | 当前进度。 |
| `message` | 进度说明。 |

Returns: 更新成功返回 true。

#### `complete_job`

- API: `public`

```gdscript
func complete_job(job_id: StringName, result: Variant = null) -> bool:
```

标记任务完成。

Parameters:

| Name | Description |
|---|---|
| `job_id` | 任务 ID。 |
| `result` | 任务结果。 |

Returns: 完成成功返回 true。

Schemas:

- `result`: Variant，项目侧任务结果载荷。

#### `fail_job`

- API: `public`

```gdscript
func fail_job(job_id: StringName, error_message: String = "", result: Variant = null) -> bool:
```

标记任务失败。

Parameters:

| Name | Description |
|---|---|
| `job_id` | 任务 ID。 |
| `error_message` | 错误文本。 |
| `result` | 可选失败结果。 |

Returns: 标记成功返回 true。

Schemas:

- `result`: Variant，项目侧失败结果载荷。

#### `cancel_job`

- API: `public`

```gdscript
func cancel_job(job_id: StringName) -> bool:
```

取消任务。

Parameters:

| Name | Description |
|---|---|
| `job_id` | 任务 ID。 |

Returns: 取消成功返回 true。

#### `pause_queue`

- API: `public`

```gdscript
func pause_queue(queue_name: StringName = &"default") -> void:
```

暂停指定队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |

#### `resume_queue`

- API: `public`

```gdscript
func resume_queue(queue_name: StringName = &"default") -> void:
```

恢复指定队列。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |

#### `is_queue_paused`

- API: `public`

```gdscript
func is_queue_paused(queue_name: StringName = &"default") -> bool:
```

检查队列是否暂停。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |

Returns: 暂停时返回 true。

#### `get_job`

- API: `public`

```gdscript
func get_job(job_id: StringName) -> GFJob:
```

获取任务。

Parameters:

| Name | Description |
|---|---|
| `job_id` | 任务 ID。 |

Returns: 任务记录；不存在时返回 null。

#### `get_waiting_jobs`

- API: `public`

```gdscript
func get_waiting_jobs(queue_name: StringName = &"default") -> Array[GFJob]:
```

获取队列中的等待任务。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |

Returns: 等待任务列表副本。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue(queue_name: StringName = &"default", cancel_jobs: bool = true) -> void:
```

清空指定队列中的等待任务。

Parameters:

| Name | Description |
|---|---|
| `queue_name` | 队列名。 |
| `cancel_jobs` | 是否把等待任务标记为取消。 |

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清空全部队列与历史任务。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含 job_count、queue_count、completed_count、failed_count，以及以队列名为键的 queues。

## GFJobWorker

- Path: `addons/gf/standard/utilities/jobs/gf_job_worker.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFJobWorker: 通用任务队列消费节点。 从 `GFJobQueueUtility` 中按批次取出等待任务，并交给项目提供的 Callable 处理。 Worker 只管理执行节奏和完成/失败写回，不规定任务数据结构或业务语义。

### Signals

#### `worker_started`

- API: `public`

```gdscript
signal worker_started
```

Worker 开始运行时发出。

#### `worker_stopped`

- API: `public`

```gdscript
signal worker_stopped
```

Worker 停止运行时发出。

#### `job_processed`

- API: `public`

```gdscript
signal job_processed(job: GFJob)
```

任务处理完成时发出。

Parameters:

| Name | Description |
|---|---|
| `job` | 被处理的任务。 |

#### `worker_idle`

- API: `public`

```gdscript
signal worker_idle
```

没有可处理任务时发出。

### Properties

#### `queue_name`

- API: `public`

```gdscript
var queue_name: StringName = &"default"
```

消费的队列名。

#### `batch_size`

- API: `public`

```gdscript
var batch_size: int = 1
```

每次处理的最大任务数量。

#### `auto_start`

- API: `public`

```gdscript
var auto_start: bool = true
```

ready 后是否自动开始。

#### `process_in_physics`

- API: `public`

```gdscript
var process_in_physics: bool = false
```

是否在 physics process 中消费任务。

#### `process_while_paused`

- API: `public`

```gdscript
var process_while_paused: bool = false
```

SceneTree 暂停时是否继续处理。

#### `signal_timeout_seconds`

- API: `public`

```gdscript
var signal_timeout_seconds: float = 30.0
```

等待异步任务处理器 Signal 的最长秒数。小于等于 0 时不启用超时。

#### `signal_timeout_respects_time_scale`

- API: `public`

```gdscript
var signal_timeout_respects_time_scale: bool = true
```

Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。

#### `queue_utility`

- API: `public`

```gdscript
var queue_utility: GFJobQueueUtility = null
```

可选任务队列工具实例；为空时从全局架构查询。

#### `processor`

- API: `public`

```gdscript
var processor: Callable = Callable()
```

任务处理器，签名推荐为 `func(job: GFJob) -> Variant`。

### Methods

#### `set_queue_utility`

- API: `public`

```gdscript
func set_queue_utility(utility: GFJobQueueUtility) -> void:
```

设置任务队列工具实例。

Parameters:

| Name | Description |
|---|---|
| `utility` | 任务队列工具实例。 |

#### `set_processor`

- API: `public`

```gdscript
func set_processor(job_processor: Callable) -> void:
```

设置任务处理器。

Parameters:

| Name | Description |
|---|---|
| `job_processor` | 任务处理器。 |

#### `start`

- API: `public`

```gdscript
func start() -> void:
```

开始消费任务。

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

停止消费任务。

#### `is_running`

- API: `public`

```gdscript
func is_running() -> bool:
```

检查 Worker 是否正在运行。

Returns: 正在运行返回 true。

#### `process_next_job`

- API: `public`

```gdscript
func process_next_job() -> GFJob:
```

处理一个任务。

Returns: 被处理的任务；没有任务或不可处理时返回 null。

#### `process_batch`

- API: `public`

```gdscript
func process_batch() -> int:
```

按 batch_size 处理一批任务。

Returns: 实际处理数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取 Worker 调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 running、processing、queue_name、batch_size、has_processor 和 has_queue_utility。

## GFJsonLineLogSink

- Path: `addons/gf/standard/utilities/logging/gf_json_line_log_sink.gd`
- Extends: `GFLogSink`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFJsonLineLogSink: 把结构化日志条目写入 JSON Lines 文件。 该 sink 只负责把 GFLogUtility 传入的条目序列化为一行一个 JSON 对象， 不规定采集服务、上传时机或业务字段 schema。

### Properties

#### `file_path`

- API: `public`

```gdscript
var file_path: String = ""
```

输出文件路径。留空时会根据 GFLogUtility 当前日志文件派生同名 `.jsonl` 文件。

#### `omit_formatted_text`

- API: `public`

```gdscript
var omit_formatted_text: bool = false
```

是否在写入前移除 `text` 字段，减少重复存储。

#### `flush_interval_msec`

- API: `public`

```gdscript
var flush_interval_msec: int = 250
```

文件自动 flush 间隔。设为 0 时每条日志都会立即 flush。

#### `flush_immediately`

- API: `public`

```gdscript
var flush_immediately: bool = false
```

是否强制每条 JSONL 日志立即 flush。

#### `max_jsonl_files`

- API: `public`

```gdscript
var max_jsonl_files: int = 10:
```

使用默认派生路径时最多保留的 JSONL 文件数量。

### Methods

#### `init`

- API: `public`

```gdscript
func init(owner: Object) -> void:
```

初始化 sink 并打开 JSONL 文件。

Parameters:

| Name | Description |
|---|---|
| `owner` | 持有该 sink 的日志工具。 |

#### `write`

- API: `public`

```gdscript
func write(entry: Dictionary) -> void:
```

写入一条结构化日志。

Parameters:

| Name | Description |
|---|---|
| `entry` | 日志条目字典。 |

Schemas:

- `entry`: Dictionary log entry produced by GFLogUtility.

#### `flush`

- API: `public`

```gdscript
func flush() -> void:
```

刷新尚未写出的 JSONL 内容。

#### `shutdown`

- API: `public`

```gdscript
func shutdown() -> void:
```

关闭文件句柄。

#### `get_file_path`

- API: `public`

```gdscript
func get_file_path() -> String:
```

获取当前实际输出路径。

Returns: JSONL 文件路径。

## GFLogSink

- Path: `addons/gf/standard/utilities/logging/gf_log_sink.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFLogSink: 日志输出 sink 基类。 项目可以继承该类，把 GFLogUtility 的结构化日志条目写入 JSONL、 远端采集、编辑器面板或其他自定义目标。Sink 不拥有日志工具生命周期， 只响应 init/write/flush/shutdown 钩子。

### Methods

#### `init`

- API: `public`

```gdscript
func init(_owner: Object) -> void:
```

初始化 sink。

Parameters:

| Name | Description |
|---|---|
| `_owner` | 持有该 sink 的日志工具。 |

#### `write`

- API: `public`

```gdscript
func write(_entry: Dictionary) -> void:
```

写入一条结构化日志。

Parameters:

| Name | Description |
|---|---|
| `_entry` | 日志条目字典。 |

Schemas:

- `_entry`: Dictionary log entry produced by GFLogUtility.

#### `flush`

- API: `public`

```gdscript
func flush() -> void:
```

刷新尚未写出的缓冲。

#### `shutdown`

- API: `public`

```gdscript
func shutdown() -> void:
```

关闭 sink 并释放内部资源。

## GFLogUtility

- Path: `addons/gf/standard/utilities/logging/gf_log_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFLogUtility: 集中式日志系统。 取代原生 print / push_error，提供分级日志（DEBUG → FATAL）， 每条日志同时写入本地按日期命名的日志文件，进入内存环形缓存， 并通过信号和可插拔 sink 广播结构化日志条目。

### Signals

#### `log_emitted`

- API: `public`

```gdscript
signal log_emitted(level: int, tag: String, message: String)
```

每次打印日志时发出，供 UI 控制台等消费者捕捉。

Parameters:

| Name | Description |
|---|---|
| `level` | LogLevel 枚举值。 |
| `tag` | 日志标签。 |
| `message` | 日志内容。 |

#### `log_entry_emitted`

- API: `public`

```gdscript
signal log_entry_emitted(entry: Dictionary)
```

每次打印日志时发出完整结构化条目。

Parameters:

| Name | Description |
|---|---|
| `entry` | 日志条目副本。 |

Schemas:

- `entry`: Dictionary log entry with timestamp, unix_time, ticks_msec, trace_id, level, level_name, tag, message, context, and text.

#### `previous_crash_detected`

- API: `public`

```gdscript
signal previous_crash_detected(marker: Dictionary)
```

初始化时检测到上次运行未干净关闭后发出。

Parameters:

| Name | Description |
|---|---|
| `marker` | 上次运行留下的标记数据。 |

Schemas:

- `marker`: Dictionary crash marker with trace_id, started_at, and ticks_msec when available.

### Enums

#### `LogLevel`

- API: `public`

```gdscript
enum LogLevel { ## 调试信息 DEBUG, ## 一般信息 INFO, ## 警告 WARN, ## 错误 ERROR, ## 致命错误 FATAL, }
```

日志等级，数值越大越严重。

### Properties

#### `max_log_files`

- API: `public`

```gdscript
var max_log_files: int:
```

最多保留的日志文件数量。

#### `flush_interval_msec`

- API: `public`

```gdscript
var flush_interval_msec: int = 250
```

日志文件自动 flush 间隔。设为 0 时每条日志都立即 flush。

#### `flush_immediately`

- API: `public`

```gdscript
var flush_immediately: bool = false
```

是否强制每条日志立即 flush。高可靠日志可开启，默认关闭以减少高频 IO。

#### `min_level`

- API: `public`

```gdscript
var min_level: int = LogLevel.DEBUG
```

最小输出等级。低于该等级的日志不会打印、写文件或发信号。

#### `max_memory_entries`

- API: `public`

```gdscript
var max_memory_entries: int:
```

内存中最多保留的最近日志条数。设为 0 可关闭内存缓存。

#### `crash_marker_enabled`

- API: `public`

```gdscript
var crash_marker_enabled: bool = true
```

是否写入运行中标记，用于下一次启动时判断上次是否未干净关闭。

#### `trace_id`

- API: `public`

```gdscript
var trace_id: String = ""
```

当前日志 trace id。为空时 init() 会生成一个短 id。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化：创建日志目录、打开日志文件、清理旧文件。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁时关闭文件句柄。

#### `debug`

- API: `public`

```gdscript
func debug(tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出 DEBUG 级别日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签（如模块名）。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `debug_lazy`

- API: `public`

```gdscript
func debug_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
```

延迟输出 DEBUG 级别日志。只有日志未被过滤时才调用 message_builder。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `message_builder` | 延迟构造日志消息的回调。 |
| `context_builder` | 延迟构造结构化上下文的回调。 |

#### `info`

- API: `public`

```gdscript
func info(tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出 INFO 级别日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `info_lazy`

- API: `public`

```gdscript
func info_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
```

延迟输出 INFO 级别日志。只有日志未被过滤时才调用 message_builder。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `message_builder` | 延迟构造日志消息的回调。 |
| `context_builder` | 延迟构造结构化上下文的回调。 |

#### `warn`

- API: `public`

```gdscript
func warn(tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出 WARN 级别日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `warn_lazy`

- API: `public`

```gdscript
func warn_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
```

延迟输出 WARN 级别日志。只有日志未被过滤时才调用 message_builder。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `message_builder` | 延迟构造日志消息的回调。 |
| `context_builder` | 延迟构造结构化上下文的回调。 |

#### `error`

- API: `public`

```gdscript
func error(tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出 ERROR 级别日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `error_lazy`

- API: `public`

```gdscript
func error_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
```

延迟输出 ERROR 级别日志。只有日志未被过滤时才调用 message_builder。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `message_builder` | 延迟构造日志消息的回调。 |
| `context_builder` | 延迟构造结构化上下文的回调。 |

#### `fatal`

- API: `public`

```gdscript
func fatal(tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出 FATAL 级别日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `fatal_lazy`

- API: `public`

```gdscript
func fatal_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
```

延迟输出 FATAL 级别日志。只有日志未被过滤时才调用 message_builder。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |
| `message_builder` | 延迟构造日志消息的回调。 |
| `context_builder` | 延迟构造结构化上下文的回调。 |

#### `log`

- API: `public`

```gdscript
func log(level: int, tag: String, msg: String, context: Dictionary = {}) -> void:
```

输出指定等级日志。

Parameters:

| Name | Description |
|---|---|
| `level` | LogLevel 枚举值。 |
| `tag` | 日志标签。 |
| `msg` | 日志内容。 |
| `context` | 结构化上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] structured context merged into the log entry.

#### `set_trace_id`

- API: `public`

```gdscript
func set_trace_id(value: String) -> void:
```

设置当前 trace id。

Parameters:

| Name | Description |
|---|---|
| `value` | 新 trace id；为空时会重新生成。 |

#### `get_trace_id`

- API: `public`

```gdscript
func get_trace_id() -> String:
```

获取当前 trace id。

Returns: trace id 字符串。

#### `set_global_context`

- API: `public`

```gdscript
func set_global_context(context: Dictionary) -> void:
```

设置全局日志上下文字典。每条日志都会合并该字典，单条日志上下文优先级更高。

Parameters:

| Name | Description |
|---|---|
| `context` | 全局上下文字典。 |

Schemas:

- `context`: Dictionary[String, Variant] sanitized global context merged into every log entry.

#### `set_global_context_provider`

- API: `public`

```gdscript
func set_global_context_provider(provider: Callable) -> void:
```

设置全局日志上下文提供者。每条日志输出时会调用一次，返回 Dictionary 时参与合并。

Parameters:

| Name | Description |
|---|---|
| `provider` | 上下文提供者，签名为 `func() -> Dictionary`。 |

#### `clear_global_context`

- API: `public`

```gdscript
func clear_global_context() -> void:
```

清空全局日志上下文和上下文提供者。

#### `get_global_context`

- API: `public`

```gdscript
func get_global_context() -> Dictionary:
```

获取全局日志上下文字典副本。

Returns: 全局上下文字典副本。

Schemas:

- `return`: Dictionary[String, Variant] sanitized global context.

#### `was_previous_shutdown_clean`

- API: `public`

```gdscript
func was_previous_shutdown_clean() -> bool:
```

获取上次运行是否干净关闭。

Returns: 没有检测到运行中标记时返回 true。

#### `get_previous_crash_marker`

- API: `public`

```gdscript
func get_previous_crash_marker() -> Dictionary:
```

获取上次未干净关闭时留下的标记数据。

Returns: crash marker 副本。

Schemas:

- `return`: Dictionary crash marker with trace_id, started_at, and ticks_msec when available.

#### `set_tag_muted`

- API: `public`

```gdscript
func set_tag_muted(tag: String, muted: bool) -> void:
```

动态设置是否忽略特定标签的日志。

Parameters:

| Name | Description |
|---|---|
| `tag` | 要静音的标签。 |
| `muted` | 是否静音。如果为 true，该 tag 的日志将不再打印及记录。 |

#### `is_tag_muted`

- API: `public`

```gdscript
func is_tag_muted(tag: String) -> bool:
```

检查指定标签是否被静音。

Parameters:

| Name | Description |
|---|---|
| `tag` | 日志标签。 |

Returns: 已静音时返回 true。

#### `add_sink`

- API: `public`

```gdscript
func add_sink(sink: GFLogSink) -> void:
```

注册日志 sink。

Parameters:

| Name | Description |
|---|---|
| `sink` | 要注册的 sink 实例。 |

#### `remove_sink`

- API: `public`

```gdscript
func remove_sink(sink: GFLogSink, shutdown: bool = true) -> void:
```

注销日志 sink。

Parameters:

| Name | Description |
|---|---|
| `sink` | 要注销的 sink 实例。 |
| `shutdown` | 是否调用 sink.shutdown()。 |

#### `clear_sinks`

- API: `public`

```gdscript
func clear_sinks(shutdown: bool = true) -> void:
```

清空所有日志 sink。

Parameters:

| Name | Description |
|---|---|
| `shutdown` | 是否调用每个 sink 的 shutdown()。 |

#### `get_sinks`

- API: `public`

```gdscript
func get_sinks() -> Array[GFLogSink]:
```

获取已注册日志 sink。

Returns: sink 列表副本。

#### `flush_sinks`

- API: `public`

```gdscript
func flush_sinks() -> void:
```

刷新所有日志 sink。

#### `get_recent_entries`

- API: `public`

```gdscript
func get_recent_entries(count: int = -1) -> Array[Dictionary]:
```

获取最近的内存日志条目。

Parameters:

| Name | Description |
|---|---|
| `count` | 读取数量；小于 0 表示全部。 |

Returns: 从旧到新的日志条目数组。

Schemas:

- `return`: Array[Dictionary] of log entries from oldest to newest.

#### `get_entries`

- API: `public`

```gdscript
func get_entries(offset: int = 0, count: int = -1) -> Array[Dictionary]:
```

按偏移读取内存日志条目。

Parameters:

| Name | Description |
|---|---|
| `offset` | 从最旧条目开始的偏移。 |
| `count` | 读取数量；小于 0 表示直到末尾。 |

Returns: 从旧到新的日志条目数组。

Schemas:

- `return`: Array[Dictionary] of log entries from oldest to newest.

#### `get_memory_entry_count`

- API: `public`

```gdscript
func get_memory_entry_count() -> int:
```

获取当前内存日志条目数量。

Returns: 条目数量。

#### `get_dropped_memory_entry_count`

- API: `public`

```gdscript
func get_dropped_memory_entry_count() -> int:
```

获取因内存上限被丢弃的日志条目数量。

Returns: 丢弃数量。

#### `get_log_file_path`

- API: `public`

```gdscript
func get_log_file_path() -> String:
```

获取当前日志文件路径。

Returns: 日志文件路径。

#### `clear_memory_entries`

- API: `public`

```gdscript
func clear_memory_entries() -> void:
```

清空内存日志缓存。

#### `sanitize_log_value`

- API: `public`

```gdscript
static func sanitize_log_value(value: Variant) -> Variant:
```

清洗任意值，使它适合进入结构化日志和 JSON sink。

Parameters:

| Name | Description |
|---|---|
| `value` | 要清洗的值。 |

Returns: 清洗后的值。

Schemas:

- `value`: Variant log context value to sanitize.
- `return`: Variant JSON-compatible value with object metadata, truncated strings, and circular references marked.

## GFModalAction

- Path: `addons/gf/standard/utilities/ui/gf_modal_action.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFModalAction: 通用 modal 动作声明。 描述一个可由 UI 渲染的操作，不绑定具体按钮样式、业务命令或页面类型。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &"ok"
```

动作 ID。

#### `label`

- API: `public`

```gdscript
var label: String = "OK"
```

显示文本。

#### `result_status`

- API: `public`

```gdscript
var result_status: StringName = GFModalResult.STATUS_CONFIRMED
```

触发动作后产生的结果状态。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

动作携带的通用载荷。

Schemas:

- `payload`: Variant，项目自定义动作载荷，会复制到 GFModalResult。

#### `grab_focus`

- API: `public`

```gdscript
var grab_focus: bool = false
```

是否作为默认聚焦动作。

#### `close_on_pressed`

- API: `public`

```gdscript
var close_on_pressed: bool = true
```

触发后是否关闭 modal。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目层或自定义 modal 面板解释。

Schemas:

- `metadata`: Dictionary，项目层或自定义 modal 面板解释的动作元数据。

### Methods

#### `make_result`

- API: `public`

```gdscript
func make_result(context: Dictionary = {}) -> GFModalResult:
```

创建该动作对应的结果。

Parameters:

| Name | Description |
|---|---|
| `context` | 打开 modal 时传入的调用上下文。 |

Returns: 结果实例。

Schemas:

- `context`: Dictionary，打开 modal 时传入并复制到结果中的调用上下文。

#### `duplicate_action`

- API: `public`

```gdscript
func duplicate_action() -> GFModalAction:
```

创建同内容拷贝。

Returns: 新动作声明。

## GFModalConfig

- Path: `addons/gf/standard/utilities/ui/gf_modal_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFModalConfig: 通用 modal 配置。 用 Resource 描述标题、正文、动作和交互策略，使项目自定义 modal 面板 可以共享同一套打开与结果协议。

### Properties

#### `title`

- API: `public`

```gdscript
var title: String = ""
```

标题文本。

#### `message`

- API: `public`

```gdscript
var message: String = ""
```

正文文本。

#### `actions`

- API: `public`

```gdscript
var actions: Array[GFModalAction] = []
```

动作列表。为空时默认生成一个确认动作。

Schemas:

- `actions`: Array[GFModalAction]，modal 可渲染的动作声明列表。

#### `dismiss_on_backdrop`

- API: `public`

```gdscript
var dismiss_on_backdrop: bool = false
```

点击背景是否按取消处理。

#### `dismiss_on_cancel`

- API: `public`

```gdscript
var dismiss_on_cancel: bool = true
```

取消请求是否关闭 modal。

#### `auto_focus`

- API: `public`

```gdscript
var auto_focus: bool = true
```

打开时是否自动聚焦动作按钮。

#### `restore_focus_on_close`

- API: `public`

```gdscript
var restore_focus_on_close: bool = true
```

关闭后是否恢复打开前焦点。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目层或自定义面板解释。

Schemas:

- `metadata`: Dictionary，项目层或自定义 modal 面板解释的配置元数据。

### Methods

#### `get_actions_or_default`

- API: `public`

```gdscript
func get_actions_or_default() -> Array[GFModalAction]:
```

获取可用动作列表；配置为空时返回默认确认动作。

Returns: 动作列表副本。

#### `get_action`

- API: `public`

```gdscript
func get_action(action_id: StringName) -> GFModalAction:
```

查找指定动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作 ID。 |

Returns: 找到时返回动作副本，否则返回 null。

#### `duplicate_config`

- API: `public`

```gdscript
func duplicate_config() -> GFModalConfig:
```

创建同内容拷贝。

Returns: 新配置。

## GFModalResult

- Path: `addons/gf/standard/utilities/ui/gf_modal_result.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFModalResult: 通用 modal 交互结果。 只描述用户选择、附加载荷和调用上下文，不解释业务含义。

### Constants

#### `STATUS_CONFIRMED`

- API: `public`

```gdscript
const STATUS_CONFIRMED: StringName = &"confirmed"
```

表示肯定或主要操作。

#### `STATUS_CANCELLED`

- API: `public`

```gdscript
const STATUS_CANCELLED: StringName = &"cancelled"
```

表示取消、返回或关闭。

#### `STATUS_DISMISSED`

- API: `public`

```gdscript
const STATUS_DISMISSED: StringName = &"dismissed"
```

表示中性关闭。

### Properties

#### `status`

- API: `public`

```gdscript
var status: StringName = STATUS_DISMISSED
```

结果状态。

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

触发该结果的动作 ID。

#### `payload`

- API: `public`

```gdscript
var payload: Variant = null
```

动作携带的通用载荷。

Schemas:

- `payload`: Variant，项目自定义动作载荷。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

结果元数据。

Schemas:

- `metadata`: Dictionary，结果附带的项目侧元数据。

#### `context`

- API: `public`

```gdscript
var context: Dictionary = {}
```

打开 modal 时传入的调用上下文。

Schemas:

- `context`: Dictionary，打开 modal 时传入的调用上下文。

### Methods

#### `create`

- API: `public`

```gdscript
static func create( result_status: StringName, result_action_id: StringName = &"", result_payload: Variant = null, result_metadata: Dictionary = {}, result_context: Dictionary = {} ) -> GFModalResult:
```

创建结果实例。

Parameters:

| Name | Description |
|---|---|
| `result_status` | 结果状态。 |
| `result_action_id` | 触发动作 ID。 |
| `result_payload` | 动作载荷。 |
| `result_metadata` | 结果元数据。 |
| `result_context` | 调用上下文。 |

Returns: 新结果实例。

Schemas:

- `result_payload`: Variant，项目自定义动作载荷。
- `result_metadata`: Dictionary，结果附带的项目侧元数据。
- `result_context`: Dictionary，打开 modal 时传入的调用上下文。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

导出为字典。

Returns: 结果字典。

Schemas:

- `return`: Dictionary，包含 status、action_id、payload、metadata 和 context。

## GFMutationBatch

- Path: `addons/gf/standard/foundation/collections/gf_mutation_batch.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFMutationBatch: 通用变更批次。 把一组 Callable 作为可提交、可回滚的批次执行。它只管理执行顺序、 结果归一化和回滚栈，不绑定资源、存档、网络或编辑器事务。

### Signals

#### `operation_added`

- API: `public`

```gdscript
signal operation_added(operation_id: int)
```

操作加入批次后发出。

Parameters:

| Name | Description |
|---|---|
| `operation_id` | 操作标识。 |

#### `operation_committed`

- API: `public`

```gdscript
signal operation_committed(operation_id: int, result: Dictionary)
```

单个操作提交成功后发出。

Parameters:

| Name | Description |
|---|---|
| `operation_id` | 操作标识。 |
| `result` | 操作结果。 |

Schemas:

- `result`: Dictionary normalized operation result.

#### `batch_committed`

- API: `public`

```gdscript
signal batch_committed(summary: Dictionary)
```

批次提交结束后发出。

Parameters:

| Name | Description |
|---|---|
| `summary` | 提交摘要。 |

Schemas:

- `summary`: Dictionary commit summary.

#### `batch_rolled_back`

- API: `public`

```gdscript
signal batch_rolled_back(summary: Dictionary)
```

已提交操作回滚结束后发出。

Parameters:

| Name | Description |
|---|---|
| `summary` | 回滚摘要。 |

Schemas:

- `summary`: Dictionary rollback summary.

#### `cleared`

- API: `public`

```gdscript
signal cleared
```

批次清空后发出。

### Properties

#### `stop_on_error`

- API: `public`

```gdscript
var stop_on_error: bool = true
```

提交遇到失败时是否停止后续操作。

#### `auto_clear_committed_on_success`

- API: `public`

```gdscript
var auto_clear_committed_on_success: bool = false
```

全部提交成功后是否自动清空 committed 栈。

### Methods

#### `add_operation`

- API: `public`

```gdscript
func add_operation(operation: Callable, rollback: Callable = Callable(), metadata: Dictionary = {}) -> int:
```

添加一个批次操作。

Parameters:

| Name | Description |
|---|---|
| `operation` | 提交回调。 |
| `rollback` | 可选回滚回调。 |
| `metadata` | 操作元数据。 |

Returns: 操作标识；失败返回 -1。

Schemas:

- `metadata`: Dictionary copied into the normalized operation result.

#### `commit`

- API: `public`

```gdscript
func commit(max_operations: int = -1) -> Dictionary:
```

提交待处理操作。

Parameters:

| Name | Description |
|---|---|
| `max_operations` | 最多提交数量；小于 0 表示处理全部。 |

Returns: 提交摘要。

Schemas:

- `return`: Dictionary commit summary.

#### `rollback_committed`

- API: `public`

```gdscript
func rollback_committed(max_operations: int = -1) -> Dictionary:
```

回滚已提交操作。

Parameters:

| Name | Description |
|---|---|
| `max_operations` | 最多回滚数量；小于 0 表示回滚全部。 |

Returns: 回滚摘要。

Schemas:

- `return`: Dictionary rollback summary.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空批次。

#### `get_pending_count`

- API: `public`

```gdscript
func get_pending_count() -> int:
```

获取待处理操作数量。

Returns: 待处理操作数量。

#### `get_committed_count`

- API: `public`

```gdscript
func get_committed_count() -> int:
```

获取已提交操作数量。

Returns: 已提交操作数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary with pending_count, committed_count, next_operation_id, and options.

## GFNodeState

- Path: `addons/gf/standard/state_machine/node/gf_node_state.gd`
- Extends: `Node`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNodeState: 基于场景树的状态节点。 适合需要直接访问动画、碰撞、输入或子节点的状态逻辑。

### Signals

#### `requested_transition`

- API: `public`

```gdscript
signal requested_transition(group_name: StringName, state_name: StringName, args: Dictionary)
```

状态请求切换时发出，由所属状态组或状态机处理。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 目标状态组名。 |
| `state_name` | 目标状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

### Properties

#### `state_name`

- API: `public`

```gdscript
var state_name: StringName = &""
```

状态注册名。为空时使用节点名称。

#### `enter_conditions`

- API: `public`

```gdscript
var enter_conditions: Array[Resource] = []
```

进入状态前需要全部通过的条件资源。

Schemas:

- `enter_conditions`: 元素为 GFNodeStateCondition 或兼容 evaluate() 入口的 Resource 列表。

#### `exit_conditions`

- API: `public`

```gdscript
var exit_conditions: Array[Resource] = []
```

离开状态前需要全部通过的条件资源。

Schemas:

- `exit_conditions`: 元素为 GFNodeStateCondition 或兼容 evaluate() 入口的 Resource 列表。

#### `behaviors`

- API: `public`

```gdscript
var behaviors: Array[Resource] = []
```

进入、退出、暂停、恢复和事件处理时调用的可复用行为资源。

Schemas:

- `behaviors`: 元素为 GFNodeStateBehavior 或兼容状态生命周期入口的 Resource 列表。

#### `host`

- API: `public`

```gdscript
var host: Node:
```

状态机宿主节点。通常是 GFNodeStateMachine 的父节点。

### Methods

#### `get_machine`

- API: `public`

```gdscript
func get_machine() -> Object:
```

获取所属状态机。

Returns: 所属 GFNodeStateMachine；尚未挂入状态组时返回 null。

#### `get_group`

- API: `public`

```gdscript
func get_group() -> Object:
```

获取所属状态组。

Returns: 所属 GFNodeStateGroup；尚未挂入状态组时返回 null。

#### `get_host`

- API: `public`

```gdscript
func get_host() -> Node:
```

获取状态机宿主节点。若无状态机，则退回到状态组父节点或当前父节点。

Returns: 状态机宿主节点；不可用时返回当前父节点或 null。

#### `get_state_name`

- API: `public`

```gdscript
func get_state_name() -> StringName:
```

获取实际注册名。

Returns: 非空 state_name，或节点名称转换出的 StringName。

#### `enter`

- API: `public`

```gdscript
func enter(previous_state: StringName = &"", args: Dictionary = {}) -> void:
```

进入状态。

Parameters:

| Name | Description |
|---|---|
| `previous_state` | 上一个状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `exit`

- API: `public`

```gdscript
func exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
```

离开状态。

Parameters:

| Name | Description |
|---|---|
| `next_state` | 下一个状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `pause`

- API: `public`

```gdscript
func pause(next_state: StringName = &"", args: Dictionary = {}) -> void:
```

进入栈式子状态时暂停当前状态。

Parameters:

| Name | Description |
|---|---|
| `next_state` | 下一个状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `resume`

- API: `public`

```gdscript
func resume(previous_state: StringName = &"", args: Dictionary = {}) -> void:
```

弹出栈式子状态后恢复当前状态。

Parameters:

| Name | Description |
|---|---|
| `previous_state` | 上一个状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `transition_to`

- API: `public`

```gdscript
func transition_to(path: StringName, args: Dictionary = {}) -> void:
```

请求切换状态。path 可为 "State" 或 "Group/State"。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或状态路径。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `initialize`

- API: `public`

```gdscript
func initialize() -> void:
```

状态初始化 Hook。状态加入状态组时调用一次。

#### `can_enter`

- API: `public`

```gdscript
func can_enter(previous_state: StringName = &"", args: Dictionary = {}) -> bool:
```

判断是否允许进入状态。

Parameters:

| Name | Description |
|---|---|
| `previous_state` | 来源状态名。 |
| `args` | 切换参数。 |

Returns: 允许进入返回 true。

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `can_exit`

- API: `public`

```gdscript
func can_exit(next_state: StringName = &"", args: Dictionary = {}) -> bool:
```

判断是否允许离开状态。

Parameters:

| Name | Description |
|---|---|
| `next_state` | 目标状态名。 |
| `args` | 切换参数。 |

Returns: 允许离开返回 true。

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `get_blackboard`

- API: `public`

```gdscript
func get_blackboard() -> Dictionary:
```

获取状态组共享黑板。

Returns: 黑板字典；没有状态组时返回空字典。

Schemas:

- `return`: 状态组共享黑板 Dictionary；键和值由项目状态逻辑约定。

#### `handle_state_event`

- API: `public`

```gdscript
func handle_state_event(event_id: StringName, payload: Variant = null) -> bool:
```

处理状态事件。返回 false 时事件会继续交给同组的暂停栈状态。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |

Returns: 已处理返回 true。

Schemas:

- `payload`: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。

#### `get_architecture_or_null`

- API: `public`

```gdscript
func get_architecture_or_null() -> GFArchitecture:
```

获取当前状态可用的架构实例。

Returns: 架构实例；状态未挂入可解析上下文时返回 null。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态上下文获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态上下文获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态上下文获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例；不可用时返回 null。

#### `get_local_model`

- API: `public`

```gdscript
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态所属架构获取 Model，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的模型实例；不可用时返回 null。

#### `get_local_system`

- API: `public`

```gdscript
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态所属架构获取 System，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的系统实例；不可用时返回 null。

#### `get_local_utility`

- API: `public`

```gdscript
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态所属架构获取 Utility，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的工具实例；不可用时返回 null。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

向当前状态上下文发送命令。

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令执行结果；无可用架构时返回 null。

Schemas:

- `return`: 命令返回值；具体结构由 GFCommand 实现决定。

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

向当前状态上下文发送查询。

Parameters:

| Name | Description |
|---|---|
| `query` | 要发送的查询实例。 |

Returns: 查询结果；无可用架构时返回 null。

Schemas:

- `return`: 查询返回值；具体结构由 GFQuery 实现决定。

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload`: 轻量事件载荷；具体结构由 event_id 和项目逻辑约定。

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册类型事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要监听的脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_event`

- API: `public`

```gdscript
func unregister_event(event_type: Script, callback: Callable) -> void:
```

注销类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_assignable_event`

- API: `public`

```gdscript
func register_assignable_event(base_event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册可赋值类型事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 要监听的基类脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_assignable_event`

- API: `public`

```gdscript
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, callback: Callable) -> void:
```

注册轻量级 StringName 事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 回调函数，签名为 func(payload: Variant)。 |

#### `unregister_simple_event`

- API: `public`

```gdscript
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 要移除的回调函数。 |

#### `unregister_owner_events`

- API: `public`

```gdscript
func unregister_owner_events() -> void:
```

注销当前状态通过事件代理注册过的全部监听器。

## GFNodeStateBehavior

- Path: `addons/gf/standard/state_machine/node/gf_node_state_behavior.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNodeStateBehavior: 节点状态的可复用生命周期行为资源。 行为资源可挂到 GFNodeState 上复用进入、退出、暂停、恢复和事件处理逻辑。 它不替代状态脚本；状态脚本仍负责业务状态的主要控制权。

### Properties

#### `behavior_id`

- API: `public`

```gdscript
var behavior_id: StringName = &""
```

行为标识，便于调试或项目工具识别。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该行为。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；键和值由项目侧约定。

### Methods

#### `initialize`

- API: `public`

```gdscript
func initialize(state: GFNodeState) -> void:
```

初始化行为。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |

#### `enter`

- API: `public`

```gdscript
func enter(state: GFNodeState, previous_state: StringName = &"", args: Dictionary = {}) -> void:
```

状态进入后调用。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |
| `previous_state` | 来源状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `exit`

- API: `public`

```gdscript
func exit(state: GFNodeState, next_state: StringName = &"", args: Dictionary = {}) -> void:
```

状态退出前调用。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |
| `next_state` | 目标状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `pause`

- API: `public`

```gdscript
func pause(state: GFNodeState, next_state: StringName = &"", args: Dictionary = {}) -> void:
```

状态被栈式子状态覆盖时调用。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |
| `next_state` | 目标状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `resume`

- API: `public`

```gdscript
func resume(state: GFNodeState, previous_state: StringName = &"", args: Dictionary = {}) -> void:
```

状态从栈式子状态恢复后调用。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |
| `previous_state` | 来源状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `handle_state_event`

- API: `public`

```gdscript
func handle_state_event(state: GFNodeState, event_id: StringName, payload: Variant = null) -> bool:
```

处理状态事件。

Parameters:

| Name | Description |
|---|---|
| `state` | 行为所属状态。 |
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |

Returns: 已处理返回 true。

Schemas:

- `payload`: 状态事件载荷；具体类型由 event_id 和项目约定决定。

## GFNodeStateCondition

- Path: `addons/gf/standard/state_machine/node/gf_node_state_condition.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFNodeStateCondition: 节点状态的可复用进入/退出条件资源。 条件只负责判断状态切换是否允许，不直接执行切换或修改状态机结构。

### Properties

#### `condition_id`

- API: `public`

```gdscript
var condition_id: StringName = &""
```

条件标识，便于调试或项目工具识别。

#### `invert`

- API: `public`

```gdscript
var invert: bool = false
```

是否反转 evaluate() 的结果。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: 项目自定义元数据 Dictionary；键和值由项目侧约定。

### Methods

#### `evaluate`

- API: `public`

```gdscript
func evaluate( state: GFNodeState, phase: StringName, peer_state: StringName = &"", args: Dictionary = {} ) -> bool:
```

评估条件。

Parameters:

| Name | Description |
|---|---|
| `state` | 当前条件所属状态。 |
| `phase` | 条件阶段，通常为 enter 或 exit。 |
| `peer_state` | 进入时为来源状态名，退出时为目标状态名。 |
| `args` | 状态切换参数。 |

Returns: 条件通过时返回 true。

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

## GFNodeStateGroup

- Path: `addons/gf/standard/state_machine/node/gf_node_state_group.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFNodeStateGroup: 管理一组互斥激活的节点状态。 一个状态组内同一时间只有一个 GFNodeState 处于启用状态。

### Signals

#### `state_added`

- API: `public`

```gdscript
signal state_added(state: GFNodeState)
```

状态加入组后发出。

Parameters:

| Name | Description |
|---|---|
| `state` | 新加入的状态节点。 |

#### `state_removed`

- API: `public`

```gdscript
signal state_removed(state: GFNodeState)
```

状态从组中移除后发出。

Parameters:

| Name | Description |
|---|---|
| `state` | 被移除的状态节点。 |

#### `current_state_changed`

- API: `public`

```gdscript
signal current_state_changed(old_state: GFNodeState, new_state: GFNodeState)
```

当前状态切换后发出。

Parameters:

| Name | Description |
|---|---|
| `old_state` | 切换前的状态；没有旧状态时为 null。 |
| `new_state` | 切换后的状态；状态组停止时可为 null。 |

#### `transition_blocked`

- API: `public`

```gdscript
signal transition_blocked(from_state: GFNodeState, to_state_name: StringName, args: Dictionary, reason: String)
```

状态切换被守卫阻止后发出。

Parameters:

| Name | Description |
|---|---|
| `from_state` | 发起切换时的当前状态；没有当前状态时为 null。 |
| `to_state_name` | 被阻止的目标状态名。 |
| `args` | 状态切换参数。 |
| `reason` | 阻止原因，通常为 "exit_guard" 或 "enter_guard"。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `requested_transition`

- API: `public`

```gdscript
signal requested_transition(group_name: StringName, state_name: StringName, args: Dictionary)
```

子状态请求跨组切换时发出。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 目标状态组名。 |
| `state_name` | 目标状态名。 |
| `args` | 状态切换参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `state_event_handled`

- API: `public`

```gdscript
signal state_event_handled(event_id: StringName, handler_state: GFNodeState, payload: Variant)
```

当前状态或暂停栈状态处理状态事件后发出。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `handler_state` | 实际处理事件的状态节点。 |
| `payload` | 状态事件载荷。 |

Schemas:

- `payload`: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。

### Properties

#### `group_name`

- API: `public`

```gdscript
var group_name: StringName = &""
```

状态组注册名。为空时使用节点名称。

#### `initial_state`

- API: `public`

```gdscript
var initial_state: StringName = &""
```

初始状态名。

#### `initial_args`

- API: `public`

```gdscript
var initial_args: Dictionary = {}
```

初始状态参数。

Schemas:

- `initial_args`: 初始状态参数 Dictionary；键和值由初始状态的项目逻辑约定。

#### `reload_states_on_ready`

- API: `public`

```gdscript
var reload_states_on_ready: bool = true
```

ready 时是否自动从子节点加载状态。

#### `auto_start`

- API: `public`

```gdscript
var auto_start: bool = true
```

初始化后是否自动进入 initial_state。关闭后可通过 start() 手动启动。

#### `history_max_size`

- API: `public`

```gdscript
var history_max_size: int = 32
```

每个状态组保留的历史状态名数量。

#### `max_stack_depth`

- API: `public`

```gdscript
var max_stack_depth: int = 8
```

push_state 可叠加的最大栈深度。

#### `blackboard`

- API: `public`

```gdscript
var blackboard: Dictionary = {}
```

状态组共享黑板。框架不解释其中字段。

Schemas:

- `blackboard`: 状态组共享黑板 Dictionary；键和值由项目状态逻辑约定。

### Methods

#### `get_group_name`

- API: `public`

```gdscript
func get_group_name() -> StringName:
```

获取状态组注册名。

Returns: 非空 group_name，或节点名称转换出的 StringName。

#### `transition_to`

- API: `public`

```gdscript
func transition_to(next_state_name: StringName, args: Dictionary = {}) -> void:
```

切换到指定状态。

Parameters:

| Name | Description |
|---|---|
| `next_state_name` | 要切换到的目标状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `push_state`

- API: `public`

```gdscript
func push_state(next_state_name: StringName, args: Dictionary = {}) -> void:
```

暂停当前状态并叠加进入一个子状态。

Parameters:

| Name | Description |
|---|---|
| `next_state_name` | 要切换到的目标状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `pop_state`

- API: `public`

```gdscript
func pop_state(args: Dictionary = {}) -> bool:
```

退出当前子状态并恢复上一层状态。

Parameters:

| Name | Description |
|---|---|
| `args` | 状态切换时传递的可选参数。 |

Returns: 成功恢复上一层状态时返回 true。

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `add_state`

- API: `public`

```gdscript
func add_state(state: GFNodeState) -> void:
```

添加状态节点。

Parameters:

| Name | Description |
|---|---|
| `state` | 状态节点。 |

#### `remove_state`

- API: `public`

```gdscript
func remove_state(state: GFNodeState) -> bool:
```

移除状态节点。

Parameters:

| Name | Description |
|---|---|
| `state` | 状态节点。 |

Returns: 成功移除已注册状态时返回 true。

#### `get_state`

- API: `public`

```gdscript
func get_state(query_state_name: StringName) -> GFNodeState:
```

获取状态。

Parameters:

| Name | Description |
|---|---|
| `query_state_name` | 目标名称。 |

Returns: 注册名对应的状态节点；不存在时返回 null。

#### `get_current_state`

- API: `public`

```gdscript
func get_current_state() -> GFNodeState:
```

获取当前状态。

Returns: 当前激活状态；未启动或已停止时返回 null。

#### `get_current_state_name`

- API: `public`

```gdscript
func get_current_state_name() -> StringName:
```

获取当前状态名。

Returns: 当前激活状态名；未启动或已停止时返回空 StringName。

#### `get_state_history`

- API: `public`

```gdscript
func get_state_history() -> Array[StringName]:
```

获取状态切换历史。

Returns: 最近进入过的状态名列表。

Schemas:

- `return`: 状态历史 Array[StringName]，按进入顺序排列。

#### `get_stack_depth`

- API: `public`

```gdscript
func get_stack_depth() -> int:
```

获取当前暂停栈深度。

Returns: 当前暂停栈深度。

#### `get_blackboard`

- API: `public`

```gdscript
func get_blackboard() -> Dictionary:
```

获取状态组共享黑板。

Returns: 黑板字典。

Schemas:

- `return`: 状态组共享黑板 Dictionary；键和值由项目状态逻辑约定，调用方可直接修改。

#### `dispatch_state_event`

- API: `public`

```gdscript
func dispatch_state_event(event_id: StringName, payload: Variant = null) -> bool:
```

从当前状态开始向暂停栈上抛状态事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |

Returns: 有状态处理该事件时返回 true。

Schemas:

- `payload`: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。

#### `is_in_state`

- API: `public`

```gdscript
func is_in_state(query_state_name: StringName) -> bool:
```

判断指定状态是否为当前状态或暂停栈中的状态。

Parameters:

| Name | Description |
|---|---|
| `query_state_name` | 目标名称。 |

Returns: 指定状态位于当前状态或暂停栈中时返回 true。

#### `restart`

- API: `public`

```gdscript
func restart(args: Dictionary = {}) -> void:
```

重启当前状态；若当前没有状态，则尝试进入初始状态。

Parameters:

| Name | Description |
|---|---|
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `start`

- API: `public`

```gdscript
func start(args: Dictionary = {}) -> void:
```

进入初始状态。若已有当前状态则保持不变。

Parameters:

| Name | Description |
|---|---|
| `args` | 启动时传给初始状态的参数；为空时使用 initial_args。 |

Schemas:

- `args`: 启动参数 Dictionary；为空时使用 initial_args。

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

停止当前激活状态，但保留已注册状态节点。

#### `get_states`

- API: `public`

```gdscript
func get_states() -> Array[GFNodeState]:
```

获取所有状态。

Returns: 已注册状态节点列表。

Schemas:

- `return`: 已注册 GFNodeState 节点数组。

#### `get_state_snapshot`

- API: `public`

```gdscript
func get_state_snapshot() -> Dictionary:
```

获取状态组调试快照。

Returns: 包含当前状态、暂停栈、历史、注册状态和黑板副本的字典。

Schemas:

- `return`: 调试快照 Dictionary，包含 group_name、current_state、stack、history、states 和 blackboard 字段。

#### `clear_states`

- API: `public`

```gdscript
func clear_states(free_states: bool = false) -> void:
```

清空状态。

Parameters:

| Name | Description |
|---|---|
| `free_states` | 为 true 时同时释放已移除的状态节点。 |

#### `reload_states_from_children`

- API: `public`

```gdscript
func reload_states_from_children() -> void:
```

从子节点重新加载状态。

## GFNodeStateMachine

- Path: `addons/gf/standard/state_machine/node/gf_node_state_machine.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNodeStateMachine: 基于场景树的多状态组状态机。 支持直接子 GFNodeState 组成内部状态组，也支持多个 GFNodeStateGroup 并行工作。

### Signals

#### `state_group_added`

- API: `public`

```gdscript
signal state_group_added(group: GFNodeStateGroup)
```

状态组加入后发出。

Parameters:

| Name | Description |
|---|---|
| `group` | 新加入的状态组。 |

#### `state_group_removed`

- API: `public`

```gdscript
signal state_group_removed(group: GFNodeStateGroup)
```

状态组移除后发出。

Parameters:

| Name | Description |
|---|---|
| `group` | 被移除的状态组。 |

#### `state_changed`

- API: `public`

```gdscript
signal state_changed(group: GFNodeStateGroup, old_state: GFNodeState, new_state: GFNodeState)
```

任意状态组切换状态后发出。

Parameters:

| Name | Description |
|---|---|
| `group` | 发生状态切换的状态组。 |
| `old_state` | 切换前的状态；没有旧状态时为 null。 |
| `new_state` | 切换后的状态；状态组停止时可为 null。 |

#### `state_event_handled`

- API: `public`

```gdscript
signal state_event_handled(group: GFNodeStateGroup, event_id: StringName, handler_state: GFNodeState, payload: Variant)
```

任意状态组中的状态处理状态事件后发出。

Parameters:

| Name | Description |
|---|---|
| `group` | 处理事件的状态所属状态组。 |
| `event_id` | 状态事件标识。 |
| `handler_state` | 实际处理事件的状态节点。 |
| `payload` | 状态事件载荷。 |

Schemas:

- `payload`: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。

### Enums

#### `StartMode`

- API: `public`

```gdscript
enum StartMode { ## 状态机 ready 时启动，适合需要旧版启动顺序的项目。 ON_READY, ## 等待宿主节点 ready 后启动。 AFTER_HOST_READY, ## 只加载状态，不自动启动；由外部调用 start()。 MANUAL, }
```

节点状态机初始状态启动时机。

### Constants

#### `INTERNAL_GROUP_NAME`

- API: `public`

```gdscript
const INTERNAL_GROUP_NAME: StringName = &"_internal"
```

直接子 GFNodeState 组成的内置状态组名称。

### Properties

#### `config`

- API: `public`

```gdscript
var config: GFNodeStateMachineConfig = null
```

可选状态机配置资源。为空时继续使用本节点上的兼容导出项。

#### `initial_state`

- API: `public`

```gdscript
var initial_state: StringName = &""
```

内部状态组初始状态名。

#### `initial_args`

- API: `public`

```gdscript
var initial_args: Dictionary = {}
```

内部状态组初始状态参数。

Schemas:

- `initial_args`: 内部状态组初始状态参数 Dictionary；键和值由初始状态的项目逻辑约定。

#### `reload_on_ready`

- API: `public`

```gdscript
var reload_on_ready: bool = true
```

ready 时是否自动从子节点加载状态与状态组。

#### `start_mode`

- API: `public`

```gdscript
var start_mode: StartMode = StartMode.AFTER_HOST_READY
```

初始状态启动模式。

#### `preserve_current_state_on_reload`

- API: `public`

```gdscript
var preserve_current_state_on_reload: bool = true
```

运行时重新从子节点加载时，是否尽量恢复各状态组的当前状态。

### Methods

#### `transition_to`

- API: `public`

```gdscript
func transition_to(path: StringName, args: Dictionary = {}) -> void:
```

通过路径切换状态。path 可为 "State" 或 "Group/State"。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或状态路径。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `transition_group_to`

- API: `public`

```gdscript
func transition_group_to(group_name: StringName, state_name: StringName, args: Dictionary = {}) -> void:
```

切换指定状态组到指定状态。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |
| `state_name` | 目标状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `push_state`

- API: `public`

```gdscript
func push_state(path: StringName, args: Dictionary = {}) -> void:
```

暂停当前内部状态并叠加进入一个子状态。path 可为 "State" 或 "Group/State"。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或状态路径。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `push_group_state`

- API: `public`

```gdscript
func push_group_state(group_name: StringName, state_name: StringName, args: Dictionary = {}) -> void:
```

暂停指定状态组当前状态并叠加进入一个子状态。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |
| `state_name` | 目标状态名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `pop_state`

- API: `public`

```gdscript
func pop_state(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> bool:
```

弹出指定状态组的栈式子状态。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |
| `args` | 状态切换时传递的可选参数。 |

Returns: 成功恢复上一层状态时返回 true。

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `start`

- API: `public`

```gdscript
func start(args: Dictionary = {}) -> void:
```

启动所有已加载状态组的初始状态。若尚未加载状态，则会先从子节点加载。

Parameters:

| Name | Description |
|---|---|
| `args` | 启动时传给初始状态的参数；为空时使用各状态组 initial_args。 |

Schemas:

- `args`: 启动参数 Dictionary；为空时使用各状态组 initial_args。

#### `start_group`

- API: `public`

```gdscript
func start_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
```

启动指定状态组的初始状态。若尚未加载状态，则会先从子节点加载。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 要启动的状态组名。 |
| `args` | 启动时传给初始状态的参数；为空时使用该状态组 initial_args。 |

Schemas:

- `args`: 启动参数 Dictionary；为空时使用该状态组 initial_args。

#### `add_state_group`

- API: `public`

```gdscript
func add_state_group(group: GFNodeStateGroup) -> void:
```

添加状态组。

Parameters:

| Name | Description |
|---|---|
| `group` | 所属状态组。 |

#### `remove_state_group`

- API: `public`

```gdscript
func remove_state_group(group: GFNodeStateGroup) -> bool:
```

移除状态组。

Parameters:

| Name | Description |
|---|---|
| `group` | 所属状态组。 |

Returns: 成功移除已注册状态组时返回 true。

#### `get_state_group`

- API: `public`

```gdscript
func get_state_group(group_name: StringName) -> GFNodeStateGroup:
```

获取状态组。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 注册名对应的状态组；不存在时返回 null。

#### `get_current_state`

- API: `public`

```gdscript
func get_current_state() -> GFNodeState:
```

获取内部状态组当前状态。

Returns: 内部状态组当前状态；未启动或不存在时返回 null。

#### `get_current_group_state`

- API: `public`

```gdscript
func get_current_group_state(group_name: StringName = INTERNAL_GROUP_NAME) -> GFNodeState:
```

获取指定状态组当前状态。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 当前状态；未找到状态组或未启动时返回 null。

#### `get_current_state_name`

- API: `public`

```gdscript
func get_current_state_name(group_name: StringName = INTERNAL_GROUP_NAME) -> StringName:
```

获取指定状态组当前状态名。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 当前状态名；未找到状态组或未启动时返回空 StringName。

#### `get_state_history`

- API: `public`

```gdscript
func get_state_history(group_name: StringName = INTERNAL_GROUP_NAME) -> Array[StringName]:
```

获取指定状态组状态历史。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 最近进入过的状态名列表。

Schemas:

- `return`: 状态历史 Array[StringName]，按进入顺序排列。

#### `get_stack_depth`

- API: `public`

```gdscript
func get_stack_depth(group_name: StringName = INTERNAL_GROUP_NAME) -> int:
```

获取指定状态组暂停栈深度。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |

Returns: 指定状态组的暂停栈深度；未找到状态组时返回 0。

#### `is_in_state`

- API: `public`

```gdscript
func is_in_state(path: StringName) -> bool:
```

判断 path 指向的状态是否为当前状态或暂停栈中的状态。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或状态路径。 |

Returns: 指定状态位于当前状态或暂停栈中时返回 true。

#### `restart_group`

- API: `public`

```gdscript
func restart_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
```

重启指定状态组当前状态。

Parameters:

| Name | Description |
|---|---|
| `group_name` | 能力组或状态组名称。 |
| `args` | 状态切换时传递的可选参数。 |

Schemas:

- `args`: 状态切换参数 Dictionary；键和值由调用方约定。

#### `dispatch_state_event`

- API: `public`

```gdscript
func dispatch_state_event(event_id: StringName, payload: Variant = null, group_name: StringName = &"") -> bool:
```

派发状态事件。group_name 为空时会按已注册状态组顺序广播到所有组。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |
| `group_name` | 可选目标状态组名；为空表示所有状态组。 |

Returns: 有状态处理该事件时返回 true。

Schemas:

- `payload`: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。

#### `get_state_snapshot`

- API: `public`

```gdscript
func get_state_snapshot() -> Dictionary:
```

获取节点状态机调试快照。

Returns: 包含所有状态组当前状态、历史、栈深度和黑板副本的字典。

Schemas:

- `return`: 调试快照 Dictionary，包含 groups 和 internal_group 字段；groups 的键为状态组名，值为 GFNodeStateGroup.get_state_snapshot() 返回的状态组快照。

#### `get_architecture_or_null`

- API: `public`

```gdscript
func get_architecture_or_null() -> GFArchitecture:
```

获取当前状态机可用的架构实例。

Returns: 架构实例；状态机未挂入可解析上下文时返回 null。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态机上下文获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例；不可用时返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态机上下文获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例；不可用时返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过当前状态机上下文获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例；不可用时返回 null。

#### `get_local_model`

- API: `public`

```gdscript
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态机所属架构获取 Model，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的模型实例；不可用时返回 null。

#### `get_local_system`

- API: `public`

```gdscript
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态机所属架构获取 System，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的系统实例；不可用时返回 null。

#### `get_local_utility`

- API: `public`

```gdscript
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

仅从当前状态机所属架构获取 Utility，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的工具实例；不可用时返回 null。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

向当前状态机上下文发送命令。

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令执行结果；无可用架构时返回 null。

Schemas:

- `return`: 命令返回值；具体结构由 GFCommand 实现决定。

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

向当前状态机上下文发送查询。

Parameters:

| Name | Description |
|---|---|
| `query` | 要发送的查询实例。 |

Returns: 查询结果；无可用架构时返回 null。

Schemas:

- `return`: 查询返回值；具体结构由 GFQuery 实现决定。

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload`: 轻量事件载荷；具体结构由 event_id 和项目逻辑约定。

#### `register_event_owned`

- API: `public`

```gdscript
func register_event_owned(owner: Object, event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册带拥有者的类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_type` | 要监听的脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_event`

- API: `public`

```gdscript
func unregister_event(event_type: Script, callback: Callable) -> void:
```

注销类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_assignable_event_owned`

- API: `public`

```gdscript
func register_assignable_event_owned( owner: Object, base_event_type: Script, callback: Callable, priority: int = 0 ) -> void:
```

注册带拥有者的可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `base_event_type` | 要监听的基类脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_assignable_event`

- API: `public`

```gdscript
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_simple_event_owned`

- API: `public`

```gdscript
func register_simple_event_owned(owner: Object, event_id: StringName, callback: Callable) -> void:
```

注册带拥有者的轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_id` | StringName 事件标识符。 |
| `callback` | 回调函数，签名为 func(payload: Variant)。 |

#### `unregister_simple_event`

- API: `public`

```gdscript
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 要移除的回调函数。 |

#### `unregister_owner_events`

- API: `public`

```gdscript
func unregister_owner_events(owner: Object) -> void:
```

注销指定拥有者通过状态机事件代理注册过的全部监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 要清理监听器的拥有者。 |

#### `reload_from_children`

- API: `public`

```gdscript
func reload_from_children() -> void:
```

从子节点重新加载状态和状态组。

#### `clear_state_groups`

- API: `public`

```gdscript
func clear_state_groups(free_groups: bool = false) -> void:
```

清空所有状态组。

Parameters:

| Name | Description |
|---|---|
| `free_groups` | 清理状态组时是否释放节点。 |

## GFNodeStateMachineConfig

- Path: `addons/gf/standard/state_machine/node/gf_node_state_machine_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFNodeStateMachineConfig: 节点状态机可复用配置资源。 适合把初始状态、历史容量和栈深度等通用运行策略做成资源复用。

### Properties

#### `initial_state`

- API: `public`

```gdscript
var initial_state: StringName = &""
```

内部状态组初始状态名。

#### `initial_args`

- API: `public`

```gdscript
var initial_args: Dictionary = {}
```

内部状态组初始状态参数。

Schemas:

- `initial_args`: 初始状态切换参数 Dictionary；键和值由调用方约定。

#### `history_max_size`

- API: `public`

```gdscript
var history_max_size: int = 32:
```

每个状态组保留的历史状态名数量。

#### `max_stack_depth`

- API: `public`

```gdscript
var max_stack_depth: int = 8:
```

push_state 可叠加的最大栈深度。

## GFNodeStateMachineDock

- Path: `addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd`
- Extends: `Control`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFNodeStateMachineDock: 节点状态机结构检查工作区页面。 面向编辑器展示当前场景中的 GFNodeStateMachine，复用标准校验器输出结构问题， 不推断项目自己的状态转移、输入或动画语义。

### Methods

#### `set_state_machine_source`

- API: `public`

```gdscript
func set_state_machine_source(root: Node) -> void:
```

设置要扫描的场景根节点。

Parameters:

| Name | Description |
|---|---|
| `root` | 场景根节点；为空时刷新会尝试使用当前编辑场景或运行时场景。 |

#### `refresh`

- API: `public`

```gdscript
func refresh(root: Node = null) -> void:
```

刷新状态机列表与当前校验报告。

Parameters:

| Name | Description |
|---|---|
| `root` | 可选场景根节点；为空时使用 set_state_machine_source() 或当前场景。 |

#### `get_last_report`

- API: `public`

```gdscript
func get_last_report() -> Dictionary:
```

获取最近一次校验报告字典。

Returns: 报告字典副本。

Schemas:

- `return`: 校验报告 Dictionary，包含 ok、summary、next_action、issues、error_count、warning_count 等字段。

#### `get_machine_count`

- API: `public`

```gdscript
func get_machine_count() -> int:
```

获取最近一次扫描到的状态机数量。

Returns: 状态机数量。

## GFNodeStateMachineValidator

- Path: `addons/gf/standard/state_machine/node/gf_node_state_machine_validator.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNodeStateMachineValidator: 节点状态机结构校验工具。 只检查状态机、状态组和状态资源挂接是否自洽，不执行状态切换， 也不推断项目业务中的转移规则。

### Methods

#### `validate_machine`

- API: `public`

```gdscript
static func validate_machine(machine: GFNodeStateMachine, options: Dictionary = {}) -> GFValidationReport:
```

校验一个节点状态机的直接子状态和显式状态组。

Parameters:

| Name | Description |
|---|---|
| `machine` | 要校验的节点状态机。 |
| `options` | 可选校验选项，支持 check_state_resources、require_initial_state。 |

Returns: 校验报告。

Schemas:

- `options`: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。

#### `validate_group`

- API: `public`

```gdscript
static func validate_group(group: GFNodeStateGroup, options: Dictionary = {}) -> GFValidationReport:
```

校验一个节点状态组的直接子状态。

Parameters:

| Name | Description |
|---|---|
| `group` | 要校验的状态组。 |
| `options` | 可选校验选项，支持 check_state_resources、require_initial_state。 |

Returns: 校验报告。

Schemas:

- `options`: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。

#### `validate_state_list`

- API: `public`

```gdscript
static func validate_state_list( states: Array[GFNodeState], initial_state: StringName = &"", subject: String = "GFNodeStateList", options: Dictionary = {} ) -> GFValidationReport:
```

校验一组状态名、初始状态和状态资源挂接。

Parameters:

| Name | Description |
|---|---|
| `states` | 要校验的状态列表。 |
| `initial_state` | 可选初始状态名。 |
| `subject` | 报告主题。 |
| `options` | 可选校验选项，支持 check_state_resources、require_initial_state。 |

Returns: 校验报告。

Schemas:

- `states`: 元素为 GFNodeState 的状态列表。
- `options`: 校验选项 Dictionary；支持 check_state_resources: bool 和 require_initial_state: bool。

## GFNodeTreeOps

- Path: `addons/gf/standard/utilities/nodes/gf_node_tree_ops.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNodeTreeOps: 通用节点树操作集合。 提供安全添加、重挂、替换、遍历、类型查找和 owner 传播等节点树基础操作。 该工具只处理 Godot Node 结构，不绑定具体玩法、UI 或场景业务。

### Methods

#### `add_child_with_owner`

- API: `public`

```gdscript
static func add_child_with_owner( parent: Node, child: Node, owner: Node = null, force_readable_name: bool = false ) -> bool:
```

把子节点添加到父节点，并按场景编辑规则设置 owner。

Parameters:

| Name | Description |
|---|---|
| `parent` | 目标父节点。 |
| `child` | 要添加的子节点。 |
| `owner` | 可选 owner；为空时使用 parent.owner，若没有则使用 parent。 |
| `force_readable_name` | 是否要求 Godot 生成可读名称。 |

Returns: 添加成功返回 true。

#### `reparent_node`

- API: `public`

```gdscript
static func reparent_node( node: Node, new_parent: Node, keep_global_transform: bool = true, owner: Node = null ) -> bool:
```

把节点移动到新父节点下。

Parameters:

| Name | Description |
|---|---|
| `node` | 要移动的节点。 |
| `new_parent` | 新父节点。 |
| `keep_global_transform` | 为 true 时尽量保留 Node2D、Node3D 或 Control 的全局变换。 |
| `owner` | 可选 owner；为空时使用 new_parent.owner，若没有则使用 new_parent。 |

Returns: 移动成功返回 true。

#### `replace_child`

- API: `public`

```gdscript
static func replace_child( parent: Node, old_child: Node, new_child: Node, keep_global_transform: bool = true, free_old_child: bool = false, owner: Node = null ) -> bool:
```

用新子节点替换父节点下的旧子节点。

Parameters:

| Name | Description |
|---|---|
| `parent` | 目标父节点。 |
| `old_child` | 要被替换的旧子节点。 |
| `new_child` | 新子节点。 |
| `keep_global_transform` | 为 true 时重挂新节点时尽量保留全局变换。 |
| `free_old_child` | 为 true 时替换后 queue_free() 旧节点。 |
| `owner` | 可选 owner；为空时使用 parent.owner，若没有则使用 parent。 |

Returns: 替换成功返回 true。

#### `find_first_parent_of_type`

- API: `public`

```gdscript
static func find_first_parent_of_type( node: Node, parent_type: Variant, include_self: bool = false ) -> Node:
```

向上查找第一个匹配类型的父级节点。

Parameters:

| Name | Description |
|---|---|
| `node` | 查询起点。 |
| `parent_type` | 目标类型，可为脚本类型、原生类或类名字符串。 |
| `include_self` | 是否包含查询起点。 |

Returns: 匹配节点；未找到时返回 null。

Schemas:

- `parent_type`: Variant type filter accepted by is_instance_of(), native class name, GDScript class_name, or script resource path.

#### `find_first_child_of_type`

- API: `public`

```gdscript
static func find_first_child_of_type( parent: Node, child_type: Variant, recursive: bool = false, include_internal: bool = false, include_parent: bool = false ) -> Node:
```

向下查找第一个匹配类型的子节点。

Parameters:

| Name | Description |
|---|---|
| `parent` | 查询根节点。 |
| `child_type` | 目标类型，可为脚本类型、原生类或类名字符串。 |
| `recursive` | 是否递归查找。 |
| `include_internal` | 是否包含内部子节点。 |
| `include_parent` | 是否允许 parent 自身命中。 |

Returns: 匹配节点；未找到时返回 null。

Schemas:

- `child_type`: Variant type filter accepted by is_instance_of(), native class name, GDScript class_name, or script resource path.

#### `collect_node_tree`

- API: `public`

```gdscript
static func collect_node_tree( root: Node, type_filter: Variant = null, include_root: bool = true, include_internal: bool = false ) -> Array[Node]:
```

收集节点树中的节点。

Parameters:

| Name | Description |
|---|---|
| `root` | 节点树根节点。 |
| `type_filter` | 可选类型过滤器，可为脚本类型、原生类或类名字符串。 |
| `include_root` | 是否包含 root 自身。 |
| `include_internal` | 是否包含内部子节点。 |

Returns: 匹配节点列表。

Schemas:

- `type_filter`: Variant type filter accepted by is_instance_of(), native class name, GDScript class_name, script resource path, or null for all nodes.

#### `set_owner_recursive`

- API: `public`

```gdscript
static func set_owner_recursive(node: Node, owner: Node) -> void:
```

递归设置节点树 owner。

Parameters:

| Name | Description |
|---|---|
| `node` | 节点树根节点。 |
| `owner` | 目标 owner；必须是节点树中被设置节点的祖先。 |

#### `free_children`

- API: `public`

```gdscript
static func free_children(parent: Node, include_internal: bool = false) -> int:
```

从父节点移除并 queue_free() 父节点下的全部子节点。

Parameters:

| Name | Description |
|---|---|
| `parent` | 目标父节点。 |
| `include_internal` | 是否包含内部子节点。 |

Returns: 进入释放队列的子节点数量。

## GFNotificationUtility

- Path: `addons/gf/standard/utilities/ui/gf_notification_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNotificationUtility: 通用运行时通知队列。 只管理通知数据、队列、去重和生命周期信号，不规定 Toast、HUD 或编辑器 UI 样式。

### Signals

#### `notification_queued`

- API: `public`

```gdscript
signal notification_queued(notification: Dictionary)
```

通知进入队列时发出。

Parameters:

| Name | Description |
|---|---|
| `notification` | 通知副本。 |

Schemas:

- `notification`: Dictionary，包含 id、key、dedupe_key、title、message、level、priority、sticky、duration_seconds、created_at_unix、actions 和 metadata。

#### `notification_started`

- API: `public`

```gdscript
signal notification_started(notification: Dictionary)
```

通知开始展示时发出。

Parameters:

| Name | Description |
|---|---|
| `notification` | 通知副本。 |

Schemas:

- `notification`: Dictionary，字段同 notification_queued 的 notification。

#### `notification_finished`

- API: `public`

```gdscript
signal notification_finished(notification: Dictionary, reason: String)
```

通知结束时发出。

Parameters:

| Name | Description |
|---|---|
| `notification` | 通知副本。 |
| `reason` | 结束原因。 |

Schemas:

- `notification`: Dictionary，字段同 notification_queued 的 notification。

#### `notification_action_invoked`

- API: `public`

```gdscript
signal notification_action_invoked(notification: Dictionary, action_id: StringName)
```

当前通知动作被触发时发出。

Parameters:

| Name | Description |
|---|---|
| `notification` | 当前通知副本。 |
| `action_id` | 动作标识。 |

Schemas:

- `notification`: Dictionary，字段同 notification_queued 的 notification。

### Enums

#### `Level`

- API: `public`

```gdscript
enum Level { ## 普通信息。 INFO, ## 成功反馈。 SUCCESS, ## 警告信息。 WARNING, ## 错误信息。 ERROR, }
```

通知等级。

#### `Priority`

- API: `public`

```gdscript
enum Priority { ## 低优先级。 LOW, ## 默认优先级。 NORMAL, ## 高优先级。 HIGH, ## 最高优先级。 CRITICAL, }
```

通知优先级。数值越大越靠前。

### Properties

#### `default_duration_seconds`

- API: `public`

```gdscript
var default_duration_seconds: float = 3.0
```

默认展示时长。

#### `max_queue_size`

- API: `public`

```gdscript
var max_queue_size: int = 32
```

最大排队数量。设为 0 时只允许当前通知，不保留等待队列。

#### `suppress_duplicates`

- API: `public`

```gdscript
var suppress_duplicates: bool = true
```

是否抑制重复入队。有显式 key 时按 key 去重，否则按消息文本去重。

### Methods

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放通知队列状态。

#### `push_notification`

- API: `public`

```gdscript
func push_notification( message: String, title: String = "", level: Level = Level.INFO, options: Dictionary = {} ) -> int:
```

推入通知。

Parameters:

| Name | Description |
|---|---|
| `message` | 通知正文。 |
| `title` | 通知标题。 |
| `level` | 通知等级。 |
| `options` | 可选参数，支持 duration_seconds、key、metadata、priority、sticky、actions。 |

Returns: 通知 id；被去重抑制时返回已有通知 id。

Schemas:

- `options`: Dictionary，支持 duration_seconds、key、metadata、priority、sticky 和 actions。actions 为 Array[StringName|String|Dictionary]，Dictionary action 包含 id、label、dismiss 和 metadata。

#### `dismiss_active`

- API: `public`

```gdscript
func dismiss_active(reason: String = "dismissed") -> void:
```

结束当前通知。

Parameters:

| Name | Description |
|---|---|
| `reason` | 结束原因。 |

#### `clear_notifications`

- API: `public`

```gdscript
func clear_notifications(reason: String = "cleared") -> void:
```

清空当前通知和等待队列。

Parameters:

| Name | Description |
|---|---|
| `reason` | 结束原因。 |

#### `get_active_notification`

- API: `public`

```gdscript
func get_active_notification() -> Dictionary:
```

获取当前通知。

Returns: 当前通知副本。

Schemas:

- `return`: Dictionary，当前通知记录；无当前通知时为空。字段同 notification_queued 的 notification。

#### `pause_active`

- API: `public`

```gdscript
func pause_active() -> void:
```

暂停当前通知倒计时。

#### `resume_active`

- API: `public`

```gdscript
func resume_active() -> void:
```

恢复当前通知倒计时。

#### `is_active_paused`

- API: `public`

```gdscript
func is_active_paused() -> bool:
```

当前通知是否处于暂停状态。

Returns: 暂停时返回 true。

#### `invoke_active_action`

- API: `public`

```gdscript
func invoke_active_action(action_id: StringName) -> bool:
```

触发当前通知的一个动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 当前通知包含该动作时返回 true。

#### `get_queue`

- API: `public`

```gdscript
func get_queue() -> Array[Dictionary]:
```

获取等待队列。

Returns: 通知副本数组。

Schemas:

- `return`: Array，元素为通知记录 Dictionary，字段同 notification_queued 的 notification。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 通知队列状态。

Schemas:

- `return`: Dictionary，包含 active、queue、queue_size、active_remaining_seconds、active_paused 和 max_queue_size。

## GFNumberFormatter

- Path: `addons/gf/standard/foundation/formatting/gf_number_formatter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNumberFormatter: 统一的数字显示格式化工具。 负责普通数字、定点小数与大数值对象在 UI 中的显示转换， 提供完整显示、紧凑缩写、科学计数法、工程计数法与自动模式。

### Enums

#### `Notation`

- API: `public`

```gdscript
enum Notation { ## 尽量输出普通十进制表示。 FULL, ## 输出紧凑缩写表示，如 12.3k。 COMPACT_SHORT, ## 输出科学计数法，如 1.23e8。 SCIENTIFIC, ## 输出工程计数法，如 123.4e6。 ENGINEERING, ## 自动选择更适合当前量级的表示方式。 AUTO, }
```

格式化记法。

#### `ScientificStyle`

- API: `public`

```gdscript
enum ScientificStyle { ## 使用小写 e。 E_LOWER, ## 使用大写 E。 E_UPPER, ## 使用 x 10^n 形式。 POWER_OF_TEN, }
```

科学计数法输出风格。

### Methods

#### `format_number`

- API: `public`

```gdscript
static func format_number( value: Variant, notation: Notation = Notation.AUTO, decimal_places: int = 2, trim_zeroes: bool = true, use_truncation: bool = false, scientific_style: ScientificStyle = ScientificStyle.E_LOWER ) -> String:
```

统一入口：按指定记法格式化一个数字值。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |
| `notation` | 目标记法。 |
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |
| `scientific_style` | 科学计数法的输出风格。 |

Returns: 格式化后的字符串。

Schemas:

- `value`: Variant numeric value accepted by the formatter.

#### `format_full`

- API: `public`

```gdscript
static func format_full( value: Variant, decimal_places: int = 2, trim_zeroes: bool = true, use_grouping: bool = false, use_truncation: bool = false ) -> String:
```

输出普通十进制字符串。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_grouping` | 是否为整数部分添加千分位分隔。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |

Returns: 普通十进制字符串。

Schemas:

- `value`: Variant numeric value accepted by the formatter.

#### `format_compact`

- API: `public`

```gdscript
static func format_compact( value: Variant, decimal_places: int = 2, trim_zeroes: bool = true, use_truncation: bool = false, suffixes: PackedStringArray = PackedStringArray() ) -> String:
```

输出紧凑缩写字符串，如 1.2k / 3.4M。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |
| `suffixes` | 自定义后缀表；为空时使用默认值。 |

Returns: 紧凑缩写字符串。

Schemas:

- `value`: Variant numeric value accepted by the formatter.

#### `format_scientific`

- API: `public`

```gdscript
static func format_scientific( value: Variant, decimal_places: int = 2, trim_zeroes: bool = true, use_truncation: bool = false, style: ScientificStyle = ScientificStyle.E_LOWER, engineering: bool = false ) -> String:
```

输出科学计数法或工程计数法字符串。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |
| `style` | 输出风格。 |
| `engineering` | 为 true 时输出工程计数法。 |

Returns: 科学计数法字符串。

Schemas:

- `value`: Variant numeric value accepted by the formatter.

#### `format_auto`

- API: `public`

```gdscript
static func format_auto( value: Variant, decimal_places: int = 2, trim_zeroes: bool = true, use_truncation: bool = false, scientific_style: ScientificStyle = ScientificStyle.E_LOWER ) -> String:
```

自动选择最合适的数字记法。

Parameters:

| Name | Description |
|---|---|
| `value` | 支持 int/float/String/GFBigNumber/GFFixedDecimal。 |
| `decimal_places` | 小数位数。 |
| `trim_zeroes` | 是否裁掉尾部 0。 |
| `use_truncation` | 是否使用截断而不是四舍五入。 |
| `scientific_style` | 科学计数法输出风格。 |

Returns: 自动挑选后的字符串。

Schemas:

- `value`: Variant numeric value accepted by the formatter.

## GFObjectPoolUtility

- Path: `addons/gf/standard/utilities/nodes/gf_object_pool_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFObjectPoolUtility: 节点对象池管理器。 继承自 GFUtility，管理 Node 对象的实例化与回收， 避免高频 instance/free 操作带来的内存碎片和性能抖动。 适合管理大量同类对象，如子弹、敌人单位、特效粒子、棋盘方块等。 内部使用 Node metadata 键 _gf_pool_active 跟踪节点使用状态， 因此兼容任意 Node 子类型（无需 CanvasItem/visible 支持）。 工作流程： 1. 调用 acquire(scene, parent) 从池中取出一个可用节点（或自动实例化）。 2. 对节点进行配置使用。 3. 对象生命周期结束后，调用 release(node, scene) 将其归还至池中。

### Constants

#### `HOOK_ON_RELEASE`

- API: `public`

```gdscript
const HOOK_ON_RELEASE: StringName = &"on_gf_pool_release"
```

节点可选实现：归还对象池前调用，用于清理 Tween、临时信号、运行时状态等。

#### `HOOK_ON_ACQUIRE`

- API: `public`

```gdscript
const HOOK_ON_ACQUIRE: StringName = &"on_gf_pool_acquire"
```

节点可选实现：从对象池取出并恢复激活后调用，用于重置本次使用状态。

### Properties

#### `max_available_per_scene`

- API: `public`

```gdscript
var max_available_per_scene: int = 0
```

每个 PackedScene 最多保留的可用节点数量。为 0 时不限制。

#### `manage_descendant_active_state`

- API: `public`

```gdscript
var manage_descendant_active_state: bool = true
```

是否递归管理子节点的 process_mode、visible 与 disabled 状态。

#### `prune_invalid_on_each_operation`

- API: `public`

```gdscript
var prune_invalid_on_each_operation: bool = true
```

是否在 acquire/release/count 等高频操作前立即清理失效节点。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化：清空内部池字典。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁阶段：释放所有池中的节点。

#### `acquire`

- API: `public`

```gdscript
func acquire(scene: PackedScene, parent: Node) -> Node:
```

从池中获取一个节点实例。若池为空则自动实例化并加入父节点。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要实例化的 PackedScene 资源。 |
| `parent` | 借出的节点将加入或移动到此父节点；释放时会移动到内部池根节点。 |

Returns: 可直接使用的节点实例。

#### `release`

- API: `public`

```gdscript
func release(node: Node, scene: PackedScene) -> void:
```

将节点归还到对象池，隐藏它以待下次复用。

Parameters:

| Name | Description |
|---|---|
| `node` | 要归还的节点实例（必须由此工具创建）。 |
| `scene` | 该节点所属的 PackedScene 资源，用于匹配正确的池。 |

#### `prewarm`

- API: `public`

```gdscript
func prewarm(scene: PackedScene, parent: Node, count: int) -> void:
```

预热对象池，预先实例化指定数量的节点以避免首次使用时的卡顿。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要预热的 PackedScene 资源。 |
| `parent` | 预热节点将加入此父节点。 |
| `count` | 预热的数量。 |

#### `prewarm_async`

- API: `public`

```gdscript
func prewarm_async(scene: PackedScene, parent: Node, count: int, batch_size: int = 32) -> void:
```

分批预热对象池，避免一次性实例化大量节点造成单帧卡顿。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要预热的 PackedScene 资源。 |
| `parent` | 预热节点将加入此父节点。 |
| `count` | 预热的数量。 |
| `batch_size` | 每帧最多实例化数量；小于等于 0 时退化为同步预热。 |

#### `prewarm_async_budget`

- API: `public`

```gdscript
func prewarm_async_budget( scene: PackedScene, parent: Node, count: int, msec_budget_per_frame: float = 8.0 ) -> void:
```

按单帧时间预算预热对象池，适合复杂度差异较大的 PackedScene。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要预热的 PackedScene 资源。 |
| `parent` | 预热节点将加入此父节点。 |
| `count` | 预热的数量。 |
| `msec_budget_per_frame` | 每帧实例化预算毫秒数；小于等于 0 时退化为同步预热。 |

#### `get_available_count`

- API: `public`

```gdscript
func get_available_count(scene: PackedScene) -> int:
```

获取指定场景当前池中可用（未使用）的节点数量。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要查询的 PackedScene 资源。 |

Returns: 池中可用节点数量。

#### `get_active_count`

- API: `public`

```gdscript
func get_active_count(scene: PackedScene) -> int:
```

获取指定场景当前正在使用中的节点数量。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要查询的 PackedScene 资源。 |

Returns: 当前激活节点数量。

#### `get_active_nodes`

- API: `public`

```gdscript
func get_active_nodes(scene: PackedScene) -> Array[Node]:
```

获取指定场景当前正在使用中的节点列表。

Parameters:

| Name | Description |
|---|---|
| `scene` | 要查询的 PackedScene 资源。 |

Returns: 当前激活节点数组。

#### `prune_invalid_nodes`

- API: `public`

```gdscript
func prune_invalid_nodes() -> void:
```

主动清理全部池中的失效节点引用。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取对象池诊断快照。

Returns: 以资源路径或实例 ID 为键的池状态字典。

Schemas:

- `return`: Dictionary[String, Dictionary] keyed by PackedScene resource path or instance id, with total, available, and active counts.

## GFPattern2D

- Path: `addons/gf/standard/foundation/math/gf_pattern_2d.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFPattern2D: 可复用的二维格子模式资源。 用 Array[Vector2i] 描述范围、形状、阵型或 tile pattern。它不规定格子语义， 只负责尺寸、去重、边界过滤和常用查询。

### Properties

#### `pattern_dimensions`

- API: `public`

```gdscript
var pattern_dimensions: Vector2i = Vector2i(7, 7):
```

模式编辑尺寸。小于 1 的分量会被钳制到 1。

#### `cells`

- API: `public`

```gdscript
var cells: Array[Vector2i] = []:
```

启用的格子坐标列表。

### Methods

#### `is_in_bounds`

- API: `public`

```gdscript
func is_in_bounds(cell: Vector2i) -> bool:
```

检查格子是否在 pattern 尺寸内。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 在范围内返回 true。

#### `has_cell`

- API: `public`

```gdscript
func has_cell(cell: Vector2i) -> bool:
```

检查格子是否启用。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 启用返回 true。

#### `set_cell`

- API: `public`

```gdscript
func set_cell(cell: Vector2i, enabled: bool) -> bool:
```

设置格子是否启用。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |
| `enabled` | 是否启用。 |

Returns: 实际发生变化返回 true。

#### `add_cell`

- API: `public`

```gdscript
func add_cell(cell: Vector2i) -> bool:
```

添加格子。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 实际添加返回 true。

#### `remove_cell`

- API: `public`

```gdscript
func remove_cell(cell: Vector2i) -> bool:
```

移除格子。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格子坐标。 |

Returns: 实际移除返回 true。

#### `clear_cells`

- API: `public`

```gdscript
func clear_cells() -> void:
```

清空所有格子。

#### `get_cells`

- API: `public`

```gdscript
func get_cells() -> Array[Vector2i]:
```

获取格子列表副本。

Returns: 格子列表副本。

#### `normalize_cells`

- API: `public`

```gdscript
func normalize_cells() -> void:
```

归一化格子列表，去重、排序并移除越界格子。

#### `duplicate_pattern`

- API: `public`

```gdscript
func duplicate_pattern() -> GFPattern2D:
```

创建深拷贝。

Returns: 新 pattern 资源。

## GFPointerActivityUtility

- Path: `addons/gf/standard/input/runtime/gf_pointer_activity_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFPointerActivityUtility: 通用指针活动状态工具。 由项目在 _input(event) 中显式转发事件，工具只维护按下、移动、拖拽和空闲状态， 不消费输入，也不绑定任何具体交互或业务对象。

### Signals

#### `pointer_pressed`

- API: `public`

```gdscript
signal pointer_pressed(pointer_id: int, position: Vector2, event: InputEvent)
```

指针按下时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 指针位置。 |
| `event` | 原始输入事件。 |

#### `pointer_released`

- API: `public`

```gdscript
signal pointer_released(pointer_id: int, position: Vector2, event: InputEvent)
```

指针释放时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 指针位置。 |
| `event` | 原始输入事件。 |

#### `pointer_moved`

- API: `public`

```gdscript
signal pointer_moved(pointer_id: int, position: Vector2, previous_position: Vector2, event: InputEvent)
```

指针移动时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 指针位置。 |
| `previous_position` | 上一次指针位置。 |
| `event` | 原始输入事件。 |

#### `pointer_drag_started`

- API: `public`

```gdscript
signal pointer_drag_started(pointer_id: int, start_position: Vector2, position: Vector2, event: InputEvent)
```

指针从按下状态进入拖拽时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `start_position` | 指针按下位置。 |
| `position` | 当前指针位置。 |
| `event` | 原始输入事件。 |

#### `pointer_dragged`

- API: `public`

```gdscript
signal pointer_dragged(pointer_id: int, position: Vector2, delta: Vector2, event: InputEvent)
```

指针拖拽中发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 当前指针位置。 |
| `delta` | 本次拖拽位移。 |
| `event` | 原始输入事件。 |

#### `pointer_drag_ended`

- API: `public`

```gdscript
signal pointer_drag_ended(pointer_id: int, position: Vector2, event: InputEvent)
```

指针拖拽结束时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 指针释放位置。 |
| `event` | 原始输入事件。 |

#### `pointer_idle_started`

- API: `public`

```gdscript
signal pointer_idle_started(pointer_id: int, position: Vector2)
```

指针活动超过阈值后进入空闲时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 最近活动位置。 |

#### `pointer_idle_ended`

- API: `public`

```gdscript
signal pointer_idle_ended(pointer_id: int, position: Vector2)
```

指针从空闲恢复活动时发出。

Parameters:

| Name | Description |
|---|---|
| `pointer_id` | 指针 ID；鼠标为 0，触摸为触点 index。 |
| `position` | 恢复活动位置。 |

### Properties

#### `track_mouse`

- API: `public`

```gdscript
var track_mouse: bool = true
```

是否追踪鼠标事件。

#### `track_touch`

- API: `public`

```gdscript
var track_touch: bool = true
```

是否追踪触摸事件。

#### `mouse_button_index`

- API: `public`

```gdscript
var mouse_button_index: MouseButton = MOUSE_BUTTON_LEFT
```

鼠标模式下作为主指针的按钮。

#### `drag_threshold_pixels`

- API: `public`

```gdscript
var drag_threshold_pixels: float = 8.0
```

从按下位置移动超过该距离后进入拖拽状态。

#### `idle_threshold_seconds`

- API: `public`

```gdscript
var idle_threshold_seconds: float = 0.5
```

无活动超过该秒数后进入空闲状态。

#### `is_pointer_pressed`

- API: `public`

```gdscript
var is_pointer_pressed: bool = false
```

当前是否有指针按下。

#### `is_pointer_dragging`

- API: `public`

```gdscript
var is_pointer_dragging: bool = false
```

当前是否处于拖拽状态。

#### `is_pointer_moving`

- API: `public`

```gdscript
var is_pointer_moving: bool = false
```

最近一帧是否收到指针活动。

#### `is_pointer_idle`

- API: `public`

```gdscript
var is_pointer_idle: bool = true
```

当前是否处于空闲状态。

#### `active_pointer_id`

- API: `public`

```gdscript
var active_pointer_id: int = -1
```

当前活动指针 ID；鼠标为 0，触摸为 InputEventScreenTouch.index。

#### `last_pointer_id`

- API: `public`

```gdscript
var last_pointer_id: int = -1
```

最近发生活动的指针 ID。

#### `press_position`

- API: `public`

```gdscript
var press_position: Vector2 = Vector2.ZERO
```

最近按下位置。

#### `last_position`

- API: `public`

```gdscript
var last_position: Vector2 = Vector2.ZERO
```

最近指针位置。

### Methods

#### `handle_input_event`

- API: `public`

```gdscript
func handle_input_event(event: InputEvent) -> bool:
```

处理一个输入事件。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: 识别为受追踪指针事件时返回 true。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进空闲计时。通常在 tick(delta) 或 _process(delta) 中调用。

Parameters:

| Name | Description |
|---|---|
| `delta` | 秒。 |

#### `reset_activity`

- API: `public`

```gdscript
func reset_activity() -> void:
```

清理所有指针活动状态。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 当前指针状态。

Schemas:

- `return`: Dictionary，包含 pointer id、pressed/dragging/moving/idle 标记、位置、idle 计时器和阈值配置。

## GFProgressionMath

- Path: `addons/gf/standard/foundation/math/gf_progression_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFProgressionMath: 挂机与模拟经营项目的纯进度曲线数学工具。 负责价格曲线、收益曲线、里程碑倍率、软上限与分段式离线收益结算。 它不依赖 GFArchitecture，可直接与 JSON、CSV 或外部工具导出的配置字典配合使用。

### Enums

#### `CurveMode`

- API: `public`

```gdscript
enum CurveMode { ## 常量曲线。 CONSTANT, ## 线性曲线。 LINEAR, ## 指数曲线。 EXPONENTIAL, }
```

支持的基础曲线类型。

### Methods

#### `evaluate_curve`

- API: `public`

```gdscript
static func evaluate_curve(level: int, curve_config: Dictionary) -> GFBigNumber:
```

根据配置计算某一级的曲线值。

Parameters:

| Name | Description |
|---|---|
| `level` | 目标等级。 |
| `curve_config` | 支持 `base_value/start_level/mode/per_level/multiplier/phases/overrides`。 |

Returns: 对应等级的曲线值。

Schemas:

- `curve_config`: Dictionary with optional `base_value`, `start_level`, `mode`, `per_level`, `multiplier`, `phases`, and `overrides` entries.

#### `apply_milestone_multipliers`

- API: `public`

```gdscript
static func apply_milestone_multipliers(value: Variant, level: int, milestones: Array) -> GFBigNumber:
```

为基础值叠加里程碑倍率。

Parameters:

| Name | Description |
|---|---|
| `value` | 基础数值。 |
| `level` | 当前等级。 |
| `milestones` | 里程碑数组；每项支持 `level/multiplier`。 |

Returns: 叠加后的数值。

Schemas:

- `value`: Variant numeric value accepted by GFBigNumber.
- `milestones`: Array[Dictionary] where each entry may contain `level: int` and `multiplier: Variant numeric value`.

#### `apply_soft_cap`

- API: `public`

```gdscript
static func apply_soft_cap( value: Variant, soft_cap: Variant, power: float = _DEFAULT_SOFT_CAP_POWER ) -> GFBigNumber:
```

对一个值应用幂函数型软上限。

Parameters:

| Name | Description |
|---|---|
| `value` | 原始值。 |
| `soft_cap` | 软上限起点。 |
| `power` | 超出部分的幂指数；0.5 表示平方根衰减。 |

Returns: 软上限处理后的数值。

Schemas:

- `value`: Variant numeric value accepted by GFBigNumber.
- `soft_cap`: Variant numeric value accepted by GFBigNumber.

#### `settle_offline_progress`

- API: `public`

```gdscript
static func settle_offline_progress( rate_per_second: Variant, offline_seconds: float, options: Dictionary = {} ) -> Dictionary:
```

计算一段离线时间内的收益。

Parameters:

| Name | Description |
|---|---|
| `rate_per_second` | 基础每秒产出。 |
| `offline_seconds` | 离线时长（秒）。 |
| `options` | 支持 `max_seconds/storage_remaining/segments`。 |

Returns: 包含产出与时间统计的字典。

Schemas:

- `rate_per_second`: Variant numeric value accepted by GFBigNumber.
- `options`: Dictionary with optional `max_seconds`, `storage_remaining`, and `segments: Array[Dictionary]`.
- `return`: Dictionary with `produced: GFBigNumber`, `requested_seconds: float`, `settled_seconds: float`, `consumed_seconds: float`, `expired_seconds: float`, `wasted_seconds: float`, and `storage_capped: bool`.

## GFQuadTreeUtility

- Path: `addons/gf/standard/utilities/spatial/gf_quad_tree_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFQuadTreeUtility: 纯逻辑 2D 四叉树空间划分工具。 继承自 GFUtility，提供不依赖引擎物理节点的 2D 空间划分和范围查询能力。 适用于模拟经营、RTS 等需要对海量实体进行高效范围检索的场景。 用法： 1. 调用 setup(bounds, max_depth, max_entities) 初始化树的参数。 2. 调用 insert(entity_id, rect) 将实体插入四叉树。 3. 调用 query_rect(rect)、query_radius(center, radius) 或 query_point(point) 查询。 4. 调用 update(entity_id, rect) 更新实体位置（内部先移除再插入）。 5. 调用 remove(entity_id) 移除实体。 注意：entity_id 为 int，由调用方自行管理 ID 映射。

### Constants

#### `DEFAULT_MAX_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_DEPTH: int = 8
```

默认最大树深度。

#### `DEFAULT_MAX_ENTITIES`

- API: `public`

```gdscript
const DEFAULT_MAX_ENTITIES: int = 8
```

默认每节点最大实体数（超过后分裂）。

### Properties

#### `bounds`

- API: `public`

```gdscript
var bounds: Rect2 = Rect2()
```

四叉树覆盖的世界边界。

#### `max_depth`

- API: `public`

```gdscript
var max_depth: int = DEFAULT_MAX_DEPTH
```

最大递归深度。

#### `max_entities_per_node`

- API: `public`

```gdscript
var max_entities_per_node: int = DEFAULT_MAX_ENTITIES
```

每个节点在分裂前允许的最大实体数。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化：创建空根节点。

#### `setup`

- API: `public`

```gdscript
func setup(world_bounds: Rect2, depth: int = DEFAULT_MAX_DEPTH, entities_per_node: int = DEFAULT_MAX_ENTITIES) -> void:
```

配置四叉树参数并重建。应在 init() 之前或之后调用。

Parameters:

| Name | Description |
|---|---|
| `world_bounds` | 世界边界矩形。 |
| `depth` | 最大递归深度。 |
| `entities_per_node` | 每节点最大实体数。 |

#### `insert`

- API: `public`

```gdscript
func insert(entity_id: int, rect: Rect2) -> void:
```

将实体插入四叉树。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体唯一标识。 |
| `rect` | 实体的轴对齐包围矩形。 |

#### `insert_with_hit_test`

- API: `public`

```gdscript
func insert_with_hit_test(entity_id: int, rect: Rect2, hit_test: Callable) -> void:
```

将带精确点命中测试的实体插入四叉树。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体唯一标识。 |
| `rect` | 实体的轴对齐包围矩形。 |
| `hit_test` | 可选精确命中测试，签名为 `(entity_id, point, rect) -> bool`。 |

#### `remove`

- API: `public`

```gdscript
func remove(entity_id: int) -> void:
```

从四叉树中移除实体。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 要移除的实体标识。 |

#### `update`

- API: `public`

```gdscript
func update(entity_id: int, new_rect: Rect2) -> void:
```

更新实体的位置（先移除再插入）。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体标识。 |
| `new_rect` | 新的包围矩形。 |

#### `set_entity_hit_test`

- API: `public`

```gdscript
func set_entity_hit_test(entity_id: int, hit_test: Callable) -> bool:
```

设置实体的精确点命中测试。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体标识。 |
| `hit_test` | 命中测试 Callable，签名为 `(entity_id, point, rect) -> bool`。 |

Returns: 设置成功返回 true。

#### `clear_entity_hit_test`

- API: `public`

```gdscript
func clear_entity_hit_test(entity_id: int) -> bool:
```

清除实体的精确点命中测试。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体标识。 |

Returns: 清除成功返回 true。

#### `get_entity_rect`

- API: `public`

```gdscript
func get_entity_rect(entity_id: int) -> Rect2:
```

获取实体矩形。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体标识。 |

Returns: 实体矩形；不存在时返回空 Rect2。

#### `query_rect`

- API: `public`

```gdscript
func query_rect(area: Rect2) -> Array[int]:
```

矩形范围查询：返回与查询区域有交集的所有实体 ID。

Parameters:

| Name | Description |
|---|---|
| `area` | 查询矩形。 |

Returns: 匹配的实体 ID 数组。

#### `query_radius`

- API: `public`

```gdscript
func query_radius(center: Vector2, radius: float) -> Array[int]:
```

圆形范围查询：返回包围矩形与圆有交集的所有实体 ID。

Parameters:

| Name | Description |
|---|---|
| `center` | 圆心坐标。 |
| `radius` | 查询半径。 |

Returns: 匹配的实体 ID 数组。

#### `query_point`

- API: `public`

```gdscript
func query_point(point: Vector2, use_exact_hit_tests: bool = true) -> Array[int]:
```

点查询：返回包含该点的实体 ID，可选执行精确命中测试。

Parameters:

| Name | Description |
|---|---|
| `point` | 查询点。 |
| `use_exact_hit_tests` | 是否执行通过 set_entity_hit_test() 注册的精确命中测试。 |

Returns: 匹配的实体 ID 数组。

#### `query_first_point`

- API: `public`

```gdscript
func query_first_point(point: Vector2, use_exact_hit_tests: bool = true) -> int:
```

点查询：返回第一个包含该点的实体 ID，不存在时返回 -1。

Parameters:

| Name | Description |
|---|---|
| `point` | 查询点。 |
| `use_exact_hit_tests` | 是否执行精确命中测试。 |

Returns: 第一个实体 ID；不存在时返回 -1。

#### `compact`

- API: `public`

```gdscript
func compact() -> void:
```

重建四叉树节点结构，保留实体、矩形和命中测试。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空四叉树中的所有实体并重建根节点。

#### `get_entity_count`

- API: `public`

```gdscript
func get_entity_count() -> int:
```

获取当前存储的实体总数。

Returns: 实体数量。

#### `has_entity`

- API: `public`

```gdscript
func has_entity(entity_id: int) -> bool:
```

检查实体是否存在于四叉树中。

Parameters:

| Name | Description |
|---|---|
| `entity_id` | 实体标识。 |

Returns: 是否存在。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 四叉树状态。

Schemas:

- `return`: Dictionary with `bounds: Rect2`, `entity_count: int`, `hit_test_count: int`, `max_depth: int`, `max_entities_per_node: int`, and `node_count: int`.

## GFRefCountedPool

- Path: `addons/gf/standard/utilities/pooling/gf_ref_counted_pool.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.20.0`

GFRefCountedPool: 通用 RefCounted 对象池。 用工厂 Callable 创建短生命周期 RefCounted 对象，并在归还时通过 hook 或 reset_callback 显式清理状态。它不管理 Node、场景树、资源加载或业务生命周期。

### Constants

#### `HOOK_ON_ACQUIRE`

- API: `public`

```gdscript
const HOOK_ON_ACQUIRE: StringName = &"on_gf_pool_acquire"
```

对象可选实现：从池中取出后调用。

#### `HOOK_ON_RELEASE`

- API: `public`

```gdscript
const HOOK_ON_RELEASE: StringName = &"on_gf_pool_release"
```

对象可选实现：归还池时调用。

#### `HOOK_RESET`

- API: `public`

```gdscript
const HOOK_RESET: StringName = &"reset_for_pool"
```

对象可选实现：归还池时用于清理可复用状态。

### Properties

#### `factory`

- API: `public`

```gdscript
var factory: Callable = Callable()
```

对象工厂。必须返回 RefCounted。

#### `reset_callback`

- API: `public`

```gdscript
var reset_callback: Callable = Callable()
```

归还对象时执行的可选重置回调。回调收到被归还的对象。

#### `max_available`

- API: `public`

```gdscript
var max_available: int:
```

最多保留的可用对象数量。为 0 时不限制。

#### `created_count`

- API: `public`

```gdscript
var created_count: int:
```

池累计创建对象数量。

#### `available_count`

- API: `public`

```gdscript
var available_count: int:
```

当前可用对象数量。

#### `active_count`

- API: `public`

```gdscript
var active_count: int:
```

当前借出对象数量。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_factory: Callable, p_reset_callback: Callable = Callable(), p_max_available: int = 0 ) -> GFRefCountedPool:
```

配置对象池并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_factory` | 对象工厂，必须返回 RefCounted。 |
| `p_reset_callback` | 归还对象时执行的可选重置回调。 |
| `p_max_available` | 最多保留的可用对象数量；0 表示不限制。 |

Returns: 当前对象池。

#### `acquire`

- API: `public`

```gdscript
func acquire() -> RefCounted:
```

从池中借出对象。

Returns: 借出的 RefCounted；工厂无效或返回非 RefCounted 时返回 null。

#### `release`

- API: `public`

```gdscript
func release(item: RefCounted) -> bool:
```

归还对象。

Parameters:

| Name | Description |
|---|---|
| `item` | 通过当前对象池借出的 RefCounted。 |

Returns: 成功归还或因容量上限丢弃时返回 true。

#### `prewarm`

- API: `public`

```gdscript
func prewarm(count: int) -> int:
```

预热对象池。

Parameters:

| Name | Description |
|---|---|
| `count` | 要创建并保留的可用对象数量。 |

Returns: 实际新增到可用池的数量。

#### `clear_available`

- API: `public`

```gdscript
func clear_available() -> void:
```

清空当前可用对象，不影响已经借出的对象。

#### `reset_pool`

- API: `public`

```gdscript
func reset_pool() -> void:
```

忘记借出记录并清空可用池。 这不会强制回收外部仍持有的 RefCounted，只让当前池停止追踪它们。

#### `is_active`

- API: `public`

```gdscript
func is_active(item: RefCounted) -> bool:
```

检查对象是否由当前池借出且尚未归还。

Parameters:

| Name | Description |
|---|---|
| `item` | 要检查的对象。 |

Returns: 对象处于借出状态时返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取对象池调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含 created_count、available_count、active_count 与 max_available。

## GFRegionMap2D

- Path: `addons/gf/standard/foundation/math/gf_region_map_2d.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRegionMap2D: 通用二维区域分块数据映射。 按固定区域尺寸管理格子数据，并追踪发生变化的区域，适合大地图、编辑器批处理或局部保存。

### Properties

#### `region_size`

- API: `public`

```gdscript
var region_size: Vector2i = Vector2i(32, 32)
```

每个区域包含的格子尺寸。

#### `duplicate_values`

- API: `public`

```gdscript
var duplicate_values: bool = true
```

读写值时是否复制集合类型。

### Methods

#### `get_region_key_for_cell`

- API: `public`

```gdscript
func get_region_key_for_cell(cell: Vector2i) -> Vector2i:
```

根据格坐标获取区域键。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 区域键。

#### `set_cell`

- API: `public`

```gdscript
func set_cell(cell: Vector2i, value: Variant) -> void:
```

设置格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `value` | 格子数据。 |

Schemas:

- `value`: Variant cell value stored in the region map.

#### `get_cell`

- API: `public`

```gdscript
func get_cell(cell: Vector2i, default_value: Variant = null) -> Variant:
```

获取格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 格子数据。

Schemas:

- `default_value`: Variant fallback value returned when the cell is missing.
- `return`: Variant cell value or default_value.

#### `erase_cell`

- API: `public`

```gdscript
func erase_cell(cell: Vector2i) -> bool:
```

移除格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 移除成功返回 true。

#### `has_cell`

- API: `public`

```gdscript
func has_cell(cell: Vector2i) -> bool:
```

检查格子是否存在。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 存在返回 true。

#### `get_region_cells`

- API: `public`

```gdscript
func get_region_cells(region_key: Vector2i) -> Array[Vector2i]:
```

获取区域内全部格子坐标。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 区域键。 |

Returns: 格坐标列表。

#### `get_region_snapshot`

- API: `public`

```gdscript
func get_region_snapshot(region_key: Vector2i) -> Dictionary:
```

获取区域数据快照。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 区域键。 |

Returns: 区域数据字典。

Schemas:

- `return`: Dictionary mapping Vector2i cells to stored cell values.

#### `get_region_keys`

- API: `public`

```gdscript
func get_region_keys() -> Array[Vector2i]:
```

获取已存在的区域键。

Returns: 区域键列表。

#### `get_dirty_region_keys`

- API: `public`

```gdscript
func get_dirty_region_keys() -> Array[Vector2i]:
```

获取脏区域键。

Returns: 脏区域键列表。

#### `clear_dirty`

- API: `public`

```gdscript
func clear_dirty(region_key: Variant = null) -> void:
```

清理脏区域标记。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 指定区域；为 null 时清空全部。 |

Schemas:

- `region_key`: Variant null or Vector2i region key.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空全部区域数据。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary with region_size, region_count, and dirty_region_count.

## GFRegionMap3D

- Path: `addons/gf/standard/foundation/math/gf_region_map_3d.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.18.0`

GFRegionMap3D: 通用三维区域分块数据映射。 按固定三维区域尺寸管理格子数据，并追踪发生变化的区域，适合大世界格子缓存、局部保存或编辑器批处理。

### Properties

#### `region_size`

- API: `public`

```gdscript
var region_size: Vector3i = Vector3i(32, 32, 32)
```

每个区域包含的格子尺寸。

#### `duplicate_values`

- API: `public`

```gdscript
var duplicate_values: bool = true
```

读写值时是否复制集合类型。

### Methods

#### `get_region_key_for_cell`

- API: `public`

```gdscript
func get_region_key_for_cell(cell: Vector3i) -> Vector3i:
```

根据格坐标获取区域键。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 区域键。

#### `get_region_keys_for_cell_bounds`

- API: `public`

```gdscript
func get_region_keys_for_cell_bounds(min_cell: Vector3i, max_cell: Vector3i) -> Array[Vector3i]:
```

获取闭区间格子范围覆盖的全部区域键。

Parameters:

| Name | Description |
|---|---|
| `min_cell` | 范围起点格坐标。 |
| `max_cell` | 范围终点格坐标。 |

Returns: 区域键列表。

#### `set_cell`

- API: `public`

```gdscript
func set_cell(cell: Vector3i, value: Variant) -> void:
```

设置格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `value` | 格子数据。 |

Schemas:

- `value`: Variant cell value stored in the region map.

#### `get_cell`

- API: `public`

```gdscript
func get_cell(cell: Vector3i, default_value: Variant = null) -> Variant:
```

获取格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 格子数据。

Schemas:

- `default_value`: Variant fallback value returned when the cell is missing.
- `return`: Variant cell value or default_value.

#### `erase_cell`

- API: `public`

```gdscript
func erase_cell(cell: Vector3i) -> bool:
```

移除格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 移除成功返回 true。

#### `has_cell`

- API: `public`

```gdscript
func has_cell(cell: Vector3i) -> bool:
```

检查格子是否存在。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 存在返回 true。

#### `get_region_cells`

- API: `public`

```gdscript
func get_region_cells(region_key: Vector3i) -> Array[Vector3i]:
```

获取区域内全部格子坐标。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 区域键。 |

Returns: 格坐标列表。

#### `get_region_snapshot`

- API: `public`

```gdscript
func get_region_snapshot(region_key: Vector3i) -> Dictionary:
```

获取区域数据快照。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 区域键。 |

Returns: 区域数据字典。

Schemas:

- `return`: Dictionary mapping Vector3i cells to stored cell values.

#### `get_region_keys`

- API: `public`

```gdscript
func get_region_keys() -> Array[Vector3i]:
```

获取已存在的区域键。

Returns: 区域键列表。

#### `get_dirty_region_keys`

- API: `public`

```gdscript
func get_dirty_region_keys() -> Array[Vector3i]:
```

获取脏区域键。

Returns: 脏区域键列表。

#### `clear_dirty`

- API: `public`

```gdscript
func clear_dirty(region_key: Variant = null) -> void:
```

清理脏区域标记。

Parameters:

| Name | Description |
|---|---|
| `region_key` | 指定区域；为 null 时清空全部。 |

Schemas:

- `region_key`: Variant null or Vector3i region key.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空全部区域数据。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary with region_size, region_count, cell_count, and dirty_region_count.

## GFRemoteCacheUtility

- Path: `addons/gf/standard/utilities/io/gf_remote_cache_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRemoteCacheUtility: 通用远程文本与 JSON 缓存工具。 提供 URL 请求、本地 TTL 缓存、失败时陈旧缓存回退和队列化 HTTP 访问。 具体内容类型、字段结构和业务策略由项目层自行决定。

### Signals

#### `fetch_completed`

- API: `public`

```gdscript
signal fetch_completed(url: String, result: Dictionary)
```

请求成功完成时发出。成功使用陈旧缓存回退时也会发出。

Parameters:

| Name | Description |
|---|---|
| `url` | 请求 URL。 |
| `result` | 请求结果字典。 |

Schemas:

- `result`: Dictionary，包含 success、url、content、data、from_cache、stale、response_code 和 error。

#### `fetch_failed`

- API: `public`

```gdscript
signal fetch_failed(url: String, result: Dictionary)
```

请求失败且没有可用缓存时发出。

Parameters:

| Name | Description |
|---|---|
| `url` | 请求 URL。 |
| `result` | 请求结果字典。 |

Schemas:

- `result`: Dictionary，包含 success、url、content、data、from_cache、stale、response_code 和 error。

### Properties

#### `cache_dir_name`

- API: `public`

```gdscript
var cache_dir_name: String = "gf_remote_cache"
```

user:// 下的缓存子目录名。

#### `default_ttl_seconds`

- API: `public`

```gdscript
var default_ttl_seconds: int = 86400
```

默认缓存有效期，单位秒。单次请求可覆盖。

#### `timeout_seconds`

- API: `public`

```gdscript
var timeout_seconds: float = 20.0
```

HTTP 请求超时时间，单位秒。

#### `max_cache_entries`

- API: `public`

```gdscript
var max_cache_entries: int = 128
```

最大缓存条目数，超过后会按修改时间清理最旧条目。

#### `max_pending_requests`

- API: `public`

```gdscript
var max_pending_requests: int = 64
```

最大等待队列长度。小于等于 0 表示不限制。

#### `cache_key_builder`

- API: `public`

```gdscript
var cache_key_builder: Callable = Callable()
```

自定义缓存 key 构造器。签名为 `func(url: String, headers: PackedStringArray, format: StringName) -> String`。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化远程缓存目录并启用暂停无关处理。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

取消等待请求、释放 HTTPRequest 并清理运行时状态。

#### `fetch_text`

- API: `public`

```gdscript
func fetch_text( url: String, callback: Callable = Callable(), ttl_seconds: int = -1, force_refresh: bool = false, headers: PackedStringArray = PackedStringArray() ) -> void:
```

获取远程文本。callback 签名为 `func(result: Dictionary) -> void`。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `ttl_seconds` | 缓存有效期（秒）。 |
| `force_refresh` | 为 true 时忽略现有缓存并重新请求。 |
| `headers` | HTTP 请求头数组。 |

#### `fetch_json`

- API: `public`

```gdscript
func fetch_json( url: String, callback: Callable = Callable(), ttl_seconds: int = -1, force_refresh: bool = false, headers: PackedStringArray = PackedStringArray() ) -> void:
```

获取远程 JSON。成功时 result["data"] 为解析结果。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `ttl_seconds` | 缓存有效期（秒）。 |
| `force_refresh` | 为 true 时忽略现有缓存并重新请求。 |
| `headers` | HTTP 请求头数组。 |

#### `has_valid_cache`

- API: `public`

```gdscript
func has_valid_cache( url: String, ttl_seconds: int = -1, headers: PackedStringArray = PackedStringArray(), format: StringName = &"text" ) -> bool:
```

判断 URL 当前是否存在有效缓存。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `ttl_seconds` | 缓存有效期（秒）。 |
| `headers` | HTTP 请求头。 |
| `format` | 缓存格式标识。 |

Returns: 存在有效缓存时返回 true。

#### `get_cached_text`

- API: `public`

```gdscript
func get_cached_text( url: String, ttl_seconds: int = -1, headers: PackedStringArray = PackedStringArray() ) -> String:
```

读取有效文本缓存；不存在或过期时返回空字符串。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `ttl_seconds` | 缓存有效期（秒）。 |
| `headers` | HTTP 请求头。 |

Returns: 有效缓存文本；不存在或过期时返回空字符串。

#### `remove_cache`

- API: `public`

```gdscript
func remove_cache( url: String, headers: PackedStringArray = PackedStringArray(), format: StringName = &"text" ) -> Error:
```

移除指定 URL 的缓存。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `headers` | HTTP 请求头。 |
| `format` | 缓存格式标识。 |

Returns: Godot 错误码。

#### `cancel`

- API: `public`

```gdscript
func cancel( url: String, headers: PackedStringArray = PackedStringArray(), format: StringName = &"text" ) -> int:
```

取消匹配 URL、headers 与 format 的等待或进行中请求，返回取消数量。

Parameters:

| Name | Description |
|---|---|
| `url` | 远程资源 URL。 |
| `headers` | HTTP 请求头。 |
| `format` | 缓存格式标识。 |

Returns: 已取消的回调数量。

#### `cancel_all`

- API: `public`

```gdscript
func cancel_all() -> int:
```

取消所有等待或进行中请求，返回取消数量。

Returns: 已取消的回调数量。

#### `clear_cache`

- API: `public`

```gdscript
func clear_cache() -> void:
```

清空当前缓存目录。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取远程缓存工具诊断快照。

Returns: 诊断快照字典。

Schemas:

- `return`: Dictionary，包含缓存设置、pending_count、active_url、active_cache_key 和 has_active_request。

## GFRenderWarmupManifest

- Path: `addons/gf/standard/utilities/display/gf_render_warmup_manifest.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFRenderWarmupManifest: 通用渲染预热清单。 只描述需要提前触碰的渲染相关资源，不绑定具体关卡、材质命名或项目加载流程。

### Properties

#### `manifest_id`

- API: `public`

```gdscript
var manifest_id: StringName = &""
```

清单稳定标识，便于诊断和队列统计。

#### `entries`

- API: `public`

```gdscript
var entries: Array[Dictionary] = []
```

预热条目列表。条目字段为 resource_path、resource、kind、type_hint、metadata。

Schemas:

- `entries`: Array[Dictionary]，元素包含 resource_path: String、resource: Resource 或 null、kind: StringName、type_hint: String 和 metadata: Dictionary。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary[String, Variant]，会复制到 describe() 结果中。

### Methods

#### `add_resource_path`

- API: `public`

```gdscript
func add_resource_path( resource_path: String, kind: StringName = &"", type_hint: String = "", entry_metadata: Dictionary = {} ) -> int:
```

添加资源路径条目。

Parameters:

| Name | Description |
|---|---|
| `resource_path` | 资源路径。 |
| `kind` | 资源类别提示。 |
| `type_hint` | ResourceLoader 类型提示。 |
| `entry_metadata` | 条目元数据。 |

Returns: 添加后的条目索引；失败返回 -1。

Schemas:

- `entry_metadata`: Dictionary[String, Variant]，会复制到 manifest 条目的 metadata。

#### `add_resource`

- API: `public`

```gdscript
func add_resource(resource: Resource, kind: StringName = &"", entry_metadata: Dictionary = {}) -> int:
```

添加已持有的资源条目。

Parameters:

| Name | Description |
|---|---|
| `resource` | 资源实例。 |
| `kind` | 资源类别提示。 |
| `entry_metadata` | 条目元数据。 |

Returns: 添加后的条目索引；失败返回 -1。

Schemas:

- `entry_metadata`: Dictionary[String, Variant]，会复制到 manifest 条目的 metadata。

#### `append_manifest`

- API: `public`

```gdscript
func append_manifest(manifest: GFRenderWarmupManifest) -> int:
```

合并另一个清单的条目。

Parameters:

| Name | Description |
|---|---|
| `manifest` | 来源清单。 |

Returns: 新增条目数量。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空清单条目。

#### `get_entry_count`

- API: `public`

```gdscript
func get_entry_count() -> int:
```

获取条目数量。

Returns: 条目数量。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查清单是否为空。

Returns: 为空返回 true。

#### `normalize_entry`

- API: `public`

```gdscript
static func normalize_entry(entry: Dictionary) -> Dictionary:
```

规范化预热条目字典。

Parameters:

| Name | Description |
|---|---|
| `entry` | 输入条目。 |

Returns: 包含 resource_path、resource、kind、type_hint、metadata 的规范化副本。

Schemas:

- `entry`: Dictionary，包含 resource_path、resource、kind、type_hint 和 metadata 的 manifest 条目。
- `return`: Dictionary，规范化后的 manifest 条目，包含 resource_path、resource、kind、type_hint 和 metadata。

#### `get_entries`

- API: `public`

```gdscript
func get_entries() -> Array[Dictionary]:
```

获取条目副本。

Returns: 条目数组副本。

Schemas:

- `return`: Array[Dictionary]，规范化后的 manifest 条目列表。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

描述清单。

Returns: 清单描述字典。

Schemas:

- `return`: Dictionary，包含 manifest_id、entry_count、entries 和 metadata。

## GFRenderWarmupUtility

- Path: `addons/gf/standard/utilities/display/gf_render_warmup_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRenderWarmupUtility: 通用渲染资源预热工具。 通过清单或节点树收集 Mesh、Material、Texture 等渲染资源，并按帧预算提前加载和触碰 RID。 它不决定项目何时预热、预热哪些场景或如何展示加载进度。

### Signals

#### `warmup_queued`

- API: `public`

```gdscript
signal warmup_queued(queue_id: int, manifest_id: StringName, entry_count: int)
```

清单加入预热队列时发出。

Parameters:

| Name | Description |
|---|---|
| `queue_id` | 预热队列标识。 |
| `manifest_id` | 清单标识。 |
| `entry_count` | 清单条目数量。 |

#### `warmup_entry_processed`

- API: `public`

```gdscript
signal warmup_entry_processed(queue_id: int, entry_index: int, result: Dictionary)
```

单个条目预热完成后发出。

Parameters:

| Name | Description |
|---|---|
| `queue_id` | 预热队列标识。 |
| `entry_index` | 清单条目索引。 |
| `result` | 单个条目的预热结果。 |

Schemas:

- `result`: Dictionary，包含 ok、resource_path、kind、resource_class、touched_count、error、metadata 和 entry_index。

#### `warmup_completed`

- API: `public`

```gdscript
signal warmup_completed(queue_id: int, summary: Dictionary)
```

单个清单预热完成后发出。

Parameters:

| Name | Description |
|---|---|
| `queue_id` | 预热队列标识。 |
| `summary` | 清单预热摘要。 |

Schemas:

- `summary`: Dictionary，包含 queue_id、manifest_id、total_count、processed_count、failed_count、ok、elapsed_seconds、stopped_by_budget、completed_at_unix 和 results。

### Enums

#### `TouchMode`

- API: `public`

```gdscript
enum TouchMode { ## 只加载资源并触碰 RID。 RID_ONLY, ## 使用离屏临时渲染节点让材质或 Mesh 参与一次渲染。 TEMPORARY_RENDER_NODES, }
```

预热触碰模式。

### Properties

#### `default_entries_per_tick`

- API: `public`

```gdscript
var default_entries_per_tick: int = 4
```

每次 tick 默认处理的最大条目数。

#### `default_max_seconds`

- API: `public`

```gdscript
var default_max_seconds: float = 0.0
```

默认预热时间预算，单位秒。小于等于 0 表示不限制。

#### `default_touch_mode`

- API: `public`

```gdscript
var default_touch_mode: TouchMode = TouchMode.RID_ONLY
```

默认触碰模式。

#### `keep_resources_cached`

- API: `public`

```gdscript
var keep_resources_cached: bool = true
```

是否保留已加载资源引用，避免预热后立刻被释放。

#### `instantiate_packed_scenes`

- API: `public`

```gdscript
var instantiate_packed_scenes: bool = false
```

从 PackedScene 条目预热时是否实例化场景并扫描其渲染资源。默认关闭以避免触发项目脚本副作用。

### Methods

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float) -> void:
```

推进预热队列。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

清空预热队列、缓存资源和临时渲染节点。

#### `queue_manifest`

- API: `public`

```gdscript
func queue_manifest(manifest: GFRenderWarmupManifest, options: Dictionary = {}) -> int:
```

将预热清单加入队列。

Parameters:

| Name | Description |
|---|---|
| `manifest` | 预热清单。 |
| `options` | 可选参数，支持 entries_per_tick、max_seconds、touch_mode、keep_cached、instantiate_packed_scenes。 |

Returns: 队列标识；失败返回 -1。

Schemas:

- `options`: Dictionary，包含 entries_per_tick、max_seconds、touch_mode、keep_cached、instantiate_packed_scenes、temporary_parent 和 temporary_viewport_size。

#### `warmup_manifest_now`

- API: `public`

```gdscript
func warmup_manifest_now(manifest: GFRenderWarmupManifest, options: Dictionary = {}) -> Dictionary:
```

立即预热整个清单。

Parameters:

| Name | Description |
|---|---|
| `manifest` | 预热清单。 |
| `options` | 可选参数，支持 max_seconds、touch_mode、keep_cached、instantiate_packed_scenes。 |

Returns: 预热摘要。

Schemas:

- `options`: Dictionary，包含 max_seconds、touch_mode、keep_cached、instantiate_packed_scenes、temporary_parent 和 temporary_viewport_size。
- `return`: Dictionary，包含 queue_id、manifest_id、total_count、processed_count、failed_count、ok、elapsed_seconds、stopped_by_budget、completed_at_unix 和 results。

#### `process_queue`

- API: `public`

```gdscript
func process_queue(max_entries: int = 1) -> int:
```

按预算处理队列。

Parameters:

| Name | Description |
|---|---|
| `max_entries` | 最多处理条目数。 |

Returns: 实际处理条目数。

#### `build_manifest_from_tree`

- API: `public`

```gdscript
func build_manifest_from_tree(root: Node, options: Dictionary = {}) -> GFRenderWarmupManifest:
```

从节点树收集可预热的渲染资源。

Parameters:

| Name | Description |
|---|---|
| `root` | 根节点。 |
| `options` | 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。 |

Returns: 预热清单。

Schemas:

- `options`: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。

#### `build_manifest_from_scene`

- API: `public`

```gdscript
func build_manifest_from_scene(scene: PackedScene, options: Dictionary = {}) -> GFRenderWarmupManifest:
```

从场景资源收集可预热的渲染资源。

Parameters:

| Name | Description |
|---|---|
| `scene` | 场景资源。 |
| `options` | 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。 |

Returns: 预热清单。

Schemas:

- `options`: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。

#### `build_manifest_from_scene_path`

- API: `public`

```gdscript
func build_manifest_from_scene_path(scene_path: String, options: Dictionary = {}) -> GFRenderWarmupManifest:
```

从场景路径收集可预热的渲染资源。

Parameters:

| Name | Description |
|---|---|
| `scene_path` | 场景资源路径。 |
| `options` | 可选参数，支持 manifest_id、include_materials、include_meshes、include_textures。 |

Returns: 预热清单。

Schemas:

- `options`: Dictionary，包含 manifest_id、include_materials、include_meshes 和 include_textures。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue() -> void:
```

清空尚未处理的预热队列。

#### `release_cached_resources`

- API: `public`

```gdscript
func release_cached_resources() -> void:
```

释放预热缓存的资源引用。

#### `release_temporary_render_nodes`

- API: `public`

```gdscript
func release_temporary_render_nodes() -> void:
```

释放尚未清理的离屏临时渲染节点。

#### `get_cached_resource_count`

- API: `public`

```gdscript
func get_cached_resource_count() -> int:
```

获取预热缓存资源数量。

Returns: 缓存资源数量。

#### `get_queue_size`

- API: `public`

```gdscript
func get_queue_size() -> int:
```

获取待处理队列数量。

Returns: 队列数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 queue_size、cached_resource_count、processed_entry_count、failed_entry_count、default_entries_per_tick、default_max_seconds、default_touch_mode、keep_resources_cached、instantiate_packed_scenes 和 temporary_render_node_count。

## GFReplayTimeline

- Path: `addons/gf/standard/foundation/timeline/gf_replay_timeline.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `domain_model`
- Since: `3.20.0`

GFReplayTimeline: 通用回放时间线。 按时间保存命令、输入、快照或项目自定义事件的纯数据记录，便于测试、 诊断、重放和工具链串联。它只负责排序、查询、合并和序列化，不执行事件。

### Constants

#### `EVENT_COMMAND`

- API: `public`

```gdscript
const EVENT_COMMAND: StringName = &"command"
```

通用命令事件类型。

#### `EVENT_INPUT`

- API: `public`

```gdscript
const EVENT_INPUT: StringName = &"input"
```

通用输入事件类型。

#### `EVENT_SNAPSHOT`

- API: `public`

```gdscript
const EVENT_SNAPSHOT: StringName = &"snapshot"
```

通用状态快照事件类型。

### Properties

#### `timeline_id`

- API: `public`

```gdscript
var timeline_id: StringName = &""
```

时间线标识。

#### `duration_seconds`

- API: `public`

```gdscript
var duration_seconds: float = 0.0
```

时间线总时长，单位秒。

#### `events`

- API: `public`

```gdscript
var events: Array[Dictionary] = []
```

事件列表。每项包含 time_seconds、event_kind、payload 和 metadata。

Schemas:

- `events`: Array[Dictionary]，包含 time_seconds: float、event_kind: StringName、payload: Variant 和 metadata: Dictionary。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，项目持有的录制、诊断或工具数据。

### Methods

#### `add_event`

- API: `public`

```gdscript
func add_event( time_seconds: float, event_kind: StringName, payload: Variant = null, event_metadata: Dictionary = {} ) -> Dictionary:
```

添加通用事件。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 事件时间，单位秒。 |
| `event_kind` | 事件类型。 |
| `payload` | 事件载荷。 |
| `event_metadata` | 事件元数据。 |

Returns: 新增事件字典。

Schemas:

- `payload`: Variant，命令、输入、快照或项目自定义纯数据。
- `event_metadata`: Dictionary，复制到当前事件中供项目诊断或工具使用。
- `return`: Dictionary，包含 time_seconds、event_kind、payload 和 metadata。

#### `add_command`

- API: `public`

```gdscript
func add_command( time_seconds: float, command_payload: Variant, event_metadata: Dictionary = {} ) -> Dictionary:
```

添加通用命令事件。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 事件时间，单位秒。 |
| `command_payload` | 命令载荷。 |
| `event_metadata` | 事件元数据。 |

Returns: 新增事件字典。

Schemas:

- `command_payload`: Variant，通常为命令快照或命令 ID 与参数字典。
- `event_metadata`: Dictionary，复制到当前事件中供项目诊断或工具使用。
- `return`: Dictionary，包含 time_seconds、event_kind、payload 和 metadata。

#### `add_input`

- API: `public`

```gdscript
func add_input( time_seconds: float, input_payload: Variant, event_metadata: Dictionary = {} ) -> Dictionary:
```

添加通用输入事件。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 事件时间，单位秒。 |
| `input_payload` | 输入载荷。 |
| `event_metadata` | 事件元数据。 |

Returns: 新增事件字典。

Schemas:

- `input_payload`: Variant，通常为抽象动作输入事件字典。
- `event_metadata`: Dictionary，复制到当前事件中供项目诊断或工具使用。
- `return`: Dictionary，包含 time_seconds、event_kind、payload 和 metadata。

#### `add_snapshot`

- API: `public`

```gdscript
func add_snapshot( time_seconds: float, snapshot_payload: Variant, event_metadata: Dictionary = {} ) -> Dictionary:
```

添加通用快照事件。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 事件时间，单位秒。 |
| `snapshot_payload` | 快照载荷。 |
| `event_metadata` | 事件元数据。 |

Returns: 新增事件字典。

Schemas:

- `snapshot_payload`: Variant，通常为状态快照字典。
- `event_metadata`: Dictionary，复制到当前事件中供项目诊断或工具使用。
- `return`: Dictionary，包含 time_seconds、event_kind、payload 和 metadata。

#### `append_timeline`

- API: `public`

```gdscript
func append_timeline( timeline: RefCounted, time_offset: float = 0.0, kind_filter: PackedStringArray = PackedStringArray() ) -> int:
```

合并另一条时间线。

Parameters:

| Name | Description |
|---|---|
| `timeline` | 要合并的时间线。 |
| `time_offset` | 合并时追加的时间偏移。 |
| `kind_filter` | 可选事件类型过滤；为空时合并全部事件。 |

Returns: 合并的事件数量。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空时间线。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查时间线是否为空。

Returns: 为空时返回 true。

#### `get_event_count`

- API: `public`

```gdscript
func get_event_count() -> int:
```

获取事件数量。

Returns: 事件数量。

#### `sort_events`

- API: `public`

```gdscript
func sort_events() -> void:
```

按事件时间排序。

#### `get_events`

- API: `public`

```gdscript
func get_events() -> Array[Dictionary]:
```

获取事件副本。

Returns: 事件副本数组。

Schemas:

- `return`: Array[Dictionary]，包含 time_seconds、event_kind、payload 和 metadata。

#### `get_events_by_kind`

- API: `public`

```gdscript
func get_events_by_kind(event_kind: StringName) -> Array[Dictionary]:
```

获取指定类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_kind` | 事件类型。 |

Returns: 事件副本数组。

Schemas:

- `return`: Array[Dictionary]，包含 time_seconds、event_kind、payload 和 metadata。

#### `get_events_in_range`

- API: `public`

```gdscript
func get_events_in_range( range_start: float, range_end: float, inclusive_end: bool = false ) -> Array[Dictionary]:
```

获取与时间范围相交的事件。

Parameters:

| Name | Description |
|---|---|
| `range_start` | 范围开始时间。 |
| `range_end` | 范围结束时间。 |
| `inclusive_end` | 为 true 时包含结束时间边界。 |

Returns: 事件副本数组。

Schemas:

- `return`: Array[Dictionary]，包含 time_seconds、event_kind、payload 和 metadata。

#### `duplicate_timeline`

- API: `public`

```gdscript
func duplicate_timeline() -> RefCounted:
```

复制时间线。

Returns: 新时间线。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary(json_compatible: bool = false) -> Dictionary:
```

转换为字典。

Parameters:

| Name | Description |
|---|---|
| `json_compatible` | 为 true 时会把 payload 与 metadata 转换为 JSON 兼容值。 |

Returns: 时间线字典。

Schemas:

- `return`: Dictionary，包含 timeline_id、duration_seconds、events 和 metadata。

#### `apply_dictionary`

- API: `public`

```gdscript
func apply_dictionary(data: Dictionary, json_compatible: bool = false) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 时间线字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Schemas:

- `data`: Dictionary，包含 timeline_id、duration_seconds、events 和 metadata。

#### `from_dictionary`

- API: `public`

```gdscript
static func from_dictionary(data: Dictionary, json_compatible: bool = false) -> RefCounted:
```

从字典创建时间线。

Parameters:

| Name | Description |
|---|---|
| `data` | 时间线字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Returns: 时间线。

Schemas:

- `data`: Dictionary，包含 timeline_id、duration_seconds、events 和 metadata。

## GFRequestEnvelope

- Path: `addons/gf/standard/utilities/io/gf_request_envelope.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `event_contract`
- Since: `3.17.0`

GFRequestEnvelope: 通用可重放请求描述。 只保存请求方法、地址、载荷、Header、重试与元数据，不绑定具体服务端、 账号、鉴权或业务协议。

### Properties

#### `request_id`

- API: `public`

```gdscript
var request_id: StringName = &""
```

请求稳定标识；为空时由 Outbox 入队时生成。

#### `method`

- API: `public`

```gdscript
var method: int = HTTPClient.METHOD_GET
```

HTTPClient.Method 数值。即使传输层不是 HTTP，也可把它当作通用动作类型使用。

#### `url`

- API: `public`

```gdscript
var url: String = ""
```

请求目标地址或项目自定义端点。

#### `body`

- API: `public`

```gdscript
var body: Dictionary = {}
```

请求载荷。框架不解释字段含义。

Schemas:

- `body`: Dictionary，项目传输层持有的请求载荷。

#### `headers`

- API: `public`

```gdscript
var headers: PackedStringArray = PackedStringArray()
```

请求 Header，使用 Godot HTTPRequest 兼容的 `Name: Value` 字符串格式。

#### `idempotency_key`

- API: `public`

```gdscript
var idempotency_key: String = ""
```

幂等键；为空时不参与任何框架逻辑。

#### `created_at_unix`

- API: `public`

```gdscript
var created_at_unix: int = 0
```

创建时间，Unix 秒。

#### `attempt_count`

- API: `public`

```gdscript
var attempt_count: int = 0
```

已尝试次数。

#### `max_attempts`

- API: `public`

```gdscript
var max_attempts: int = 3
```

最大尝试次数；小于等于 0 表示不限制。

#### `retry_after_msec`

- API: `public`

```gdscript
var retry_after_msec: int = 0
```

下一次允许重试的毫秒时间戳，基于 Time.get_ticks_msec()。

#### `last_error`

- API: `public`

```gdscript
var last_error: String = ""
```

最近一次失败原因。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，随请求持久化的项目侧元数据。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_method: int, p_url: String, p_body: Dictionary = {}, p_headers: PackedStringArray = PackedStringArray(), p_metadata: Dictionary = {} ) -> GFRequestEnvelope:
```

配置请求并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_method` | HTTPClient.Method 数值。 |
| `p_url` | 请求目标地址或项目自定义端点。 |
| `p_body` | 请求载荷。 |
| `p_headers` | 请求 Header。 |
| `p_metadata` | 项目自定义元数据。 |

Returns: 当前请求描述。

Schemas:

- `p_body`: Dictionary，项目传输层持有的请求载荷。
- `p_metadata`: Dictionary，随请求持久化的项目侧元数据。

#### `is_valid`

- API: `public`

```gdscript
func is_valid() -> bool:
```

检查请求是否具备最小有效信息。

Returns: 有效时返回 true。

#### `can_attempt`

- API: `public`

```gdscript
func can_attempt(now_msec: int = -1) -> bool:
```

检查当前时刻是否允许再次尝试。

Parameters:

| Name | Description |
|---|---|
| `now_msec` | 当前毫秒时间戳；小于 0 时自动读取。 |

Returns: 可尝试时返回 true。

#### `is_exhausted`

- API: `public`

```gdscript
func is_exhausted() -> bool:
```

检查是否已耗尽尝试次数。

Returns: 已耗尽时返回 true。

#### `mark_attempt`

- API: `public`

```gdscript
func mark_attempt() -> void:
```

记录一次发送尝试。

#### `mark_failure`

- API: `public`

```gdscript
func mark_failure(error: String, retry_delay_msec: int = 0) -> void:
```

记录失败并安排下一次重试。

Parameters:

| Name | Description |
|---|---|
| `error` | 失败原因。 |
| `retry_delay_msec` | 从现在起等待多少毫秒后可重试。 |

#### `mark_success`

- API: `public`

```gdscript
func mark_success() -> void:
```

记录成功状态。

#### `duplicate_request`

- API: `public`

```gdscript
func duplicate_request() -> GFRequestEnvelope:
```

复制请求描述。

Returns: 新请求描述。

#### `to_dict`

- API: `public`

```gdscript
func to_dict(json_compatible: bool = false) -> Dictionary:
```

转为字典。

Parameters:

| Name | Description |
|---|---|
| `json_compatible` | 为 true 时会把载荷与元数据转换为 JSON 兼容值。 |

Returns: 请求字典。

Schemas:

- `return`: Dictionary，包含 request_id、method、method_name、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary, json_compatible: bool = false) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 请求字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Schemas:

- `data`: Dictionary，包含 request_id、method、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。

#### `get_method_name`

- API: `public`

```gdscript
func get_method_name() -> String:
```

获取方法名称。

Returns: 方法名称。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary, json_compatible: bool = false) -> GFRequestEnvelope:
```

从字典创建请求描述。

Parameters:

| Name | Description |
|---|---|
| `data` | 请求字典。 |
| `json_compatible` | 为 true 时会先恢复类型化 JSON 值。 |

Returns: 请求描述。

Schemas:

- `data`: Dictionary，包含 request_id、method、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。

## GFRequestOutboxUtility

- Path: `addons/gf/standard/utilities/io/gf_request_outbox_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRequestOutboxUtility: 通用离线请求队列。 负责把项目提交的请求描述持久化、按重试策略重放，并通过 transport_callback 交给项目自己的网络、SDK 或工具链发送。它不内置任何账号、云服务或业务协议。

### Signals

#### `request_enqueued`

- API: `public`

```gdscript
signal request_enqueued(envelope: GFRequestEnvelope)
```

请求成功进入队列。

Parameters:

| Name | Description |
|---|---|
| `envelope` | 请求描述。 |

#### `request_started`

- API: `public`

```gdscript
signal request_started(envelope: GFRequestEnvelope)
```

请求开始重放。

Parameters:

| Name | Description |
|---|---|
| `envelope` | 请求描述。 |

#### `request_completed`

- API: `public`

```gdscript
signal request_completed(envelope: GFRequestEnvelope, result: Dictionary)
```

请求成功完成。

Parameters:

| Name | Description |
|---|---|
| `envelope` | 请求描述。 |
| `result` | transport 返回的结果字典。 |

Schemas:

- `result`: Dictionary，由 transport_callback 返回；ok 或 success=true 表示完成。

#### `request_failed`

- API: `public`

```gdscript
signal request_failed(envelope: GFRequestEnvelope, result: Dictionary)
```

请求失败。

Parameters:

| Name | Description |
|---|---|
| `envelope` | 请求描述。 |
| `result` | transport 返回的结果字典。 |

Schemas:

- `result`: Dictionary，由 transport_callback 返回，包含 error 或 reason 字段。

#### `queue_changed`

- API: `public`

```gdscript
signal queue_changed(snapshot: Dictionary)
```

队列快照变化。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 调试快照。 |

Schemas:

- `snapshot`: Dictionary，由 get_debug_snapshot() 返回的调试快照。

### Properties

#### `storage_path`

- API: `public`

```gdscript
var storage_path: String = "user://gf_request_outbox.json"
```

队列持久化路径。

#### `auto_load_on_init`

- API: `public`

```gdscript
var auto_load_on_init: bool = true
```

init() 时是否自动读取持久化队列。

#### `auto_persist`

- API: `public`

```gdscript
var auto_persist: bool = true
```

队列变化后是否自动写入 storage_path。

#### `max_queue_size`

- API: `public`

```gdscript
var max_queue_size: int = 128
```

最大等待队列长度；小于等于 0 表示不限制。

#### `default_max_attempts`

- API: `public`

```gdscript
var default_max_attempts: int = 3
```

新入队请求默认最大尝试次数；小于等于 0 表示不限制。

#### `retry_delays_msec`

- API: `public`

```gdscript
var retry_delays_msec: Array[int] = [500, 1000, 2000, 5000]
```

重试延迟序列，单位毫秒；超过长度后复用最后一个值。

Schemas:

- `retry_delays_msec`: Array，按毫秒记录的重试延迟列表。

#### `keep_failed_requests`

- API: `public`

```gdscript
var keep_failed_requests: bool = true
```

请求耗尽尝试次数后是否保留在失败列表中。

#### `max_failed_requests`

- API: `public`

```gdscript
var max_failed_requests: int = 32
```

失败列表最多保留数量；小于等于 0 表示不保留。

#### `transport_callback`

- API: `public`

```gdscript
var transport_callback: Callable = Callable()
```

传输回调，签名为 func(envelope: GFRequestEnvelope) -> Dictionary；也可返回会发出结果值的 Signal。

#### `replay_filter`

- API: `public`

```gdscript
var replay_filter: Callable = Callable()
```

可选重放过滤回调，签名为 func(envelope: GFRequestEnvelope) -> bool。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化请求 Outbox，并按配置读取持久化队列。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

按配置保存队列并清理运行时状态。

#### `enqueue_request`

- API: `public`

```gdscript
func enqueue_request( method: int, url: String, body: Dictionary = {}, headers: PackedStringArray = PackedStringArray(), metadata: Dictionary = {} ) -> GFRequestEnvelope:
```

创建并入队一个请求。

Parameters:

| Name | Description |
|---|---|
| `method` | HTTPClient.Method 数值。 |
| `url` | 请求目标地址或项目自定义端点。 |
| `body` | 请求载荷。 |
| `headers` | 请求 Header。 |
| `metadata` | 项目自定义元数据。 |

Returns: 入队成功时返回请求描述；失败返回 null。

Schemas:

- `body`: Dictionary，项目传输层持有的请求载荷。
- `metadata`: Dictionary，随请求持久化的项目侧元数据。

#### `enqueue`

- API: `public`

```gdscript
func enqueue(envelope: GFRequestEnvelope) -> bool:
```

入队已有请求描述。

Parameters:

| Name | Description |
|---|---|
| `envelope` | 请求描述。 |

Returns: 入队成功返回 true。

#### `replay`

- API: `public`

```gdscript
func replay(max_count: int = 0) -> Dictionary:
```

重放可尝试的请求。

Parameters:

| Name | Description |
|---|---|
| `max_count` | 最多处理数量；小于等于 0 表示不限制。 |

Returns: 重放报告。

Schemas:

- `return`: Dictionary，包含 ok、processed、succeeded、failed、skipped、pending、failed_stored 和 reason。

#### `remove_request`

- API: `public`

```gdscript
func remove_request(request_id: StringName) -> bool:
```

移除指定请求。

Parameters:

| Name | Description |
|---|---|
| `request_id` | 请求标识。 |

Returns: 移除成功返回 true。

#### `clear_queue`

- API: `public`

```gdscript
func clear_queue() -> void:
```

清空等待队列。

#### `clear_failed_requests`

- API: `public`

```gdscript
func clear_failed_requests() -> void:
```

清空失败请求列表。

#### `get_queue_size`

- API: `public`

```gdscript
func get_queue_size() -> int:
```

获取等待队列长度。

Returns: 队列长度。

#### `get_failed_request_count`

- API: `public`

```gdscript
func get_failed_request_count() -> int:
```

获取失败请求数量。

Returns: 失败请求数量。

#### `get_pending_requests`

- API: `public`

```gdscript
func get_pending_requests() -> Array[GFRequestEnvelope]:
```

获取等待请求副本。

Returns: 请求副本数组。

Schemas:

- `return`: Array，当前等待重放的 GFRequestEnvelope 副本。

#### `get_failed_requests`

- API: `public`

```gdscript
func get_failed_requests() -> Array[GFRequestEnvelope]:
```

获取失败请求副本。

Returns: 失败请求副本数组。

Schemas:

- `return`: Array，重试耗尽后保存的 GFRequestEnvelope 副本。

#### `save_queue`

- API: `public`

```gdscript
func save_queue() -> Error:
```

保存队列到 storage_path。

Returns: Godot 错误码。

#### `load_queue`

- API: `public`

```gdscript
func load_queue() -> Error:
```

从 storage_path 读取队列。

Returns: Godot 错误码。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照。

Schemas:

- `return`: Dictionary，包含存储设置、队列计数、传输可用性和请求 ID 列表。

## GFResultDictionary

- Path: `addons/gf/standard/foundation/validation/gf_result_dictionary.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFResultDictionary: 通用结果字典常量与轻量工厂。 用于统一 `ok`、`data`、`metadata`、`error` 等常见结果字典字段， 便于运行时服务和底层模块逐步收敛返回结构，同时保持字典兼容。

### Constants

#### `KEY_OK`

- API: `public`

```gdscript
const KEY_OK: String = "ok"
```

操作是否成功字段名。

#### `KEY_DATA`

- API: `public`

```gdscript
const KEY_DATA: String = "data"
```

结果数据字段名。

#### `KEY_METADATA`

- API: `public`

```gdscript
const KEY_METADATA: String = "metadata"
```

元数据字段名。

#### `KEY_ERROR`

- API: `public`

```gdscript
const KEY_ERROR: String = "error"
```

单个错误字段名。

#### `KEY_ERRORS`

- API: `public`

```gdscript
const KEY_ERRORS: String = "errors"
```

多个错误字段名。

#### `KEY_INTEGRITY_VALID`

- API: `public`

```gdscript
const KEY_INTEGRITY_VALID: String = "integrity_valid"
```

完整性校验结果字段名。

### Methods

#### `make`

- API: `public`

```gdscript
static func make(ok: bool, fields: Dictionary = {}) -> Dictionary:
```

创建结果字典，并写入 ok 字段。

Parameters:

| Name | Description |
|---|---|
| `ok` | 操作是否成功。 |
| `fields` | 需要合并到结果中的附加字段。 |

Returns: 新结果字典。

Schemas:

- `fields`: Dictionary fields copied into the result.
- `return`: Dictionary with ok plus caller-provided fields.

#### `make_success`

- API: `public`

```gdscript
static func make_success(fields: Dictionary = {}) -> Dictionary:
```

创建成功结果字典。

Parameters:

| Name | Description |
|---|---|
| `fields` | 需要合并到结果中的附加字段。 |

Returns: 新结果字典。

Schemas:

- `fields`: Dictionary fields copied into the result.
- `return`: Dictionary with ok set to true plus caller-provided fields.

#### `make_failure`

- API: `public`

```gdscript
static func make_failure(error: String = "", fields: Dictionary = {}) -> Dictionary:
```

创建失败结果字典，并写入 error 字段。

Parameters:

| Name | Description |
|---|---|
| `error` | 错误说明。 |
| `fields` | 需要合并到结果中的附加字段。 |

Returns: 新结果字典。

Schemas:

- `fields`: Dictionary fields copied into the result.
- `return`: Dictionary with ok set to false, error, and caller-provided fields.

## GFRichTextFormatter

- Path: `addons/gf/standard/utilities/ui/gf_rich_text_formatter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRichTextFormatter: 通用 RichTextLabel BBCode 格式化辅助。 提供安全转义、Markdown 子集转 BBCode、变量占位符替换和可配置 token 替换。 该类不加载任何资源，不规定文本来源、语言、本地化、图标集或 UI 展示规则。

### Constants

#### `MARKUP_BBCODE`

- API: `public`

```gdscript
const MARKUP_BBCODE: StringName = &"bbcode"
```

BBCode 输入模式。

#### `MARKUP_PLAIN`

- API: `public`

```gdscript
const MARKUP_PLAIN: StringName = &"plain"
```

普通文本输入模式，会先转义 BBCode 控制字符。

#### `MARKUP_MARKDOWN`

- API: `public`

```gdscript
const MARKUP_MARKDOWN: StringName = &"markdown"
```

Markdown 子集输入模式，会转换为 RichTextLabel BBCode。

### Methods

#### `to_bbcode`

- API: `public`

```gdscript
static func to_bbcode(text: String, options: Dictionary = {}) -> String:
```

格式化文本为 RichTextLabel 可用的 BBCode。

Parameters:

| Name | Description |
|---|---|
| `text` | 原始文本。 |
| `options` | 可选设置，支持 markup、variables、variable_resolver、variable_prefix、variable_suffix、token_resolver、token_prefix、token_suffix。 |

Returns: BBCode 文本。

Schemas:

- `options`: Dictionary，支持 markup、variables、variable_resolver、variable_prefix、variable_suffix、escape_variable_values、missing_variable_text、token_resolver、token_prefix、token_suffix、escape_token_values。

#### `markdown_to_bbcode`

- API: `public`

```gdscript
static func markdown_to_bbcode(text: String) -> String:
```

把常见 Markdown 子集转换为 RichTextLabel BBCode。

Parameters:

| Name | Description |
|---|---|
| `text` | Markdown 文本。 |

Returns: BBCode 文本。

#### `replace_variables`

- API: `public`

```gdscript
static func replace_variables( text: String, variables: Dictionary = {}, resolver: Callable = Callable(), options: Dictionary = {} ) -> String:
```

替换变量占位符。

Parameters:

| Name | Description |
|---|---|
| `text` | 输入文本。 |
| `variables` | 变量字典。 |
| `resolver` | 可选变量解析回调，签名为 func(name: String) -> Variant。 |
| `options` | 可选设置，支持 variable_prefix、variable_suffix、escape_variable_values、missing_variable_text。 |

Returns: 替换后的文本。

Schemas:

- `variables`: Dictionary，key 为变量名 String，value 为会转成文本的任意值。
- `options`: Dictionary，支持 variable_prefix、variable_suffix、escape_variable_values、missing_variable_text。

#### `replace_tokens`

- API: `public`

```gdscript
static func replace_tokens(text: String, resolver: Callable, options: Dictionary = {}) -> String:
```

替换可配置 token，例如 `:icon_id:`。

Parameters:

| Name | Description |
|---|---|
| `text` | 输入文本。 |
| `resolver` | token 解析回调，签名为 func(token: String) -> String。 |
| `options` | 可选设置，支持 token_prefix、token_suffix、escape_token_values。 |

Returns: 替换后的文本。

Schemas:

- `options`: Dictionary，支持 token_prefix、token_suffix、escape_token_values。

#### `escape_bbcode`

- API: `public`

```gdscript
static func escape_bbcode(text: String) -> String:
```

转义 BBCode 控制字符。

Parameters:

| Name | Description |
|---|---|
| `text` | 输入文本。 |

Returns: 可安全嵌入 BBCode 的文本。

#### `strip_bbcode`

- API: `public`

```gdscript
static func strip_bbcode(text: String) -> String:
```

移除 BBCode 标签。

Parameters:

| Name | Description |
|---|---|
| `text` | 输入文本。 |

Returns: 去掉标签后的文本。

## GFRuntimeInspectorUtility

- Path: `addons/gf/standard/utilities/debug/gf_runtime_inspector_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFRuntimeInspectorUtility: 显式 schema 驱动的运行时调参注册表。 项目主动注册可调对象和属性后，工具提供快照、读取和受控写入能力。 它不自动暴露业务对象，也不内置具体 UI 或玩法语义。

### Signals

#### `target_registered`

- API: `public`

```gdscript
signal target_registered(target_id: StringName)
```

目标注册后发出。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |

#### `target_unregistered`

- API: `public`

```gdscript
signal target_unregistered(target_id: StringName)
```

目标注销后发出。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |

#### `property_changed`

- API: `public`

```gdscript
signal property_changed(target_id: StringName, property_id: StringName, old_value: Variant, new_value: Variant)
```

属性成功写入后发出。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `property_id` | 属性 ID。 |
| `old_value` | 写入前的值。 |
| `new_value` | 写入后的值。 |

Schemas:

- `old_value`: Variant，写入前的属性值。
- `new_value`: Variant，写入后的属性值。

### Properties

#### `allow_writes`

- API: `public`

```gdscript
var allow_writes: bool = true
```

是否允许通过本工具写入值。

#### `debug_build_writes_only`

- API: `public`

```gdscript
var debug_build_writes_only: bool = true
```

为 true 时，非 debug 构建禁止写入。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放 Inspector 注册状态并解除 Overlay 面板。

#### `register_target`

- API: `public`

```gdscript
func register_target( target_id: StringName, target: Object, properties: Array[GFRuntimeTunableProperty] = [], options: Dictionary = {} ) -> bool:
```

注册一个运行时可检查目标。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `target` | 目标对象。 |
| `properties` | 可调属性列表。 |
| `options` | 可选显示参数，支持 label、group、visible。 |

Returns: 注册成功返回 true。

Schemas:

- `properties`: Array[GFRuntimeTunableProperty]，目标允许检查或写入的属性声明列表。
- `options`: Dictionary，支持 label、group 和 visible。

#### `unregister_target`

- API: `public`

```gdscript
func unregister_target(target_id: StringName) -> bool:
```

注销运行时目标。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |

Returns: 找到并移除时返回 true。

#### `has_target`

- API: `public`

```gdscript
func has_target(target_id: StringName) -> bool:
```

检查目标是否存在且仍有效。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |

Returns: 目标存在且对象有效时返回 true。

#### `register_property`

- API: `public`

```gdscript
func register_property(target_id: StringName, property: GFRuntimeTunableProperty) -> bool:
```

为目标注册或替换一个可调属性。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `property` | 可调属性声明。 |

Returns: 注册成功返回 true。

#### `remove_property`

- API: `public`

```gdscript
func remove_property(target_id: StringName, property_id: StringName) -> bool:
```

移除目标上的可调属性。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `property_id` | 属性 ID。 |

Returns: 找到并移除时返回 true。

#### `get_target_ids`

- API: `public`

```gdscript
func get_target_ids(include_hidden: bool = false) -> PackedStringArray:
```

获取目标 ID 列表。

Parameters:

| Name | Description |
|---|---|
| `include_hidden` | 为 true 时包含隐藏目标。 |

Returns: 排序后的目标 ID。

#### `get_property_value`

- API: `public`

```gdscript
func get_property_value(target_id: StringName, property_id: StringName) -> Variant:
```

读取目标属性当前值。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `property_id` | 属性 ID。 |

Returns: 当前值；找不到时返回 null。

Schemas:

- `return`: Variant，当前属性值，类型由对应 GFRuntimeTunableProperty 决定。

#### `set_property_value`

- API: `public`

```gdscript
func set_property_value(target_id: StringName, property_id: StringName, value: Variant) -> bool:
```

写入目标属性。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标 ID。 |
| `property_id` | 属性 ID。 |
| `value` | 请求写入的值。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant，请求写入的原始值，会由属性 schema 归一化。

#### `get_target_snapshot`

- API: `public`

```gdscript
func get_target_snapshot(include_hidden: bool = false) -> Array[Dictionary]:
```

读取运行时 Inspector 快照。

Parameters:

| Name | Description |
|---|---|
| `include_hidden` | 为 true 时包含隐藏目标和属性。 |

Returns: 目标快照数组。

Schemas:

- `return`: Array[Dictionary]，每个元素包含 id、label、group、visible、valid 和 properties。

#### `clear_targets`

- API: `public`

```gdscript
func clear_targets() -> void:
```

清空所有目标。

#### `attach_to_debug_overlay`

- API: `public`

```gdscript
func attach_to_debug_overlay(panel_id: StringName = &"gf.runtime_inspector") -> bool:
```

将 Inspector 快照作为文本面板注册到 GFDebugOverlayUtility。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | Overlay 面板 ID。 |

Returns: 注册成功返回 true。

#### `detach_from_debug_overlay`

- API: `public`

```gdscript
func detach_from_debug_overlay(panel_id: StringName = &"") -> void:
```

从 GFDebugOverlayUtility 移除 Inspector 面板。

Parameters:

| Name | Description |
|---|---|
| `panel_id` | Overlay 面板 ID；为空时使用当前附加的面板 ID。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取诊断快照。

Returns: 当前注册状态。

Schemas:

- `return`: Dictionary，包含 target_count、target_ids 和 writes_allowed。

## GFRuntimeTunableProperty

- Path: `addons/gf/standard/utilities/debug/gf_runtime_tunable_property.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFRuntimeTunableProperty: 运行时可调属性声明。 用显式 schema 描述一个目标对象上允许被运行时工具读取或写入的属性。 它不自动扫描业务对象，也不决定具体调参界面。

### Enums

#### `ValueKind`

- API: `public`

```gdscript
enum ValueKind { ## 不转换类型。 ANY, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Vector2。 VECTOR2, ## Vector3。 VECTOR3, ## Color。 COLOR, }
```

运行时值类型约束。

### Properties

#### `property_id`

- API: `public`

```gdscript
var property_id: StringName = &""
```

属性 ID，在同一目标内必须唯一。

#### `label`

- API: `public`

```gdscript
var label: String = ""
```

展示标签；为空时使用 property_id。

#### `group`

- API: `public`

```gdscript
var group: String = "Runtime"
```

展示分组。

#### `property_name`

- API: `public`

```gdscript
var property_name: NodePath = NodePath("")
```

目标对象上的属性路径。使用 getter/setter 回调时可为空。

#### `value_kind`

- API: `public`

```gdscript
var value_kind: ValueKind = ValueKind.ANY
```

值类型约束。

#### `read_only`

- API: `public`

```gdscript
var read_only: bool = false
```

是否只读。

#### `visible`

- API: `public`

```gdscript
var visible: bool = true
```

是否默认出现在快照中。

#### `has_min_value`

- API: `public`

```gdscript
var has_min_value: bool = false
```

是否启用最小值限制，仅对 int/float 生效。

#### `min_value`

- API: `public`

```gdscript
var min_value: float = 0.0
```

最小值。

#### `has_max_value`

- API: `public`

```gdscript
var has_max_value: bool = false
```

是否启用最大值限制，仅对 int/float 生效。

#### `max_value`

- API: `public`

```gdscript
var max_value: float = 0.0
```

最大值。

#### `step`

- API: `public`

```gdscript
var step: float = 1.0
```

建议步长，仅供 UI 使用。

#### `options`

- API: `public`

```gdscript
var options: Array = []
```

可选值列表。非空时写入值必须归一到列表内。

Schemas:

- `options`: Array，保存允许写入的候选值。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据。

Schemas:

- `metadata`: Dictionary，保存项目自定义属性元数据。

#### `getter`

- API: `public`

```gdscript
var getter: Callable
```

可选读取回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty) -> Variant`。

#### `setter`

- API: `public`

```gdscript
var setter: Callable
```

可选写入回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty, value: Variant) -> void`。

#### `validator`

- API: `public`

```gdscript
var validator: Callable
```

可选校验回调，签名为 `func(target: Object, property: GFRuntimeTunableProperty, value: Variant) -> bool`。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup( p_property_id: StringName, p_property_name: NodePath = NodePath(""), p_value_kind: ValueKind = ValueKind.ANY ) -> GFRuntimeTunableProperty:
```

设置基础字段并返回自身，便于代码构造 schema。

Parameters:

| Name | Description |
|---|---|
| `p_property_id` | 属性 ID。 |
| `p_property_name` | 目标属性路径。 |
| `p_value_kind` | 值类型约束。 |

Returns: 当前属性声明。

#### `with_range`

- API: `public`

```gdscript
func with_range(p_min_value: float, p_max_value: float, p_step: float = 1.0) -> GFRuntimeTunableProperty:
```

设置数值范围并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_min_value` | 最小值。 |
| `p_max_value` | 最大值。 |
| `p_step` | 建议步长。 |

Returns: 当前属性声明。

#### `with_options`

- API: `public`

```gdscript
func with_options(p_options: Array) -> GFRuntimeTunableProperty:
```

设置可选值列表并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_options` | 可选值列表。 |

Returns: 当前属性声明。

Schemas:

- `p_options`: Array，保存允许写入的候选值。

#### `read_value`

- API: `public`

```gdscript
func read_value(target: Object) -> Variant:
```

读取目标对象当前值。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |

Returns: 当前值；无法读取时返回 null。

Schemas:

- `return`: Variant，类型由 value_kind 和实际目标属性决定。

#### `write_value`

- API: `public`

```gdscript
func write_value(target: Object, value: Variant) -> bool:
```

写入目标对象。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标对象。 |
| `value` | 请求写入的值。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant，请求写入的原始值，会按 value_kind 和范围配置归一化。

#### `normalize_value`

- API: `public`

```gdscript
func normalize_value(value: Variant) -> Variant:
```

根据 schema 归一化写入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 归一化后的值。

Schemas:

- `value`: Variant，输入值。
- `return`: Variant，归一化后的值，类型由 value_kind 决定。

#### `to_schema`

- API: `public`

```gdscript
func to_schema() -> Dictionary:
```

生成可序列化 schema 快照。

Returns: schema 字典。

Schemas:

- `return`: Dictionary，包含 property_id、label、group、property_name、value_kind、read_only、visible、has_min_value、min_value、has_max_value、max_value、step、options 和 metadata 字段。

## GFScenePreloadEntry

- Path: `addons/gf/standard/utilities/scene/gf_scene_preload_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFScenePreloadEntry: 场景预加载图谱中的单个节点。 描述一个场景与相邻场景的关系，以及该场景是否应进入固定缓存。 它只表达资源关系，不假设关卡、地图、菜单或玩法语义。

### Properties

#### `scene_path`

- API: `public`

```gdscript
var scene_path: String = ""
```

当前场景资源路径。

#### `adjacent_scene_paths`

- API: `public`

```gdscript
var adjacent_scene_paths: PackedStringArray = PackedStringArray()
```

与当前场景相邻、可能被提前预热的场景资源路径。

#### `fixed`

- API: `public`

```gdscript
var fixed: bool = false
```

是否建议将该场景放入固定缓存。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary[String, Variant]，会复制到 describe_entry() 结果中。

### Methods

#### `get_scene_path`

- API: `public`

```gdscript
func get_scene_path() -> String:
```

获取规范化后的场景路径。

Returns: 去除首尾空白后的场景路径。

#### `get_adjacent_scene_paths`

- API: `public`

```gdscript
func get_adjacent_scene_paths() -> PackedStringArray:
```

获取去重后的相邻场景路径。

Returns: 相邻场景路径列表。

#### `describe_entry`

- API: `public`

```gdscript
func describe_entry() -> Dictionary:
```

描述当前条目。

Returns: 条目描述字典。

Schemas:

- `return`: Dictionary，包含 scene_path、adjacent_scene_paths、fixed 和 metadata。

## GFScenePreloadMap

- Path: `addons/gf/standard/utilities/scene/gf_scene_preload_map.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFScenePreloadMap: 通用场景预加载关系图。 用资源描述场景间的相邻关系，供 GFSceneUtility 或项目层根据当前场景计算预加载计划。 图谱只关注资源路径和缓存策略，不绑定地图、关卡、菜单或具体业务流。

### Properties

#### `default_radius`

- API: `public`

```gdscript
var default_radius: int = 1:
```

默认相邻搜索半径；0 表示只使用固定预加载路径。

#### `max_scheduled_scenes`

- API: `public`

```gdscript
var max_scheduled_scenes: int = 0:
```

单次计划最多返回的临时相邻场景数量；0 表示不限制。

#### `fixed_scene_paths`

- API: `public`

```gdscript
var fixed_scene_paths: PackedStringArray = PackedStringArray()
```

始终参与预加载计划的固定场景路径。

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFScenePreloadEntry] = []
```

场景关系条目列表。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary[String, Variant]，会复制到预加载计划报告中。

### Methods

#### `get_entry`

- API: `public`

```gdscript
func get_entry(scene_path: String) -> GFScenePreloadEntry:
```

获取指定路径对应的条目。

Parameters:

| Name | Description |
|---|---|
| `scene_path` | 场景资源路径。 |

Returns: 对应条目；未找到时返回 null。

#### `get_fixed_scene_paths`

- API: `public`

```gdscript
func get_fixed_scene_paths() -> PackedStringArray:
```

获取去重后的固定预加载路径。

Returns: 固定预加载路径列表。

#### `get_neighbor_scene_paths`

- API: `public`

```gdscript
func get_neighbor_scene_paths( scene_path: String, radius: int = -1, include_source: bool = false ) -> PackedStringArray:
```

获取指定场景周围的相邻场景路径。

Parameters:

| Name | Description |
|---|---|
| `scene_path` | 当前场景资源路径。 |
| `radius` | 搜索半径；小于 0 时使用 default_radius。 |
| `include_source` | 是否包含 scene_path 自身。 |

Returns: 相邻场景路径列表。

#### `get_preload_plan`

- API: `public`

```gdscript
func get_preload_plan( scene_path: String, radius: int = -1, include_fixed: bool = true ) -> Dictionary:
```

获取指定场景的预加载计划。

Parameters:

| Name | Description |
|---|---|
| `scene_path` | 当前场景资源路径。 |
| `radius` | 搜索半径；小于 0 时使用 default_radius。 |
| `include_fixed` | 是否包含固定预加载路径。 |

Returns: 预加载计划字典。

Schemas:

- `return`: Dictionary，包含 source_path、radius、include_fixed、fixed_paths、temporary_paths、paths 和 metadata。

#### `validate_map`

- API: `public`

```gdscript
func validate_map(options: Dictionary = {}) -> Dictionary:
```

校验预加载图谱结构。

Parameters:

| Name | Description |
|---|---|
| `options` | 可选参数，支持 check_exists。 |

Returns: 校验报告字典。

Schemas:

- `options`: Dictionary，包含 check_exists: bool。
- `return`: Dictionary，由 GFValidationReport.to_dict() 生成的校验报告。

## GFSceneTransitionConfig

- Path: `addons/gf/standard/utilities/scene/gf_scene_transition_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSceneTransitionConfig: 场景切换配置资源。 用资源描述一次场景切换所需的目标场景、loading scene、缓存策略、切换参数和扩展参数。

### Properties

#### `target_scene_path`

- API: `public`

```gdscript
var target_scene_path: String = ""
```

目标场景路径。

#### `loading_scene_path`

- API: `public`

```gdscript
var loading_scene_path: String = ""
```

可选 loading scene 路径。

#### `preload_before_change`

- API: `public`

```gdscript
var preload_before_change: bool = false
```

切换前是否先发起预加载。

#### `preload_as_fixed_cache`

- API: `public`

```gdscript
var preload_as_fixed_cache: bool = false
```

preload_before_change 为 true 时，是否把预加载结果写入固定缓存。

#### `cache_loaded_scene`

- API: `public`

```gdscript
var cache_loaded_scene: bool = true
```

本次切换完成后是否允许写入 GFSceneUtility 缓存。

#### `params`

- API: `public`

```gdscript
var params: Dictionary = {}
```

本次切换传递给目标场景或项目流程的参数。

Schemas:

- `params`: Dictionary[String, Variant]，复制到 GFSceneUtility 的场景切换参数。

#### `minimum_duration_seconds`

- API: `public`

```gdscript
var minimum_duration_seconds: float = 0.0
```

loading scene 最短保留秒数；为 0 时不额外等待。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义参数。

Schemas:

- `metadata`: Dictionary[String, Variant]，复制到 to_dict() 的项目自定义元数据。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为 Dictionary。

Returns: 配置字典。

Schemas:

- `return`: Dictionary，包含 target_scene_path、loading_scene_path、preload_before_change、preload_as_fixed_cache、cache_loaded_scene、params、minimum_duration_seconds 和 metadata。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典配置。

Parameters:

| Name | Description |
|---|---|
| `data` | 配置字典。 |

Schemas:

- `data`: Dictionary，由 to_dict() 生成。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFSceneTransitionConfig:
```

从 Dictionary 创建配置。

Parameters:

| Name | Description |
|---|---|
| `data` | 配置字典。 |

Returns: 新配置。

Schemas:

- `data`: Dictionary，由 to_dict() 生成。

## GFSceneUtility

- Path: `addons/gf/standard/utilities/scene/gf_scene_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSceneUtility: 场景与流程切换管理器。 封装原生场景切换，支持带有 `loading scene` 的异步加载、PackedScene 资源预加载缓存、切换参数、场景历史，并可在切换完成后清理不需要跨场景保留的 `System/Model`。

### Signals

#### `scene_load_started`

- API: `public`

```gdscript
signal scene_load_started(path: String)
```

当场景异步加载开始时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |

#### `scene_load_progress`

- API: `public`

```gdscript
signal scene_load_progress(path: String, progress: float)
```

当场景异步加载进度更新时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `progress` | 当前进度，范围在 `0.0` 到 `1.0` 之间。 |

#### `scene_load_completed`

- API: `public`

```gdscript
signal scene_load_completed(path: String, scene: PackedScene)
```

当场景异步加载完成时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `scene` | 已加载完成的场景资源。 |

#### `scene_load_failed`

- API: `public`

```gdscript
signal scene_load_failed(path: String)
```

当场景异步加载失败时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |

#### `scene_preload_started`

- API: `public`

```gdscript
signal scene_preload_started(path: String)
```

当场景预加载开始时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |

#### `scene_preload_progress`

- API: `public`

```gdscript
signal scene_preload_progress(path: String, progress: float)
```

当场景预加载进度更新时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `progress` | 当前进度，范围在 `0.0` 到 `1.0` 之间。 |

#### `scene_preload_completed`

- API: `public`

```gdscript
signal scene_preload_completed(path: String, scene: PackedScene)
```

当场景预加载完成并进入缓存时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `scene` | 已缓存的场景资源。 |

#### `scene_preload_failed`

- API: `public`

```gdscript
signal scene_preload_failed(path: String)
```

当场景预加载失败时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |

#### `scene_preload_cancelled`

- API: `public`

```gdscript
signal scene_preload_cancelled(path: String)
```

当场景预加载被取消时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |

#### `scene_switch_started`

- API: `public`

```gdscript
signal scene_switch_started(path: String, previous_path: String)
```

当一次场景切换流程开始时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `previous_path` | 切换前场景路径。 |

#### `scene_switch_completed`

- API: `public`

```gdscript
signal scene_switch_completed(path: String, previous_path: String)
```

当一次场景切换流程完成时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `previous_path` | 切换前场景路径。 |

#### `scene_switch_failed`

- API: `public`

```gdscript
signal scene_switch_failed(path: String, previous_path: String, message: String)
```

当一次场景切换流程失败时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景路径。 |
| `previous_path` | 切换前场景路径。 |
| `message` | 失败说明。 |

#### `loading_scene_shown`

- API: `public`

```gdscript
signal loading_scene_shown(path: String)
```

当 loading scene 切入后发出。

Parameters:

| Name | Description |
|---|---|
| `path` | loading scene 路径。 |

#### `loading_scene_hidden`

- API: `public`

```gdscript
signal loading_scene_hidden(path: String)
```

当 loading scene 准备退出时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | loading scene 路径。 |

#### `scene_cache_added`

- API: `public`

```gdscript
signal scene_cache_added(path: String, fixed: bool)
```

当场景资源写入预加载缓存后发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |
| `fixed` | 是否写入固定缓存。 |

#### `scene_cache_removed`

- API: `public`

```gdscript
signal scene_cache_removed(path: String, fixed: bool)
```

当场景资源从预加载缓存移除后发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |
| `fixed` | 是否来自固定缓存。 |

### Enums

#### `SceneResourceState`

- API: `public`

```gdscript
enum SceneResourceState { ## 未加载。 NOT_LOADED, ## 正在预加载。 PRELOADING, ## 已缓存 PackedScene。 PRELOADED, ## 当前 load_scene_async() 正在等待该资源。 ACTIVE_LOADING, }
```

场景资源在 GFSceneUtility 内部的缓存状态。

### Properties

#### `max_preloaded_scene_resources`

- API: `public`

```gdscript
var max_preloaded_scene_resources: int:
```

最多保留的预加载 PackedScene 数量；设为 `0` 表示禁用预加载缓存。

#### `cache_loaded_scenes`

- API: `public`

```gdscript
var cache_loaded_scenes: bool = true
```

通过 load_scene_async() 加载完成的目标场景是否写入预加载缓存。

#### `scene_preload_map`

- API: `public`

```gdscript
var scene_preload_map: GFScenePreloadMap = null
```

可选场景预加载图谱；配置后可按当前场景自动预热相邻场景。

#### `auto_preload_map_neighbors_on_switch`

- API: `public`

```gdscript
var auto_preload_map_neighbors_on_switch: bool = true
```

成功切换场景后是否自动按 scene_preload_map 预加载相邻场景。

#### `scene_preload_map_radius`

- API: `public`

```gdscript
var scene_preload_map_radius: int = -1:
```

自动图谱预加载半径；小于 0 时使用 GFScenePreloadMap.default_radius。

#### `loading_screen_fade_in_method`

- API: `public`

```gdscript
var loading_screen_fade_in_method: StringName = &"fade_in"
```

loading scene 可选淡入方法名；目标节点存在该方法时会被调用。

#### `loading_screen_fade_out_method`

- API: `public`

```gdscript
var loading_screen_fade_out_method: StringName = &"fade_out"
```

loading scene 可选淡出方法名；目标节点存在该方法时会被调用。

#### `loading_screen_progress_method`

- API: `public`

```gdscript
var loading_screen_progress_method: StringName = &"set_progress"
```

loading scene 可选进度更新方法名；不存在时会回退到 update_progress。

#### `loading_screen_progress_fallback_method`

- API: `public`

```gdscript
var loading_screen_progress_fallback_method: StringName = &"update_progress"
```

loading scene 进度更新回退方法名。

#### `loading_screen_error_method`

- API: `public`

```gdscript
var loading_screen_error_method: StringName = &"show_error"
```

loading scene 可选错误显示方法名；目标节点存在该方法时会被调用并传入错误文本。

#### `default_transition_minimum_seconds`

- API: `public`

```gdscript
var default_transition_minimum_seconds: float = 0.0
```

默认 loading scene 最短保留秒数；单次切换可覆盖。

#### `max_scene_history`

- API: `public`

```gdscript
var max_scene_history: int:
```

最多保留的场景历史数量；设为 0 表示不记录历史。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化场景工具的暂停策略。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

取消待处理场景切换并释放预加载请求、背景参数和缓存。

#### `load_scene_async`

- API: `public`

```gdscript
func load_scene_async( path: String, loading_scene_path: String = "", params: Dictionary = {}, minimum_duration_seconds: float = -1.0 ) -> void:
```

异步切换场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景资源路径。 |
| `loading_scene_path` | 可选的过渡场景路径。 |
| `params` | 本次切换参数；完成后可通过 get_current_scene_params() 读取。 |
| `minimum_duration_seconds` | loading scene 最短保留秒数；小于 0 时使用默认值。 |

Schemas:

- `params`: Dictionary[String, Variant]，切换完成后复制到当前场景参数中的场景切换参数。

#### `load_scene_with_transition`

- API: `public`

```gdscript
func load_scene_with_transition(config: GFSceneTransitionConfig) -> Error:
```

按资源配置切换场景。

Parameters:

| Name | Description |
|---|---|
| `config` | 场景切换配置。 |

Returns: 发起切换的 Godot Error。

#### `preload_scene`

- API: `public`

```gdscript
func preload_scene(path: String, fixed: bool = false) -> Error:
```

预加载一个场景资源并放入缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景资源路径。 |
| `fixed` | 为 true 时写入固定缓存，不受 LRU 容量淘汰影响。 |

Returns: 发起请求的 Godot Error。

#### `begin_background_scene_load`

- API: `public`

```gdscript
func begin_background_scene_load(path: String, params: Dictionary = {}, fixed: bool = false) -> Error:
```

后台加载一个场景并记录稍后激活时使用的参数。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景资源路径。 |
| `params` | 激活该场景时传入的参数。 |
| `fixed` | 为 true 时写入固定缓存，不受 LRU 容量淘汰影响。 |

Returns: 发起请求的 Godot Error。

Schemas:

- `params`: Dictionary[String, Variant]，后台场景激活时复制并应用的参数。

#### `activate_background_scene`

- API: `public`

```gdscript
func activate_background_scene( path: String, loading_scene_path: String = "", minimum_duration_seconds: float = -1.0 ) -> Error:
```

激活已经后台加载或正在后台加载的场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标场景资源路径。 |
| `loading_scene_path` | 可选的过渡场景路径。 |
| `minimum_duration_seconds` | loading scene 最短保留秒数；小于 0 时使用默认值。 |

Returns: 发起切换的 Godot Error。

#### `get_background_scene_params`

- API: `public`

```gdscript
func get_background_scene_params(path: String) -> Dictionary:
```

获取后台场景记录的参数副本。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 参数副本；没有记录时返回空字典。

Schemas:

- `return`: Dictionary[String, Variant]，后台场景参数。

#### `preload_scenes`

- API: `public`

```gdscript
func preload_scenes(paths: PackedStringArray, fixed: bool = false) -> Dictionary:
```

批量预加载场景资源。

Parameters:

| Name | Description |
|---|---|
| `paths` | 场景路径数组。 |
| `fixed` | 为 true 时全部写入固定缓存。 |

Returns: path -> Error 的结果字典。

Schemas:

- `return`: Dictionary[String, Error]，以场景路径为键。

#### `configure_scene_preload_map`

- API: `public`

```gdscript
func configure_scene_preload_map( preload_map: GFScenePreloadMap, radius: int = -1, auto_preload_on_switch: bool = true ) -> void:
```

配置场景预加载图谱。

Parameters:

| Name | Description |
|---|---|
| `preload_map` | 场景预加载图谱资源；传 null 可关闭图谱预加载。 |
| `radius` | 自动预加载半径；小于 0 时使用图谱默认值。 |
| `auto_preload_on_switch` | 成功切换场景后是否自动预加载相邻场景。 |

#### `get_scene_preload_map_plan`

- API: `public`

```gdscript
func get_scene_preload_map_plan(path: String, radius: int = -1, include_fixed: bool = true) -> Dictionary:
```

获取指定场景的图谱预加载计划。

Parameters:

| Name | Description |
|---|---|
| `path` | 当前场景资源路径。 |
| `radius` | 搜索半径；小于 0 时使用 scene_preload_map_radius，再小于 0 时使用图谱默认值。 |
| `include_fixed` | 是否包含固定预加载路径。 |

Returns: 预加载计划字典；未配置图谱时 ok 为 false。

Schemas:

- `return`: Dictionary，包含 ok、source_path、radius、include_fixed、fixed_paths、temporary_paths 和 errors。

#### `preload_scene_map_for`

- API: `public`

```gdscript
func preload_scene_map_for(path: String, radius: int = -1, include_fixed: bool = true) -> Dictionary:
```

按图谱为指定场景发起预加载。

Parameters:

| Name | Description |
|---|---|
| `path` | 当前场景资源路径。 |
| `radius` | 搜索半径；小于 0 时使用 scene_preload_map_radius，再小于 0 时使用图谱默认值。 |
| `include_fixed` | 是否包含固定预加载路径。 |

Returns: 预加载结果字典。

Schemas:

- `return`: Dictionary，包含 ok、source_path、radius、include_fixed、requested_count、fixed_requested、temporary_requested、results、errors 和 plan。

#### `preload_current_scene_map`

- API: `public`

```gdscript
func preload_current_scene_map(radius: int = -1, include_fixed: bool = true) -> Dictionary:
```

按图谱为当前场景发起预加载。

Parameters:

| Name | Description |
|---|---|
| `radius` | 搜索半径；小于 0 时使用 scene_preload_map_radius，再小于 0 时使用图谱默认值。 |
| `include_fixed` | 是否包含固定预加载路径。 |

Returns: 预加载结果字典。

Schemas:

- `return`: Dictionary，包含 ok、source_path、radius、include_fixed、requested_count、fixed_requested、temporary_requested、results、errors 和 plan。

#### `cancel_scene_preload`

- API: `public`

```gdscript
func cancel_scene_preload(path: String) -> void:
```

取消一个仍在进行中的预加载请求。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

#### `cancel_all_scene_preloads`

- API: `public`

```gdscript
func cancel_all_scene_preloads() -> void:
```

取消全部正在进行中的预加载请求。

#### `is_scene_preloading`

- API: `public`

```gdscript
func is_scene_preloading(path: String) -> bool:
```

检查场景是否正在预加载。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 正在预加载时返回 true。

#### `is_scene_preloaded`

- API: `public`

```gdscript
func is_scene_preloaded(path: String) -> bool:
```

检查场景是否已经预加载到缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 已缓存时返回 true。

#### `get_preloaded_scene`

- API: `public`

```gdscript
func get_preloaded_scene(path: String) -> PackedScene:
```

获取已预加载的 PackedScene。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 命中缓存时返回 PackedScene，否则返回 null。

#### `put_preloaded_scene`

- API: `public`

```gdscript
func put_preloaded_scene(path: String, scene: PackedScene, fixed: bool = false) -> void:
```

手动写入预加载缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |
| `scene` | PackedScene 实例。 |
| `fixed` | 为 true 时写入固定缓存。 |

#### `remove_preloaded_scene`

- API: `public`

```gdscript
func remove_preloaded_scene(path: String) -> void:
```

移除一个预加载场景资源。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

#### `clear_preloaded_scenes`

- API: `public`

```gdscript
func clear_preloaded_scenes(include_fixed: bool = true) -> void:
```

清空所有预加载场景资源。

Parameters:

| Name | Description |
|---|---|
| `include_fixed` | 为 true 时同时清空固定缓存。 |

#### `move_preloaded_scene_to_fixed`

- API: `public`

```gdscript
func move_preloaded_scene_to_fixed(path: String) -> bool:
```

把已缓存场景移动到固定缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 移动成功返回 true。

#### `move_preloaded_scene_to_temporary`

- API: `public`

```gdscript
func move_preloaded_scene_to_temporary(path: String) -> bool:
```

把已缓存场景移动到临时 LRU 缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 移动成功返回 true。

#### `is_preloaded_scene_fixed`

- API: `public`

```gdscript
func is_preloaded_scene_fixed(path: String) -> bool:
```

检查已缓存场景是否位于固定缓存。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 固定缓存命中时返回 true。

#### `get_preloading_scene_paths`

- API: `public`

```gdscript
func get_preloading_scene_paths() -> PackedStringArray:
```

获取正在预加载的场景路径列表。

Returns: 路径列表。

#### `get_scene_cache_debug_snapshot`

- API: `public`

```gdscript
func get_scene_cache_debug_snapshot() -> Dictionary:
```

获取场景缓存与加载状态快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含 is_loading、target_path、loading_scene_path、current_scene、loading_progress、transition、preload_cache、scene_preload_map、preloading 和 background。

#### `get_scene_resource_state`

- API: `public`

```gdscript
func get_scene_resource_state(path: String) -> int:
```

获取场景资源状态。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: SceneResourceState 枚举值。

#### `get_loading_progress`

- API: `public`

```gdscript
func get_loading_progress() -> float:
```

获取当前异步加载进度。

Returns: 当前加载进度，未加载时为 0。

#### `get_scene_resource_info`

- API: `public`

```gdscript
func get_scene_resource_info(path: String) -> Dictionary:
```

获取单个场景资源的缓存与加载信息。

Parameters:

| Name | Description |
|---|---|
| `path` | 场景路径。 |

Returns: 场景资源状态字典。

Schemas:

- `return`: Dictionary，包含 path、state、is_loading、is_preloading、is_preloaded、is_fixed、progress、cached 和 file_size_bytes。

#### `get_current_scene_params`

- API: `public`

```gdscript
func get_current_scene_params() -> Dictionary:
```

获取当前场景参数副本。

Returns: 当前场景参数。

Schemas:

- `return`: Dictionary[String, Variant]，当前场景参数。

#### `get_scene_history`

- API: `public`

```gdscript
func get_scene_history() -> Array[Dictionary]:
```

获取场景历史副本。

Returns: 场景历史列表，最新项位于数组末尾。

Schemas:

- `return`: Array[Dictionary]，元素包含 path、params 和 timestamp_unix。

#### `clear_scene_history`

- API: `public`

```gdscript
func clear_scene_history() -> void:
```

清空场景历史。

#### `pop_scene_history`

- API: `public`

```gdscript
func pop_scene_history() -> Dictionary:
```

弹出最近一个场景历史项。

Returns: 历史项；没有历史时返回空字典。

Schemas:

- `return`: Dictionary，包含 path、params 和 timestamp_unix；没有记录时为空字典。

#### `load_previous_scene`

- API: `public`

```gdscript
func load_previous_scene(loading_scene_path: String = "", minimum_duration_seconds: float = -1.0) -> Error:
```

切换到最近一个历史场景。

Parameters:

| Name | Description |
|---|---|
| `loading_scene_path` | 可选 loading scene 路径。 |
| `minimum_duration_seconds` | loading scene 最短保留秒数；小于 0 时使用默认值。 |

Returns: 发起切换的 Godot Error。

#### `mark_transient`

- API: `public`

```gdscript
func mark_transient(script_cls: Script) -> void:
```

标记一个脚本类型为瞬态实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 需要在下次切场景时清理的脚本类型。 |

#### `unmark_transient`

- API: `public`

```gdscript
func unmark_transient(script_cls: Script) -> void:
```

取消一个脚本类型的瞬态标记。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要取消标记的脚本类型。 |

#### `cleanup_transients`

- API: `public`

```gdscript
func cleanup_transients() -> void:
```

立即清理所有瞬态实例。

## GFSeedUtility

- Path: `addons/gf/standard/utilities/random/gf_seed_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSeedUtility: 全局随机数种子管理器。 内部维护一个主 RandomNumberGenerator，并支持基于字符串标签派生 出独立的子 RNG。子 RNG 的生成不推进主随机序列，可用于保证 回放系统的确定性。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化：创建主 RNG 实例。

#### `set_global_seed`

- API: `public`

```gdscript
func set_global_seed(seed_hash: int) -> void:
```

设置全局主种子，并同步应用到主 RNG。

Parameters:

| Name | Description |
|---|---|
| `seed_hash` | 用于驱动主随机数序列的整数种子。 |

#### `get_global_seed`

- API: `public`

```gdscript
func get_global_seed() -> int:
```

获取当前全局主种子。

Returns: 当前全局主种子。

#### `get_rng`

- API: `public`

```gdscript
func get_rng() -> RandomNumberGenerator:
```

获取主随机数生成器。 调用方可以直接使用该实例生成随机数；生成行为会推进主 RNG 状态。

Returns: 主随机数生成器实例。

#### `get_state`

- API: `public`

```gdscript
func get_state() -> int:
```

获取当前主 RNG 的内部精确状态。

Returns: 当前的内部状态值。

#### `set_state`

- API: `public`

```gdscript
func set_state(state: int) -> void:
```

恢复主 RNG 的内部精确状态。

Parameters:

| Name | Description |
|---|---|
| `state` | 要恢复的内部状态值。 |

#### `get_full_state`

- API: `public`

```gdscript
func get_full_state() -> Dictionary:
```

获取包含主种子、主 RNG 状态与分支计数的完整随机状态。 返回的 64 位整数状态会以十进制字符串保存，确保默认 JSON 存储可精确往返。

Returns: JSON 安全的完整随机状态。

Schemas:

- `return`: Dictionary with `state_schema_version: int`, `global_seed: String`, `rng_state: String`, and `branch_counters: Dictionary[String, String]`.

#### `set_full_state`

- API: `public`

```gdscript
func set_full_state(state: Dictionary) -> void:
```

恢复完整随机状态。

Parameters:

| Name | Description |
|---|---|
| `state` | get_full_state() 产生的字典。 |

Schemas:

- `state`: Dictionary produced by get_full_state().

#### `get_branched_rng`

- API: `public`

```gdscript
func get_branched_rng(string_seed: String) -> RandomNumberGenerator:
```

基于主 RNG 当前状态与字符串标签，派生出一个独立的子 RNG。 每次调用只推进当前标签的分支计数，不推进主 RNG 的随机序列。 同一主状态、同一标签和同一调用序号会产生确定的子随机序列。

Parameters:

| Name | Description |
|---|---|
| `string_seed` | 用于标识子随机流用途的字符串（如 "loot_table"、"enemy_ai"）。 |

Returns: 一个已完成种子初始化的独立 RandomNumberGenerator 实例。

## GFSequenceContext

- Path: `addons/gf/standard/sequence/gf_sequence_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSequenceContext: 指令序列执行上下文。 用于在一组序列步骤之间传递共享数据，并为步骤提供架构访问入口。

### Properties

#### `values`

- API: `public`

```gdscript
var values: Dictionary = {}
```

共享数据表。

Schemas:

- `values`: Dictionary shared by sequence steps.

### Methods

#### `set_architecture`

- API: `public`

```gdscript
func set_architecture(architecture: GFArchitecture) -> void:
```

设置上下文所属架构。

Parameters:

| Name | Description |
|---|---|
| `architecture` | 架构实例。 |

#### `get_architecture`

- API: `public`

```gdscript
func get_architecture() -> GFArchitecture:
```

获取上下文所属架构。

Returns: 架构实例；不可用时返回 null。

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant) -> GFSequenceContext:
```

写入共享值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `value` | 值。 |

Returns: 当前上下文，便于链式构造。

Schemas:

- `value`: Variant value stored in the sequence context.

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, default_value: Variant = null) -> Variant:
```

读取共享值。

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `default_value` | 默认值。 |

Returns: 共享值或默认值。

Schemas:

- `default_value`: Variant fallback value.
- `return`: Variant stored value or fallback value.

## GFSequenceStep

- Path: `addons/gf/standard/sequence/gf_sequence_step.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSequenceStep: 可资源化的序列步骤基类。 子类重写 `execute()` 返回 `Signal` 时，`GFCommandSequence` 默认会等待该信号完成；也可以关闭 `wait_for_result` 让步骤异步旁路。

### Properties

#### `step_id`

- API: `public`

```gdscript
var step_id: StringName = &""
```

步骤标识，便于调试和序列编辑器显示。

#### `wait_for_result`

- API: `public`

```gdscript
var wait_for_result: bool = true
```

是否等待 `execute()` 返回的 Signal。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute(_context: GFSequenceContext) -> Variant:
```

执行步骤。

Parameters:

| Name | Description |
|---|---|
| `_context` | 序列上下文。 |

Returns: 可返回 null 或 Signal。

Schemas:

- `return`: Variant, null or Signal.

#### `cancel`

- API: `public`

```gdscript
func cancel(_context: GFSequenceContext) -> void:
```

请求取消步骤。

Parameters:

| Name | Description |
|---|---|
| `_context` | 序列上下文。 |

## GFSettingDefinition

- Path: `addons/gf/standard/utilities/settings/gf_setting_definition.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSettingDefinition: 单个运行时设置项的声明。 只描述稳定键、默认值、值类型和持久化策略，不绑定具体 UI 或业务含义。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 不做类型转换。 ANY, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Vector2。 VECTOR2, ## Vector2i。 VECTOR2I, ## Color。 COLOR, ## Dictionary。 DICTIONARY, ## Array。 ARRAY, }
```

设置值类型，用于运行时输入钳制和持久化恢复。

### Properties

#### `key`

- API: `public`

```gdscript
var key: StringName = &""
```

设置项稳定键。建议使用 `category/name` 形式。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

默认值。

Schemas:

- `default_value`: Variant setting value accepted by value_type.

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.ANY
```

值类型。

#### `persistent`

- API: `public`

```gdscript
var persistent: bool = true
```

是否参与持久化保存。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供设置界面分组、排序或展示使用。

Schemas:

- `metadata`: Dictionary with optional UI grouping, ordering, label, and project-defined metadata.

### Methods

#### `get_setting_key`

- API: `public`

```gdscript
func get_setting_key() -> StringName:
```

获取稳定设置键。

Returns: 设置键；未显式设置时尝试使用资源路径。

#### `coerce_value`

- API: `public`

```gdscript
func coerce_value(value: Variant) -> Variant:
```

将输入值转换为当前定义要求的类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 转换后的值。

Schemas:

- `value`: Variant setting value accepted by value_type.
- `return`: Variant coerced to the configured value_type when possible.

#### `is_value_valid`

- API: `public`

```gdscript
func is_value_valid(value: Variant) -> bool:
```

检查值是否符合声明类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 待检查值。 |

Returns: 符合时返回 true。

Schemas:

- `value`: Variant setting value to validate against value_type.

#### `duplicate_definition`

- API: `public`

```gdscript
func duplicate_definition() -> GFSettingDefinition:
```

创建同内容拷贝，避免运行时修改污染共享资源。

Returns: 新定义。

## GFSettingsUtility

- Path: `addons/gf/standard/utilities/settings/gf_settings_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSettingsUtility: 通用设置注册、读写与持久化工具。 设置项以 StringName 键访问，可选使用 GFSettingDefinition 声明默认值和类型。 该工具只管理抽象设置值，不直接绑定窗口、音频、输入或任何项目业务。

### Signals

#### `setting_changed`

- API: `public`

```gdscript
signal setting_changed(key: StringName, old_value: Variant, new_value: Variant)
```

设置值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `old_value` | 旧值。 |
| `new_value` | 新值。 |

Schemas:

- `old_value`: Variant previous setting value or null when the setting did not exist.
- `new_value`: Variant next setting value or null when the setting was removed.

#### `settings_loaded`

- API: `public`

```gdscript
signal settings_loaded(data: Dictionary)
```

设置加载完成时发出。

Parameters:

| Name | Description |
|---|---|
| `data` | 已加载的持久化设置数据。 |

Schemas:

- `data`: Dictionary[String, Variant] loaded persisted settings data.

#### `settings_saved`

- API: `public`

```gdscript
signal settings_saved(data: Dictionary)
```

设置保存完成时发出。

Parameters:

| Name | Description |
|---|---|
| `data` | 已保存的持久化设置数据。 |

Schemas:

- `data`: Dictionary[String, Variant] saved persisted settings data produced by to_dict(true).

### Properties

#### `storage_file_name`

- API: `public`

```gdscript
var storage_file_name: String = "settings.sav"
```

默认持久化文件名。

#### `auto_load_on_init`

- API: `public`

```gdscript
var auto_load_on_init: bool = true
```

init() 时是否自动读取持久化设置。

#### `auto_save_on_change`

- API: `public`

```gdscript
var auto_save_on_change: bool = true
```

set_value() 修改持久化设置时是否自动保存。

#### `save_debounce_seconds`

- API: `public`

```gdscript
var save_debounce_seconds: float = 0.25
```

自动保存的防抖秒数；小于等于 0 时保持立即保存。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化设置工具，并按配置自动加载持久化设置或应用默认值。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放设置工具，并清理已注册定义、当前值和等待中的自动保存状态。

#### `register_definition`

- API: `public`

```gdscript
func register_definition(definition: GFSettingDefinition, apply_default: bool = true) -> void:
```

注册一个设置定义。

Parameters:

| Name | Description |
|---|---|
| `definition` | 设置定义。 |
| `apply_default` | 缺少当前值时是否写入默认值。 |

#### `register_setting`

- API: `public`

```gdscript
func register_setting( key: StringName, default_value: Variant = null, value_type: GFSettingDefinition.ValueType = GFSettingDefinition.ValueType.ANY, persistent: bool = true, metadata: Dictionary = {} ) -> GFSettingDefinition:
```

使用参数快速注册一个设置定义。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `default_value` | 默认值。 |
| `value_type` | 值类型。 |
| `persistent` | 是否持久化。 |
| `metadata` | 可选元数据。 |

Returns: 新设置定义。

Schemas:

- `default_value`: Variant default setting value accepted by value_type.
- `metadata`: Dictionary with optional UI grouping, ordering, label, and project-defined metadata.

#### `register_definitions`

- API: `public`

```gdscript
func register_definitions(definitions: Array[GFSettingDefinition]) -> void:
```

批量注册设置定义。

Parameters:

| Name | Description |
|---|---|
| `definitions` | 设置定义数组。 |

#### `get_definition`

- API: `public`

```gdscript
func get_definition(key: StringName) -> GFSettingDefinition:
```

获取指定设置定义。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |

Returns: 设置定义；不存在时返回 null。

#### `get_definitions`

- API: `public`

```gdscript
func get_definitions() -> Array[GFSettingDefinition]:
```

获取所有设置定义。

Returns: 设置定义数组。

#### `set_value`

- API: `public`

```gdscript
func set_value(key: StringName, value: Variant, save_after_change: bool = true) -> void:
```

设置一个值。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `value` | 设置值。 |
| `save_after_change` | 若为持久化设置，变化后是否保存。 |

Schemas:

- `value`: Variant setting value coerced by the registered definition when present.

#### `apply_values`

- API: `public`

```gdscript
func apply_values(values: Dictionary, options: Dictionary = {}) -> Dictionary:
```

批量应用一组设置值，适合图形质量、辅助功能或输入方案等项目预设。

Parameters:

| Name | Description |
|---|---|
| `values` | 设置键到设置值的字典。 |
| `options` | 可选行为。支持 save_after_change、emit_changes、reset_missing 与 scope。 |

Returns: 应用报告；问题项使用标准 kind 字段。

Schemas:

- `values`: Dictionary[String, Variant] mapping setting keys to new values.
- `options`: Dictionary with save_after_change: bool, emit_changes: bool, reset_missing: bool, and scope as Array, PackedStringArray, Dictionary, String, or StringName.
- `return`: Dictionary with ok, healthy, applied_count, changed_count, reset_count, skipped_count, error_count, warning_count, issue_count, and issues: Array[Dictionary].

#### `begin_batch`

- API: `public`

```gdscript
func begin_batch() -> void:
```

开始一批设置修改。批处理中自动保存会延后到 end_batch()。

#### `end_batch`

- API: `public`

```gdscript
func end_batch(save_after_change: bool = true) -> void:
```

结束一批设置修改，并在需要时合并触发一次自动保存。

Parameters:

| Name | Description |
|---|---|
| `save_after_change` | 本批变化结束后是否允许保存。 |

#### `queue_save`

- API: `public`

```gdscript
func queue_save() -> void:
```

将当前设置标记为稍后保存，受 save_debounce_seconds 控制。

#### `flush_pending_save`

- API: `public`

```gdscript
func flush_pending_save() -> Error:
```

立即执行正在等待的自动保存。

Returns: 保存结果；没有待保存内容时返回 OK。

#### `get_value`

- API: `public`

```gdscript
func get_value(key: StringName, fallback: Variant = null) -> Variant:
```

获取一个值。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `fallback` | 无当前值和默认值时返回的值。 |

Returns: 设置值。

Schemas:

- `fallback`: Variant value returned when the setting has no current value or definition.
- `return`: Variant current setting value, coerced default, or fallback.

#### `has_setting`

- API: `public`

```gdscript
func has_setting(key: StringName) -> bool:
```

检查设置是否存在当前值或定义。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |

Returns: 存在时返回 true。

#### `reset_value`

- API: `public`

```gdscript
func reset_value(key: StringName, save_after_change: bool = true) -> void:
```

重置单个设置到默认值。未定义设置会被移除。

Parameters:

| Name | Description |
|---|---|
| `key` | 设置键。 |
| `save_after_change` | 若为持久化设置，变化后是否保存。 |

#### `reset_all`

- API: `public`

```gdscript
func reset_all(save_after_change: bool = true) -> void:
```

重置所有已定义设置到默认值，并移除未定义的临时设置。

Parameters:

| Name | Description |
|---|---|
| `save_after_change` | 是否保存。 |

#### `to_dict`

- API: `public`

```gdscript
func to_dict(persistent_only: bool = true) -> Dictionary:
```

转换为可持久化字典。

Parameters:

| Name | Description |
|---|---|
| `persistent_only` | 是否仅包含 persistent 定义。 |

Returns: 设置字典。

Schemas:

- `return`: Dictionary[String, Variant] serialized setting values suitable for persistence.

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary, emit_changes: bool = true) -> void:
```

从字典恢复设置。

Parameters:

| Name | Description |
|---|---|
| `data` | 设置数据。 |
| `emit_changes` | 变化时是否发出 setting_changed。 |

Schemas:

- `data`: Dictionary[String, Variant] serialized setting values produced by to_dict().

#### `load_settings`

- API: `public`

```gdscript
func load_settings(file_name: String = "") -> Dictionary:
```

读取持久化设置。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 可选文件名；为空时使用 storage_file_name。 |

Returns: 已读取的数据。

Schemas:

- `return`: Dictionary[String, Variant] loaded persisted settings data.

#### `save_settings`

- API: `public`

```gdscript
func save_settings(file_name: String = "") -> Error:
```

保存持久化设置。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 可选文件名；为空时使用 storage_file_name。 |

Returns: Godot 错误码。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float = 0.0) -> void:
```

驱动自动保存防抖。

Parameters:

| Name | Description |
|---|---|
| `delta` | 距离上一帧的秒数。 |

## GFSignalBridge

- Path: `addons/gf/standard/utilities/signals/bridge/gf_signal_bridge.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSignalBridge: 声明式信号到 Callable 的桥接资源。 桥接只描述信号来源、目标方法、参数重排和常量参数。它不修改场景结构、 不解释信号业务含义，也不要求调用方使用特定 UI 或状态机。

### Properties

#### `bridge_id`

- API: `public`

```gdscript
var bridge_id: StringName = &""
```

桥接 ID，便于调试和项目侧索引。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该桥接。

#### `source`

- API: `public`

```gdscript
var source: GFSignalSourceRef = GFSignalSourceRef.new()
```

信号来源引用。

#### `target`

- API: `public`

```gdscript
var target: GFCallableTargetRef = GFCallableTargetRef.new()
```

调用目标引用。

#### `argument_indices`

- API: `public`

```gdscript
var argument_indices: PackedInt32Array = PackedInt32Array()
```

要从原始信号参数中抽取的索引。为空时透传全部信号参数。

#### `constant_args`

- API: `public`

```gdscript
var constant_args: Array = []
```

追加到桥接参数末尾的常量参数。

Schemas:

- `constant_args`: Array，追加在选中信号参数后的固定参数。

#### `append_context`

- API: `public`

```gdscript
var append_context: bool = false
```

是否把桥接上下文字典追加到参数末尾。

#### `one_shot`

- API: `public`

```gdscript
var one_shot: bool = false
```

是否只触发一次。

#### `connect_flags`

- API: `public`

```gdscript
var connect_flags: int = 0
```

Godot 信号连接标记。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，关联到信号桥的项目侧元数据。

### Methods

#### `connect_bridge`

- API: `public`

```gdscript
func connect_bridge( root: Node, owner: Object = null, signal_utility: GFSignalUtility = null ) -> GFSignalBridgeBinding:
```

连接桥接。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |
| `owner` | 可选连接拥有者。 |
| `signal_utility` | 可选 GFSignalUtility；为空时创建独立连接。 |

Returns: 运行中的桥接绑定；失败时返回 null。

#### `invoke`

- API: `public`

```gdscript
func invoke(root: Node, signal_args: Array = []) -> Dictionary:
```

直接执行桥接调用。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |
| `signal_args` | 原始信号参数。 |

Returns: 结构化调用结果。

Schemas:

- `signal_args`: Array，来源信号发出的原始参数。
- `return`: Dictionary，包含 ok、reason、value、bridge_id 和 args。

#### `build_callable_args`

- API: `public`

```gdscript
func build_callable_args(signal_args: Array = []) -> Array:
```

构建目标 Callable 参数。

Parameters:

| Name | Description |
|---|---|
| `signal_args` | 原始信号参数。 |

Returns: 映射后的参数。

Schemas:

- `signal_args`: Array，来源信号发出的原始参数。
- `return`: Array，传给目标 Callable 且位于 target.default_args 之前的参数。

#### `get_validation_report`

- API: `public`

```gdscript
func get_validation_report(root: Node) -> Dictionary:
```

获取校验报告。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 兼容 GFValidationReportDictionary 的报告字典。

Schemas:

- `return`: GFValidationReportDictionary 兼容 Dictionary，包含 subject、bridge_id、issues、counts、summary 和 next_action。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为调试字典。

Returns: 桥接快照。

Schemas:

- `return`: Dictionary，包含 bridge_id、enabled、source、target、argument_indices、constant_args、append_context、one_shot 和 metadata。

## GFSignalBridgeBinding

- Path: `addons/gf/standard/utilities/signals/bridge/gf_signal_bridge_binding.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFSignalBridgeBinding: 运行中的信号桥接连接。 Binding 持有桥接资源、根节点和底层 GFSignalConnection，用于在运行时断开、 检查状态，并把原生信号参数转交给桥接规则。

### Properties

#### `bridge`

- API: `public`

```gdscript
var bridge: GFSignalBridge = null
```

桥接资源。

#### `connection`

- API: `public`

```gdscript
var connection: GFSignalConnection = null
```

底层信号连接。

### Methods

#### `setup`

- API: `public`

```gdscript
func setup(new_bridge: GFSignalBridge, root: Node, new_connection: GFSignalConnection) -> void:
```

初始化绑定。

Parameters:

| Name | Description |
|---|---|
| `new_bridge` | 桥接资源。 |
| `root` | 路径解析根节点。 |
| `new_connection` | 底层连接。 |

#### `disconnect_bridge`

- API: `public`

```gdscript
func disconnect_bridge() -> void:
```

断开桥接。

#### `is_active`

- API: `public`

```gdscript
func is_active() -> bool:
```

当前绑定是否仍活跃。

Returns: 活跃时返回 true。

## GFSignalConnection

- Path: `addons/gf/standard/utilities/signals/gf_signal_connection.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFSignalConnection: 可管理的 Godot Signal 链式连接。 连接支持默认参数、过滤、映射、延迟、防抖、节流、次数限制、 累积转换、一次性触发和 owner 归属清理。

### Enums

#### `OperationType`

- API: `public`

```gdscript
enum OperationType { ## 过滤信号参数。 FILTER, ## 映射信号参数。 MAP, ## 延迟处理。 DELAY, ## 防抖处理。 DEBOUNCE, ## 节流处理。 THROTTLE, ## 跳过前若干次触发。 SKIP, ## 只接收前若干次触发。 TAKE, ## 累积转换信号参数。 SCAN, }
```

链式连接处理步骤类型。

### Methods

#### `filter`

- API: `public`

```gdscript
func filter(predicate: Callable) -> GFSignalConnection:
```

增加过滤步骤。predicate 返回 false 时停止本次回调。

Parameters:

| Name | Description |
|---|---|
| `predicate` | 用于过滤信号参数的回调。 |

Returns: 当前连接对象，便于继续链式配置。

#### `map`

- API: `public`

```gdscript
func map(mapper: Callable) -> GFSignalConnection:
```

增加映射步骤。mapper 的返回值会替换后续回调参数。

Parameters:

| Name | Description |
|---|---|
| `mapper` | 用于转换信号参数的回调。 |

Returns: 当前连接对象，便于继续链式配置。

#### `delay`

- API: `public`

```gdscript
func delay(seconds: float) -> GFSignalConnection:
```

延迟指定秒数后再继续处理。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 延迟或防抖时间（秒）。 |

Returns: 当前连接对象，便于继续链式配置。

#### `debounce`

- API: `public`

```gdscript
func debounce(seconds: float) -> GFSignalConnection:
```

防抖处理。连续触发时只保留静默期后的最后一次。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 延迟或防抖时间（秒）。 |

Returns: 当前连接对象，便于继续链式配置。

#### `throttle`

- API: `public`

```gdscript
func throttle(seconds: float) -> GFSignalConnection:
```

节流处理。指定秒数内只允许首次触发继续传递。

Parameters:

| Name | Description |
|---|---|
| `seconds` | 节流时间（秒）。 |

Returns: 当前连接对象，便于继续链式配置。

#### `skip`

- API: `public`

```gdscript
func skip(count: int) -> GFSignalConnection:
```

跳过前 count 次成功进入该步骤的触发。

Parameters:

| Name | Description |
|---|---|
| `count` | 需要跳过的次数。 |

Returns: 当前连接对象，便于继续链式配置。

#### `take`

- API: `public`

```gdscript
func take(count: int) -> GFSignalConnection:
```

只允许前 count 次成功进入该步骤的触发继续传递，耗尽后自动断开。

Parameters:

| Name | Description |
|---|---|
| `count` | 允许传递的次数。 |

Returns: 当前连接对象，便于继续链式配置。

#### `first`

- API: `public`

```gdscript
func first() -> GFSignalConnection:
```

只允许第一次成功进入该步骤的触发继续传递，之后自动断开。

Returns: 当前连接对象，便于继续链式配置。

#### `scan`

- API: `public`

```gdscript
func scan(accumulator: Variant, reducer: Callable) -> GFSignalConnection:
```

对信号参数执行累积转换。reducer 第一个参数为当前累积值，后续参数为当前信号参数。

Parameters:

| Name | Description |
|---|---|
| `accumulator` | 初始累积值。 |
| `reducer` | 累积转换回调。 |

Returns: 当前连接对象，便于继续链式配置。

Schemas:

- `accumulator`: Variant，传给 reducer 的初始累加器。

#### `start_with`

- API: `public`

```gdscript
func start_with(value: Variant) -> GFSignalConnection:
```

立即用指定参数主动执行一次链式处理。

Parameters:

| Name | Description |
|---|---|
| `value` | 初始参数；Array 会按参数列表传入，Callable 会被调用并使用其返回值。 |

Returns: 当前连接对象，便于继续链式配置。

Schemas:

- `value`: Variant，起始值、参数 Array，或返回这两类形态的 Callable。

#### `once`

- API: `public`

```gdscript
func once() -> GFSignalConnection:
```

设置为一次性连接，首次成功触发后自动断开。

Returns: 当前连接对象，便于继续链式配置。

#### `start`

- API: `public`

```gdscript
func start() -> GFSignalConnection:
```

启动连接。

Returns: 当前连接对象。

#### `disconnect_signal`

- API: `public`

```gdscript
func disconnect_signal() -> void:
```

主动断开连接。

#### `is_active`

- API: `public`

```gdscript
func is_active() -> bool:
```

当前连接是否仍有效。

Returns: 当前连接仍处于连接状态时返回 true。

#### `is_owned_by`

- API: `public`

```gdscript
func is_owned_by(owner: Object) -> bool:
```

当前连接是否属于指定 owner。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听或连接的拥有者。 |

Returns: owner 匹配时返回 true。

#### `matches`

- API: `public`

```gdscript
func matches(source_signal: Signal, callback: Callable, owner: Object = null) -> bool:
```

检查连接是否匹配指定 Signal、回调和可选 owner。

Parameters:

| Name | Description |
|---|---|
| `source_signal` | 要连接或断开的 Godot 信号。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `owner` | 监听或连接的拥有者。 |

Returns: Signal、回调和 owner 匹配时返回 true。

#### `prune_if_invalid`

- API: `public`

```gdscript
func prune_if_invalid() -> bool:
```

owner、signal 发射源或 callback 目标失效时清理连接。

Returns: 连接已被判定无效并清理时返回 true。

## GFSignalGraphDock

- Path: `addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd`
- Extends: `Control`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFSignalGraphDock: 当前场景信号连接与发射记录查看面板。 基于 GFSceneSignalAudit 渲染编辑器中保存的信号连接，并可显式开启 GFSignalRuntimeProbe 观察当前场景信号发射。面板只读，不修改场景。

### Methods

#### `set_graph_source`

- API: `public`

```gdscript
func set_graph_source(root: Node) -> void:
```

设置要查看的根节点。

Parameters:

| Name | Description |
|---|---|
| `root` | 根节点；为空时刷新时会尝试使用当前编辑场景根节点。 |

#### `refresh`

- API: `public`

```gdscript
func refresh(root: Node = null) -> void:
```

刷新信号图。

Parameters:

| Name | Description |
|---|---|
| `root` | 可选根节点；为空时使用 set_graph_source() 或当前编辑场景根节点。 |

#### `set_live_tracking_enabled`

- API: `public`

```gdscript
func set_live_tracking_enabled(enabled: bool) -> void:
```

设置运行时信号发射追踪开关。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 为 true 时追踪当前可见信号；为 false 时停止追踪。 |

#### `get_last_graph`

- API: `public`

```gdscript
func get_last_graph() -> Dictionary:
```

获取最近一次信号图快照。

Returns: 信号图字典副本。

Schemas:

- `return`: Dictionary，包含 GFSceneSignalAudit.build_signal_graph() 返回的信号图字段。

#### `get_recent_events`

- API: `public`

```gdscript
func get_recent_events() -> Array[Dictionary]:
```

获取最近信号发射记录。

Returns: 发射记录副本。

Schemas:

- `return`: Array[Dictionary]，每个元素包含 timestamp_msec、source_node_path、signal_name、arguments 和 connections 等字段。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取面板调试快照。

Returns: 面板调试快照。

Schemas:

- `return`: Dictionary，包含 graph、recent_events、live 和 ui 分区，用于编辑器诊断和测试。

## GFSignalRuntimeProbe

- Path: `addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSignalRuntimeProbe: 运行时信号发射追踪器。 以显式 watch 的方式连接节点信号，并把实际发射记录为只读事件快照。 它不修改被观察节点，不解释业务语义，也不应默认用于生产环境全局采样。

### Signals

#### `signal_emitted`

- API: `public`

```gdscript
signal signal_emitted(event: Dictionary)
```

记录到信号发射事件后发出。

Parameters:

| Name | Description |
|---|---|
| `event` | 发射事件快照。 |

Schemas:

- `event`: Dictionary，包含 timestamp_msec、process_frame、physics_frame、source_instance_id、source_node_path、signal_name、argument_count、arguments 和 connections。

#### `signal_watch_started`

- API: `public`

```gdscript
signal signal_watch_started(source_path: String, signal_name: StringName)
```

开始监听一个节点信号后发出。

Parameters:

| Name | Description |
|---|---|
| `source_path` | 信号来源节点路径。 |
| `signal_name` | 信号名称。 |

#### `signal_watch_stopped`

- API: `public`

```gdscript
signal signal_watch_stopped(source_path: String, signal_name: StringName)
```

停止监听一个节点信号后发出。

Parameters:

| Name | Description |
|---|---|
| `source_path` | 信号来源节点路径。 |
| `signal_name` | 信号名称。 |

### Constants

#### `DEFAULT_MAX_EVENTS`

- API: `public`

```gdscript
const DEFAULT_MAX_EVENTS: int = 256
```

默认保留的最近信号发射事件数量。

#### `DEFAULT_MAX_ARGUMENT_COUNT`

- API: `public`

```gdscript
const DEFAULT_MAX_ARGUMENT_COUNT: int = _MAX_SUPPORTED_ARGUMENT_COUNT
```

默认单个信号最多追踪的参数数量。

#### `DEFAULT_MAX_WATCH_TREE_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_WATCH_TREE_DEPTH: int = 64
```

默认递归监听节点树深度上限。

#### `DEFAULT_MAX_WATCH_TREE_NODES`

- API: `public`

```gdscript
const DEFAULT_MAX_WATCH_TREE_NODES: int = 4096
```

默认递归监听节点树数量上限。

### Properties

#### `max_events`

- API: `public`

```gdscript
var max_events: int = DEFAULT_MAX_EVENTS
```

最多保留的最近事件数量。小于等于 0 表示不保留历史，只发出 signal_emitted。

#### `max_argument_count`

- API: `public`

```gdscript
var max_argument_count: int = DEFAULT_MAX_ARGUMENT_COUNT
```

单个信号最多支持追踪的参数数量。

### Methods

#### `watch_node`

- API: `public`

```gdscript
func watch_node(source: Node, options: Dictionary = {}) -> Dictionary:
```

监听单个节点的信号。

Parameters:

| Name | Description |
|---|---|
| `source` | 需要观察的节点。 |
| `options` | 选项，支持 include_signals、exclude_signals、include_internal、max_argument_count 与 connect_flags。 |

Returns: 监听报告。

Schemas:

- `options`: Dictionary，支持 include_signals、exclude_signals、include_internal、max_argument_count 和 connect_flags。
- `return`: Dictionary，包含 ok、watched_count、skipped_count 和 errors。

#### `watch_tree`

- API: `public`

```gdscript
func watch_tree(root: Node, options: Dictionary = {}) -> Dictionary:
```

递归监听节点树。

Parameters:

| Name | Description |
|---|---|
| `root` | 需要观察的根节点。 |
| `options` | 选项，支持 watch_node() 选项以及 recursive、include_internal_nodes、max_node_depth 与 max_nodes。 |

Returns: 监听报告。

Schemas:

- `options`: Dictionary，支持 watch_node() 选项以及 recursive、include_internal_nodes、max_node_depth 和 max_nodes。
- `return`: Dictionary，包含 ok、watched_count、skipped_count 和 errors。

#### `unwatch_node`

- API: `public`

```gdscript
func unwatch_node(source: Node) -> int:
```

停止监听某个节点。

Parameters:

| Name | Description |
|---|---|
| `source` | 需要停止观察的节点。 |

Returns: 断开的信号数量。

#### `unwatch_all`

- API: `public`

```gdscript
func unwatch_all() -> int:
```

停止所有监听。

Returns: 断开的信号数量。

#### `clear_events`

- API: `public`

```gdscript
func clear_events() -> void:
```

清空最近事件。

#### `get_events`

- API: `public`

```gdscript
func get_events() -> Array[Dictionary]:
```

获取最近事件副本。

Returns: 事件快照数组。

Schemas:

- `return`: Array[Dictionary]，每个元素包含 timestamp_msec、process_frame、physics_frame、source_instance_id、source_node_path、signal_name、argument_count、arguments 和 connections。

#### `get_watch_count`

- API: `public`

```gdscript
func get_watch_count() -> int:
```

获取被监听的信号数量。

Returns: 当前有效监听数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 watch_count、event_count、max_events、max_argument_count 和 watches。

## GFSignalSourceRef

- Path: `addons/gf/standard/utilities/signals/bridge/gf_signal_source_ref.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSignalSourceRef: 可资源化的信号来源引用。 该资源只描述相对于某个根节点的信号来源节点和信号名，不连接信号、 不解释信号含义，也不绑定任何业务流程。

### Properties

#### `source_path`

- API: `public`

```gdscript
var source_path: NodePath = NodePath("")
```

信号来源节点路径。为空时使用传入的根节点。

#### `signal_name`

- API: `public`

```gdscript
var signal_name: StringName = &""
```

要读取的信号名。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary，关联到信号来源引用的项目侧元数据。

### Methods

#### `resolve_source`

- API: `public`

```gdscript
func resolve_source(root: Node) -> Object:
```

解析信号来源对象。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 来源对象；无法解析时返回 null。

#### `get_signal`

- API: `public`

```gdscript
func get_signal(root: Node) -> Signal:
```

获取信号。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 有效信号；无法解析时返回空 Signal。

#### `is_valid_for`

- API: `public`

```gdscript
func is_valid_for(root: Node) -> bool:
```

检查信号来源是否有效。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 有效时返回 true。

#### `get_signal_argument_count`

- API: `public`

```gdscript
func get_signal_argument_count(root: Node) -> int:
```

获取信号参数数量。

Parameters:

| Name | Description |
|---|---|
| `root` | 路径解析根节点。 |

Returns: 参数数量；无法确定时返回 -1。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为调试字典。

Returns: 来源快照。

Schemas:

- `return`: Dictionary，包含 source_path、signal_name 和 metadata。

## GFSignalUtility

- Path: `addons/gf/standard/utilities/signals/gf_signal_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSignalUtility: Godot 原生 Signal 的安全连接与链式处理工具。 用于连接不适合进入 GF 业务事件总线的节点信号，支持 owner 归属清理、 默认参数、过滤、映射、延迟、防抖和一次性触发。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放工具持有的所有 Signal 连接。

#### `connect_signal`

- API: `public`

```gdscript
func connect_signal( source_signal: Signal, callback: Callable, owner: Object = null, default_args: Array = [], connect_flags: int = 0 ) -> GFSignalConnection:
```

安全连接一个 Signal，并返回可继续链式配置的连接对象。

Parameters:

| Name | Description |
|---|---|
| `source_signal` | 要连接或断开的 Godot 信号。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `owner` | 监听或连接的拥有者。 |
| `default_args` | 回调调用时追加的默认参数。 |
| `connect_flags` | Godot 信号连接标记。 |

Returns: 创建或复用的连接对象。

Schemas:

- `default_args`: Array，调用回调时前置于信号参数之前的参数。

#### `connect_once`

- API: `public`

```gdscript
func connect_once( source_signal: Signal, callback: Callable, owner: Object = null, default_args: Array = [], connect_flags: int = 0 ) -> GFSignalConnection:
```

创建一次性 Signal 连接。

Parameters:

| Name | Description |
|---|---|
| `source_signal` | 要连接或断开的 Godot 信号。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `owner` | 监听或连接的拥有者。 |
| `default_args` | 回调调用时追加的默认参数。 |
| `connect_flags` | Godot 信号连接标记。 |

Returns: 创建或复用的一次性连接对象。

Schemas:

- `default_args`: Array，调用回调时前置于信号参数之前的参数。

#### `connect_any`

- API: `public`

```gdscript
func connect_any( source_signals: Array, callback: Callable, owner: Object = null, default_args: Array = [], connect_flags: int = 0 ) -> Array[GFSignalConnection]:
```

批量连接多个 Signal 到同一个回调。

Parameters:

| Name | Description |
|---|---|
| `source_signals` | 要连接的一组 Godot 信号。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `owner` | 监听或连接的拥有者。 |
| `default_args` | 回调调用时追加的默认参数。 |
| `connect_flags` | Godot 信号连接标记。 |

Returns: 成功创建或复用的连接列表。

Schemas:

- `source_signals`: Array，要连接到回调的 Signal 值。
- `default_args`: Array，调用回调时前置于信号参数之前的参数。

#### `disconnect_signal`

- API: `public`

```gdscript
func disconnect_signal(source_signal: Signal, callback: Callable, owner: Object = null) -> void:
```

断开指定 Signal 与回调的连接。

Parameters:

| Name | Description |
|---|---|
| `source_signal` | 要连接或断开的 Godot 信号。 |
| `callback` | 操作完成或事件触发时执行的回调。 |
| `owner` | 监听或连接的拥有者。 |

#### `disconnect_owner`

- API: `public`

```gdscript
func disconnect_owner(owner: Object) -> void:
```

断开某个 owner 拥有的全部连接。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听或连接的拥有者。 |

#### `disconnect_connections`

- API: `public`

```gdscript
func disconnect_connections(connections: Array) -> void:
```

断开一组由 connect_signal/connect_any 返回的连接。

Parameters:

| Name | Description |
|---|---|
| `connections` | 连接对象列表。 |

Schemas:

- `connections`: Array，由 connect_signal()、connect_once() 或 connect_any() 返回的 GFSignalConnection 句柄。

#### `disconnect_all`

- API: `public`

```gdscript
func disconnect_all() -> void:
```

断开所有连接。

#### `prune_invalid_connections`

- API: `public`

```gdscript
func prune_invalid_connections() -> void:
```

清理已经失效的连接。

#### `get_connection_count`

- API: `public`

```gdscript
func get_connection_count() -> int:
```

获取当前仍被工具追踪的连接数量。

Returns: 仍被工具追踪的有效连接数量。

## GFSnapshotHistoryUtility

- Path: `addons/gf/standard/utilities/history/gf_snapshot_history_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSnapshotHistoryUtility: 通用快照历史与回滚工具。 管理一组有序快照，支持捕获、前后跳转、按 ID 恢复和调试快照。 默认会使用注入架构的 `get_global_snapshot()` / `restore_global_snapshot()`， 也可以通过回调接入任意项目自定义状态。

### Signals

#### `snapshot_recorded`

- API: `public`

```gdscript
signal snapshot_recorded(snapshot_id: int, metadata: Dictionary)
```

捕获或推入快照后发出。

Parameters:

| Name | Description |
|---|---|
| `snapshot_id` | 快照 ID。 |
| `metadata` | 快照元数据副本。 |

Schemas:

- `metadata`: Dictionary[String, Variant] snapshot metadata copied from capture() or push_snapshot().

#### `snapshot_restored`

- API: `public`

```gdscript
signal snapshot_restored(snapshot_id: int, index: int)
```

恢复快照后发出。

Parameters:

| Name | Description |
|---|---|
| `snapshot_id` | 快照 ID。 |
| `index` | 恢复后的当前位置。 |

#### `history_changed`

- API: `public`

```gdscript
signal history_changed(snapshot: Dictionary)
```

历史内容或当前位置变化后发出。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 调试快照。 |

Schemas:

- `snapshot`: Dictionary produced by get_debug_snapshot().

### Properties

#### `max_history_size`

- API: `public`

```gdscript
var max_history_size: int:
```

最多保留的快照数量；为 0 时不限制。

#### `current_index`

- API: `public`

```gdscript
var current_index: int:
```

当前快照索引；没有快照时为 -1。

#### `snapshot_count`

- API: `public`

```gdscript
var snapshot_count: int:
```

当前快照数量。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放快照历史并清理捕获、恢复回调。

#### `configure`

- API: `public`

```gdscript
func configure( capture_callback: Callable = Callable(), restore_callback: Callable = Callable(), options: Dictionary = {} ) -> void:
```

配置快照捕获与恢复回调。

Parameters:

| Name | Description |
|---|---|
| `capture_callback` | 可选捕获回调，签名为 func() -> Variant。 |
| `restore_callback` | 可选恢复回调，签名为 func(data: Variant) -> void。 |
| `options` | 可选设置，支持 max_history_size、restore_command_builder。 |

Schemas:

- `options`: Dictionary with max_history_size: int and restore_command_builder: Callable.

#### `capture`

- API: `public`

```gdscript
func capture(metadata: Dictionary = {}) -> int:
```

捕获当前状态并写入历史。

Parameters:

| Name | Description |
|---|---|
| `metadata` | 快照元数据。 |

Returns: 快照 ID；捕获失败时返回 0。

Schemas:

- `metadata`: Dictionary[String, Variant] copied into the snapshot record.

#### `push_snapshot`

- API: `public`

```gdscript
func push_snapshot(data: Variant, metadata: Dictionary = {}) -> int:
```

推入一份外部快照数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 快照数据。 |
| `metadata` | 快照元数据。 |

Returns: 快照 ID。

Schemas:

- `data`: Variant snapshot payload; Array and Dictionary values are deep-copied.
- `metadata`: Dictionary[String, Variant] copied into the snapshot record.

#### `step`

- API: `public`

```gdscript
func step(offset: int) -> bool:
```

按相对偏移恢复快照。

Parameters:

| Name | Description |
|---|---|
| `offset` | 相对当前位置的偏移，负数向旧快照移动，正数向新快照移动。 |

Returns: 成功恢复时返回 true。

#### `step_back`

- API: `public`

```gdscript
func step_back() -> bool:
```

恢复到上一份快照。

Returns: 成功恢复时返回 true。

#### `step_forward`

- API: `public`

```gdscript
func step_forward() -> bool:
```

恢复到下一份快照。

Returns: 成功恢复时返回 true。

#### `restore_index`

- API: `public`

```gdscript
func restore_index(index: int) -> bool:
```

按索引恢复快照。

Parameters:

| Name | Description |
|---|---|
| `index` | 快照索引。 |

Returns: 成功恢复时返回 true。

#### `restore_snapshot_id`

- API: `public`

```gdscript
func restore_snapshot_id(snapshot_id: int) -> bool:
```

按快照 ID 恢复快照。

Parameters:

| Name | Description |
|---|---|
| `snapshot_id` | 快照 ID。 |

Returns: 成功恢复时返回 true。

#### `can_step_back`

- API: `public`

```gdscript
func can_step_back() -> bool:
```

是否可以恢复到上一份快照。

Returns: 可以后退时返回 true。

#### `can_step_forward`

- API: `public`

```gdscript
func can_step_forward() -> bool:
```

是否可以恢复到下一份快照。

Returns: 可以前进时返回 true。

#### `get_current_snapshot`

- API: `public`

```gdscript
func get_current_snapshot() -> Dictionary:
```

获取当前快照副本。

Returns: 当前快照记录；没有快照时返回空字典。

Schemas:

- `return`: Dictionary with id, created_at_unix, metadata, and data.

#### `get_history`

- API: `public`

```gdscript
func get_history() -> Array[Dictionary]:
```

获取全部历史副本。

Returns: 快照记录数组。

Schemas:

- `return`: Array[Dictionary] of snapshot records with id, created_at_unix, metadata, and data.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空历史。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 工具状态字典。

Schemas:

- `return`: Dictionary with snapshot_count, current_index, current_snapshot_id, max_history_size, can_step_back, can_step_forward, and ids.

## GFSourceSpan

- Path: `addons/gf/standard/foundation/validation/gf_source_span.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSourceSpan: 通用源码或资源文本定位范围。 用于把校验、导入、生成器或编辑器工具中的问题定位到一个稳定的 source_path、line、column 范围。行列约定为 1-based，0 表示未知。

### Properties

#### `source_path`

- API: `public`

```gdscript
var source_path: String = ""
```

源文件或资源路径。

#### `line`

- API: `public`

```gdscript
var line: int = 0
```

起始行号，1-based；0 表示未知。

#### `column`

- API: `public`

```gdscript
var column: int = 0
```

起始列号，1-based；0 表示未知。

#### `length`

- API: `public`

```gdscript
var length: int = 0
```

同一行内的跨度长度；0 表示未知。

#### `end_line`

- API: `public`

```gdscript
var end_line: int = 0
```

结束行号，1-based；0 表示未知。

#### `end_column`

- API: `public`

```gdscript
var end_column: int = 0
```

结束列号，1-based；0 表示未知。

#### `preview`

- API: `public`

```gdscript
var preview: String = ""
```

可选源码预览。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: Dictionary caller metadata.

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_source_path: String = "", p_line: int = 0, p_column: int = 0, p_length: int = 0, p_end_line: int = 0, p_end_column: int = 0, p_preview: String = "", p_metadata: Dictionary = {} ) -> RefCounted:
```

配置定位范围。

Parameters:

| Name | Description |
|---|---|
| `p_source_path` | 源文件或资源路径。 |
| `p_line` | 起始行号，1-based；0 表示未知。 |
| `p_column` | 起始列号，1-based；0 表示未知。 |
| `p_length` | 同一行内的跨度长度；0 表示未知。 |
| `p_end_line` | 结束行号，1-based；0 表示未知。 |
| `p_end_column` | 结束列号，1-based；0 表示未知。 |
| `p_preview` | 可选源码预览。 |
| `p_metadata` | 调用方附加元数据。 |

Returns: 当前定位范围。

Schemas:

- `p_metadata`: Dictionary caller metadata.

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

从字典应用字段。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。`source` 会作为 `source_path` 的兼容别名读取。 |

Schemas:

- `data`: Dictionary source span fields.

#### `to_dict`

- API: `public`

```gdscript
func to_dict(include_empty_fields: bool = false, include_legacy_source_alias: bool = false) -> Dictionary:
```

转换为字典。

Parameters:

| Name | Description |
|---|---|
| `include_empty_fields` | 为 true 时包含空字段。 |
| `include_legacy_source_alias` | 为 true 时额外写入 `source` 兼容字段。 |

Returns: 字典副本。

Schemas:

- `return`: Dictionary source span fields.

#### `duplicate_span`

- API: `public`

```gdscript
func duplicate_span() -> RefCounted:
```

创建当前定位范围的深拷贝。

Returns: 新定位范围。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查是否没有任何定位信息。

Returns: 没有路径且没有位置时返回 true。

#### `has_source_path`

- API: `public`

```gdscript
func has_source_path() -> bool:
```

检查是否有源路径。

Returns: 有源路径时返回 true。

#### `has_position`

- API: `public`

```gdscript
func has_position() -> bool:
```

检查是否有起始行号。

Returns: 有起始行号时返回 true。

#### `get_effective_end_line`

- API: `public`

```gdscript
func get_effective_end_line() -> int:
```

获取有效结束行。

Returns: 显式 end_line 或起始行。

#### `get_effective_end_column`

- API: `public`

```gdscript
func get_effective_end_column() -> int:
```

获取有效结束列。

Returns: 显式 end_column，或根据 column 与 length 推导出的列号。

#### `get_location_text`

- API: `public`

```gdscript
func get_location_text() -> String:
```

生成人类可读定位文本。

Returns: 例如 `res://table.csv:4:2`。

#### `merge_into_dictionary`

- API: `public`

```gdscript
func merge_into_dictionary( target: Dictionary, include_empty_fields: bool = false, include_legacy_source_alias: bool = false ) -> Dictionary:
```

将定位字段写入目标字典。

Parameters:

| Name | Description |
|---|---|
| `target` | 目标字典。 |
| `include_empty_fields` | 为 true 时包含空字段。 |
| `include_legacy_source_alias` | 为 true 时额外写入 `source` 兼容字段。 |

Returns: 目标字典。

Schemas:

- `target`: Dictionary updated in place.
- `return`: Dictionary same instance as target with source span fields.

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> RefCounted:
```

从字典创建定位范围。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新定位范围。

Schemas:

- `data`: Dictionary source span fields.

#### `from_issue`

- API: `public`

```gdscript
static func from_issue(issue: Variant) -> RefCounted:
```

从问题对象或问题字典创建定位范围。

Parameters:

| Name | Description |
|---|---|
| `issue` | GFValidationIssue 或问题字典。 |

Returns: 新定位范围。

Schemas:

- `issue`: Variant GFValidationIssue-like object or Dictionary.

#### `make`

- API: `public`

```gdscript
static func make( p_source_path: String = "", p_line: int = 0, p_column: int = 0, p_length: int = 0 ) -> RefCounted:
```

创建定位范围。

Parameters:

| Name | Description |
|---|---|
| `p_source_path` | 源文件或资源路径。 |
| `p_line` | 起始行号，1-based；0 表示未知。 |
| `p_column` | 起始列号，1-based；0 表示未知。 |
| `p_length` | 同一行内的跨度长度；0 表示未知。 |

Returns: 新定位范围。

## GFSpatialHash3D

- Path: `addons/gf/standard/foundation/math/gf_spatial_hash_3d.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSpatialHash3D: 纯逻辑 3D 空间哈希。 适用于大量动态 3D 实体的粗粒度范围查询。它只维护 AABB 索引， 不负责物理碰撞、可见性或玩法规则。

### Properties

#### `cell_size`

- API: `public`

```gdscript
var cell_size: float:
```

单个哈希格子的世界尺寸。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_cell_size: float) -> void:
```

配置格子尺寸并清空索引。

Parameters:

| Name | Description |
|---|---|
| `p_cell_size` | 单格世界尺寸。 |

#### `insert`

- API: `public`

```gdscript
func insert(entity: Variant, bounds: AABB) -> bool:
```

插入实体。

Parameters:

| Name | Description |
|---|---|
| `entity` | 实体标识或 Object。 |
| `bounds` | 实体 AABB。 |

Returns: 成功时返回 true。

Schemas:

- `entity`: Variant entity identity stored by value or weak Object reference.

#### `remove`

- API: `public`

```gdscript
func remove(entity: Variant) -> void:
```

移除实体。

Parameters:

| Name | Description |
|---|---|
| `entity` | 实体标识或 Object。 |

Schemas:

- `entity`: Variant entity identity stored by value or weak Object reference.

#### `update`

- API: `public`

```gdscript
func update(entity: Variant, bounds: AABB) -> bool:
```

更新实体 AABB。

Parameters:

| Name | Description |
|---|---|
| `entity` | 实体标识或 Object。 |
| `bounds` | 新 AABB。 |

Returns: 成功时返回 true。

Schemas:

- `entity`: Variant entity identity stored by value or weak Object reference.

#### `has_entity`

- API: `public`

```gdscript
func has_entity(entity: Variant) -> bool:
```

检查实体是否存在。

Parameters:

| Name | Description |
|---|---|
| `entity` | 实体标识或 Object。 |

Returns: 存在时返回 true。

Schemas:

- `entity`: Variant entity identity stored by value or weak Object reference.

#### `get_entity_count`

- API: `public`

```gdscript
func get_entity_count() -> int:
```

获取实体数量。

Returns: 实体数量。

#### `query_aabb`

- API: `public`

```gdscript
func query_aabb(area: AABB) -> Array[Variant]:
```

查询与 AABB 相交的实体。

Parameters:

| Name | Description |
|---|---|
| `area` | 查询 AABB。 |

Returns: 实体数组。

Schemas:

- `return`: Array entity values restored from spatial hash records.

#### `query_radius`

- API: `public`

```gdscript
func query_radius(center: Vector3, radius: float) -> Array[Variant]:
```

查询与球体相交的实体。

Parameters:

| Name | Description |
|---|---|
| `center` | 球心。 |
| `radius` | 半径。 |

Returns: 实体数组。

Schemas:

- `return`: Array entity values restored from spatial hash records.

#### `prune_invalid_entities`

- API: `public`

```gdscript
func prune_invalid_entities() -> void:
```

清理已释放 Object 实体。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空索引。

## GFState

- Path: `addons/gf/standard/state_machine/pure/gf_state.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFState: 纯代码状态机的状态抽象基类。 继承自 RefCounted，不依赖 Node 树，可在任何逻辑层使用。 通过持有对所属 GFStateMachine 的弱引用，间接访问框架的 Model、System、Utility 层，实现状态与框架的解耦。 子类必须重写 enter()、update()、exit() 以实现具体状态逻辑。

### Methods

#### `enter`

- API: `public`

```gdscript
func enter(_msg: Dictionary = {}) -> void:
```

进入此状态时调用。子类可重写以执行进入逻辑（如初始化动画）。

Parameters:

| Name | Description |
|---|---|
| `_msg` | 从上一个状态或调用方传递过来的可选参数字典。 |

Schemas:

- `_msg`: Dictionary state transition payload.

#### `update`

- API: `public`

```gdscript
func update(_delta: float) -> void:
```

每帧更新时调用，用于处理持续性逻辑（如计时、轮询）。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 上一帧的时间间隔（秒）。 |

#### `exit`

- API: `public`

```gdscript
func exit() -> void:
```

退出此状态时调用。子类可重写以执行清理逻辑（如停止动画）。

#### `get_state_name`

- API: `public`

```gdscript
func get_state_name() -> StringName:
```

获取该状态在状态机中的注册名。

Returns: 注册名；未加入状态机时为空 StringName。

#### `can_enter`

- API: `public`

```gdscript
func can_enter(_previous_state: StringName = &"", _msg: Dictionary = {}) -> bool:
```

判断是否允许进入状态。用于 GFStateMachine 分层切换守卫。

Parameters:

| Name | Description |
|---|---|
| `_previous_state` | 来源叶子状态名。 |
| `_msg` | 状态切换参数。 |

Returns: 允许进入返回 true。

Schemas:

- `_msg`: Dictionary state transition payload.

#### `can_exit`

- API: `public`

```gdscript
func can_exit(_next_state: StringName = &"", _msg: Dictionary = {}) -> bool:
```

判断是否允许离开状态。用于 GFStateMachine 分层切换守卫。

Parameters:

| Name | Description |
|---|---|
| `_next_state` | 目标叶子状态名。 |
| `_msg` | 状态切换参数。 |

Returns: 允许离开返回 true。

Schemas:

- `_msg`: Dictionary state transition payload.

#### `handle_state_event`

- API: `public`

```gdscript
func handle_state_event(_event_id: StringName, _payload: Variant = null) -> bool:
```

处理状态事件。返回 false 时事件会继续向父状态上抛。

Parameters:

| Name | Description |
|---|---|
| `_event_id` | 状态事件标识。 |
| `_payload` | 状态事件载荷。 |

Returns: 已处理返回 true。

Schemas:

- `_payload`: Variant state event payload.

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

获取框架内的 Model 实例（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

获取框架内的 System 实例（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

获取框架内的 Utility 实例（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |

Returns: 工具实例。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

向框架发送命令（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令执行结果；未绑定状态机时返回 null。

Schemas:

- `return`: Variant command result, Signal, or null.

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

向框架发送查询（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `query` | 要发送的查询实例。 |

Returns: 查询结果；未绑定状态机时返回 null。

Schemas:

- `return`: Variant query result or null.

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

发送类型事件（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件（委托给所属状态机）。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload`: Variant event payload.

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册类型事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要监听的脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_event`

- API: `public`

```gdscript
func unregister_event(event_type: Script, callback: Callable) -> void:
```

注销类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_assignable_event`

- API: `public`

```gdscript
func register_assignable_event(base_event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册可赋值类型事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 要监听的基类脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_assignable_event`

- API: `public`

```gdscript
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, callback: Callable) -> void:
```

注册轻量级 StringName 事件监听器，默认以当前状态作为 owner。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 回调函数，签名为 func(payload: Variant)。 |

#### `unregister_simple_event`

- API: `public`

```gdscript
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 要移除的回调函数。 |

#### `unregister_owner_events`

- API: `public`

```gdscript
func unregister_owner_events() -> void:
```

注销当前状态通过事件代理注册过的全部监听器。

#### `change_state`

- API: `public`

```gdscript
func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
```

请求状态机切换到指定状态。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 目标状态的注册名。 |
| `msg` | 传递给目标状态 enter() 的可选参数字典。 |

Schemas:

- `msg`: Dictionary state transition payload.

#### `dispatch_state_event`

- API: `public`

```gdscript
func dispatch_state_event(event_id: StringName, payload: Variant = null) -> bool:
```

从所属状态机派发状态事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |

Returns: 有状态处理该事件时返回 true。

Schemas:

- `payload`: Variant state event payload.

#### `get_parent_state_name`

- API: `public`

```gdscript
func get_parent_state_name() -> StringName:
```

获取当前状态在所属状态机中的父状态名。

Returns: 父状态名；未绑定状态机或没有父级时返回空 StringName。

#### `is_in_state`

- API: `public`

```gdscript
func is_in_state(state_name: StringName) -> bool:
```

判断指定状态是否在所属状态机当前激活路径中。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要查询的状态名。 |

Returns: 处于激活路径中返回 true。

#### `get_blackboard`

- API: `public`

```gdscript
func get_blackboard() -> Dictionary:
```

获取所属状态机共享黑板。

Returns: 黑板字典；未绑定状态机时返回空字典。

Schemas:

- `return`: Dictionary shared blackboard.

## GFStateMachine

- Path: `addons/gf/standard/state_machine/pure/gf_state_machine.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFStateMachine: 纯代码分层有限状态机。 继承自 RefCounted，不依赖 Node 树，可在 GFSystem 或 GFUtility 中直接持有。 支持平铺 FSM，也支持通过 parent_state_name 组成父子状态层级；切换时会 按最近公共祖先执行退出/进入链，并允许事件从当前叶子状态向父状态上抛。 context 通常是拥有它的 GFSystem/GFUtility 实例，仅用于生命周期守卫； 未传入 context 时，状态机仍可通过全局 Gf 访问框架依赖。 使用示例： var _fsm := GFStateMachine.new(self) _fsm.add_state(&"Grounded", GroundedState.new()) _fsm.add_state(&"Idle", IdleState.new(), &"Grounded") _fsm.add_state(&"Run", RunState.new(), &"Grounded") _fsm.start(&"Idle")

### Signals

#### `state_changed`

- API: `public`

```gdscript
signal state_changed(from_state: StringName, to_state: StringName)
```

当状态成功切换后发出。

Parameters:

| Name | Description |
|---|---|
| `from_state` | 离开的叶子状态名，初始切换时为空字符串。 |
| `to_state` | 进入的新叶子状态名。 |

#### `transition_blocked`

- API: `public`

```gdscript
signal transition_blocked(from_state: StringName, to_state: StringName, msg: Dictionary, reason: StringName)
```

当状态守卫阻止切换时发出。

Parameters:

| Name | Description |
|---|---|
| `from_state` | 当前叶子状态名。 |
| `to_state` | 请求进入的目标叶子状态名。 |
| `msg` | 状态切换参数。 |
| `reason` | 阻止原因，常见为 exit_guard 或 enter_guard。 |

Schemas:

- `msg`: Dictionary state transition payload.

#### `state_event_handled`

- API: `public`

```gdscript
signal state_event_handled(event_id: StringName, handler_state: StringName, payload: Variant)
```

当状态事件被某个激活状态处理后发出。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `handler_state` | 处理该事件的状态名。 |
| `payload` | 状态事件载荷。 |

Schemas:

- `payload`: Variant state event payload.

### Properties

#### `current_state_name`

- API: `public`

```gdscript
var current_state_name: StringName = &""
```

当前激活的叶子状态注册名。

#### `blackboard`

- API: `public`

```gdscript
var blackboard: Dictionary = {}
```

状态机共享黑板。框架不解释其中字段。

Schemas:

- `blackboard`: Dictionary shared state machine data.

### Methods

#### `add_state`

- API: `public`

```gdscript
func add_state(state_name: StringName, state: GFState, parent_state_name: StringName = &"") -> void:
```

注册一个状态。注册后，状态机会自动注入自身引用。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 用于标识和切换该状态的唯一名称。 |
| `state` | GFState 实例。 |
| `parent_state_name` | 可选父状态名；为空表示根状态。 |

#### `set_state_parent`

- API: `public`

```gdscript
func set_state_parent(state_name: StringName, parent_state_name: StringName = &"") -> bool:
```

设置已注册状态的父状态。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要调整父级的状态名。 |
| `parent_state_name` | 新父状态名；为空表示根状态。 |

Returns: 设置成功返回 true。

#### `start`

- API: `public`

```gdscript
func start(initial_state_name: StringName, msg: Dictionary = {}, emit_changed: bool = true) -> void:
```

启动状态机并进入初始状态。

Parameters:

| Name | Description |
|---|---|
| `initial_state_name` | 首个要进入的状态名。 |
| `msg` | 传递给初始状态 enter() 的可选参数字典。 |
| `emit_changed` | 是否发出 state_changed 信号；默认为 true，from_state 为空字符串。 |

Schemas:

- `msg`: Dictionary state transition payload.

#### `change_state`

- API: `public`

```gdscript
func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
```

切换到指定状态。分层状态会按最近公共祖先执行退出/进入链。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 目标状态的注册名。 |
| `msg` | 传递给目标状态 enter() 的可选参数字典。 |

Schemas:

- `msg`: Dictionary state transition payload.

#### `update`

- API: `public`

```gdscript
func update(delta: float, include_ancestors: bool = false) -> void:
```

驱动当前状态的 update() 逻辑，应在宿主的 _process() 中调用。

Parameters:

| Name | Description |
|---|---|
| `delta` | 上一帧的时间间隔（秒）。 |
| `include_ancestors` | 为 true 时按 root -> leaf 顺序更新整条激活路径。 |

#### `dispatch_state_event`

- API: `public`

```gdscript
func dispatch_state_event(event_id: StringName, payload: Variant = null) -> bool:
```

从当前叶子状态开始向父状态上抛事件，直到某个状态返回 true。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 状态事件标识。 |
| `payload` | 状态事件载荷。 |

Returns: 有状态处理该事件时返回 true。

Schemas:

- `payload`: Variant state event payload.

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

停止状态机，按 leaf -> root 顺序调用当前激活路径的 exit() 并清空状态。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放状态机持有的所有引用，避免 RefCounted 环状引用。

#### `get_state`

- API: `public`

```gdscript
func get_state(state_name: StringName) -> GFState:
```

获取状态实例。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要查询的状态名。 |

Returns: 已注册状态实例；不存在时返回 null。

#### `get_current_state`

- API: `public`

```gdscript
func get_current_state() -> GFState:
```

获取当前叶子状态实例。

Returns: 当前叶子状态；未启动时返回 null。

#### `has_state`

- API: `public`

```gdscript
func has_state(state_name: StringName) -> bool:
```

判断状态是否已注册。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要查询的状态名。 |

Returns: 已注册返回 true。

#### `get_state_names`

- API: `public`

```gdscript
func get_state_names() -> Array[StringName]:
```

获取已注册状态名列表。

Returns: 状态名列表副本。

#### `get_parent_state_name`

- API: `public`

```gdscript
func get_parent_state_name(state_name: StringName) -> StringName:
```

获取指定状态的父状态名。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要查询的状态名。 |

Returns: 父状态名；没有父级或状态不存在时返回空 StringName。

#### `get_active_state_path`

- API: `public`

```gdscript
func get_active_state_path() -> Array[StringName]:
```

获取当前激活状态路径，按 root -> leaf 排列。

Returns: 激活状态路径副本。

#### `is_in_state`

- API: `public`

```gdscript
func is_in_state(state_name: StringName) -> bool:
```

判断指定状态是否在当前激活路径中。

Parameters:

| Name | Description |
|---|---|
| `state_name` | 要查询的状态名。 |

Returns: 处于当前激活路径中返回 true。

#### `get_blackboard`

- API: `public`

```gdscript
func get_blackboard() -> Dictionary:
```

获取共享黑板。

Returns: 状态机黑板字典。

Schemas:

- `return`: Dictionary shared blackboard.

#### `get_state_snapshot`

- API: `public`

```gdscript
func get_state_snapshot() -> Dictionary:
```

获取状态机调试快照。

Returns: 包含当前状态、激活路径、父子关系和黑板副本的字典。

Schemas:

- `return`: Dictionary with current_state, active_path, states, parents, and blackboard.

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script) -> Object:
```

代理获取框架内的 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |

Returns: 模型实例，若上下文或架构无效则返回 null。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script) -> Object:
```

代理获取框架内的 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |

Returns: 系统实例，若上下文或架构无效则返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script) -> Object:
```

代理获取框架内的 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |

Returns: 工具实例，若上下文或架构无效则返回 null。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

代理向框架发送命令。

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令执行结果；上下文或架构无效时返回 null。

Schemas:

- `return`: Variant command result, Signal, or null.

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

代理向框架发送查询。

Parameters:

| Name | Description |
|---|---|
| `query` | 要发送的查询实例。 |

Returns: 查询结果；上下文或架构无效时返回 null。

Schemas:

- `return`: Variant query result or null.

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

代理发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

代理发送轻量级 StringName 事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload`: Variant event payload.

#### `register_event_owned`

- API: `public`

```gdscript
func register_event_owned(owner: Object, event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册带拥有者的类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_type` | 要监听的脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_event`

- API: `public`

```gdscript
func unregister_event(event_type: Script, callback: Callable) -> void:
```

注销类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_assignable_event_owned`

- API: `public`

```gdscript
func register_assignable_event_owned( owner: Object, base_event_type: Script, callback: Callable, priority: int = 0 ) -> void:
```

注册带拥有者的可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `base_event_type` | 要监听的基类脚本类型。 |
| `callback` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_assignable_event`

- API: `public`

```gdscript
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `callback` | 要移除的回调函数。 |

#### `register_simple_event_owned`

- API: `public`

```gdscript
func register_simple_event_owned(owner: Object, event_id: StringName, callback: Callable) -> void:
```

注册带拥有者的轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_id` | StringName 事件标识符。 |
| `callback` | 回调函数，签名为 func(payload: Variant)。 |

#### `unregister_simple_event`

- API: `public`

```gdscript
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `callback` | 要移除的回调函数。 |

#### `unregister_owner_events`

- API: `public`

```gdscript
func unregister_owner_events(owner: Object) -> void:
```

注销指定拥有者通过状态机事件代理注册过的全部监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 要清理监听器的拥有者。 |

## GFSteeringAcceleration

- Path: `addons/gf/standard/foundation/math/gf_steering_acceleration.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSteeringAcceleration: steering 计算输出的线性与角加速度。 作为纯数据对象在多个 steering 行为之间传递，不绑定节点或物理体。

### Properties

#### `linear`

- API: `public`

```gdscript
var linear: Vector3 = Vector3.ZERO
```

线性加速度。

#### `angular`

- API: `public`

```gdscript
var angular: float = 0.0
```

角加速度。

### Methods

#### `clear`

- API: `public`

```gdscript
func clear() -> GFSteeringAcceleration:
```

清零加速度。

Returns: 当前实例。

#### `set_values`

- API: `public`

```gdscript
func set_values( linear_acceleration: Vector3, angular_acceleration: float = 0.0 ) -> GFSteeringAcceleration:
```

写入加速度值。

Parameters:

| Name | Description |
|---|---|
| `linear_acceleration` | 线性加速度。 |
| `angular_acceleration` | 角加速度。 |

Returns: 当前实例。

#### `add_scaled`

- API: `public`

```gdscript
func add_scaled(other: GFSteeringAcceleration, weight: float = 1.0) -> GFSteeringAcceleration:
```

按权重叠加另一个加速度。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个加速度。 |
| `weight` | 权重。 |

Returns: 当前实例。

#### `clamp_to`

- API: `public`

```gdscript
func clamp_to(max_linear: float = -1.0, max_angular: float = -1.0) -> GFSteeringAcceleration:
```

按上限裁剪加速度。

Parameters:

| Name | Description |
|---|---|
| `max_linear` | 最大线性加速度；小于 0 时不限制。 |
| `max_angular` | 最大角加速度；小于 0 时不限制。 |

Returns: 当前实例。

#### `is_zero`

- API: `public`

```gdscript
func is_zero(threshold: float = 0.001) -> bool:
```

判断加速度是否接近零。

Parameters:

| Name | Description |
|---|---|
| `threshold` | 零阈值。 |

Returns: 接近零返回 true。

#### `duplicate_acceleration`

- API: `public`

```gdscript
func duplicate_acceleration() -> GFSteeringAcceleration:
```

创建深拷贝。

Returns: 新加速度对象。

## GFSteeringAgent

- Path: `addons/gf/standard/foundation/math/gf_steering_agent.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFSteeringAgent: steering 计算使用的通用代理状态。 只描述位置、速度、朝向和运动上限，不持有 Node 或物理体。

### Properties

#### `position`

- API: `public`

```gdscript
var position: Vector3 = Vector3.ZERO
```

当前世界位置。2D 项目可使用 x/y，z 保持 0。

#### `velocity`

- API: `public`

```gdscript
var velocity: Vector3 = Vector3.ZERO
```

当前线性速度。2D 项目可使用 x/y，z 保持 0。

#### `orientation`

- API: `public`

```gdscript
var orientation: float = 0.0
```

当前朝向角，单位为弧度。

#### `angular_velocity`

- API: `public`

```gdscript
var angular_velocity: float = 0.0
```

当前角速度，单位为弧度每秒。

#### `radius`

- API: `public`

```gdscript
var radius: float = 8.0
```

代理半径，用于邻域或避让计算。

#### `linear_speed_max`

- API: `public`

```gdscript
var linear_speed_max: float = 240.0
```

最大线性速度。

#### `linear_acceleration_max`

- API: `public`

```gdscript
var linear_acceleration_max: float = 800.0
```

最大线性加速度。

#### `angular_speed_max`

- API: `public`

```gdscript
var angular_speed_max: float = TAU
```

最大角速度。

#### `angular_acceleration_max`

- API: `public`

```gdscript
var angular_acceleration_max: float = TAU * 4.0
```

最大角加速度。

### Methods

#### `set_from_node_2d`

- API: `public`

```gdscript
func set_from_node_2d(node: Node2D, linear_velocity: Vector2 = Vector2.ZERO) -> void:
```

从 Node2D 同步位置与朝向。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标 Node2D。 |
| `linear_velocity` | 可选线性速度。 |

#### `set_from_node_3d`

- API: `public`

```gdscript
func set_from_node_3d(node: Node3D, linear_velocity: Vector3 = Vector3.ZERO) -> void:
```

从 Node3D 同步位置与朝向。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标 Node3D。 |
| `linear_velocity` | 可选线性速度。 |

#### `duplicate_agent`

- API: `public`

```gdscript
func duplicate_agent() -> GFSteeringAgent:
```

创建深拷贝。

Returns: 新代理状态。

## GFSteeringBehaviorResource

- Path: `addons/gf/standard/foundation/math/gf_steering_behavior_resource.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSteeringBehaviorResource: 可资源化配置的 steering 行为。 包装 GFSteeringMath 的纯算法，允许项目用 Resource 组合 seek、arrive、avoid 等 通用行为。动态目标、邻居和路径通过 context 传入，避免把业务对象写死进资源。

### Enums

#### `BehaviorType`

- API: `public`

```gdscript
enum BehaviorType { ## 朝目标位置加速。 SEEK, ## 远离目标位置。 FLEE, ## 抵达目标位置并减速。 ARRIVE, ## 追逐目标代理。 PURSUE, ## 躲避目标代理。 EVADE, ## 面向目标位置。 FACE, ## 朝当前速度方向转向。 LOOK_WHERE_YOU_GO, ## 对齐指定朝向。 ALIGN, ## 与邻居保持距离。 SEPARATION, ## 朝邻居中心靠拢。 COHESION, ## 基于预测最近距离避让碰撞。 AVOID_COLLISIONS, ## 沿路径计算目标点并 seek。 PATH_FOLLOW_SEEK, }
```

Steering 行为类型。

### Properties

#### `behavior_type`

- API: `public`

```gdscript
var behavior_type: BehaviorType = BehaviorType.SEEK
```

行为类型。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该行为。

#### `weight`

- API: `public`

```gdscript
var weight: float = 1.0
```

组合时使用的权重。

#### `target_position`

- API: `public`

```gdscript
var target_position: Vector3 = Vector3.ZERO
```

静态目标位置；context 中的 `target_position` 会覆盖该值。

#### `target_orientation`

- API: `public`

```gdscript
var target_orientation: float = 0.0
```

静态目标朝向；context 中的 `target_orientation` 会覆盖该值。

#### `arrival_radius`

- API: `public`

```gdscript
var arrival_radius: float = 4.0
```

抵达半径。

#### `slow_radius`

- API: `public`

```gdscript
var slow_radius: float = 64.0
```

减速半径。

#### `time_to_target`

- API: `public`

```gdscript
var time_to_target: float = 0.1
```

逼近期望时间。

#### `align_tolerance`

- API: `public`

```gdscript
var align_tolerance: float = 0.001
```

角度对齐容差。

#### `slow_angle`

- API: `public`

```gdscript
var slow_angle: float = 0.5
```

开始角速度减速的角度。

#### `use_z_axis`

- API: `public`

```gdscript
var use_z_axis: bool = false
```

3D 转向是否使用 x/z 平面。

#### `max_prediction_seconds`

- API: `public`

```gdscript
var max_prediction_seconds: float = 1.0
```

目标预测最大秒数。

#### `decay_coefficient`

- API: `public`

```gdscript
var decay_coefficient: float = 1.0
```

分离行为距离衰减系数。

#### `max_distance`

- API: `public`

```gdscript
var max_distance: float = -1.0
```

最大影响距离；小于 0 时由算法使用代理半径。

#### `collision_radius`

- API: `public`

```gdscript
var collision_radius: float = -1.0
```

避让碰撞半径；小于 0 时由算法使用双方半径。

#### `minimum_separation`

- API: `public`

```gdscript
var minimum_separation: float = -1.0
```

避让最小分离距离；小于 0 时由算法使用碰撞半径。

#### `path_offset`

- API: `public`

```gdscript
var path_offset: float = 0.0
```

路径跟随前进偏移。

### Methods

#### `calculate`

- API: `public`

```gdscript
func calculate(agent: GFSteeringAgent, context: Dictionary = {}) -> GFSteeringAcceleration:
```

计算 steering 加速度。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `context` | 动态上下文，支持 target_position、target_orientation、target_agent、neighbors、targets、path。 |

Returns: steering 加速度。

Schemas:

- `context`: Dictionary steering behavior context with optional target_position, target_orientation, target_agent, neighbors, targets, and path.

#### `duplicate_behavior`

- API: `public`

```gdscript
func duplicate_behavior() -> Resource:
```

创建配置副本。

Returns: 新行为资源。

## GFSteeringBehaviorStack

- Path: `addons/gf/standard/foundation/math/gf_steering_behavior_stack.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFSteeringBehaviorStack: 资源化 steering 行为组合。 以 blend 或 priority 模式组合 GFSteeringBehaviorResource。它只返回加速度结果， 不负责移动节点、应用物理或解释项目 AI 状态。

### Enums

#### `CompositionMode`

- API: `public`

```gdscript
enum CompositionMode { ## 按权重混合所有行为。 BLEND, ## 选择第一个超过阈值的行为。 PRIORITY, }
```

行为组合方式。

### Properties

#### `mode`

- API: `public`

```gdscript
var mode: CompositionMode = CompositionMode.BLEND
```

组合方式。

#### `behaviors`

- API: `public`

```gdscript
var behaviors: Array[GFSteeringBehaviorResource] = []
```

行为列表。

#### `max_linear`

- API: `public`

```gdscript
var max_linear: float = -1.0
```

混合后最大线性加速度；小于 0 时使用 agent 上限。

#### `max_angular`

- API: `public`

```gdscript
var max_angular: float = -1.0
```

混合后最大角加速度；小于 0 时使用 agent 上限。

#### `priority_threshold`

- API: `public`

```gdscript
var priority_threshold: float = 0.001
```

Priority 模式下判断非零的阈值。

### Methods

#### `add_behavior`

- API: `public`

```gdscript
func add_behavior(behavior: GFSteeringBehaviorResource) -> bool:
```

添加行为。

Parameters:

| Name | Description |
|---|---|
| `behavior` | 行为资源。 |

Returns: 添加成功返回 true。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查是否没有有效行为。

Returns: 没有有效行为时返回 true。

#### `calculate`

- API: `public`

```gdscript
func calculate(agent: GFSteeringAgent, context: Dictionary = {}) -> GFSteeringAcceleration:
```

计算组合后的 steering 加速度。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `context` | 传给每个行为的动态上下文。 |

Returns: steering 加速度。

Schemas:

- `context`: Dictionary steering behavior context passed to each behavior.

#### `duplicate_stack`

- API: `public`

```gdscript
func duplicate_stack() -> Resource:
```

创建配置副本。

Returns: 新行为组合。

## GFSteeringMath

- Path: `addons/gf/standard/foundation/math/gf_steering_math.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSteeringMath: 通用 steering 行为的纯算法集合。 提供 seek、flee、arrive、pursue、separation、cohesion、blend、priority 等 可组合计算，不负责把结果应用到具体 Node、物理体或业务状态。

### Methods

#### `acceleration`

- API: `public`

```gdscript
static func acceleration(linear: Vector3 = Vector3.ZERO, angular: float = 0.0) -> GFSteeringAcceleration:
```

创建加速度结果。

Parameters:

| Name | Description |
|---|---|
| `linear` | 线性加速度。 |
| `angular` | 角加速度。 |

Returns: 新加速度结果。

#### `seek`

- API: `public`

```gdscript
static func seek(agent: GFSteeringAgent, target_position: Vector3) -> GFSteeringAcceleration:
```

计算朝目标点加速的 seek 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_position` | 目标位置。 |

Returns: steering 加速度。

#### `flee`

- API: `public`

```gdscript
static func flee(agent: GFSteeringAgent, target_position: Vector3) -> GFSteeringAcceleration:
```

计算远离目标点的 flee 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_position` | 目标位置。 |

Returns: steering 加速度。

#### `arrive`

- API: `public`

```gdscript
static func arrive( agent: GFSteeringAgent, target_position: Vector3, arrival_radius: float = 4.0, slow_radius: float = 64.0, time_to_target: float = 0.1 ) -> GFSteeringAcceleration:
```

计算抵达目标点并在近处减速的 arrive 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_position` | 目标位置。 |
| `arrival_radius` | 视为到达的半径。 |
| `slow_radius` | 开始减速的半径。 |
| `time_to_target` | 期望在多少秒内逼近目标速度。 |

Returns: steering 加速度。

#### `pursue`

- API: `public`

```gdscript
static func pursue( agent: GFSteeringAgent, target_agent: GFSteeringAgent, max_prediction_seconds: float = 1.0 ) -> GFSteeringAcceleration:
```

计算追逐移动目标的 pursue 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_agent` | 目标代理状态。 |
| `max_prediction_seconds` | 最大预测秒数。 |

Returns: steering 加速度。

#### `evade`

- API: `public`

```gdscript
static func evade( agent: GFSteeringAgent, target_agent: GFSteeringAgent, max_prediction_seconds: float = 1.0 ) -> GFSteeringAcceleration:
```

计算逃离移动目标的 evade 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_agent` | 目标代理状态。 |
| `max_prediction_seconds` | 最大预测秒数。 |

Returns: steering 加速度。

#### `face`

- API: `public`

```gdscript
static func face( agent: GFSteeringAgent, target_position: Vector3, use_z_axis: bool = false, align_tolerance: float = 0.001, slow_angle: float = 0.5, time_to_target: float = 0.1 ) -> GFSteeringAcceleration:
```

计算面向目标点的角加速度。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_position` | 目标位置。 |
| `use_z_axis` | 为 true 时使用 x/z 平面，否则使用 x/y 平面。 |
| `align_tolerance` | 视为对齐的角度阈值。 |
| `slow_angle` | 开始减速的角度。 |
| `time_to_target` | 期望在多少秒内逼近目标角速度。 |

Returns: steering 加速度。

#### `look_where_you_go`

- API: `public`

```gdscript
static func look_where_you_go( agent: GFSteeringAgent, use_z_axis: bool = false, align_tolerance: float = 0.001, slow_angle: float = 0.5, time_to_target: float = 0.1 ) -> GFSteeringAcceleration:
```

计算朝当前速度方向转向的角加速度。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `use_z_axis` | 为 true 时使用 x/z 平面，否则使用 x/y 平面。 |
| `align_tolerance` | 视为对齐的角度阈值。 |
| `slow_angle` | 开始减速的角度。 |
| `time_to_target` | 期望在多少秒内逼近目标角速度。 |

Returns: steering 加速度。

#### `align`

- API: `public`

```gdscript
static func align( agent: GFSteeringAgent, target_orientation: float, align_tolerance: float = 0.001, slow_angle: float = 0.5, time_to_target: float = 0.1 ) -> GFSteeringAcceleration:
```

计算对齐指定朝向的角加速度。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `target_orientation` | 目标朝向弧度。 |
| `align_tolerance` | 视为对齐的角度阈值。 |
| `slow_angle` | 开始减速的角度。 |
| `time_to_target` | 期望在多少秒内逼近目标角速度。 |

Returns: steering 加速度。

#### `separation`

- API: `public`

```gdscript
static func separation( agent: GFSteeringAgent, neighbors: Array[GFSteeringAgent], decay_coefficient: float = 1.0, max_distance: float = -1.0 ) -> GFSteeringAcceleration:
```

计算邻居分离行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `neighbors` | 邻居代理列表。 |
| `decay_coefficient` | 距离衰减系数。 |
| `max_distance` | 最大影响距离；小于等于 0 时使用双方半径之和。 |

Returns: steering 加速度。

#### `cohesion`

- API: `public`

```gdscript
static func cohesion(agent: GFSteeringAgent, neighbors: Array[GFSteeringAgent]) -> GFSteeringAcceleration:
```

计算朝邻居中心靠拢的 cohesion 行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `neighbors` | 邻居代理列表。 |

Returns: steering 加速度。

#### `blend`

- API: `public`

```gdscript
static func blend( accelerations: Array[GFSteeringAcceleration], weights: Array[float] = [], max_linear: float = -1.0, max_angular: float = -1.0 ) -> GFSteeringAcceleration:
```

混合多个 steering 加速度。

Parameters:

| Name | Description |
|---|---|
| `accelerations` | 加速度列表。 |
| `weights` | 对应权重；缺失时使用 1。 |
| `max_linear` | 最大线性加速度；小于 0 时不限制。 |
| `max_angular` | 最大角加速度；小于 0 时不限制。 |

Returns: 混合后的加速度。

#### `priority`

- API: `public`

```gdscript
static func priority( accelerations: Array[GFSteeringAcceleration], threshold: float = 0.001 ) -> GFSteeringAcceleration:
```

从多个 steering 加速度中选择第一个超过阈值的结果。

Parameters:

| Name | Description |
|---|---|
| `accelerations` | 加速度列表。 |
| `threshold` | 非零阈值。 |

Returns: 第一个有效加速度；没有时返回零加速度。

#### `radius_neighbors`

- API: `public`

```gdscript
static func radius_neighbors( agent: GFSteeringAgent, candidates: Array[GFSteeringAgent], radius: float = -1.0 ) -> Array[GFSteeringAgent]:
```

获取半径内的邻居代理。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `candidates` | 候选代理列表。 |
| `radius` | 查询半径；小于 0 时使用 agent.radius。 |

Returns: 半径内邻居列表。

#### `avoid_collisions`

- API: `public`

```gdscript
static func avoid_collisions( agent: GFSteeringAgent, targets: Array[GFSteeringAgent], max_prediction_seconds: float = 1.0, collision_radius: float = -1.0, minimum_separation: float = -1.0 ) -> GFSteeringAcceleration:
```

计算基于未来最近距离的动态碰撞避让行为。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `targets` | 需要避让的目标代理列表。 |
| `max_prediction_seconds` | 最大预测秒数；小于等于 0 时只处理当前重叠。 |
| `collision_radius` | 碰撞半径；小于 0 时使用双方半径之和。 |
| `minimum_separation` | 预测最近距离阈值；小于 0 时使用碰撞半径。 |

Returns: steering 加速度。

#### `path_follow_target`

- API: `public`

```gdscript
static func path_follow_target( agent: GFSteeringAgent, path: Array[Vector3], path_offset: float = 0.0 ) -> Vector3:
```

计算路径跟随的下一个目标点。

Parameters:

| Name | Description |
|---|---|
| `agent` | 代理状态。 |
| `path` | 路径点列表。 |
| `path_offset` | 沿路径前进的距离。 |

Returns: 路径上的目标点；路径为空时返回代理当前位置。

## GFStorageBackend

- Path: `addons/gf/standard/utilities/storage/gf_storage_backend.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFStorageBackend: 存储后端扩展接口。 该类只定义通用后端协议，不绑定本地、云、平台 SDK 或同步策略。 默认实现返回不可用结果；项目可继承它并由自定义 Utility 或派生的 GFStorageUtility 组合使用。

### Methods

#### `initialize`

- API: `public`

```gdscript
func initialize(config: Dictionary = {}) -> Error:
```

初始化后端。

Parameters:

| Name | Description |
|---|---|
| `config` | 后端配置字典。 |

Returns: Godot Error 结果码。

Schemas:

- `config`: Dictionary，包含后端特定的初始化选项。

#### `shutdown`

- API: `public`

```gdscript
func shutdown() -> void:
```

关闭后端并释放资源。

#### `save_data`

- API: `public`

```gdscript
func save_data(file_name: String, data: Dictionary, metadata: Dictionary = {}) -> Error:
```

保存纯字典数据。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |
| `data` | 要保存的数据。 |
| `metadata` | 可选元数据。 |

Returns: Godot Error 结果码。

Schemas:

- `data`: Dictionary，存储后端持有的数据载荷。
- `metadata`: Dictionary，包含时间戳或修订号等后端特定元数据。

#### `load_data`

- API: `public`

```gdscript
func load_data(file_name: String) -> Dictionary:
```

读取纯字典数据。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |

Returns: 结果字典，包含 ok、data、metadata、error。

Schemas:

- `return`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary 和 error: String。

#### `delete_data`

- API: `public`

```gdscript
func delete_data(file_name: String) -> Error:
```

删除纯字典数据。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |

Returns: Godot Error 结果码。

#### `has_data`

- API: `public`

```gdscript
func has_data(file_name: String) -> bool:
```

判断逻辑文件是否存在。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |

Returns: 存在时返回 true。

#### `list_data`

- API: `public`

```gdscript
func list_data() -> Array[Dictionary]:
```

枚举后端中的逻辑文件。

Returns: 文件摘要数组。

Schemas:

- `return`: Array，包含 file_name: String 和可选 metadata: Dictionary 的 Dictionary 条目。

#### `get_capabilities`

- API: `public`

```gdscript
func get_capabilities() -> Dictionary:
```

获取后端能力描述。

Returns: 能力字典副本。

Schemas:

- `return`: Dictionary，包含 read、write、delete、list 和 sync 布尔能力标记。

## GFStorageCodec

- Path: `addons/gf/standard/utilities/storage/gf_storage_codec.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFStorageCodec: 通用存档字典编码与解码策略。 负责字典序列化、可选压缩、完整性校验和轻量混淆。 它不负责路径、槽位、事务提交或云同步。

### Enums

#### `Format`

- API: `public`

```gdscript
enum Format { ## 稳定排序后的 JSON 文本。 JSON, ## Godot Variant 二进制格式。 BINARY, }
```

存档载荷序列化格式。

### Constants

#### `META_KEY`

- API: `public`

```gdscript
const META_KEY: String = "_meta"
```

存储元信息字段名。

#### `VERSION_KEY`

- API: `public`

```gdscript
const VERSION_KEY: String = "version"
```

存储版本字段名。

#### `TIMESTAMP_KEY`

- API: `public`

```gdscript
const TIMESTAMP_KEY: String = "timestamp"
```

存储时间戳字段名。

#### `CHECKSUM_KEY`

- API: `public`

```gdscript
const CHECKSUM_KEY: String = "checksum"
```

存储完整性校验字段名。

#### `FORMAT_KEY`

- API: `public`

```gdscript
const FORMAT_KEY: String = "format"
```

存储编码格式字段名。

#### `COMPRESSION_KEY`

- API: `public`

```gdscript
const COMPRESSION_KEY: String = "compression"
```

存储压缩方式字段名。

#### `ENVELOPE_KEY`

- API: `public`

```gdscript
const ENVELOPE_KEY: String = "__gf_storage_envelope"
```

当用户数据自身包含 `_meta` 时，外层包裹使用的标记字段名。

#### `ENVELOPE_DATA_KEY`

- API: `public`

```gdscript
const ENVELOPE_DATA_KEY: String = "data"
```

存储 envelope 内原始用户数据的字段名。

### Properties

#### `format`

- API: `public`

```gdscript
var format: Format = Format.JSON
```

默认序列化格式。

#### `use_compression`

- API: `public`

```gdscript
var use_compression: bool = false
```

是否压缩载荷。

#### `use_integrity_checksum`

- API: `public`

```gdscript
var use_integrity_checksum: bool = false
```

是否在 `_meta.checksum` 中写入 SHA-256 完整性校验。

#### `strict_integrity`

- API: `public`

```gdscript
var strict_integrity: bool = true
```

校验失败时是否拒绝读取。

#### `require_integrity_checksum`

- API: `public`

```gdscript
var require_integrity_checksum: bool = true
```

启用完整性校验时，是否要求载荷必须包含 `_meta.checksum`。

#### `include_metadata`

- API: `public`

```gdscript
var include_metadata: bool = false
```

是否写入 `_meta.version` 和 `_meta.timestamp`。

#### `version`

- API: `public`

```gdscript
var version: int = 1:
```

当前数据版本。

#### `obfuscation_key`

- API: `public`

```gdscript
var obfuscation_key: int = 0
```

轻量 XOR 混淆密钥；为 0 时写入原始 bytes。该字段不提供安全加密能力。

#### `max_decompressed_bytes`

- API: `public`

```gdscript
var max_decompressed_bytes: int = 64 * 1024 * 1024
```

解压时允许的最大输出字节数。

#### `allow_legacy_plain_json_fallback`

- API: `public`

```gdscript
var allow_legacy_plain_json_fallback: bool = false
```

解码失败时是否尝试按旧版未压缩、未混淆 JSON 读取原始 bytes。

#### `normalize_json_numbers`

- API: `public`

```gdscript
var normalize_json_numbers: bool = false
```

JSON 解码时是否把接近整数的 float 归一为 int。Binary 格式不受影响。

### Methods

#### `encode`

- API: `public`

```gdscript
func encode(data: Dictionary, options: Dictionary = {}) -> PackedByteArray:
```

将字典编码为可写入文件的 bytes。

Parameters:

| Name | Description |
|---|---|
| `data` | 要编码的数据。 |
| `options` | 临时覆盖当前 codec 设置的选项字典。 |

Returns: 编码后的 bytes。

Schemas:

- `data`: Dictionary，要序列化的数据载荷；启用存储元数据时，用户 `_meta` 键会通过信封结构保留。
- `options`: Dictionary，可包含 format、use_compression、obfuscation_key、use_integrity_checksum、include_metadata、version 和 max_decompressed_bytes。

#### `decode`

- API: `public`

```gdscript
func decode(bytes: PackedByteArray, options: Dictionary = {}) -> Dictionary:
```

从 bytes 解码字典。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 文件读取到的 bytes。 |
| `options` | 临时覆盖当前 codec 设置的选项字典。 |

Returns: 结果字典，包含 ok、data、metadata、integrity_valid、error。

Schemas:

- `options`: Dictionary，可包含 format、use_compression、obfuscation_key、allow_legacy_plain_json_fallback、use_integrity_checksum、strict_integrity、normalize_json_numbers、require_integrity_checksum 和 max_decompressed_bytes。
- `return`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

#### `serialize_dictionary`

- API: `public`

```gdscript
func serialize_dictionary(data: Dictionary, p_format: Format = Format.JSON) -> PackedByteArray:
```

序列化字典。JSON 格式会递归排序字典键。

Parameters:

| Name | Description |
|---|---|
| `data` | 要序列化的数据。 |
| `p_format` | 目标格式。 |

Returns: 字节数组。

Schemas:

- `data`: Dictionary，要序列化的数据载荷。

#### `deserialize_dictionary`

- API: `public`

```gdscript
func deserialize_dictionary(bytes: PackedByteArray, p_format: Format = Format.JSON) -> Dictionary:
```

反序列化字典。

Parameters:

| Name | Description |
|---|---|
| `bytes` | 源 bytes。 |
| `p_format` | 源格式。 |

Returns: 字典；失败时返回空字典。

Schemas:

- `return`: Dictionary，从字节解析出的数据；解析失败时为空字典。

#### `calculate_checksum`

- API: `public`

```gdscript
func calculate_checksum(data: Dictionary, p_format: Format = Format.JSON) -> String:
```

计算当前数据按指定格式序列化后的 SHA-256。 JSON 格式会在 checksum 输入中规范化整数字面量，避免不同 Godot 版本解析 JSON 数字类型导致误判损坏。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入数据。 |
| `p_format` | 序列化格式。 |

Returns: checksum hex 字符串。

Schemas:

- `data`: Dictionary，用作校验和输入的数据载荷。

#### `verify_integrity`

- API: `public`

```gdscript
func verify_integrity(data: Dictionary, p_format: Format = Format.JSON) -> bool:
```

校验 `_meta.checksum`。

Parameters:

| Name | Description |
|---|---|
| `data` | 包含可选 `_meta.checksum` 的字典。 |
| `p_format` | checksum 计算使用的格式。 |

Returns: 缺少 checksum 或校验通过时返回 true。

Schemas:

- `data`: Dictionary，包含可选 `_meta.checksum` 的数据载荷。

#### `get_metadata`

- API: `public`

```gdscript
func get_metadata(data: Dictionary) -> Dictionary:
```

获取存档元信息副本。

Parameters:

| Name | Description |
|---|---|
| `data` | 存档数据。 |

Returns: `_meta` 字典副本；不存在时为空字典。

Schemas:

- `data`: Dictionary，可能包含 `_meta` 的数据载荷。
- `return`: Dictionary，从 `_meta` 复制出的元数据；不存在元数据时为空字典。

#### `has_integrity_checksum`

- API: `public`

```gdscript
func has_integrity_checksum(data: Dictionary) -> bool:
```

判断字典是否包含完整性 checksum。

Parameters:

| Name | Description |
|---|---|
| `data` | 存档数据。 |

Returns: 包含 `_meta.checksum` 时返回 true。

Schemas:

- `data`: Dictionary，可能包含 `_meta.checksum` 的数据载荷。

## GFStorageConflictReport

- Path: `addons/gf/standard/utilities/storage/gf_storage_conflict_report.gd`
- Extends: `Resource`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFStorageConflictReport: 存储同步冲突的通用报告数据。 该资源只描述冲突，不决定如何解决冲突。项目可以把它用于云同步、 多端合并、调试 UI 或自动化测试。

### Enums

#### `Resolution`

- API: `public`

```gdscript
enum Resolution { ## 尚未决定。 UNRESOLVED, ## 使用本地值。 USE_LOCAL, ## 使用远端值。 USE_REMOTE, ## 使用合并后的值。 MERGED, ## 跳过该冲突。 SKIPPED, }
```

冲突解决策略。

### Properties

#### `file_name`

- API: `public`

```gdscript
var file_name: String = ""
```

冲突所属逻辑文件名。

#### `key`

- API: `public`

```gdscript
var key: String = ""
```

冲突字段或业务 key。

#### `local_value`

- API: `public`

```gdscript
var local_value: Variant = null
```

本地值。

Schemas:

- `local_value`: Variant，从本地记录复制的冲突 key 或载荷值。

#### `remote_value`

- API: `public`

```gdscript
var remote_value: Variant = null
```

远端值。

Schemas:

- `remote_value`: Variant，从远端记录复制的冲突 key 或载荷值。

#### `resolved_value`

- API: `public`

```gdscript
var resolved_value: Variant = null
```

合并后的值。

Schemas:

- `resolved_value`: Variant，由解析器选择或合并出的值。

#### `resolution`

- API: `public`

```gdscript
var resolution: Resolution = Resolution.UNRESOLVED
```

解决策略。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

扩展元数据。

Schemas:

- `metadata`: Dictionary，包含解析器特定诊断信息或后端元数据快照。

### Methods

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

从字典应用字段。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Schemas:

- `data`: Dictionary，包含 file_name、key、local_value、remote_value、resolved_value、resolution 和 metadata。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 字典副本。

Schemas:

- `return`: Dictionary，包含 file_name、key、local_value、remote_value、resolved_value、resolution 和 metadata。

#### `duplicate_report`

- API: `public`

```gdscript
func duplicate_report() -> GFStorageConflictReport:
```

复制冲突报告。

Returns: 新报告实例。

#### `is_resolved`

- API: `public`

```gdscript
func is_resolved() -> bool:
```

是否已经解决。

Returns: resolution 不是 UNRESOLVED 时返回 true。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFStorageConflictReport:
```

从字典创建冲突报告。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新报告实例。

Schemas:

- `data`: Dictionary，包含 file_name、key、local_value、remote_value、resolved_value、resolution 和 metadata。

## GFStorageSyncUtility

- Path: `addons/gf/standard/utilities/storage/gf_storage_sync_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFStorageSyncUtility: 通用存储后端同步协调器。 该工具只协调两个 GFStorageBackend 的字典数据同步、冲突检测和写回策略。 它不绑定本地/云/平台 SDK，也不替项目定义存档业务结构。

### Signals

#### `sync_conflict_detected`

- API: `public`

```gdscript
signal sync_conflict_detected(report: GFStorageConflictReport)
```

检测到存储冲突后发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 冲突报告。 |

#### `sync_conflict_unresolved`

- API: `public`

```gdscript
signal sync_conflict_unresolved(file_name: String, result: Dictionary)
```

单个逻辑文件存在未解决冲突时发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |
| `result` | 同步结果字典。 |

Schemas:

- `result`: Dictionary，由 sync_data() 为未解决冲突返回。

#### `sync_completed`

- API: `public`

```gdscript
signal sync_completed(file_name: String, result: Dictionary)
```

单个逻辑文件同步完成后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |
| `result` | 同步结果字典。 |

Schemas:

- `result`: Dictionary，由 sync_data() 为已完成同步返回。

#### `sync_failed`

- API: `public`

```gdscript
signal sync_failed(file_name: String, result: Dictionary)
```

单个逻辑文件同步失败后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |
| `result` | 同步结果字典。 |

Schemas:

- `result`: Dictionary，由 sync_data() 为失败同步返回。

### Enums

#### `ConflictStrategy`

- API: `public`

```gdscript
enum ConflictStrategy { ## 按后端元数据中的 revision/timestamp 选择更新的一侧；无法判断时保留冲突。 USE_NEWEST, ## 冲突时使用 local_backend 的数据。 USE_LOCAL, ## 冲突时使用 remote_backend 的数据。 USE_REMOTE, ## 只报告冲突，不自动写回。 MANUAL, ## 调用 options.resolver 或 options.resolution_callback 生成结果。 CUSTOM, }
```

冲突解决策略。

#### `SyncStatus`

- API: `public`

```gdscript
enum SyncStatus { ## 两端数据已经一致。 UNCHANGED, ## 已把 local_backend 数据复制到 remote_backend。 COPIED_LOCAL_TO_REMOTE, ## 已把 remote_backend 数据复制到 local_backend。 COPIED_REMOTE_TO_LOCAL, ## 已用自定义合并结果写回两端。 MERGED, ## 存在未解决冲突。 CONFLICT, ## 同步失败。 FAILED, }
```

同步结果状态。

### Properties

#### `default_conflict_strategy`

- API: `public`

```gdscript
var default_conflict_strategy: ConflictStrategy = ConflictStrategy.USE_NEWEST
```

默认冲突策略。

#### `write_resolved_by_default`

- API: `public`

```gdscript
var write_resolved_by_default: bool = true
```

默认是否把解析出的结果写回后端。关闭后可用于 dry-run。

### Methods

#### `sync_data`

- API: `public`

```gdscript
func sync_data( file_name: String, local_backend: GFStorageBackend, remote_backend: GFStorageBackend, options: Dictionary = {} ) -> Dictionary:
```

同步一个逻辑文件。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 逻辑文件名。 |
| `local_backend` | 本地或主后端。 |
| `remote_backend` | 远端或副后端。 |
| `options` | 同步选项，支持 strategy、write_resolved、write_to_local、write_to_remote、resolver、revision_keys、timestamp_keys。 |

Returns: 同步结果字典。

Schemas:

- `options`: Dictionary，包含 strategy: ConflictStrategy、write_resolved: bool、write_to_local: bool、write_to_remote: bool、resolver: Callable、resolution_callback: Callable、revision_keys: Array[String] 和 timestamp_keys: Array[String]。
- `return`: Dictionary，包含 ok、file_name、status、status_name、selected_source、written_backends、conflicts、errors、error、data、metadata、local 和 remote。

#### `sync_many`

- API: `public`

```gdscript
func sync_many( file_names: PackedStringArray, local_backend: GFStorageBackend, remote_backend: GFStorageBackend, options: Dictionary = {} ) -> Dictionary:
```

批量同步多个逻辑文件。

Parameters:

| Name | Description |
|---|---|
| `file_names` | 逻辑文件名列表。 |
| `local_backend` | 本地或主后端。 |
| `remote_backend` | 远端或副后端。 |
| `options` | 传给 sync_data() 的同步选项。 |

Returns: 批量结果字典。

Schemas:

- `options`: Dictionary，支持字段与 sync_data() 相同。
- `return`: Dictionary，包含 ok: bool、count: int、results: Array[Dictionary] 和 status_counts: Dictionary。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取同步工具调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含 sync_count、conflict_count、failed_count、default_conflict_strategy 和 write_resolved_by_default。

## GFStorageUtility

- Path: `addons/gf/standard/utilities/storage/gf_storage_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFStorageUtility: 基于 `user://` 的轻量存档系统。 支持槽位存档、元数据分离读取、`Resource` 存取， 以及可配置 codec、完整性校验、版本迁移和简单混淆，适合通用本地持久化场景。 该混淆不提供安全加密能力，请勿用于保护敏感数据。

### Signals

#### `data_integrity_failed`

- API: `public`

```gdscript
signal data_integrity_failed(file_name: String, error: String)
```

解码数据失败或发现完整性校验失败后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 文件名。 |
| `error` | 错误描述。 |

#### `data_migrated`

- API: `public`

```gdscript
signal data_migrated(file_name: String, from_version: int, to_version: int)
```

数据版本迁移后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 文件名。 |
| `from_version` | 原版本。 |
| `to_version` | 目标版本。 |

#### `save_completed`

- API: `public`

```gdscript
signal save_completed(file_name: String, error: Error)
```

异步保存完成后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 文件名。 |
| `error` | Godot 的 Error 结果码。 |

#### `load_completed`

- API: `public`

```gdscript
signal load_completed(file_name: String, result: Dictionary)
```

异步读取完成后发出。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 文件名。 |
| `result` | 读取结果，包含 ok、data、metadata、integrity_valid、error。 |

Schemas:

- `result`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

### Constants

#### `DEFAULT_MAX_LIST_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_LIST_DEPTH: int = 32
```

递归枚举文件时默认允许进入的最大目录深度。

#### `DEFAULT_MAX_LISTED_FILES`

- API: `public`

```gdscript
const DEFAULT_MAX_LISTED_FILES: int = 10000
```

单次文件枚举默认最多返回的文件数量。

### Properties

#### `encrypt_key`

- API: `public`

```gdscript
var encrypt_key: int = 42
```

用于简单 XOR + Base64 混淆的密钥；为 `0` 时直接保存明文 JSON。该字段不是安全加密密钥。

#### `save_dir_name`

- API: `public`

```gdscript
var save_dir_name: String = "saves"
```

保存子目录名；为空时直接写入 `user://`。

#### `codec`

- API: `public`

```gdscript
var codec: GFStorageCodec = GFStorageCodec.new()
```

存档 codec。为 null 时会自动创建默认 GFStorageCodec。

#### `file_format`

- API: `public`

```gdscript
var file_format: GFStorageCodec.Format = GFStorageCodec.Format.JSON
```

数据序列化格式。

#### `use_compression`

- API: `public`

```gdscript
var use_compression: bool = false
```

是否压缩存档载荷。

#### `allow_legacy_plain_json_fallback`

- API: `public`

```gdscript
var allow_legacy_plain_json_fallback: bool = false
```

解码失败时是否尝试按旧版未压缩、未混淆 JSON 读取原始 bytes。

#### `normalize_json_numbers`

- API: `public`

```gdscript
var normalize_json_numbers: bool = false
```

JSON 读取时是否把接近整数的 float 归一为 int。Binary 格式不受影响。

#### `use_integrity_checksum`

- API: `public`

```gdscript
var use_integrity_checksum: bool = false
```

是否写入并校验 SHA-256 完整性校验。

#### `strict_integrity`

- API: `public`

```gdscript
var strict_integrity: bool = true
```

完整性校验失败时是否拒绝读取。

#### `require_integrity_checksum`

- API: `public`

```gdscript
var require_integrity_checksum: bool = true
```

启用完整性校验时，是否要求载荷必须包含 `_meta.checksum`。

#### `include_storage_metadata`

- API: `public`

```gdscript
var include_storage_metadata: bool = false
```

是否写入 `_meta.version`、`_meta.timestamp` 等通用元信息。

#### `allow_absolute_paths`

- API: `public`

```gdscript
var allow_absolute_paths: bool = false
```

是否允许传入绝对路径。关闭后绝对路径会被收敛到存档目录下的同名文件。

#### `create_directories_for_nested_paths`

- API: `public`

```gdscript
var create_directories_for_nested_paths: bool = true
```

写入嵌套相对路径时是否自动创建目录。

#### `max_async_thread_count`

- API: `public`

```gdscript
var max_async_thread_count: int = 4:
```

同时运行的异步存取线程数量。小于 1 时会被钳制为 1。

#### `save_version`

- API: `public`

```gdscript
var save_version: int = 1:
```

当前存档数据版本。小于 1 会被钳制为 1。

#### `strict_schema_migrations`

- API: `public`

```gdscript
var strict_schema_migrations: bool = false
```

为 true 时，读取旧版本存档必须存在完整迁移链，不能仅更新 `_meta.version`。

#### `default_values_for_new_keys`

- API: `public`

```gdscript
var default_values_for_new_keys: Dictionary = {}
```

读取旧版本数据时需要补齐的新字段默认值。

Schemas:

- `default_values_for_new_keys`: Dictionary，包含迁移旧存档时合并进去的新字段默认值。

#### `last_load_result`

- API: `public`

```gdscript
var last_load_result: Dictionary = {}
```

迁移后的最近一次读取结果，包含 ok、data、metadata、integrity_valid、error。

Schemas:

- `last_load_result`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化存储目录和内部帮助器。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

等待并清理异步存取任务。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float = 0.0) -> void:
```

驱动异步存档任务完成检查。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量（秒），默认实现不直接使用。 |

#### `save_resource`

- API: `public`

```gdscript
func save_resource(file_name: String, resource: Resource) -> Error:
```

保存一个 `Resource` 文件。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `resource` | 要保存的资源实例。 |

Returns: Godot 的 `Error` 结果码。

#### `load_resource`

- API: `public`

```gdscript
func load_resource(file_name: String, type_hint: String = "") -> Resource:
```

读取一个 `Resource` 文件。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `type_hint` | 可选类型提示。 |

Returns: 读取到的资源实例；不存在时返回 `null`。

#### `ensure_directory`

- API: `public`

```gdscript
func ensure_directory(directory_name: String = "") -> Error:
```

确保存储相对目录存在。

Parameters:

| Name | Description |
|---|---|
| `directory_name` | 相对存储目录；为空时只确保根存储目录存在。 |

Returns: Godot 的 `Error` 结果码。

#### `list_files`

- API: `public`

```gdscript
func list_files( directory_name: String = "", extension_filter: String = "", recursive: bool = false, options: Dictionary = {} ) -> PackedStringArray:
```

枚举指定存储目录下的文件。

Parameters:

| Name | Description |
|---|---|
| `directory_name` | 相对存储目录；为空时枚举根存储目录。 |
| `extension_filter` | 可选扩展名过滤，允许传入 `"json"` 或 `".json"`。 |
| `recursive` | 是否递归枚举子目录。 |
| `options` | 可选参数，支持 `max_scan_depth` 与 `max_file_count`。 |

Returns: 存储相对文件路径数组；若传入允许的绝对目录，则返回绝对文件路径。

Schemas:

- `options`: Dictionary，包含 max_scan_depth: int 和 max_file_count: int。

#### `delete_file`

- API: `public`

```gdscript
func delete_file(file_name: String) -> Error:
```

删除一个存储文件。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 存储相对文件路径。 |

Returns: Godot 的 `Error` 结果码；文件不存在时返回 `ERR_FILE_NOT_FOUND`。

#### `save_slot`

- API: `public`

```gdscript
func save_slot(slot_id: int, data: Dictionary, metadata: Dictionary = {}) -> Error:
```

保存一个槽位存档。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |
| `data` | 核心存档数据。 |
| `metadata` | 展示用元数据。 |

Returns: Godot 的 `Error` 结果码。

Schemas:

- `data`: Dictionary，作为存档槽主要数据保存的载荷。
- `metadata`: Dictionary，作为存档槽展示元数据保存。

#### `load_slot`

- API: `public`

```gdscript
func load_slot(slot_id: int) -> Dictionary:
```

读取槽位核心数据。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 反序列化后的核心数据字典。

Schemas:

- `return`: Dictionary，作为存档槽主要数据保存的载荷。

#### `load_slot_result`

- API: `public`

```gdscript
func load_slot_result(slot_id: int) -> Dictionary:
```

读取槽位核心数据并返回 codec 结果。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 结果字典，包含 ok、data、metadata、integrity_valid、error。

Schemas:

- `return`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

#### `load_slot_meta`

- API: `public`

```gdscript
func load_slot_meta(slot_id: int) -> Dictionary:
```

读取槽位元数据。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 反序列化后的元数据字典。

Schemas:

- `return`: Dictionary，作为存档槽展示元数据保存。

#### `load_slot_meta_result`

- API: `public`

```gdscript
func load_slot_meta_result(slot_id: int) -> Dictionary:
```

读取槽位元数据并返回 codec 结果。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 结果字典，包含 ok、data、metadata、integrity_valid、error。

Schemas:

- `return`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

#### `has_slot`

- API: `public`

```gdscript
func has_slot(slot_id: int) -> bool:
```

检查槽位是否存在有效存档。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 核心数据与元数据文件都存在时返回 `true`。

#### `list_slots`

- API: `public`

```gdscript
func list_slots() -> Array[Dictionary]:
```

枚举所有有效槽位。

Returns: 槽位信息数组，元素包含 `slot_id`、`metadata` 与 `modified_time`。

Schemas:

- `return`: Array，包含 slot_id: int、metadata: Dictionary 和 modified_time: int 的 Dictionary 条目。

#### `delete_slot`

- API: `public`

```gdscript
func delete_slot(slot_id: int) -> void:
```

删除指定槽位的数据与元数据。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

#### `save_data`

- API: `public`

```gdscript
func save_data(file_name: String, data: Dictionary) -> Error:
```

保存纯字典数据。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `data` | 要保存的字典。 |

Returns: Godot 的 `Error` 结果码。

Schemas:

- `data`: Dictionary，要序列化并保存的数据载荷。

#### `load_data`

- API: `public`

```gdscript
func load_data(file_name: String) -> Dictionary:
```

读取纯字典数据。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |

Returns: 反序列化后的字典数据。

Schemas:

- `return`: Dictionary，从存储读取的数据载荷；读取失败时为空字典。

#### `load_data_result`

- API: `public`

```gdscript
func load_data_result(file_name: String) -> Dictionary:
```

读取纯字典数据并返回 codec 结果。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |

Returns: 结果字典，包含 ok、data、metadata、integrity_valid、error。

Schemas:

- `return`: Dictionary，包含 ok: bool、data: Dictionary、metadata: Dictionary、integrity_valid: bool 和 error: String。

#### `save_data_async`

- API: `public`

```gdscript
func save_data_async(file_name: String, data: Dictionary) -> Error:
```

在线程中异步保存纯字典数据。完成后从主线程发出 save_completed。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |
| `data` | 要保存的字典。 |

Returns: 启动线程的 Error 结果码。

Schemas:

- `data`: Dictionary，要序列化并保存的数据载荷。

#### `load_data_async`

- API: `public`

```gdscript
func load_data_async(file_name: String) -> Error:
```

在线程中异步读取纯字典数据。完成后从主线程发出 load_completed。

Parameters:

| Name | Description |
|---|---|
| `file_name` | 目标文件名。 |

Returns: 启动线程的 Error 结果码。

#### `wait_for_async_tasks`

- API: `public`

```gdscript
func wait_for_async_tasks() -> void:
```

等待已经入队和正在执行的异步纯数据任务全部完成。 需要在同一路径上混合同步与异步读写时，可先调用该方法收敛顺序。

#### `migrate_data`

- API: `public`

```gdscript
func migrate_data(data: Dictionary, _from_version: int, _to_version: int) -> Dictionary:
```

迁移存档数据。项目可继承 GFStorageUtility 并重写该方法。

Parameters:

| Name | Description |
|---|---|
| `data` | 已读取的数据副本。 |
| `_from_version` | 原版本。 |
| `_to_version` | 目标版本。 |

Returns: 迁移后的数据。

Schemas:

- `data`: Dictionary，在存档 schema 版本之间迁移的数据载荷。
- `return`: Dictionary，应用已注册迁移和默认值后的数据载荷。

#### `register_migration`

- API: `public`

```gdscript
func register_migration(from_version: int, to_version: int, callback: Callable) -> bool:
```

注册一个版本迁移步骤。

Parameters:

| Name | Description |
|---|---|
| `from_version` | 来源版本。 |
| `to_version` | 目标版本，必须大于来源版本。 |
| `callback` | 迁移回调，签名为 `func(data: Dictionary, from_version: int, to_version: int) -> Dictionary`。 |

Returns: 注册成功时返回 true。

#### `unregister_migration`

- API: `public`

```gdscript
func unregister_migration(from_version: int, to_version: int) -> void:
```

注销一个版本迁移步骤。

Parameters:

| Name | Description |
|---|---|
| `from_version` | 来源版本。 |
| `to_version` | 目标版本。 |

#### `clear_migrations`

- API: `public`

```gdscript
func clear_migrations() -> void:
```

清空所有注册的版本迁移步骤。

#### `get_registered_migrations`

- API: `public`

```gdscript
func get_registered_migrations() -> Array[Dictionary]:
```

获取已注册迁移步骤。

Returns: 迁移步骤摘要数组。

Schemas:

- `return`: Array，包含 from_version: int 和 to_version: int 的 Dictionary 条目。

## GFStorageViewerDock

- Path: `addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd`
- Extends: `VBoxContainer`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFStorageViewerDock: 开发期本地存档查看面板。 用 GFStorageCodec 解码本地存档字节，便于编辑器内排查存档内容与完整性状态。

## GFSupportReportUtility

- Path: `addons/gf/standard/utilities/debug/gf_support_report_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSupportReportUtility: 通用支持报告构建工具。 聚合用户描述、项目元数据、诊断快照、日志和可扩展分区，并提供 JSON / Markdown 导出与回调提交入口。 它不绑定任何工单系统、上传服务或反馈 UI。

### Signals

#### `report_built`

- API: `public`

```gdscript
signal report_built(report: Dictionary)
```

报告构建完成后发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 已构建的支持报告。 |

Schemas:

- `report`: Dictionary，build_report() 返回结构。

#### `report_saved`

- API: `public`

```gdscript
signal report_saved(path: String, error: Error)
```

报告写入文件后发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标路径。 |
| `error` | 写入结果错误码。 |

#### `report_submitted`

- API: `public`

```gdscript
signal report_submitted(result: Dictionary)
```

报告通过外部回调提交后发出。

Parameters:

| Name | Description |
|---|---|
| `result` | 提交结果。 |

Schemas:

- `result`: Dictionary，包含 ok、value、error、metadata，可选 submitted_at_unix。

### Constants

#### `DEFAULT_SCENE_COUNT_MAX_DEPTH`

- API: `public`

```gdscript
const DEFAULT_SCENE_COUNT_MAX_DEPTH: int = 64
```

场景节点统计默认最大深度。

#### `DEFAULT_SCENE_COUNT_MAX_NODES`

- API: `public`

```gdscript
const DEFAULT_SCENE_COUNT_MAX_NODES: int = 10000
```

场景节点统计默认最大节点数。

### Properties

#### `include_diagnostics_by_default`

- API: `public`

```gdscript
var include_diagnostics_by_default: bool = true
```

默认是否包含 GFDiagnosticsUtility 快照。

#### `include_scene_by_default`

- API: `public`

```gdscript
var include_scene_by_default: bool = true
```

默认是否包含场景快照。

#### `default_scene_count_max_depth`

- API: `public`

```gdscript
var default_scene_count_max_depth: int = DEFAULT_SCENE_COUNT_MAX_DEPTH
```

场景节点数量统计默认最大深度。0 表示不限制。

#### `default_scene_count_max_nodes`

- API: `public`

```gdscript
var default_scene_count_max_nodes: int = DEFAULT_SCENE_COUNT_MAX_NODES
```

场景节点数量统计默认最大节点数。0 表示不限制。

#### `default_recent_log_count`

- API: `public`

```gdscript
var default_recent_log_count: int = 50
```

默认最近日志数量。

#### `default_max_attachment_bytes`

- API: `public`

```gdscript
var default_max_attachment_bytes: int = 2 * 1024 * 1024
```

默认单个附件最大字节数。小于等于 0 表示不限制。

#### `include_screenshot_by_default`

- API: `public`

```gdscript
var include_screenshot_by_default: bool = false
```

默认是否包含当前 Viewport 截图。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放支持报告工具的运行时状态。

#### `register_section`

- API: `public`

```gdscript
func register_section(section_id: StringName, provider: Callable, options: Dictionary = {}) -> bool:
```

注册自定义报告分区。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 分区标识。 |
| `provider` | 分区回调，建议签名为 func(options: Dictionary) -> Variant。 |
| `options` | 分区元数据，支持 label、metadata。 |

Returns: 注册成功返回 true。

Schemas:

- `options`: Dictionary，支持 label、metadata。

#### `unregister_section`

- API: `public`

```gdscript
func unregister_section(section_id: StringName) -> void:
```

注销自定义报告分区。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 分区标识。 |

#### `has_section`

- API: `public`

```gdscript
func has_section(section_id: StringName) -> bool:
```

检查自定义分区是否存在。

Parameters:

| Name | Description |
|---|---|
| `section_id` | 分区标识。 |

Returns: 存在返回 true。

#### `get_section_catalog`

- API: `public`

```gdscript
func get_section_catalog() -> Dictionary:
```

获取自定义分区目录。

Returns: 分区元数据字典。

Schemas:

- `return`: Dictionary[StringName, Dictionary]，每个值包含 label 和 metadata。

#### `build_report`

- API: `public`

```gdscript
func build_report(description: String = "", options: Dictionary = {}) -> Dictionary:
```

构建支持报告。

Parameters:

| Name | Description |
|---|---|
| `description` | 用户描述或问题摘要。 |
| `options` | 可选参数，支持 metadata、tags、include_diagnostics、diagnostics_options、include_scene、scene_options、include_sections、section_options、attachments、max_attachment_bytes、include_screenshot、viewport、screenshot_path。 |

Returns: 报告字典。

Schemas:

- `options`: Dictionary，支持 report_id、metadata、tags、include_diagnostics、diagnostics_options、include_scene、scene_options、include_sections、section_options、attachments、max_attachment_bytes、include_screenshot、viewport、screenshot_path。
- `return`: Dictionary，包含 report_id、timestamp_unix、description、metadata、tags、build、runtime、scene、diagnostics、sections、attachments。

#### `collect_sections`

- API: `public`

```gdscript
func collect_sections(options: Dictionary = {}) -> Dictionary:
```

采集所有自定义分区。

Parameters:

| Name | Description |
|---|---|
| `options` | 传给每个 provider 的选项。 |

Returns: 分区结果字典。

Schemas:

- `options`: Dictionary，原样传给各分区 provider。
- `return`: Dictionary[StringName, Dictionary]，每个值包含 label、metadata、value、ok、error。

#### `collect_attachments`

- API: `public`

```gdscript
func collect_attachments(attachments: Variant, options: Dictionary = {}) -> Dictionary:
```

采集并规范化报告附件。

Parameters:

| Name | Description |
|---|---|
| `attachments` | 附件集合。Dictionary 使用键作为附件标识；Array 中的 Dictionary 可提供 id 或 attachment_id。 |
| `options` | 可选参数，支持 max_attachment_bytes。 |

Returns: 附件字典。

Schemas:

- `attachments`: Variant，支持 Dictionary[StringName, Variant] 或 Array[Dictionary]。
- `options`: Dictionary，支持 filename、mime_type、metadata、max_attachment_bytes、save_path。
- `return`: Dictionary[StringName, Dictionary]，每个值为规范化附件条目。

#### `add_attachment_to_report`

- API: `public`

```gdscript
func add_attachment_to_report( report: Dictionary, attachment_id: StringName, content: Variant, options: Dictionary = {} ) -> Dictionary:
```

向已有报告追加附件。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `attachment_id` | 附件标识。 |
| `content` | 附件内容，可为 PackedByteArray、String 或带 bytes/text/path 字段的 Dictionary。 |
| `options` | 可选参数，支持 filename、mime_type、metadata、max_attachment_bytes、save_path。 |

Returns: 规范化附件结果。

Schemas:

- `report`: Dictionary，build_report() 返回结构或带 attachments 字段的兼容结构。
- `content`: Variant，支持 PackedByteArray、String 或包含 bytes、text、path 字段的 Dictionary。
- `options`: Dictionary，支持 filename、mime_type、metadata、max_attachment_bytes、save_path。
- `return`: Dictionary，包含 ok、filename、mime_type、size_bytes、encoding、data、metadata，失败时包含 reason。

#### `export_report_json`

- API: `public`

```gdscript
func export_report_json(report: Dictionary, indent: String = "\t") -> String:
```

将报告导出为 JSON 文本。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `indent` | JSON 缩进字符串。 |

Returns: JSON 文本。

Schemas:

- `report`: Dictionary，build_report() 返回结构。

#### `export_report_markdown`

- API: `public`

```gdscript
func export_report_markdown(report: Dictionary, options: Dictionary = {}) -> String:
```

将报告导出为 Markdown 文本。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `options` | 可选参数，支持 title、include_metadata、include_diagnostics_summary、include_sections、include_attachments。 |

Returns: Markdown 文本。

Schemas:

- `report`: Dictionary，build_report() 返回结构。
- `options`: Dictionary，支持 title、include_metadata、include_diagnostics_summary、include_sections、include_attachments。

#### `save_report`

- API: `public`

```gdscript
func save_report(report: Dictionary, path: String) -> Error:
```

保存报告到文件。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `path` | 目标路径。 |

Returns: Godot 错误码。

Schemas:

- `report`: Dictionary，build_report() 返回结构。

#### `build_and_save_report`

- API: `public`

```gdscript
func build_and_save_report(path: String, description: String = "", options: Dictionary = {}) -> Error:
```

构建并保存支持报告。

Parameters:

| Name | Description |
|---|---|
| `path` | 目标路径。 |
| `description` | 用户描述或问题摘要。 |
| `options` | 构建选项。 |

Returns: Godot 错误码。

Schemas:

- `options`: Dictionary，build_report() 支持的构建选项。

#### `submit_report`

- API: `public`

```gdscript
func submit_report(report: Dictionary, transport: Callable, options: Dictionary = {}) -> Dictionary:
```

通过外部回调提交报告。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `transport` | 提交回调，签名为 func(report: Dictionary, options: Dictionary) -> Variant。 |
| `options` | 提交选项。 |

Returns: 提交结果字典。

Schemas:

- `report`: Dictionary，build_report() 返回结构。
- `options`: Dictionary，提交回调使用的选项。
- `return`: Dictionary，包含 ok、value、error、metadata，可选 submitted_at_unix。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 section_count、reports_built_count、reports_saved_count、reports_submitted_count 和默认配置字段。

## GFSurfaceUtility

- Path: `addons/gf/standard/utilities/display/gf_surface_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFSurfaceUtility: 3D 表面材质查询工具。 根据碰撞命中的 face index 推导 MeshInstance3D surface，并返回基础材质、 覆盖材质或最终 active material。框架只负责几何到材质的映射，不解释材质语义。

### Enums

#### `CacheMode`

- API: `public`

```gdscript
enum CacheMode { ## 不读写缓存，每次查询都重新计算。 DISABLED, ## 只使用显式预热写入的缓存。 MANUAL, ## 查询时自动缓存，并按 auto_cache_size 控制容量。 AUTOMATIC, }
```

Mesh surface face count 缓存策略。

### Constants

#### `DEFAULT_AUTO_CACHE_SIZE`

- API: `public`

```gdscript
const DEFAULT_AUTO_CACHE_SIZE: int = 8
```

自动缓存默认容量。

### Properties

#### `cache_mode`

- API: `public`

```gdscript
var cache_mode: CacheMode = CacheMode.AUTOMATIC
```

当前缓存策略。

#### `auto_cache_size`

- API: `public`

```gdscript
var auto_cache_size: int = DEFAULT_AUTO_CACHE_SIZE
```

自动缓存容量。小于 1 时会被归一化为 1。

### Methods

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放工具时清空 Mesh surface face count 缓存。

#### `get_active_material`

- API: `public`

```gdscript
func get_active_material(source: Object, face_index: int) -> Material:
```

获取命中表面最终渲染使用的材质。

Parameters:

| Name | Description |
|---|---|
| `source` | MeshInstance3D、CollisionObject3D 或其相邻节点。 |
| `face_index` | RayCast3D.get_collision_face_index() 返回的面索引。 |

Returns: 命中材质；无法解析时返回 null。

#### `get_surface_override_material`

- API: `public`

```gdscript
func get_surface_override_material(source: Object, face_index: int) -> Material:
```

获取 MeshInstance3D surface override 材质。

Parameters:

| Name | Description |
|---|---|
| `source` | MeshInstance3D、CollisionObject3D 或其相邻节点。 |
| `face_index` | RayCast3D.get_collision_face_index() 返回的面索引。 |

Returns: 覆盖材质；未设置或无法解析时返回 null。

#### `get_base_material`

- API: `public`

```gdscript
func get_base_material(source: Object, face_index: int) -> Material:
```

获取 Mesh 资源自身的 surface 材质。

Parameters:

| Name | Description |
|---|---|
| `source` | MeshInstance3D、CollisionObject3D 或其相邻节点。 |
| `face_index` | RayCast3D.get_collision_face_index() 返回的面索引。 |

Returns: 基础材质；无法解析时返回 null。

#### `get_surface_index`

- API: `public`

```gdscript
func get_surface_index(source: Object, face_index: int) -> int:
```

获取 face index 所属的 Mesh surface 索引。

Parameters:

| Name | Description |
|---|---|
| `source` | MeshInstance3D、CollisionObject3D 或其相邻节点。 |
| `face_index` | RayCast3D.get_collision_face_index() 返回的面索引。 |

Returns: surface 索引；无法解析时返回 -1。

#### `clear_cache`

- API: `public`

```gdscript
func clear_cache() -> void:
```

清空 Mesh surface face count 缓存。

#### `cache_mesh_surface`

- API: `public`

```gdscript
func cache_mesh_surface(source: Object) -> bool:
```

预热指定 Mesh 或 MeshInstance3D 的 surface face count 缓存。

Parameters:

| Name | Description |
|---|---|
| `source` | Mesh、MeshInstance3D、CollisionObject3D 或其相邻节点。 |

Returns: 缓存成功返回 true。

#### `erase_cached_mesh`

- API: `public`

```gdscript
func erase_cached_mesh(source: Object) -> bool:
```

移除指定 Mesh 或 MeshInstance3D 的 surface face count 缓存。

Parameters:

| Name | Description |
|---|---|
| `source` | Mesh、MeshInstance3D、CollisionObject3D 或其相邻节点。 |

Returns: 移除成功返回 true。

#### `set_auto_cache_size`

- API: `public`

```gdscript
func set_auto_cache_size(size: int) -> void:
```

设置自动缓存容量。

Parameters:

| Name | Description |
|---|---|
| `size` | 自动缓存容量；小于 1 时按 1 处理。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 缓存状态。

Schemas:

- `return`: Dictionary，包含 cached_meshes、cache_mode 和 auto_cache_size。

## GFTagExpression

- Path: `addons/gf/standard/foundation/tags/gf_tag_expression.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.18.0`

GFTagExpression: 可嵌套标签查询表达式资源。 在 GFTagQuery 的 all/any/none 单层查询之上提供组合表达式，适合描述 “任意一组条件成立”“全部子条件成立”或“没有子条件成立”等通用标签规则。 它只组合查询结果，不维护全局标签表，也不规定标签业务语义。

### Enums

#### `Operator`

- API: `public`

```gdscript
enum Operator { ## 使用 query 作为叶子查询。 QUERY, ## 全部子表达式都满足。 ALL, ## 任意子表达式满足。 ANY, ## 没有子表达式满足。 NONE, }
```

表达式运算类型。

### Properties

#### `operator`

- API: `public`

```gdscript
var operator: Operator = Operator.QUERY
```

当前表达式运算类型。

#### `query`

- API: `public`

```gdscript
var query: GFTagQuery = null
```

叶子标签查询。operator 为 QUERY 时使用；为空时视为无条件通过。

#### `expressions`

- API: `public`

```gdscript
var expressions: Array[GFTagExpression] = []
```

子表达式列表。operator 为 ALL、ANY 或 NONE 时使用。

Schemas:

- `expressions`: Array[GFTagExpression]，按数组顺序参与组合判断。

### Methods

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查表达式是否为空。

Returns: 无叶子查询且无子表达式时返回 true。

#### `matches`

- API: `public`

```gdscript
func matches(source: Variant) -> bool:
```

匹配标签源。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 表达式满足时返回 true。

Schemas:

- `source`: Variant accepted by GFTagSourceAdapter through GFTagQuery.

#### `get_match_report`

- API: `public`

```gdscript
func get_match_report(source: Variant) -> Dictionary:
```

获取匹配报告。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 匹配报告。

Schemas:

- `source`: Variant accepted by GFTagSourceAdapter through GFTagQuery.
- `return`: Dictionary，包含 ok、operator、query_report、child_reports、matched_indices、failed_indices、reason 等字段。

#### `configure_query`

- API: `public`

```gdscript
func configure_query(tag_query: GFTagQuery) -> GFTagExpression:
```

配置为叶子查询表达式。

Parameters:

| Name | Description |
|---|---|
| `tag_query` | 标签查询资源。 |

Returns: 当前表达式。

#### `configure_all`

- API: `public`

```gdscript
func configure_all(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
```

配置为全部子表达式都满足。

Parameters:

| Name | Description |
|---|---|
| `child_expressions` | 子表达式列表。 |

Returns: 当前表达式。

Schemas:

- `child_expressions`: Array[GFTagExpression]，null 项会在匹配时按失败处理。

#### `configure_any`

- API: `public`

```gdscript
func configure_any(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
```

配置为任意子表达式满足。

Parameters:

| Name | Description |
|---|---|
| `child_expressions` | 子表达式列表。 |

Returns: 当前表达式。

Schemas:

- `child_expressions`: Array[GFTagExpression]，null 项会在匹配时按失败处理。

#### `configure_none`

- API: `public`

```gdscript
func configure_none(child_expressions: Array[GFTagExpression]) -> GFTagExpression:
```

配置为没有子表达式满足。

Parameters:

| Name | Description |
|---|---|
| `child_expressions` | 子表达式列表。 |

Returns: 当前表达式。

Schemas:

- `child_expressions`: Array[GFTagExpression]，null 项会在匹配时按失败处理。

#### `duplicate_expression`

- API: `public`

```gdscript
func duplicate_expression() -> GFTagExpression:
```

创建同内容拷贝。

Returns: 新表达式。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

导出为字典。

Returns: 表达式字典。

Schemas:

- `return`: Dictionary serialized tag expression.

#### `from_dictionary`

- API: `public`

```gdscript
static func from_dictionary(data: Dictionary) -> GFTagExpression:
```

从字典创建表达式。

Parameters:

| Name | Description |
|---|---|
| `data` | 表达式字典。 |

Returns: 新表达式。

Schemas:

- `data`: Dictionary serialized tag expression.

#### `from_query`

- API: `public`

```gdscript
static func from_query(tag_query: GFTagQuery) -> GFTagExpression:
```

以查询资源创建叶子表达式。

Parameters:

| Name | Description |
|---|---|
| `tag_query` | 标签查询资源。 |

Returns: 新表达式。

## GFTagQuery

- Path: `addons/gf/standard/foundation/tags/gf_tag_query.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTagQuery: 通用标签查询资源。 使用 all/any/none 三组标签描述条件，可直接匹配标签集合、标签组件或普通数据。

### Properties

#### `all_tags`

- API: `public`

```gdscript
var all_tags: Array[StringName] = []
```

必须全部存在的标签。

#### `any_tags`

- API: `public`

```gdscript
var any_tags: Array[StringName] = []
```

至少存在一个的标签；为空时跳过该条件。

#### `none_tags`

- API: `public`

```gdscript
var none_tags: Array[StringName] = []
```

不允许存在的标签。

#### `include_child_tags`

- API: `public`

```gdscript
var include_child_tags: bool = false
```

是否启用层级匹配。例如查询 `state` 时可匹配 `state.burning`。

### Methods

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查查询是否为空。

Returns: 无任何条件时返回 true。

#### `matches`

- API: `public`

```gdscript
func matches(source: Variant) -> bool:
```

匹配标签源。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 满足查询返回 true。

Schemas:

- `source`: Variant accepted by GFTagSourceAdapter.

#### `get_match_report`

- API: `public`

```gdscript
func get_match_report(source: Variant) -> Dictionary:
```

获取匹配报告。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 包含 ok、missing_all、missing_any、blocked_tags 的报告。

Schemas:

- `source`: Variant accepted by GFTagSourceAdapter.
- `return`: Dictionary with ok, missing_all, missing_any, blocked_tags, include_child_tags.

#### `configure`

- API: `public`

```gdscript
func configure( required_all: Array[StringName] = [], required_any: Array[StringName] = [], rejected_none: Array[StringName] = [], hierarchical: bool = false ) -> GFTagQuery:
```

配置查询条件。

Parameters:

| Name | Description |
|---|---|
| `required_all` | 必须全部存在的标签。 |
| `required_any` | 至少存在一个的标签。 |
| `rejected_none` | 不允许存在的标签。 |
| `hierarchical` | 是否启用层级匹配。 |

Returns: 当前查询。

#### `duplicate_query`

- API: `public`

```gdscript
func duplicate_query() -> GFTagQuery:
```

创建同内容拷贝。

Returns: 新查询。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

导出为字典。

Returns: 查询字典。

Schemas:

- `return`: Dictionary serialized tag query.

#### `from_dictionary`

- API: `public`

```gdscript
static func from_dictionary(data: Dictionary) -> GFTagQuery:
```

从字典创建查询。

Parameters:

| Name | Description |
|---|---|
| `data` | 查询字典。 |

Returns: 新查询。

Schemas:

- `data`: Dictionary serialized tag query.

## GFTagSet

- Path: `addons/gf/standard/foundation/tags/gf_tag_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTagSet: 通用标签集合资源。 只维护标签到层数的映射，不规定标签命名、业务含义或全局注册表。

### Properties

#### `tag_counts`

- API: `public`

```gdscript
var tag_counts: Dictionary = {}
```

标签层数字典。键建议使用 StringName，值为正整数层数。

Schemas:

- `tag_counts`: Dictionary mapping tag names to positive integer counts.

### Methods

#### `set_tags`

- API: `public`

```gdscript
func set_tags(source_tags: Variant) -> GFTagSet:
```

清空并设置标签集合。

Parameters:

| Name | Description |
|---|---|
| `source_tags` | Array、PackedStringArray 或 Dictionary 标签数据。 |

Returns: 当前标签集合。

Schemas:

- `source_tags`: Variant tag source accepted as Array, PackedStringArray, or Dictionary.

#### `add_tag`

- API: `public`

```gdscript
func add_tag(tag: StringName, count: int = 1) -> GFTagSet:
```

添加标签层数。

Parameters:

| Name | Description |
|---|---|
| `tag` | 标签名。 |
| `count` | 增加层数。 |

Returns: 当前标签集合。

#### `remove_tag`

- API: `public`

```gdscript
func remove_tag(tag: StringName, count: int = 1) -> GFTagSet:
```

移除标签层数。

Parameters:

| Name | Description |
|---|---|
| `tag` | 标签名。 |
| `count` | 移除层数；-1 表示完全移除。 |

Returns: 当前标签集合。

#### `has_tag`

- API: `public`

```gdscript
func has_tag(tag: StringName, minimum_count: int = 1, include_child_tags: bool = false) -> bool:
```

检查是否拥有指定标签且层数达到要求。

Parameters:

| Name | Description |
|---|---|
| `tag` | 标签名。 |
| `minimum_count` | 要求的最小层数。 |
| `include_child_tags` | 为 true 时，`state` 可匹配 `state.burning`。 |

Returns: 满足要求返回 true。

#### `get_tag_count`

- API: `public`

```gdscript
func get_tag_count(tag: StringName, include_child_tags: bool = false) -> int:
```

获取标签层数。

Parameters:

| Name | Description |
|---|---|
| `tag` | 标签名。 |
| `include_child_tags` | 为 true 时合并子标签层数。 |

Returns: 标签层数。

#### `get_tags`

- API: `public`

```gdscript
func get_tags() -> PackedStringArray:
```

获取所有标签名。

Returns: 排序后的标签名。

#### `get_tag_counts`

- API: `public`

```gdscript
func get_tag_counts() -> Dictionary:
```

获取标签层数字典副本。

Returns: 标签层数字典。

Schemas:

- `return`: Dictionary mapping tag names to positive integer counts.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空标签集合。

#### `duplicate_set`

- API: `public`

```gdscript
func duplicate_set() -> GFTagSet:
```

创建同内容拷贝。

Returns: 新标签集合。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

导出为字典。

Returns: 标签集合字典。

Schemas:

- `return`: Dictionary serialized tag set.

#### `from_dictionary`

- API: `public`

```gdscript
static func from_dictionary(data: Dictionary) -> GFTagSet:
```

从字典创建标签集合。

Parameters:

| Name | Description |
|---|---|
| `data` | 标签集合字典。 |

Returns: 新标签集合。

Schemas:

- `data`: Dictionary serialized tag set or tag count map.

## GFTagSourceAdapter

- Path: `addons/gf/standard/foundation/tags/gf_tag_source_adapter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTagSourceAdapter: 通用标签源适配器。 支持 GFTagSet、Array、PackedStringArray、Dictionary 以及具备 has_tag/get_tag_count/get_tags 方法的对象。它不维护全局标签表，也不规定标签语义。

### Methods

#### `source_has_tag`

- API: `public`

```gdscript
static func source_has_tag( source: Variant, tag: StringName, minimum_count: int = 1, include_child_tags: bool = false ) -> bool:
```

检查标签源是否拥有指定标签。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |
| `tag` | 标签名。 |
| `minimum_count` | 要求的最小层数。 |
| `include_child_tags` | 为 true 时，`state` 可匹配 `state.burning`。 |

Returns: 满足要求返回 true。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `get_tag_count`

- API: `public`

```gdscript
static func get_tag_count(source: Variant, tag: StringName, include_child_tags: bool = false) -> int:
```

获取标签源中的标签层数。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |
| `tag` | 标签名。 |
| `include_child_tags` | 为 true 时合并子标签层数。 |

Returns: 标签层数。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `get_tags`

- API: `public`

```gdscript
static func get_tags(source: Variant) -> PackedStringArray:
```

获取标签源中的标签名。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 排序后的标签名。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `get_tag_counts`

- API: `public`

```gdscript
static func get_tag_counts(source: Variant) -> Dictionary:
```

获取标签源中的标签层数字典。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 标签名到层数的字典。

Schemas:

- `source`: Variant tag source accepted by the adapter.
- `return`: Dictionary[StringName, int]，只包含层数大于 0 的标签。

#### `to_tag_set`

- API: `public`

```gdscript
static func to_tag_set(source: Variant) -> GFTagSet:
```

将任意标签源规范化为 GFTagSet。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |

Returns: 新的标签集合。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `merge_sources`

- API: `public`

```gdscript
static func merge_sources(sources: Array) -> GFTagSet:
```

合并多个标签源并返回新的 GFTagSet。

Parameters:

| Name | Description |
|---|---|
| `sources` | 标签源数组。 |

Returns: 合并后的标签集合。

Schemas:

- `sources`: Array[Variant]，每个元素都可被 GFTagSourceAdapter 读取。

#### `matches_all`

- API: `public`

```gdscript
static func matches_all(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
```

检查标签源是否包含所有标签。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |
| `tags` | 需要全部满足的标签。 |
| `include_child_tags` | 是否启用层级匹配。 |

Returns: 全部满足返回 true。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `matches_any`

- API: `public`

```gdscript
static func matches_any(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
```

检查标签源是否包含任意标签。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |
| `tags` | 需要满足任意一个的标签；空数组返回 true。 |
| `include_child_tags` | 是否启用层级匹配。 |

Returns: 满足任意标签返回 true。

Schemas:

- `source`: Variant tag source accepted by the adapter.

#### `matches_none`

- API: `public`

```gdscript
static func matches_none(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
```

检查标签源是否不包含任何禁止标签。

Parameters:

| Name | Description |
|---|---|
| `source` | 标签源。 |
| `tags` | 禁止出现的标签。 |
| `include_child_tags` | 是否启用层级匹配。 |

Returns: 未命中禁止标签返回 true。

Schemas:

- `source`: Variant tag source accepted by the adapter.

## GFTextAutoFit

- Path: `addons/gf/standard/utilities/ui/gf_text_auto_fit.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTextAutoFit: 文本控件自动字体适配节点。 挂在文本控件旁边或子节点中，在控件尺寸、场景就绪或语言变化时调用 GFTextFitter。 它只负责字体尺寸计算和主题覆盖，不接管文本来源、布局策略或项目本地化规则。

### Properties

#### `target_path`

- API: `public`

```gdscript
var target_path: NodePath
```

目标 Control 路径。为空时使用父节点。

#### `min_font_size`

- API: `public`

```gdscript
var min_font_size: int = GFTextFitter.DEFAULT_MIN_FONT_SIZE:
```

最小字体尺寸。

#### `max_font_size`

- API: `public`

```gdscript
var max_font_size: int = GFTextFitter.DEFAULT_MAX_FONT_SIZE:
```

最大字体尺寸。小于等于 0 时使用控件当前主题字体尺寸。

#### `fit_width`

- API: `public`

```gdscript
var fit_width: bool = true:
```

是否约束宽度。

#### `fit_height`

- API: `public`

```gdscript
var fit_height: bool = true:
```

是否约束高度。

#### `fit_on_ready`

- API: `public`

```gdscript
var fit_on_ready: bool = true
```

是否在进入树并解析目标后立即适配。

#### `refresh_on_resize`

- API: `public`

```gdscript
var refresh_on_resize: bool = true
```

是否监听目标控件 resized 信号。

#### `refresh_on_translation_changed`

- API: `public`

```gdscript
var refresh_on_translation_changed: bool = true
```

是否在收到翻译变更通知时刷新。

#### `deferred_refresh`

- API: `public`

```gdscript
var deferred_refresh: bool = true
```

是否把刷新合并到 deferred 调用，避免同帧多次尺寸变化造成重复计算。

#### `options`

- API: `public`

```gdscript
var options: Dictionary = {}
```

可选额外配置，会合并到 GFTextFitter.fit_control() 的 options。

Schemas:

- `options`: Dictionary，字段同 GFTextFitter.fit_control() 的 options；节点会覆盖 min_font_size、max_font_size、fit_width、fit_height 和 apply。

### Methods

#### `rebind_target`

- API: `public`

```gdscript
func rebind_target() -> void:
```

重新解析并绑定目标控件。

#### `request_refresh`

- API: `public`

```gdscript
func request_refresh() -> void:
```

请求刷新文本适配。

#### `refresh`

- API: `public`

```gdscript
func refresh() -> int:
```

立即执行一次文本适配。

Returns: 计算出的字体尺寸；目标无效时返回 0。

#### `get_target`

- API: `public`

```gdscript
func get_target() -> Control:
```

获取当前目标控件。

Returns: 已绑定的 Control；未绑定时返回 null。

## GFTextFitter

- Path: `addons/gf/standard/utilities/ui/gf_text_fitter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTextFitter: 文本尺寸适配器。 为常见文本控件提供通用字体大小计算，不接管控件布局、主题或项目文本规则。

### Constants

#### `DEFAULT_MIN_FONT_SIZE`

- API: `public`

```gdscript
const DEFAULT_MIN_FONT_SIZE: int = 8
```

默认最小字体尺寸。

#### `DEFAULT_MAX_FONT_SIZE`

- API: `public`

```gdscript
const DEFAULT_MAX_FONT_SIZE: int = 64
```

默认最大字体尺寸。

### Methods

#### `fit_control`

- API: `public`

```gdscript
static func fit_control(control: Control, options: Dictionary = {}) -> int:
```

计算并可选应用常见 Control 的合适字体尺寸。

Parameters:

| Name | Description |
|---|---|
| `control` | 目标文本控件，支持 Label、RichTextLabel、Button、LineEdit 与 TextEdit，也可通过 options.text 适配自定义控件。 |
| `options` | 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name、text、content_insets、use_placeholder。 |

Returns: 计算出的字体尺寸；目标无效或无法读取文本时返回 0。

Schemas:

- `options`: Dictionary，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name、font、text、content_insets、use_placeholder。

#### `fit_label`

- API: `public`

```gdscript
static func fit_label(label: Label, options: Dictionary = {}) -> int:
```

计算并可选应用 Label 的合适字体尺寸。

Parameters:

| Name | Description |
|---|---|
| `label` | 目标 Label。 |
| `options` | 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name。 |

Returns: 计算出的字体尺寸；目标无效时返回 0。

Schemas:

- `options`: Dictionary，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name、font。

#### `fit_rich_text_label`

- API: `public`

```gdscript
static func fit_rich_text_label(label: RichTextLabel, options: Dictionary = {}) -> int:
```

计算并可选应用 RichTextLabel 的合适字体尺寸。

Parameters:

| Name | Description |
|---|---|
| `label` | 目标 RichTextLabel。 |
| `options` | 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name。 |

Returns: 计算出的字体尺寸；目标无效时返回 0。

Schemas:

- `options`: Dictionary，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name、font。

#### `measure_control_text`

- API: `public`

```gdscript
static func measure_control_text(control: Control, font_size: int, options: Dictionary = {}) -> Vector2:
```

测量常见 Control 在指定字体尺寸下的文本占用。

Parameters:

| Name | Description |
|---|---|
| `control` | 目标文本控件。 |
| `font_size` | 字体尺寸。 |
| `options` | fit_control() 使用的设置。 |

Returns: 文本尺寸；目标无效或字体缺失时返回 Vector2.ZERO。

Schemas:

- `options`: Dictionary，字段同 fit_control() 的 options。

#### `measure_text`

- API: `public`

```gdscript
static func measure_text(control: Control, text: String, font_size: int, options: Dictionary = {}) -> Vector2:
```

测量 Control 在指定字体尺寸下的文本占用。

Parameters:

| Name | Description |
|---|---|
| `control` | 提供主题字体的控件。 |
| `text` | 待测量文本。 |
| `font_size` | 字体尺寸。 |
| `options` | fit_label() 或 fit_rich_text_label() 使用的设置。 |

Returns: 文本尺寸；字体缺失时返回 Vector2.ZERO。

Schemas:

- `options`: Dictionary，支持 available_size、fit_width、font_name 和 font。

## GFTileMapCache

- Path: `addons/gf/standard/foundation/math/gf_tile_map_cache.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTileMapCache: 通用格子数据快照与差分缓存。 用 Vector2i 管理格子字典数据，既可手动写入，也可从 TileMapLayer 采集基础 source/atlas/alternative/terrain 信息。它不规定字段语义，项目可扩展记录内容。

### Properties

#### `cells`

- API: `public`

```gdscript
var cells: Dictionary = {}
```

格子数据，结构为 Vector2i -> Dictionary。

Schemas:

- `cells`: Dictionary mapping Vector2i cells to Dictionary cell records.

### Methods

#### `update_from_tile_map`

- API: `public`

```gdscript
func update_from_tile_map(layer: TileMapLayer, target_cells: Array[Vector2i] = []) -> void:
```

从 TileMapLayer 更新缓存。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标 TileMapLayer。 |
| `target_cells` | 要更新的格子；为空时采集 layer.get_used_cells()。 |

#### `set_cell_data`

- API: `public`

```gdscript
func set_cell_data(cell: Vector2i, data: Dictionary) -> void:
```

设置一个格子的字典数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `data` | 格子数据。 |

Schemas:

- `data`: Dictionary cell record copied into the cache.

#### `erase_cell`

- API: `public`

```gdscript
func erase_cell(cell: Vector2i) -> void:
```

移除一个格子。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

#### `has_cell`

- API: `public`

```gdscript
func has_cell(cell: Vector2i) -> bool:
```

检查格子是否存在。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 存在时返回 true。

#### `get_cell_data`

- API: `public`

```gdscript
func get_cell_data(cell: Vector2i) -> Dictionary:
```

获取格子数据副本。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 格子数据。

Schemas:

- `return`: Dictionary cell record copy.

#### `get_value`

- API: `public`

```gdscript
func get_value(cell: Vector2i, key: StringName, default_value: Variant = null) -> Variant:
```

获取格子字段值。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `key` | 字段名。 |
| `default_value` | 默认值。 |

Returns: 字段值。

Schemas:

- `default_value`: Variant fallback value returned when the field is missing.
- `return`: Variant field value or default_value.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空缓存。

#### `diff_cells`

- API: `public`

```gdscript
func diff_cells(other: GFTileMapCache, compare_key: StringName = &"") -> Array[Vector2i]:
```

和另一个缓存做差分。

Parameters:

| Name | Description |
|---|---|
| `other` | 另一个缓存。 |
| `compare_key` | 为空时比较完整字典；否则只比较指定字段。 |

Returns: 发生变化的格子列表。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

序列化为字典。

Returns: 可保存的字典。

Schemas:

- `return`: Dictionary mapping string cell keys to Dictionary cell records.

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | to_dict() 生成的数据。 |

Schemas:

- `data`: Dictionary mapping string cell keys to Dictionary cell records.

## GFTileMetadataLayer

- Path: `addons/gf/standard/foundation/math/gf_tile_metadata_layer.gd`
- Extends: `GFTileMapCache`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTileMetadataLayer: 通用格子元数据层。 在 Vector2i 格坐标上维护任意键值元数据，可服务于编辑器画刷、运行时标记、 规则查询或导出流程。它只管理数据结构，不绑定 TileSet、TileMapLayer 或项目业务语义。

### Properties

#### `schema`

- API: `public`

```gdscript
var schema: Dictionary = {}
```

可选字段 schema。框架不解释 schema 内容，项目可用于编辑器 UI、校验或导出。

Schemas:

- `schema`: Dictionary mapping metadata field names to project-defined field metadata.

### Methods

#### `set_cell_value`

- API: `public`

```gdscript
func set_cell_value(cell: Vector2i, key: StringName, value: Variant) -> void:
```

设置格子字段值。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `key` | 字段名。 |
| `value` | 字段值。 |

Schemas:

- `value`: Variant metadata field value.

#### `get_cell_data`

- API: `public`

```gdscript
func get_cell_data(cell: Vector2i) -> Dictionary:
```

获取格子数据副本。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |

Returns: 格子数据。

Schemas:

- `return`: Dictionary metadata record stored on the cell.

#### `get_cell_value`

- API: `public`

```gdscript
func get_cell_value(cell: Vector2i, key: StringName, default_value: Variant = null) -> Variant:
```

获取格子字段值。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `key` | 字段名。 |
| `default_value` | 默认值。 |

Returns: 字段值。

Schemas:

- `default_value`: Variant fallback value returned when the field is missing.
- `return`: Variant metadata field value or default_value.

#### `merge_cell_data`

- API: `public`

```gdscript
func merge_cell_data(cell: Vector2i, data: Dictionary, overwrite: bool = true) -> void:
```

合并格子数据。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `data` | 要合并的数据。 |
| `overwrite` | 为 false 时不覆盖已有字段。 |

Schemas:

- `data`: Dictionary metadata fields merged into the cell.

#### `erase_cell_key`

- API: `public`

```gdscript
func erase_cell_key(cell: Vector2i, key: StringName) -> bool:
```

移除格子字段。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `key` | 字段名。 |

Returns: 成功移除返回 true。

#### `has_cell_key`

- API: `public`

```gdscript
func has_cell_key(cell: Vector2i, key: StringName) -> bool:
```

检查格子字段是否存在。

Parameters:

| Name | Description |
|---|---|
| `cell` | 格坐标。 |
| `key` | 字段名。 |

Returns: 存在时返回 true。

#### `paint_cells`

- API: `public`

```gdscript
func paint_cells(target_cells: Array[Vector2i], key: StringName, value: Variant) -> int:
```

批量为格子绘制同一个字段值。

Parameters:

| Name | Description |
|---|---|
| `target_cells` | 目标格子。 |
| `key` | 字段名。 |
| `value` | 字段值。 |

Returns: 实际写入的格子数量。

Schemas:

- `value`: Variant metadata field value painted into target cells.

#### `erase_cells_key`

- API: `public`

```gdscript
func erase_cells_key(target_cells: Array[Vector2i], key: StringName) -> int:
```

批量移除格子字段。

Parameters:

| Name | Description |
|---|---|
| `target_cells` | 目标格子。 |
| `key` | 字段名。 |

Returns: 实际移除的字段数量。

#### `get_cells_with_value`

- API: `public`

```gdscript
func get_cells_with_value(key: StringName, value: Variant) -> Array[Vector2i]:
```

查找拥有指定字段值的格子。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |
| `value` | 目标值。 |

Returns: 匹配格子列表。

Schemas:

- `value`: Variant metadata field value to match.

#### `set_schema_entry`

- API: `public`

```gdscript
func set_schema_entry(key: StringName, metadata: Dictionary) -> void:
```

设置 schema 字段元数据。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |
| `metadata` | 字段元数据。 |

Schemas:

- `metadata`: Dictionary project-defined schema metadata for a field.

#### `get_schema_entry`

- API: `public`

```gdscript
func get_schema_entry(key: StringName) -> Dictionary:
```

获取 schema 字段元数据。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |

Returns: schema 元数据副本。

Schemas:

- `return`: Dictionary project-defined schema metadata for a field.

#### `erase_schema_entry`

- API: `public`

```gdscript
func erase_schema_entry(key: StringName) -> void:
```

移除 schema 字段元数据。

Parameters:

| Name | Description |
|---|---|
| `key` | 字段名。 |

#### `to_tile_map_cache`

- API: `public`

```gdscript
func to_tile_map_cache() -> GFTileMapCache:
```

转换为基础 TileMap 缓存。

Returns: 缓存副本。

#### `from_tile_map_cache`

- API: `public`

```gdscript
func from_tile_map_cache(cache: GFTileMapCache, merge: bool = false) -> void:
```

从基础 TileMap 缓存复制数据。

Parameters:

| Name | Description |
|---|---|
| `cache` | 源缓存。 |
| `merge` | 为 true 时合并到现有数据，否则先清空。 |

## GFTileRuleSet

- Path: `addons/gf/standard/foundation/math/gf_tile_rule_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTileRuleSet: 通用瓦片邻域规则表。 使用邻域值序列匹配结果，可用于自动铺砖、地形变体、网格装饰或任意 基于相邻格子状态的选择逻辑。规则只处理 Variant 值，不绑定 TileSet 语义。

### Properties

#### `fallback_neighbor_value`

- API: `public`

```gdscript
var fallback_neighbor_value: Variant = 0
```

规则匹配失败时尝试使用的邻域回退值。

Schemas:

- `fallback_neighbor_value`: Variant fallback neighbor value used while resolving rules.

#### `default_result`

- API: `public`

```gdscript
var default_result: Variant = null
```

没有匹配规则时返回的值。

Schemas:

- `default_result`: Variant fallback result returned when no rule matches.

#### `deterministic_seed`

- API: `public`

```gdscript
var deterministic_seed: int = 0
```

参与确定性加权选择的默认种子。

### Methods

#### `register_rule`

- API: `public`

```gdscript
func register_rule(neighbor_values: Array, result: Variant, weight: float = 1.0) -> void:
```

注册一条邻域规则。

Parameters:

| Name | Description |
|---|---|
| `neighbor_values` | 邻域值序列。 |
| `result` | 匹配结果。 |
| `weight` | 同一邻域下多个结果的权重。 |

Schemas:

- `neighbor_values`: Array ordered neighbor values used as a rule key.
- `result`: Variant result returned when the rule matches.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空全部规则。

#### `get_rule_count`

- API: `public`

```gdscript
func get_rule_count() -> int:
```

获取已注册规则数量。

Returns: 规则数量。

#### `resolve`

- API: `public`

```gdscript
func resolve(neighbor_values: Array, cell: Vector2i = Vector2i.ZERO, seed: int = 0) -> Variant:
```

根据邻域值解析结果。

Parameters:

| Name | Description |
|---|---|
| `neighbor_values` | 邻域值序列。 |
| `cell` | 可选格坐标，用于确定性加权选择。 |
| `seed` | 可选种子；为 0 时使用 deterministic_seed。 |

Returns: 匹配结果；没有匹配时返回 default_result。

Schemas:

- `neighbor_values`: Array ordered neighbor values used as a rule key.
- `return`: Variant matched result or default_result.

#### `has_rule`

- API: `public`

```gdscript
func has_rule(neighbor_values: Array) -> bool:
```

检查邻域值是否存在明确规则。

Parameters:

| Name | Description |
|---|---|
| `neighbor_values` | 邻域值序列。 |

Returns: 存在规则时返回 true。

Schemas:

- `neighbor_values`: Array ordered neighbor values used as a rule key.

## GFTimeUtility

- Path: `addons/gf/standard/utilities/time/gf_time_utility.gd`
- Extends: `GFTimeProvider`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTimeUtility: 全局时间控制工具。 继承自 GFUtility，提供全局时间缩放、暂停和组级暂停控制能力。 架构在 tick / physics_tick 中自动从本工具获取缩放后的 delta， 无需 System 自行处理暂停逻辑。 用法： 1. 在架构的 _on_init() 中注册本工具。 2. 设置 time_scale 可全局加减速（如子弹时间设为 0.3）。 3. 设置 is_paused = true 暂停所有受控 System。 4. 使用 set_group_paused() 实现 UI 层/逻辑层分组暂停。 5. System 可设置 ignore_pause = true 来忽略暂停（如暂停菜单动画）。

### Properties

#### `time_scale`

- API: `public`

```gdscript
var time_scale: float = 1.0:
```

全局时间缩放系数。1.0 为正常速度，0.5 为半速，2.0 为双倍速。 不得为负值，设置负值将被钳制为 0.0。

#### `max_scaled_delta`

- API: `public`

```gdscript
var max_scaled_delta: float = 0.0:
```

单次缩放后 delta 的最大值。小于等于 0 时不限制。 可用于避免极端 time_scale 或掉帧后向普通 tick 传入过大步长。

#### `physics_substep_max_delta`

- API: `public`

```gdscript
var physics_substep_max_delta: float = 0.0:
```

physics_tick 子步进的最大缩放步长。小于等于 0 时不启用子步进。

#### `max_physics_substeps`

- API: `public`

```gdscript
var max_physics_substeps: int = 8:
```

单个物理帧最多拆分出的子步数。

#### `is_paused`

- API: `public`

```gdscript
var is_paused: bool = false
```

全局暂停标志。为 true 时，所有未标记 ignore_pause 的 System 接收 delta = 0.0。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化：重置时间状态。

#### `get_scaled_delta`

- API: `public`

```gdscript
func get_scaled_delta(delta: float) -> float:
```

获取经过全局缩放的 delta 值。暂停时返回 0.0。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始帧间隔时间。 |

Returns: 缩放后的 delta。

#### `get_physics_scaled_delta_steps`

- API: `public`

```gdscript
func get_physics_scaled_delta_steps(delta: float) -> Array[float]:
```

获取 physics_tick 使用的缩放 delta 子步数组。 未启用子步进或无需拆分时返回单元素数组。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始物理帧间隔时间。 |

Returns: 缩放后的 delta 子步数组。

#### `should_substep_physics`

- API: `public`

```gdscript
func should_substep_physics(delta: float) -> bool:
```

判断当前物理帧是否会被拆分为多个子步。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始物理帧间隔时间。 |

Returns: 会拆分时返回 true。

#### `is_time_paused`

- API: `public`

```gdscript
func is_time_paused() -> bool:
```

检查当前工具是否处于全局暂停状态。

Returns: 暂停时返回 true。

#### `set_group_paused`

- API: `public`

```gdscript
func set_group_paused(group: StringName, paused: bool) -> void:
```

设置指定组的暂停状态。

Parameters:

| Name | Description |
|---|---|
| `group` | 组标识符。 |
| `paused` | 是否暂停。 |

#### `is_group_paused`

- API: `public`

```gdscript
func is_group_paused(group: StringName) -> bool:
```

查询指定组是否处于暂停状态。

Parameters:

| Name | Description |
|---|---|
| `group` | 组标识符。 |

Returns: 该组是否暂停，未注册的组返回 false。

#### `get_group_scaled_delta`

- API: `public`

```gdscript
func get_group_scaled_delta(group: StringName, delta: float) -> float:
```

获取指定组经过缩放的 delta 值。 若全局暂停或该组暂停，返回 0.0。

Parameters:

| Name | Description |
|---|---|
| `group` | 组标识符。 |
| `delta` | 引擎原始帧间隔时间。 |

Returns: 缩放后的 delta。

#### `remove_group`

- API: `public`

```gdscript
func remove_group(group: StringName) -> void:
```

移除指定组的暂停记录。

Parameters:

| Name | Description |
|---|---|
| `group` | 组标识符。 |

#### `clear_groups`

- API: `public`

```gdscript
func clear_groups() -> void:
```

清除所有组级暂停记录。

## GFTimedTextEntry

- Path: `addons/gf/standard/foundation/timeline/gf_timed_text_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTimedTextEntry: 通用时间段文本条目。 表示一段开始时间、结束时间和文本，可用于字幕、对白、提示或时间轴注释。

### Properties

#### `start_time`

- API: `public`

```gdscript
var start_time: float = 0.0
```

开始时间，单位秒。

#### `end_time`

- API: `public`

```gdscript
var end_time: float = 0.0
```

结束时间，单位秒。

#### `text`

- API: `public`

```gdscript
var text: String = ""
```

文本内容。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: Dictionary extension metadata for the timed text entry.

### Methods

#### `contains_time`

- API: `public`

```gdscript
func contains_time(time_seconds: float) -> bool:
```

检查时间是否落在条目范围内。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 时间，单位秒。 |

Returns: 落在范围内返回 true。

#### `intersects_range`

- API: `public`

```gdscript
func intersects_range(range_start: float, range_end: float) -> bool:
```

检查条目是否与时间范围相交。

Parameters:

| Name | Description |
|---|---|
| `range_start` | 范围开始时间。 |
| `range_end` | 范围结束时间。 |

Returns: 相交返回 true。

#### `duplicate_entry`

- API: `public`

```gdscript
func duplicate_entry() -> GFTimedTextEntry:
```

创建同内容拷贝。

Returns: 新条目。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 条目字典。

Schemas:

- `return`: Dictionary serialized timed text entry.

#### `apply_dictionary`

- API: `public`

```gdscript
func apply_dictionary(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary serialized timed text entry.

## GFTimedTextImporter

- Path: `addons/gf/standard/foundation/timeline/gf_timed_text_importer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTimedTextImporter: 通用时间段文本解析器。 提供 SRT、WebVTT 与 LRC 的轻量解析入口，输出 `GFTimedTextTrack`。

### Methods

#### `parse_srt`

- API: `public`

```gdscript
static func parse_srt(text: String, track_id: StringName = &"") -> Dictionary:
```

解析 SRT 文本。

Parameters:

| Name | Description |
|---|---|
| `text` | SRT 文本。 |
| `track_id` | 可选轨道标识。 |

Returns: 解析结果字典，包含 success、track 与 error。

Schemas:

- `return`: Dictionary with success: bool, track: GFTimedTextTrack, error: String.

#### `parse_vtt`

- API: `public`

```gdscript
static func parse_vtt(text: String, track_id: StringName = &"") -> Dictionary:
```

解析 WebVTT 文本。

Parameters:

| Name | Description |
|---|---|
| `text` | WebVTT 文本。 |
| `track_id` | 可选轨道标识。 |

Returns: 解析结果字典，包含 success、track 与 error。

Schemas:

- `return`: Dictionary with success: bool, track: GFTimedTextTrack, error: String.

#### `parse_lrc`

- API: `public`

```gdscript
static func parse_lrc( text: String, default_duration: float = 2.0, track_id: StringName = &"" ) -> Dictionary:
```

解析 LRC 文本。

Parameters:

| Name | Description |
|---|---|
| `text` | LRC 文本。 |
| `default_duration` | 单行没有下一行时使用的默认时长。 |
| `track_id` | 可选轨道标识。 |

Returns: 解析结果字典，包含 success、track 与 error。

Schemas:

- `return`: Dictionary with success: bool, track: GFTimedTextTrack, error: String.

## GFTimedTextTrack

- Path: `addons/gf/standard/foundation/timeline/gf_timed_text_track.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTimedTextTrack: 通用时间段文本轨道。 管理一组按时间查询的 `GFTimedTextEntry`，不绑定字幕格式或具体 UI。

### Properties

#### `track_id`

- API: `public`

```gdscript
var track_id: StringName = &""
```

轨道标识。

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFTimedTextEntry] = []
```

时间段文本条目列表。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。

Schemas:

- `metadata`: Dictionary extension metadata for the timed text track.

### Methods

#### `add_entry`

- API: `public`

```gdscript
func add_entry( start_time: float, end_time: float, text: String, entry_metadata: Dictionary = {} ) -> GFTimedTextEntry:
```

添加时间段文本条目。

Parameters:

| Name | Description |
|---|---|
| `start_time` | 开始时间，单位秒。 |
| `end_time` | 结束时间，单位秒。 |
| `text` | 文本内容。 |
| `entry_metadata` | 条目元数据。 |

Returns: 新条目。

Schemas:

- `entry_metadata`: Dictionary metadata copied into the new entry.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空轨道。

#### `sort_entries`

- API: `public`

```gdscript
func sort_entries() -> void:
```

按开始时间排序条目。

#### `get_entry_at_time`

- API: `public`

```gdscript
func get_entry_at_time(time_seconds: float) -> GFTimedTextEntry:
```

获取指定时间的第一条文本条目。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 时间，单位秒。 |

Returns: 命中的条目；没有命中时返回 null。

#### `get_text_at_time`

- API: `public`

```gdscript
func get_text_at_time(time_seconds: float, default_text: String = "") -> String:
```

获取指定时间的文本。

Parameters:

| Name | Description |
|---|---|
| `time_seconds` | 时间，单位秒。 |
| `default_text` | 没有命中时返回的文本。 |

Returns: 文本内容。

#### `get_entries_in_range`

- API: `public`

```gdscript
func get_entries_in_range(range_start: float, range_end: float) -> Array[GFTimedTextEntry]:
```

获取与时间范围相交的条目。

Parameters:

| Name | Description |
|---|---|
| `range_start` | 范围开始时间。 |
| `range_end` | 范围结束时间。 |

Returns: 条目列表。

#### `get_total_duration`

- API: `public`

```gdscript
func get_total_duration() -> float:
```

获取轨道总时长。

Returns: 最大结束时间。

#### `duplicate_track`

- API: `public`

```gdscript
func duplicate_track() -> GFTimedTextTrack:
```

创建同内容拷贝。

Returns: 新轨道。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: 轨道字典。

Schemas:

- `return`: Dictionary serialized timed text track.

#### `apply_dictionary`

- API: `public`

```gdscript
func apply_dictionary(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary serialized timed text track.

## GFTimerUtility

- Path: `addons/gf/standard/utilities/time/gf_timer_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTimerUtility: 纯代码驱动的全局定时器工具。 通过框架 `tick()` 驱动延时回调，不依赖场景树中的 `Timer` 节点， 因而可直接受到 `GFTimeUtility` 的时间缩放与暂停控制。适用于在 `GFSystem`、`GFModel` 或其他纯逻辑模块中调度一次性、重复或 owner 绑定任务。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化定时器队列。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

清空定时器队列。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

推进运行时逻辑。

Parameters:

| Name | Description |
|---|---|
| `delta` | 本帧时间增量（秒）。 |

#### `execute_after`

- API: `public`

```gdscript
func execute_after(delay: float, callback: Callable) -> int:
```

在指定延迟后执行一次回调函数。 基于框架 `tick()` 推进计时，因此会自动遵循 `GFTimeUtility` 的暂停与缩放结果。

Parameters:

| Name | Description |
|---|---|
| `delay` | 延迟时长，单位为秒。 |
| `callback` | 延迟结束后执行的无参回调函数。 |

Returns: 已排队定时器的句柄；无效回调或立即执行时返回 `0`。

#### `execute_after_owned`

- API: `public`

```gdscript
func execute_after_owned(owner: Object, delay: float, callback: Callable) -> int:
```

在指定延迟后执行一次 owner 绑定回调。owner 释放后任务会自动丢弃。

Parameters:

| Name | Description |
|---|---|
| `owner` | 定时器拥有者。 |
| `delay` | 延迟时长，单位为秒。 |
| `callback` | 延迟结束后执行的无参回调函数。 |

Returns: 已排队定时器的句柄；无效输入或立即执行时返回 `0`。

#### `execute_repeating`

- API: `public`

```gdscript
func execute_repeating( interval: float, callback: Callable, repeat_count: int = -1, initial_delay: float = -1.0 ) -> int:
```

按固定间隔重复执行回调。

Parameters:

| Name | Description |
|---|---|
| `interval` | 重复间隔，单位为秒。 |
| `callback` | 每次触发时执行的无参回调函数。 |
| `repeat_count` | 触发次数；小于 0 表示无限重复。 |
| `initial_delay` | 首次触发延迟；小于 0 时使用 interval。 |

Returns: 已排队定时器的句柄；无效输入时返回 `0`。

#### `execute_repeating_owned`

- API: `public`

```gdscript
func execute_repeating_owned( owner: Object, interval: float, callback: Callable, repeat_count: int = -1, initial_delay: float = -1.0 ) -> int:
```

按固定间隔重复执行 owner 绑定回调。owner 释放后任务会自动丢弃。

Parameters:

| Name | Description |
|---|---|
| `owner` | 定时器拥有者。 |
| `interval` | 重复间隔，单位为秒。 |
| `callback` | 每次触发时执行的无参回调函数。 |
| `repeat_count` | 触发次数；小于 0 表示无限重复。 |
| `initial_delay` | 首次触发延迟；小于 0 时使用 interval。 |

Returns: 已排队定时器的句柄；无效输入时返回 `0`。

#### `cancel`

- API: `public`

```gdscript
func cancel(handle: int) -> bool:
```

取消一个尚未触发的延时任务。

Parameters:

| Name | Description |
|---|---|
| `handle` | `execute_after()` 返回的定时器句柄。 |

Returns: 找到并取消任务时返回 `true`。

#### `cancel_owner`

- API: `public`

```gdscript
func cancel_owner(owner: Object) -> int:
```

取消指定 owner 绑定的全部待执行任务。

Parameters:

| Name | Description |
|---|---|
| `owner` | 定时器拥有者。 |

Returns: 被取消的任务数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取定时器工具诊断快照。

Returns: 诊断快照字典。

Schemas:

- `return`: Dictionary with `pending_count`, `pending_handles`, `owner_bound_count`, `executing_count`, and `next_timer_id`.

## GFTouchButton

- Path: `addons/gf/standard/input/touch/gf_touch_button.gd`
- Extends: `Node2D`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTouchButton: 通用触屏虚拟按钮节点。 可直接发送按下/释放信号，也可映射到 Godot InputMap 动作或虚拟手柄按钮事件。

### Signals

#### `button_pressed`

- API: `public`

```gdscript
signal button_pressed
```

按钮按下时发出。

#### `button_released`

- API: `public`

```gdscript
signal button_released
```

按钮释放时发出。

### Properties

#### `radius`

- API: `public`

```gdscript
var radius: float = 48.0:
```

按钮半径。

#### `color`

- API: `public`

```gdscript
var color: Color = Color(1.0, 1.0, 1.0, 0.3):
```

按钮常态颜色。

#### `pressed_color`

- API: `public`

```gdscript
var pressed_color: Color = Color(1.0, 1.0, 1.0, 0.65):
```

按钮按下颜色。

#### `accept_mouse_input`

- API: `public`

```gdscript
var accept_mouse_input: bool = true
```

是否允许鼠标左键模拟触屏。

#### `action_name`

- API: `public`

```gdscript
var action_name: StringName = &""
```

映射到 Godot InputMap 的动作名。为空则不映射。

#### `emit_joypad_button`

- API: `public`

```gdscript
var emit_joypad_button: bool = false
```

是否额外发送虚拟手柄按钮事件。

#### `joypad_device_id`

- API: `public`

```gdscript
var joypad_device_id: int = -2
```

虚拟手柄设备 ID。建议使用负数以避开真实手柄。

#### `joy_button`

- API: `public`

```gdscript
var joy_button: JoyButton = JOY_BUTTON_A
```

对应的手柄按钮。

### Methods

#### `is_pressed`

- API: `public`

```gdscript
func is_pressed() -> bool:
```

检查按钮是否处于按下状态。

Returns: 是否按下。

#### `release`

- API: `public`

```gdscript
func release() -> void:
```

手动释放按钮。

## GFTouchJoystick

- Path: `addons/gf/standard/input/touch/gf_touch_joystick.gd`
- Extends: `Node2D`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTouchJoystick: 通用触屏虚拟摇杆节点。 可直接发出方向信号，也可选择映射到 Godot InputMap 动作。

### Signals

#### `direction_changed`

- API: `public`

```gdscript
signal direction_changed(direction: Vector2)
```

摇杆方向变化时发出。方向已归一化并应用死区。

Parameters:

| Name | Description |
|---|---|
| `direction` | 已归一化并应用死区后的摇杆方向。 |

#### `joystick_pressed`

- API: `public`

```gdscript
signal joystick_pressed
```

摇杆按下时发出。

#### `joystick_released`

- API: `public`

```gdscript
signal joystick_released
```

摇杆释放时发出。

### Enums

#### `PositionMode`

- API: `public`

```gdscript
enum PositionMode { ## 摇杆中心保持在场景中摆放的位置。 FIXED, ## 初次触摸时摇杆中心移动到触点，释放后回到原位置。 RELATIVE, }
```

摇杆定位模式。

### Properties

#### `radius`

- API: `public`

```gdscript
var radius: float = 64.0:
```

摇杆半径。

#### `knob_radius_ratio`

- API: `public`

```gdscript
var knob_radius_ratio: float = 3.0:
```

摇杆手柄半径比例。

#### `color`

- API: `public`

```gdscript
var color: Color = Color(1.0, 1.0, 1.0, 0.35):
```

摇杆颜色。

#### `draw_interaction_zone`

- API: `public`

```gdscript
var draw_interaction_zone: bool = false:
```

是否绘制相对摇杆交互范围。

#### `deadzone`

- API: `public`

```gdscript
var deadzone: float = 0.1
```

输入死区，范围 0 到 1。

#### `position_mode`

- API: `public`

```gdscript
var position_mode: PositionMode = PositionMode.FIXED:
```

摇杆定位模式。

#### `interaction_radius`

- API: `public`

```gdscript
var interaction_radius: float = 160.0:
```

相对模式下允许开始触控的交互半径。

#### `action_left`

- API: `public`

```gdscript
var action_left: StringName = &""
```

左方向动作名。为空则不映射。

#### `action_right`

- API: `public`

```gdscript
var action_right: StringName = &""
```

右方向动作名。为空则不映射。

#### `action_up`

- API: `public`

```gdscript
var action_up: StringName = &""
```

上方向动作名。为空则不映射。

#### `action_down`

- API: `public`

```gdscript
var action_down: StringName = &""
```

下方向动作名。为空则不映射。

#### `emit_joypad_motion`

- API: `public`

```gdscript
var emit_joypad_motion: bool = false
```

是否额外发送虚拟手柄轴事件。

#### `joypad_device_id`

- API: `public`

```gdscript
var joypad_device_id: int = -2
```

虚拟手柄设备 ID。建议使用负数以避开真实手柄。

#### `joy_axis_x`

- API: `public`

```gdscript
var joy_axis_x: JoyAxis = JOY_AXIS_LEFT_X
```

X 轴对应的手柄轴。

#### `joy_axis_y`

- API: `public`

```gdscript
var joy_axis_y: JoyAxis = JOY_AXIS_LEFT_Y
```

Y 轴对应的手柄轴。

### Methods

#### `get_direction`

- API: `public`

```gdscript
func get_direction() -> Vector2:
```

获取当前方向。

Returns: 当前摇杆方向。

#### `release`

- API: `public`

```gdscript
func release() -> void:
```

手动释放摇杆并清理动作状态。

## GFUIRoute

- Path: `addons/gf/standard/utilities/ui/gf_ui_route.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFUIRoute: UI 路由资源描述。 只描述路由标识、面板场景、目标层级和默认打开选项，不规定页面业务、 动画实现或面板通信方式。

### Properties

#### `route_id`

- API: `public`

```gdscript
var route_id: StringName = &""
```

路由稳定标识。

#### `scene_path`

- API: `public`

```gdscript
var scene_path: String = ""
```

面板场景路径。

#### `layer`

- API: `public`

```gdscript
var layer: int = GFUIUtility.Layer.POPUP
```

目标 UI 层级。默认使用 GFUIUtility.POPUP。

#### `default_options`

- API: `public`

```gdscript
var default_options: Dictionary = {}
```

默认面板选项，会传给 GFUIUtility。

Schemas:

- `default_options`: Dictionary，字段同 GFUIUtility 打开面板 options，例如 metadata、config_callback、modal、allow_cancel_dismiss。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

路由元数据。框架只透传，不解释字段含义。

Schemas:

- `metadata`: Dictionary，由项目定义的路由元数据；build_options() 会追加 route_id 和 route_params。

### Methods

#### `get_route_id`

- API: `public`

```gdscript
func get_route_id() -> StringName:
```

获取稳定路由标识。

Returns: 路由标识；未显式设置时尝试使用资源路径。

#### `is_valid_route`

- API: `public`

```gdscript
func is_valid_route() -> bool:
```

检查路由是否具备可打开的基本信息。

Returns: 路由有效时返回 true。

#### `build_options`

- API: `public`

```gdscript
func build_options(params: Dictionary = {}, option_overrides: Dictionary = {}) -> Dictionary:
```

合并默认选项、覆盖选项和路由参数。

Parameters:

| Name | Description |
|---|---|
| `params` | 本次打开路由携带的参数。 |
| `option_overrides` | 本次打开路由的选项覆盖。 |

Returns: 合并后的 GFUIUtility 选项。

Schemas:

- `params`: Dictionary，由项目定义的路由参数，会复制到 metadata.route_params。
- `option_overrides`: Dictionary，字段同 GFUIUtility 打开面板 options，会覆盖 default_options。
- `return`: Dictionary，合并后的面板打开 options，至少包含 metadata.route_id，可能包含 metadata.route_params。

## GFUIRouterUtility

- Path: `addons/gf/standard/utilities/ui/gf_ui_router_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFUIRouterUtility: 基于路由 ID 的 UI 导航工具。 作为 GFUIUtility 之上的轻量路由层，负责把稳定 route_id 映射到面板场景、 打开参数、层级和历史记录，不接管具体页面业务或动画表现。

### Signals

#### `route_open_requested`

- API: `public`

```gdscript
signal route_open_requested(route_id: StringName, operation: Operation, params: Dictionary)
```

路由打开请求发出时触发。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `operation` | 打开操作。 |
| `params` | 路由参数。 |

Schemas:

- `params`: Dictionary，本次打开路由携带的项目自定义参数。

#### `route_opened`

- API: `public`

```gdscript
signal route_opened(route_id: StringName, panel: Node, operation: Operation)
```

路由面板成功打开后触发。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `panel` | 面板实例。 |
| `operation` | 打开操作。 |

#### `route_open_failed`

- API: `public`

```gdscript
signal route_open_failed(route_id: StringName, reason: String)
```

路由打开失败时触发。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `reason` | 失败原因。 |

#### `route_back_completed`

- API: `public`

```gdscript
signal route_back_completed(route_id: StringName, layer: int)
```

路由返回完成时触发。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 被弹出的路由标识。 |
| `layer` | 所在层级。 |

### Enums

#### `Operation`

- API: `public`

```gdscript
enum Operation { ## 压入当前层级栈顶。 PUSH, ## 替换当前层级栈。 REPLACE, }
```

路由打开操作。

### Properties

#### `max_history`

- API: `public`

```gdscript
var max_history: int = 64
```

路由历史最大保留数量。小于等于 0 表示不保留历史。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化路由表、UI 工具引用和历史记录。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放路由表、UI 工具引用和历史记录。

#### `configure`

- API: `public`

```gdscript
func configure(routes: Array[GFUIRoute] = [], ui_utility: GFUIUtility = null) -> void:
```

配置路由表和可选 UI 工具实例。

Parameters:

| Name | Description |
|---|---|
| `routes` | 路由资源列表。 |
| `ui_utility` | 可选 GFUIUtility；为空时从当前架构查找。 |

#### `set_ui_utility`

- API: `public`

```gdscript
func set_ui_utility(ui_utility: GFUIUtility) -> void:
```

设置路由使用的 UI 栈工具。

Parameters:

| Name | Description |
|---|---|
| `ui_utility` | UI 栈工具实例。 |

#### `register_route`

- API: `public`

```gdscript
func register_route(route: GFUIRoute) -> bool:
```

注册一个路由。

Parameters:

| Name | Description |
|---|---|
| `route` | 路由资源。 |

Returns: 注册成功返回 true。

#### `register_routes`

- API: `public`

```gdscript
func register_routes(routes: Array[GFUIRoute]) -> void:
```

批量注册路由。

Parameters:

| Name | Description |
|---|---|
| `routes` | 路由资源列表。 |

#### `unregister_route`

- API: `public`

```gdscript
func unregister_route(route_id: StringName) -> void:
```

注销路由。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |

#### `clear_routes`

- API: `public`

```gdscript
func clear_routes() -> void:
```

清空路由表。

#### `get_route`

- API: `public`

```gdscript
func get_route(route_id: StringName) -> GFUIRoute:
```

获取路由资源。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |

Returns: 路由资源；不存在时返回 null。

#### `has_route`

- API: `public`

```gdscript
func has_route(route_id: StringName) -> bool:
```

检查路由是否已注册。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |

Returns: 已注册返回 true。

#### `get_route_ids`

- API: `public`

```gdscript
func get_route_ids() -> PackedStringArray:
```

获取所有路由标识。

Returns: 路由标识列表。

#### `push_route`

- API: `public`

```gdscript
func push_route( route_id: StringName, params: Dictionary = {}, option_overrides: Dictionary = {}, config_callback: Callable = Callable() ) -> Node:
```

压入一个路由面板。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `params` | 路由参数。 |
| `option_overrides` | 面板选项覆盖。 |
| `config_callback` | 面板实例化后、入栈前的额外配置回调。 |

Returns: 成功时返回面板实例。

Schemas:

- `params`: Dictionary，本次打开路由携带的项目自定义参数。
- `option_overrides`: Dictionary，字段同 GFUIUtility 打开面板 options，会覆盖路由 default_options。

#### `replace_route`

- API: `public`

```gdscript
func replace_route( route_id: StringName, params: Dictionary = {}, option_overrides: Dictionary = {}, config_callback: Callable = Callable() ) -> Node:
```

替换路由所在层级。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `params` | 路由参数。 |
| `option_overrides` | 面板选项覆盖。 |
| `config_callback` | 面板实例化后、入栈前的额外配置回调。 |

Returns: 成功时返回面板实例。

Schemas:

- `params`: Dictionary，本次打开路由携带的项目自定义参数。
- `option_overrides`: Dictionary，字段同 GFUIUtility 打开面板 options，会覆盖路由 default_options。

#### `push_route_async`

- API: `public`

```gdscript
func push_route_async( route_id: StringName, params: Dictionary = {}, option_overrides: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

异步压入一个路由面板。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `params` | 路由参数。 |
| `option_overrides` | 面板选项覆盖。 |
| `config_callback` | 面板实例化后、入栈前的额外配置回调。 |

Schemas:

- `params`: Dictionary，本次打开路由携带的项目自定义参数。
- `option_overrides`: Dictionary，字段同 GFUIUtility 打开面板 options，会覆盖路由 default_options。

#### `replace_route_async`

- API: `public`

```gdscript
func replace_route_async( route_id: StringName, params: Dictionary = {}, option_overrides: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

异步替换路由所在层级。

Parameters:

| Name | Description |
|---|---|
| `route_id` | 路由标识。 |
| `params` | 路由参数。 |
| `option_overrides` | 面板选项覆盖。 |
| `config_callback` | 面板实例化后、入栈前的额外配置回调。 |

Schemas:

- `params`: Dictionary，本次打开路由携带的项目自定义参数。
- `option_overrides`: Dictionary，字段同 GFUIUtility 打开面板 options，会覆盖路由 default_options。

#### `back`

- API: `public`

```gdscript
func back(layer: int = -1, do_free: bool = true) -> bool:
```

返回上一层路由。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时使用最近的历史记录。 |
| `do_free` | 是否释放被弹出的面板。 |

Returns: 成功返回 true。

#### `get_current_route_id`

- API: `public`

```gdscript
func get_current_route_id(layer: int = -1) -> StringName:
```

获取当前路由标识。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时返回最近路由。 |

Returns: 当前路由标识；没有时返回空 StringName。

#### `get_route_history`

- API: `public`

```gdscript
func get_route_history() -> Array[Dictionary]:
```

获取路由历史副本。

Returns: 从旧到新的历史条目。

Schemas:

- `return`: Array，元素为 Dictionary，包含 route_id、layer、panel、params 和 metadata。

#### `clear_history`

- API: `public`

```gdscript
func clear_history() -> void:
```

清空路由历史，不影响已打开面板。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取路由诊断快照。

Returns: 诊断快照。

Schemas:

- `return`: Dictionary，包含 route_count、history_count、current_route_id 和 has_ui_utility。

## GFUIUtility

- Path: `addons/gf/standard/utilities/ui/gf_ui_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFUIUtility: 栈式 UI 管理器。 负责多层级界面的入栈、出栈与异步加载， 适合 HUD、弹窗和顶层遮罩等需要分层管理的 UI 场景。

### Signals

#### `panel_opened`

- API: `public`

```gdscript
signal panel_opened(panel: Node, layer: int)
```

面板成功进入 UI 栈后发出。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |
| `layer` | 目标层级。 |

#### `panel_closed`

- API: `public`

```gdscript
signal panel_closed(panel: Node, layer: int)
```

面板离开 UI 栈后发出。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |
| `layer` | 原层级。 |

#### `navigation_changed`

- API: `public`

```gdscript
signal navigation_changed(layer: int, top_panel: Node)
```

指定层级的栈顶面板变化后发出。

Parameters:

| Name | Description |
|---|---|
| `layer` | 发生变化的层级。 |
| `top_panel` | 新栈顶面板；层级为空时为 null。 |

#### `panel_dismiss_requested`

- API: `public`

```gdscript
signal panel_dismiss_requested(panel: Node, layer: int, reason: String)
```

面板请求被取消或关闭时发出。

Parameters:

| Name | Description |
|---|---|
| `panel` | 请求关闭的面板。 |
| `layer` | 所在层级。 |
| `reason` | 关闭原因。 |

#### `panel_async_load_started`

- API: `public`

```gdscript
signal panel_async_load_started(path: String, layer: int, operation: StringName)
```

异步面板加载请求开始时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `operation` | 打开操作，可能为 push 或 replace。 |

#### `panel_async_load_finished`

- API: `public`

```gdscript
signal panel_async_load_finished(path: String, layer: int, operation: StringName, status: int, panel: Node)
```

异步面板加载请求结束时发出。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `operation` | 打开操作，可能为 push 或 replace。 |
| `status` | 结束状态，使用 AsyncPanelLoadStatus。 |
| `panel` | 成功打开的面板；失败或取消时为 null。 |

### Enums

#### `Layer`

- API: `public`

```gdscript
enum Layer { ## 基础信息层，如主界面、血条 HUD 等。 HUD = 0, ## 弹窗层，如背包、设置菜单、对话框等。 POPUP = 1, ## 顶层，如全屏遮罩、断线重连提示等。 TOP = 2, }
```

UI 层级，数值越大显示越靠前。

#### `PanelMode`

- API: `public`

```gdscript
enum PanelMode { ## 普通面板。 NORMAL, ## Modal 面板，通常会独占当前交互焦点。 MODAL, }
```

面板交互模式。

#### `AsyncPanelLoadStatus`

- API: `public`

```gdscript
enum AsyncPanelLoadStatus { ## 面板已完成加载并进入 UI 栈。 OPENED, ## 加载资源、实例化或入栈失败。 FAILED, ## 请求被弹出、清层、替换层或销毁 UI 工具取消。 CANCELLED, }
```

异步面板加载结束状态。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化 UI 层级根节点并激活管理器。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放 UI 层级、面板栈和未完成异步请求。

#### `configure`

- API: `public`

```gdscript
func configure(auto_hide_under: bool = true) -> void:
```

配置 UI 管理器。

Parameters:

| Name | Description |
|---|---|
| `auto_hide_under` | 压入新面板时是否自动隐藏下层面板。 |

#### `push_panel_async`

- API: `public`

```gdscript
func push_panel_async(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> void:
```

异步压入一个面板场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

#### `push_panel_async_with_options`

- API: `public`

```gdscript
func push_panel_async_with_options( path: String, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

异步压入一个带策略选项的面板场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `push_panel`

- API: `public`

```gdscript
func push_panel(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
```

同步压入一个面板场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Returns: 成功时返回面板实例，失败时返回 `null`。

#### `push_panel_with_options`

- API: `public`

```gdscript
func push_panel_with_options( path: String, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> Node:
```

同步压入一个带策略选项的面板场景。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Returns: 成功时返回面板实例，失败时返回 `null`。

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `replace_layer`

- API: `public`

```gdscript
func replace_layer(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
```

同步替换指定层级的面板栈。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Returns: 成功时返回面板实例，失败时返回 `null`。

#### `replace_layer_with_options`

- API: `public`

```gdscript
func replace_layer_with_options( path: String, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> Node:
```

同步替换指定层级为带策略选项的面板。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Returns: 成功时返回面板实例，失败时返回 `null`。

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `replace_layer_async`

- API: `public`

```gdscript
func replace_layer_async(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> void:
```

异步替换指定层级的面板栈。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

#### `replace_layer_async_with_options`

- API: `public`

```gdscript
func replace_layer_async_with_options( path: String, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

异步替换指定层级为带策略选项的面板。

Parameters:

| Name | Description |
|---|---|
| `path` | 面板场景路径。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 实例化后、入栈前的可选配置回调。 |

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `push_panel_instance`

- API: `public`

```gdscript
func push_panel_instance( panel_instance: Node, layer: Layer = Layer.POPUP, config_callback: Callable = Callable() ) -> void:
```

压入一个已实例化的面板节点。

Parameters:

| Name | Description |
|---|---|
| `panel_instance` | 面板实例。 |
| `layer` | 目标层级。 |
| `config_callback` | 入栈前的可选配置回调。 |

#### `push_panel_instance_with_options`

- API: `public`

```gdscript
func push_panel_instance_with_options( panel_instance: Node, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

压入一个已实例化且带策略选项的面板节点。

Parameters:

| Name | Description |
|---|---|
| `panel_instance` | 面板实例。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 入栈前的可选配置回调。 |

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `replace_layer_instance`

- API: `public`

```gdscript
func replace_layer_instance( panel_instance: Node, layer: Layer = Layer.POPUP, config_callback: Callable = Callable() ) -> void:
```

用已实例化面板替换指定层级的面板栈。

Parameters:

| Name | Description |
|---|---|
| `panel_instance` | 面板实例。 |
| `layer` | 目标层级。 |
| `config_callback` | 入栈前的可选配置回调。 |

#### `replace_layer_instance_with_options`

- API: `public`

```gdscript
func replace_layer_instance_with_options( panel_instance: Node, layer: Layer = Layer.POPUP, options: Dictionary = {}, config_callback: Callable = Callable() ) -> void:
```

用已实例化且带策略选项的面板替换指定层级的面板栈。

Parameters:

| Name | Description |
|---|---|
| `panel_instance` | 面板实例。 |
| `layer` | 目标层级。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |
| `config_callback` | 入栈前的可选配置回调。 |

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `pop_panel`

- API: `public`

```gdscript
func pop_panel(layer: Layer = Layer.POPUP, do_free: bool = true) -> void:
```

弹出指定层级的顶部面板。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |
| `do_free` | 是否在弹出后释放面板。 |

#### `pop_to_panel`

- API: `public`

```gdscript
func pop_to_panel(panel: Node, layer: Layer = Layer.POPUP, do_free: bool = true) -> bool:
```

弹出面板直到指定面板成为栈顶。

Parameters:

| Name | Description |
|---|---|
| `panel` | 目标面板实例。 |
| `layer` | 目标层级。 |
| `do_free` | 是否释放被弹出的面板。 |

Returns: 找到目标面板并完成回退时返回 true。

#### `clear_layer`

- API: `public`

```gdscript
func clear_layer(layer: Layer) -> void:
```

清空指定层级的所有面板。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清空所有层级的所有面板。

#### `get_top_panel`

- API: `public`

```gdscript
func get_top_panel(layer: Layer = Layer.POPUP) -> Node:
```

获取指定层级的顶部面板。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

Returns: 栈顶面板；为空时返回 `null`。

#### `get_panel_stack`

- API: `public`

```gdscript
func get_panel_stack(layer: Layer = Layer.POPUP) -> Array[Node]:
```

获取指定层级当前面板栈的副本。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

Returns: 从底到顶排列的面板列表。

#### `get_stack_count`

- API: `public`

```gdscript
func get_stack_count(layer: Layer = Layer.POPUP) -> int:
```

获取指定层级当前面板数量。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

Returns: 面板数量。

#### `is_panel_open`

- API: `public`

```gdscript
func is_panel_open(panel: Node, layer: int = -1) -> bool:
```

检查面板是否已进入 UI 栈。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |
| `layer` | 指定层级；小于 0 时检查所有层级。 |

Returns: 面板已打开时返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取 UI 管理器诊断快照。

Returns: 包含各层级栈数量和栈顶名称的字典。

Schemas:

- `return`: Dictionary，包含 active、auto_hide_under、pending_async_panel_count 和 layers；layers 按 Layer 值索引，每项包含 count、top_panel 和 top_modal。

#### `get_layer_root`

- API: `public`

```gdscript
func get_layer_root(layer: Layer) -> CanvasLayer:
```

获取指定层级的 CanvasLayer。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

Returns: 对应的 `CanvasLayer` 实例。

#### `set_panel_options`

- API: `public`

```gdscript
func set_panel_options(panel: Node, options: Dictionary) -> void:
```

设置已打开面板的策略选项。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |
| `options` | 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。 |

Schemas:

- `options`: Dictionary，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `get_panel_options`

- API: `public`

```gdscript
func get_panel_options(panel: Node) -> Dictionary:
```

获取面板策略选项。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |

Returns: 策略选项副本。

Schemas:

- `return`: Dictionary，包含 mode、dismiss_on_cancel、focus_on_open、restore_focus_on_close 和 metadata。

#### `is_panel_modal`

- API: `public`

```gdscript
func is_panel_modal(panel: Node) -> bool:
```

判断面板是否按 modal 策略管理。

Parameters:

| Name | Description |
|---|---|
| `panel` | 面板实例。 |

Returns: 是 modal 面板时返回 true。

#### `has_modal_open`

- API: `public`

```gdscript
func has_modal_open(layer: int = -1) -> bool:
```

检查是否存在打开的 modal 面板。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时检查所有层级。 |

Returns: 存在 modal 面板时返回 true。

#### `has_pending_async_panel`

- API: `public`

```gdscript
func has_pending_async_panel(layer: int = -1, path: String = "") -> bool:
```

检查是否存在仍在等待资源回调的异步面板请求。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时检查所有层级。 |
| `path` | 指定面板路径；为空时不按路径过滤。 |

Returns: 存在匹配请求时返回 true。

#### `get_pending_async_panel_requests`

- API: `public`

```gdscript
func get_pending_async_panel_requests(layer: int = -1) -> Array[Dictionary]:
```

获取仍在等待资源回调的异步面板请求快照。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时返回所有层级。 |

Returns: 请求快照数组，每项包含 path、layer、operation 和 serial。

Schemas:

- `return`: Array，元素为 Dictionary，包含 path、layer、operation 和 serial。

#### `get_modal_count`

- API: `public`

```gdscript
func get_modal_count(layer: int = -1) -> int:
```

获取打开的 modal 面板数量。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时统计所有层级。 |

Returns: modal 面板数量。

#### `request_dismiss_top`

- API: `public`

```gdscript
func request_dismiss_top(layer: int = -1, reason: String = "cancel") -> bool:
```

按顶层优先顺序处理取消请求。

Parameters:

| Name | Description |
|---|---|
| `layer` | 指定层级；小于 0 时从最高层级开始查找。 |
| `reason` | 关闭原因。 |

Returns: 找到可取消面板并处理时返回 true。

#### `keep_focus_inside_top_modal`

- API: `public`

```gdscript
func keep_focus_inside_top_modal(layer: Layer = Layer.POPUP) -> bool:
```

尝试把焦点保持在指定层级栈顶 modal 面板内。

Parameters:

| Name | Description |
|---|---|
| `layer` | 目标层级。 |

Returns: 发生焦点修正时返回 true。

## GFUndoableCommand

- Path: `addons/gf/standard/command/gf_undoable_command.gd`
- Extends: `GFCommand`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFUndoableCommand: 可撤销命令的抽象基类。 继承自 GFCommand，在标准命令的基础上新增撤销能力。 子类须在 execute() 执行前通过 set_snapshot() 保存当前状态快照， 并在 undo() 中借助 get_snapshot() 取回快照以还原数据， 从而支持解谜、战棋等游戏的回放与悔步功能。

### Properties

#### `action_name`

- API: `public`

```gdscript
var action_name: String = "未命名动作"
```

在 UI 历史记录面板中显示当前命令的名称描述。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行命令逻辑。子类必须重写此方法，并建议在此处先调用 set_snapshot()。

Returns: 同步命令返回 null；异步命令可返回 Signal 供外部 await。

Schemas:

- `return`: Variant, null or Signal.

#### `undo`

- API: `public`

```gdscript
func undo() -> Variant:
```

撤销命令。子类必须重写此方法，使用 get_snapshot() 还原状态。

Returns: 同步命令返回 null；异步命令可返回 Signal 供外部 await。

Schemas:

- `return`: Variant, null or Signal.

#### `should_record`

- API: `public`

```gdscript
func should_record(_execute_result: Variant) -> bool:
```

判断 execute() 返回后是否应该写入命令历史。

Parameters:

| Name | Description |
|---|---|
| `_execute_result` | execute() 的最终返回值。 |

Returns: 返回 false 时，GFCommandHistoryUtility 不会记录该命令。

Schemas:

- `_execute_result`: Variant returned by execute().

#### `set_snapshot`

- API: `public`

```gdscript
func set_snapshot(data: Variant) -> void:
```

保存执行前的状态快照。应在 execute() 内部、修改数据之前调用。

Parameters:

| Name | Description |
|---|---|
| `data` | 任意可序列化的快照数据（如字典、数值、数组）。 |

Schemas:

- `data`: Variant snapshot value; Array and Dictionary values are deep-copied.

#### `get_snapshot`

- API: `public`

```gdscript
func get_snapshot() -> Variant:
```

获取由 set_snapshot() 保存的状态快照。在 undo() 中调用以还原数据。

Returns: 之前保存的快照数据，不存在则返回 null。

Schemas:

- `return`: Variant snapshot value or null.

## GFUuid

- Path: `addons/gf/standard/foundation/identity/gf_uuid.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.19.0`

GFUuid: 通用 UUID 生成与校验工具。 只处理 RFC 4122 形态的字符串标识，不绑定存档、分析、网络请求或编辑器资源语义。 v4 适合匿名随机标识，v7 适合需要大致按生成时间排序的标识。

### Constants

#### `BYTE_COUNT`

- API: `public`

```gdscript
const BYTE_COUNT: int = 16
```

UUID 字节长度。

#### `CANONICAL_LENGTH`

- API: `public`

```gdscript
const CANONICAL_LENGTH: int = 36
```

UUID 规范字符串长度。

### Methods

#### `generate_v4`

- API: `public`

```gdscript
static func generate_v4() -> String:
```

生成随机 UUID v4。

Returns: 小写 canonical UUID 字符串。

#### `generate_v7`

- API: `public`

```gdscript
static func generate_v7(unix_time_msec: int = -1) -> String:
```

生成时间有序 UUID v7。

Parameters:

| Name | Description |
|---|---|
| `unix_time_msec` | Unix epoch 毫秒；小于 0 时使用系统当前时间。 |

Returns: 小写 canonical UUID 字符串。

#### `is_valid`

- API: `public`

```gdscript
static func is_valid(value: String, version: int = 0) -> bool:
```

判断字符串是否为 canonical UUID。

Parameters:

| Name | Description |
|---|---|
| `value` | 待校验字符串。 |
| `version` | 可选版本过滤；0 表示接受任意版本。 |

Returns: 字符串符合 canonical UUID 形态且版本匹配时返回 true。

## GFValidationDiagnosticAdapter

- Path: `addons/gf/standard/foundation/validation/gf_validation_diagnostic_adapter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFValidationDiagnosticAdapter: 校验报告到编辑器诊断数据的适配器。 只把 `GFValidationIssue`、`GFValidationReport` 或兼容字典转换成纯 Dictionary 诊断记录，不创建 UI，也不假设具体编辑器控件，便于 Inspector、Dock、CI 和项目工具复用。

### Methods

#### `issue_to_diagnostic`

- API: `public`

```gdscript
static func issue_to_diagnostic(issue: Variant, options: Dictionary = {}) -> Dictionary:
```

将单个问题转换成诊断字典。

Parameters:

| Name | Description |
|---|---|
| `issue` | GFValidationIssue 或兼容问题字典。 |
| `options` | 可选参数，支持 use_path_as_source、include_empty_source_span。 |

Returns: 诊断字典；输入无效时返回空字典。

Schemas:

- `issue`: Variant accepting GFValidationIssue or Dictionary issue payload.
- `options`: Dictionary diagnostic conversion options.
- `return`: Dictionary editor diagnostic record.

#### `report_to_diagnostics`

- API: `public`

```gdscript
static func report_to_diagnostics(source: Variant, options: Dictionary = {}) -> Array[Dictionary]:
```

将报告、报告字典或问题数组转换成诊断数组。

Parameters:

| Name | Description |
|---|---|
| `source` | GFValidationReport、报告字典或问题数组。 |
| `options` | 可选参数，支持 source_path、include_positionless、use_path_as_source。 |

Returns: 诊断数组。

Schemas:

- `source`: Variant accepting GFValidationReport, Dictionary report payload, or Array issues.
- `options`: Dictionary diagnostic conversion options.
- `return`: Array of Dictionary editor diagnostic records.

#### `group_by_source`

- API: `public`

```gdscript
static func group_by_source(diagnostics: Array[Dictionary]) -> Dictionary:
```

按源路径分组诊断。

Parameters:

| Name | Description |
|---|---|
| `diagnostics` | 诊断数组。 |

Returns: source_path -> Array[Dictionary]。

Schemas:

- `diagnostics`: Array of Dictionary editor diagnostic records.
- `return`: Dictionary keyed by source_path with diagnostic arrays.

#### `make_line_records`

- API: `public`

```gdscript
static func make_line_records(diagnostics: Array[Dictionary], options: Dictionary = {}) -> Array[Dictionary]:
```

生成适合行号栏、问题列表或资源面板消费的行记录。

Parameters:

| Name | Description |
|---|---|
| `diagnostics` | 诊断数组。 |
| `options` | 可选参数，支持 include_positionless。 |

Returns: 行记录数组。

Schemas:

- `diagnostics`: Array of Dictionary editor diagnostic records.
- `options`: Dictionary line record conversion options.
- `return`: Array of Dictionary line records.

#### `make_display_text`

- API: `public`

```gdscript
static func make_display_text(diagnostic: Dictionary) -> String:
```

生成单条诊断的简短显示文本。

Parameters:

| Name | Description |
|---|---|
| `diagnostic` | 诊断字典。 |

Returns: 显示文本。

Schemas:

- `diagnostic`: Dictionary editor diagnostic record.

#### `make_tooltip`

- API: `public`

```gdscript
static func make_tooltip(diagnostic: Dictionary) -> String:
```

生成单条诊断的工具提示文本。

Parameters:

| Name | Description |
|---|---|
| `diagnostic` | 诊断字典。 |

Returns: 工具提示文本。

Schemas:

- `diagnostic`: Dictionary editor diagnostic record.

## GFValidationIssue

- Path: `addons/gf/standard/foundation/validation/gf_validation_issue.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFValidationIssue: 通用校验问题条目。 用于描述配置、资源、节点树、存档载荷或编辑器工具中的单个问题。它只记录 严重级别、问题类别、定位信息和附加字段，不决定项目如何展示或修复问题。

### Enums

#### `Severity`

- API: `public`

```gdscript
enum Severity { ## 信息提示，不影响健康状态。 INFO, ## 警告，报告仍可继续使用，但不再视为完全健康。 WARNING, ## 错误，报告不应视为通过。 ERROR, }
```

校验问题严重级别。

### Properties

#### `severity`

- API: `public`

```gdscript
var severity: Severity = Severity.ERROR
```

严重级别。

#### `kind`

- API: `public`

```gdscript
var kind: StringName = &""
```

通用问题类别。推荐使用稳定的 snake_case 标识。

#### `key`

- API: `public`

```gdscript
var key: Variant = null
```

可选定位键，例如行号、资源 key、节点 key 或调用方自定义标识。

Schemas:

- `key`: Variant caller-defined location key.

#### `path`

- API: `public`

```gdscript
var path: String = ""
```

可选路径，例如资源路径、节点路径或数据路径。

#### `source_path`

- API: `public`

```gdscript
var source_path: String = ""
```

可选源文件或资源路径。`source` 字典字段会作为兼容别名读取。

#### `line`

- API: `public`

```gdscript
var line: int = 0
```

可选源码起始行号，1-based；0 表示未知。

#### `column`

- API: `public`

```gdscript
var column: int = 0
```

可选源码起始列号，1-based；0 表示未知。

#### `length`

- API: `public`

```gdscript
var length: int = 0
```

可选源码范围长度；0 表示未知。

#### `end_line`

- API: `public`

```gdscript
var end_line: int = 0
```

可选源码结束行号，1-based；0 表示未知。

#### `end_column`

- API: `public`

```gdscript
var end_column: int = 0
```

可选源码结束列号，1-based；0 表示未知。

#### `preview`

- API: `public`

```gdscript
var preview: String = ""
```

可选源码预览。

#### `subject`

- API: `public`

```gdscript
var subject: String = ""
```

可选主题，用于标记问题所属对象或报告域。

#### `message`

- API: `public`

```gdscript
var message: String = ""
```

面向开发者或工具 UI 的简短说明。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary caller metadata.

#### `extra_fields`

- API: `public`

```gdscript
var extra_fields: Dictionary = {}
```

额外上下文字段。用于无损保留已有报告中的自定义字段。

Schemas:

- `extra_fields`: Dictionary caller-defined fields preserved during conversion.

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_severity: Variant, p_kind: StringName, p_message: String, p_key: Variant = null, p_path: String = "", p_metadata: Dictionary = {} ) -> RefCounted:
```

配置问题条目并返回自身，便于链式构造。

Parameters:

| Name | Description |
|---|---|
| `p_severity` | 严重级别，可传入 Severity、int 或字符串。 |
| `p_kind` | 问题类别。 |
| `p_message` | 问题说明。 |
| `p_key` | 可选定位键。 |
| `p_path` | 可选路径。 |
| `p_metadata` | 可选元数据。 |

Returns: 当前问题条目。

Schemas:

- `p_severity`: Variant Severity, int, or string.
- `p_key`: Variant caller-defined location key.
- `p_metadata`: Dictionary caller metadata.

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

从字典应用字段。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Schemas:

- `data`: Dictionary validation issue fields.

#### `to_dict`

- API: `public`

```gdscript
func to_dict(include_empty_fields: bool = false) -> Dictionary:
```

转换为字典。

Parameters:

| Name | Description |
|---|---|
| `include_empty_fields` | 为 true 时包含空的可选字段。 |

Returns: 字典副本。

Schemas:

- `return`: Dictionary validation issue fields.

#### `duplicate_issue`

- API: `public`

```gdscript
func duplicate_issue() -> RefCounted:
```

创建当前问题条目的深拷贝。

Returns: 新问题条目。

#### `set_source_span`

- API: `public`

```gdscript
func set_source_span(source_span: Variant) -> RefCounted:
```

设置源码定位范围。

Parameters:

| Name | Description |
|---|---|
| `source_span` | GFSourceSpan 或兼容字典。 |

Returns: 当前问题条目。

Schemas:

- `source_span`: Variant GFSourceSpan-like object or Dictionary.

#### `get_source_span`

- API: `public`

```gdscript
func get_source_span() -> RefCounted:
```

获取源码定位范围副本。

Returns: GFSourceSpan。

#### `has_source_position`

- API: `public`

```gdscript
func has_source_position() -> bool:
```

检查问题是否有源码行号。

Returns: 有行号时返回 true。

#### `get_location_text`

- API: `public`

```gdscript
func get_location_text() -> String:
```

获取人类可读定位文本。

Returns: 例如 `res://table.csv:4:2`。

#### `get_kind_key`

- API: `public`

```gdscript
func get_kind_key() -> String:
```

获取统计用问题类别。

Returns: 优先返回 kind，最后返回 unknown。

#### `is_error`

- API: `public`

```gdscript
func is_error() -> bool:
```

是否为错误。

Returns: 严重级别为 ERROR 时返回 true。

#### `is_warning`

- API: `public`

```gdscript
func is_warning() -> bool:
```

是否为警告。

Returns: 严重级别为 WARNING 时返回 true。

#### `is_info`

- API: `public`

```gdscript
func is_info() -> bool:
```

是否为信息。

Returns: 严重级别为 INFO 时返回 true。

#### `normalize_severity`

- API: `public`

```gdscript
static func normalize_severity(value: Variant) -> Severity:
```

将任意输入归一为 Severity。

Parameters:

| Name | Description |
|---|---|
| `value` | Severity、int 或字符串。 |

Returns: 归一后的严重级别。

Schemas:

- `value`: Variant Severity, int, string, or null.

#### `severity_to_string`

- API: `public`

```gdscript
static func severity_to_string(value: Variant) -> String:
```

将严重级别转换为稳定字符串。

Parameters:

| Name | Description |
|---|---|
| `value` | Severity、int 或字符串。 |

Returns: info、warning 或 error。

Schemas:

- `value`: Variant Severity, int, string, or null.

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> RefCounted:
```

从字典创建问题条目。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新问题条目。

Schemas:

- `data`: Dictionary validation issue fields.

## GFValidationJUnitExporter

- Path: `addons/gf/standard/foundation/validation/gf_validation_junit_exporter.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFValidationJUnitExporter: 将 GFValidationReport 导出为 JUnit XML。 该导出器只负责把通用校验报告转成 CI 友好的文本，不决定测试命名、 构建失败策略或项目修复流程。

### Methods

#### `export_report`

- API: `public`

```gdscript
static func export_report(report: GFValidationReport, options: Dictionary = {}) -> String:
```

导出单个报告。

Parameters:

| Name | Description |
|---|---|
| `report` | 校验报告。 |
| `options` | 可选参数，支持 suite_name、warnings_as_failures、include_passing_case。 |

Returns: JUnit XML 文本。

Schemas:

- `options`: Dictionary JUnit export options.

#### `export_reports`

- API: `public`

```gdscript
static func export_reports(reports: Array, options: Dictionary = {}) -> String:
```

导出多个报告。

Parameters:

| Name | Description |
|---|---|
| `reports` | 校验报告数组。 |
| `options` | 可选参数，支持 suite_name、warnings_as_failures、include_passing_case。 |

Returns: JUnit XML 文本。

Schemas:

- `reports`: Array of GFValidationReport values.
- `options`: Dictionary JUnit export options.

## GFValidationReport

- Path: `addons/gf/standard/foundation/validation/gf_validation_report.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFValidationReport: 通用校验报告数据结构。 用于聚合 `GFValidationIssue`，提供错误/警告统计、健康状态、摘要、下一步建议 和字典序列化。报告不绑定具体配置、存档、节点或编辑器业务语义。

### Properties

#### `subject`

- API: `public`

```gdscript
var subject: String = ""
```

报告主题，例如资源名、模块名或调用方自定义域。

#### `issues`

- API: `public`

```gdscript
var issues: Array[RefCounted] = []
```

问题列表。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary of caller-defined report metadata.

#### `extra_fields`

- API: `public`

```gdscript
var extra_fields: Dictionary = {}
```

额外报告字段。用于保留或附加调用方自己的统计数据。

Schemas:

- `extra_fields`: Dictionary of caller-defined serialized report fields.

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_subject: String = "", p_metadata: Dictionary = {}) -> RefCounted:
```

配置报告主题和元数据。

Parameters:

| Name | Description |
|---|---|
| `p_subject` | 报告主题。 |
| `p_metadata` | 可选元数据。 |

Returns: 当前报告。

Schemas:

- `p_metadata`: Dictionary of caller-defined report metadata.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空问题与额外字段。

#### `add_issue`

- API: `public`

```gdscript
func add_issue(issue: Variant) -> RefCounted:
```

添加一个问题。

Parameters:

| Name | Description |
|---|---|
| `issue` | GFValidationIssue 或问题字典。 |

Returns: 添加后的问题；输入无效时返回 null。

Schemas:

- `issue`: Variant accepting GFValidationIssue or Dictionary issue payload.

#### `add_info`

- API: `public`

```gdscript
func add_info( kind: StringName, message: String, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加信息问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_warning`

- API: `public`

```gdscript
func add_warning( kind: StringName, message: String, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加警告问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_error`

- API: `public`

```gdscript
func add_error( kind: StringName, message: String, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加错误问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_source_issue`

- API: `public`

```gdscript
func add_source_issue( severity: Variant, kind: StringName, message: String, source_span: Variant, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加带源码定位的问题。

Parameters:

| Name | Description |
|---|---|
| `severity` | 严重级别，可传入 Severity、int 或字符串。 |
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `source_span` | GFSourceSpan 或兼容字典。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `severity`: Variant accepting GFValidationIssue.Severity, int, String, or StringName.
- `source_span`: Variant accepting GFSourceSpan or Dictionary span payload.
- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_source_info`

- API: `public`

```gdscript
func add_source_info( kind: StringName, message: String, source_span: Variant, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加带源码定位的信息问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `source_span` | GFSourceSpan 或兼容字典。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `source_span`: Variant accepting GFSourceSpan or Dictionary span payload.
- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_source_warning`

- API: `public`

```gdscript
func add_source_warning( kind: StringName, message: String, source_span: Variant, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加带源码定位的警告问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `source_span` | GFSourceSpan 或兼容字典。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `source_span`: Variant accepting GFSourceSpan or Dictionary span payload.
- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `add_source_error`

- API: `public`

```gdscript
func add_source_error( kind: StringName, message: String, source_span: Variant, key: Variant = null, path: String = "", issue_metadata: Dictionary = {} ) -> RefCounted:
```

添加带源码定位的错误问题。

Parameters:

| Name | Description |
|---|---|
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `source_span` | GFSourceSpan 或兼容字典。 |
| `key` | 可选定位键。 |
| `path` | 可选路径。 |
| `issue_metadata` | 可选元数据。 |

Returns: 新问题。

Schemas:

- `source_span`: Variant accepting GFSourceSpan or Dictionary span payload.
- `key`: Variant caller-defined location key.
- `issue_metadata`: Dictionary of caller-defined issue metadata.

#### `merge`

- API: `public`

```gdscript
func merge(source: Variant, include_metadata: bool = true) -> RefCounted:
```

合并另一个报告或报告字典。

Parameters:

| Name | Description |
|---|---|
| `source` | GFValidationReport 或包含 issues 的字典。 |
| `include_metadata` | 为 true 时合并源报告 metadata。 |

Returns: 当前报告。

Schemas:

- `source`: Variant accepting GFValidationReport or Dictionary report payload.

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

从字典应用报告字段。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Schemas:

- `data`: Dictionary report payload.

#### `to_dict`

- API: `public`

```gdscript
func to_dict(additional_fields: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
```

转换为报告字典。

Parameters:

| Name | Description |
|---|---|
| `additional_fields` | 附加到输出中的调用方字段。 |
| `options` | 可选输出控制，支持 include_subject、include_metadata、include_info_count、include_issue_count、include_empty_issue_fields、summary_subject、next_actions、fallback_action、no_action。 |

Returns: 报告字典。

Schemas:

- `additional_fields`: Dictionary of caller-defined serialized fields.
- `options`: Dictionary controlling report serialization options.
- `return`: Dictionary serialized report payload.

#### `duplicate_report`

- API: `public`

```gdscript
func duplicate_report() -> RefCounted:
```

创建当前报告深拷贝。

Returns: 新报告。

#### `get_error_count`

- API: `public`

```gdscript
func get_error_count() -> int:
```

获取错误数量。

Returns: 错误数量。

#### `get_warning_count`

- API: `public`

```gdscript
func get_warning_count() -> int:
```

获取警告数量。

Returns: 警告数量。

#### `get_info_count`

- API: `public`

```gdscript
func get_info_count() -> int:
```

获取信息数量。

Returns: 信息数量。

#### `is_ok`

- API: `public`

```gdscript
func is_ok() -> bool:
```

检查报告是否没有错误。

Returns: 没有错误时返回 true。

#### `is_healthy`

- API: `public`

```gdscript
func is_healthy() -> bool:
```

检查报告是否完全健康。

Returns: 没有错误和警告时返回 true。

#### `get_issue_counts_by_kind`

- API: `public`

```gdscript
func get_issue_counts_by_kind() -> Dictionary:
```

按问题类别统计数量。

Returns: 类别计数字典。

Schemas:

- `return`: Dictionary keyed by issue kind with integer counts.

#### `make_summary`

- API: `public`

```gdscript
func make_summary(subject_override: String = "") -> String:
```

生成摘要文本。

Parameters:

| Name | Description |
|---|---|
| `subject_override` | 临时覆盖报告主题。 |

Returns: 摘要文本。

#### `get_next_action`

- API: `public`

```gdscript
func get_next_action( action_map: Dictionary = {}, fallback_action: String = "Review the first reported issue.", no_action: String = "No action required." ) -> String:
```

获取下一步建议。

Parameters:

| Name | Description |
|---|---|
| `action_map` | 按问题类别映射的建议文本。 |
| `fallback_action` | 存在问题但没有命中映射时返回的建议。 |
| `no_action` | 没有问题时返回的建议。 |

Returns: 建议文本。

Schemas:

- `action_map`: Dictionary keyed by issue kind with action text values.

#### `promote_warnings_to_errors`

- API: `public`

```gdscript
func promote_warnings_to_errors(kinds: PackedStringArray = PackedStringArray()) -> RefCounted:
```

将警告提升为错误。

Parameters:

| Name | Description |
|---|---|
| `kinds` | 为空时提升全部警告；否则只提升匹配类别。 |

Returns: 当前报告。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> RefCounted:
```

从字典创建报告。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新报告。

Schemas:

- `data`: Dictionary report payload.

## GFValidationReportDictionary

- Path: `addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFValidationReportDictionary: 通用校验报告字典辅助。 提供字典报告的追加、归一化、统计和严重级别提升工具，便于字典式报告 接入 `GFValidationIssue` / `GFValidationReport` 使用的标准字段。

### Methods

#### `issue_to_dict`

- API: `public`

```gdscript
static func issue_to_dict(issue: Variant, include_empty_fields: bool = false) -> Dictionary:
```

将任意问题转换为字典。

Parameters:

| Name | Description |
|---|---|
| `issue` | GFValidationIssue 或问题字典。 |
| `include_empty_fields` | 为 true 时包含空的可选字段。 |

Returns: 问题字典。

Schemas:

- `issue`: Variant accepting GFValidationIssue or Dictionary issue payload.
- `return`: Dictionary serialized issue payload.

#### `report_from_dict`

- API: `public`

```gdscript
static func report_from_dict(data: Dictionary) -> RefCounted:
```

将报告字典转换为 GFValidationReport。

Parameters:

| Name | Description |
|---|---|
| `data` | 输入字典。 |

Returns: 新报告。

Schemas:

- `data`: Dictionary report payload.

#### `append_issue`

- API: `public`

```gdscript
static func append_issue( report: Dictionary, severity: Variant, kind: StringName, message: String, fields: Dictionary = {} ) -> Dictionary:
```

向字典报告追加问题。

Parameters:

| Name | Description |
|---|---|
| `report` | 目标报告字典。 |
| `severity` | 严重级别，可传入 Severity、int 或字符串。 |
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `fields` | 附加字段，例如 key、path、row_key、metadata。 |

Returns: 追加的问题字典。

Schemas:

- `report`: Dictionary report payload mutated in place.
- `severity`: Variant accepting GFValidationIssue.Severity, int, String, or StringName.
- `fields`: Dictionary additional issue fields.
- `return`: Dictionary appended issue payload.

#### `append_source_issue`

- API: `public`

```gdscript
static func append_source_issue( report: Dictionary, severity: Variant, kind: StringName, message: String, source_span: Variant, fields: Dictionary = {} ) -> Dictionary:
```

向字典报告追加带源码定位的问题。

Parameters:

| Name | Description |
|---|---|
| `report` | 目标报告字典。 |
| `severity` | 严重级别，可传入 Severity、int 或字符串。 |
| `kind` | 问题类别。 |
| `message` | 问题说明。 |
| `source_span` | GFSourceSpan 或兼容字典。 |
| `fields` | 附加字段，例如 key、path、row_key、metadata。 |

Returns: 追加的问题字典。

Schemas:

- `report`: Dictionary report payload mutated in place.
- `severity`: Variant accepting GFValidationIssue.Severity, int, String, or StringName.
- `source_span`: Variant accepting GFSourceSpan or Dictionary span payload.
- `fields`: Dictionary additional issue fields.
- `return`: Dictionary appended issue payload.

#### `finalize_report`

- API: `public`

```gdscript
static func finalize_report( report: Dictionary, subject: String = "", options: Dictionary = {} ) -> Dictionary:
```

重新计算字典报告的统计字段。

Parameters:

| Name | Description |
|---|---|
| `report` | 目标报告字典。 |
| `subject` | 摘要主题；为空时使用 report.subject 或 Validation report。 |
| `options` | 可选控制，支持 next_actions、fallback_action、no_action、include_info_count、include_issue_count、warnings_as_errors、promote_warning_kinds。 |

Returns: 同一个报告字典。

Schemas:

- `report`: Dictionary report payload mutated in place.
- `options`: Dictionary controlling report finalization.
- `return`: Dictionary finalized report payload.

#### `make_summary`

- API: `public`

```gdscript
static func make_summary(subject: String, error_count: int, warning_count: int) -> String:
```

生成摘要文本。

Parameters:

| Name | Description |
|---|---|
| `subject` | 摘要主题。 |
| `error_count` | 错误数量。 |
| `warning_count` | 警告数量。 |

Returns: 摘要文本。

#### `get_next_action`

- API: `public`

```gdscript
static func get_next_action( report: Dictionary, action_map: Dictionary = {}, fallback_action: String = "Review the first reported issue.", no_action: String = "No action required.", options: Dictionary = {} ) -> String:
```

获取报告下一步建议。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `action_map` | 按问题类别映射的建议文本。 |
| `fallback_action` | 存在问题但未命中映射时返回的建议。 |
| `no_action` | 没有问题时返回的建议。 |
| `options` | 严重级别计算选项。 |

Returns: 建议文本。

Schemas:

- `report`: Dictionary report payload.
- `action_map`: Dictionary keyed by issue kind with action text values.
- `options`: Dictionary severity evaluation options.

#### `has_error_issues`

- API: `public`

```gdscript
static func has_error_issues(report: Dictionary, options: Dictionary = {}) -> bool:
```

检查报告是否包含错误。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `options` | 严重级别计算选项。 |

Returns: 存在错误时返回 true。

Schemas:

- `report`: Dictionary report payload.
- `options`: Dictionary severity evaluation options.

#### `make_issue_fingerprint`

- API: `public`

```gdscript
static func make_issue_fingerprint(issue: Variant, fields: PackedStringArray = PackedStringArray()) -> String:
```

生成稳定的问题指纹，用于项目工具的忽略项、基线和 CI 差异比较。

Parameters:

| Name | Description |
|---|---|
| `issue` | GFValidationIssue 或兼容问题字典。 |
| `fields` | 参与指纹计算的字段；为空时使用 severity、kind、path、source_path、key 和 message。 |

Returns: 问题指纹；输入无效时返回空字符串。

Schemas:

- `issue`: Variant accepting GFValidationIssue or Dictionary issue payload.

#### `filter_issues`

- API: `public`

```gdscript
static func filter_issues(report: Dictionary, options: Dictionary = {}) -> Dictionary:
```

返回应用忽略项和基线后的报告副本。

Parameters:

| Name | Description |
|---|---|
| `report` | 输入报告字典，不会被修改。 |
| `options` | 可选过滤设置，支持 ignored_kinds、ignored_paths、ignored_path_patterns、ignored_keys、ignored_fingerprints、baseline_fingerprints、baseline_issues、fingerprint_fields、include_filter_summary。 |

Returns: 过滤并重新 finalize 的报告副本。

Schemas:

- `report`: Dictionary report payload.
- `options`: Dictionary issue filtering options.
- `return`: Dictionary finalized report payload.

#### `promote_warnings`

- API: `public`

```gdscript
static func promote_warnings(report: Dictionary, kinds: PackedStringArray = PackedStringArray()) -> Dictionary:
```

将报告中的警告提升为错误。

Parameters:

| Name | Description |
|---|---|
| `report` | 报告字典。 |
| `kinds` | 为空时提升全部警告；否则只提升匹配类别。 |

Returns: 同一个报告字典。

Schemas:

- `report`: Dictionary report payload mutated in place.
- `return`: Dictionary report payload mutated in place.

## GFValidationRule

- Path: `addons/gf/standard/foundation/validation/gf_validation_rule.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFValidationRule: 通用校验规则资源。 通过 Callable 或子类钩子校验任意对象、资源、节点或数据。规则只负责把问题写入 GFValidationReport，不约定项目脚本方法名，也不内置业务字段语义。

### Enums

#### `TargetKind`

- API: `public`

```gdscript
enum TargetKind { ## 接受任意目标。 ANY, ## 接受 Node。 NODE, ## 接受 Resource。 RESOURCE, ## 接受 PackedScene。 PACKED_SCENE, ## 接受 Dictionary。 DICTIONARY, ## 接受 Array。 ARRAY, ## 接受 Object。 OBJECT, }
```

规则适用的目标类型。

### Properties

#### `rule_id`

- API: `public`

```gdscript
var rule_id: StringName = &""
```

规则唯一标识。推荐使用稳定的 snake_case 或点分层级标识。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

面向工具或报告的规则说明。

#### `target_kind`

- API: `public`

```gdscript
var target_kind: TargetKind = TargetKind.ANY
```

规则适用的目标类型。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用该规则。

#### `severity`

- API: `public`

```gdscript
var severity: GFValidationIssue.Severity = GFValidationIssue.Severity.ERROR
```

当 Callable 或钩子返回 false / 非空字符串时使用的默认严重级别。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary of caller-defined rule metadata.

#### `callback`

- API: `public`

```gdscript
var callback: Callable = Callable()
```

可选校验回调，签名为 func(target: Variant, report: GFValidationReport, context: Dictionary) -> Variant。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( p_rule_id: StringName, p_callback: Callable = Callable(), options: Dictionary = {} ) -> GFValidationRule:
```

配置规则并返回自身。

Parameters:

| Name | Description |
|---|---|
| `p_rule_id` | 规则标识。 |
| `p_callback` | 可选校验回调。 |
| `options` | 可选字段，支持 description、target_kind、enabled、severity、metadata。 |

Returns: 当前规则。

Schemas:

- `options`: Dictionary rule configuration overrides.

#### `applies_to`

- API: `public`

```gdscript
func applies_to(target: Variant, context: Dictionary = {}) -> bool:
```

检查规则是否适用于目标。

Parameters:

| Name | Description |
|---|---|
| `target` | 待校验目标。 |
| `context` | 调用方上下文。 |

Returns: 适用时返回 true。

Schemas:

- `target`: Variant validation target.
- `context`: Dictionary validation context.

#### `validate`

- API: `public`

```gdscript
func validate(target: Variant, context: Dictionary = {}) -> GFValidationReport:
```

执行规则并返回报告。

Parameters:

| Name | Description |
|---|---|
| `target` | 待校验目标。 |
| `context` | 调用方上下文。 |

Returns: 校验报告。

Schemas:

- `target`: Variant validation target.
- `context`: Dictionary validation context.

#### `duplicate_rule`

- API: `public`

```gdscript
func duplicate_rule() -> GFValidationRule:
```

创建当前规则的浅配置副本。

Returns: 新规则。

## GFValidationRunner

- Path: `addons/gf/standard/foundation/validation/gf_validation_runner.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFValidationRunner: 通用校验套件执行器。 执行 GFValidationSuite 中的规则，支持直接目标、资源路径和 PackedScene 实例化。 Runner 不调用项目约定方法，只把目标、路径和上下文交给显式注册的规则。

### Signals

#### `validation_started`

- API: `public`

```gdscript
signal validation_started(suite_id: StringName)
```

套件开始执行后发出。

Parameters:

| Name | Description |
|---|---|
| `suite_id` | 套件标识。 |

#### `target_validated`

- API: `public`

```gdscript
signal target_validated(target_id: String, report: GFValidationReport)
```

单个目标完成校验后发出。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标标识。 |
| `report` | 目标报告。 |

#### `validation_finished`

- API: `public`

```gdscript
signal validation_finished(report: GFValidationReport)
```

套件完成执行后发出。

Parameters:

| Name | Description |
|---|---|
| `report` | 聚合报告。 |

### Constants

#### `GFValidationSuiteBase`

- API: `public`

```gdscript
const GFValidationSuiteBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_suite.gd")
```

校验套件脚本基类。

#### `GFValidationRuleBase`

- API: `public`

```gdscript
const GFValidationRuleBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_rule.gd")
```

校验规则脚本基类。

### Properties

#### `validate_scene_instances`

- API: `public`

```gdscript
var validate_scene_instances: bool = true
```

通过路径加载 PackedScene 时是否同时实例化根节点参与 Node 规则校验。

#### `free_instantiated_scenes`

- API: `public`

```gdscript
var free_instantiated_scenes: bool = true
```

路径校验时是否释放由 Runner 实例化的场景根节点。

### Methods

#### `run_suite`

- API: `public`

```gdscript
func run_suite(suite: GFValidationSuiteBase, options: Dictionary = {}) -> GFValidationReport:
```

执行套件。

Parameters:

| Name | Description |
|---|---|
| `suite` | 校验套件。 |
| `options` | 可选参数，支持 targets、paths、context、treat_warnings_as_errors。 |

Returns: 聚合报告。

Schemas:

- `options`: Dictionary runner options with targets, paths, context, and warning policy.

#### `run_targets`

- API: `public`

```gdscript
func run_targets( targets: Array, suite: GFValidationSuiteBase = null, options: Dictionary = {} ) -> GFValidationReport:
```

校验一组直接目标。

Parameters:

| Name | Description |
|---|---|
| `targets` | 目标数组。 |
| `suite` | 可选套件；为空时使用无规则套件。 |
| `options` | 可选参数，支持 context、treat_warnings_as_errors。 |

Returns: 聚合报告。

Schemas:

- `targets`: Array of validation targets.
- `options`: Dictionary runner options with context and warning policy.

#### `run_paths`

- API: `public`

```gdscript
func run_paths( paths: PackedStringArray, suite: GFValidationSuiteBase = null, options: Dictionary = {} ) -> GFValidationReport:
```

校验一组资源或场景路径。

Parameters:

| Name | Description |
|---|---|
| `paths` | 资源或场景路径列表。 |
| `suite` | 可选套件；为空时使用无规则套件。 |
| `options` | 可选参数，支持 context、treat_warnings_as_errors。 |

Returns: 聚合报告。

Schemas:

- `options`: Dictionary runner options with context and warning policy.

## GFValidationSuite

- Path: `addons/gf/standard/foundation/validation/gf_validation_suite.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFValidationSuite: 通用校验套件资源。 保存一组规则与可选资源路径筛选条件。套件只描述“要检查什么”，实际加载、 实例化和报告聚合由 GFValidationRunner 完成。

### Constants

#### `GFValidationRuleBase`

- API: `public`

```gdscript
const GFValidationRuleBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_rule.gd")
```

校验规则脚本基类。

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认递归扫描目录深度上限。

#### `DEFAULT_MAX_COLLECTED_PATHS`

- API: `public`

```gdscript
const DEFAULT_MAX_COLLECTED_PATHS: int = 10_000
```

默认单次路径收集数量上限。

### Properties

#### `suite_id`

- API: `public`

```gdscript
var suite_id: StringName = &""
```

套件标识。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

套件说明。

#### `enabled`

- API: `public`

```gdscript
var enabled: bool = true
```

是否启用套件。

#### `treat_warnings_as_errors`

- API: `public`

```gdscript
var treat_warnings_as_errors: bool = false
```

是否把警告提升为错误。

#### `rules`

- API: `public`

```gdscript
var rules: Array[GFValidationRuleBase] = []
```

校验规则列表。

#### `include_paths`

- API: `public`

```gdscript
var include_paths: PackedStringArray = PackedStringArray()
```

需要扫描的路径。可以是文件或目录；为空时不自动扫描。

#### `exclude_paths`

- API: `public`

```gdscript
var exclude_paths: PackedStringArray = PackedStringArray()
```

需要排除的路径或通配模式。

#### `resource_extensions`

- API: `public`

```gdscript
var resource_extensions: PackedStringArray = PackedStringArray(["tres", "res"])
```

资源文件扩展名，不含点号。

#### `scene_extensions`

- API: `public`

```gdscript
var scene_extensions: PackedStringArray = PackedStringArray(["tscn", "scn"])
```

场景文件扩展名，不含点号。

#### `recursive`

- API: `public`

```gdscript
var recursive: bool = true
```

扫描目录时是否递归。

#### `include_hidden`

- API: `public`

```gdscript
var include_hidden: bool = false
```

扫描目录时是否包含隐藏目录和文件。

#### `max_scan_depth`

- API: `public`

```gdscript
var max_scan_depth: int = DEFAULT_MAX_SCAN_DEPTH:
```

递归扫描的最大目录深度。0 表示不限制。

#### `max_collected_paths`

- API: `public`

```gdscript
var max_collected_paths: int = DEFAULT_MAX_COLLECTED_PATHS:
```

单次 collect_paths() 最多收集的路径数量。0 表示不限制。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据。框架不解释该字段。

Schemas:

- `metadata`: Dictionary of caller-defined suite metadata.

### Methods

#### `add_rule`

- API: `public`

```gdscript
func add_rule(rule: GFValidationRuleBase) -> bool:
```

添加规则。

Parameters:

| Name | Description |
|---|---|
| `rule` | 规则资源。 |

Returns: 添加成功返回 true。

#### `remove_rule`

- API: `public`

```gdscript
func remove_rule(rule: GFValidationRuleBase) -> bool:
```

移除规则。

Parameters:

| Name | Description |
|---|---|
| `rule` | 规则资源。 |

Returns: 移除成功返回 true。

#### `get_enabled_rules`

- API: `public`

```gdscript
func get_enabled_rules() -> Array[GFValidationRuleBase]:
```

获取启用的规则。

Returns: 规则数组副本。

#### `matches_path`

- API: `public`

```gdscript
func matches_path(path: String) -> bool:
```

检查路径是否会被套件扫描。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源或场景路径。 |

Returns: 匹配返回 true。

#### `collect_paths`

- API: `public`

```gdscript
func collect_paths() -> PackedStringArray:
```

收集 include_paths 中匹配的资源和场景路径。

Returns: 已排序路径列表。

#### `duplicate_suite`

- API: `public`

```gdscript
func duplicate_suite() -> GFValidationSuite:
```

创建套件配置副本。

Returns: 新套件。

## GFValueIndex

- Path: `addons/gf/standard/foundation/collections/gf_value_index.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFValueIndex: 通用值索引。 为任意 item_id 关联值和字段，并支持按字段快速查询。它只维护索引结构， 不规定字段含义、业务规则或生命周期。

### Signals

#### `item_indexed`

- API: `public`

```gdscript
signal item_indexed(item_id: StringName)
```

条目写入索引后发出。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |

#### `item_removed`

- API: `public`

```gdscript
signal item_removed(item_id: StringName)
```

条目从索引移除后发出。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |

#### `cleared`

- API: `public`

```gdscript
signal cleared
```

索引清空后发出。

### Properties

#### `duplicate_values`

- API: `public`

```gdscript
var duplicate_values: bool = true
```

读取或写入值时是否复制 Dictionary / Array。

### Methods

#### `set_item`

- API: `public`

```gdscript
func set_item(item_id: StringName, value: Variant, fields: Dictionary = {}) -> bool:
```

写入或替换一个条目。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |
| `value` | 条目值。 |
| `fields` | 可索引字段，字段值可为单值、Array 或 PackedStringArray。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant item value.
- `fields`: Dictionary from field id to scalar, Array, or PackedStringArray values.

#### `remove_item`

- API: `public`

```gdscript
func remove_item(item_id: StringName) -> bool:
```

移除条目。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |

Returns: 移除成功返回 true。

#### `has_item`

- API: `public`

```gdscript
func has_item(item_id: StringName) -> bool:
```

检查条目是否存在。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |

Returns: 存在返回 true。

#### `get_item`

- API: `public`

```gdscript
func get_item(item_id: StringName, default_value: Variant = null) -> Variant:
```

获取条目值。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |
| `default_value` | 不存在时返回的默认值。 |

Returns: 条目值或默认值。

Schemas:

- `default_value`: Variant fallback value.
- `return`: Variant item value or fallback value.

#### `get_fields`

- API: `public`

```gdscript
func get_fields(item_id: StringName) -> Dictionary:
```

获取条目字段。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 条目标识。 |

Returns: 字段副本。

Schemas:

- `return`: Dictionary indexed field values.

#### `query`

- API: `public`

```gdscript
func query(field_id: StringName, field_value: Variant) -> PackedStringArray:
```

按单个字段值查询条目标识。

Parameters:

| Name | Description |
|---|---|
| `field_id` | 字段标识。 |
| `field_value` | 字段值。 |

Returns: 条目标识列表。

Schemas:

- `field_value`: Variant indexed field value.

#### `query_many`

- API: `public`

```gdscript
func query_many(criteria: Dictionary, match_all: bool = true) -> PackedStringArray:
```

按多个字段查询条目标识。

Parameters:

| Name | Description |
|---|---|
| `criteria` | 字段到值的查询条件。 |
| `match_all` | true 表示交集查询，false 表示并集查询。 |

Returns: 条目标识列表。

Schemas:

- `criteria`: Dictionary from field id to query value.

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空索引。

#### `get_item_count`

- API: `public`

```gdscript
func get_item_count() -> int:
```

获取条目数量。

Returns: 条目数量。

#### `get_index_count`

- API: `public`

```gdscript
func get_index_count() -> int:
```

获取字段索引数量。

Returns: 字段索引数量。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary with item_count, index_count, and duplicate_values.

## GFVariantData

- Path: `addons/gf/standard/foundation/variant/gf_variant_data.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFVariantData: 通用 Variant 数据复制与默认值合并。 提供不依赖 GFArchitecture 的集合复制、Resource 可选复制和默认值递归补齐。 JSON 兼容编码由 GFVariantJsonCodec 负责。

### Methods

#### `duplicate_variant`

- API: `public`

```gdscript
static func duplicate_variant(value: Variant, deep: bool = true, duplicate_resources: bool = false) -> Variant:
```

深拷贝 Dictionary 或 Array；其他 Variant 原样返回。

Parameters:

| Name | Description |
|---|---|
| `value` | 待复制的值。 |
| `deep` | 是否深拷贝集合或 Resource。 |
| `duplicate_resources` | 是否复制 Resource；默认为 false 以保留引用语义。 |

Returns: 复制后的值。

Schemas:

- `value`: Variant value to duplicate.
- `return`: Variant duplicated value.

#### `duplicate_collection`

- API: `public`

```gdscript
static func duplicate_collection(value: Variant, deep: bool = true) -> Variant:
```

深拷贝集合值；语义同 duplicate_variant()，便于集合字段调用处表达意图。

Parameters:

| Name | Description |
|---|---|
| `value` | 待复制的值。 |
| `deep` | 是否深拷贝集合。 |

Returns: 复制后的值。

Schemas:

- `value`: Variant collection value to duplicate.
- `return`: Variant duplicated collection value.

#### `deep_merge_defaults`

- API: `public`

```gdscript
static func deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> Dictionary:
```

将 defaults 中缺失的字段递归合并到 base。

Parameters:

| Name | Description |
|---|---|
| `base` | 会被原地补齐的目标字典。 |
| `defaults` | 默认值字典。 |

Returns: 已补齐的 base 字典。

Schemas:

- `base`: Dictionary target mutated in place.
- `defaults`: Dictionary default values merged into base.
- `return`: Dictionary merged base dictionary.

## GFVariantJsonCodec

- Path: `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFVariantJsonCodec: Godot Variant 的 JSON 兼容编码器。 负责在 JSON.stringify() 可编码的数据和常见 Godot Variant 类型之间往返转换。 该类不负责集合复制或默认值合并；这类数据操作由 GFVariantData 提供。

### Methods

#### `variant_to_json_compatible`

- API: `public`

```gdscript
static func variant_to_json_compatible(value: Variant, options: Dictionary = {}) -> Variant:
```

将 Variant 转为 JSON.stringify() 可安全编码的值。

Parameters:

| Name | Description |
|---|---|
| `value` | 待转换的 Variant。 |
| `options` | 可选项；encode_dictionary_keys 为 true 时会保留非字符串字典键；encode_unsafe_ints 为 false 时不标记超出 JSON 安全范围的整数。 |

Returns: JSON 兼容值；Godot 专有类型会带类型标记。

Schemas:

- `value`: Variant value to encode.
- `options`: Dictionary with encode_dictionary_keys, encode_unsafe_ints, unsupported, and circular_reference options.
- `return`: Variant made only from JSON-compatible values and typed marker dictionaries.

#### `json_compatible_to_variant`

- API: `public`

```gdscript
static func json_compatible_to_variant(value: Variant, options: Dictionary = {}) -> Variant:
```

从 variant_to_json_compatible() 生成的值恢复 Godot Variant。

Parameters:

| Name | Description |
|---|---|
| `value` | JSON.parse_string() 后的值。 |
| `options` | 可选项；decode_typed_markers 为 false 时只递归恢复集合。 |

Returns: 恢复后的 Variant。

Schemas:

- `value`: Variant parsed from JSON-compatible data.
- `options`: Dictionary with decode_typed_markers and key decoding options.
- `return`: Variant restored from JSON-compatible data.

#### `vector2_to_array`

- API: `public`

```gdscript
static func vector2_to_array(value: Vector2) -> Array[float]:
```

将 Vector2 转成 JSON 友好的数组。

Parameters:

| Name | Description |
|---|---|
| `value` | 待转换的 Vector2。 |

Returns: [x, y] 数组。

#### `array_to_vector2`

- API: `public`

```gdscript
static func array_to_vector2(value: Variant, fallback: Vector2 = Vector2.ZERO) -> Vector2:
```

从数组读取 Vector2，失败时返回 fallback。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |
| `fallback` | 转换失败时返回的值。 |

Returns: Vector2 值。

Schemas:

- `value`: Variant expected to be an Array with at least two numeric values.

#### `vector3_to_array`

- API: `public`

```gdscript
static func vector3_to_array(value: Vector3) -> Array[float]:
```

将 Vector3 转成 JSON 友好的数组。

Parameters:

| Name | Description |
|---|---|
| `value` | 待转换的 Vector3。 |

Returns: [x, y, z] 数组。

#### `array_to_vector3`

- API: `public`

```gdscript
static func array_to_vector3(value: Variant, fallback: Vector3 = Vector3.ZERO) -> Vector3:
```

从数组读取 Vector3，失败时返回 fallback。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |
| `fallback` | 转换失败时返回的值。 |

Returns: Vector3 值。

Schemas:

- `value`: Variant expected to be an Array with at least three numeric values.

#### `color_to_array`

- API: `public`

```gdscript
static func color_to_array(value: Color) -> Array[float]:
```

将 Color 转成 JSON 友好的数组。

Parameters:

| Name | Description |
|---|---|
| `value` | 待转换的 Color。 |

Returns: [r, g, b, a] 数组。

#### `array_to_color`

- API: `public`

```gdscript
static func array_to_color(value: Variant, fallback: Color = Color.WHITE) -> Color:
```

从数组读取 Color，失败时返回 fallback。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |
| `fallback` | 转换失败时返回的值。 |

Returns: Color 值。

Schemas:

- `value`: Variant expected to be an Array with at least four numeric values.

## GFViewportUtility

- Path: `addons/gf/standard/utilities/display/gf_viewport_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFViewportUtility: 通用 SubViewport 布局管理工具。 用于本地多人、调试监视器、小地图或多视角预览等场景。它只管理 Viewport 容器、相机挂载和后处理材质，不接管玩家、场景切换或输入规则。

### Signals

#### `split_screen_configured`

- API: `public`

```gdscript
signal split_screen_configured(viewports: Array)
```

分屏布局创建完成后发出。

Parameters:

| Name | Description |
|---|---|
| `viewports` | 当前 SubViewport 列表副本。 |

Schemas:

- `viewports`: Array，由分屏布局创建的 SubViewport 实例。

#### `split_screen_cleared`

- API: `public`

```gdscript
signal split_screen_cleared
```

分屏布局被清理后发出。

### Properties

#### `viewport_resolution_scale`

- API: `public`

```gdscript
var viewport_resolution_scale: float = 1.0:
```

子 viewport 渲染尺寸缩放。1 表示使用配置尺寸。

#### `default_disable_3d`

- API: `public`

```gdscript
var default_disable_3d: bool = false
```

新建 SubViewport 是否禁用 3D。

#### `default_transparent_bg`

- API: `public`

```gdscript
var default_transparent_bg: bool = false
```

新建 SubViewport 是否启用透明背景。

### Methods

#### `setup_split_screen`

- API: `public`

```gdscript
func setup_split_screen(root: Control, viewport_count: int, options: Dictionary = {}) -> Array[SubViewport]:
```

创建 1 到 4 个 SubViewport 的分屏布局。

Parameters:

| Name | Description |
|---|---|
| `root` | 承载布局的 Control。 |
| `viewport_count` | 目标 viewport 数量；小于等于 0 时只清理。 |
| `options` | 可选设置，支持 viewport_size、columns、disable_3d、transparent_bg、stretch。 |

Returns: 当前 SubViewport 列表副本。

Schemas:

- `options`: Dictionary，包含 viewport_size: Vector2i 或 Vector2、columns: int、disable_3d: bool、transparent_bg: bool 和 stretch: bool。

#### `clear_split_screen`

- API: `public`

```gdscript
func clear_split_screen(free_cameras: bool = false) -> void:
```

清理当前分屏布局。

Parameters:

| Name | Description |
|---|---|
| `free_cameras` | 是否连同已挂载相机一起释放。 |

#### `get_viewport_count`

- API: `public`

```gdscript
func get_viewport_count() -> int:
```

获取当前 SubViewport 数量。

Returns: viewport 数量。

#### `get_viewports`

- API: `public`

```gdscript
func get_viewports() -> Array[SubViewport]:
```

获取当前 SubViewport 列表副本。

Returns: viewport 列表。

#### `get_viewport`

- API: `public`

```gdscript
func get_viewport(index: int) -> SubViewport:
```

获取指定索引的 SubViewport。

Parameters:

| Name | Description |
|---|---|
| `index` | viewport 索引。 |

Returns: SubViewport；不存在时返回 null。

#### `get_container`

- API: `public`

```gdscript
func get_container(index: int) -> SubViewportContainer:
```

获取指定索引的 SubViewportContainer。

Parameters:

| Name | Description |
|---|---|
| `index` | viewport 索引。 |

Returns: SubViewportContainer；不存在时返回 null。

#### `set_viewport_camera`

- API: `public`

```gdscript
func set_viewport_camera(index: int, camera: Node) -> bool:
```

将相机挂载到指定 SubViewport。

Parameters:

| Name | Description |
|---|---|
| `index` | viewport 索引。 |
| `camera` | Camera2D 或 Camera3D 节点。 |

Returns: 挂载成功返回 true。

#### `set_postprocess_material`

- API: `public`

```gdscript
func set_postprocess_material(index: int, material: Material) -> bool:
```

设置指定 SubViewportContainer 的后处理材质。

Parameters:

| Name | Description |
|---|---|
| `index` | viewport 索引。 |
| `material` | 材质；传 null 可清除。 |

Returns: 设置成功返回 true。

#### `screen_to_world_ray_3d`

- API: `public`

```gdscript
func screen_to_world_ray_3d( camera: Camera3D, screen_position: Vector2, length: float = 1000.0 ) -> Dictionary:
```

从屏幕/Viewport 坐标构建 3D 射线。

Parameters:

| Name | Description |
|---|---|
| `camera` | 用于投射的 Camera3D。 |
| `screen_position` | Viewport 内的屏幕坐标。 |
| `length` | 射线长度。 |

Returns: 包含 ok、origin、direction、end 的字典。

Schemas:

- `return`: Dictionary，包含 ok: bool、origin: Vector3、direction: Vector3 和 end: Vector3。

#### `raycast_from_screen_3d`

- API: `public`

```gdscript
func raycast_from_screen_3d( camera: Camera3D, screen_position: Vector2, collision_mask: int = 0xffffffff, length: float = 1000.0, exclude: Array[RID] = [] ) -> Dictionary:
```

从屏幕/Viewport 坐标执行 3D 射线检测。

Parameters:

| Name | Description |
|---|---|
| `camera` | 用于投射的 Camera3D。 |
| `screen_position` | Viewport 内的屏幕坐标。 |
| `collision_mask` | 物理碰撞层掩码。 |
| `length` | 射线长度。 |
| `exclude` | 要排除的 RID 列表。 |

Returns: 包含射线信息、hit 标记和 result 的字典。

Schemas:

- `return`: Dictionary，包含物理射线检测得到的 ok、origin、direction、end、hit 和 result。

#### `world_to_screen_3d`

- API: `public`

```gdscript
func world_to_screen_3d(camera: Camera3D, world_position: Vector3) -> Vector2:
```

将 3D 世界坐标转换为屏幕/Viewport 坐标。

Parameters:

| Name | Description |
|---|---|
| `camera` | 用于投影的 Camera3D。 |
| `world_position` | 3D 世界坐标。 |

Returns: 屏幕坐标；camera 无效时返回 INF 坐标。

#### `world_to_screen_2d`

- API: `public`

```gdscript
func world_to_screen_2d(canvas_item: CanvasItem, world_position: Vector2) -> Vector2:
```

将 CanvasItem 所在世界坐标转换为屏幕/Viewport 坐标。

Parameters:

| Name | Description |
|---|---|
| `canvas_item` | 参考 CanvasItem。 |
| `world_position` | 2D 世界坐标。 |

Returns: 屏幕坐标。

#### `screen_to_world_2d`

- API: `public`

```gdscript
func screen_to_world_2d(canvas_item: CanvasItem, screen_position: Vector2) -> Vector2:
```

将屏幕/Viewport 坐标转换为 CanvasItem 所在世界坐标。

Parameters:

| Name | Description |
|---|---|
| `canvas_item` | 参考 CanvasItem。 |
| `screen_position` | 屏幕坐标。 |

Returns: 2D 世界坐标。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary，包含 viewport_count、container_count、has_root、has_grid 和 resolution_scale。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float) -> void:
```

驱动布局生命周期清理。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 本帧时间增量。 |

## GFVirtualInputSource

- Path: `addons/gf/standard/input/sources/gf_virtual_input_source.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_handle`
- Since: `3.17.0`

GFVirtualInputSource: 可编程虚拟输入源。 用于测试、回放、AI 控制或项目自定义输入桥接，向 GFInputMappingUtility 注入抽象动作值；它不读取 InputMap，也不规定具体设备或玩法语义。

### Properties

#### `source_id`

- API: `public`

```gdscript
var source_id: StringName = &"virtual"
```

虚拟输入源标识。

#### `player_index`

- API: `public`

```gdscript
var player_index: int = -1
```

玩家索引；小于 0 时只写入全局动作状态。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( input_mapping: GFInputMappingUtility, p_source_id: StringName = &"virtual", p_player_index: int = -1 ) -> GFVirtualInputSource:
```

配置虚拟输入源。

Parameters:

| Name | Description |
|---|---|
| `input_mapping` | 输入映射工具。 |
| `p_source_id` | 虚拟输入源标识。 |
| `p_player_index` | 玩家索引。 |

Returns: 当前输入源。

#### `set_action_value`

- API: `public`

```gdscript
func set_action_value(action_id: StringName, value: Variant) -> bool:
```

写入动作值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 动作值。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant，GFInputMappingUtility 接受的动作值，通常为 bool、float、Vector2 或 Vector3。

#### `set_action_value_for_player`

- API: `public`

```gdscript
func set_action_value_for_player(action_id: StringName, value: Variant, next_player_index: int) -> bool:
```

为指定玩家写入动作值。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 动作值。 |
| `next_player_index` | 玩家索引。 |

Returns: 写入成功返回 true。

Schemas:

- `value`: Variant，GFInputMappingUtility 接受的动作值，通常为 bool、float、Vector2 或 Vector3。

#### `press`

- API: `public`

```gdscript
func press(action_id: StringName, strength: float = 1.0) -> bool:
```

按下布尔动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `strength` | 输入强度。 |

Returns: 写入成功返回 true。

#### `release`

- API: `public`

```gdscript
func release(action_id: StringName) -> bool:
```

释放动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 写入成功返回 true。

#### `set_axis_1d`

- API: `public`

```gdscript
func set_axis_1d(action_id: StringName, value: float) -> bool:
```

写入一维轴动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 一维轴值。 |

Returns: 写入成功返回 true。

#### `set_axis_2d`

- API: `public`

```gdscript
func set_axis_2d(action_id: StringName, value: Vector2) -> bool:
```

写入二维轴动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 二维轴值。 |

Returns: 写入成功返回 true。

#### `set_axis_3d`

- API: `public`

```gdscript
func set_axis_3d(action_id: StringName, value: Vector3) -> bool:
```

写入三维轴动作。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `value` | 三维轴值。 |

Returns: 写入成功返回 true。

#### `clear_action`

- API: `public`

```gdscript
func clear_action(action_id: StringName) -> bool:
```

清除指定动作贡献。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |

Returns: 清除成功返回 true。

#### `clear_action_for_player`

- API: `public`

```gdscript
func clear_action_for_player(action_id: StringName, next_player_index: int) -> bool:
```

清除指定玩家的动作贡献。

Parameters:

| Name | Description |
|---|---|
| `action_id` | 动作标识。 |
| `next_player_index` | 玩家索引。 |

Returns: 清除成功返回 true。

#### `clear_all`

- API: `public`

```gdscript
func clear_all() -> void:
```

清除当前虚拟源的所有动作贡献。

#### `get_snapshot`

- API: `public`

```gdscript
func get_snapshot() -> Dictionary:
```

获取当前虚拟源快照。

Returns: 快照字典。

Schemas:

- `return`: Dictionary，包含 source_id: StringName、player_index: int，以及当前虚拟输入贡献的 actions: Array[Dictionary]。

## GFWaitSequenceStep

- Path: `addons/gf/standard/sequence/gf_wait_sequence_step.gd`
- Extends: `GFSequenceStep`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFWaitSequenceStep: 通用等待步骤。 用于在 `GFCommandSequence` 中插入时间间隔。

### Properties

#### `duration`

- API: `public`

```gdscript
var duration: float = 0.0
```

等待时长，单位秒。

#### `respect_engine_time_scale`

- API: `public`

```gdscript
var respect_engine_time_scale: bool = true
```

是否受 Engine.time_scale 影响。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute(_context: GFSequenceContext) -> Variant:
```

执行等待步骤。

Parameters:

| Name | Description |
|---|---|
| `_context` | 序列上下文。 |

Returns: 等待用 Signal，时长小于等于 0 时返回 null。

Schemas:

- `return`: Variant, null or Signal.

## GFWeightedEntry

- Path: `addons/gf/standard/foundation/math/gf_weighted_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFWeightedEntry: 权重表中的单个候选项。 只保存值、权重和可选元数据，不约束 value 的业务类型。

### Properties

#### `value`

- API: `public`

```gdscript
var value: Variant = null
```

被选择后返回的值。

Schemas:

- `value`: Variant selected value owned by project code.

#### `weight`

- API: `public`

```gdscript
var weight: float = 1.0
```

权重；小于等于 0 的条目不会被选择。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目层可选元数据，框架不解释其含义。

Schemas:

- `metadata`: Dictionary extension metadata for the weighted entry.

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(p_value: Variant, p_weight: float = 1.0, p_metadata: Dictionary = {}) -> GFWeightedEntry:
```

配置条目内容。

Parameters:

| Name | Description |
|---|---|
| `p_value` | 被选择后返回的值。 |
| `p_weight` | 权重；小于等于 0 表示不可被选择。 |
| `p_metadata` | 可选元数据。 |

Returns: 当前条目。

Schemas:

- `p_value`: Variant selected value owned by project code.
- `p_metadata`: Dictionary extension metadata for the weighted entry.

#### `is_selectable`

- API: `public`

```gdscript
func is_selectable() -> bool:
```

判断该条目当前是否可被选择。

Returns: 权重大于 0 时返回 true。

#### `duplicate_entry`

- API: `public`

```gdscript
func duplicate_entry(deep: bool = true) -> GFWeightedEntry:
```

复制当前条目。

Parameters:

| Name | Description |
|---|---|
| `deep` | 是否深拷贝元数据。 |

Returns: 新条目实例。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

导出为通用字典。

Returns: 包含 `value`、`weight` 与 `metadata` 的字典。

Schemas:

- `return`: Dictionary serialized weighted entry.

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFWeightedEntry:
```

从通用字典创建条目。

Parameters:

| Name | Description |
|---|---|
| `data` | 包含 `value`、`weight` 与 `metadata` 的字典。 |

Returns: 新条目实例。

Schemas:

- `data`: Dictionary serialized weighted entry.

## GFWeightedTable

- Path: `addons/gf/standard/foundation/math/gf_weighted_table.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFWeightedTable: 通用权重选择表。 适合需要“按权重从候选集合中选择值”的纯算法场景。 该类只处理权重和随机源，不绑定掉落、奖励、AI 等业务语义。

### Properties

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFWeightedEntry] = []
```

候选条目列表。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

没有可选条目时返回的默认值。

Schemas:

- `default_value`: Variant fallback value returned when no entry can be selected.

#### `deterministic_seed`

- API: `public`

```gdscript
var deterministic_seed: int = 0
```

可选确定性种子；为 0 时使用随机化种子。

### Methods

#### `add_entry`

- API: `public`

```gdscript
func add_entry(value: Variant, weight: float = 1.0, metadata: Dictionary = {}) -> GFWeightedEntry:
```

追加一个候选条目。

Parameters:

| Name | Description |
|---|---|
| `value` | 被选择后返回的值。 |
| `weight` | 权重；小于等于 0 的条目会保留但不会被选择。 |
| `metadata` | 可选元数据。 |

Returns: 新增的条目实例。

Schemas:

- `value`: Variant selected value owned by project code.
- `metadata`: Dictionary extension metadata for the new weighted entry.

#### `add_weighted_entry`

- API: `public`

```gdscript
func add_weighted_entry(entry: GFWeightedEntry) -> bool:
```

追加已有候选条目。

Parameters:

| Name | Description |
|---|---|
| `entry` | 要追加的条目。 |

Returns: 添加成功时返回 true。

#### `remove_entry`

- API: `public`

```gdscript
func remove_entry(entry: GFWeightedEntry) -> bool:
```

移除候选条目。

Parameters:

| Name | Description |
|---|---|
| `entry` | 要移除的条目。 |

Returns: 找到并移除时返回 true。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空候选条目。

#### `get_selectable_entries`

- API: `public`

```gdscript
func get_selectable_entries() -> Array[GFWeightedEntry]:
```

获取当前可被选择的条目。

Returns: 权重大于 0 的条目数组。

#### `get_total_weight`

- API: `public`

```gdscript
func get_total_weight() -> float:
```

计算当前总权重。

Returns: 所有可选条目的权重总和。

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

判断当前是否没有可选条目。

Returns: 没有可选条目时返回 true。

#### `pick_entry`

- API: `public`

```gdscript
func pick_entry(rng: RandomNumberGenerator = null) -> GFWeightedEntry:
```

按权重选择一个条目。

Parameters:

| Name | Description |
|---|---|
| `rng` | 可选随机源；传入同一种子可获得可复现结果。 |

Returns: 选中的条目；没有可选条目时返回 null。

#### `pick_value`

- API: `public`

```gdscript
func pick_value(rng: RandomNumberGenerator = null) -> Variant:
```

按权重选择一个值。

Parameters:

| Name | Description |
|---|---|
| `rng` | 可选随机源；传入同一种子可获得可复现结果。 |

Returns: 选中条目的 value；没有可选条目时返回 default_value。

Schemas:

- `return`: Variant selected value or default_value.

#### `pick_many`

- API: `public`

```gdscript
func pick_many( count: int, rng: RandomNumberGenerator = null, allow_repeats: bool = true ) -> Array[Variant]:
```

按权重选择多个值。

Parameters:

| Name | Description |
|---|---|
| `count` | 选择次数。 |
| `rng` | 可选随机源；传入同一种子可获得可复现结果。 |
| `allow_repeats` | 是否允许同一条目被重复选择。 |

Returns: 选中的 value 数组。

Schemas:

- `return`: Array selected values.

#### `duplicate_table`

- API: `public`

```gdscript
func duplicate_table(deep: bool = true) -> GFWeightedTable:
```

复制当前权重表。

Parameters:

| Name | Description |
|---|---|
| `deep` | 是否深拷贝条目和元数据。 |

Returns: 新权重表实例。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

导出为通用字典。

Returns: 包含条目、默认值和确定性种子的字典。

Schemas:

- `return`: Dictionary serialized weighted table.

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

使用通用字典覆盖当前权重表。

Parameters:

| Name | Description |
|---|---|
| `data` | 包含 `entries`、`default_value` 与 `deterministic_seed` 的字典。 |

Schemas:

- `data`: Dictionary serialized weighted table.

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFWeightedTable:
```

从通用字典创建权重表。

Parameters:

| Name | Description |
|---|---|
| `data` | 包含 `entries`、`default_value` 与 `deterministic_seed` 的字典。 |

Returns: 新权重表实例。

Schemas:

- `data`: Dictionary serialized weighted table.

