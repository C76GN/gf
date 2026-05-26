# 重映射配置与 Profile

运行时改键通过 `GFInputRemapConfig` 保存覆盖项。默认绑定仍留在上下文资源中，配置只记录用户或项目层修改过的部分。

```gdscript
var remap := GFInputRemapConfig.new()
input_map.set_remap_config(remap)
input_map.set_binding_override(&"gameplay", &"jump", 0, new_input_event)
var saved_remap := remap.to_dict()
var restored_remap := GFInputRemapConfig.from_dict(saved_remap)
```

如果项目需要多套可命名的键位配置，可以用 `GFInputProfileBank` 保存多个 `GFInputRemapConfig`。Bank 只管理 profile id 与重映射资源，不规定账号、玩家编号、存档槽位或设置界面结构。

```gdscript
var profiles := GFInputProfileBank.new()
profiles.set_profile(&"keyboard", input_map.get_remap_config(true))
profiles.ensure_profile(&"gamepad")
profiles.set_active_profile(&"gamepad")

input_map.set_remap_config(profiles.get_active_profile())
```

`GFInputRemapConfig.to_dict()` 会把覆盖的 `InputEvent` 与显式解绑记录转换为可写入配置或存档的字典，`from_dict()` 可恢复，`duplicate_config()` 会用同一套持久化格式做深拷贝；默认绑定仍来自上下文资源，不会被复制进重映射配置。

新的重映射记录使用白名单事件类型和结构化属性，不再为新数据写入 `str_to_var()` 文本；旧格式仍可被读取，便于已有存档渐进迁移。
