# 最佳实践、维护与测试

本页收拢 GF 项目的落地建议、分层边界、包使用规则和维护检查流程。

## 使用类型断言

从架构中取得模块后，推荐立刻使用 `as Type` 获得明确类型。这样能保留 IDE 补全，也能让调用点更清楚。

```gdscript
var player_model := Gf.get_model(PlayerModel) as PlayerModel
if player_model == null:
	return

player_model.set_run_speed(30.0)
```

如果一个查询可能失败，调用点应该显式处理 `null`。不要把依赖缺失隐藏在后续属性访问错误里。

## 不要让 Model 只剩字段

`GFModel` 是数据层，但不是只能保存裸变量。和数据一致性直接相关的操作应放在 Model 内部，例如生命值钳制、背包容量限制、进度合并和状态快照。

```gdscript
class_name PlayerModel
extends GFModel

var hp: int = 100
var max_hp: int = 100


func apply_damage(amount: int) -> void:
	hp = maxi(hp - maxi(amount, 0), 0)


func heal(amount: int) -> void:
	hp = mini(hp + maxi(amount, 0), max_hp)
```

`GFSystem` 负责规则流程，`GFModel` 负责状态自身的合法性。这样即使多个系统修改同一个 Model，也更不容易写出非法状态。

## Controller 应该可以被删除

`GFController` 是 Godot 场景树和 GF 架构之间的桥。它可以处理输入、动画、UI、节点引用和场景信号，但核心业务规则不应写死在 Controller 中。

一个简单检验是：删除某个表现节点后，底层 Model 和 System 是否仍能正常推进。如果删除 UI、角色显示节点或特效节点就让核心规则无法运行，说明表现层承担了过多职责。

## 合理使用事件

事件适合跨模块通知，但不适合替代所有函数调用。

- UI 展示 Model 字段变化时，优先用 `GFBindableProperty` 或明确的绑定逻辑。
- 同一个类内部的连续步骤，直接调用私有方法。
- 同一 System 内部的计算流程，直接传参。
- 跨 System、跨 Utility 或跨局部上下文的通知，再使用类型事件或 simple 事件。

事件监听应优先绑定 owner。动态节点、临时模块和场景对象释放时，应通过 owner 让框架自动清理监听。

## ready() 中保持防御

GF 会按生命周期阶段推进模块，但大型项目中模块可能由包 Installer、项目 Installer、局部 `GFNodeContext` 和运行时动态注册共同装配。`ready()` 中读取其他模块时，应允许依赖暂时不存在或尚未完成 ready。

需要强依赖时，使用依赖诊断或在 Installer 中明确装配顺序；需要弱依赖时，使用 `get_utility(..., require_ready = true)` 这类查询，并在缺失时跳过本轮逻辑。

## 分清代码归属

新增能力时，先判断它属于哪一层：

- `kernel`：GF 启动、架构容器、基础契约、事件、绑定、包基础设施、核心编辑器装配。
- `standard/foundation`：纯值对象、纯算法、纯格式化、纯转换、纯校验。
- `standard/utilities`：默认稳定、足够通用、需要生命周期或运行时状态的服务。
- `standard/input`、`standard/state_machine`、`standard/sequence`：稳定标准能力。
- `packages/official`：通用但可选的官方能力。
- `packages/community`：项目本地、社区或更偏业务的包。
- 项目代码：具体玩法、关卡、SDK 适配、资源路径、业务表结构。

如果一个能力不需要框架生命周期，优先保持为纯对象或 Resource；如果它开始管理缓存、异步、事件、全局状态或跨模块服务，再考虑成为 Utility 或包 Installer 注册项。

新增跨层能力时还要遵守加载边界：

- `kernel` 不能直接引用 `standard` 或官方包的具体类名；需要内核识别的能力先抽成 kernel 契约。
- `kernel/editor` 不能硬编码可选包 ID、包模板或包内 Inspector；这些能力由包 manifest 注入。
- `standard` 不能硬 preload 官方包、写死官方包脚本路径、硬编码官方包 ID、动态探测官方包或直接类型引用官方包类。
- 可选包需要出现在诊断、Overlay、工具快照或其他标准库通道时，必须由包侧向标准库提供的通用注册入口主动贡献。

