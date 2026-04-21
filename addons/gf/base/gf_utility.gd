class_name GFUtility


## GFUtility: 工具组件抽象基类。
##
## 提供不依赖其他架构组件的独立工具功能。
## 子类可以实现 'init'、'async_init'、'ready'、 'dispose' 来管理其生命周期。
##
## 三阶段初始化约定：
##   - 'init'       阶段：只允许初始化自身内部变量，禁止跨模块获取依赖。
##   - 'async_init' 阶段：可使用 await，用于异步资源加载等操作。
##   - 'ready'      阶段：架构内所有模块均已完成 'init'，可安全跨模块获取依赖。


# --- 公共变量 ---

## 是否忽略全局暂停。为 true 时，即使 GFTimeUtility.is_paused 为 true，
## 该 Utility 的 tick / physics_tick 仍会接收到原始（未缩放）的 delta 值。
var ignore_pause: bool = false


# --- Godot 生命周期方法 ---

## 第一阶段初始化。子类可以重写此方法。
## 约束：只允许初始化自身内部变量，不得跨模块获取依赖。
func init() -> void:
	pass


## 异步初始化阶段。子类可以重写此方法并在其中使用 await。
## Godot 4 支持在 void 函数内部使用 await，框架的 Gf.init() 会串行且安全地 await 每个模块的 async_init()，不再需要返回 Signal。
## 约束：在 init() 之后、ready() 之前执行。
func async_init() -> void:
	pass


## 第二阶段初始化。子类可以重写此方法。
## 约束：此时所有模块已完成 'init'，可安全跨模块获取依赖。
func ready() -> void:
	pass


## 销毁工具。子类可以重写此方法。
func dispose() -> void:
	pass
