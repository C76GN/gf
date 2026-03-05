# tests/gf_core/test_gf_quad_tree_utility.gd

## 测试 GFQuadTreeUtility 的插入、删除、更新和范围查询功能。
extends GutTest


# --- 私有变量 ---

var _tree: GFQuadTreeUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_tree = GFQuadTreeUtility.new()
	_tree.setup(Rect2(0, 0, 1000, 1000), 6, 4)
	_tree.init()


func after_each() -> void:
	_tree = null


# --- 测试：插入与查询 ---

## 验证插入后可通过矩形查询找到实体。
func test_insert_and_query() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	var result: Array[int] = _tree.query_rect(Rect2(90, 90, 70, 70))
	assert_true(result.has(1), "查询应找到已插入的实体。")


## 验证不在查询范围内的实体不被返回。
func test_query_miss() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	var result: Array[int] = _tree.query_rect(Rect2(500, 500, 50, 50))
	assert_false(result.has(1), "不在范围内的实体不应被返回。")


## 验证多个实体的查询。
func test_multiple_entities() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	_tree.insert(2, Rect2(120, 120, 50, 50))
	_tree.insert(3, Rect2(800, 800, 50, 50))
	var result: Array[int] = _tree.query_rect(Rect2(90, 90, 100, 100))
	assert_true(result.has(1), "实体 1 应在查询范围内。")
	assert_true(result.has(2), "实体 2 应在查询范围内。")
	assert_false(result.has(3), "实体 3 不应在查询范围内。")


# --- 测试：删除 ---

## 验证删除后查询不再返回。
func test_remove() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	_tree.remove(1)
	var result: Array[int] = _tree.query_rect(Rect2(90, 90, 70, 70))
	assert_false(result.has(1), "删除后不应找到该实体。")


## 验证删除不存在的实体不报错。
func test_remove_nonexistent() -> void:
	_tree.remove(999)
	assert_eq(_tree.get_entity_count(), 0, "删除不存在的实体不应影响计数。")


# --- 测试：更新 ---

## 验证更新位置后旧位置查询不到、新位置可查到。
func test_update_moves_entity() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	_tree.update(1, Rect2(800, 800, 50, 50))

	var old_result: Array[int] = _tree.query_rect(Rect2(90, 90, 70, 70))
	assert_false(old_result.has(1), "旧位置不应查到实体。")

	var new_result: Array[int] = _tree.query_rect(Rect2(790, 790, 70, 70))
	assert_true(new_result.has(1), "新位置应查到实体。")


# --- 测试：圆形查询 ---

## 验证圆形范围查询找到范围内的实体。
func test_query_radius_hit() -> void:
	_tree.insert(1, Rect2(100, 100, 10, 10))
	var result: Array[int] = _tree.query_radius(Vector2(105, 105), 50.0)
	assert_true(result.has(1), "圆形查询应找到范围内的实体。")


## 验证圆形范围查询排除范围外的实体。
func test_query_radius_miss() -> void:
	_tree.insert(1, Rect2(100, 100, 10, 10))
	var result: Array[int] = _tree.query_radius(Vector2(500, 500), 10.0)
	assert_false(result.has(1), "圆形查询不应找到范围外的实体。")


# --- 测试：边界条件 ---

## 验证空树查询返回空数组。
func test_empty_tree_query() -> void:
	var result: Array[int] = _tree.query_rect(Rect2(0, 0, 1000, 1000))
	assert_eq(result.size(), 0, "空树查询应返回空数组。")


## 验证 clear 后实体被清除。
func test_clear() -> void:
	_tree.insert(1, Rect2(100, 100, 50, 50))
	_tree.insert(2, Rect2(200, 200, 50, 50))
	_tree.clear()
	assert_eq(_tree.get_entity_count(), 0, "clear 后实体数应为 0。")
	var result: Array[int] = _tree.query_rect(Rect2(0, 0, 1000, 1000))
	assert_eq(result.size(), 0, "clear 后查询应返回空。")


## 验证 has_entity 检查。
func test_has_entity() -> void:
	_tree.insert(42, Rect2(0, 0, 10, 10))
	assert_true(_tree.has_entity(42), "已插入的实体应存在。")
	assert_false(_tree.has_entity(99), "未插入的实体不应存在。")


## 验证大量实体触发分裂后仍可正确查询。
func test_split_and_query() -> void:
	for i: int in range(20):
		_tree.insert(i, Rect2(i * 40.0, i * 40.0, 30, 30))
	var result: Array[int] = _tree.query_rect(Rect2(0, 0, 200, 200))
	assert_true(result.size() > 0, "分裂后查询应仍能找到实体。")
	assert_true(result.has(0), "实体 0 应在查询范围内。")


## 验证边界上的实体能被查到。
func test_entity_on_boundary() -> void:
	_tree.insert(1, Rect2(0, 0, 10, 10))
	var result: Array[int] = _tree.query_rect(Rect2(0, 0, 10, 10))
	assert_true(result.has(1), "边界上的实体应被查到。")
