# 09. 最佳实践 (Best Practices)

## 🎯 #1 始终使用纯类型推断
GF Framework 不需要依赖注入或者魔法装饰器。因此必须养成良好的**在使用 `get_xx` 宏之后断言类型**的习惯，这不仅极大方便 IDE 检查拼写，同时也符合 GDScript 4 引擎级的内联优化机制。

```gdscript
# ❌ 坏习惯 (失去了代码提示)
var player_model = Gf.get_model(PlayerModel)
player_model.xx_x 

# ✅ 好习惯 (全程代码补全，打字飞快)
var player_model := Gf.get_model(PlayerModel) as PlayerModel
player_model.set_run_speed(30.0)
```

## 🎯 #2 不要让 Model 成为"贫血模型"

Model 层虽然是"数据所在的地方"，但这绝不意味着它只能含有裸露的 `var` 变量。

你可以并且应该在 Model 内部写入能够保证数据自身完整性的函数方法。比如，扣血逻辑应该放在 `PlayerModel` 内部验证（不能扣到负数），而不是每一次都在调用的 `System` 端验证。

```gdscript
# 在 PlayerModel 内部提供
func apply_damage(amount: int) -> void:
    var final_dmg = max(1, amount - self.defense)
    self.hp.value = max(0, self.hp.value - final_dmg)
```

## 🎯 #3 Controller (节点层) 就该随时可以被删除

你可以如此检验你的界限是否干净：如果在 Godot 场景编辑器里把一个人物模型节点，立刻删掉，游戏是否依然会在底层正常"打怪练级"？（例如放置类游戏）。

**永远不要把计算金币增长、任务接取判定写在继承自于 Node 的代码下层**。如果你这么做了，就意味着当你某天想重构 UI 层布局时，你的业务逻辑会随之断裂。

## 🎯 #4 注意滥用事件系统的陷阱

在初遇事件驱动时，初学者很容易陷入：**满天飞事件，代码跳来跳去，没法 Debug 追踪流向。**
请遵守如下纪律以维持项目规模变大也不失序：
1. UI 纯单纯展示数据？用 `BindableProperty`。
2. 同一个 `System` 内两个私有方法连续调用？ 直接传参，不要发内部事件。
3. 试图横跨整个 `Architecture` 通知另外一个无关系统开始干活？用 `GFPayload` 事件。

## 🎯 #5 `ready()` 不要信任任何顺序
当多个模块的 `ready` 开跑时，它们理论上的确是有按引导书册顺序运行的。但为了写出极致健壮的模块代码，你应该假设：**在 `ready` 里拿到别人数据时，应该做好防御并监听如果变化后我也跟着变**。

一旦某次更改了入口文件 `boot.gd` 而调换了两句加载顺序，如果你的模块是完全解耦独立且做好前置探测预案的，整个框架并不会因此散架崩溃。
