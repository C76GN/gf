# 通用标识

`GFUuid` 提供无状态的 UUID v4/v7 生成和 canonical 字符串校验。它属于 Foundation：不注册到 `GFArchitecture`，不读写文件，不维护全局计数，也不解释标识属于存档实体、分析会话、网络请求还是编辑器资源。

## 基础用法

```gdscript
var random_id := GFUuid.generate_v4()
var ordered_id := GFUuid.generate_v7()

if GFUuid.is_valid(random_id, 4):
	print(random_id)
```

`generate_v4()` 使用 Godot `Crypto` 生成随机字节，适合匿名客户端 ID、会话 ID、临时操作 ID 或项目层需要随机唯一字符串的场景。`generate_v7()` 把 Unix epoch 毫秒写入前 48 位，适合日志、快照、请求、编辑器生成记录等需要大致按生成时间排序的场景。

## 使用边界

- `GFUuid` 只保证字符串形态、版本位和 RFC variant 位，不维护注册表，也不检查项目内唯一性。
- 需要可复现随机序列时继续使用 `GFSeedUtility`；UUID 生成面向唯一标识，不应参与回放确定性。
- 需要业务含义时，把字段名和生命周期放在调用方，例如 `persistent_id`、`request_id` 或 `session_id`，不要让 Foundation 类型承载领域语义。

## 参考

- 源码：`addons/gf/standard/foundation/identity/gf_uuid.gd`
- 测试：`tests/gf_core/standard/foundation/identity/test_gf_uuid.gd`