## Godot 物理以引擎为准

碰撞、刚体、导航、Area 和 RayCast 这类能力应由 Godot 节点负责采集事实，再交给 GF 的命令、事件或系统处理业务结果。

推荐流程：

1. Controller 或桥接节点读取 Godot 物理结果。
2. 把命中、接触、输入或区域变化转换成清晰的命令/事件/Payload。
3. System 根据这些事实修改 Model 或派发后续结果。

不要在纯 System 中维护一套和 Godot 场景树并行的“影子物理世界”，除非它是明确的纯模拟模型，并且不依赖实际场景节点。

## Controller 宿主引用

当 Controller 作为某个场景节点的输入、动画或状态桥接层时，推荐把 Controller 放在宿主节点下面，并使用 `get_host()`、`get_host_as()` 或 `host` 获取宿主引用。

```gdscript
class_name MovementController
extends GFController

@export var speed: float = 160.0

@onready var _body: CharacterBody2D = get_host_as(CharacterBody2D) as CharacterBody2D


func _physics_process(_delta: float) -> void:
	if _body == null:
		return

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_body.velocity = input_vector * speed
	_body.move_and_slide()
```

不推荐把 `owner` 当作运行时宿主引用。`owner` 表示编辑器场景所有权，不等同于父节点，也不一定是逻辑控制目标。

## 包使用规则

官方包默认随 GF 启用，但仍保持可选边界。项目不用某个官方包时，可以在 `GF Packages` 面板禁用它；如果导出时启用了排除禁用包，包目录不会进入导出产物。

禁用或删除包前，应确认项目没有直接引用该包：

- 脚本中的 `preload()` / `load()` 路径。
- 场景、资源或导入文件中的脚本路径。
- 生成访问器中的包类型或包路径。
- 直接使用包内 `class_name` 的类型声明。

`GF Packages` 面板提供“扫描引用”，导出开始时也会检查禁用包引用。发布前可启用“引用禁用包时阻止导出”，把这类问题提升为导出错误。

分层边界必须按硬规则维护：`kernel` 不认识 `standard` 或任何 package；`standard` 只认识 `kernel`，不能通过包 ID、包路径、动态脚本探测或包内类名弱联动官方包；`packages` 可以依赖 `kernel` 和稳定的 `standard`，但官方包之间也不能通过其他官方包路径或包 ID 暗中探测。需要跨包协作时，应使用上层通用协议、显式注册点或项目装配。如果包功能需要显示在标准库诊断、Overlay 或工具快照里，应由包侧向标准库的通用注册入口贡献能力，而不是在标准库中写包探测逻辑。

## 测试建议

源码变更后优先运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

测试目录按框架层级组织：

- `tests/gf_core/maintenance`：API 注释、GDScript 布局、脚本解析、包边界等静态维护检查。
- `tests/gf_core/kernel`：内核、生命周期、事件、编辑器基础设施和包基础设施。
- `tests/gf_core/standard`：标准库。
- `tests/gf_core/packages/official`：官方包。
- `tests/gf_core/fixtures`：测试夹具。

迁移目录或重命名公开类后，维护测试还会检查旧源码路径、旧公开类名、重复 `class_name` 和 `.gd.uid` 冲突。不要为了兼容旧路径保留副本脚本；3.0.0 的路径迁移应通过 changelog 和迁移指南说明，而不是在源码里留下双入口。

公开 API、文档或生成器变化后，还应检查正式文档覆盖：

```powershell
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api --check --check-wiki-coverage
```

## 文档维护

文档应按功能归属更新：

- 内核、生命周期、依赖、事件、命令、查询：更新 `01` 到 `03`。
- 场景树、Controller、数据绑定、更新循环：更新 `04`。
- Foundation 与 Standard Utilities：更新 `05` 到 `08`。
- 包规范和官方包：更新 `09` 到 `12`。
- 编辑器工具和代码生成：更新 `13`。
- 维护流程、测试和最佳实践：更新本页。

