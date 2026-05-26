# 随机种子与可复现随机流

这一页说明 `GFSeedUtility` 如何管理全局主种子、主 RNG 状态和按标签派生的独立随机流。它面向玩法确定性和回放稳定，不适合作为安全随机或服务端权威随机来源。

## 全局随机数种子管理器 (`GFSeedUtility`)

**应用场景：** 当你需要管理全局随机流以保证游戏的核心随机事件（如掉落、遇敌、甚至战斗回放）具有确定性和可观测性时。它支持恢复指定的随机序列状态，并且可以通过标签派生出完全独立的子随机发生器。

**如何使用：**
```gdscript
var seed_util := Gf.get_utility(GFSeedUtility) as GFSeedUtility

# 设置全局主种子
seed_util.set_global_seed(12345)

# 可以随时获取当前的主种子
var current_seed := seed_util.get_global_seed()

# 获取并保存当前主 RNG 的精确内部状态，为稍后的回放或状态恢复做准备
var current_state := seed_util.get_state()

# ...进行一系列随机操作...

# 恢复此前保存的状态，使得接下来的随机序列能完全复现
seed_util.set_state(current_state)

# 派生出一个专门用于某模块的子 RNG
var combat_rng := seed_util.get_branched_rng("combat_calculations")
print(combat_rng.randi())
```

`get_state()` / `set_state()` 只处理主 RNG 的内部状态；如果项目还使用了 `get_branched_rng()`，应使用 `get_full_state()` / `set_full_state()` 保存和恢复主种子、主 RNG 状态以及各标签的分支调用计数。`get_full_state()` 返回的是面向默认 JSON 存储的状态字典，当前 `state_schema_version` 为 `2`；`global_seed`、`rng_state` 和分支计数都使用十进制字符串保存，避免 Godot JSON 解析 64 位整数时丢失精度。项目层不要把这些字段改回裸数字，也不要把 `state_schema_version` 当作 GF 框架版本号。需要恢复单个整数 RNG 状态时使用 `set_state()`。`set_global_seed()` 会重置分支计数。作为 Utility 注册到架构时会正常初始化；测试或工具代码直接 `GFSeedUtility.new()` 调用公共方法时，也会懒初始化内部 RNG。

分支 RNG 的生成不会推进主 RNG 序列。同一主种子、同一主状态、同一标签和同一调用序号会得到相同的子随机序列，适合掉落表、AI 局部决策或回放中需要隔离随机流的模块。分支种子使用稳定 FNV-32 哈希，目标是玩法确定性和回放稳定，不适合作为安全随机、抽卡防作弊或服务端权威随机来源。
