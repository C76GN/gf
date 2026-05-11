## 测试通用 2D 网格生成管线。
extends GutTest


# --- 常量 ---

const GFGridSelection2DBase = preload("res://addons/gf/standard/foundation/math/gf_grid_selection_2d.gd")
const GFGridGenerationStep2DBase = preload("res://addons/gf/standard/foundation/math/gf_grid_generation_step_2d.gd")
const GFGridGenerationPipeline2DBase = preload("res://addons/gf/standard/foundation/math/gf_grid_generation_pipeline_2d.gd")


# --- 测试方法 ---

func test_grid_generation_pipeline_applies_selection_steps() -> void:
	var candidates := GFGridGenerationPipeline2DBase.make_rect_candidates(Vector2i.ZERO, Vector2i(3, 2))
	var selection := GFGridSelection2DBase.new()
	selection.use_bounds = true
	selection.bounds_position = Vector2i(1, 0)
	selection.bounds_size = Vector2i(2, 1)
	var step := GFGridGenerationStep2DBase.new()
	step.selection = selection
	step.value = "edge"
	var pipeline := GFGridGenerationPipeline2DBase.new()
	pipeline.fill_default_value = true
	pipeline.default_value = "empty"
	pipeline.add_step(step)

	var grid := pipeline.generate(candidates)

	assert_eq(grid[Vector2i(0, 0)], "empty", "未选中格子应保留默认值。")
	assert_eq(grid[Vector2i(1, 0)], "edge", "选中格子应写入步骤值。")
	assert_eq(grid[Vector2i(2, 0)], "edge", "矩形选择器应覆盖边界内格子。")
	assert_eq(grid.size(), 6, "默认填充应覆盖全部候选格子。")


func test_grid_generation_step_can_use_value_callback_and_erase() -> void:
	var candidates := GFGridGenerationPipeline2DBase.make_rect_candidates(Vector2i.ZERO, Vector2i(2, 1))
	var write_step := GFGridGenerationStep2DBase.new()
	write_step.value_callback = func(cell: Vector2i, _previous_value: Variant, context: Dictionary) -> Variant:
		return int(context["base"]) + cell.x
	var erase_selection := GFGridSelection2DBase.new()
	erase_selection.included_cells = [Vector2i(0, 0)]
	var erase_step := GFGridGenerationStep2DBase.new()
	erase_step.selection = erase_selection
	erase_step.erase_cells = true
	var pipeline := GFGridGenerationPipeline2DBase.new()
	pipeline.steps = [write_step, erase_step]

	var grid := pipeline.generate(candidates, { "base": 10 })

	assert_false(grid.has(Vector2i(0, 0)), "擦除步骤应移除选中格子。")
	assert_eq(grid[Vector2i(1, 0)], 11, "值回调应能基于上下文生成通用值。")
