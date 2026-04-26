## GFInstaller: 项目启动装配脚本基类。
##
## 继承后重写 install()，并在 Project Settings 的 gf/project/installers 中登记脚本路径，
## Gf.init() 与 Gf.set_architecture() 会在架构初始化前自动执行这些安装器。
class_name GFInstaller
extends RefCounted


# --- 公共方法 ---

## 将项目模块注册到架构。
## @param architecture: 当前即将初始化的架构实例。
func install(_architecture: GFArchitecture) -> void:
	pass

