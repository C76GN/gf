## 用于验证架构级 Model 序列化/恢复的稳定脚本资源。
extends GFModel


# --- 公共变量 ---

var volume: float = 1.0


# --- 公共方法 ---

func to_dict() -> Dictionary:
	return {
		"volume": volume,
	}


func from_dict(data: Dictionary) -> void:
	volume = data.get("volume", 1.0)
