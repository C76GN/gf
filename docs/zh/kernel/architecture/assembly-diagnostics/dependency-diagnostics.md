# 依赖诊断

`GFArchitecture.get_dependency_diagnostics()` 可读取已注册模块的可选依赖声明，并生成统一报告。它适合大型项目、局部 `GFNodeContext` 或插件式装配在初始化前后检查“模块声明需要什么、当前架构是否已经注册”。

诊断只读，不会自动注册缺失模块，也不会改变 `get_model()`、`get_system()`、`get_utility()` 和工厂创建的现有语义。

## 依赖声明

模块可按需实现这些 hook：

```gdscript
func get_required_models() -> Array[Script]:
	return [PlayerModel]

func get_required_utilities() -> Array[Script]:
	return [InventoryConfigUtility]

func get_required_dependencies() -> Dictionary:
	return {
		"systems": [BattleSystem],
		"factories": [DealDamageCommand],
	}
```

## 诊断调用

```gdscript
var report := architecture.get_dependency_diagnostics({
	"include_parent_lookup": true,
	"include_factories": true,
})
if not report["ok"]:
	for issue in report["issues"]:
		push_warning(issue["message"])
```

## 使用边界

依赖声明应保持抽象和稳定，优先声明模块真正需要的接口脚本、基类或别名类型；不要把具体关卡、敌人、UI 页面或临时玩法条件写进通用模块 hook。

需要按玩家进度、DLC、服务器配置或场景状态动态判断的内容，应留在项目自己的装配流程或诊断命令里。
