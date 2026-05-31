## 测试通用 2D 网格生成管线。
extends GutTest


# --- 测试方法 ---

func test_grid_generation_pipeline_applies_selection_steps() -> void:
	var candidates: Array[Vector2i] = GFGridGenerationPipeline2D.make_rect_candidates(Vector2i.ZERO, Vector2i(3, 2))
	var selection: GFGridSelection2D = GFGridSelection2D.new()
	selection.use_bounds = true
	selection.bounds_position = Vector2i(1, 0)
	selection.bounds_size = Vector2i(2, 1)
	var step: GFGridGenerationStep2D = GFGridGenerationStep2D.new()
	step.selection = selection
	step.value = "edge"
	var pipeline: GFGridGenerationPipeline2D = GFGridGenerationPipeline2D.new()
	pipeline.fill_default_value = true
	pipeline.default_value = "empty"
	pipeline.add_step(step)

	var grid: Dictionary = pipeline.generate(candidates)

	assert_eq(GFVariantData.get_option_string(grid, Vector2i(0, 0)), "empty", "未选中格子应保留默认值。")
	assert_eq(GFVariantData.get_option_string(grid, Vector2i(1, 0)), "edge", "选中格子应写入步骤值。")
	assert_eq(GFVariantData.get_option_string(grid, Vector2i(2, 0)), "edge", "矩形选择器应覆盖边界内格子。")
	assert_eq(grid.size(), 6, "默认填充应覆盖全部候选格子。")


func test_grid_generation_step_can_use_value_callback_and_erase() -> void:
	var candidates: Array[Vector2i] = GFGridGenerationPipeline2D.make_rect_candidates(Vector2i.ZERO, Vector2i(2, 1))
	var write_step: GFGridGenerationStep2D = GFGridGenerationStep2D.new()
	write_step.value_callback = func(cell: Vector2i, _previous_value: Variant, context: Dictionary) -> Variant:
		return GFVariantData.get_option_int(context, "base", 0) + cell.x
	var erase_selection: GFGridSelection2D = GFGridSelection2D.new()
	erase_selection.included_cells = [Vector2i(0, 0)]
	var erase_step: GFGridGenerationStep2D = GFGridGenerationStep2D.new()
	erase_step.selection = erase_selection
	erase_step.erase_cells = true
	var pipeline: GFGridGenerationPipeline2D = GFGridGenerationPipeline2D.new()
	pipeline.steps = [write_step, erase_step]

	var grid: Dictionary = pipeline.generate(candidates, { "base": 10 })

	assert_false(grid.has(Vector2i(0, 0)), "擦除步骤应移除选中格子。")
	assert_eq(GFVariantData.get_option_int(grid, Vector2i(1, 0)), 11, "值回调应能基于上下文生成通用值。")
