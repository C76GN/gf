## GFInstaller: 项目启动装配脚本基类。
##
## 继承后重写 install()，并在 Project Settings 的 gf/project/installers 中登记脚本路径，
## Gf.init() 与 Gf.set_architecture() 会在架构初始化前自动执行这些安装器。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFInstaller
extends RefCounted


# --- 公共方法 ---

## 将项目模块注册到架构。
## [br]
## @api public
## [br]
## @param _architecture: 当前即将初始化的架构实例。
func install(_architecture: GFArchitecture) -> void:
	pass


## 使用声明式装配器注册项目模块。
## [br]
## @api public
## [br]
## @param _binder: 绑定到当前架构的装配器。
## [br]
## @schema _binder {
##   "type": "Variant",
##   "description": "当前架构创建的装配器实例，实际类型为 GFBindBuilder。"
## }
func install_bindings(_binder: Variant) -> void:
	pass
