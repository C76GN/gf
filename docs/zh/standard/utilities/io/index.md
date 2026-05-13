# 资源、存储与 IO

本组文档覆盖标准库里和资源、文件、配置、远程缓存、同步和请求队列相关的 Utility。场景树级存档图不在本组展开，主说明见 [Save 场景存档图](../../../extensions/save-graph/index.md)。

## 阅读入口

- [资源加载、下载、任务队列与预热](assets-jobs-warmup.md)：`GFAssetUtility`、下载队列、任务队列、渲染预热。
- [本地存储、编码、同步与快照](storage-snapshot.md)：`GFStorageUtility`、编码器、后端、同步和快照历史。
- [导表、分析、远程缓存与请求 Outbox](config-remote-outbox.md)：配置表、分析事件、远程缓存、离线请求。

## 源码目录速查

- `addons/gf/standard/utilities/assets/`：异步资源加载、资源句柄、资源分组。
- `addons/gf/standard/utilities/storage/`：本地存储、编码、同步后端、快照历史。
- `addons/gf/standard/utilities/io/`：下载、远程缓存、请求 Outbox。
- `addons/gf/standard/utilities/config/`：静态导表读取、表结构声明、导入校验。
- `addons/gf/standard/utilities/jobs/`：通用任务队列和节点工作器。
- `addons/gf/standard/utilities/display/`：渲染预热、显示相关通用支撑。
