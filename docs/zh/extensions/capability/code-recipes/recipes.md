# 能力组合 Recipe

当项目希望把一组能力作为可复用配置应用到不同 receiver，可以使用 `GFCapabilityRecipe`。Recipe 只描述能力条目、默认启停和分组，不规定实体类型、属性字段或玩法规则。

```gdscript
var recipe := GFCapabilityRecipe.new()
recipe.recipe_id = &"interactable_target"
recipe.groups = [&"targets"]

var entry := GFCapabilityRecipeEntry.new()
entry.capability_type = InteractableCapability
entry.active = true
recipe.entries = [entry]

var result := capabilities.apply_recipe(enemy, recipe)
if not result["ok"]:
	push_warning(result["failed"])
```

`GFCapabilityRecipeEntry` 可以通过 `capability_type` 创建普通能力，也可以通过 `scene` 挂载节点能力场景；如果两者都提供，运行时会实例化场景并按 `capability_type` 注册。

`apply_recipe()` 默认会在应用后调用依赖校验，并把新增、复用、失败条目和分组写入报告。默认 `transactional = true`，任一条目失败或依赖校验失败时，会移除本次新增能力、回滚本次新增分组，并恢复被复用能力的原 active 状态，避免留下半应用的实体预设。

确实需要“尽力应用”的工具流程，可在 options 中显式传 `{ "transactional": false }`。`remove_recipe()` 可按 Recipe 反向移除能力和可选分组。

复杂实体预设应保持为项目资源，不应把具体敌人、卡牌、任务或 UI 规则写进 GF 能力基类。
