# 本地存储、编码、同步与快照

本组文档聚焦标准库的本地读写、编码、同步和快照历史。场景树存档图属于 GF Save 扩展。

## 阅读入口

- [本地存档管理器](storage-utility.md)：`GFStorageUtility` 的字典、槽位、Resource 和通用文件读写。
- [完整性校验与版本迁移](integrity-migrations/index.md)：codec 元信息、checksum、事务恢复、旧存档兼容和迁移链。
- [存储后端与同步](backends-sync.md)：`GFStorageBackend`、`GFStorageSyncUtility` 和冲突报告。
- [快照历史与查看器](snapshot-history-viewer.md)：`GFSnapshotHistoryUtility`、`GF Storage Viewer` 和 SaveGraph 交叉入口。

## 使用边界

`GFStorageUtility` 基于 Godot `user://` 提供本地持久化能力。它不负责云同步、业务 schema 设计、玩家账号隔离或安全加密。多端同步、平台 SDK、账号体系和业务冲突策略应由项目层或独立插件接入。
