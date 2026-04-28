## 测试 GFProgressionMath 的曲线、里程碑、软上限与离线收益结算。
extends GutTest


const GF_PROGRESSION_MATH := preload("res://addons/gf/foundation/math/gf_progression_math.gd")


# --- 测试 ---

func test_evaluate_curve_supports_piecewise_growth() -> void:
	var curve := {
		"base_value": 10,
		"phases": [
			{
				"start_level": 0,
				"mode": "exponential",
				"multiplier": 2.0,
			},
			{
				"start_level": 3,
				"mode": "linear",
				"per_level": 50,
			},
		],
	}

	var level_two = GF_PROGRESSION_MATH.evaluate_curve(2, curve)
	var level_five = GF_PROGRESSION_MATH.evaluate_curve(5, curve)

	assert_eq(level_two.to_plain_string(0), "40", "前 3 级应按指数曲线计算。")
	assert_eq(level_five.to_plain_string(0), "180", "后续阶段应继承上一阶段起点再做线性增长。")


func test_evaluate_curve_supports_level_overrides() -> void:
	var curve := {
		"base_value": 10,
		"mode": GF_PROGRESSION_MATH.CurveMode.EXPONENTIAL,
		"multiplier": 2.0,
		"overrides": {
			4: 999,
		},
	}

	var overridden = GF_PROGRESSION_MATH.evaluate_curve(4, curve)

	assert_eq(overridden.to_plain_string(0), "999", "特殊等级应优先命中 override 配置。")


func test_evaluate_curve_supports_string_override_keys() -> void:
	var curve := {
		"base_value": 10,
		"mode": "linear",
		"per_level": 5,
		"overrides": {
			"7": 1234,
		},
	}

	var overridden = GF_PROGRESSION_MATH.evaluate_curve(7, curve)

	assert_eq(overridden.to_plain_string(0), "1234", "override 使用字符串等级键时也应能命中。")


func test_invalid_exponential_multiplier_returns_anchor_value() -> void:
	var curve := {
		"base_value": 10,
		"mode": "exponential",
		"multiplier": 0.0,
	}

	var result = GF_PROGRESSION_MATH.evaluate_curve(5, curve)

	assert_push_error("[GFProgressionMath] 指数曲线 multiplier 必须大于 0。")
	assert_eq(result.to_plain_string(0), "10", "非法指数倍率应回退到锚点值。")


func test_apply_milestone_multipliers_stacks_all_unlocked_thresholds() -> void:
	var result = GF_PROGRESSION_MATH.apply_milestone_multipliers(
		10,
		25,
		[
			{
				"level": 10,
				"multiplier": 2.0,
			},
			{
				"level": 25,
				"multiplier": 5.0,
			},
		]
	)

	assert_eq(result.to_plain_string(0), "100", "已解锁的里程碑倍率应全部叠乘。")


func test_apply_soft_cap_uses_power_falloff() -> void:
	var softened = GF_PROGRESSION_MATH.apply_soft_cap(150, 100, 0.5)

	assert_almost_eq(
		softened.to_float(),
		107.0710678,
		0.000001,
		"150 在 100 起始、0.5 幂软上限下应约为 107.0710678。"
	)


func test_settle_offline_progress_applies_segmented_buff_windows() -> void:
	var result := GF_PROGRESSION_MATH.settle_offline_progress(
		10,
		3600.0,
		{
			"segments": [
				{
					"duration_seconds": 600.0,
					"multiplier": 2.0,
				},
			],
		}
	)

	assert_eq(result["produced"].to_plain_string(0), "42000", "前 10 分钟双倍、剩余正常时应产出 42000。")
	assert_almost_eq(result["settled_seconds"], 3600.0, 0.000001, "未设置上限时应完整结算全部离线秒数。")
	assert_almost_eq(result["consumed_seconds"], 3600.0, 0.000001, "无仓储上限时应消耗全部已结算时间。")
	assert_false(result["storage_capped"], "未配置仓储上限时不应触发 storage capped。")


func test_settle_offline_progress_respects_max_seconds_and_storage_limit() -> void:
	var result := GF_PROGRESSION_MATH.settle_offline_progress(
		10,
		7200.0,
		{
			"max_seconds": 3600.0,
			"storage_remaining": 20000,
		}
	)

	assert_eq(result["produced"].to_plain_string(0), "20000", "仓储上限应截断最终离线产出。")
	assert_almost_eq(result["settled_seconds"], 3600.0, 0.000001, "max_seconds 应限制可结算时长。")
	assert_almost_eq(result["consumed_seconds"], 2000.0, 0.000001, "10/s 在 20000 容量下应于 2000 秒后装满。")
	assert_almost_eq(result["expired_seconds"], 3600.0, 0.000001, "超过 max_seconds 的离线时间应计入 expired_seconds。")
	assert_almost_eq(result["wasted_seconds"], 1600.0, 0.000001, "仓储满后的剩余已结算时间应计入 wasted_seconds。")
	assert_true(result["storage_capped"], "仓储装满后应标记 storage_capped。")


func test_settle_offline_progress_clamps_negative_seconds_to_zero() -> void:
	var result := GF_PROGRESSION_MATH.settle_offline_progress(10, -5.0)

	assert_eq(result["produced"].to_plain_string(0), "0", "负离线时间应按 0 秒处理。")
	assert_almost_eq(result["requested_seconds"], 0.0, 0.000001, "requested_seconds 不应保留负值。")
	assert_almost_eq(result["settled_seconds"], 0.0, 0.000001, "settled_seconds 应为 0。")


func test_settle_offline_progress_zero_storage_caps_immediately() -> void:
	var result := GF_PROGRESSION_MATH.settle_offline_progress(
		10,
		60.0,
		{ "storage_remaining": 0 }
	)

	assert_eq(result["produced"].to_plain_string(0), "0", "仓储为 0 时不应产生收益。")
	assert_almost_eq(result["consumed_seconds"], 0.0, 0.000001, "仓储为 0 时消耗时间应为 0。")
	assert_almost_eq(result["wasted_seconds"], 60.0, 0.000001, "仓储为 0 时已结算时间都应计入浪费。")
	assert_true(result["storage_capped"], "仓储为 0 时应立即标记已封顶。")
