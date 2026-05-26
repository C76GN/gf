# 轻量结果字典

`GFResultDictionary` 是轻量结果字典辅助，只统一常见字段名和基础构造，不负责统计问题或表达校验报告。

它适合 `ok` / `data` / `metadata` / `error` 这类底层 Utility 返回值，尤其是存储、导入导出、异步任务等需要保持字典兼容的场景。

```gdscript
var result := GFResultDictionary.make_success({
	GFResultDictionary.KEY_DATA: { "coins": 10 },
	GFResultDictionary.KEY_METADATA: { "version": 2 },
})

if result[GFResultDictionary.KEY_OK]:
	print(result[GFResultDictionary.KEY_DATA])
```

如果返回结构需要问题列表、严重级别、摘要和下一步建议，应使用 `GFValidationIssue` / `GFValidationReport` / `GFValidationReportDictionary`。

如果只是表达一次操作的成功、失败和载荷，优先复用 `GFResultDictionary` 的 key 常量和轻量工厂，避免不同模块手写字段名漂移。
