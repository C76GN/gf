# 五层职责

GF 项目通常按 Foundation、Model、System、Controller 和 Utility 组织核心代码。每层应保持稳定职责，不要因为调用方便而互相穿透。

## 阅读入口

- [Foundation](foundation.md)：纯值对象、纯算法和纯格式化工具。
- [Model 与 System](model-system.md)：核心数据状态和纯代码业务流程中心。
- [Controller 与 Utility](controller-utility.md)：场景桥接和通用运行时服务。

## 使用边界

五层分工用于保持依赖方向清晰。信息流方向详见 [信息流方向](../information-flow.md)。
