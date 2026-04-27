## AsyncInstallerUtilityFixture: 用于验证异步 install_bindings 会在架构初始化前完成。
extends GFUtility


# --- 公共变量 ---

## 是否已经进入 ready 阶段。
var ready_called: bool = false


# --- Godot 生命周期方法 ---

func ready() -> void:
	ready_called = true
