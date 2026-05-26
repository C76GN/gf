# 输入缓冲、指针活动与拖放

本组页面说明手感缓冲、宽容窗口、指针活动状态和通用拖放会话。它们描述输入意图与交互活动，不绑定具体玩法或 UI 行为。

## 阅读入口

- [输入缓冲与宽容窗口](input-buffer-grace.md)：`GFInputAssistUtility` 的 buffered action 和 grace window。
- [指针活动状态](pointer-activity.md)：`GFPointerActivityUtility` 的按下、移动、拖拽和空闲状态。
- [拖放会话](drag-drop.md)：`GFDragDropUtility`、`GFDragSession`、`GFDropZone` 和 drop 结果。

## 使用边界

这些工具只记录输入意图、宽容窗口、指针活动和拖放会话。角色动作、UI 接受规则、物品交换、拖放动画和业务提交应由项目层处理。
