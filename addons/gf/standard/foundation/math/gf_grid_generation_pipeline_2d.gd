## GFGridGenerationPipeline2D: 通用 2D 网格生成管线。
##
## 以候选格子为输入，按步骤输出 `Dictionary[Vector2i, Variant]`。
## 适合程序化生成的中间数据层，不绑定任何具体节点、资源或玩法类型。
class_name GFGridGenerationPipeline2D
extends Resource


# --- 导出变量 ---

## 生成步骤。
@export var steps: Array[GFGridGenerationStep2D] = []

## 是否在执行步骤前为全部候选格子写入默认值。
@export var fill_default_value: bool = false

## 默认值。
@export var default_value: Variant = null

## 管线元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 从矩形范围生成候选格子。
## @param position: 范围起点。
## @param size: 范围尺寸。
## @return 候选格子。
static func make_rect_candidates(position: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if size.x <= 0 or size.y <= 0:
		return result
	for y: int in range(position.y, position.y + size.y):
		for x: int in range(position.x, position.x + size.x):
			result.append(Vector2i(x, y))
	return result


## 执行生成管线。
## @param candidates: 候选格子。
## @param context: 项目自定义上下文。
## @return 生成结果字典，key 为 Vector2i。
func generate(candidates: Array[Vector2i], context: Dictionary = {}) -> Dictionary:
	var grid: Dictionary = {}
	if fill_default_value:
		for cell: Vector2i in candidates:
			grid[cell] = GFVariantData.duplicate_variant(default_value)

	for step: GFGridGenerationStep2D in steps:
		if step == null:
			continue
		step.apply(grid, candidates, context)
	return grid


## 在已有网格上执行生成管线。
## @param grid: 目标网格字典，key 为 Vector2i。
## @param candidates: 候选格子。
## @param context: 项目自定义上下文。
## @return 目标网格本身。
func apply_to_grid(
	grid: Dictionary,
	candidates: Array[Vector2i],
	context: Dictionary = {}
) -> Dictionary:
	if fill_default_value:
		for cell: Vector2i in candidates:
			if not grid.has(cell):
				grid[cell] = GFVariantData.duplicate_variant(default_value)

	for step: GFGridGenerationStep2D in steps:
		if step == null:
			continue
		step.apply(grid, candidates, context)
	return grid


## 添加生成步骤。
## @param step: 生成步骤。
func add_step(step: GFGridGenerationStep2D) -> void:
	if step == null:
		return
	steps.append(step)


## 清空生成步骤。
func clear_steps() -> void:
	steps.clear()


## 获取诊断快照。
## @return 诊断字典。
func get_debug_snapshot() -> Dictionary:
	var step_snapshots: Array[Dictionary] = []
	for step: GFGridGenerationStep2D in steps:
		if step != null:
			step_snapshots.append(step.get_debug_snapshot())
	return {
		"step_count": steps.size(),
		"fill_default_value": fill_default_value,
		"metadata": metadata.duplicate(true),
		"steps": step_snapshots,
	}
