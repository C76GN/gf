## GFBindingLifetimes: 依赖绑定的生命周期枚举。
class_name GFBindingLifetimes
extends RefCounted


# --- 枚举 ---

## 绑定实例的生命周期。
enum Lifetime {
	## 首次解析后缓存实例，后续解析复用。
	SINGLETON,
	## 每次解析都重新创建实例。
	TRANSIENT,
}
