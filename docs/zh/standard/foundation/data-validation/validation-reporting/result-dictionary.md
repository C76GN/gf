# 轻量结果字典

`GFResultDictionary` 是轻量结果字典辅助，统一 `ok`、`reason`、`message`、`data`、`metadata`、`issues` 和 `issue_count` 等常见字段。

它适合底层 Utility、导入导出、异步任务、轻量运行时命令等“只表达一次操作结果”的场景。需要严重级别、统计、摘要和下一步建议时，再使用 `GFValidationIssue` / `GFValidationReport` / `GFValidationReportDictionary`。

```gdscript
var result := GFResultDictionary.make_success({
	GFResultDictionary.KEY_DATA: { "coins": 10 },
	GFResultDictionary.KEY_METADATA: { "version": 2 },
})

if result[GFResultDictionary.KEY_OK]:
	print(result[GFResultDictionary.KEY_DATA])
```

失败结果应优先写入稳定的机器可读 `reason`，再写人类可读 `message`。`error` 只作为通用错误文本字段保留，不作为新 API 的主要分支依据：

```gdscript
return GFResultDictionary.make_rejected(
	&"invalid_state",
	"State is invalid for this operation.",
	{
		GFResultDictionary.KEY_METADATA: { "state": current_state },
	}
)
```

已有字典需要接入统一协议时，先用 `normalize()` 补齐标准字段；需要把项目自定义信息合入结果时，用 `merge_metadata()` 保持深拷贝和递归合并语义一致。

新 API 不应继续手写散落的 `"ok"`、`"reason"`、`"metadata"` 字符串。优先复用 `GFResultDictionary` 的 key 常量和工厂方法，让普通结果、带问题结果和校验报告在字段层面保持可组合。
