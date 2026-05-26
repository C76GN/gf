# 切换与 Transition 配置

`GFSceneUtility` 用于切换主场景、播放 Loading 过渡、后台预加载资源，并在切换时清理旧场景专用模块。

```gdscript
var scene_util := Gf.get_utility(GFSceneUtility) as GFSceneUtility

# 标记 BattleSystem 为瞬态，它会在切场景时自动从架构中被注销/销毁。
scene_util.mark_transient(BattleSystem)

# 开始带 Loading 过渡的异步切换。
scene_util.load_scene_async("res://levels/level_2.tscn", "res://ui/loading_screen.tscn")
```

如果项目希望把切换参数做成资源，可使用 `GFSceneTransitionConfig`：

```gdscript
var transition := GFSceneTransitionConfig.new()
transition.target_scene_path = "res://levels/level_2.tscn"
transition.loading_scene_path = "res://ui/loading_screen.tscn"
transition.preload_before_change = true
transition.cache_loaded_scene = true
transition.params = { "spawn_point": "gate_a" }
transition.minimum_duration_seconds = 0.35

scene_util.load_scene_with_transition(transition)
```

`minimum_duration_seconds` 只控制 loading scene 至少停留多久，避免缓存命中时过渡 UI 一闪而过；它不替代目标场景自己的初始化等待。
