## 测试 GFThumbnailRenderer 的输入边界处理。
extends GutTest


# --- 测试方法 ---

func test_normalize_render_size_clamps_to_positive_pixels() -> void:
	var renderer := GFThumbnailRenderer.new()

	assert_eq(renderer._normalize_render_size(Vector2i(0, -4)), Vector2i(1, 1), "渲染尺寸应钳制到至少 1 像素。")
	renderer.free()
