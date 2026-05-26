# 入队与 Fire-and-Forget

普通入队示例：

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem
var grp := GFVisualActionGroup.new()
grp.add(PlayCardVisualAction.new(...))

q_sys.enqueue(grp)
```

`GFActionQueueSystem` 使用自动完成模式：`execute()` 返回 `Signal` 就等待，返回 `null` 就继续。

如果某个动作只是发出音效、粒子、非阻塞 Tween，不希望占住队列，可以显式声明 fire-and-forget。

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem

var action := GFAudioAction.new("res://audio/hit.wav")
q_sys.enqueue_fire_and_forget(action)

# 或者在动作自身上声明
q_sys.enqueue(MyParticleAction.new(...).as_fire_and_forget())
```
