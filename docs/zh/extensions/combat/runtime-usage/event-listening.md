# 事件监听

Combat 扩展会通过 GF 事件系统派发通用战斗 payload。项目可以监听这些事件，把战斗状态变化同步给日志、UI、音效、表现队列或诊断面板。

```gdscript
# 监听 Buff 应用事件。
Gf.listen(GFCombatPayloads.GFBuffAppliedPayload, func(payload: GFCombatPayloads.GFBuffAppliedPayload):
	var buff := payload.buff as GFBuff
	print("实体 ", payload.target, " 获得了 Buff: ", buff.id)
)
```

事件 payload 只描述 Combat 层发生了什么，不定义项目应该播放什么表现、写入什么战报、如何结算任务或是否通知网络层。
