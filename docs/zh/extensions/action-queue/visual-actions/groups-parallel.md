# 复合动作与并行执行

`GFVisualActionGroup` 可以将一组 `GFVisualAction` 打包为一个大动作。

```gdscript
# 将两张卡牌的移动动作并行执行，全部完成后再进入后续动作。
var group: GFVisualActionGroup = GFVisualActionGroup.new([
	GFMoveTweenAction.new(card_a, target_pos_a),
	GFMoveTweenAction.new(card_b, target_pos_b),
], true)

action_queue_sys.enqueue(group)
```

也可以直接使用 `enqueue_parallel([action_a, action_b])`，队列会把它们封装成并行动作组。
