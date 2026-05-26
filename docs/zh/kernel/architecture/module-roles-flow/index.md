# 五层分工与信息流

本组页面说明 Foundation、Model、System、Controller 和 Utility 的职责边界，以及数据和调用在这些层之间的推荐方向。

## 阅读入口

- [五层职责](module-roles/index.md)：每一层负责什么、可以依赖什么、应避免什么。
- [信息流方向](information-flow.md)：Controller、System、Model、Utility 与 Foundation 之间的数据和调用方向。

## 使用边界

GF 的分层不是为了增加目录，而是为了让项目状态、规则、表现和底层服务能被独立测试、替换和诊断。跨层调用应保持明确，核心业务状态不应泄漏到场景节点或临时 UI 中。
