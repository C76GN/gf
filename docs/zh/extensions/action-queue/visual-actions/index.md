# 视觉动作与入队

`GFActionQueueSystem` 是 ActionQueue 扩展的队列入口。战斗、卡牌、战棋、剧情和教程可以把表现动作交给它按顺序、并行组或命名流执行。

## 阅读入口

- [复合动作与并行执行](groups-parallel.md)：`GFVisualActionGroup` 和 `enqueue_parallel()`。
- [自定义 Action](custom-action.md)：`GFVisualAction.execute()`、Signal 等待、取消和超时。
- [入队与 Fire-and-Forget](enqueue-fire-and-forget.md)：普通入队、自动完成模式和非阻塞动作。

## 使用边界

ActionQueue 只负责表现动作的执行顺序和等待边界。动作内部的 Tween、Timer、临时信号连接、资源释放和业务含义仍由项目动作实现负责。
