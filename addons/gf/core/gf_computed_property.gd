## GFComputedProperty: 由多个 BindableProperty 派生的只读响应式属性。
##
## 通过 compute 回调计算自身值，并在任一来源属性变化时自动刷新。
class_name GFComputedProperty
extends BindableProperty


# --- 私有变量 ---

var _effect: GFReactiveEffect = null


# --- Godot 生命周期方法 ---

## 构造函数。
## @param sources: 要监听的 BindableProperty 列表。
## @param compute: 用于计算当前值的回调。
## @param default_value: 初始默认值。
## @param owner: 可选 Node 生命周期宿主。
func _init(
	sources: Array[BindableProperty] = [],
	compute: Callable = Callable(),
	default_value: Variant = null,
	owner: Node = null
) -> void:
	super._init(default_value)
	if not sources.is_empty() or compute.is_valid():
		bind_sources(sources, compute, owner)


# --- 公共方法 ---

## 绑定来源属性与计算回调。重复调用会替换旧绑定。
## @param sources: 要监听的 BindableProperty 列表。
## @param compute: 用于计算当前值的回调。
## @param owner: 可选 Node 生命周期宿主。
## @param run_immediately: 是否立即计算一次。
func bind_sources(
	sources: Array[BindableProperty],
	compute: Callable,
	owner: Node = null,
	run_immediately: bool = true
) -> void:
	stop()
	if not compute.is_valid():
		return

	_effect = GFReactiveEffect.new(
		sources,
		func() -> Variant:
			var next_value: Variant = compute.call()
			_set_value_from_compute(next_value)
			return next_value,
		owner,
		run_immediately
	)


## 停止自动刷新。
func stop() -> void:
	if _effect != null:
		_effect.stop()
		_effect = null


## 只读派生属性不允许外部直接写入值。
## @param _new_value: 调用方尝试写入的新值。
func set_value(_new_value: Variant) -> void:
	push_error("[GFComputedProperty] 当前属性由 compute 回调派生，请修改来源属性。")


## 获取内部 effect 是否激活。
## @return 激活时返回 true。
func is_computing() -> bool:
	return _effect != null and _effect.is_active()


# --- 私有/辅助方法 ---

func _set_value_from_compute(new_value: Variant) -> void:
	super.set_value(new_value)
