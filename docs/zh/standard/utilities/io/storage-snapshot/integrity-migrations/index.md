# 完整性校验与版本迁移

这一组文档说明 `GFStorageUtility` 的写入策略、完整性校验、旧存档兼容和版本迁移链。

`GFStorageUtility` 的本地写入路径、文件操作和事务提交/恢复共用同一套内部策略。槽位存档、纯字典存档和异步纯字典存档会遵循一致的路径规整、目录创建、临时文件、备份文件与事务标记规则。

## 阅读入口

- [完整性校验](integrity-checksum.md)：codec 元信息、checksum、旧 checksum 迁移和 JSON 语义归一化。
- [兼容旧存档](legacy-compatibility.md)：旧版纯 JSON 回退、数字归一、绝对路径、槽位结果和异步收敛。
- [迁移链](migration-chain.md)：`migrate_data()`、`register_migration()` 和严格 schema 迁移。

## 使用边界

项目层不应依赖 `.tmp`、`.bak`、`.txn` 这些内部文件。恢复流程会在下次读取、写入或槽位检查时自动收敛。
