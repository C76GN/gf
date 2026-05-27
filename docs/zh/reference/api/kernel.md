# Kernel API

Module: `kernel`

## Classes

- [`GFAccessGenerator`](#gfaccessgenerator)
- [`GFArchitecture`](#gfarchitecture)
- [`GFBindBuilder`](#gfbindbuilder)
- [`GFBindableProperty`](#gfbindableproperty)
- [`GFBinder`](#gfbinder)
- [`GFBindingLifetimes`](#gfbindinglifetimes)
- [`GFCommand`](#gfcommand)
- [`GFComputedProperty`](#gfcomputedproperty)
- [`GFConfig`](#gfconfig)
- [`GFConfigAccessGenerator`](#gfconfigaccessgenerator)
- [`GFController`](#gfcontroller)
- [`GFEditorActionDefinition`](#gfeditoractiondefinition)
- [`GFEditorCommand`](#gfeditorcommand)
- [`GFEditorPickOperation`](#gfeditorpickoperation)
- [`GFEditorTool`](#gfeditortool)
- [`GFEditorToolContext`](#gfeditortoolcontext)
- [`GFEditorToolOption`](#gfeditortooloption)
- [`GFEditorToolOptionSchema`](#gfeditortooloptionschema)
- [`GFEditorTypeIndex`](#gfeditortypeindex)
- [`GFEditorValueField`](#gfeditorvaluefield)
- [`GFExtensionCatalog`](#gfextensioncatalog)
- [`GFExtensionManifest`](#gfextensionmanifest)
- [`GFExtensionSettings`](#gfextensionsettings)
- [`GFExtensionUsageAudit`](#gfextensionusageaudit)
- [`GFInstaller`](#gfinstaller)
- [`GFModel`](#gfmodel)
- [`GFNodeContext`](#gfnodecontext)
- [`GFObjectPropertyTools`](#gfobjectpropertytools)
- [`GFPayload`](#gfpayload)
- [`GFQuery`](#gfquery)
- [`GFReactiveEffect`](#gfreactiveeffect)
- [`GFReadOnlyBindableProperty`](#gfreadonlybindableproperty)
- [`GFResourceTableEditor`](#gfresourcetableeditor)
- [`GFRule`](#gfrule)
- [`GFSceneSignalAudit`](#gfscenesignalaudit)
- [`GFSourceBuilder`](#gfsourcebuilder)
- [`GFSystem`](#gfsystem)
- [`GFThumbnailRenderer`](#gfthumbnailrenderer)
- [`GFTimeProvider`](#gftimeprovider)
- [`GFTypeEventSystem`](#gftypeeventsystem)
- [`GFUtility`](#gfutility)

## GFAccessGenerator

- Path: `addons/gf/kernel/editor/gf_access_generator.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFAccessGenerator: 生成强类型 GF 访问器脚本。 生成结果用于减少 `Gf.get_model(Type) as Type` 这类重复样板， 并为 Model / System / Utility / Command / Query 提供稳定的 IDE 补全入口。

### Enums

#### `TargetKind`

- API: `public`

```gdscript
enum TargetKind { ## Model 访问器目标。 MODEL, ## System 访问器目标。 SYSTEM, ## Utility 访问器目标。 UTILITY, ## Command 访问器目标。 COMMAND, ## Query 访问器目标。 QUERY, ## Capability 访问器目标。 CAPABILITY, }
```

访问器目标类型。

### Constants

#### `DEFAULT_OUTPUT_PATH`

- API: `public`

```gdscript
const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_access.gd"
```

默认强类型访问器输出路径。

#### `DEFAULT_PROJECT_OUTPUT_PATH`

- API: `public`

```gdscript
const DEFAULT_PROJECT_OUTPUT_PATH: String = "res://gf/generated/gf_project_access.gd"
```

默认项目常量访问器输出路径。

### Methods

#### `generate`

- API: `public`

```gdscript
func generate(output_path: String = DEFAULT_OUTPUT_PATH, overwrite_existing: bool = true) -> Error:
```

扫描项目 class_name 脚本并生成访问器。

Parameters:

| Name | Description |
|---|---|
| `output_path` | 生成文件输出路径。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |

Returns: 写入结果错误码。

#### `generate_project_access`

- API: `public`

```gdscript
func generate_project_access(output_path: String = DEFAULT_PROJECT_OUTPUT_PATH, overwrite_existing: bool = true) -> Error:
```

生成项目常量访问器。

Parameters:

| Name | Description |
|---|---|
| `output_path` | 生成文件输出路径。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |

Returns: 写入结果错误码。

#### `collect_records`

- API: `public`

```gdscript
func collect_records() -> Array[Dictionary]:
```

收集当前项目中可生成访问器的 GF 类型记录。

Returns: 类型记录列表。

Schemas:

- `return`: Array of Dictionary type records with class_name, path, script, kind, and access metadata.

#### `collect_project_records`

- API: `public`

```gdscript
func collect_project_records() -> Dictionary:
```

收集项目层常量记录，包括命名层、InputMap 动作和 GF ProjectSettings。

Returns: 项目常量记录。

Schemas:

- `return`: Dictionary with layers, input_actions, and settings arrays.

#### `build_source`

- API: `public`

```gdscript
func build_source(records: Array) -> String:
```

根据记录生成访问器源码。测试可直接调用该方法验证输出。

Parameters:

| Name | Description |
|---|---|
| `records` | 生成访问器时使用的类型记录列表。 |

Returns: GDScript 源码。

Schemas:

- `records`: Array of Dictionary type records containing class_name, path, and kind.

#### `build_project_source`

- API: `public`

```gdscript
func build_project_source(records: Dictionary) -> String:
```

根据项目常量记录生成访问器源码。

Parameters:

| Name | Description |
|---|---|
| `records` | 生成访问器时使用的类型记录列表。 |

Returns: GDScript 源码。

Schemas:

- `records`: Dictionary with layers, input_actions, and settings arrays.

#### `save_source`

- API: `public`

```gdscript
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
```

保存生成源码到指定路径。

Parameters:

| Name | Description |
|---|---|
| `output_path` | 生成文件输出路径。 |
| `source` | 源对象或资源。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |

Returns: 写入结果错误码。

## GFArchitecture

- Path: `addons/gf/kernel/core/gf_architecture.gd`
- Extends: `Object`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFArchitecture: 管理 Model、System 和 Utility 的注册与生命周期的容器。 生命周期遵循三阶段初始化协议： 阶段一 (init)       ：所有模块执行自身内部变量初始化。 阶段二 (async_init) ：所有模块串行执行异步初始化（可使用 await）。 阶段三 (ready)      ：所有模块均已完成 init，可安全进行跨模块依赖获取。

### Signals

#### `initialization_finished`

- API: `public`

```gdscript
signal initialization_finished
```

当一次初始化流程完成或被 dispose() 中断后发出。

#### `initialization_failed`

- API: `public`

```gdscript
signal initialization_failed(reason: String)
```

当一次初始化流程因为框架级保护失败后发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 初始化失败原因。 |

#### `project_installers_finished`

- API: `public`

```gdscript
signal project_installers_finished
```

当项目级 Installer 应用完成或被 dispose() 中断后发出。

### Constants

#### `HOOK_GET_REQUIRED_DEPENDENCIES`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_DEPENDENCIES: StringName = &"get_required_dependencies"
```

声明式依赖聚合 Hook 名称。

#### `HOOK_GET_REQUIRED_MODELS`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_MODELS: StringName = &"get_required_models"
```

声明式 Model 依赖 Hook 名称。

#### `HOOK_GET_REQUIRED_SYSTEMS`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_SYSTEMS: StringName = &"get_required_systems"
```

声明式 System 依赖 Hook 名称。

#### `HOOK_GET_REQUIRED_UTILITIES`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_UTILITIES: StringName = &"get_required_utilities"
```

声明式 Utility 依赖 Hook 名称。

#### `HOOK_GET_REQUIRED_FACTORIES`

- API: `public`

```gdscript
const HOOK_GET_REQUIRED_FACTORIES: StringName = &"get_required_factories"
```

声明式工厂依赖 Hook 名称。

### Properties

#### `module_async_init_timeout_seconds`

- API: `public`

```gdscript
var module_async_init_timeout_seconds: float = 0.0:
```

单个模块 async_init() 的最长等待时间。小于等于 0 时不启用超时。 默认关闭；项目可按自身加载预算显式启用。

#### `module_lifecycle_max_stage_passes`

- API: `public`

```gdscript
var module_lifecycle_max_stage_passes: int = 256:
```

单个生命周期阶段最多扫描模块注册表的次数，避免模块在生命周期中无限注册新模块。

#### `strict_dependency_lookup`

- API: `public`

```gdscript
var strict_dependency_lookup: bool = false
```

严格依赖查询模式。开启后本架构查询不到本地模块时不会回退父级架构。

#### `last_initialization_error`

- API: `public`

```gdscript
var last_initialization_error: String = ""
```

最近一次初始化失败原因；没有失败时为空字符串。

### Methods

#### `is_inited`

- API: `public`

```gdscript
func is_inited() -> bool:
```

检查架构是否已初始化。

Returns: 已初始化返回 true，否则返回 false。

#### `has_initialization_failed`

- API: `public`

```gdscript
func has_initialization_failed() -> bool:
```

检查最近一次初始化是否因为框架级保护失败。

Returns: 最近一次初始化失败返回 true。

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查当前架构生命周期是否仍处于可安全继续异步写回的活动状态。

Returns: 正在初始化或已完成初始化，且未被 dispose() 或失败保护中断时返回 true。

#### `is_module_ready`

- API: `public`

```gdscript
func is_module_ready(instance: Object) -> bool:
```

检查指定模块实例是否已经完成 ready 阶段。

Parameters:

| Name | Description |
|---|---|
| `instance` | 由当前架构注册的模块实例。 |

Returns: 模块完成 ready 阶段时返回 true。

#### `fail_initialization`

- API: `public`

```gdscript
func fail_initialization(reason: String) -> void:
```

将当前架构标记为初始化失败，并唤醒等待初始化或 Installer 的调用方。

Parameters:

| Name | Description |
|---|---|
| `reason` | 初始化失败原因。 |

#### `get_parent_architecture`

- API: `public`

```gdscript
func get_parent_architecture() -> GFArchitecture:
```

获取父级架构。Scoped 架构会在本地未找到依赖时回退到父级架构查询。

Returns: 父级架构实例；未设置时返回 null。

#### `set_parent_architecture`

- API: `public`

```gdscript
func set_parent_architecture(parent_architecture: GFArchitecture) -> void:
```

设置父级架构。不会接管父级生命周期。

Parameters:

| Name | Description |
|---|---|
| `parent_architecture` | 要作为依赖回退来源的父级架构。 |

#### `has_project_installers_applied`

- API: `public`

```gdscript
func has_project_installers_applied() -> bool:
```

检查项目级 Installer 是否已经应用到当前架构。

Returns: 已应用返回 true。

#### `is_project_installers_running`

- API: `public`

```gdscript
func is_project_installers_running() -> bool:
```

检查项目级 Installer 是否正在应用。

Returns: 正在应用返回 true。

#### `begin_project_installers`

- API: `public`

```gdscript
func begin_project_installers() -> bool:
```

标记项目级 Installer 已开始应用。

Returns: 成功开始返回 true；已经完成或正在运行时返回 false。

#### `mark_project_installers_applied`

- API: `public`

```gdscript
func mark_project_installers_applied() -> void:
```

标记项目级 Installer 已应用。由 Gf 启动入口调用。

#### `finish_project_installers`

- API: `public`

```gdscript
func finish_project_installers() -> void:
```

标记项目级 Installer 应用完成并唤醒等待方。

#### `create_binder`

- API: `public`

```gdscript
func create_binder() -> Variant:
```

创建一个声明式装配器，便于 Installer 使用 fluent API 注册模块与工厂。

Returns: 绑定到当前架构的装配器。

Schemas:

- `return`: GFBindBuilder-compatible binder owned by this architecture.

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

初始化架构及所有注册的组件（三阶段）。 阶段一：调用所有模块的 init()，用于初始化自身内部变量。 阶段二：串行 await 所有模块的 async_init()，用于异步资源加载等操作。 阶段三：调用所有模块的 ready()，此时跨模块依赖获取是安全的。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁架构及所有注册的组件。

#### `tick`

- API: `public`

```gdscript
func tick(delta: float) -> void:
```

驱动所有参与 tick 的 System 与 Utility 的每帧更新。 在架构初始化完成后方可生效。 若已注册 GFTimeProvider，则自动将 delta 经过时间缩放/暂停处理后再传递给参与 tick 的模块。 设置了 ignore_pause 的模块在暂停时将接收原始 delta。 设置了 ignore_time_scale 的模块在未暂停时将跳过 time_scale。

Parameters:

| Name | Description |
|---|---|
| `delta` | 距上一帧的时间（秒）。 |

#### `physics_tick`

- API: `public`

```gdscript
func physics_tick(delta: float) -> void:
```

驱动所有参与 physics_tick 的 System 与 Utility 的每物理帧更新。 在架构初始化完成后方可生效。 若已注册 GFTimeProvider，则自动将 delta 经过时间缩放/暂停处理后再传递给参与 physics_tick 的模块。 设置了 ignore_pause 的模块在暂停时将接收原始 delta。 设置了 ignore_time_scale 的模块在未暂停时将跳过 time_scale。

Parameters:

| Name | Description |
|---|---|
| `delta` | 距上一物理帧的时间（秒）。 |

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

执行命令实例。支持 await：'await send_command(MyCommand.new())'。 command 缺少 execute() 方法时会输出 warning 并返回 null。

Parameters:

| Name | Description |
|---|---|
| `command` | 要执行的命令实例。 |

Returns: 命令 execute() 的返回值；空对象或缺少 execute() 时返回 null。

Schemas:

- `return`: Variant command result returned by command.execute().

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

执行查询实例并返回结果。 query 缺少 execute() 方法时会输出 warning 并返回 null。

Parameters:

| Name | Description |
|---|---|
| `query` | 要执行的查询实例。 |

Returns: 查询 execute() 的返回值；空对象或缺少 execute() 时返回 null。

Schemas:

- `return`: Variant query result returned by query.execute().

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

通过事件系统发送类型事件实例。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, on_event: Callable, priority: int = 0) -> void:
```

为脚本类型注册事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要监听的脚本类型。 |
| `on_event` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `register_event_owned`

- API: `public`

```gdscript
func register_event_owned(owner: Object, event_type: Script, on_event: Callable, priority: int = 0) -> void:
```

为脚本类型注册带拥有者的事件监听器。 拥有者注销或释放后，可通过 unregister_owner_events() 一次性清理相关监听。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_type` | 要监听的脚本类型。 |
| `on_event` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `register_assignable_event`

- API: `public`

```gdscript
func register_assignable_event(base_event_type: Script, on_event: Callable, priority: int = 0) -> void:
```

为脚本类型注册可赋值事件监听器。 监听基类事件时，也会收到继承自该脚本类型的事件实例。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 要监听的基类脚本类型。 |
| `on_event` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `register_assignable_event_owned`

- API: `public`

```gdscript
func register_assignable_event_owned( owner: Object, base_event_type: Script, on_event: Callable, priority: int = 0 ) -> void:
```

为脚本类型注册带拥有者的可赋值事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `base_event_type` | 要监听的基类脚本类型。 |
| `on_event` | 回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |

#### `unregister_event`

- API: `public`

```gdscript
func unregister_event(event_type: Script, on_event: Callable) -> void:
```

为脚本类型注销事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `on_event` | 要移除的回调函数。 |

#### `unregister_assignable_event`

- API: `public`

```gdscript
func unregister_assignable_event(base_event_type: Script, on_event: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `on_event` | 要移除的回调函数。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, on_event: Callable) -> void:
```

注册轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `on_event` | 回调函数，签名为 func(payload: Variant)。 |

#### `register_simple_event_owned`

- API: `public`

```gdscript
func register_simple_event_owned(owner: Object, event_id: StringName, on_event: Callable) -> void:
```

注册带拥有者的轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听器拥有者。 |
| `event_id` | StringName 事件标识符。 |
| `on_event` | 回调函数，签名为 func(payload: Variant)。 |

#### `unregister_simple_event`

- API: `public`

```gdscript
func unregister_simple_event(event_id: StringName, on_event: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `on_event` | 要移除的回调函数。 |

#### `unregister_owner_events`

- API: `public`

```gdscript
func unregister_owner_events(owner: Object) -> void:
```

注销某个拥有者注册过的所有事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 要清理监听器的拥有者。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload`: Variant payload passed unchanged to simple event listeners.

#### `get_event_debug_stats`

- API: `public`

```gdscript
func get_event_debug_stats() -> Dictionary:
```

获取事件系统诊断统计。

Returns: 包含各事件轨道监听数量与 pending 操作数量的字典。

Schemas:

- `return`: Dictionary produced by GFTypeEventSystem.get_debug_stats().

#### `configure_event_debugging`

- API: `public`

```gdscript
func configure_event_debugging( max_dispatch_depth: int = GFTypeEventSystem.DEFAULT_MAX_DISPATCH_DEPTH, trace_enabled: bool = false, max_trace_entries: int = 64 ) -> void:
```

配置事件系统调试与保护选项。

Parameters:

| Name | Description |
|---|---|
| `max_dispatch_depth` | 最大嵌套派发深度；小于等于 0 表示不限制。 |
| `trace_enabled` | 是否记录派发追踪。 |
| `max_trace_entries` | 最多保留的追踪条目数。 |

#### `get_event_dispatch_trace`

- API: `public`

```gdscript
func get_event_dispatch_trace() -> Array[Dictionary]:
```

获取最近事件派发追踪条目。

Returns: 从旧到新的追踪条目副本。

Schemas:

- `return`: Array of Dictionary trace entries with event, listener, owner, and dispatch metadata.

#### `clear_event_dispatch_trace`

- API: `public`

```gdscript
func clear_event_dispatch_trace() -> void:
```

清空事件派发追踪。

#### `register_system`

- API: `public`

```gdscript
func register_system(script_cls: Script, instance: Object) -> void:
```

注册 System 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 系统的脚本类。 |
| `instance` | 系统实例。 |

#### `register_model`

- API: `public`

```gdscript
func register_model(script_cls: Script, instance: Object) -> void:
```

注册 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 模型的脚本类。 |
| `instance` | 模型实例。 |

#### `register_utility`

- API: `public`

```gdscript
func register_utility(script_cls: Script, instance: Object) -> void:
```

注册 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 工具的脚本类。 |
| `instance` | 工具实例。 |

#### `replace_system`

- API: `public`

```gdscript
func replace_system(script_cls: Script, instance: Object) -> void:
```

替换 System 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 系统的脚本类。 |
| `instance` | 新系统实例。 |

#### `replace_model`

- API: `public`

```gdscript
func replace_model(script_cls: Script, instance: Object) -> void:
```

替换 Model 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 模型的脚本类。 |
| `instance` | 新模型实例。 |

#### `replace_utility`

- API: `public`

```gdscript
func replace_utility(script_cls: Script, instance: Object) -> void:
```

替换 Utility 实例。若旧实例存在，会先调用 dispose() 并移除相关别名。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 工具的脚本类。 |
| `instance` | 新工具实例。 |

#### `register_factory`

- API: `public`

```gdscript
func register_factory( script_cls: Script, factory: Callable, lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT ) -> void:
```

注册短生命周期对象工厂。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |
| `factory` | 返回对象实例的工厂回调。 |
| `lifetime` | 工厂生命周期，默认每次 create_instance() 都创建新对象。 |

#### `register_factory_instance`

- API: `public`

```gdscript
func register_factory_instance(script_cls: Script, instance: Object) -> void:
```

注册已有实例作为短生命周期工厂入口。该实例以单例方式返回。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |
| `instance` | 要暴露的实例。 |

#### `replace_factory`

- API: `public`

```gdscript
func replace_factory( script_cls: Script, factory: Callable, lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT ) -> void:
```

替换短生命周期对象工厂。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |
| `factory` | 新工厂回调。 |
| `lifetime` | 工厂生命周期。 |

#### `replace_factory_instance`

- API: `public`

```gdscript
func replace_factory_instance(script_cls: Script, instance: Object) -> void:
```

替换已有实例工厂入口。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |
| `instance` | 要暴露的实例。 |

#### `unregister_factory`

- API: `public`

```gdscript
func unregister_factory(script_cls: Script) -> void:
```

注销短生命周期对象工厂。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要移除的脚本类型。 |

#### `has_factory`

- API: `public`

```gdscript
func has_factory(script_cls: Script) -> bool:
```

检查当前架构或父级架构是否注册了指定工厂。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要查询的脚本类型。 |

Returns: 工厂存在时返回 true。

#### `register_system_alias`

- API: `public`

```gdscript
func register_system_alias(alias_cls: Script, target_cls: Script) -> void:
```

为已注册 System 增加一个额外查询别名。 适合把具体实现以抽象基类或接口式脚本暴露给调用方。

Parameters:

| Name | Description |
|---|---|
| `alias_cls` | 调用 get_system() 时使用的别名脚本类。 |
| `target_cls` | 已注册 System 的实际脚本类。 |

#### `register_model_alias`

- API: `public`

```gdscript
func register_model_alias(alias_cls: Script, target_cls: Script) -> void:
```

为已注册 Model 增加一个额外查询别名。

Parameters:

| Name | Description |
|---|---|
| `alias_cls` | 调用 get_model() 时使用的别名脚本类。 |
| `target_cls` | 已注册 Model 的实际脚本类。 |

#### `register_utility_alias`

- API: `public`

```gdscript
func register_utility_alias(alias_cls: Script, target_cls: Script) -> void:
```

为已注册 Utility 增加一个额外查询别名。

Parameters:

| Name | Description |
|---|---|
| `alias_cls` | 调用 get_utility() 时使用的别名脚本类。 |
| `target_cls` | 已注册 Utility 的实际脚本类。 |

#### `register_system_instance`

- API: `public`

```gdscript
func register_system_instance(instance: Object) -> void:
```

便捷注册 System 实例，自动从实例获取脚本类作为注册键。

Parameters:

| Name | Description |
|---|---|
| `instance` | 系统实例，必须附加有 GDScript 脚本。 |

#### `register_model_instance`

- API: `public`

```gdscript
func register_model_instance(instance: Object) -> void:
```

便捷注册 Model 实例，自动从实例获取脚本类作为注册键。

Parameters:

| Name | Description |
|---|---|
| `instance` | 模型实例，必须附加有 GDScript 脚本。 |

#### `register_utility_instance`

- API: `public`

```gdscript
func register_utility_instance(instance: Object) -> void:
```

便捷注册 Utility 实例，自动从实例获取脚本类作为注册键。

Parameters:

| Name | Description |
|---|---|
| `instance` | 工具实例，必须附加有 GDScript 脚本。 |

#### `register_system_instance_as`

- API: `public`

```gdscript
func register_system_instance_as(instance: Object, alias_cls: Script) -> void:
```

便捷注册 System，并同时以 alias_cls 作为额外查询键。

Parameters:

| Name | Description |
|---|---|
| `instance` | System 实例。 |
| `alias_cls` | 额外查询脚本类。 |

#### `register_model_instance_as`

- API: `public`

```gdscript
func register_model_instance_as(instance: Object, alias_cls: Script) -> void:
```

便捷注册 Model，并同时以 alias_cls 作为额外查询键。

Parameters:

| Name | Description |
|---|---|
| `instance` | Model 实例。 |
| `alias_cls` | 额外查询脚本类。 |

#### `register_utility_instance_as`

- API: `public`

```gdscript
func register_utility_instance_as(instance: Object, alias_cls: Script) -> void:
```

便捷注册 Utility，并同时以 alias_cls 作为额外查询键。

Parameters:

| Name | Description |
|---|---|
| `instance` | Utility 实例。 |
| `alias_cls` | 额外查询脚本类。 |

#### `unregister_system`

- API: `public`

```gdscript
func unregister_system(script_cls: Script) -> void:
```

注销 System 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 系统的脚本类。 |

#### `unregister_model`

- API: `public`

```gdscript
func unregister_model(script_cls: Script) -> void:
```

注销 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 模型的脚本类。 |

#### `unregister_utility`

- API: `public`

```gdscript
func unregister_utility(script_cls: Script) -> void:
```

注销 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 工具的脚本类。 |

#### `get_system`

- API: `public`

```gdscript
func get_system(script_cls: Script, require_ready: bool = false) -> Object:
```

通过脚本类获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例，如果未找到则返回 null。

#### `get_model`

- API: `public`

```gdscript
func get_model(script_cls: Script, require_ready: bool = false) -> Object:
```

通过脚本类获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例，如果未找到则返回 null。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(script_cls: Script, require_ready: bool = false) -> Object:
```

通过脚本类获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例，如果未找到则返回 null。

#### `get_local_system`

- API: `public`

```gdscript
func get_local_system(script_cls: Script, require_ready: bool = false) -> Object:
```

仅从当前架构获取 System，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的系统实例，如果未找到则返回 null。

#### `get_local_model`

- API: `public`

```gdscript
func get_local_model(script_cls: Script, require_ready: bool = false) -> Object:
```

仅从当前架构获取 Model，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的模型实例，如果未找到则返回 null。

#### `get_local_utility`

- API: `public`

```gdscript
func get_local_utility(script_cls: Script, require_ready: bool = false) -> Object:
```

仅从当前架构获取 Utility，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 脚本类。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的工具实例，如果未找到则返回 null。

#### `create_instance`

- API: `public`

```gdscript
func create_instance(script_cls: Script) -> Object:
```

通过已注册工厂创建短生命周期对象。

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |

Returns: 新对象实例；没有工厂或工厂返回非对象时返回 null。

#### `inject_object`

- API: `public`

```gdscript
func inject_object(instance: Object) -> void:
```

向任意对象注入当前架构依赖。

Parameters:

| Name | Description |
|---|---|
| `instance` | 需要注入的对象。 |

#### `inject_node_tree`

- API: `public`

```gdscript
func inject_node_tree(node: Node) -> void:
```

递归向节点树中实现注入 Hook 的节点注入当前架构。

Parameters:

| Name | Description |
|---|---|
| `node` | 节点树根节点。 |

#### `get_all_models_state`

- API: `public`

```gdscript
func get_all_models_state() -> Dictionary:
```

收集所有已注册 Model 的状态快照。 遍历所有 Model，调用其 to_dict() 方法，以脚本类的全局类名为键汇聚成一个字典。

Returns: 包含所有 Model 状态的字典，可直接用于 JSON 序列化。

Schemas:

- `return`: Dictionary keyed by stable model save key, storing each Model.to_dict() result.

#### `restore_all_models_state`

- API: `public`

```gdscript
func restore_all_models_state(data: Dictionary) -> void:
```

从状态字典恢复所有已注册 Model 的数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 由 get_all_models_state() 返回的状态字典。 |

Schemas:

- `data`: Dictionary keyed by stable model save key, storing serialized model data.

#### `get_global_snapshot`

- API: `public`

```gdscript
func get_global_snapshot() -> Dictionary:
```

获取整个框架的全局快照，包含所有 Model 状态以及可选命令历史记录。

Returns: 包含全局快照数据的字典。可直接用于 JSON 序列化。

Schemas:

- `return`: Dictionary with models and optional command_history fields.

#### `restore_global_snapshot`

- API: `public`

```gdscript
func restore_global_snapshot(data: Dictionary, command_builder: Callable = Callable()) -> void:
```

从全局快照中恢复整个框架的状态，包含 Model 状态以及可选命令历史记录。 注意：恢复命令历史需要外部传入 CommandBuilder 进行控制反转，因为它涉及到具体的业务命令类实例化。

Parameters:

| Name | Description |
|---|---|
| `data` | 由 get_global_snapshot() 导出的全局快照字典数据。 |
| `command_builder` | 【可选】如果需要恢复历史记录，必须传入用于反序列化具体 Command 实例的 Callable。 |

Schemas:

- `data`: Dictionary produced by get_global_snapshot().

#### `get_debug_lifecycle_state`

- API: `public`

```gdscript
func get_debug_lifecycle_state() -> Dictionary:
```

获取架构模块生命周期诊断快照。

Returns: 包含 Model、System、Utility、Factory、Alias 与 Tick 缓存状态的字典。

Schemas:

- `return`: Dictionary containing lifecycle flags, registered module summaries, factory summaries, alias counts, and tick cache counts.

#### `get_dependency_diagnostics`

- API: `public`

```gdscript
func get_dependency_diagnostics(options: Dictionary = {}) -> Dictionary:
```

获取架构中已注册模块的声明式依赖诊断报告。 模块可选择实现 get_required_dependencies() 或 get_required_models/systems/utilities/factories()。

Parameters:

| Name | Description |
|---|---|
| `options` | 可选参数，支持 include_parent_lookup 与 include_factories。 |

Returns: 统一诊断报告字典。

Schemas:

- `options`: Dictionary with optional bool keys include_parent_lookup and include_factories.
- `return`: Dictionary dependency diagnostics report with modules, resolved_dependencies, missing_dependencies, issue counts, and next_action.

## GFBindBuilder

- Path: `addons/gf/kernel/core/gf_bind_builder.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFBindBuilder: 声明式装配链，用于把脚本绑定为模块或短生命周期工厂。

### Methods

#### `from_factory`

- API: `public`

```gdscript
func from_factory(factory: Callable) -> Variant:
```

使用 Callable 作为绑定来源。 "type": "Variant", "description": "当前 GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `factory` | 返回 Object 实例的工厂。 |

Returns: 当前 Builder，便于继续声明生命周期。

Schemas:

- `return {`: 

#### `from_instance`

- API: `public`

```gdscript
func from_instance(instance: Object) -> Variant:
```

使用已有实例作为绑定来源。 "type": "Variant", "description": "当前 GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `instance` | 要注册或暴露的实例。 |

Returns: 当前 Builder，便于继续声明生命周期。

Schemas:

- `return {`: 

#### `with_alias`

- API: `public`

```gdscript
func with_alias(alias_cls: Script) -> Variant:
```

额外登记一个查询别名。仅对 Model/System/Utility 有效。 "type": "Variant", "description": "当前 GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `alias_cls` | 调用 get_* 时使用的抽象脚本类型。 |

Returns: 当前 Builder，便于继续声明生命周期。

Schemas:

- `return {`: 

#### `as_singleton`

- API: `public`

```gdscript
func as_singleton() -> void:
```

以单例语义完成绑定。

#### `as_transient`

- API: `public`

```gdscript
func as_transient() -> void:
```

以瞬态语义完成绑定。仅短生命周期工厂支持 transient。

## GFBindableProperty

- Path: `addons/gf/kernel/core/gf_bindable_property.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFBindableProperty: 响应式数据绑定属性容器。 封装一个 Variant 值，当值发生变化时自动发出 value_changed 信号。 可用于 Controller 直接监听 Model 数据变化，无需通过事件总线中转。

### Signals

#### `value_changed`

- API: `public`

```gdscript
signal value_changed(old_value: Variant, new_value: Variant)
```

当属性值被设置为不同的新值时发出。 "type": "Variant", "description": "变化前的旧值。" } "type": "Variant", "description": "变化后的新值。" }

Parameters:

| Name | Description |
|---|---|
| `old_value` | 变化前的旧值。 |
| `new_value` | 变化后的新值。 |

Schemas:

- `old_value {`: 
- `new_value {`: 

### Properties

#### `value`

- API: `public`

```gdscript
var value: Variant:
```

当前属性值。设置该属性等价于调用 `set_value()`。 "type": "Variant", "description": "当前属性值。" }

Schemas:

- `value {`: 

### Methods

#### `get_value`

- API: `public`

```gdscript
func get_value() -> Variant:
```

获取当前属性值。 "type": "Variant", "description": "当前存储的值。" }

Returns: 当前存储的值。

Schemas:

- `return {`: 

#### `set_value`

- API: `public`

```gdscript
func set_value(new_value: Variant) -> void:
```

设置属性值。仅当新值与旧值不同时，才会更新并发出 value_changed 信号。 "type": "Variant", "description": "要设置的新值。" }

Parameters:

| Name | Description |
|---|---|
| `new_value` | 要设置的新值。 |

Schemas:

- `new_value {`: 

#### `force_emit`

- API: `public`

```gdscript
func force_emit() -> void:
```

强制发出 value_changed 信号。 适合在 Array、Dictionary 或 Object 发生原地变更后，由业务层显式通知监听者。

#### `mutate`

- API: `public`

```gdscript
func mutate(mutator: Callable) -> bool:
```

通过回调修改当前值并强制广播。

Parameters:

| Name | Description |
|---|---|
| `mutator` | 修改当前值的回调。 |

Returns: 回调有效时返回 true。

#### `append_to_array`

- API: `public`

```gdscript
func append_to_array(item: Variant) -> bool:
```

向当前 Array 追加一个元素。 "type": "Variant", "description": "要追加的元素。" }

Parameters:

| Name | Description |
|---|---|
| `item` | 要追加的元素。 |

Returns: 成功返回 true。

Schemas:

- `item {`: 

#### `append_array`

- API: `public`

```gdscript
func append_array(items: Array) -> bool:
```

向当前 Array 追加多个元素。 "type": "Array", "description": "要追加的元素列表。" }

Parameters:

| Name | Description |
|---|---|
| `items` | 要追加的元素列表。 |

Returns: 成功返回 true。

Schemas:

- `items {`: 

#### `erase_from_array`

- API: `public`

```gdscript
func erase_from_array(item: Variant) -> bool:
```

从当前 Array 删除一个元素。 "type": "Variant", "description": "要删除的元素。" }

Parameters:

| Name | Description |
|---|---|
| `item` | 要删除的元素。 |

Returns: 成功返回 true。

Schemas:

- `item {`: 

#### `set_dictionary_value`

- API: `public`

```gdscript
func set_dictionary_value(key: Variant, new_value: Variant) -> bool:
```

设置当前 Dictionary 的一个键值。 "type": "Variant", "description": "Dictionary 键。" } "type": "Variant", "description": "Dictionary 新值。" }

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |
| `new_value` | 新值。 |

Returns: 成功返回 true。

Schemas:

- `key {`: 
- `new_value {`: 

#### `erase_dictionary_key`

- API: `public`

```gdscript
func erase_dictionary_key(key: Variant) -> bool:
```

从当前 Dictionary 删除一个键。 "type": "Variant", "description": "Dictionary 键。" }

Parameters:

| Name | Description |
|---|---|
| `key` | 键。 |

Returns: 成功返回 true。

Schemas:

- `key {`: 

#### `clear_collection`

- API: `public`

```gdscript
func clear_collection() -> bool:
```

清空当前 Array 或 Dictionary。

Returns: 成功返回 true。

#### `unbind`

- API: `public`

```gdscript
func unbind(node: Variant, callable: Callable) -> void:
```

断开指定 Node 与 Callable 的绑定关系。 "type": "Variant", "description": "绑定生命周期的 Node；已失效对象会触发失效绑定清理。" }

Parameters:

| Name | Description |
|---|---|
| `node` | 绑定生命周期的节点；已失效对象会触发失效绑定清理。 |
| `callable` | 要解绑的回调函数。 |

Schemas:

- `node {`: 

#### `unbind_all`

- API: `public`

```gdscript
func unbind_all() -> void:
```

断开所有由 bind_to() 创建的 Node 生命周期绑定。

#### `unbind_all_node_bindings`

- API: `public`

```gdscript
func unbind_all_node_bindings() -> void:
```

断开所有由 bind_to() 创建的 Node 生命周期绑定。

#### `disconnect_all_subscribers`

- API: `public`

```gdscript
func disconnect_all_subscribers() -> void:
```

断开 value_changed 信号上的所有订阅者，并清理 bind_to() 创建的 Node 生命周期绑定。

#### `bind_to`

- API: `public`

```gdscript
func bind_to(node: Node, callable: Callable) -> void:
```

绑定信号到一个 Node 的 Callable。当该 Node 退出场景树时，自动断开连接。

Parameters:

| Name | Description |
|---|---|
| `node` | 监听生命周期的节点。 |
| `callable` | 绑定的回调函数。 |

## GFBinder

- Path: `addons/gf/kernel/core/gf_binder.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFBinder: 面向 Installer 的声明式装配入口。

### Methods

#### `bind_model`

- API: `public`

```gdscript
func bind_model(script_cls: Script) -> Variant:
```

声明一个 Model 绑定。 "type": "Variant", "description": "GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `script_cls` | Model 脚本类型。 |

Returns: 绑定构建器。

Schemas:

- `return {`: 

#### `bind_system`

- API: `public`

```gdscript
func bind_system(script_cls: Script) -> Variant:
```

声明一个 System 绑定。 "type": "Variant", "description": "GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `script_cls` | System 脚本类型。 |

Returns: 绑定构建器。

Schemas:

- `return {`: 

#### `bind_utility`

- API: `public`

```gdscript
func bind_utility(script_cls: Script) -> Variant:
```

声明一个 Utility 绑定。 "type": "Variant", "description": "GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `script_cls` | Utility 脚本类型。 |

Returns: 绑定构建器。

Schemas:

- `return {`: 

#### `bind_factory`

- API: `public`

```gdscript
func bind_factory(script_cls: Script) -> Variant:
```

声明一个短生命周期对象工厂绑定。 "type": "Variant", "description": "GFBindBuilder 实例。" }

Parameters:

| Name | Description |
|---|---|
| `script_cls` | 要创建的脚本类型。 |

Returns: 绑定构建器。

Schemas:

- `return {`: 

## GFBindingLifetimes

- Path: `addons/gf/kernel/core/gf_binding_lifetimes.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFBindingLifetimes: 依赖绑定的生命周期枚举。

### Enums

#### `Lifetime`

- API: `public`

```gdscript
enum Lifetime { ## 首次解析后缓存实例，后续解析复用。 SINGLETON, ## 每次解析都重新创建实例。 TRANSIENT, }
```

绑定实例的生命周期。

## GFCommand

- Path: `addons/gf/kernel/base/gf_command.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFCommand: 命令抽象基类。 子类必须实现 'execute' 方法来定义命令逻辑。 'execute' 可返回 null（同步命令）或一个 Signal（异步命令）。 调用方可使用 'await send_command(MyCommand.new())' 等待异步命令完成。 提供对 Model、System、Utility 的访问以及发送命令和事件的能力。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行命令逻辑。子类必须重写此方法。 "type": "Variant", "description": "同步命令返回 null；异步命令可返回 Signal。" }

Returns: 同步命令返回 null；异步命令可返回一个 Signal 供外部 await。

Schemas:

- `return {`: 

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查命令所属架构生命周期是否仍可安全继续异步写回。

Returns: 所属架构仍处于活动生命周期时返回 true。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

向架构发送命令。支持 await：'await send_command(MyCommand.new())'。 "type": "Variant", "description": "命令执行结果；异步命令可返回 Signal。" }

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令的执行结果（null 或 Signal）。

Schemas:

- `return {`: 

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

向架构发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。 "type": "Variant", "description": "事件附加数据；由事件消费者约定结构。" }

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload {`: 

## GFComputedProperty

- Path: `addons/gf/kernel/core/gf_computed_property.gd`
- Extends: `GFBindableProperty`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFComputedProperty: 由多个 GFBindableProperty 派生的只读响应式属性。 通过 compute 回调计算自身值，并在任一来源属性变化时自动刷新。

### Methods

#### `bind_sources`

- API: `public`

```gdscript
func bind_sources( sources: Array[GFBindableProperty], compute: Callable, owner: Node = null, run_immediately: bool = true ) -> void:
```

绑定来源属性与计算回调。重复调用会替换旧绑定。

Parameters:

| Name | Description |
|---|---|
| `sources` | 要监听的 GFBindableProperty 列表。 |
| `compute` | 用于计算当前值的回调。 |
| `owner` | 可选 Node 生命周期宿主。 |
| `run_immediately` | 是否立即计算一次。 |

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

停止自动刷新。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放派生属性持有的监听。

#### `set_value`

- API: `public`

```gdscript
func set_value(_new_value: Variant) -> void:
```

只读派生属性不允许外部直接写入值。 "type": "Variant", "description": "调用方尝试写入的新值。" }

Parameters:

| Name | Description |
|---|---|
| `_new_value` | 调用方尝试写入的新值。 |

Schemas:

- `_new_value {`: 

#### `mutate`

- API: `public`

```gdscript
func mutate(_mutator: Callable) -> bool:
```

只读派生属性不允许外部原地修改值。

Parameters:

| Name | Description |
|---|---|
| `_mutator` | 调用方尝试执行的修改回调。 |

Returns: 始终返回 false。

#### `append_to_array`

- API: `public`

```gdscript
func append_to_array(_item: Variant) -> bool:
```

只读派生属性不允许外部向数组追加元素。 "type": "Variant", "description": "调用方尝试追加的元素。" }

Parameters:

| Name | Description |
|---|---|
| `_item` | 调用方尝试追加的元素。 |

Returns: 始终返回 false。

Schemas:

- `_item {`: 

#### `append_array`

- API: `public`

```gdscript
func append_array(_items: Array) -> bool:
```

只读派生属性不允许外部向数组追加元素列表。 "type": "Array", "description": "调用方尝试追加的元素列表。" }

Parameters:

| Name | Description |
|---|---|
| `_items` | 调用方尝试追加的元素列表。 |

Returns: 始终返回 false。

Schemas:

- `_items {`: 

#### `erase_from_array`

- API: `public`

```gdscript
func erase_from_array(_item: Variant) -> bool:
```

只读派生属性不允许外部从数组删除元素。 "type": "Variant", "description": "调用方尝试删除的元素。" }

Parameters:

| Name | Description |
|---|---|
| `_item` | 调用方尝试删除的元素。 |

Returns: 始终返回 false。

Schemas:

- `_item {`: 

#### `set_dictionary_value`

- API: `public`

```gdscript
func set_dictionary_value(_key: Variant, _new_value: Variant) -> bool:
```

只读派生属性不允许外部设置字典键值。 "type": "Variant", "description": "调用方尝试设置的键。" } "type": "Variant", "description": "调用方尝试设置的新值。" }

Parameters:

| Name | Description |
|---|---|
| `_key` | 调用方尝试设置的键。 |
| `_new_value` | 调用方尝试设置的新值。 |

Returns: 始终返回 false。

Schemas:

- `_key {`: 
- `_new_value {`: 

#### `erase_dictionary_key`

- API: `public`

```gdscript
func erase_dictionary_key(_key: Variant) -> bool:
```

只读派生属性不允许外部删除字典键。 "type": "Variant", "description": "调用方尝试删除的键。" }

Parameters:

| Name | Description |
|---|---|
| `_key` | 调用方尝试删除的键。 |

Returns: 始终返回 false。

Schemas:

- `_key {`: 

#### `clear_collection`

- API: `public`

```gdscript
func clear_collection() -> bool:
```

只读派生属性不允许外部清空集合。

Returns: 始终返回 false。

#### `is_computing`

- API: `public`

```gdscript
func is_computing() -> bool:
```

获取内部 effect 是否激活。

Returns: 激活时返回 true。

## GFConfig

- Path: `addons/gf/kernel/base/gf_config.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFConfig: 数据驱动配置的抽象基类。 继承自 Resource，可在编辑器中配置并序列化为 .tres 文件。 用于承载关卡配置、难度配置、游戏模式定义等只读数据， 供 GFSystem 在初始化或运行期间读取，彻底分离"数据"与"逻辑"。 子类应将所有可配置数据声明为 @export 变量。

### Methods

#### `validate`

- API: `public`

```gdscript
func validate() -> bool:
```

校验此配置数据是否完整且合法。 子类应重写此方法以添加必要的校验逻辑（如非空检查、范围检查）。

Returns: 配置合法返回 true，否则返回 false。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

将配置数据序列化为字典，便于存档或网络传输。 子类可重写此方法以控制序列化范围。 "type": "Dictionary", "additional_properties": true }

Returns: 包含配置数据的字典。

Schemas:

- `return {`: 

## GFConfigAccessGenerator

- Path: `addons/gf/kernel/editor/gf_config_access_generator.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFConfigAccessGenerator: 生成静态导表访问器脚本。 生成结果只封装 provider 的 `get_record()` / `get_table()` 调用， 不规定项目表结构语义，适合需要 IDE 补全和集中表名常量的项目使用。

### Constants

#### `DEFAULT_OUTPUT_PATH`

- API: `public`

```gdscript
const DEFAULT_OUTPUT_PATH: String = "res://gf/generated/gf_config_access.gd"
```

默认生成输出路径。

#### `DEFAULT_CLASS_NAME`

- API: `public`

```gdscript
const DEFAULT_CLASS_NAME: String = "GFConfigAccess"
```

默认生成 class_name。

#### `DEFAULT_PROVIDER_ACCESSOR`

- API: `public`

```gdscript
const DEFAULT_PROVIDER_ACCESSOR: String = "null"
```

默认 provider 获取表达式。

### Methods

#### `generate`

- API: `public`

```gdscript
func generate( schemas: Array, output_path: String = DEFAULT_OUTPUT_PATH, overwrite_existing: bool = true, access_class_name: String = DEFAULT_CLASS_NAME, provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR, options: Dictionary = {} ) -> Error:
```

根据 schema 列表生成访问器并写入文件。

Parameters:

| Name | Description |
|---|---|
| `schemas` | 带有 `table_name` 或 `table_key` 属性的 schema 列表。 |
| `output_path` | 生成文件输出路径。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |
| `access_class_name` | 生成脚本的 class_name。 |
| `provider_accessor` | 无显式 provider 参数时用于获取 provider 的表达式。 |
| `options` | 可选生成选项，支持 method_name_style、constant_prefix、record_method_pattern、table_method_pattern、include_schema_comments。 |

Returns: 写入结果错误码。

Schemas:

- `schemas`: Array of Dictionary or Object schemas with table_name/table_key and optional metadata.
- `options`: Dictionary controlling method_name_style, constant_prefix, record_method_pattern, table_method_pattern, and include_schema_comments.

#### `build_source`

- API: `public`

```gdscript
func build_source( schemas: Array, access_class_name: String = DEFAULT_CLASS_NAME, provider_accessor: String = DEFAULT_PROVIDER_ACCESSOR, options: Dictionary = {} ) -> String:
```

根据 schema 列表生成访问器源码。

Parameters:

| Name | Description |
|---|---|
| `schemas` | 带有 `table_name` 或 `table_key` 属性的 schema 列表。 |
| `access_class_name` | 生成脚本的 class_name。 |
| `provider_accessor` | 无显式 provider 参数时用于获取 provider 的表达式。 |
| `options` | 可选生成选项。 |

Returns: GDScript 源码。

Schemas:

- `schemas`: Array of Dictionary or Object schemas with table_name/table_key and optional metadata.
- `options`: Dictionary controlling method_name_style, constant_prefix, record_method_pattern, table_method_pattern, and include_schema_comments.

#### `save_source`

- API: `public`

```gdscript
func save_source(output_path: String, source: String, overwrite_existing: bool = true) -> Error:
```

保存生成源码到指定路径。

Parameters:

| Name | Description |
|---|---|
| `output_path` | 生成文件输出路径。 |
| `source` | GDScript 源码。 |
| `overwrite_existing` | 为 false 时目标已存在会返回 ERR_ALREADY_EXISTS。 |

Returns: 写入结果错误码。

## GFController

- Path: `addons/gf/kernel/base/gf_controller.gd`
- Extends: `Node`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFController: 连接 UI/输入与架构的控制器基类。 提供访问架构的便捷代理。这里不缓存 Model/System/Utility 引用， 以避免架构切换或模块注销后保留过期对象。

### Properties

#### `host_node_path`

- API: `public`

```gdscript
var host_node_path: NodePath = NodePath("..")
```

Controller 控制的宿主节点路径。默认指向父节点。 当 Controller 不是宿主节点的直接子节点时，可在 Inspector 中改为目标节点路径。

#### `host`

- API: `public`

```gdscript
var host: Node:
```

Controller 控制的宿主节点。

### Methods

#### `get_architecture`

- API: `public`

```gdscript
func get_architecture() -> GFArchitecture:
```

获取当前 Controller 所属的架构。 优先沿场景树向上寻找 GFNodeContext；若未找到，则回退到全局 Gf 架构。

Returns: 当前可用的架构实例。

#### `get_architecture_or_null`

- API: `public`

```gdscript
func get_architecture_or_null() -> GFArchitecture:
```

获取当前 Controller 所属的架构，找不到时返回 null 且不触发全局错误。

Returns: 当前可用的架构实例。

#### `wait_for_context_ready`

- API: `public`

```gdscript
func wait_for_context_ready() -> GFArchitecture:
```

等待最近的 GFNodeContext 完成初始化并返回可用架构。 若当前节点不在上下文子树下，则直接返回全局架构。

Returns: 当前 Controller 可用的架构实例。

#### `get_host`

- API: `public`

```gdscript
func get_host() -> Node:
```

获取当前 Controller 控制的宿主节点。 默认返回父节点。若宿主不是父节点，可通过 host_node_path 指定。

Returns: 当前宿主节点；路径为空或目标不存在时返回 null。

#### `has_host`

- API: `public`

```gdscript
func has_host() -> bool:
```

判断当前 Controller 是否能解析到有效宿主节点。

Returns: 能解析到宿主节点时返回 true。

#### `get_host_as`

- API: `public`

```gdscript
func get_host_as(host_type: Variant) -> Node:
```

获取指定类型的宿主节点。 可传入项目脚本类型或 Godot 原生类型。 "type": "Variant", "description": "Script、ClassDB 原生类型或 null。" }

Parameters:

| Name | Description |
|---|---|
| `host_type` | 宿主节点类型。 |

Returns: 匹配类型的宿主节点；未找到或类型不匹配时返回 null。

Schemas:

- `host_type {`: 

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `get_local_model`

- API: `public`

```gdscript
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
```

仅从当前 Controller 所属架构获取 Model，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的模型实例。

#### `get_local_system`

- API: `public`

```gdscript
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
```

仅从当前 Controller 所属架构获取 System，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的系统实例。

#### `get_local_utility`

- API: `public`

```gdscript
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

仅从当前 Controller 所属架构获取 Utility，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前架构中的工具实例。

#### `send_command`

- API: `public`

```gdscript
func send_command(command: Object) -> Variant:
```

向架构发送命令。支持 await：'await send_command(MyCommand.new())'。 "type": "Variant", "description": "命令执行结果；异步命令可返回 Signal。" }

Parameters:

| Name | Description |
|---|---|
| `command` | 要发送的命令实例。 |

Returns: 命令的执行结果（null 或 Signal）。

Schemas:

- `return {`: 

#### `send_query`

- API: `public`

```gdscript
func send_query(query: Object) -> Variant:
```

执行查询并返回结果。 "type": "Variant", "description": "查询结果；具体类型由查询对象定义。" }

Parameters:

| Name | Description |
|---|---|
| `query` | 要执行的查询实例。 |

Returns: 查询结果。

Schemas:

- `return {`: 

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册类型事件监听器。

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

注册可赋值类型事件监听器。

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

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

通过事件系统发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, callback: Callable) -> void:
```

注册轻量级 StringName 事件监听器。

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

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。 "type": "Variant", "description": "事件附加数据；由事件消费者约定结构。" }

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload {`: 

## GFEditorActionDefinition

- Path: `addons/gf/kernel/editor/gf_editor_action_definition.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorActionDefinition: 编辑器动作声明。 把菜单、按钮、快捷键或面板入口与命令工厂解耦。动作只负责描述入口和创建命令， 具体执行、撤销和业务含义由调用方或命令实现决定。

### Properties

#### `action_id`

- API: `public`

```gdscript
var action_id: StringName = &""
```

动作稳定标识。

#### `label`

- API: `public`

```gdscript
var label: String = ""
```

动作显示名称。

#### `tooltip`

- API: `public`

```gdscript
var tooltip: String = ""
```

动作提示文本。

#### `shortcut_text`

- API: `public`

```gdscript
var shortcut_text: String = ""
```

快捷键说明文本，由具体 UI 决定是否展示。

#### `command_factory`

- API: `public`

```gdscript
var command_factory: Callable = Callable()
```

命令工厂。推荐签名为 `func(context: Dictionary) -> GFEditorCommand`。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

动作元数据。

Schemas:

- `metadata`: Dictionary for caller-defined editor action metadata.

### Methods

#### `create_command`

- API: `public`

```gdscript
func create_command(context: Dictionary = {}) -> GFEditorCommandBase:
```

根据上下文创建命令。

Parameters:

| Name | Description |
|---|---|
| `context` | 调用方传入的编辑器上下文。 |

Returns: 命令对象，工厂无效或返回类型不匹配时为 null。

Schemas:

- `context`: Dictionary editor context passed to command_factory.

#### `invoke`

- API: `public`

```gdscript
func invoke(context: Dictionary = {}, undo_manager: Object = null) -> Error:
```

执行动作并可选接入 UndoRedo。

Parameters:

| Name | Description |
|---|---|
| `context` | 调用方传入的编辑器上下文。 |
| `undo_manager` | EditorUndoRedoManager 或兼容对象；为空时直接执行命令。 |

Returns: Godot 错误码。

Schemas:

- `context`: Dictionary editor context passed to create_command().

#### `is_available`

- API: `public`

```gdscript
func is_available(context: Dictionary = {}) -> bool:
```

动作是否具备可调用命令工厂。

Parameters:

| Name | Description |
|---|---|
| `context` | 调用方传入的编辑器上下文。 |

Returns: 可创建且可执行命令时返回 true。

Schemas:

- `context`: Dictionary editor context passed to create_command().

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取动作快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary containing action_id, label, tooltip, shortcut_text, has_command_factory, and metadata.

## GFEditorCommand

- Path: `addons/gf/kernel/editor/gf_editor_command.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorCommand: 可撤销编辑器操作的通用基类。 用于把编辑器 UI、快捷键或交互工具产生的修改收敛成可执行、可撤销的命令。 命令只描述操作协议，不绑定具体资源、节点类型或业务含义。

### Properties

#### `command_name`

- API: `public`

```gdscript
var command_name: String = "GF Editor Command"
```

命令显示名称，会作为 UndoRedo action 名称使用。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方可附加的上下文数据。

Schemas:

- `metadata`: Dictionary for caller-defined command metadata.

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Error:
```

执行命令。

Returns: Godot 错误码。

#### `revert`

- API: `public`

```gdscript
func revert() -> Error:
```

撤销命令。

Returns: Godot 错误码。

#### `add_to_undo_manager`

- API: `public`

```gdscript
func add_to_undo_manager(undo_manager: Object, execute_immediately: bool = true) -> Error:
```

将命令写入 Godot 编辑器 UndoRedo 管理器。

Parameters:

| Name | Description |
|---|---|
| `undo_manager` | EditorUndoRedoManager 或兼容对象。 |
| `execute_immediately` | 提交 action 时是否立即执行 do 方法。 |

Returns: Godot 错误码。

#### `is_executed`

- API: `public`

```gdscript
func is_executed() -> bool:
```

当前命令是否已执行。

Returns: 已执行时返回 true。

#### `can_execute`

- API: `public`

```gdscript
func can_execute() -> bool:
```

命令当前是否允许执行。

Returns: 允许执行时返回 true。

#### `can_revert_before_execute`

- API: `public`

```gdscript
func can_revert_before_execute() -> bool:
```

未执行时是否仍允许调用 revert()。

Returns: 未执行时允许撤销返回 true。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary containing command_name, executed, and metadata.

## GFEditorPickOperation

- Path: `addons/gf/kernel/editor/gf_editor_pick_operation.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorPickOperation: 编辑器工具的分阶段拾取操作协议。 用于描述 pick、preview、ready、apply 和 cancel 这类持续交互流程。

### Enums

#### `State`

- API: `public`

```gdscript
enum State { ## 尚未开始。 IDLE, ## 正在拾取。 PICKING, ## 已准备好应用。 READY, ## 已应用。 APPLIED, ## 已取消。 CANCELLED, }
```

拾取操作状态。

### Properties

#### `operation_id`

- API: `public`

```gdscript
var operation_id: StringName = &""
```

操作稳定标识。

#### `label`

- API: `public`

```gdscript
var label: String = ""
```

操作显示名称。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: Dictionary for caller-defined pick operation metadata.

### Methods

#### `begin`

- API: `public`

```gdscript
func begin(context: GFEditorToolContextBase) -> bool:
```

开始拾取操作。

Parameters:

| Name | Description |
|---|---|
| `context` | 编辑器工具上下文。 |

Returns: 成功开始返回 true。

#### `pick`

- API: `public`

```gdscript
func pick(input_data: Dictionary) -> State:
```

输入一次拾取数据。

Parameters:

| Name | Description |
|---|---|
| `input_data` | 调用方传入的通用拾取数据。 |

Returns: 操作状态。

Schemas:

- `input_data`: Dictionary containing tool-specific pick input.

#### `can_apply`

- API: `public`

```gdscript
func can_apply() -> bool:
```

检查当前操作是否可应用。

Returns: 可应用返回 true。

#### `apply`

- API: `public`

```gdscript
func apply() -> Dictionary:
```

应用拾取结果。

Returns: 应用结果字典。

Schemas:

- `return`: Dictionary result produced by _on_apply().

#### `cancel`

- API: `public`

```gdscript
func cancel() -> void:
```

取消拾取操作。

#### `get_state`

- API: `public`

```gdscript
func get_state() -> State:
```

获取当前状态。

Returns: 当前操作状态。

#### `get_preview`

- API: `public`

```gdscript
func get_preview() -> Dictionary:
```

获取预览数据副本。

Returns: 预览数据。

Schemas:

- `return`: Dictionary preview data produced by _on_pick().

#### `get_result`

- API: `public`

```gdscript
func get_result() -> Dictionary:
```

获取拾取结果副本。

Returns: 拾取结果。

Schemas:

- `return`: Dictionary result data produced by _on_pick().

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary containing operation_id, label, state, preview, result, and metadata.

## GFEditorTool

- Path: `addons/gf/kernel/editor/gf_editor_tool.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorTool: 持续式编辑器交互工具基类。 用于封装需要激活、停用、接收输入并最终产生命令的编辑器工具。 基类只定义生命周期协议，具体绘制和资源修改由子类实现。

### Properties

#### `tool_id`

- API: `public`

```gdscript
var tool_id: StringName = &""
```

工具稳定标识。

#### `label`

- API: `public`

```gdscript
var label: String = ""
```

工具显示名称。

#### `tooltip`

- API: `public`

```gdscript
var tooltip: String = ""
```

工具提示文本。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

工具排序权重。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: Dictionary for caller-defined editor tool metadata.

#### `option_schema`

- API: `public`

```gdscript
var option_schema: GFEditorToolOptionSchemaBase = null
```

可选工具选项声明。

### Methods

#### `activate`

- API: `public`

```gdscript
func activate(context: GFEditorToolContextBase) -> void:
```

激活工具。

Parameters:

| Name | Description |
|---|---|
| `context` | 编辑器工具上下文。 |

#### `deactivate`

- API: `public`

```gdscript
func deactivate() -> void:
```

停用工具。

#### `is_active`

- API: `public`

```gdscript
func is_active() -> bool:
```

工具是否处于激活状态。

Returns: 激活时返回 true。

#### `get_context`

- API: `public`

```gdscript
func get_context() -> GFEditorToolContextBase:
```

获取当前上下文。

Returns: 当前上下文；未激活时返回 null。

#### `set_option_schema`

- API: `public`

```gdscript
func set_option_schema(schema: GFEditorToolOptionSchemaBase, reset_values: bool = true) -> void:
```

设置工具选项声明。

Parameters:

| Name | Description |
|---|---|
| `schema` | 工具选项声明。 |
| `reset_values` | 是否重置当前选项值。 |

#### `set_tool_option`

- API: `public`

```gdscript
func set_tool_option(option_id: StringName, value: Variant) -> bool:
```

设置工具选项值。

Parameters:

| Name | Description |
|---|---|
| `option_id` | 选项标识。 |
| `value` | 选项值。 |

Returns: 设置成功返回 true。

Schemas:

- `value`: Variant raw option value.

#### `get_tool_option`

- API: `public`

```gdscript
func get_tool_option(option_id: StringName, default_value: Variant = null) -> Variant:
```

获取工具选项值。

Parameters:

| Name | Description |
|---|---|
| `option_id` | 选项标识。 |
| `default_value` | 缺失时返回的默认值。 |

Returns: 选项值。

Schemas:

- `default_value`: Variant fallback returned when the option is missing.
- `return`: Variant option value copy or fallback.

#### `get_tool_options`

- API: `public`

```gdscript
func get_tool_options() -> Dictionary:
```

获取工具选项快照。

Returns: 选项值副本。

Schemas:

- `return`: Dictionary keyed by option_id, storing option values.

#### `clear_tool_options`

- API: `public`

```gdscript
func clear_tool_options() -> void:
```

清空工具选项值。

#### `can_handle`

- API: `public`

```gdscript
func can_handle(context: GFEditorToolContextBase) -> bool:
```

工具是否可以处理当前上下文。

Parameters:

| Name | Description |
|---|---|
| `context` | 编辑器工具上下文。 |

Returns: 可处理时返回 true。

#### `begin_pick_operation`

- API: `public`

```gdscript
func begin_pick_operation(operation: GFEditorPickOperationBase) -> bool:
```

开始分阶段拾取操作。

Parameters:

| Name | Description |
|---|---|
| `operation` | 拾取操作。 |

Returns: 成功开始返回 true。

#### `pick`

- API: `public`

```gdscript
func pick(input_data: Dictionary) -> int:
```

向当前拾取操作输入数据。

Parameters:

| Name | Description |
|---|---|
| `input_data` | 通用拾取数据。 |

Returns: 当前拾取状态；没有操作时返回 IDLE。

Schemas:

- `input_data`: Dictionary pick input forwarded to the active pick operation.

#### `apply_pick_operation`

- API: `public`

```gdscript
func apply_pick_operation() -> Dictionary:
```

应用当前拾取操作。

Returns: 应用结果字典。

Schemas:

- `return`: Dictionary apply result from the active pick operation.

#### `cancel_pick_operation`

- API: `public`

```gdscript
func cancel_pick_operation() -> void:
```

取消当前拾取操作。

#### `get_pick_operation`

- API: `public`

```gdscript
func get_pick_operation() -> GFEditorPickOperationBase:
```

获取当前拾取操作。

Returns: 拾取操作；不存在时返回 null。

#### `gui_input`

- API: `public`

```gdscript
func gui_input(event: InputEvent) -> bool:
```

向工具转发输入事件。

Parameters:

| Name | Description |
|---|---|
| `event` | 输入事件。 |

Returns: true 表示事件已被工具消费。

#### `draw_tool`

- API: `public`

```gdscript
func draw_tool(viewport: Viewport) -> void:
```

请求工具绘制调试或交互辅助。

Parameters:

| Name | Description |
|---|---|
| `viewport` | 绘制目标视口。 |

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取工具快照。

Returns: 调试信息字典。

Schemas:

- `return`: Dictionary containing tool_id, label, tooltip, priority, active, options, pick_operation, and metadata.

## GFEditorToolContext

- Path: `addons/gf/kernel/editor/gf_editor_tool_context.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorToolContext: 编辑器交互工具上下文。 用于在工具、动作和命令之间传递 EditorPlugin、UndoRedo、选中节点和额外元数据。 该对象只保存通用编辑器上下文，不假设具体工具会编辑哪类资源。

### Properties

#### `plugin`

- API: `public`

```gdscript
var plugin: EditorPlugin = null
```

当前 EditorPlugin。

#### `undo_manager`

- API: `public`

```gdscript
var undo_manager: Object = null
```

UndoRedo 管理器或兼容对象。

#### `edited_scene_root`

- API: `public`

```gdscript
var edited_scene_root: Node = null
```

当前编辑场景根节点。

#### `selected_nodes`

- API: `public`

```gdscript
var selected_nodes: Array[Node] = []
```

当前选中节点快照。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

调用方附加元数据。

Schemas:

- `metadata`: Dictionary for caller-defined editor tool context metadata.

### Methods

#### `from_plugin`

- API: `public`

```gdscript
static func from_plugin(editor_plugin: EditorPlugin, extra_metadata: Dictionary = {}) -> GFEditorToolContext:
```

从 EditorPlugin 构建上下文。

Parameters:

| Name | Description |
|---|---|
| `editor_plugin` | 当前编辑器插件。 |
| `extra_metadata` | 额外元数据。 |

Returns: 新上下文。

Schemas:

- `extra_metadata`: Dictionary copied into metadata.

#### `commit_command`

- API: `public`

```gdscript
func commit_command(command: GFEditorCommandBase, use_undo: bool = true) -> Error:
```

提交一个命令。

Parameters:

| Name | Description |
|---|---|
| `command` | 需要执行或写入 UndoRedo 的命令。 |
| `use_undo` | 为 true 且存在 undo_manager 时写入 UndoRedo。 |

Returns: Godot 错误码。

#### `get_selected_nodes`

- API: `public`

```gdscript
func get_selected_nodes() -> Array[Node]:
```

获取选中节点副本。

Returns: 选中节点数组。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

获取上下文字典。

Returns: 普通字典快照。

Schemas:

- `return`: Dictionary containing plugin, undo_manager, edited_scene_root, selected_nodes, and metadata.

## GFEditorToolOption

- Path: `addons/gf/kernel/editor/gf_editor_tool_option.gd`
- Extends: `Resource`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorToolOption: 编辑器工具选项声明。 用通用字段描述工具面板需要的一个选项，不绑定具体 UI 控件或资源类型。

### Enums

#### `ValueType`

- API: `public`

```gdscript
enum ValueType { ## 不做类型约束。 ANY, ## 布尔值。 BOOL, ## 整数。 INT, ## 浮点数。 FLOAT, ## 字符串。 STRING, ## StringName。 STRING_NAME, ## Color。 COLOR, ## Vector2。 VECTOR2, ## Vector2i。 VECTOR2I, ## NodePath。 NODE_PATH, ## 从 choices 中选择。 OPTION, }
```

编辑器工具选项的通用值类型。

### Properties

#### `option_id`

- API: `public`

```gdscript
var option_id: StringName = &""
```

选项稳定标识。

#### `label`

- API: `public`

```gdscript
var label: String = ""
```

选项显示名称。

#### `tooltip`

- API: `public`

```gdscript
var tooltip: String = ""
```

选项提示文本。

#### `value_type`

- API: `public`

```gdscript
var value_type: ValueType = ValueType.ANY
```

选项值类型。

#### `default_value`

- API: `public`

```gdscript
var default_value: Variant = null
```

默认值。

Schemas:

- `default_value`: Variant default value duplicated when needed.

#### `min_value`

- API: `public`

```gdscript
var min_value: float = 0.0
```

数值最小值。

#### `max_value`

- API: `public`

```gdscript
var max_value: float = 1.0
```

数值最大值。

#### `step`

- API: `public`

```gdscript
var step: float = 0.01
```

数值步长。

#### `choices`

- API: `public`

```gdscript
var choices: Array = []
```

可选项列表。`value_type` 为 OPTION 时用于校验。

Schemas:

- `choices`: Array of allowed values for OPTION value_type.

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供工具 UI、持久化或项目层扩展使用。

Schemas:

- `metadata`: Dictionary for caller-defined option metadata.

### Methods

#### `get_option_id`

- API: `public`

```gdscript
func get_option_id() -> StringName:
```

获取稳定选项标识。

Returns: 选项标识。

#### `is_valid_definition`

- API: `public`

```gdscript
func is_valid_definition() -> bool:
```

检查选项声明是否有效。

Returns: 有效返回 true。

#### `normalize_value`

- API: `public`

```gdscript
func normalize_value(value: Variant) -> Variant:
```

规范化输入值。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |

Returns: 规范化后的值。

Schemas:

- `value`: Variant raw option value.
- `return`: Variant normalized option value.

#### `is_value_valid`

- API: `public`

```gdscript
func is_value_valid(value: Variant) -> bool:
```

检查值是否符合选项声明。

Parameters:

| Name | Description |
|---|---|
| `value` | 待检查值。 |

Returns: 符合声明时返回 true。

Schemas:

- `value`: Variant option value to validate.

#### `duplicate_option`

- API: `public`

```gdscript
func duplicate_option() -> GFEditorToolOption:
```

创建同内容拷贝。

Returns: 新选项声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出选项声明摘要。

Returns: 选项声明字典。

Schemas:

- `return`: Dictionary containing option_id, label, tooltip, value_type, default_value, numeric constraints, choices, and metadata.

## GFEditorToolOptionSchema

- Path: `addons/gf/kernel/editor/gf_editor_tool_option_schema.gd`
- Extends: `Resource`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorToolOptionSchema: 编辑器工具选项集合声明。 为工具面板、持久化和调试快照提供稳定的选项描述与值规范化入口。

### Properties

#### `options`

- API: `public`

```gdscript
var options: Array[GFEditorToolOption] = []
```

工具选项列表。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

可选元数据，供项目层扩展使用。

Schemas:

- `metadata`: Dictionary for caller-defined option schema metadata.

### Methods

#### `add_option`

- API: `public`

```gdscript
func add_option(option: GFEditorToolOption) -> bool:
```

添加或替换选项声明。

Parameters:

| Name | Description |
|---|---|
| `option` | 选项声明。 |

Returns: 添加成功返回 true。

#### `remove_option`

- API: `public`

```gdscript
func remove_option(option_id: StringName) -> bool:
```

移除选项声明。

Parameters:

| Name | Description |
|---|---|
| `option_id` | 选项标识。 |

Returns: 移除成功返回 true。

#### `clear_options`

- API: `public`

```gdscript
func clear_options() -> void:
```

清空选项声明。

#### `get_option`

- API: `public`

```gdscript
func get_option(option_id: StringName) -> GFEditorToolOption:
```

获取选项声明。

Parameters:

| Name | Description |
|---|---|
| `option_id` | 选项标识。 |

Returns: 找到时返回选项声明，否则返回 null。

#### `has_option`

- API: `public`

```gdscript
func has_option(option_id: StringName) -> bool:
```

检查选项声明是否存在。

Parameters:

| Name | Description |
|---|---|
| `option_id` | 选项标识。 |

Returns: 存在返回 true。

#### `get_option_ids`

- API: `public`

```gdscript
func get_option_ids() -> PackedStringArray:
```

获取选项 ID 列表。

Returns: 排序后的选项 ID。

#### `get_default_values`

- API: `public`

```gdscript
func get_default_values() -> Dictionary:
```

获取默认值字典。

Returns: 选项 ID 到默认值的字典。

Schemas:

- `return`: Dictionary keyed by option_id, storing normalized default values.

#### `normalize_values`

- API: `public`

```gdscript
func normalize_values(values: Dictionary, include_defaults: bool = true) -> Dictionary:
```

规范化一组选项值。

Parameters:

| Name | Description |
|---|---|
| `values` | 输入选项值。 |
| `include_defaults` | 为 true 时补齐缺失默认值。 |

Returns: 规范化后的选项字典。

Schemas:

- `values`: Dictionary keyed by option_id, storing raw option values.
- `return`: Dictionary keyed by option_id, storing normalized option values.

#### `validate_values`

- API: `public`

```gdscript
func validate_values(values: Dictionary) -> Dictionary:
```

校验一组选项值。

Parameters:

| Name | Description |
|---|---|
| `values` | 输入选项值。 |

Returns: 校验报告字典。

Schemas:

- `values`: Dictionary keyed by option_id, storing option values to validate.
- `return`: Dictionary containing ok, error_count, warning_count, and issues.

#### `duplicate_schema`

- API: `public`

```gdscript
func duplicate_schema() -> GFEditorToolOptionSchema:
```

创建同内容拷贝。

Returns: 新选项集合声明。

#### `describe`

- API: `public`

```gdscript
func describe() -> Dictionary:
```

导出选项集合摘要。

Returns: 选项集合字典。

Schemas:

- `return`: Dictionary containing option descriptions and metadata.

## GFEditorTypeIndex

- Path: `addons/gf/kernel/editor/gf_editor_type_index.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorTypeIndex: 编辑器侧 GF 类型查询工具。 集中扫描 class_name 脚本与能力场景，供代码生成器和 Inspector 工具复用。

### Constants

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认最大扫描深度。

#### `DEFAULT_MAX_SCANNED_SCENES`

- API: `public`

```gdscript
const DEFAULT_MAX_SCANNED_SCENES: int = 10000
```

默认最大扫描场景数。

### Methods

#### `collect_scripts_extending`

- API: `public`

```gdscript
func collect_scripts_extending(base_script: Script, excluded_scripts: Array[Script] = []) -> Array[Dictionary]:
```

收集继承指定脚本基类的全局脚本类。

Parameters:

| Name | Description |
|---|---|
| `base_script` | 要匹配的基类脚本。 |
| `excluded_scripts` | 收集类型时需要排除的脚本列表。 |

Returns: 匹配脚本记录列表。

Schemas:

- `return`: Array of Dictionary script records with class_name, path, and script.

#### `collect_scene_roots_extending`

- API: `public`

```gdscript
func collect_scene_roots_extending( base_script: Script, used_paths: Dictionary = {}, root_paths: PackedStringArray = PackedStringArray(), options: Dictionary = {} ) -> Array[Dictionary]:
```

收集根脚本继承指定基类的场景。

Parameters:

| Name | Description |
|---|---|
| `base_script` | 要匹配的基类脚本。 |
| `used_paths` | 已使用的资源路径集合。 |
| `root_paths` | 可选扫描根路径；为空时扫描整个资源树。 |
| `options` | 可选参数，支持 max_scan_depth 与 max_scanned_scenes。 |

Returns: 匹配场景记录列表。

Schemas:

- `used_paths`: Dictionary keyed by already consumed resource path.
- `options`: Dictionary with optional max_scan_depth and max_scanned_scenes.
- `return`: Array of Dictionary scene root records with path, root_script, and class metadata.

#### `get_scene_root_script`

- API: `public`

```gdscript
func get_scene_root_script(path: String) -> Script:
```

获取 PackedScene 根节点脚本。

Parameters:

| Name | Description |
|---|---|
| `path` | 资源路径或状态路径。 |

Returns: 根节点脚本；无法解析时返回 null。

#### `clear_cache`

- API: `public`

```gdscript
func clear_cache() -> void:
```

清空脚本和场景根脚本缓存。

## GFEditorValueField

- Path: `addons/gf/kernel/editor/gf_editor_value_field.gd`
- Extends: `HBoxContainer`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFEditorValueField: 编辑器通用 Variant 值输入控件。 根据 Godot 属性信息创建基础输入控件，适合 Inspector、Dock 或批量资源表格复用。

### Signals

#### `value_changed`

- API: `public`

```gdscript
signal value_changed(value: Variant)
```

控件值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `value` | 新值。 |

Schemas:

- `value`: Variant editor value read from the active control.

#### `value_parse_failed`

- API: `public`

```gdscript
signal value_parse_failed(text: String, error_message: String)
```

Array/Dictionary JSON 输入解析失败时发出。

Parameters:

| Name | Description |
|---|---|
| `text` | 用户输入的原始文本。 |
| `error_message` | JSON 解析错误说明。 |

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(property_info: Dictionary, value: Variant = null) -> void:
```

配置字段输入控件。

Parameters:

| Name | Description |
|---|---|
| `property_info` | Godot 属性信息字典，常用键为 name、type、hint、hint_string。 |
| `value` | 初始值。 |

Schemas:

- `property_info`: Godot property info dictionary.
- `value`: Variant initial editor value.

#### `set_value`

- API: `public`

```gdscript
func set_value(value: Variant) -> void:
```

设置当前值。

Parameters:

| Name | Description |
|---|---|
| `value` | 新值。 |

Schemas:

- `value`: Variant value assigned to the editor.

#### `get_value`

- API: `public`

```gdscript
func get_value() -> Variant:
```

获取当前值。

Returns: 当前值。

Schemas:

- `return`: Variant value read from the active editor control.

#### `set_editable`

- API: `public`

```gdscript
func set_editable(editable: bool) -> void:
```

设置控件是否可编辑。

Parameters:

| Name | Description |
|---|---|
| `editable` | 为 true 时允许编辑。 |

#### `get_property_info`

- API: `public`

```gdscript
func get_property_info() -> Dictionary:
```

获取当前属性信息。

Returns: 属性信息字典。

Schemas:

- `return`: Godot property info dictionary copy.

## GFExtensionCatalog

- Path: `addons/gf/kernel/extension/gf_extension_catalog.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFExtensionCatalog: GF 扩展 manifest 发现与读取辅助。 扫描 `addons/gf/extensions` 下一层扩展目录中的 `gf_extension.json`， 供编辑器工具或项目侧扩展管理界面使用。

### Constants

#### `EXTENSIONS_PATH`

- API: `public`

```gdscript
const EXTENSIONS_PATH: String = "res://addons/gf/extensions"
```

GF 内置可选扩展根目录。

### Methods

#### `load_extension_manifests`

- API: `public`

```gdscript
static func load_extension_manifests() -> Array[GFExtensionManifest]:
```

读取 GF 内置可选扩展 manifest。

Returns: 扩展 manifest 列表。

#### `load_all_manifests`

- API: `public`

```gdscript
static func load_all_manifests() -> Array[GFExtensionManifest]:
```

读取所有 GF 内置可选扩展 manifest。

Returns: 扩展 manifest 列表。

#### `load_manifests_in`

- API: `public`

```gdscript
static func load_manifests_in(root_path: String) -> Array[GFExtensionManifest]:
```

读取指定根目录下一层扩展目录中的 manifest。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扩展集合根目录。 |

Returns: 扩展 manifest 列表。

#### `get_manifest_paths`

- API: `public`

```gdscript
static func get_manifest_paths(root_path: String) -> Array[String]:
```

获取指定根目录下一层扩展目录中的 manifest 路径。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扩展集合根目录。 |

Returns: manifest 路径列表。

## GFExtensionManifest

- Path: `addons/gf/kernel/extension/gf_extension_manifest.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFExtensionManifest: GF 扩展元数据描述。 用于描述 GF 扩展的稳定 ID、版本、依赖、安装入口和编辑器扩展。

### Constants

#### `FILE_NAME`

- API: `public`

```gdscript
const FILE_NAME: String = "gf_extension.json"
```

GF 扩展 manifest 文件名。

#### `KIND_STANDARD`

- API: `public`

```gdscript
const KIND_STANDARD: String = "standard"
```

扩展类型：GF 标准库内置能力。

#### `KIND_EXTENSION`

- API: `public`

```gdscript
const KIND_EXTENSION: String = "extension"
```

扩展类型：GF 可选扩展。

### Properties

#### `id`

- API: `public`

```gdscript
var id: String = ""
```

稳定扩展 ID，推荐格式为反向域名或作者命名空间，例如 `author.extension_name`。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

面向用户显示的扩展名。

#### `version`

- API: `public`

```gdscript
var version: String = ""
```

扩展发行版本号。GF 内置扩展必须与当前 GF 发行版本一致。

#### `extension_version`

- API: `public`

```gdscript
var extension_version: String = ""
```

扩展自身版本号。GF 内置扩展按扩展内公开行为变化独立递增；未声明时回退到 version。

#### `kind`

- API: `public`

```gdscript
var kind: String = KIND_EXTENSION
```

扩展类型，应为 `standard` 或 `extension`。

#### `root_path`

- API: `public`

```gdscript
var root_path: String = ""
```

扩展根目录。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

简短说明。

#### `dependencies`

- API: `public`

```gdscript
var dependencies: Array[String] = []
```

依赖的扩展 ID 列表。

#### `installer_paths`

- API: `public`

```gdscript
var installer_paths: Array[String] = []
```

可选 GFInstaller 路径列表。需要自动装配运行时模块时使用。

#### `editor_action_paths`

- API: `public`

```gdscript
var editor_action_paths: Array[String] = []
```

可选编辑器菜单动作脚本路径列表。

#### `editor_dock_paths`

- API: `public`

```gdscript
var editor_dock_paths: Array[String] = []
```

可选编辑器工作区页面脚本路径列表。

#### `editor_dock_order`

- API: `public`

```gdscript
var editor_dock_order: int = 1000
```

编辑器工作区页面排序。数值越小越靠前。

#### `editor_dock_short_label`

- API: `public`

```gdscript
var editor_dock_short_label: String = ""
```

编辑器工作区页面短标签。为空时使用扩展显示名。

#### `editor_inspector_paths`

- API: `public`

```gdscript
var editor_inspector_paths: Array[String] = []
```

可选 EditorInspectorPlugin 路径列表。需要为扩展内类型提供 Inspector 增强时使用。

#### `import_plugin_paths`

- API: `public`

```gdscript
var import_plugin_paths: Array[String] = []
```

可选 EditorImportPlugin 路径列表。需要为自定义资源格式提供导入器时使用。

#### `export_plugin_paths`

- API: `public`

```gdscript
var export_plugin_paths: Array[String] = []
```

可选 EditorExportPlugin 路径列表。

#### `gltf_document_extension_paths`

- API: `public`

```gdscript
var gltf_document_extension_paths: Array[String] = []
```

可选 GLTFDocumentExtension 路径列表。用于导入期资产元数据桥接等编辑器能力。

#### `access_generator_extension_paths`

- API: `public`

```gdscript
var access_generator_extension_paths: Array[String] = []
```

可选 GFAccessGenerator 扩展脚本路径列表。

#### `tags`

- API: `public`

```gdscript
var tags: Array[String] = []
```

便于工具筛选的标签。

#### `enabled_by_default`

- API: `public`

```gdscript
var enabled_by_default: bool = false
```

是否在项目首次启用 GF 时默认启用该扩展。

#### `source_path`

- API: `public`

```gdscript
var source_path: String = ""
```

manifest 文件路径。

### Methods

#### `from_dictionary`

- API: `public`

```gdscript
static func from_dictionary( data: Dictionary, extension_root_path: String = "", manifest_source_path: String = "" ) -> GFExtensionManifest:
```

从字典创建扩展 manifest。

Parameters:

| Name | Description |
|---|---|
| `data` | manifest 字典。 |
| `extension_root_path` | 扩展根目录。 |
| `manifest_source_path` | manifest 文件路径。 |

Returns: 扩展 manifest 实例。

Schemas:

- `data`: Dictionary decoded from gf_extension.json.

#### `from_json_file`

- API: `public`

```gdscript
static func from_json_file(path: String) -> GFExtensionManifest:
```

从 JSON 文件读取扩展 manifest。

Parameters:

| Name | Description |
|---|---|
| `path` | `gf_extension.json` 文件路径。 |

Returns: 读取成功时返回 manifest；失败时返回 null。

#### `to_dictionary`

- API: `public`

```gdscript
func to_dictionary() -> Dictionary:
```

转换为字典。

Returns: manifest 字典副本。

Schemas:

- `return`: Dictionary matching the gf_extension.json manifest shape.

#### `is_valid`

- API: `public`

```gdscript
func is_valid() -> bool:
```

检查 manifest 是否满足基本规范。

Returns: 满足规范时返回 true。

#### `get_validation_errors`

- API: `public`

```gdscript
func get_validation_errors() -> Array[String]:
```

获取 manifest 规范错误。

Returns: 错误消息列表。

## GFExtensionSettings

- Path: `addons/gf/kernel/extension/gf_extension_settings.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFExtensionSettings: GF 扩展启用状态与 ProjectSettings 桥接。 负责读取启用扩展 ID、解析扩展依赖、收集启用扩展 Installer，以及提供导出排除开关。

### Constants

#### `ENABLED_EXTENSIONS_SETTING`

- API: `public`

```gdscript
const ENABLED_EXTENSIONS_SETTING: String = "gf/extensions/enabled"
```

项目设置：启用的 GF 扩展 ID 列表。

#### `AUTO_INSTALL_ENABLED_INSTALLERS_SETTING`

- API: `public`

```gdscript
const AUTO_INSTALL_ENABLED_INSTALLERS_SETTING: String = "gf/extensions/auto_install_enabled_installers"
```

项目设置：是否自动执行启用扩展 manifest 中声明的 installer_paths。

#### `EXPORT_EXCLUDE_DISABLED_SETTING`

- API: `public`

```gdscript
const EXPORT_EXCLUDE_DISABLED_SETTING: String = "gf/extensions/export_exclude_disabled"
```

项目设置：导出时是否跳过禁用扩展目录。

#### `EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING`

- API: `public`

```gdscript
const EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING: String = "gf/extensions/export_fail_on_disabled_references"
```

项目设置：导出审计发现项目仍引用禁用扩展时是否报告为错误。

#### `AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT`

- API: `public`

```gdscript
const AUTO_INSTALL_ENABLED_INSTALLERS_DEFAULT: bool = true
```

默认自动执行启用扩展 Installer。

#### `EXPORT_EXCLUDE_DISABLED_DEFAULT`

- API: `public`

```gdscript
const EXPORT_EXCLUDE_DISABLED_DEFAULT: bool = true
```

默认导出时排除禁用扩展。

#### `EXPORT_FAIL_ON_DISABLED_REFERENCES_DEFAULT`

- API: `public`

```gdscript
const EXPORT_FAIL_ON_DISABLED_REFERENCES_DEFAULT: bool = true
```

默认把禁用扩展引用作为导出错误，避免导出产物缺少被引用的扩展文件。

#### `BUILT_IN_EXTENSION_IDS`

- API: `public`

```gdscript
const BUILT_IN_EXTENSION_IDS: Array[String] = [
```

内置依赖 ID。这些不是可启停扩展 manifest，但允许被扩展声明为基础依赖。

### Methods

#### `ensure_defaults`

- API: `public`

```gdscript
static func ensure_defaults() -> bool:
```

确保扩展相关 ProjectSettings 存在。

Returns: 写入了默认值时返回 true。

#### `register_property_info`

- API: `public`

```gdscript
static func register_property_info() -> void:
```

注册扩展相关 ProjectSettings 显示信息。

#### `get_default_enabled_extension_ids`

- API: `public`

```gdscript
static func get_default_enabled_extension_ids() -> Array[String]:
```

获取默认启用的扩展 ID。

Returns: 默认启用扩展 ID 列表。

#### `get_enabled_extension_ids`

- API: `public`

```gdscript
static func get_enabled_extension_ids() -> Array[String]:
```

获取用户配置的启用扩展 ID。

Returns: 启用扩展 ID 列表。

#### `set_enabled_extension_ids`

- API: `public`

```gdscript
static func set_enabled_extension_ids(extension_ids: Array[String], include_dependencies: bool = true) -> void:
```

保存启用扩展 ID，可选自动补齐依赖。

Parameters:

| Name | Description |
|---|---|
| `extension_ids` | 要启用的扩展 ID 列表。 |
| `include_dependencies` | 是否自动包含依赖扩展。 |

#### `should_auto_install_enabled_installers`

- API: `public`

```gdscript
static func should_auto_install_enabled_installers() -> bool:
```

判断是否自动运行启用扩展 Installer。

Returns: 自动运行时返回 true。

#### `set_auto_install_enabled_installers`

- API: `public`

```gdscript
static func set_auto_install_enabled_installers(enabled: bool) -> void:
```

设置是否自动运行启用扩展 Installer。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 是否自动运行。 |

#### `should_export_exclude_disabled_extensions`

- API: `public`

```gdscript
static func should_export_exclude_disabled_extensions() -> bool:
```

判断导出时是否排除禁用扩展目录。

Returns: 排除禁用扩展时返回 true。

#### `set_export_exclude_disabled_extensions`

- API: `public`

```gdscript
static func set_export_exclude_disabled_extensions(enabled: bool) -> void:
```

设置导出时是否排除禁用扩展目录。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 是否排除禁用扩展。 |

#### `should_fail_export_on_disabled_extension_references`

- API: `public`

```gdscript
static func should_fail_export_on_disabled_extension_references() -> bool:
```

判断导出审计发现禁用扩展引用时是否报告为错误。

Returns: 报告为错误时返回 true。

#### `set_fail_export_on_disabled_extension_references`

- API: `public`

```gdscript
static func set_fail_export_on_disabled_extension_references(enabled: bool) -> void:
```

设置导出审计发现禁用扩展引用时是否报告为错误。

Parameters:

| Name | Description |
|---|---|
| `enabled` | 是否报告为错误。 |

#### `get_all_manifests`

- API: `public`

```gdscript
static func get_all_manifests() -> Array[GFExtensionManifest]:
```

获取所有 manifest。

Returns: manifest 列表。

#### `clear_manifest_cache`

- API: `public`

```gdscript
static func clear_manifest_cache() -> void:
```

清空 manifest 发现缓存。编辑器或工具在扩展目录发生变化后可主动调用。

#### `get_manifest_by_id`

- API: `public`

```gdscript
static func get_manifest_by_id(extension_id: String) -> GFExtensionManifest:
```

按 ID 获取 manifest。

Parameters:

| Name | Description |
|---|---|
| `extension_id` | 扩展 ID。 |

Returns: 找到时返回 manifest，否则返回 null。

#### `has_extension`

- API: `public`

```gdscript
static func has_extension(extension_id: String) -> bool:
```

判断扩展 manifest 是否存在。

Parameters:

| Name | Description |
|---|---|
| `extension_id` | 扩展 ID。 |

Returns: 存在 manifest 时返回 true。

#### `get_extension_resource_path`

- API: `public`

```gdscript
static func get_extension_resource_path( extension_id: String, relative_path: String = "" ) -> String:
```

获取扩展内资源路径。

Parameters:

| Name | Description |
|---|---|
| `extension_id` | 扩展 ID。 |
| `relative_path` | 相对扩展根目录的资源路径；传入 `res://` 或 `user://` 时会原样返回。 |

Returns: 扩展资源路径；扩展不存在时返回空字符串。

#### `is_extension_enabled`

- API: `public`

```gdscript
static func is_extension_enabled( extension_id: String, include_dependencies: bool = true ) -> bool:
```

判断扩展当前是否启用。

Parameters:

| Name | Description |
|---|---|
| `extension_id` | 扩展 ID。 |
| `include_dependencies` | 是否把依赖补齐后的启用结果纳入判断。 |

Returns: 扩展存在且启用时返回 true。

#### `load_enabled_extension_script`

- API: `public`

```gdscript
static func load_enabled_extension_script( extension_id: String, relative_path: String, include_dependencies: bool = true ) -> Script:
```

加载启用扩展内的脚本资源。

Parameters:

| Name | Description |
|---|---|
| `extension_id` | 扩展 ID。 |
| `relative_path` | 相对扩展根目录的脚本路径；传入 `res://` 或 `user://` 时会原样解析。 |
| `include_dependencies` | 是否把依赖补齐后的启用结果纳入判断。 |

Returns: 扩展存在、已启用且脚本可加载时返回 Script，否则返回 null。

#### `get_enabled_manifests`

- API: `public`

```gdscript
static func get_enabled_manifests() -> Array[GFExtensionManifest]:
```

获取启用扩展的 manifest。

Returns: 启用 manifest 列表。

#### `get_disabled_manifests`

- API: `public`

```gdscript
static func get_disabled_manifests() -> Array[GFExtensionManifest]:
```

获取禁用扩展的 manifest。

Returns: 禁用 manifest 列表。

#### `get_enabled_installer_paths`

- API: `public`

```gdscript
static func get_enabled_installer_paths() -> Array[String]:
```

获取启用扩展声明的 Installer 路径。

Returns: Installer 路径列表。

#### `get_enabled_editor_action_paths`

- API: `public`

```gdscript
static func get_enabled_editor_action_paths() -> Array[String]:
```

获取启用扩展声明的编辑器菜单动作路径。

Returns: 编辑器菜单动作脚本路径列表。

#### `get_enabled_editor_dock_paths`

- API: `public`

```gdscript
static func get_enabled_editor_dock_paths() -> Array[String]:
```

获取启用扩展声明的编辑器工作区页面路径。

Returns: 编辑器工作区页面脚本路径列表。

#### `get_enabled_editor_inspector_paths`

- API: `public`

```gdscript
static func get_enabled_editor_inspector_paths() -> Array[String]:
```

获取启用扩展声明的 Inspector 扩展路径。

Returns: EditorInspectorPlugin 脚本路径列表。

#### `get_enabled_import_plugin_paths`

- API: `public`

```gdscript
static func get_enabled_import_plugin_paths() -> Array[String]:
```

获取启用扩展声明的导入插件路径。

Returns: EditorImportPlugin 脚本路径列表。

#### `get_enabled_export_plugin_paths`

- API: `public`

```gdscript
static func get_enabled_export_plugin_paths() -> Array[String]:
```

获取启用扩展声明的导出插件路径。

Returns: EditorExportPlugin 脚本路径列表。

#### `get_enabled_gltf_document_extension_paths`

- API: `public`

```gdscript
static func get_enabled_gltf_document_extension_paths() -> Array[String]:
```

获取启用扩展声明的 glTF 文档扩展路径。

Returns: GLTFDocumentExtension 脚本路径列表。

#### `get_enabled_access_generator_extension_paths`

- API: `public`

```gdscript
static func get_enabled_access_generator_extension_paths() -> Array[String]:
```

获取启用扩展声明的访问器生成扩展路径。

Returns: GFAccessGenerator 扩展脚本路径列表。

#### `resolve_extension_dependencies`

- API: `public`

```gdscript
static func resolve_extension_dependencies( extension_ids: Array[String], manifests: Array[GFExtensionManifest] = [] ) -> Array[String]:
```

根据 manifest 依赖关系补齐启用扩展。

Parameters:

| Name | Description |
|---|---|
| `extension_ids` | 原始启用扩展 ID。 |
| `manifests` | 可选 manifest 列表。 |

Returns: 补齐依赖后的扩展 ID。

#### `get_manifest_graph_report`

- API: `public`

```gdscript
static func get_manifest_graph_report(manifests: Array[GFExtensionManifest] = []) -> Dictionary:
```

获取 manifest 依赖图诊断。

Parameters:

| Name | Description |
|---|---|
| `manifests` | 可选 manifest 列表；为空时扫描所有 GF 内置扩展。 |

Returns: 包含重复 ID、无效 manifest、缺失依赖和循环依赖的诊断字典。

Schemas:

- `return`: Dictionary containing ok, extension_count, issue_count, duplicate_ids, invalid_manifests, missing_dependencies, and dependency_cycles.

#### `get_extension_selection_report`

- API: `public`

```gdscript
static func get_extension_selection_report() -> Dictionary:
```

获取启用状态诊断。

Returns: 诊断字典。

Schemas:

- `return`: Dictionary containing configured_ids, resolved_ids, unknown_enabled_ids, graph status, and extension counts.

## GFExtensionUsageAudit

- Path: `addons/gf/kernel/extension/gf_extension_usage_audit.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFExtensionUsageAudit: 检查禁用扩展是否仍被项目文件直接引用。

### Constants

#### `DEFAULT_SCAN_ROOTS`

- API: `public`

```gdscript
const DEFAULT_SCAN_ROOTS: Array[String] = ["res://"]
```

默认扫描根目录。

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认最大扫描深度。

#### `DEFAULT_MAX_SCANNED_FILES`

- API: `public`

```gdscript
const DEFAULT_MAX_SCANNED_FILES: int = 10000
```

默认最大扫描文件数。

#### `DEFAULT_IGNORED_ROOTS`

- API: `public`

```gdscript
const DEFAULT_IGNORED_ROOTS: Array[String] = [
```

默认忽略的根目录。

#### `TEXT_FILE_EXTENSIONS`

- API: `public`

```gdscript
const TEXT_FILE_EXTENSIONS: Array[String] = [
```

作为文本扫描的资源扩展名。

### Methods

#### `audit_disabled_extensions`

- API: `public`

```gdscript
static func audit_disabled_extensions( manifests: Array[GFExtensionManifest], options: Dictionary = {} ) -> Dictionary:
```

检查一组禁用扩展是否仍被项目文件直接引用。

Parameters:

| Name | Description |
|---|---|
| `manifests` | 要检查的禁用扩展 manifest 列表。 |
| `options` | 可选参数，支持 scan_roots、ignored_roots、max_references_per_extension、max_scan_depth、max_scanned_files。 |

Returns: 引用审计报告。

Schemas:

- `options`: Dictionary controlling scan roots, ignored roots, reference limits, depth, and scanned file count.
- `return`: Dictionary containing ok, extension_count, reference_count, extensions, and references.

#### `find_references_to_root`

- API: `public`

```gdscript
static func find_references_to_root(root_path: String, options: Dictionary = {}) -> Array[Dictionary]:
```

查找项目文件中对指定扩展根目录的直接路径引用。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扩展根目录。 |
| `options` | 可选参数，支持 scan_roots、ignored_roots、max_references_per_extension、max_scan_depth、max_scanned_files。 |

Returns: 引用列表。

Schemas:

- `options`: Dictionary controlling scan roots, ignored roots, reference limits, depth, and scanned file count.
- `return`: Array of Dictionary file reference records.

## GFInstaller

- Path: `addons/gf/kernel/core/gf_installer.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFInstaller: 项目启动装配脚本基类。 继承后重写 install()，并在 Project Settings 的 gf/project/installers 中登记脚本路径， Gf.init() 与 Gf.set_architecture() 会在架构初始化前自动执行这些安装器。

### Methods

#### `install`

- API: `public`

```gdscript
func install(_architecture: GFArchitecture) -> void:
```

将项目模块注册到架构。

Parameters:

| Name | Description |
|---|---|
| `_architecture` | 当前即将初始化的架构实例。 |

#### `install_bindings`

- API: `public`

```gdscript
func install_bindings(_binder: Variant) -> void:
```

使用声明式装配器注册项目模块。 "type": "Variant", "description": "当前架构创建的装配器实例，实际类型为 GFBindBuilder。" }

Parameters:

| Name | Description |
|---|---|
| `_binder` | 绑定到当前架构的装配器。 |

Schemas:

- `_binder {`: 

## GFModel

- Path: `addons/gf/kernel/base/gf_model.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFModel: 数据层抽象基类。 负责管理应用数据和业务状态。 子类可以实现 'init'、'async_init'、'ready'、'dispose' 来管理其生命周期。 三阶段初始化约定： - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。 - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。 - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。

### Properties

#### `lifecycle_priority`

- API: `public`

```gdscript
var lifecycle_priority: int = 0
```

生命周期优先级。数值越大越早执行 init/async_init/ready，dispose 时越晚释放。 默认 0 表示同优先级下按注册顺序执行；只有存在明确依赖顺序时才建议设置。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化。子类可以重写此方法。 约束：只允许初始化自身内部变量，不得跨模块获取依赖。

#### `async_init`

- API: `public`

```gdscript
func async_init() -> void:
```

异步初始化阶段。子类可以重写此方法并在其中使用 await。 Godot 4 支持在 void 函数内部使用 await，框架的 Gf.init() 会串行且安全地 await 每个模块的 async_init()，不再需要返回 Signal。 约束：在 init() 之后、ready() 之前执行。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

第三阶段初始化。子类可以重写此方法。 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁模型。子类可以重写此方法。

#### `get_save_key`

- API: `public`

```gdscript
func get_save_key() -> StringName:
```

获取架构级存档使用的稳定键。 默认返回空字符串，表示由 GFArchitecture 使用 class_name 或资源路径。

Returns: 稳定存档键；为空时使用框架默认规则。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

将此模型的状态序列化为字典，用于存档、状态快照等。 子类应重写此方法以包含所有需要持久化的字段。 "type": "Dictionary", "additional_properties": true }

Returns: 包含模型状态数据的字典。

Schemas:

- `return {`: 

#### `from_dict`

- API: `public`

```gdscript
func from_dict(_data: Dictionary) -> void:
```

从字典反序列化并恢复此模型的状态。 子类应重写此方法以恢复所有相关字段。 "type": "Dictionary", "additional_properties": true }

Parameters:

| Name | Description |
|---|---|
| `_data` | 包含状态数据的字典（通常来自 to_dict() 的结果）。 |

Schemas:

- `_data {`: 

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查所属架构生命周期是否仍可安全继续异步写回。 async_init() 或其他 await 之后写入状态前建议检查该值。

Returns: 所属架构仍处于活动生命周期时返回 true。

#### `is_ready_in_architecture`

- API: `public`

```gdscript
func is_ready_in_architecture() -> bool:
```

检查当前模块是否已经完成 ready 阶段。

Returns: 当前模块完成 ready 阶段时返回 true。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

向架构发送事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。 "type": "Variant", "description": "事件附加数据；由事件消费者约定结构。" }

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload {`: 

## GFNodeContext

- Path: `addons/gf/kernel/core/gf_node_context.gd`
- Extends: `Node`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFNodeContext: 场景树上的局部架构上下文。 可选择继承父级架构，或创建带父级回退的 Scoped 架构。 Scoped 架构会在节点退出树时自动 dispose，适合关卡、战斗房间、调试面板等局部模块。

### Signals

#### `context_ready`

- API: `public`

```gdscript
signal context_ready(architecture: GFArchitecture)
```

当上下文架构完成初始化后发出。

Parameters:

| Name | Description |
|---|---|
| `architecture` | 当前上下文使用的架构实例。 |

#### `context_failed`

- API: `public`

```gdscript
signal context_failed(reason: String)
```

当上下文无法继续等待或初始化时发出。

Parameters:

| Name | Description |
|---|---|
| `reason` | 失败原因。 |

### Enums

#### `ScopeMode`

- API: `public`

```gdscript
enum ScopeMode { ## 直接复用最近的父级上下文架构；若不存在则回退到全局 Gf 架构。 INHERITED, ## 创建新的局部架构，并将最近的父级或全局架构作为依赖回退来源。 SCOPED, }
```

上下文作用域模式。

### Properties

#### `scope_mode`

- API: `public`

```gdscript
var scope_mode: ScopeMode = ScopeMode.SCOPED
```

当前节点上下文的作用域模式。

#### `auto_init`

- API: `public`

```gdscript
var auto_init: bool = true
```

是否在进入树后自动初始化 Scoped 架构。

#### `process_scoped_ticks`

- API: `public`

```gdscript
var process_scoped_ticks: bool = true
```

是否由该节点驱动 Scoped 架构的 tick 与 physics_tick。

#### `strict_dependency_lookup`

- API: `public`

```gdscript
var strict_dependency_lookup: bool = false
```

Scoped 架构是否启用严格依赖查询。开启后本地未注册的依赖不会回退父级架构。

#### `module_async_init_timeout_seconds`

- API: `public`

```gdscript
var module_async_init_timeout_seconds: float = 0.0
```

Scoped 架构中单个模块 async_init() 的最长等待时间。小于等于 0 时继承架构默认行为。

#### `context_wait_timeout_seconds`

- API: `public`

```gdscript
var context_wait_timeout_seconds: float = 30.0
```

等待父级架构或当前上下文 ready 的超时时间。小于等于 0 时禁用超时。

#### `architecture`

- API: `public`

```gdscript
var architecture: GFArchitecture:
```

当前上下文使用的架构实例。

### Methods

#### `install`

- API: `public`

```gdscript
func install(_architecture_instance: GFArchitecture) -> void:
```

安装当前上下文的局部模块。仅在 SCOPED 模式下调用。

Parameters:

| Name | Description |
|---|---|
| `_architecture_instance` | 当前上下文创建的局部架构。 |

#### `install_bindings`

- API: `public`

```gdscript
func install_bindings(_binder: Variant) -> void:
```

使用声明式装配器安装当前上下文的局部模块。仅在 SCOPED 模式下调用。

Parameters:

| Name | Description |
|---|---|
| `_binder` | 当前上下文创建的局部架构装配器。 |

Schemas:

- `_binder`: GFBindBuilder-compatible binder produced by GFArchitecture.create_binder().

#### `get_architecture`

- API: `public`

```gdscript
func get_architecture() -> GFArchitecture:
```

获取当前上下文使用的架构。

Returns: 架构实例；未找到时返回 null。

#### `is_context_ready`

- API: `public`

```gdscript
func is_context_ready() -> bool:
```

检查上下文是否已经完成初始化。

Returns: 已完成初始化返回 true。

#### `initialize_context`

- API: `public`

```gdscript
func initialize_context() -> GFArchitecture:
```

手动初始化当前 Scoped 上下文。适合 auto_init 为 false 时，在 install()/install_bindings() 完成后统一触发初始化与 context_ready/context_failed 信号。

Returns: 初始化完成的架构；上下文失效或初始化失败时返回 null。

#### `wait_until_ready`

- API: `public`

```gdscript
func wait_until_ready() -> GFArchitecture:
```

等待上下文架构完成初始化并返回该架构。

Returns: 当前上下文架构；上下文失效时返回 null。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过当前上下文架构获取 Model。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过当前上下文架构获取 System。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过当前上下文架构获取 Utility。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `get_local_model`

- API: `public`

```gdscript
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
```

仅从当前上下文架构获取 Model，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前上下文架构中的模型实例。

#### `get_local_system`

- API: `public`

```gdscript
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
```

仅从当前上下文架构获取 System，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前上下文架构中的系统实例。

#### `get_local_utility`

- API: `public`

```gdscript
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

仅从当前上下文架构获取 Utility，不回退父级架构。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 当前上下文架构中的工具实例。

#### `inject_object`

- API: `public`

```gdscript
func inject_object(instance: Object) -> void:
```

向任意对象注入当前上下文架构依赖。

Parameters:

| Name | Description |
|---|---|
| `instance` | 要注册、替换或注入的实例。 |

#### `inject_node_tree`

- API: `public`

```gdscript
func inject_node_tree(node: Node) -> void:
```

递归向节点树中实现注入 Hook 的节点注入当前上下文架构。

Parameters:

| Name | Description |
|---|---|
| `node` | 目标节点。 |

## GFObjectPropertyTools

- Path: `addons/gf/kernel/core/gf_object_property_tools.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFObjectPropertyTools: Godot Object 属性访问辅助。 集中处理属性列表查询、属性路径读写、可写性判断和基础类型校验。 它不负责属性绑定、自动派发、表达式执行或业务字段解释。

### Methods

#### `get_property_infos`

- API: `public`

```gdscript
static func get_property_infos(object: Object, usage_filter: int = -1) -> Array[Dictionary]:
```

获取对象属性信息列表。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `usage_filter` | 属性 usage 过滤掩码；小于 0 时不过滤。 |

Returns: 属性信息字典列表副本。

Schemas:

- `return`: Array of Godot property info Dictionary values.

#### `get_property_info_map`

- API: `public`

```gdscript
static func get_property_info_map(object: Object, usage_filter: int = -1) -> Dictionary:
```

获取对象属性信息映射。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `usage_filter` | 属性 usage 过滤掩码；小于 0 时不过滤。 |

Returns: 以属性名为键的属性信息字典。

Schemas:

- `return`: Dictionary[StringName, Dictionary]

#### `get_property_names`

- API: `public`

```gdscript
static func get_property_names(object: Object, usage_filter: int = -1) -> PackedStringArray:
```

获取对象属性名列表。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `usage_filter` | 属性 usage 过滤掩码；小于 0 时不过滤。 |

Returns: 属性名列表。

#### `get_property_info`

- API: `public`

```gdscript
static func get_property_info(object: Object, property_name: StringName) -> Dictionary:
```

获取单个属性信息。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_name` | 属性名。 |

Returns: 属性信息字典副本；不存在时返回空字典。

Schemas:

- `return`: Godot property info dictionary.

#### `has_property`

- API: `public`

```gdscript
static func has_property(object: Object, property_name: StringName) -> bool:
```

检查对象是否声明了指定属性。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_name` | 属性名。 |

Returns: 属性存在时返回 true。

#### `has_property_path`

- API: `public`

```gdscript
static func has_property_path(object: Object, property_path: NodePath) -> bool:
```

检查对象是否声明了属性路径的根属性。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_path` | 属性路径。 |

Returns: 根属性存在时返回 true。

#### `is_property_writable`

- API: `public`

```gdscript
static func is_property_writable(property_info: Dictionary) -> bool:
```

判断属性信息是否可写。

Parameters:

| Name | Description |
|---|---|
| `property_info` | Godot 属性信息字典。 |

Returns: 未标记为只读时返回 true。

Schemas:

- `property_info`: Godot property info dictionary.

#### `can_write_property`

- API: `public`

```gdscript
static func can_write_property(object: Object, property_path: NodePath) -> bool:
```

检查对象属性路径是否可写。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_path` | 属性路径。 |

Returns: 根属性存在且未标记为只读时返回 true。

#### `read_property`

- API: `public`

```gdscript
static func read_property( object: Object, property_path: NodePath, default_value: Variant = null ) -> Variant:
```

读取对象属性路径。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_path` | 属性路径。 |
| `default_value` | 对象、路径或根属性无效时返回的默认值。 |

Returns: 属性值或默认值。

Schemas:

- `default_value`: Variant fallback returned unchanged when the property cannot be read.
- `return`: Variant property value or the supplied default value.

#### `write_property`

- API: `public`

```gdscript
static func write_property( object: Object, property_path: NodePath, value: Variant, options: Dictionary = {} ) -> Dictionary:
```

写入对象属性路径。

Parameters:

| Name | Description |
|---|---|
| `object` | 目标对象。 |
| `property_path` | 属性路径。 |
| `value` | 请求写入的值。 |
| `options` | 可选项，支持 check_writable、check_type、coerce_value。 |

Returns: 写入结果字典，包含 ok、error、property_name、old_value 与 new_value。

Schemas:

- `value`: Variant value requested for assignment.
- `options`: Dictionary with optional bool keys check_writable, check_type, and coerce_value.
- `return`: Dictionary { ok: bool, error: String, property_name: StringName, old_value: Variant, new_value: Variant }.

#### `value_matches_property_type`

- API: `public`

```gdscript
static func value_matches_property_type(value: Variant, property_type: int) -> bool:
```

检查值是否可写入指定 Variant 类型。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |
| `property_type` | Variant.Type 常量。 |

Returns: 类型兼容时返回 true。

Schemas:

- `value`: Variant value to compare against the requested Variant.Type.

#### `coerce_property_value`

- API: `public`

```gdscript
static func coerce_property_value(value: Variant, property_type: int) -> Variant:
```

将值转换为指定 Variant 类型的基础兼容形式。

Parameters:

| Name | Description |
|---|---|
| `value` | 输入值。 |
| `property_type` | Variant.Type 常量。 |

Returns: 转换后的值；不支持转换时返回原值。

Schemas:

- `value`: Variant value to coerce.
- `return`: Variant coerced value or original value.

#### `get_root_property_name`

- API: `public`

```gdscript
static func get_root_property_name(property_path: NodePath) -> StringName:
```

获取属性路径的根属性名。

Parameters:

| Name | Description |
|---|---|
| `property_path` | 属性路径。 |

Returns: 根属性名；无效路径返回空 StringName。

## GFPayload

- Path: `addons/gf/kernel/base/gf_payload.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFPayload: 强类型数据载体的抽象基类。 继承自 RefCounted，用作事件传递、命令参数、系统间查询返回值的 标准化强类型数据包，替代容易在大型项目中引发类型错误和 null 访问的裸 Dictionary。 使用方式：为每个具体的数据场景定义一个子类， 将相关字段声明为强类型变量，并按需实现 to_dict() / from_dict()。 典型用途： - 作为 GFCommand 的参数包（替代 Dictionary 参数） - 作为类型事件系统中的事件数据载体 - 作为 GFQuery 的查询结果返回值

### Properties

#### `is_consumed`

- API: `public`

```gdscript
var is_consumed: bool = false
```

事件消费标记。高优先级回调可将此标记设为 true， 阻止后续低优先级回调继续接收该事件。 仅在 GFTypeEventSystem 的类型事件轨道中生效。

### Methods

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

将此载体序列化为字典，便于存档、网络传输或日志记录。 子类应重写此方法以包含所有相关字段。 "type": "Dictionary", "additional_properties": true }

Returns: 包含字段数据的字典。

Schemas:

- `return {`: 

#### `from_dict`

- API: `public`

```gdscript
func from_dict(_data: Dictionary) -> void:
```

从字典反序列化并填充此载体的字段。 子类应重写此方法以恢复所有相关字段。 "type": "Dictionary", "additional_properties": true }

Parameters:

| Name | Description |
|---|---|
| `_data` | 包含字段数据的字典（通常来自 to_dict() 的结果）。 |

Schemas:

- `_data {`: 

#### `validate`

- API: `public`

```gdscript
func validate() -> bool:
```

校验载体中的数据是否满足业务约束。 子类可重写此方法以添加非空、范围等校验逻辑。

Returns: 数据合法返回 true，否则返回 false。

## GFQuery

- Path: `addons/gf/kernel/base/gf_query.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFQuery: 查询抽象基类。 用于从架构中查询数据。子类必须返回结果。 子类必须实现 'execute' 方法来定义查询逻辑。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute() -> Variant:
```

执行查询并返回结果。子类必须重写此方法。 "type": "Variant", "description": "查询结果；具体类型由查询子类定义。" }

Returns: 查询结果。

Schemas:

- `return {`: 

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查查询所属架构生命周期是否仍可安全继续异步写回。

Returns: 所属架构仍处于活动生命周期时返回 true。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

## GFReactiveEffect

- Path: `addons/gf/kernel/core/gf_reactive_effect.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFReactiveEffect: GFBindableProperty 的轻量响应式副作用。 监听一组 GFBindableProperty，在任意来源变化时执行回调。可绑定 Node 生命周期， 适合 Controller 层组合多个 Model 属性，不要求项目引入新的状态模型。

### Signals

#### `effect_ran`

- API: `public`

```gdscript
signal effect_ran(value: Variant)
```

effect 执行后发出。 "type": "Variant", "description": "回调返回值。" }

Parameters:

| Name | Description |
|---|---|
| `value` | 回调返回值。 |

Schemas:

- `value {`: 

### Properties

#### `max_reruns_per_run`

- API: `public`

```gdscript
var max_reruns_per_run: int = 8
```

单次 run 中最多补跑的次数，避免回调持续写入来源属性造成死循环。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure( sources: Array[GFBindableProperty], callback: Callable, owner: Node = null, run_immediately: bool = true ) -> void:
```

配置并启动 effect。重复调用会先停止旧绑定。

Parameters:

| Name | Description |
|---|---|
| `sources` | 要监听的 GFBindableProperty 列表。 |
| `callback` | 变化后执行的回调。 |
| `owner` | 可选 Node 生命周期宿主。 |
| `run_immediately` | 是否立即执行一次。 |

#### `run`

- API: `public`

```gdscript
func run() -> Variant:
```

手动执行 effect。 "type": "Variant", "description": "回调返回值；回调无效时返回 null。" }

Returns: 回调返回值；回调无效时返回 null。

Schemas:

- `return {`: 

#### `stop`

- API: `public`

```gdscript
func stop() -> void:
```

停止 effect 并断开全部监听。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

释放 effect 持有的监听。

#### `is_active`

- API: `public`

```gdscript
func is_active() -> bool:
```

检查 effect 是否处于激活状态。

Returns: 激活时返回 true。

#### `get_sources`

- API: `public`

```gdscript
func get_sources() -> Array[GFBindableProperty]:
```

获取当前监听的属性列表。

Returns: GFBindableProperty 数组。

## GFReadOnlyBindableProperty

- Path: `addons/gf/kernel/core/gf_read_only_bindable_property.gd`
- Extends: `GFBindableProperty`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFReadOnlyBindableProperty: 只读响应式属性视图。 复用 `GFBindableProperty` 的读取、信号和生命周期绑定能力， 但阻止外部直接调用 `set_value()` 修改底层值。

### Methods

#### `set_value`

- API: `public`

```gdscript
func set_value(_new_value: Variant) -> void:
```

只读视图不允许外部直接写入值。 "type": "Variant", "description": "调用方尝试写入的新值。" }

Parameters:

| Name | Description |
|---|---|
| `_new_value` | 调用方尝试写入的新值。 |

Schemas:

- `_new_value {`: 

#### `mutate`

- API: `public`

```gdscript
func mutate(_mutator: Callable) -> bool:
```

只读视图不允许外部原地修改值。

Parameters:

| Name | Description |
|---|---|
| `_mutator` | 调用方尝试执行的修改回调。 |

Returns: 始终返回 false。

#### `append_to_array`

- API: `public`

```gdscript
func append_to_array(_item: Variant) -> bool:
```

只读视图不允许外部向数组追加元素。 "type": "Variant", "description": "调用方尝试追加的元素。" }

Parameters:

| Name | Description |
|---|---|
| `_item` | 调用方尝试追加的元素。 |

Returns: 始终返回 false。

Schemas:

- `_item {`: 

#### `append_array`

- API: `public`

```gdscript
func append_array(_items: Array) -> bool:
```

只读视图不允许外部向数组追加元素列表。 "type": "Array", "description": "调用方尝试追加的元素列表。" }

Parameters:

| Name | Description |
|---|---|
| `_items` | 调用方尝试追加的元素列表。 |

Returns: 始终返回 false。

Schemas:

- `_items {`: 

#### `erase_from_array`

- API: `public`

```gdscript
func erase_from_array(_item: Variant) -> bool:
```

只读视图不允许外部从数组删除元素。 "type": "Variant", "description": "调用方尝试删除的元素。" }

Parameters:

| Name | Description |
|---|---|
| `_item` | 调用方尝试删除的元素。 |

Returns: 始终返回 false。

Schemas:

- `_item {`: 

#### `set_dictionary_value`

- API: `public`

```gdscript
func set_dictionary_value(_key: Variant, _new_value: Variant) -> bool:
```

只读视图不允许外部设置字典键值。 "type": "Variant", "description": "调用方尝试设置的键。" } "type": "Variant", "description": "调用方尝试设置的新值。" }

Parameters:

| Name | Description |
|---|---|
| `_key` | 调用方尝试设置的键。 |
| `_new_value` | 调用方尝试设置的新值。 |

Returns: 始终返回 false。

Schemas:

- `_key {`: 
- `_new_value {`: 

#### `erase_dictionary_key`

- API: `public`

```gdscript
func erase_dictionary_key(_key: Variant) -> bool:
```

只读视图不允许外部删除字典键。 "type": "Variant", "description": "调用方尝试删除的键。" }

Parameters:

| Name | Description |
|---|---|
| `_key` | 调用方尝试删除的键。 |

Returns: 始终返回 false。

Schemas:

- `_key {`: 

#### `clear_collection`

- API: `public`

```gdscript
func clear_collection() -> bool:
```

只读视图不允许外部清空集合。

Returns: 始终返回 false。

## GFResourceTableEditor

- Path: `addons/gf/kernel/editor/gf_resource_table_editor.gd`
- Extends: `VBoxContainer`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFResourceTableEditor: 通用 Resource 表格编辑控件。 提供资源扫描、属性列提取、表格刷新与单元格提交，不绑定具体资源类型或业务数据。

### Signals

#### `resource_selected`

- API: `public`

```gdscript
signal resource_selected(resource: Resource)
```

表格选中资源时发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 被选中的资源。 |

#### `cell_value_committed`

- API: `public`

```gdscript
signal cell_value_committed(resource: Resource, property: StringName, old_value: Variant, new_value: Variant)
```

单元格值提交后发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 被修改的资源。 |
| `property` | 被修改的属性名。 |
| `old_value` | 提交前的旧值。 |
| `new_value` | 提交后的新值。 |

Schemas:

- `old_value`: Variant value before commit.
- `new_value`: Variant value after commit.

#### `resource_save_failed`

- API: `public`

```gdscript
signal resource_save_failed(resource: Resource, path: String, error: Error)
```

自动保存资源失败时发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 保存失败的资源。 |
| `path` | 资源路径。 |
| `error` | Godot 错误码。 |

#### `resources_reordered`

- API: `public`

```gdscript
signal resources_reordered(resources: Array)
```

资源列表顺序变化后发出。

Parameters:

| Name | Description |
|---|---|
| `resources` | 当前资源列表副本。 |

Schemas:

- `resources`: Array[Resource]

#### `resource_inserted`

- API: `public`

```gdscript
signal resource_inserted(resource: Resource, index: int)
```

插入资源后发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 被插入的资源。 |
| `index` | 插入索引。 |

#### `resource_removed`

- API: `public`

```gdscript
signal resource_removed(resource: Resource, index: int)
```

移除资源后发出。

Parameters:

| Name | Description |
|---|---|
| `resource` | 被移除的资源。 |
| `index` | 移除前索引。 |

#### `resource_filter_changed`

- API: `public`

```gdscript
signal resource_filter_changed(query: String, visible_count: int)
```

搜索过滤条件变化后发出。

Parameters:

| Name | Description |
|---|---|
| `query` | 当前搜索文本。 |
| `visible_count` | 当前可见资源数量。 |

### Constants

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认最大扫描深度。

#### `DEFAULT_MAX_RESOURCE_PATHS`

- API: `public`

```gdscript
const DEFAULT_MAX_RESOURCE_PATHS: int = 10000
```

默认最大扫描资源路径数量。

### Properties

#### `auto_save_committed_resources`

- API: `public`

```gdscript
var auto_save_committed_resources: bool = false
```

提交单元格后是否自动保存已绑定路径的 Resource。

#### `search_text`

- API: `public`

```gdscript
var search_text: String = ""
```

当前搜索过滤文本。为空时显示全部资源。

#### `sort_property`

- API: `public`

```gdscript
var sort_property: StringName = &""
```

当前排序属性；为空时不记录排序属性。

#### `sort_ascending`

- API: `public`

```gdscript
var sort_ascending: bool = true
```

当前排序方向。

### Methods

#### `build_export_columns`

- API: `public`

```gdscript
static func build_export_columns(resource: Resource, include_read_only: bool = false) -> Array[Dictionary]:
```

基于资源属性列表构建可编辑列声明。

Parameters:

| Name | Description |
|---|---|
| `resource` | 示例资源。 |
| `include_read_only` | 是否包含只读属性。 |

Returns: 列声明列表。

Schemas:

- `return`: Array of Dictionary column records with name, type, hint, hint_string, usage, and read_only.

#### `scan_resource_paths`

- API: `public`

```gdscript
static func scan_resource_paths( root_path: String = "res://", extensions: PackedStringArray = PackedStringArray(["tres", "res"]), options: Dictionary = {} ) -> PackedStringArray:
```

递归扫描资源路径。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 扫描根路径。 |
| `extensions` | 文件扩展名白名单，不包含点号。 |
| `options` | 可选参数，支持 `max_scan_depth` 与 `max_resource_paths`。 |

Returns: 资源路径列表。

Schemas:

- `options`: Dictionary with optional max_scan_depth and max_resource_paths.

#### `load_resources_from_paths`

- API: `public`

```gdscript
static func load_resources_from_paths(paths: PackedStringArray, script_filter: Script = null) -> Array[Resource]:
```

从路径列表加载资源。

Parameters:

| Name | Description |
|---|---|
| `paths` | 资源路径列表。 |
| `script_filter` | 可选脚本过滤；只返回附加该脚本或其子类脚本的资源。 |

Returns: 资源列表。

#### `load_resources`

- API: `public`

```gdscript
func load_resources(resources: Array[Resource], columns: Array[Dictionary] = []) -> void:
```

加载资源与列声明。

Parameters:

| Name | Description |
|---|---|
| `resources` | Resource 列表。 |
| `columns` | 可选列声明；为空时从第一条资源推导。 |

Schemas:

- `columns`: Array of Dictionary column records.

#### `get_resources`

- API: `public`

```gdscript
func get_resources() -> Array[Resource]:
```

获取当前资源列表拷贝。

Returns: 资源列表。

#### `get_columns`

- API: `public`

```gdscript
func get_columns() -> Array[Dictionary]:
```

获取当前列声明拷贝。

Returns: 列声明列表。

Schemas:

- `return`: Array of Dictionary column records.

#### `set_search_text`

- API: `public`

```gdscript
func set_search_text(query: String) -> void:
```

设置搜索过滤文本。

Parameters:

| Name | Description |
|---|---|
| `query` | 搜索文本，会匹配资源标签、路径和当前列值。 |

#### `get_visible_row_indices`

- API: `public`

```gdscript
func get_visible_row_indices() -> PackedInt32Array:
```

获取当前可见资源行的原始索引。

Returns: 可见行索引列表。

#### `get_visible_resource_count`

- API: `public`

```gdscript
func get_visible_resource_count() -> int:
```

获取当前可见资源数量。

Returns: 可见资源数量。

#### `find_resource_index`

- API: `public`

```gdscript
func find_resource_index(resource: Resource) -> int:
```

查找资源在当前列表中的索引。

Parameters:

| Name | Description |
|---|---|
| `resource` | 目标资源。 |

Returns: 资源索引；不存在时返回 -1。

#### `sort_by_property`

- API: `public`

```gdscript
func sort_by_property(property: StringName = &"", ascending: bool = true) -> void:
```

按属性或资源标签排序。

Parameters:

| Name | Description |
|---|---|
| `property` | 属性名；为空时按资源标签排序。 |
| `ascending` | 是否升序。 |

#### `move_resource`

- API: `public`

```gdscript
func move_resource(from_index: int, to_index: int) -> bool:
```

移动资源位置。

Parameters:

| Name | Description |
|---|---|
| `from_index` | 原始索引。 |
| `to_index` | 目标索引。 |

Returns: 移动成功返回 true。

#### `insert_resource`

- API: `public`

```gdscript
func insert_resource(resource: Resource, index: int = -1) -> bool:
```

插入资源。

Parameters:

| Name | Description |
|---|---|
| `resource` | 要插入的资源。 |
| `index` | 插入索引；越界或负数时追加到末尾。 |

Returns: 插入成功返回 true。

#### `remove_resource`

- API: `public`

```gdscript
func remove_resource(row_index: int) -> Resource:
```

移除资源。

Parameters:

| Name | Description |
|---|---|
| `row_index` | 资源行索引。 |

Returns: 被移除的资源；无效索引返回 null。

#### `duplicate_resource`

- API: `public`

```gdscript
func duplicate_resource(row_index: int, deep: bool = false, insert_after: bool = true) -> Resource:
```

复制资源并插入到列表。

Parameters:

| Name | Description |
|---|---|
| `row_index` | 资源行索引。 |
| `deep` | 是否深拷贝子资源。 |
| `insert_after` | 为 true 时插入到当前资源之后，否则插入到当前位置。 |

Returns: 复制出的资源；无效索引返回 null。

#### `commit_cell_value`

- API: `public`

```gdscript
func commit_cell_value(row_index: int, property: StringName, new_value: Variant) -> bool:
```

提交单元格值。

Parameters:

| Name | Description |
|---|---|
| `row_index` | 资源行索引。 |
| `property` | 属性名。 |
| `new_value` | 新值。 |

Returns: 提交成功返回 true。

Schemas:

- `new_value`: Variant value assigned to the resource property.

#### `commit_visible_cell_value`

- API: `public`

```gdscript
func commit_visible_cell_value(visible_row_index: int, property: StringName, new_value: Variant) -> bool:
```

提交当前可见行的单元格值。

Parameters:

| Name | Description |
|---|---|
| `visible_row_index` | 过滤后的可见行索引。 |
| `property` | 属性名。 |
| `new_value` | 新值。 |

Returns: 提交成功返回 true。

Schemas:

- `new_value`: Variant value assigned to the resource property.

#### `refresh`

- API: `public`

```gdscript
func refresh() -> void:
```

刷新表格显示。

## GFRule

- Path: `addons/gf/kernel/base/gf_rule.gd`
- Extends: `Resource`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFRule: 数据驱动规则的抽象基类。 继承自 Resource，可在编辑器中配置并序列化为 .tres 文件。 GFSystem 作为规则的执行者，通过调用 execute() 驱动规则逻辑， 从而避免在 System 内硬编码业务分支，实现策略模式。 子类必须重写 execute() 以实现具体规则。

### Methods

#### `execute`

- API: `public`

```gdscript
func execute(_context: Object = null) -> Variant:
```

执行规则逻辑。子类必须重写此方法。 "type": "Variant", "description": "规则执行结果；异步规则可返回 Signal 供 await。" }

Parameters:

| Name | Description |
|---|---|
| `_context` | 传递给规则的上下文数据，通常是一个 GFPayload 子类实例。 |

Returns: 规则执行结果，同步返回 Variant，异步返回一个 Signal 供 await。

Schemas:

- `return {`: 

#### `validate`

- API: `public`

```gdscript
func validate() -> bool:
```

校验规则的配置数据是否合法。 子类可重写此方法以添加配置校验逻辑。

Returns: 配置合法返回 true，否则返回 false。

## GFSceneSignalAudit

- Path: `addons/gf/kernel/editor/gf_scene_signal_audit.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFSceneSignalAudit: 开发期场景信号连接审计工具。 扫描 PackedScene 中由编辑器保存的信号连接，报告缺失节点、缺失信号、 缺失方法和可选的参数数量不匹配。该工具只返回结构化报告，不修改场景， 也不参与运行时 GFArchitecture 生命周期。

### Enums

#### `IssueType`

- API: `public`

```gdscript
enum IssueType { ## 场景资源加载失败。 SCENE_LOAD_FAILED, ## 无法读取场景保存的连接状态。 SCENE_STATE_UNAVAILABLE, ## 场景实例化失败。 SCENE_INSTANTIATION_FAILED, ## 连接源节点缺失。 MISSING_SOURCE, ## 连接目标节点缺失。 MISSING_TARGET, ## 连接源信号缺失。 MISSING_SIGNAL, ## 连接目标方法缺失。 MISSING_METHOD, ## 信号参数数量与目标方法不匹配。 PARAMETER_COUNT_MISMATCH, }
```

场景信号连接审计问题类型。

### Constants

#### `DEFAULT_MAX_SCAN_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SCAN_DEPTH: int = 32
```

默认最大目录扫描深度。

#### `DEFAULT_MAX_SCENE_PATHS`

- API: `public`

```gdscript
const DEFAULT_MAX_SCENE_PATHS: int = 10000
```

默认最大扫描场景路径数量。

#### `DEFAULT_MAX_SIGNAL_GRAPH_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_SIGNAL_GRAPH_DEPTH: int = 64
```

默认最大运行时信号图节点深度。

#### `DEFAULT_MAX_SIGNAL_GRAPH_NODES`

- API: `public`

```gdscript
const DEFAULT_MAX_SIGNAL_GRAPH_NODES: int = 10000
```

默认最大运行时信号图节点数量。

### Methods

#### `audit_directory`

- API: `public`

```gdscript
static func audit_directory(root_path: String = "res://", options: Dictionary = {}) -> Dictionary:
```

审计指定目录下的场景文件。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 需要扫描的目录，通常为 `res://`。 |
| `options` | 审计选项，支持 `include_hidden`、`respect_gdignore`、`check_parameter_count`、`max_scan_depth` 与 `max_scene_paths`。 |

Returns: 审计汇总报告。

Schemas:

- `options`: Dictionary with include_hidden, respect_gdignore, check_parameter_count, max_scan_depth, and max_scene_paths.
- `return`: Dictionary containing ok, root_path, scene_count, issue_count, scanned_paths, and issues.

#### `audit_scene_paths`

- API: `public`

```gdscript
static func audit_scene_paths(scene_paths: PackedStringArray, options: Dictionary = {}) -> Dictionary:
```

审计一组场景路径并返回汇总报告。

Parameters:

| Name | Description |
|---|---|
| `scene_paths` | 需要审计的 PackedScene 路径列表。 |
| `options` | 审计选项，支持 `check_parameter_count`。 |

Returns: 审计汇总报告。

Schemas:

- `options`: Dictionary with optional check_parameter_count.
- `return`: Dictionary containing ok, scene_count, issue_count, scanned_paths, and issues.

#### `audit_scene`

- API: `public`

```gdscript
static func audit_scene(scene_path: String, options: Dictionary = {}) -> Array[Dictionary]:
```

审计单个 PackedScene 的编辑器信号连接。

Parameters:

| Name | Description |
|---|---|
| `scene_path` | 需要审计的 PackedScene 路径。 |
| `options` | 审计选项，支持 `check_parameter_count`。 |

Returns: 场景连接问题列表。

Schemas:

- `options`: Dictionary with optional check_parameter_count.
- `return`: Array of Dictionary scene signal audit issues.

#### `collect_scene_paths`

- API: `public`

```gdscript
static func collect_scene_paths(root_path: String = "res://", options: Dictionary = {}) -> PackedStringArray:
```

收集目录下可审计的 `.tscn` 场景路径。

Parameters:

| Name | Description |
|---|---|
| `root_path` | 需要扫描的目录。 |
| `options` | 收集选项，支持 `include_hidden`、`respect_gdignore`、`max_scan_depth` 与 `max_scene_paths`。 |

Returns: 场景路径列表。

Schemas:

- `options`: Dictionary with include_hidden, respect_gdignore, max_scan_depth, and max_scene_paths.

#### `build_signal_graph`

- API: `public`

```gdscript
static func build_signal_graph(root: Node, options: Dictionary = {}) -> Dictionary:
```

构建运行中节点树的信号连接图快照。

Parameters:

| Name | Description |
|---|---|
| `root` | 需要扫描的根节点。 |
| `options` | 选项，支持 `include_internal`、`persistent_only`、`include_empty_signals`、`include_external_targets`、`max_node_depth` 与 `max_nodes`。 |

Returns: 信号连接图报告。

Schemas:

- `options`: Dictionary with include_internal, persistent_only, include_empty_signals, include_external_targets, max_node_depth, and max_nodes.
- `return`: Dictionary containing ok, root_path, node_count, signal_count, connection_count, nodes, signals, connections, and truncated.

#### `index_signal_graph`

- API: `public`

```gdscript
static func index_signal_graph(graph: Dictionary) -> Dictionary:
```

为信号图报告构建按节点分组的索引。

Parameters:

| Name | Description |
|---|---|
| `graph` | build_signal_graph() 返回的报告。 |

Returns: 节点索引，包含 incoming/outgoing/signals。

Schemas:

- `graph`: Dictionary returned by build_signal_graph().
- `return`: Dictionary containing node_count, connection_count, nodes, outgoing, incoming, and signals.

## GFSourceBuilder

- Path: `addons/gf/kernel/editor/gf_source_builder.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFSourceBuilder: 编辑器代码生成用的轻量源码构建器。 用于集中处理生成脚本时的缩进、空行、section 与文档注释格式， 避免各个 generator 直接拼接 `PackedStringArray` 时出现格式漂移。

### Methods

#### `line`

- API: `public`

```gdscript
func line(text: String = "") -> GFSourceBuilder:
```

添加一行源码。

Parameters:

| Name | Description |
|---|---|
| `text` | 行内容；空字符串会生成空行且不添加缩进。 |

Returns: 当前构建器，便于链式调用。

#### `doc`

- API: `public`

```gdscript
func doc(text: String = "") -> GFSourceBuilder:
```

添加文档注释行。

Parameters:

| Name | Description |
|---|---|
| `text` | 注释内容；空字符串会生成 `##`。 |

Returns: 当前构建器，便于链式调用。

#### `section`

- API: `public`

```gdscript
func section(title: String) -> GFSourceBuilder:
```

添加规范 section 标题，并在其后添加一个空行。

Parameters:

| Name | Description |
|---|---|
| `title` | section 标题。 |

Returns: 当前构建器，便于链式调用。

#### `blank`

- API: `public`

```gdscript
func blank(count: int = 1) -> GFSourceBuilder:
```

添加空行。

Parameters:

| Name | Description |
|---|---|
| `count` | 空行数量，小于等于 0 时不产生输出。 |

Returns: 当前构建器，便于链式调用。

#### `indent`

- API: `public`

```gdscript
func indent() -> GFSourceBuilder:
```

增加后续行的缩进层级。

Returns: 当前构建器，便于链式调用。

#### `dedent`

- API: `public`

```gdscript
func dedent(count: int = 1) -> GFSourceBuilder:
```

减少后续行的缩进层级。

Parameters:

| Name | Description |
|---|---|
| `count` | 要减少的层级数，小于等于 0 时不改变缩进。 |

Returns: 当前构建器，便于链式调用。

#### `clear`

- API: `public`

```gdscript
func clear() -> GFSourceBuilder:
```

清空已构建内容并重置缩进。

Returns: 当前构建器，便于链式调用。

#### `build`

- API: `public`

```gdscript
func build() -> String:
```

生成最终源码字符串；非空源码末尾会包含换行。

Returns: 完整源码文本。

## GFSystem

- Path: `addons/gf/kernel/base/gf_system.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFSystem: 逻辑层抽象基类。 负责实现核心业务逻辑。 子类可以实现 'init'、'async_init'、'ready'、'dispose' 来管理其生命周期。 三阶段初始化约定： - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。 - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。 - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。

### Properties

#### `ignore_pause`

- API: `public`

```gdscript
var ignore_pause: bool = false
```

是否忽略全局暂停。为 true 时，即使当前 GFTimeProvider 处于暂停状态， 该 System 仍会接收到原始（未缩放）的 delta 值。 典型场景：暂停菜单动画、设置界面过渡效果等。

#### `ignore_time_scale`

- API: `public`

```gdscript
var ignore_time_scale: bool = false
```

是否忽略当前 GFTimeProvider 的时间缩放。为 true 且未全局暂停时， 该 System 的 tick / physics_tick 会接收到原始 delta。

#### `lifecycle_priority`

- API: `public`

```gdscript
var lifecycle_priority: int = 0
```

生命周期优先级。数值越大越早执行 init/async_init/ready，dispose 时越晚释放。 默认 0 表示同优先级下按注册顺序执行；只有存在明确依赖顺序时才建议设置。

#### `tick_priority`

- API: `public`

```gdscript
var tick_priority: int = 0
```

每帧 tick 优先级。数值越大越早执行 tick()。 默认 0 表示同优先级下按注册顺序执行。

#### `physics_tick_priority`

- API: `public`

```gdscript
var physics_tick_priority: int = 0
```

物理帧 tick 优先级。数值越大越早执行 physics_tick()。 默认 0 表示同优先级下按注册顺序执行。

#### `tick_enabled`

- API: `public`

```gdscript
var tick_enabled: bool = false:
```

是否显式加入每帧 tick 缓存。 重写 tick() 的旧项目无需设置；仅在需要强制使用基类 tick 模板或动态 tick 入口时启用。

#### `physics_tick_enabled`

- API: `public`

```gdscript
var physics_tick_enabled: bool = false:
```

是否显式加入物理帧 tick 缓存。 重写 physics_tick() 的旧项目无需设置；仅在需要强制使用基类 physics_tick 模板或动态入口时启用。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化。子类可以重写此方法。 约束：只允许初始化自身内部变量，不得跨模块获取依赖。

#### `async_init`

- API: `public`

```gdscript
func async_init() -> void:
```

异步初始化阶段。子类可以重写此方法并在其中使用 await。 Godot 4 支持在 void 函数内部使用 await，框架的 Gf.init() 会串行且安全地 await 每个模块的 async_init()，不再需要返回 Signal。 约束：在 init() 之后、ready() 之前执行。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

第三阶段初始化。子类可以重写此方法。 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁系统。子类可以重写此方法。

#### `tick`

- API: `public`

```gdscript
func tick(_delta: float) -> void:
```

每帧更新回调。子类可以重写此方法以实现帧逻辑。 由架构在 _process 中统一驱动，无需 System 继承 Node。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 距上一帧的时间（秒）。 |

#### `physics_tick`

- API: `public`

```gdscript
func physics_tick(_delta: float) -> void:
```

物理帧更新回调。子类可以重写此方法以实现物理帧逻辑。 由架构在 _physics_process 中统一驱动，无需 System 继承 Node。

Parameters:

| Name | Description |
|---|---|
| `_delta` | 距上一物理帧的时间（秒）。 |

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查所属架构生命周期是否仍可安全继续异步写回。 async_init() 或其他 await 之后写入状态前建议检查该值。

Returns: 所属架构仍处于活动生命周期时返回 true。

#### `is_ready_in_architecture`

- API: `public`

```gdscript
func is_ready_in_architecture() -> bool:
```

检查当前模块是否已经完成 ready 阶段。

Returns: 当前模块完成 ready 阶段时返回 true。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册类型事件监听器。

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

注册可赋值类型事件监听器。

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

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

向架构发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, callback: Callable) -> void:
```

注册轻量级 StringName 事件监听器。

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

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。 "type": "Variant", "description": "事件附加数据；由事件消费者约定结构。" }

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload {`: 

## GFThumbnailRenderer

- Path: `addons/gf/kernel/editor/gf_thumbnail_renderer.gd`
- Extends: `Node`
- API: `public`
- Category: `editor_api`
- Since: `3.17.0`

GFThumbnailRenderer: 编辑器缩略图渲染辅助节点。 使用独立 SubViewport 渲染 Node3D 或 Mesh，供项目自定义编辑器工具复用。

### Properties

#### `cancel_preview_generation`

- API: `public`

```gdscript
var cancel_preview_generation: bool = false
```

请求取消正在进行的 MeshLibrary 批量预览生成。

### Methods

#### `render_node3d`

- API: `public`

```gdscript
func render_node3d(source: Node3D, size: Vector2i = Vector2i(256, 256), transparent: bool = true) -> Image:
```

渲染一个 3D 节点缩略图。

Parameters:

| Name | Description |
|---|---|
| `source` | 要渲染的 3D 节点，会被复制后放入内部 Viewport。 |
| `size` | 输出尺寸。 |
| `transparent` | 是否透明背景。 |

Returns: 渲染出的 Image；失败时返回 null。

#### `render_node3d_texture`

- API: `public`

```gdscript
func render_node3d_texture( source: Node3D, size: Vector2i = Vector2i(256, 256), transparent: bool = true ) -> ImageTexture:
```

渲染一个 3D 节点缩略图纹理。

Parameters:

| Name | Description |
|---|---|
| `source` | 要渲染的 3D 节点。 |
| `size` | 输出尺寸。 |
| `transparent` | 是否透明背景。 |

Returns: 渲染出的 ImageTexture；失败时返回 null。

#### `render_mesh`

- API: `public`

```gdscript
func render_mesh(mesh: Mesh, size: Vector2i = Vector2i(256, 256), transparent: bool = true) -> Image:
```

渲染一个 Mesh 缩略图。

Parameters:

| Name | Description |
|---|---|
| `mesh` | 要渲染的 Mesh。 |
| `size` | 输出尺寸。 |
| `transparent` | 是否透明背景。 |

Returns: 渲染出的 Image；失败时返回 null。

#### `render_mesh_texture`

- API: `public`

```gdscript
func render_mesh_texture( mesh: Mesh, size: Vector2i = Vector2i(256, 256), transparent: bool = true ) -> ImageTexture:
```

渲染一个 Mesh 缩略图纹理。

Parameters:

| Name | Description |
|---|---|
| `mesh` | 要渲染的 Mesh。 |
| `size` | 输出尺寸。 |
| `transparent` | 是否透明背景。 |

Returns: 渲染出的 ImageTexture；失败时返回 null。

#### `render_mesh_library_previews`

- API: `public`

```gdscript
func render_mesh_library_previews( mesh_library: MeshLibrary, size: Vector2i = Vector2i(128, 128), overwrite_existing: bool = true ) -> int:
```

为 MeshLibrary 批量生成条目预览。

Parameters:

| Name | Description |
|---|---|
| `mesh_library` | 目标 MeshLibrary。 |
| `size` | 预览尺寸。 |
| `overwrite_existing` | 是否覆盖已有预览。 |

Returns: 成功生成的预览数量。

## GFTimeProvider

- Path: `addons/gf/kernel/base/gf_time_provider.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFTimeProvider: 架构 tick 时间缩放协议。 该基类只定义 `GFArchitecture` 需要理解的时间控制契约。 具体时间工具可以继承它来提供暂停、缩放和物理子步能力。

### Methods

#### `get_scaled_delta`

- API: `public`

```gdscript
func get_scaled_delta(delta: float) -> float:
```

获取普通 tick 使用的 delta。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始帧间隔时间。 |

Returns: 模块应接收的 delta。

#### `get_physics_scaled_delta_steps`

- API: `public`

```gdscript
func get_physics_scaled_delta_steps(delta: float) -> Array[float]:
```

获取 physics_tick 使用的 delta 子步数组。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始物理帧间隔时间。 |

Returns: 模块应依次接收的 physics delta。

#### `should_substep_physics`

- API: `public`

```gdscript
func should_substep_physics(delta: float) -> bool:
```

判断当前物理帧是否需要拆分为多个子步。

Parameters:

| Name | Description |
|---|---|
| `delta` | 引擎原始物理帧间隔时间。 |

Returns: 需要拆分时返回 true。

#### `is_time_paused`

- API: `public`

```gdscript
func is_time_paused() -> bool:
```

检查当前时间提供者是否处于全局暂停状态。

Returns: 暂停时返回 true。

## GFTypeEventSystem

- Path: `addons/gf/kernel/core/gf_type_event_system.gd`
- Extends: `Object`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFTypeEventSystem: 基于类型和 StringName 的双轨事件系统。 轨道一（类型事件）：使用 Script 类型作为键，以对象实例为载体分发事件。 轨道二（简单事件）：使用 StringName 作为键，以 Variant 为 payload 分发事件。

### Constants

#### `DEFAULT_MAX_DISPATCH_DEPTH`

- API: `public`

```gdscript
const DEFAULT_MAX_DISPATCH_DEPTH: int = 64
```

默认最大事件嵌套派发深度。

### Properties

#### `max_dispatch_depth`

- API: `public`

```gdscript
var max_dispatch_depth: int = DEFAULT_MAX_DISPATCH_DEPTH:
```

最大事件嵌套派发深度。小于等于 0 时不限制。

#### `trace_enabled`

- API: `public`

```gdscript
var trace_enabled: bool = false
```

是否记录事件派发追踪。默认关闭，避免调试数据持有过多运行时引用。

#### `max_trace_entries`

- API: `public`

```gdscript
var max_trace_entries: int = 64:
```

最多保留的事件派发追踪条目数。

### Methods

#### `register`

- API: `public`

```gdscript
func register(event_type: Script, on_event: Callable, priority: int = 0, owner: Object = null) -> void:
```

注册特定脚本类型的事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要监听的脚本类型。 |
| `on_event` | 事件发送时执行的回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |
| `owner` | 可选监听拥有者，用于批量注销。 |

#### `unregister`

- API: `public`

```gdscript
func unregister(event_type: Script, on_event: Callable) -> void:
```

注销特定脚本类型的事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_type` | 要注销的脚本类型。 |
| `on_event` | 要移除的回调函数。 |

#### `register_assignable`

- API: `public`

```gdscript
func register_assignable(base_event_type: Script, on_event: Callable, priority: int = 0, owner: Object = null) -> void:
```

注册可赋值类型事件监听器。 监听 base_event_type 时，也会收到继承自该脚本类型的事件实例。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 要监听的基类脚本类型。 |
| `on_event` | 事件发送时执行的回调函数。 |
| `priority` | 回调优先级，数值越大越先执行，默认为 0。 |
| `owner` | 可选监听拥有者，用于批量注销。 |

#### `unregister_assignable`

- API: `public`

```gdscript
func unregister_assignable(base_event_type: Script, on_event: Callable) -> void:
```

注销可赋值类型事件监听器。

Parameters:

| Name | Description |
|---|---|
| `base_event_type` | 注册时使用的基类脚本类型。 |
| `on_event` | 要移除的回调函数。 |

#### `send`

- API: `public`

```gdscript
func send(event_instance: Object) -> void:
```

将事件实例发送给其脚本类型的所有注册监听器。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `register_simple`

- API: `public`

```gdscript
func register_simple(event_id: StringName, on_event: Callable, owner: Object = null) -> void:
```

注册轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `on_event` | 回调函数，签名为 func(payload: Variant)。 |
| `owner` | 可选监听拥有者，用于批量注销。 |

#### `unregister_simple`

- API: `public`

```gdscript
func unregister_simple(event_id: StringName, on_event: Callable) -> void:
```

注销轻量级 StringName 事件监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `on_event` | 要移除的回调函数。 |

#### `send_simple`

- API: `public`

```gdscript
func send_simple(event_id: StringName, payload: Variant = null) -> void:
```

将 payload 发送给指定 StringName 事件的所有注册监听器。

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 传递给监听器的数据，可为任意类型。 |

Schemas:

- `payload`: Variant payload passed unchanged to simple event listeners.

#### `unregister_owner`

- API: `public`

```gdscript
func unregister_owner(owner: Object) -> void:
```

注销指定拥有者注册过的所有事件监听器。

Parameters:

| Name | Description |
|---|---|
| `owner` | 监听拥有者。 |

#### `get_debug_stats`

- API: `public`

```gdscript
func get_debug_stats() -> Dictionary:
```

获取事件系统诊断统计。

Returns: 包含类型事件、可赋值事件和简单事件监听数量的字典。

Schemas:

- `return`: Dictionary containing listener counts, pending operation counts, dispatch counters, depth limits, and trace counters.

#### `get_dispatch_trace`

- API: `public`

```gdscript
func get_dispatch_trace() -> Array[Dictionary]:
```

获取最近事件派发追踪条目。

Returns: 从旧到新的追踪条目副本。

Schemas:

- `return`: Array of Dictionary trace entries with event, listener, owner, and dispatch metadata.

#### `clear_dispatch_trace`

- API: `public`

```gdscript
func clear_dispatch_trace() -> void:
```

清空事件派发追踪。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有已注册的事件监听器（包括类型事件和简单事件）。

## GFUtility

- Path: `addons/gf/kernel/base/gf_utility.gd`
- Extends: `Object`
- API: `public`
- Category: `protocol`
- Since: `3.17.0`

GFUtility: 工具组件抽象基类。 提供不依赖其他架构组件的独立工具功能。 子类可以实现 'init'、'async_init'、'ready'、 'dispose' 来管理其生命周期。 三阶段初始化约定： - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。 - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。 - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。

### Properties

#### `ignore_pause`

- API: `public`

```gdscript
var ignore_pause: bool = false
```

是否忽略全局暂停。为 true 时，即使当前 GFTimeProvider 处于暂停状态， 该 Utility 的 tick / physics_tick 仍会接收到原始（未缩放）的 delta 值。

#### `ignore_time_scale`

- API: `public`

```gdscript
var ignore_time_scale: bool = false
```

是否忽略当前 GFTimeProvider 的时间缩放。为 true 且未全局暂停时， 该 Utility 的 tick / physics_tick 会接收到原始 delta。

#### `lifecycle_priority`

- API: `public`

```gdscript
var lifecycle_priority: int = 0
```

生命周期优先级。数值越大越早执行 init/async_init/ready，dispose 时越晚释放。 默认 0 表示同优先级下按注册顺序执行；只有存在明确依赖顺序时才建议设置。

#### `tick_priority`

- API: `public`

```gdscript
var tick_priority: int = 0
```

每帧 tick 优先级。数值越大越早执行 tick()。 默认 0 表示同优先级下按注册顺序执行。

#### `physics_tick_priority`

- API: `public`

```gdscript
var physics_tick_priority: int = 0
```

物理帧 tick 优先级。数值越大越早执行 physics_tick()。 默认 0 表示同优先级下按注册顺序执行。

#### `tick_enabled`

- API: `public`

```gdscript
var tick_enabled: bool = false:
```

是否显式加入每帧 tick 缓存。 实现 tick() 的旧项目无需设置；仅在需要强制声明运行时 tick 能力时启用。

#### `physics_tick_enabled`

- API: `public`

```gdscript
var physics_tick_enabled: bool = false:
```

是否显式加入物理帧 tick 缓存。 实现 physics_tick() 的旧项目无需设置；仅在需要强制声明运行时 physics_tick 能力时启用。

### Methods

#### `init`

- API: `public`

```gdscript
func init() -> void:
```

第一阶段初始化。子类可以重写此方法。 约束：只允许初始化自身内部变量，不得跨模块获取依赖。

#### `async_init`

- API: `public`

```gdscript
func async_init() -> void:
```

异步初始化阶段。子类可以重写此方法并在其中使用 await。 Godot 4 支持在 void 函数内部使用 await，框架的 Gf.init() 会串行且安全地 await 每个模块的 async_init()，不再需要返回 Signal。 约束：在 init() 之后、ready() 之前执行。

#### `ready`

- API: `public`

```gdscript
func ready() -> void:
```

第三阶段初始化。子类可以重写此方法。 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。

#### `dispose`

- API: `public`

```gdscript
func dispose() -> void:
```

销毁工具。子类可以重写此方法。

#### `is_lifecycle_active`

- API: `public`

```gdscript
func is_lifecycle_active() -> bool:
```

检查所属架构生命周期是否仍可安全继续异步写回。 async_init() 或其他 await 之后写入状态前建议检查该值。

Returns: 所属架构仍处于活动生命周期时返回 true。

#### `is_ready_in_architecture`

- API: `public`

```gdscript
func is_ready_in_architecture() -> bool:
```

检查当前模块是否已经完成 ready 阶段。

Returns: 当前模块完成 ready 阶段时返回 true。

#### `get_model`

- API: `public`

```gdscript
func get_model(model_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Model 实例。

Parameters:

| Name | Description |
|---|---|
| `model_type` | 模型的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 模型实例。

#### `get_system`

- API: `public`

```gdscript
func get_system(system_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 System 实例。

Parameters:

| Name | Description |
|---|---|
| `system_type` | 系统的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 系统实例。

#### `get_utility`

- API: `public`

```gdscript
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
```

通过类型获取 Utility 实例。

Parameters:

| Name | Description |
|---|---|
| `utility_type` | 工具的脚本类型。 |
| `require_ready` | 为 true 时，仅返回已完成 ready 阶段的实例。 |

Returns: 工具实例。

#### `register_event`

- API: `public`

```gdscript
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
```

注册类型事件监听器。Utility 注销时框架会自动清理由该方法注册的监听。

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

注册可赋值类型事件监听器。Utility 注销时框架会自动清理由该方法注册的监听。

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

#### `send_event`

- API: `public`

```gdscript
func send_event(event_instance: Object) -> void:
```

向架构发送类型事件。

Parameters:

| Name | Description |
|---|---|
| `event_instance` | 要分发的事件实例。 |

#### `register_simple_event`

- API: `public`

```gdscript
func register_simple_event(event_id: StringName, callback: Callable) -> void:
```

注册轻量级 StringName 事件监听器。Utility 注销时框架会自动清理由该方法注册的监听。

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

#### `send_simple_event`

- API: `public`

```gdscript
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
```

发送轻量级 StringName 事件，避免高频 new() 带来的 GC 压力。 "type": "Variant", "description": "事件附加数据；由事件消费者约定结构。" }

Parameters:

| Name | Description |
|---|---|
| `event_id` | StringName 事件标识符。 |
| `payload` | 可选的事件附加数据。 |

Schemas:

- `payload {`: 

