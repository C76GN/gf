# Modal 协议

`modal` / `PanelMode.MODAL` 表达“项目层应该把该面板视为独占交互面板”。框架会提供取消关闭、打开抢焦点、关闭恢复焦点和 `keep_focus_inside_top_modal()` 等辅助；它不创建遮罩、不播放动画、不拦截输入树，也不决定页面返回值。项目可以监听 `panel_dismiss_requested` 处理音效、路由记录或二次确认。

## 结果协议

需要通用确认或选择流程时，使用 `GFModalConfig`、`GFModalAction` 和 `GFModalResult` 描述动作与返回值。框架不提供默认弹窗视觉实现；项目应使用自己的 `.tscn` 面板渲染标题、正文、按钮、动画、音效、主题和输入规则。

```gdscript
var action := GFModalAction.new()
action.action_id = &"confirm"
action.label = "Confirm"
action.result_status = GFModalResult.STATUS_CONFIRMED

var config := GFModalConfig.new()
config.title = "Confirm"
config.message = "Continue?"
config.actions = [action]

var panel := ui_util.push_panel_with_options("res://ui/confirm_modal.tscn", GFUIUtility.Layer.POPUP, {
	"mode": GFUIUtility.PanelMode.MODAL,
	"dismiss_on_cancel": config.dismiss_on_cancel,
	"focus_on_open": config.auto_focus,
	"restore_focus_on_close": config.restore_focus_on_close,
	"metadata": config.metadata,
}, func(instance: Node) -> void:
	instance.call("configure", config, { "source": "settings" })
	var on_resolved := func(result: GFModalResult) -> void:
		ui_util.pop_panel(GFUIUtility.Layer.POPUP)
		if result.status == GFModalResult.STATUS_CONFIRMED:
			print(result.context)
	instance.connect("resolved", on_resolved, CONNECT_ONE_SHOT)
)
```

## 项目面板约定

项目 Modal 面板可以约定实现以下接口：

- `configure(config: GFModalConfig, context: Dictionary)`：接收配置和项目上下文。
- `resolve_cancel()`：处理取消请求，可播放动画、给出提示或拒绝关闭。
- `resolved(result: GFModalResult)`：向调用方返回最终结果。

`request_dismiss_top()` 会在允许取消时优先调用栈顶面板的 `resolve_cancel()`。是否关闭、何时关闭、是否等待转场结束，由项目面板在发出 `resolved` 前后自行决定。