行为变化、公开 API 变化、路径迁移、移除和升级说明应写入 `更新日志 (Changelog).md`。

根 README 使用双语入口：`README.md` 是 GitHub 默认英文页，`README.zh.md` 是中文页。两者应保持同一章节顺序和信息粒度；安装步骤、核心概念、分层说明、测试命令和文档入口变化时必须同步更新。`addons/gf/README.md` 只作为插件目录内的简短分发说明，链接根 README 与 Read the Docs，不承载完整正文。

## Read the Docs 结构

GF 文档使用 MkDocs 构建，并由 Read the Docs 托管。源码结构如下：

- `docs/zh/` 是中文文档源文件。
- `docs/en/` 是未来英文文档源文件。
- `mkdocs.yml` 维护全站导航、主题和 Markdown 扩展。
- `.readthedocs.yaml` 维护 Read the Docs 构建环境。
- `docs/requirements.txt` 锁定文档构建依赖。
- `docs/wiki/` 只保留 GitHub Wiki 的 Home、Sidebar 和 Footer 入口，不再作为正式正文来源。

调整阅读顺序、增加页面或重命名页面时，应同步检查 `mkdocs.yml`、`docs/zh/index.md`、`README.md` 和站内交叉链接。除非确实改变页面职责，不应为了局部措辞优化重命名文件；文档 URL 会跟随 slug 变化，反复重命名会影响外部链接和翻译配对。

站内链接使用标准 Markdown 相对链接，例如 `[本地存储、编码、同步与快照](../standard/utilities/io/storage-snapshot.md)`。指向源码、命令、类名、设置键和文件路径时继续使用反引号。

`docs/zh` 的文件目录应和网站导航保持一致：顶层是 `overview/`、`kernel/`、`standard/`、`packages/`、`editor/`、`maintenance/` 等语义目录，顶层 Markdown 只保留 `index.md`、`faq.md` 和 `changelog.md`。各组的 `index.md` 只作为导读，例如 `../standard/utilities/io/index.md` 负责说明资源、存储与 IO 的页面入口；具体能力放到所属语义目录下的子页，例如 `../standard/utilities/io/storage-snapshot.md`。新增专题时优先追加同组子页，不要把无关能力重新堆回一个长页面。

`tests/gf_core/maintenance/test_docs_structure_validation.gd` 会检查 `docs/zh` 页面是否进入 `mkdocs.yml` 导航、导航路径是否真实存在、顶层目录是否为允许的语义目录、旧编号目录是否没有回流，并确认旧 GitHub Wiki 目录只保留入口文件。这类结构问题应先修测试失败，再补正文内容。

旧 Wiki 不再维护正文副本、章节页或迁移页。`docs/wiki/Home.md`、`_Sidebar.md` 和 `_Footer.md` 只提供 Read the Docs 入口。需要修改正式内容时，应修改 `docs/zh/**`，再由 MkDocs / Read the Docs 发布。

## 本地化维护

后续维护中英文两份文档时，应把“编号 + 章节顺序”作为对齐标准，而不是只依赖翻译后的标题：

- 中文页和英文页保留相同语义目录与子页 slug，例如 `standard/utilities/io/storage-snapshot.md` 对应同一个存储与快照主题。
- 同 slug 页面保持相同一级标题数量和主要二级标题顺序；允许翻译标题，但不要改变内容边界。
- 代码示例、类名、方法名、ProjectSettings 键、路径、manifest 字段和命令行保持一致，不做语言本地化。
- 中文页新增或删除一段行为说明时，英文页应同步新增或删除同一信息；如果暂时不能翻译，应在维护记录或 PR 描述中明确标记待同步页。
- 不把同一概念复制到两种语言的多个页面中。中文和英文都应遵循“一个概念一个主说明页，其他页面只交叉引用”的规则。
- Changelog 的版本、API Changes 和 Migration Guide 应保持事实一致；翻译可以不同，但不得让两个语言版本描述出不同迁移路径。

双语文档准备阶段不建议先批量生成粗糙译文。应先保证中文主线页面边界稳定、重复内容归零、示例可运行，再按编号逐页翻译和校验。
