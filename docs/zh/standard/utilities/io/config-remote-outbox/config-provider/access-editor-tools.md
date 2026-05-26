# 访问器生成与编辑器工具

配置表 schema 可以用于生成静态访问器，也可以驱动编辑器里的资源表格和通用输入控件。生成和编辑工具都不改变 `GFConfigProvider` 协议。

## 静态访问器生成

如果项目希望减少散落的表名字符串，可以用 `GFConfigAccessGenerator` 根据 schema 生成静态访问器。生成结果只是对 provider 的 `get_record()` 和 `get_table()` 的轻量访问封装，不把具体表结构写入框架：

```gdscript
var generator := GFConfigAccessGenerator.new()
generator.generate(
	[items_schema, levels_schema],
	"res://gf/generated/gf_config_access.gd",
	true,
	"GFConfigAccess",
	"Gf.get_utility(GFConfigProvider) as GFConfigProvider"
)

# 生成后项目代码可以通过 IDE 补全调用：
var item := GFConfigAccess.get_items_record(1001)
var levels := GFConfigAccess.get_levels_table()
```

生成器位于 kernel/editor，因此不会默认硬引用标准库的 `GFConfigProvider`。如果希望生成的访问器能在不显式传 provider 时工作，需要像上面这样传入项目自己的 `provider_accessor`。也可以在调用点显式传入 provider：`GFConfigAccess.get_items_record(1001, provider)`。

访问器适合稳定表名、团队协作和重构检查；原始 `GFConfigProvider` 仍适合动态表名、热更新表包或项目自定义导表运行时。

生成器只读取 schema 的 `table_name` 或 `table_key` 属性，不调用项目自定义取表名方法，适合在编辑器批量生成时避开非 `@tool` 脚本副作用。生成器只输出 GDScript，可用 `method_name_style`、`constant_prefix`、`record_method_pattern`、`table_method_pattern` 和 `include_schema_comments` 微调命名与注释，不生成其他语言代码。

## 编辑器工具

开发期如果需要做 Resource 批量检查或表格式编辑，可以复用 `GFResourceTableEditor` 和 `GFEditorValueField`。

`GFResourceTableEditor` 负责扫描 `.tres` / `.res`、从 Resource export 推导列、提交单元格值并广播变更。`scan_resource_paths()` 默认限制递归深度和收集数量，项目工具可按需要传入 `max_scan_depth` / `max_resource_paths`。默认只修改内存中的 Resource，不接管完整 UndoRedo 工作流；如果资源已有 `resource_path` 且项目希望提交后立即写盘，可以开启 `auto_save_committed_resources` 并监听 `resource_save_failed`。

`GFEditorValueField` 负责按 Godot 属性类型创建基础输入控件。Array/Dictionary JSON 输入解析失败或容器类型不匹配时会发出 `value_parse_failed` 并保留旧值，不会把错误输入静默提交成空容器或错误容器。

这些编辑器工具是通用控件，不保存业务表结构，也不替项目决定资源分类、校验规则或提交工作流。
