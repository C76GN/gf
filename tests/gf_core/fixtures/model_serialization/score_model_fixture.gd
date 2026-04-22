## 用于验证架构级 Model 序列化/恢复的稳定脚本资源。
extends GFModel


# --- 公共变量 ---

var score: int = 0
var level: int = 1


# --- 公共方法 ---

func to_dict() -> Dictionary:
	return {
		"score": score,
		"level": level,
	}


func from_dict(data: Dictionary) -> void:
	score = data.get("score", 0)
	level = data.get("level", 1)
