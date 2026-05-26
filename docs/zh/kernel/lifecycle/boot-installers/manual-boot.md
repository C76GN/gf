# 手动启动注册

在游戏启动之初，通常在根节点的首个场景或 AutoLoad 执行，项目可以手动向 `GFArchitecture` 注册模块。推荐顺序是数据、工具、系统。

```gdscript
# boot.gd
func _ready():
	# 1. 注册核心数据
	await Gf.register_model(PlayerModel.new())
	await Gf.register_model(InventoryModel.new())

	# 2. 注册底层工具
	await Gf.register_utility(GFStorageUtility.new())
	await Gf.register_utility(GFAssetUtility.new())

	# 3. 注册业务逻辑系统
	await Gf.register_system(BattleSystem.new())
	await Gf.register_system(QuestSystem.new())

	# 全部注册完毕后，启动生命周期引擎
	await Gf.init()

	# 启动游戏初始场景
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

手动 boot 适合小型项目、原型和希望显式控制启动顺序的工程。项目规模扩大后，可以把装配逻辑迁移到项目级 Installer。
