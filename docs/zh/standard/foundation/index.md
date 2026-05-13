# Foundation 基础能力

Standard Foundation 放置纯算法、纯数据结构、轻量格式化和通用诊断结构。它不参与 `GFArchitecture` 生命周期，也不承担项目业务规则。

## 阅读入口

- [Foundation 数值、成长与权重](scalars.md)：大数、定点数、格式化、成长曲线和权重表。
- [Foundation 网格、路径与空间索引](grid-spatial.md)：网格、Hex、图、Pattern2D、TileMap、转向、空间哈希。
- [Foundation 标签、公式、序列化与结果报告](data-validation.md)：标签、黑板、公式、Variant、校验报告和结果字典。

## 为什么要单独分层

这些类型常被多个模块同时使用，但它们不应该依赖运行时容器、场景树或可选扩展。把它们放在 `standard/foundation` 可以避免 `kernel` 膨胀，也能避免各个 Utility 重复实现基础能力。

## 当前目录结构

```text
addons/gf/standard/foundation/
  math/          # 数值、网格、图、公式、空间索引
  tags/          # 标签集合、标签查询、标签源适配
  blackboard/    # 黑板 Schema 与条目描述
  data/          # Variant 复制、JSON 编码、结果字典
  validation/    # 统一校验问题与报告
```

## 放什么进 Foundation

- 没有生命周期，不需要注册到 `GFArchitecture`。
- 不持有场景节点、文件句柄、网络请求或异步状态。
- 可以被 `standard`、官方扩展、社区扩展和项目代码安全复用。
- 表达的是稳定通用概念，而不是某个项目的业务规则。

## 使用约定

- 需要 `tick()`、缓存、异步加载、ProjectSettings 或全局状态时，优先放到 `standard/utilities`。
- 需要扩展启用状态、Installer 或扩展内场景资源时，放到对应 `extensions/official` 或社区扩展。
- 新增基础件时，应同步补充对应子页和 `docs/zh/changelog.md`。
