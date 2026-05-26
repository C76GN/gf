# Foundation

路径：`addons/gf/standard/foundation/*`

Foundation 承载纯值对象、纯算法和纯格式化工具，例如 `GFBigNumber`、`GFFixedDecimal`、`GFNumberFormatter` 和 `GFProgressionMath`。

规则：

- 不注册到 `Gf` / `GFArchitecture`。
- 不依赖 SceneTree、Node 生命周期或框架事件总线。
- 可以被 Model、System、Controller 和 Utility 直接引用。
- 优先放机制原语，不放具体项目业务规则。
