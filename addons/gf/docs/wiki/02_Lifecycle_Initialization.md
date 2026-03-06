# 02. 生命周期与初始化 (Lifecycle)

Godot 原生的节点初始化机制 (`_enter_tree`, `_ready`) 依赖场景树的加载顺序。这种方式经常导致"模块间的启动顺序无法保障"以及"异步依赖阻塞主线程"的问题。

GF Framework 抛弃了基于节点的初始化学说，为底层的 `Model`, `System`, `Utility` 引入了独立可控的**三阶段初始化模型**。

## 注册阶段 (`boot`)

在游戏启动之初（通常在根节点的首个场景或 AutoLoad 执行），你需要手动向 `GFArchitecture` 注册你的模块。推荐顺序是：**数据 -> 工具 -> 系统**。

```gdscript
# boot.gd (游戏的启动引导脚本)
func _ready():
    # 1. 注册核心数据
    Gf.register_model(PlayerModel.new())
    Gf.register_model(InventoryModel.new())
    
    # 2. 注册底层工具
    Gf.register_utility(GFStorageUtility.new())
    Gf.register_utility(GFAssetUtility.new())
    
    # 3. 注册业务逻辑统
    Gf.register_system(BattleSystem.new())
    Gf.register_system(QuestSystem.new())
    
    # 全部注册完毕后，启动生命周期引擎
    await Gf.init()
    
    # 启动游戏初始场景
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

---

## 模块的三阶段初始化

当你调用 `Gf.init()` 后，框架会自动按照注册的顺序，遍历所有的模块组件，并依次触发以下三个阶段。

所有的 `GFModel`、`GFSystem` 和 `GFUtility` 基类都提供了这三个虚方法供你重写：

### 阶段一：同步初始化 `init()`

```gdscript
func init() -> void:
    # 同步的初步设置
```
- **执行顺序**：首先遍历并调用所有实例的 `init()` 方法。
- **作用**：适合执行没有任何外部依赖、立即完成的轻量化参数设置，比如绑定初始的响应式属性、设置默认数值等。

> 此时不能保证其他模块已经甚至了 `init()`，因此不建议在此处频繁跨模块调用。

### 阶段二：异步等待 `async_init()`

```gdscript
func async_init() -> void:
    # 异步加载完成后的处理
    # Godot 4 支持在返回 void 的函数内直接使用 await
    await GF.get_utility(GFAssetUtility).load_assets_async(["res://data/tables.json"])
```
- **执行顺序**：在所有 `init()` 执行完毕后，遍历所有的 `async_init()`。
- **作用**：该函数返回 `void`。如果该模块有网络请求、本地 IO 读取、或者大批量资源异步加载等慢操作，可以在这里使用 `await` 等待其完成。
- **机制**：Godot 4 支持在 `void` 函数内部使用 `await`，框架的 `Gf.init()` 引擎会自动串行且安全地 `await` 每个模块的 `async_init()`，不再需要手动返回 `Signal`。这完美解决了模块在异步加载未完成前就被迫参战的问题。

### 阶段三：就绪完成 `ready()`

```gdscript
func ready() -> void:
    # 注册事件监听，可以安全调用其他模块
    Gf.listen(EventConst.GAME_STARTED, _on_game_started)
```
- **执行顺序**：在所有模块的 `async_init()` 均宣告结束后触发。
- **作用**：这意味着当前整个游戏框架已完全挂载并且所有前置异步资源均已就位。此时模块可以安全地获取其他任何 `Model`、`System` 进行交叉调用与事件监听。

---

## Controller (表现层) 的初始化

表现层的控制器由于依附于 Godot 原生场景树（继承于 `Node`），它们的初始化游离于这套框架体系之外。

控制器在进入场景树时会执行其原生的 `_ready()` 方法。在控制器的 `_ready()` 中，你应该：

1. 获取场景节点引用（如 Label, AnimationPlayer）。
2. 从 `Gf` 获取你需要的 `Model` 或 `System`。
3. 绑定关注的数据属性（BindableProperty）。
4. 更新初始显示的界面状态。

```gdscript
class_name HUDController extends GFController

@onready var hp_bar: ProgressBar = $HealthBar

func _ready() -> void:
    # 原生 Godot 初始化...
    var user_model := Gf.get_model(UserModel) as UserModel
    
    # 绑定数据变更回调
    user_model.health.value_changed.connect(_on_health_changed)
    
    # 初始化视图
    _on_health_changed(user_model.health.value)

func _on_health_changed(new_val: float) -> void:
    hp_bar.value = new_val
```
