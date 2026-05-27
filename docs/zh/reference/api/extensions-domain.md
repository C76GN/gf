# Domain API

Module: `extensions/domain`

## Classes

- [`GFAttributeSet`](#gfattributeset)
- [`GFDerivedAttributeRule`](#gfderivedattributerule)
- [`GFEquipmentSet`](#gfequipmentset)
- [`GFEquipmentSlot`](#gfequipmentslot)
- [`GFInventoryItemDefinition`](#gfinventoryitemdefinition)
- [`GFInventoryItemRegistry`](#gfinventoryitemregistry)
- [`GFInventoryModel`](#gfinventorymodel)
- [`GFInventoryOperationResult`](#gfinventoryoperationresult)
- [`GFInventorySlotDefinition`](#gfinventoryslotdefinition)
- [`GFInventoryStack`](#gfinventorystack)
- [`GFLevelCatalog`](#gflevelcatalog)
- [`GFLevelEntry`](#gflevelentry)
- [`GFLevelProgressModel`](#gflevelprogressmodel)
- [`GFLevelUtility`](#gflevelutility)
- [`GFQuestUtility`](#gfquestutility)
- [`GFSlotInventoryModel`](#gfslotinventorymodel)
- [`GFTrait`](#gftrait)
- [`GFTraitSet`](#gftraitset)

## GFAttributeSet

- Path: `addons/gf/extensions/domain/attributes/gf_attribute_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFAttributeSet: 通用数值属性集合。 用 StringName 管理一组可保存、可恢复、可限制范围的数值属性。它不规定 属性含义，生命值、耐久、温度、声望或任意项目数值都由项目层命名和解释。

### Signals

#### `attribute_defined`

- API: `public`

```gdscript
signal attribute_defined(attribute_id: StringName)
```

属性被定义时发出。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 被定义或替换的属性 ID。 |

#### `attribute_changed`

- API: `public`

```gdscript
signal attribute_changed(attribute_id: StringName, current_value: float, previous_value: float)
```

当前值变化时发出。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 发生变化的属性 ID。 |
| `current_value` | 新当前值。 |
| `previous_value` | 旧当前值。 |

### Constants

#### `DEFAULT_MIN_VALUE`

- API: `public`

```gdscript
const DEFAULT_MIN_VALUE: float = -1.0e20
```

默认属性最小值。

#### `DEFAULT_MAX_VALUE`

- API: `public`

```gdscript
const DEFAULT_MAX_VALUE: float = 1.0e20
```

默认属性最大值。

### Properties

#### `attributes`

- API: `public`

```gdscript
var attributes: Dictionary = {}
```

属性记录。结构为 attribute_id -> { base, current, min, max, metadata }。

Schemas:

- `attributes`: Dictionary，键为 StringName 属性 ID，值为包含 base: float、current: float、min: float、max: float、metadata: Dictionary 的记录。

#### `derived_rules`

- API: `public`

```gdscript
var derived_rules: Array[GFDerivedAttributeRule] = []
```

派生属性规则列表。规则只计算属性值，不改变属性命名含义。

Schemas:

- `derived_rules`: Array[GFDerivedAttributeRule]，按顺序保存的派生属性规则资源。

### Methods

#### `define_attribute`

- API: `public`

```gdscript
func define_attribute( attribute_id: StringName, base_value: float = 0.0, current_value: Variant = null, min_value: float = DEFAULT_MIN_VALUE, max_value: float = DEFAULT_MAX_VALUE, metadata: Dictionary = {} ) -> void:
```

定义或替换属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `base_value` | 基础值。 |
| `current_value` | 当前值；为 null 或 NAN 时使用 base_value。 |
| `min_value` | 最小值。 |
| `max_value` | 最大值。 |
| `metadata` | 项目自定义元数据。 |

Schemas:

- `current_value`: Variant，null 或 NAN 表示使用 base_value，数字值会转换为 float。
- `metadata`: Dictionary，项目自定义属性元数据；GF 会深拷贝保存。

#### `has_attribute`

- API: `public`

```gdscript
func has_attribute(attribute_id: StringName) -> bool:
```

检查属性是否存在。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

Returns: 存在返回 true。

#### `remove_attribute`

- API: `public`

```gdscript
func remove_attribute(attribute_id: StringName) -> void:
```

移除属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有属性。

#### `set_value`

- API: `public`

```gdscript
func set_value(attribute_id: StringName, value: float) -> bool:
```

设置当前值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `value` | 新值。 |

Returns: 成功返回 true。

#### `adjust_value`

- API: `public`

```gdscript
func adjust_value(attribute_id: StringName, delta: float) -> bool:
```

增减当前值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `delta` | 增量。 |

Returns: 成功返回 true。

#### `set_base_value`

- API: `public`

```gdscript
func set_base_value(attribute_id: StringName, value: float, sync_current: bool = false) -> bool:
```

设置基础值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `value` | 新基础值。 |
| `sync_current` | 是否同步当前值。 |

Returns: 成功返回 true。

#### `set_limits`

- API: `public`

```gdscript
func set_limits(attribute_id: StringName, min_value: float, max_value: float) -> bool:
```

设置属性范围。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `min_value` | 最小值。 |
| `max_value` | 最大值。 |

Returns: 成功返回 true。

#### `get_value`

- API: `public`

```gdscript
func get_value(attribute_id: StringName, default_value: float = 0.0) -> float:
```

获取当前值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `default_value` | 默认值。 |

Returns: 当前值。

#### `get_base_value`

- API: `public`

```gdscript
func get_base_value(attribute_id: StringName, default_value: float = 0.0) -> float:
```

获取基础值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `default_value` | 默认值。 |

Returns: 基础值。

#### `get_value_with_traits`

- API: `public`

```gdscript
func get_value_with_traits(attribute_id: StringName, trait_set: GFTraitSet) -> float:
```

通过 TraitSet 计算属性值。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `trait_set` | 特征集合。 |

Returns: Trait 修饰后的值。

#### `get_metadata`

- API: `public`

```gdscript
func get_metadata(attribute_id: StringName) -> Dictionary:
```

获取属性元数据。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |

Returns: 元数据副本。

Schemas:

- `return`: Dictionary，属性的项目自定义 metadata 副本；属性不存在时为空字典。

#### `set_metadata`

- API: `public`

```gdscript
func set_metadata(attribute_id: StringName, metadata: Dictionary) -> bool:
```

设置属性元数据。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 属性标识。 |
| `metadata` | 元数据。 |

Returns: 成功返回 true。

Schemas:

- `metadata`: Dictionary，项目自定义属性元数据；GF 会深拷贝保存。

#### `add_derived_rule`

- API: `public`

```gdscript
func add_derived_rule(rule: GFDerivedAttributeRule) -> bool:
```

添加或替换派生属性规则。

Parameters:

| Name | Description |
|---|---|
| `rule` | 派生属性规则。 |

Returns: 成功返回 true。

#### `remove_derived_rule`

- API: `public`

```gdscript
func remove_derived_rule(attribute_id: StringName) -> bool:
```

移除指定目标属性的派生规则。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 目标属性 ID。 |

Returns: 至少移除一个规则时返回 true。

#### `get_derived_rule`

- API: `public`

```gdscript
func get_derived_rule(attribute_id: StringName) -> GFDerivedAttributeRule:
```

获取指定目标属性的派生规则。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 目标属性 ID。 |

Returns: 派生规则；不存在时返回 null。

#### `recalculate_derived`

- API: `public`

```gdscript
func recalculate_derived(attribute_id: StringName = &"") -> void:
```

重新计算派生属性。

Parameters:

| Name | Description |
|---|---|
| `attribute_id` | 目标属性 ID；为空时重算全部规则。 |

#### `get_snapshot`

- API: `public`

```gdscript
func get_snapshot() -> Dictionary:
```

导出快照。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，键为 String 属性 ID，值为包含 base、current、min、max 与 metadata 的属性记录。

#### `restore_snapshot`

- API: `public`

```gdscript
func restore_snapshot(snapshot: Dictionary) -> void:
```

从快照恢复。

Parameters:

| Name | Description |
|---|---|
| `snapshot` | 由 get_snapshot() 或 to_dict() 返回的数据。 |

Schemas:

- `snapshot`: Dictionary，键为 String 或 StringName 属性 ID，值为包含 base、current、min、max 与 metadata 的属性记录。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

序列化为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，键为 String 属性 ID，值为包含 base、current、min、max 与 metadata 的属性记录。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 属性数据。 |

Schemas:

- `data`: Dictionary，键为 String 或 StringName 属性 ID，值为包含 base、current、min、max 与 metadata 的属性记录。

## GFDerivedAttributeRule

- Path: `addons/gf/extensions/domain/attributes/gf_derived_attribute_rule.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFDerivedAttributeRule: 通用派生属性规则。 通过权重或自定义回调从 GFAttributeSet 的其他属性计算目标属性，不规定属性业务含义。

### Constants

#### `DEFAULT_MIN_VALUE`

- API: `public`

```gdscript
const DEFAULT_MIN_VALUE: float = -1.0e20
```

默认规则最小值。

#### `DEFAULT_MAX_VALUE`

- API: `public`

```gdscript
const DEFAULT_MAX_VALUE: float = 1.0e20
```

默认规则最大值。

### Properties

#### `attribute_id`

- API: `public`

```gdscript
var attribute_id: StringName = &""
```

被写入的目标属性 ID。

#### `source_attribute_ids`

- API: `public`

```gdscript
var source_attribute_ids: Array[StringName] = []
```

参与计算的来源属性 ID。为空时使用 source_weights 的键。

Schemas:

- `source_attribute_ids`: Array[StringName]，参与当前派生规则计算的来源属性 ID 列表。

#### `source_weights`

- API: `public`

```gdscript
var source_weights: Dictionary = {}
```

来源属性权重，键为属性 ID，值为数字权重。

Schemas:

- `source_weights`: Dictionary，键为 StringName 或 String 属性 ID，值为 float 权重。

#### `flat_bonus`

- API: `public`

```gdscript
var flat_bonus: float = 0.0
```

固定加值。

#### `min_value`

- API: `public`

```gdscript
var min_value: float = DEFAULT_MIN_VALUE
```

规则级最小值。

#### `max_value`

- API: `public`

```gdscript
var max_value: float = DEFAULT_MAX_VALUE
```

规则级最大值。

#### `sync_base_value`

- API: `public`

```gdscript
var sync_base_value: bool = false
```

是否同步写入目标属性的 base 值。

#### `compute_callback`

- API: `public`

```gdscript
var compute_callback: Callable = Callable()
```

自定义计算回调，建议签名为 func(attribute_set: GFAttributeSet, rule: GFDerivedAttributeRule) -> Variant。

### Methods

#### `calculate`

- API: `public`

```gdscript
func calculate(attribute_set: Object) -> float:
```

计算派生属性值。

Parameters:

| Name | Description |
|---|---|
| `attribute_set` | 属性集合。 |

Returns: 计算后的数值。

#### `get_source_attribute_ids`

- API: `public`

```gdscript
func get_source_attribute_ids() -> Array[StringName]:
```

获取来源属性 ID 列表。

Returns: 来源属性 ID 副本。

Schemas:

- `return`: Array[StringName]，当前规则实际使用的来源属性 ID 列表。

#### `get_source_weight`

- API: `public`

```gdscript
func get_source_weight(source_attribute_id: StringName) -> float:
```

获取来源属性权重。

Parameters:

| Name | Description |
|---|---|
| `source_attribute_id` | 来源属性 ID。 |

Returns: 权重；未配置时返回 1。

#### `depends_on`

- API: `public`

```gdscript
func depends_on(source_attribute_id: StringName) -> bool:
```

判断是否依赖指定属性。

Parameters:

| Name | Description |
|---|---|
| `source_attribute_id` | 来源属性 ID。 |

Returns: 依赖返回 true。

#### `duplicate_rule`

- API: `public`

```gdscript
func duplicate_rule() -> GFDerivedAttributeRule:
```

创建当前规则的深拷贝。

Returns: 规则副本。

## GFEquipmentSet

- Path: `addons/gf/extensions/domain/equipment/gf_equipment_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFEquipmentSet: 通用槽位集合。 用于管理一组 `GFEquipmentSlot`，不约束槽位名称或装备类型。

### Properties

#### `slots`

- API: `public`

```gdscript
var slots: Dictionary = {}
```

槽位表。Key 推荐为 StringName，Value 应为 GFEquipmentSlot。

Schemas:

- `slots`: Dictionary，键为 StringName 槽位 ID，值为 GFEquipmentSlot 槽位资源。

### Methods

#### `set_slot`

- API: `public`

```gdscript
func set_slot(slot: GFEquipmentSlot) -> void:
```

添加或替换槽位。

Parameters:

| Name | Description |
|---|---|
| `slot` | 槽位资源。 |

#### `get_slot`

- API: `public`

```gdscript
func get_slot(slot_id: StringName) -> GFEquipmentSlot:
```

获取槽位。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 槽位资源；不存在时返回 null。

#### `equip`

- API: `public`

```gdscript
func equip(slot_id: StringName, item_id: StringName, item_tags: Array[StringName] = []) -> bool:
```

挂载物品到槽位。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |
| `item_id` | 物品 ID。 |
| `item_tags` | 物品标签。 |

Returns: 成功时返回 true。

Schemas:

- `item_tags`: Array[StringName]，当前物品拥有的标签列表。

#### `unequip`

- API: `public`

```gdscript
func unequip(slot_id: StringName) -> void:
```

清空槽位。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

#### `get_equipped_item`

- API: `public`

```gdscript
func get_equipped_item(slot_id: StringName) -> StringName:
```

获取槽位当前物品。

Parameters:

| Name | Description |
|---|---|
| `slot_id` | 槽位 ID。 |

Returns: 物品 ID。

## GFEquipmentSlot

- Path: `addons/gf/extensions/domain/equipment/gf_equipment_slot.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFEquipmentSlot: 通用装备/挂载槽位。 槽位只记录可接受标签和已挂载 item_id，不规定装备类型。

### Properties

#### `slot_id`

- API: `public`

```gdscript
var slot_id: StringName = &""
```

槽位 ID。

#### `item_id`

- API: `public`

```gdscript
var item_id: StringName = &""
```

当前挂载的物品 ID。

#### `accepted_tags`

- API: `public`

```gdscript
var accepted_tags: Array[StringName] = []
```

接受的物品标签。为空表示不限制。

Schemas:

- `accepted_tags`: Array[StringName]，槽位接受的物品标签；为空时不限制。

#### `require_all_tags`

- API: `public`

```gdscript
var require_all_tags: bool = false
```

是否要求物品同时拥有全部 accepted_tags。false 表示拥有任一标签即可。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义槽位元数据；GF 不读取或改写其中字段。

### Methods

#### `can_accept`

- API: `public`

```gdscript
func can_accept(item_tags: Array[StringName]) -> bool:
```

检查标签是否可被槽位接受。

Parameters:

| Name | Description |
|---|---|
| `item_tags` | 物品标签。 |

Returns: 可接受时返回 true。

Schemas:

- `item_tags`: Array[StringName]，当前物品拥有的标签列表。

#### `equip`

- API: `public`

```gdscript
func equip(p_item_id: StringName, item_tags: Array[StringName] = []) -> bool:
```

挂载物品。

Parameters:

| Name | Description |
|---|---|
| `p_item_id` | 物品 ID。 |
| `item_tags` | 物品标签。 |

Returns: 成功时返回 true。

Schemas:

- `item_tags`: Array[StringName]，当前物品拥有的标签列表。

#### `unequip`

- API: `public`

```gdscript
func unequip() -> void:
```

清空槽位。

## GFInventoryItemDefinition

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_item_definition.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInventoryItemDefinition: 通用库存物品定义。 只描述库存系统需要理解的堆叠、分类和实例数据匹配规则， 不规定品质、装备、货币、掉落等项目业务语义。

### Properties

#### `item_id`

- API: `public`

```gdscript
var item_id: StringName = &""
```

物品稳定标识。

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

显示名称，供项目 UI 或编辑器工具使用。

#### `description`

- API: `public`

```gdscript
var description: String = ""
```

描述文本，供项目 UI 或编辑器工具使用。

#### `icon`

- API: `public`

```gdscript
var icon: Texture2D = null
```

可选图标资源。

#### `max_stack_amount`

- API: `public`

```gdscript
var max_stack_amount: int:
```

单个堆叠最多容纳的数量。

#### `max_stack_count`

- API: `public`

```gdscript
var max_stack_count: int:
```

同一物品最多占用的堆叠数量。小于等于 0 表示不限制。

#### `categories`

- API: `public`

```gdscript
var categories: Array[StringName] = []
```

分类标签。框架只保存和匹配，不解释具体含义。

Schemas:

- `categories`: Array[StringName]，用于项目自定义筛选的分类标签列表。

#### `default_instance_data`

- API: `public`

```gdscript
var default_instance_data: Dictionary = {}
```

默认实例数据。空堆叠或空输入会按这些默认值参与兼容性比较。

Schemas:

- `default_instance_data`: Dictionary，物品实例数据默认值；用于堆叠兼容性比较和序列化。

#### `stack_key_fields`

- API: `public`

```gdscript
var stack_key_fields: PackedStringArray = PackedStringArray()
```

用于判断堆叠兼容性的实例数据字段。为空时比较完整实例数据。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义物品定义元数据；GF 不读取或改写其中字段。

#### `compatibility_checker`

- API: `public`

```gdscript
var compatibility_checker: Callable = Callable()
```

可选堆叠兼容性回调。签名为 Callable(left: Dictionary, right: Dictionary, definition: GFInventoryItemDefinition) -> bool。

### Methods

#### `get_item_id`

- API: `public`

```gdscript
func get_item_id() -> StringName:
```

获取稳定物品标识。

Returns: 物品标识。

#### `get_display_name`

- API: `public`

```gdscript
func get_display_name() -> String:
```

获取可显示名称。

Returns: 显示名称；为空时回退到 item_id 或资源文件名。

#### `has_category`

- API: `public`

```gdscript
func has_category(category: StringName) -> bool:
```

检查是否包含分类标签。

Parameters:

| Name | Description |
|---|---|
| `category` | 分类标签。 |

Returns: 包含时返回 true。

#### `matches_categories`

- API: `public`

```gdscript
func matches_categories(required_categories: Array[StringName]) -> bool:
```

检查是否满足全部分类标签。

Parameters:

| Name | Description |
|---|---|
| `required_categories` | 需要匹配的分类标签。 |

Returns: 全部满足时返回 true。

Schemas:

- `required_categories`: Array[StringName]，必须全部存在于 categories 中的分类标签列表。

#### `normalize_instance_data`

- API: `public`

```gdscript
func normalize_instance_data(instance_data: Dictionary = {}) -> Dictionary:
```

规范化实例数据。与默认实例数据等价时返回空字典。

Parameters:

| Name | Description |
|---|---|
| `instance_data` | 实例数据。 |

Returns: 规范化后的实例数据副本。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据。
- `return`: Dictionary，规范化后的物品实例数据副本；等价于默认实例数据时为空字典。

#### `are_instance_data_compatible`

- API: `public`

```gdscript
func are_instance_data_compatible(left: Dictionary = {}, right: Dictionary = {}) -> bool:
```

判断两份实例数据是否可以合并到同一堆叠。

Parameters:

| Name | Description |
|---|---|
| `left` | 左侧实例数据。 |
| `right` | 右侧实例数据。 |

Returns: 可合并返回 true。

Schemas:

- `left`: Dictionary，左侧物品实例数据。
- `right`: Dictionary，右侧物品实例数据。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，包含 item_id、display_name、description、max_stack_amount、max_stack_count、categories、default_instance_data、stack_key_fields 与 metadata。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary，可包含 item_id、display_name、description、max_stack_amount、max_stack_count、categories、default_instance_data、stack_key_fields 与 metadata。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFInventoryItemDefinition:
```

从字典创建物品定义。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Returns: 物品定义。

Schemas:

- `data`: Dictionary，可包含 item_id、display_name、description、max_stack_amount、max_stack_count、categories、default_instance_data、stack_key_fields 与 metadata。

## GFInventoryItemRegistry

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_item_registry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFInventoryItemRegistry: 通用库存物品定义注册表。 统一提供物品堆叠上限、堆叠数量上限和实例数据兼容性规则。 未注册物品可按默认规则处理，便于项目渐进接入资源化定义。

### Properties

#### `definitions`

- API: `public`

```gdscript
var definitions: Dictionary = {}
```

物品定义表。Key 推荐为 StringName，Value 应为 GFInventoryItemDefinition。

Schemas:

- `definitions`: Dictionary，键为 StringName 或 String 物品 ID，值为 GFInventoryItemDefinition 物品定义资源。

#### `default_max_stack_amount`

- API: `public`

```gdscript
var default_max_stack_amount: int:
```

未注册物品的默认单堆叠容量。

#### `default_max_stack_count`

- API: `public`

```gdscript
var default_max_stack_count: int:
```

未注册物品的默认堆叠数量上限。小于等于 0 表示不限制。

#### `allow_unregistered_items`

- API: `public`

```gdscript
var allow_unregistered_items: bool = true
```

是否允许未注册物品进入库存。

### Methods

#### `set_definition`

- API: `public`

```gdscript
func set_definition(definition: GFInventoryItemDefinition) -> void:
```

添加或替换物品定义。

Parameters:

| Name | Description |
|---|---|
| `definition` | 物品定义。 |

#### `remove_definition`

- API: `public`

```gdscript
func remove_definition(item_id: StringName) -> void:
```

移除物品定义。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空所有物品定义。

#### `has_definition`

- API: `public`

```gdscript
func has_definition(item_id: StringName) -> bool:
```

检查物品定义是否存在。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

Returns: 存在返回 true。

#### `get_definition`

- API: `public`

```gdscript
func get_definition(item_id: StringName) -> GFInventoryItemDefinition:
```

获取物品定义。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

Returns: 物品定义；不存在时返回 null。

#### `accepts_item`

- API: `public`

```gdscript
func accepts_item(item_id: StringName) -> bool:
```

检查物品是否可被库存接受。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

Returns: 可接受返回 true。

#### `get_max_stack_amount`

- API: `public`

```gdscript
func get_max_stack_amount(item_id: StringName) -> int:
```

获取单堆叠容量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

Returns: 单堆叠容量。

#### `get_max_stack_count`

- API: `public`

```gdscript
func get_max_stack_count(item_id: StringName) -> int:
```

获取堆叠数量上限。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |

Returns: 堆叠数量上限；小于等于 0 表示不限制。

#### `normalize_instance_data`

- API: `public`

```gdscript
func normalize_instance_data(item_id: StringName, instance_data: Dictionary = {}) -> Dictionary:
```

规范化物品实例数据。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `instance_data` | 实例数据。 |

Returns: 规范化后的实例数据副本。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据。
- `return`: Dictionary，规范化后的物品实例数据副本。

#### `are_instance_data_compatible`

- API: `public`

```gdscript
func are_instance_data_compatible( item_id: StringName, left: Dictionary = {}, right: Dictionary = {} ) -> bool:
```

判断两份实例数据是否可合并堆叠。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `left` | 左侧实例数据。 |
| `right` | 右侧实例数据。 |

Returns: 可合并返回 true。

Schemas:

- `left`: Dictionary，左侧物品实例数据。
- `right`: Dictionary，右侧物品实例数据。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，包含 definitions、default_max_stack_amount、default_max_stack_count 与 allow_unregistered_items。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary，可包含 definitions、default_max_stack_amount、default_max_stack_count 与 allow_unregistered_items。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFInventoryItemRegistry:
```

从字典创建注册表。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Returns: 物品定义注册表。

Schemas:

- `data`: Dictionary，可包含 definitions、default_max_stack_amount、default_max_stack_count 与 allow_unregistered_items。

## GFInventoryModel

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_model.gd`
- Extends: `GFModel`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFInventoryModel: 通用可序列化库存模型。 只管理 item_id、数量和元数据，不假设道具类型、品质、装备等业务概念。

### Methods

#### `add_item`

- API: `public`

```gdscript
func add_item(item_id: StringName, amount: int = 1, metadata: Dictionary = {}) -> void:
```

添加物品数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |
| `amount` | 增加数量。 |
| `metadata` | 可选元数据；首次加入时保存。 |

Schemas:

- `metadata`: Dictionary，首次加入物品时保存的项目自定义元数据。

#### `remove_item`

- API: `public`

```gdscript
func remove_item(item_id: StringName, amount: int = 1) -> bool:
```

移除物品数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |
| `amount` | 移除数量。 |

Returns: 成功移除完整数量时返回 true。

#### `set_item_amount`

- API: `public`

```gdscript
func set_item_amount(item_id: StringName, amount: int) -> void:
```

设置物品数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |
| `amount` | 新数量；小于等于 0 时移除。 |

#### `get_item_amount`

- API: `public`

```gdscript
func get_item_amount(item_id: StringName) -> int:
```

获取物品数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |

Returns: 数量。

#### `has_item`

- API: `public`

```gdscript
func has_item(item_id: StringName, amount: int = 1) -> bool:
```

检查是否拥有足够数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |
| `amount` | 需要数量。 |

Returns: 足够时返回 true。

#### `get_item_metadata`

- API: `public`

```gdscript
func get_item_metadata(item_id: StringName) -> Dictionary:
```

获取物品元数据。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品 ID。 |

Returns: 元数据副本。

Schemas:

- `return`: Dictionary，物品项目自定义元数据副本；不存在时为空字典。

#### `get_items`

- API: `public`

```gdscript
func get_items() -> Dictionary:
```

获取库存快照。

Returns: 库存字典副本。

Schemas:

- `return`: Dictionary，键为 StringName 物品 ID，值为包含 amount 与 metadata 的堆叠记录。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空库存。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

序列化库存状态。

Returns: 可写入存档的字典。

Schemas:

- `return`: Dictionary，包含 items 字典；items 键为 String 物品 ID，值为 amount 与 metadata 记录。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复库存状态。

Parameters:

| Name | Description |
|---|---|
| `data` | 序列化数据。 |

Schemas:

- `data`: Dictionary，包含 items 字典；items 键为 String 物品 ID，值为 amount 与 metadata 记录。

## GFInventoryOperationResult

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_operation_result.gd`
- Extends: `RefCounted`
- API: `public`
- Category: `value_object`
- Since: `3.17.0`

GFInventoryOperationResult: 通用库存操作结果。 描述一次添加、移除、移动或合并操作的接受数量、剩余数量和失败原因。

### Properties

#### `ok`

- API: `public`

```gdscript
var ok: bool = false
```

操作是否完全成功。

#### `item_id`

- API: `public`

```gdscript
var item_id: StringName = &""
```

物品标识。

#### `requested_amount`

- API: `public`

```gdscript
var requested_amount: int = 0
```

请求处理的数量。

#### `accepted_amount`

- API: `public`

```gdscript
var accepted_amount: int = 0
```

实际处理的数量。

#### `remaining_amount`

- API: `public`

```gdscript
var remaining_amount: int = 0
```

未处理的剩余数量。

#### `source_slot`

- API: `public`

```gdscript
var source_slot: int = -1
```

源槽位。没有源槽位时为 -1。

#### `target_slot`

- API: `public`

```gdscript
var target_slot: int = -1
```

目标槽位。没有目标槽位时为 -1。

#### `reason`

- API: `public`

```gdscript
var reason: StringName = &""
```

操作结果原因。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义操作结果元数据；GF 会在 to_dict() 中复制输出。

### Methods

#### `success`

- API: `public`

```gdscript
static func success( result_item_id: StringName, amount: int, result_source_slot: int = -1, result_target_slot: int = -1 ) -> GFInventoryOperationResult:
```

创建成功结果。

Parameters:

| Name | Description |
|---|---|
| `result_item_id` | 物品标识。 |
| `amount` | 处理数量。 |
| `result_source_slot` | 源槽位。 |
| `result_target_slot` | 目标槽位。 |

Returns: 操作结果。

#### `partial`

- API: `public`

```gdscript
static func partial( result_item_id: StringName, requested: int, accepted: int, result_reason: StringName, result_source_slot: int = -1, result_target_slot: int = -1 ) -> GFInventoryOperationResult:
```

创建失败或部分成功结果。

Parameters:

| Name | Description |
|---|---|
| `result_item_id` | 物品标识。 |
| `requested` | 请求数量。 |
| `accepted` | 实际处理数量。 |
| `result_reason` | 操作结果原因。 |
| `result_source_slot` | 源槽位。 |
| `result_target_slot` | 目标槽位。 |

Returns: 操作结果。

#### `is_partial_success`

- API: `public`

```gdscript
func is_partial_success() -> bool:
```

检查操作是否处理了部分数量。

Returns: 有部分处理返回 true。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 操作结果字典。

Schemas:

- `return`: Dictionary，包含 ok、item_id、requested_amount、accepted_amount、remaining_amount、source_slot、target_slot、reason 与 metadata。

## GFInventorySlotDefinition

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_slot_definition.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.20.0`

GFInventorySlotDefinition: 通用库存槽位接收规则。 只描述一个槽位允许接收哪些物品或分类，不保存槽位内容，也不绑定 UI、 拖拽、装备类型或具体项目玩法。项目可把它挂到 `GFSlotInventoryModel.slot_definitions` 上，为背包、快捷栏或容器槽位提供轻量约束。

### Properties

#### `display_name`

- API: `public`

```gdscript
var display_name: String = ""
```

显示名称，供项目 UI 或编辑器工具使用。

#### `accepted_item_ids`

- API: `public`

```gdscript
var accepted_item_ids: Array[StringName] = []
```

允许的物品 ID。为空表示不按物品 ID 限制。

Schemas:

- `accepted_item_ids`: Array[StringName]，槽位允许接收的物品 ID；为空时不限制。

#### `rejected_item_ids`

- API: `public`

```gdscript
var rejected_item_ids: Array[StringName] = []
```

禁止的物品 ID。优先级高于 accepted_item_ids。

Schemas:

- `rejected_item_ids`: Array[StringName]，槽位拒绝接收的物品 ID。

#### `accepted_categories`

- API: `public`

```gdscript
var accepted_categories: Array[StringName] = []
```

允许的物品分类。为空表示不按分类限制。

Schemas:

- `accepted_categories`: Array[StringName]，槽位允许接收的物品分类；为空时不限制。

#### `require_all_categories`

- API: `public`

```gdscript
var require_all_categories: bool = false
```

是否要求物品同时拥有全部 accepted_categories。false 表示拥有任一分类即可。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

项目自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义槽位元数据；GF 不读取或改写其中字段。

#### `acceptance_checker`

- API: `public`

```gdscript
var acceptance_checker: Callable = Callable()
```

可选接收检查回调。签名为 Callable(item_id, definition, instance_data, slot_index, inventory) -> bool。

### Methods

#### `can_accept`

- API: `public`

```gdscript
func can_accept( item_id: StringName, definition: GFInventoryItemDefinition = null, instance_data: Dictionary = {}, slot_index: int = -1, inventory: Object = null ) -> bool:
```

判断槽位是否接受指定物品。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `definition` | 可选物品定义；分类规则需要该定义。 |
| `instance_data` | 物品实例数据。 |
| `slot_index` | 槽位索引。 |
| `inventory` | 调用方库存模型。 |

Returns: 接受时返回 true。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，包含 display_name、accepted_item_ids、rejected_item_ids、accepted_categories、require_all_categories 与 metadata。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary，可包含 display_name、accepted_item_ids、rejected_item_ids、accepted_categories、require_all_categories 与 metadata。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFInventorySlotDefinition:
```

从字典创建槽位定义。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Returns: 槽位定义。

Schemas:

- `data`: Dictionary，可包含 display_name、accepted_item_ids、rejected_item_ids、accepted_categories、require_all_categories 与 metadata。

## GFInventoryStack

- Path: `addons/gf/extensions/domain/inventory/gf_inventory_stack.gd`
- Extends: `Resource`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFInventoryStack: 通用库存堆叠记录。 只保存物品标识、数量和实例数据，不解释实例数据的业务含义。

### Properties

#### `item_id`

- API: `public`

```gdscript
var item_id: StringName = &""
```

物品稳定标识。

#### `amount`

- API: `public`

```gdscript
var amount: int:
```

当前堆叠数量。

#### `instance_data`

- API: `public`

```gdscript
var instance_data: Dictionary = {}
```

项目自定义实例数据。框架只用于兼容性比较和序列化。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；GF 只用于兼容性比较和序列化。

### Methods

#### `is_empty`

- API: `public`

```gdscript
func is_empty() -> bool:
```

检查堆叠是否为空。

Returns: 为空返回 true。

#### `get_stack_limit`

- API: `public`

```gdscript
func get_stack_limit(registry: GFInventoryItemRegistry = null) -> int:
```

获取当前堆叠容量上限。

Parameters:

| Name | Description |
|---|---|
| `registry` | 可选物品注册表。 |

Returns: 堆叠容量上限。

#### `get_available_space`

- API: `public`

```gdscript
func get_available_space(registry: GFInventoryItemRegistry = null) -> int:
```

获取当前堆叠剩余空间。

Parameters:

| Name | Description |
|---|---|
| `registry` | 可选物品注册表。 |

Returns: 剩余空间。

#### `can_merge`

- API: `public`

```gdscript
func can_merge( target_item_id: StringName, target_instance_data: Dictionary = {}, registry: GFInventoryItemRegistry = null ) -> bool:
```

检查是否可与指定物品实例合并。

Parameters:

| Name | Description |
|---|---|
| `target_item_id` | 目标物品标识。 |
| `target_instance_data` | 目标实例数据。 |
| `registry` | 可选物品注册表。 |

Returns: 可合并返回 true。

Schemas:

- `target_instance_data`: Dictionary，目标物品实例数据。

#### `add_amount`

- API: `public`

```gdscript
func add_amount(add_amount: int, registry: GFInventoryItemRegistry = null) -> int:
```

增加数量并返回未加入的剩余数量。

Parameters:

| Name | Description |
|---|---|
| `add_amount` | 尝试增加的数量。 |
| `registry` | 可选物品注册表。 |

Returns: 未加入的剩余数量。

#### `remove_amount`

- API: `public`

```gdscript
func remove_amount(remove_amount: int) -> int:
```

移除数量并返回实际移除数量。

Parameters:

| Name | Description |
|---|---|
| `remove_amount` | 尝试移除的数量。 |

Returns: 实际移除数量。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空堆叠。

#### `duplicate_stack`

- API: `public`

```gdscript
func duplicate_stack() -> GFInventoryStack:
```

复制堆叠。

Returns: 新堆叠资源。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

转换为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，包含 item_id、amount 与 instance_data。

#### `apply_dict`

- API: `public`

```gdscript
func apply_dict(data: Dictionary) -> void:
```

应用字典数据。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary，可包含 item_id、amount 与 instance_data。

#### `from_dict`

- API: `public`

```gdscript
static func from_dict(data: Dictionary) -> GFInventoryStack:
```

从字典创建堆叠。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Returns: 堆叠资源。

Schemas:

- `data`: Dictionary，可包含 item_id、amount 与 instance_data。

## GFLevelCatalog

- Path: `addons/gf/extensions/domain/level/gf_level_catalog.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFLevelCatalog: 通用关卡目录资源。 用于按关卡包和排序值组织 GFLevelEntry，保持目录查询与具体关卡规则解耦。

### Properties

#### `entries`

- API: `public`

```gdscript
var entries: Array[GFLevelEntry] = []
```

关卡条目列表。

Schemas:

- `entries`: Array[GFLevelEntry]，关卡目录条目列表；查询方法会返回条目拷贝。

### Methods

#### `add_entry`

- API: `public`

```gdscript
func add_entry(entry: GFLevelEntry) -> void:
```

添加关卡条目。

Parameters:

| Name | Description |
|---|---|
| `entry` | 关卡条目。 |

#### `has_level`

- API: `public`

```gdscript
func has_level(level_id: StringName) -> bool:
```

检查关卡是否存在。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 存在时返回 true。

#### `get_entry`

- API: `public`

```gdscript
func get_entry(level_id: StringName) -> GFLevelEntry:
```

获取关卡条目。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 条目拷贝；不存在时返回 null。

#### `get_levels`

- API: `public`

```gdscript
func get_levels(pack_id: StringName = &"") -> Array[GFLevelEntry]:
```

获取指定关卡扩展中的条目。

Parameters:

| Name | Description |
|---|---|
| `pack_id` | 关卡扩展 ID；为空时返回全部。 |

Returns: 已排序的条目拷贝数组。

Schemas:

- `return`: Array[GFLevelEntry]，按 sort_order 与 level_id 排序后的关卡条目拷贝。

#### `get_pack_ids`

- API: `public`

```gdscript
func get_pack_ids() -> Array[StringName]:
```

获取所有关卡扩展 ID。

Returns: 关卡扩展 ID 数组。

Schemas:

- `return`: Array[StringName]，已排序的关卡包或章节 ID 列表。

#### `get_next_level_id`

- API: `public`

```gdscript
func get_next_level_id(level_id: StringName) -> StringName:
```

获取同关卡扩展内下一个关卡 ID。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 当前关卡 ID。 |

Returns: 后续关卡 ID；没有时返回空 StringName。

#### `get_previous_level_id`

- API: `public`

```gdscript
func get_previous_level_id(level_id: StringName) -> StringName:
```

获取同关卡扩展内上一个关卡 ID。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 当前关卡 ID。 |

Returns: 前序关卡 ID；没有时返回空 StringName。

## GFLevelEntry

- Path: `addons/gf/extensions/domain/level/gf_level_entry.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFLevelEntry: 通用关卡目录条目。 只描述关卡 ID、所属分组、可选场景路径和元数据，不规定关卡玩法规则。

### Properties

#### `level_id`

- API: `public`

```gdscript
var level_id: StringName = &""
```

关卡稳定 ID。

#### `pack_id`

- API: `public`

```gdscript
var pack_id: StringName = &""
```

可选关卡包或章节 ID。

#### `scene_path`

- API: `public`

```gdscript
var scene_path: String = ""
```

可选关卡场景路径。

#### `sort_order`

- API: `public`

```gdscript
var sort_order: int = 0
```

目录排序值，数值越小越靠前。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

关卡通用元数据。

Schemas:

- `metadata`: Dictionary，项目自定义关卡元数据；GF 会在构建关卡数据时复制透传。

#### `unlocks_on_complete`

- API: `public`

```gdscript
var unlocks_on_complete: Array[StringName] = []
```

当前关卡完成后建议解锁的后续关卡 ID。

Schemas:

- `unlocks_on_complete`: Array[StringName]，完成当前关卡后建议解锁的关卡 ID 列表。

### Methods

#### `get_level_id`

- API: `public`

```gdscript
func get_level_id() -> StringName:
```

获取稳定关卡 ID。

Returns: 关卡 ID。

#### `duplicate_entry`

- API: `public`

```gdscript
func duplicate_entry() -> GFLevelEntry:
```

创建条目拷贝。

Returns: 新条目。

## GFLevelProgressModel

- Path: `addons/gf/extensions/domain/level/gf_level_progress_model.gd`
- Extends: `GFModel`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFLevelProgressModel: 通用关卡解锁与完成进度模型。 只记录关卡是否解锁、是否完成以及项目层自定义结果字典。

### Signals

#### `level_unlocked`

- API: `public`

```gdscript
signal level_unlocked(level_id: StringName)
```

关卡解锁时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

#### `level_locked`

- API: `public`

```gdscript
signal level_locked(level_id: StringName)
```

关卡锁定时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

#### `level_completed`

- API: `public`

```gdscript
signal level_completed(level_id: StringName, result: Dictionary)
```

关卡完成时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `result` | 完成结果。 |

Schemas:

- `result`: Dictionary，项目自定义关卡完成结果副本。

#### `level_result_updated`

- API: `public`

```gdscript
signal level_result_updated(level_id: StringName, result: Dictionary)
```

关卡结果更新时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `result` | 结果字典。 |

Schemas:

- `result`: Dictionary，项目自定义关卡结果副本。

### Methods

#### `unlock_level`

- API: `public`

```gdscript
func unlock_level(level_id: StringName) -> void:
```

解锁关卡。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

#### `lock_level`

- API: `public`

```gdscript
func lock_level(level_id: StringName) -> void:
```

锁定关卡。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

#### `is_level_unlocked`

- API: `public`

```gdscript
func is_level_unlocked(level_id: StringName) -> bool:
```

检查关卡是否解锁。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 已解锁时返回 true。

#### `complete_level`

- API: `public`

```gdscript
func complete_level(level_id: StringName, result: Dictionary = {}, merge_result: bool = true) -> void:
```

标记关卡完成。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `result` | 项目层结果数据。 |
| `merge_result` | 是否合并已有结果。 |

Schemas:

- `result`: Dictionary，项目自定义关卡完成结果；merge_result 为 true 时会覆盖同名字段。

#### `is_level_completed`

- API: `public`

```gdscript
func is_level_completed(level_id: StringName) -> bool:
```

检查关卡是否完成。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 已完成时返回 true。

#### `set_level_result`

- API: `public`

```gdscript
func set_level_result(level_id: StringName, result: Dictionary, merge_result: bool = true) -> void:
```

设置关卡结果。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `result` | 结果字典。 |
| `merge_result` | 是否合并已有结果。 |

Schemas:

- `result`: Dictionary，项目自定义关卡结果；merge_result 为 true 时会覆盖同名字段。

#### `get_level_result`

- API: `public`

```gdscript
func get_level_result(level_id: StringName) -> Dictionary:
```

获取关卡结果。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 结果字典副本。

Schemas:

- `return`: Dictionary，项目自定义关卡结果副本；不存在时为空字典。

#### `clear_progress`

- API: `public`

```gdscript
func clear_progress() -> void:
```

清空所有进度。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

序列化进度。

Returns: 字典数据。

Schemas:

- `return`: Dictionary，包含 unlocked_levels、completed_levels 与 level_results 三个 String 键字典。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

反序列化进度。

Parameters:

| Name | Description |
|---|---|
| `data` | 字典数据。 |

Schemas:

- `data`: Dictionary，包含 unlocked_levels、completed_levels 与 level_results 三个可选字典字段。

## GFLevelUtility

- Path: `addons/gf/extensions/domain/level/gf_level_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFLevelUtility: 关卡流程管理工具。 负责统一关卡数据读取、开始、重开、胜利和失败信号派发。 默认通过 GFConfigProvider 读取静态关卡表，并可在重开关卡时清理 命令历史与外部显式注册的运行时残留。

### Signals

#### `level_started`

- API: `public`

```gdscript
signal level_started(level_id: Variant, level_data: Dictionary)
```

当关卡开始时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `level_data` | 当前关卡数据。 |

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。
- `level_data`: Dictionary，当前关卡数据副本。

#### `level_restarted`

- API: `public`

```gdscript
signal level_restarted(level_id: Variant, level_data: Dictionary)
```

当关卡重开时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `level_data` | 当前关卡数据。 |

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。
- `level_data`: Dictionary，当前关卡数据副本。

#### `level_won`

- API: `public`

```gdscript
signal level_won(level_id: Variant)
```

当关卡胜利时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。

#### `level_lost`

- API: `public`

```gdscript
signal level_lost(level_id: Variant)
```

当关卡失败时发出。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。

### Properties

#### `level_table_name`

- API: `public`

```gdscript
var level_table_name: StringName = &"levels"
```

默认关卡配置表名。

#### `current_level_id`

- API: `public`

```gdscript
var current_level_id: Variant = null
```

当前关卡 ID。

Schemas:

- `current_level_id`: Variant，项目传入的当前关卡 ID；未启动关卡时为 null。

#### `current_level_data`

- API: `public`

```gdscript
var current_level_data: Dictionary = {}
```

当前关卡数据副本。

Schemas:

- `current_level_data`: Dictionary，当前关卡数据副本；来源可以是配置表、目录条目或外部覆盖。

#### `catalog`

- API: `public`

```gdscript
var catalog: GFLevelCatalog = null
```

可选关卡目录资源。

#### `fail_on_missing_level_data`

- API: `public`

```gdscript
var fail_on_missing_level_data: bool = false
```

为 true 时，找不到关卡数据会拒绝启动或重开当前关卡。

### Methods

#### `configure`

- API: `public`

```gdscript
func configure(table_name: StringName = &"levels") -> void:
```

配置关卡数据表名。

Parameters:

| Name | Description |
|---|---|
| `table_name` | 用于 GFConfigProvider.get_record() 的表名。 |

#### `set_catalog`

- API: `public`

```gdscript
func set_catalog(level_catalog: GFLevelCatalog) -> void:
```

设置关卡目录资源。

Parameters:

| Name | Description |
|---|---|
| `level_catalog` | 关卡目录。 |

#### `get_catalog`

- API: `public`

```gdscript
func get_catalog() -> GFLevelCatalog:
```

获取关卡目录资源。

Returns: 关卡目录；不存在时返回 null。

#### `get_level_entry`

- API: `public`

```gdscript
func get_level_entry(level_id: StringName) -> GFLevelEntry:
```

获取目录中的关卡条目。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 关卡条目；不存在时返回 null。

#### `get_catalog_levels`

- API: `public`

```gdscript
func get_catalog_levels(pack_id: StringName = &"") -> Array[GFLevelEntry]:
```

获取目录中的关卡列表。

Parameters:

| Name | Description |
|---|---|
| `pack_id` | 可选关卡扩展 ID；为空时返回全部。 |

Returns: 关卡条目数组。

Schemas:

- `return`: Array[GFLevelEntry]，目录返回的已排序关卡条目拷贝。

#### `load_level_data`

- API: `public`

```gdscript
func load_level_data(level_id: Variant) -> Dictionary:
```

读取关卡数据。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 关卡数据副本，找不到时返回空字典。

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。
- `return`: Dictionary，当前关卡数据副本；找不到数据时为空字典。

#### `start_level`

- API: `public`

```gdscript
func start_level(level_id: Variant, level_data_override: Dictionary = {}) -> Dictionary:
```

开始指定关卡。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |
| `level_data_override` | 可选的外部数据覆盖；为空时从配置表读取。 |

Returns: 当前关卡数据副本。

Schemas:

- `level_id`: Variant，项目传入的关卡 ID，通常为 StringName 或 String。
- `level_data_override`: Dictionary，项目提供的关卡数据覆盖；非空时优先使用。
- `return`: Dictionary，启动后的当前关卡数据副本；失败时为空字典。

#### `restart_level`

- API: `public`

```gdscript
func restart_level(clear_runtime: bool = true) -> Dictionary:
```

重开当前关卡，并清理常见运行时队列。

Parameters:

| Name | Description |
|---|---|
| `clear_runtime` | 是否清理命令历史与表现队列。 |

Returns: 当前关卡数据副本。

Schemas:

- `return`: Dictionary，重开后的当前关卡数据副本；失败时为空字典。

#### `win_current_level`

- API: `public`

```gdscript
func win_current_level() -> void:
```

标记当前关卡胜利。

#### `complete_current_level`

- API: `public`

```gdscript
func complete_current_level( result: Dictionary = {}, unlock_next: bool = true, emit_win_signal: bool = true ) -> void:
```

完成当前关卡并可选更新通用进度模型与后续解锁。

Parameters:

| Name | Description |
|---|---|
| `result` | 项目层结果数据。 |
| `unlock_next` | 是否解锁目录中的后续关卡。 |
| `emit_win_signal` | 是否发出 level_won。 |

Schemas:

- `result`: Dictionary，项目自定义关卡完成结果。

#### `lose_current_level`

- API: `public`

```gdscript
func lose_current_level() -> void:
```

标记当前关卡失败。

#### `clear_level_runtime`

- API: `public`

```gdscript
func clear_level_runtime() -> void:
```

清理常见关卡运行时残留。

#### `register_runtime_cleanup`

- API: `public`

```gdscript
func register_runtime_cleanup(cleanup_id: StringName, callback: Callable) -> bool:
```

注册关卡运行时清理回调。

Parameters:

| Name | Description |
|---|---|
| `cleanup_id` | 清理项唯一标识。 |
| `callback` | 无参数清理回调。 |

Returns: 注册成功返回 true。

#### `unregister_runtime_cleanup`

- API: `public`

```gdscript
func unregister_runtime_cleanup(cleanup_id: StringName) -> void:
```

注销关卡运行时清理回调。

Parameters:

| Name | Description |
|---|---|
| `cleanup_id` | 清理项唯一标识。 |

#### `has_runtime_cleanup`

- API: `public`

```gdscript
func has_runtime_cleanup(cleanup_id: StringName) -> bool:
```

检查关卡运行时清理回调是否存在。

Parameters:

| Name | Description |
|---|---|
| `cleanup_id` | 清理项唯一标识。 |

Returns: 存在返回 true。

#### `get_runtime_cleanup_ids`

- API: `public`

```gdscript
func get_runtime_cleanup_ids() -> PackedStringArray:
```

获取已注册清理项标识。

Returns: 排序后的清理项标识。

#### `clear_current_level`

- API: `public`

```gdscript
func clear_current_level() -> void:
```

清除当前关卡记录。

#### `start_next_level`

- API: `public`

```gdscript
func start_next_level() -> Dictionary:
```

启动目录中的下一个关卡。

Returns: 下一个关卡数据；没有后续关卡时返回空字典。

Schemas:

- `return`: Dictionary，下一个关卡数据副本；没有后续关卡时为空字典。

#### `unlock_level`

- API: `public`

```gdscript
func unlock_level(level_id: StringName) -> void:
```

解锁关卡进度。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

#### `is_level_unlocked`

- API: `public`

```gdscript
func is_level_unlocked(level_id: StringName) -> bool:
```

检查关卡是否已解锁。

Parameters:

| Name | Description |
|---|---|
| `level_id` | 关卡 ID。 |

Returns: 已解锁时返回 true；未注册进度模型时返回 true。

## GFQuestUtility

- Path: `addons/gf/extensions/domain/quest/gf_quest_utility.gd`
- Extends: `GFUtility`
- API: `public`
- Category: `runtime_service`
- Since: `3.17.0`

GFQuestUtility: 轻量级任务进度监听系统。 基于 `simple event` 将业务事件映射为任务进度累积， 适合用于成就、收集与击杀类目标的低成本跟踪。

### Signals

#### `quest_started`

- API: `public`

```gdscript
signal quest_started(quest_id: StringName)
```

当任务开始监听时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `quest_available`

- API: `public`

```gdscript
signal quest_available(quest_id: StringName)
```

当任务进入可接取状态时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `quest_acceptance_blocked`

- API: `public`

```gdscript
signal quest_acceptance_blocked(quest_id: StringName, reason: String)
```

当任务接取条件拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `reason` | 拒绝原因。 |

#### `quest_progressed`

- API: `public`

```gdscript
signal quest_progressed(quest_id: StringName, current: int, target: int)
```

当任务进度变化时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `current` | 当前进度。 |
| `target` | 目标进度。 |

#### `quest_completed`

- API: `public`

```gdscript
signal quest_completed(quest_id: StringName)
```

当任务完成时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 完成的任务 ID。 |

#### `quest_completion_blocked`

- API: `public`

```gdscript
signal quest_completion_blocked(quest_id: StringName, reason: String)
```

当任务完成条件被阻塞器拒绝时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `reason` | 阻塞原因。 |

#### `quest_cancelled`

- API: `public`

```gdscript
signal quest_cancelled(quest_id: StringName)
```

当任务取消时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `quest_failed`

- API: `public`

```gdscript
signal quest_failed(quest_id: StringName)
```

当任务失败时发出。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

### Constants

#### `STATUS_AVAILABLE`

- API: `public`

```gdscript
const STATUS_AVAILABLE: StringName = &"available"
```

任务已定义、可接取但尚未开始监听。

#### `STATUS_ACTIVE`

- API: `public`

```gdscript
const STATUS_ACTIVE: StringName = &"active"
```

任务正在监听事件并累计进度。

#### `STATUS_COMPLETED`

- API: `public`

```gdscript
const STATUS_COMPLETED: StringName = &"completed"
```

任务已完成。

#### `STATUS_CANCELLED`

- API: `public`

```gdscript
const STATUS_CANCELLED: StringName = &"cancelled"
```

任务已取消。

#### `STATUS_FAILED`

- API: `public`

```gdscript
const STATUS_FAILED: StringName = &"failed"
```

任务已失败。

### Properties

#### `allow_negative_progress`

- API: `public`

```gdscript
var allow_negative_progress: bool = false
```

是否允许事件传入负数进度。默认关闭，避免任务进度被异常 payload 反向扣减。

### Methods

#### `start_quest`

- API: `public`

```gdscript
func start_quest(quest_id: StringName, target_event: StringName, target_count: int = 1) -> void:
```

开始监听一个任务。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `target_event` | 推进该任务的事件 ID。 |
| `target_count` | 完成任务所需的累计次数。 |

#### `define_quest`

- API: `public`

```gdscript
func define_quest( quest_id: StringName, target_event: StringName, target_count: int = 1, metadata: Dictionary = {} ) -> void:
```

定义一个可接取任务，但暂不开始监听事件。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `target_event` | 推进该任务的事件 ID。 |
| `target_count` | 完成任务所需的累计次数。 |
| `metadata` | 任务元数据。框架不解释该字段。 |

Schemas:

- `metadata`: Dictionary，项目自定义任务元数据；GF 会复制保存并在任务报告中透传。

#### `accept_quest`

- API: `public`

```gdscript
func accept_quest(quest_id: StringName) -> bool:
```

接取一个已定义任务，并开始监听事件。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 接取成功返回 true。

#### `complete_quest`

- API: `public`

```gdscript
func complete_quest(quest_id: StringName) -> bool:
```

手动完成一个任务。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 完成成功返回 true。

#### `cancel_quest`

- API: `public`

```gdscript
func cancel_quest(quest_id: StringName) -> bool:
```

取消一个任务。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 取消成功返回 true。

#### `fail_quest`

- API: `public`

```gdscript
func fail_quest(quest_id: StringName, reason: String = "") -> bool:
```

标记任务失败。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `reason` | 可选失败原因，会写入任务 metadata 的 last_failure_reason。 |

Returns: 标记成功返回 true。

#### `add_acceptance_condition`

- API: `public`

```gdscript
func add_acceptance_condition(quest_id: StringName, condition: Callable) -> void:
```

添加接取条件。条件返回 false 或包含 ok=false 的 Dictionary 时阻止接取。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `condition` | 条件回调。 |

#### `clear_acceptance_conditions`

- API: `public`

```gdscript
func clear_acceptance_conditions(quest_id: StringName) -> void:
```

清空任务接取条件。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `add_completion_blocker`

- API: `public`

```gdscript
func add_completion_blocker(quest_id: StringName, blocker: Callable) -> void:
```

添加完成阻塞器。阻塞器返回 false 或包含 ok=false 的 Dictionary 时阻止完成。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |
| `blocker` | 阻塞器回调。 |

#### `clear_completion_blockers`

- API: `public`

```gdscript
func clear_completion_blockers(quest_id: StringName) -> void:
```

清空任务完成阻塞器。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `set_quest_parent`

- API: `public`

```gdscript
func set_quest_parent(quest_id: StringName, parent_quest_id: StringName) -> bool:
```

设置任务父级关系。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 子任务 ID。 |
| `parent_quest_id` | 父任务 ID。 |

Returns: 设置成功返回 true。

#### `clear_quest_parent`

- API: `public`

```gdscript
func clear_quest_parent(quest_id: StringName) -> void:
```

清除任务父级关系。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

#### `get_child_quests`

- API: `public`

```gdscript
func get_child_quests(quest_id: StringName) -> PackedStringArray:
```

获取任务的直接子任务 ID。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 子任务 ID 列表。

#### `get_quest_tree_report`

- API: `public`

```gdscript
func get_quest_tree_report(root_quest_id: StringName) -> Dictionary:
```

获取任务树报告。

Parameters:

| Name | Description |
|---|---|
| `root_quest_id` | 根任务 ID。 |

Returns: 树形报告；任务不存在时返回空字典。

Schemas:

- `return`: Dictionary，包含任务报告字段、children: Array[Dictionary]、total_count、completed_count 与 aggregate_progress。

#### `emit_quest_event`

- API: `public`

```gdscript
func emit_quest_event(event_id: StringName, amount: int = 1) -> void:
```

手动触发一次任务事件。

Parameters:

| Name | Description |
|---|---|
| `event_id` | 事件 ID。 |
| `amount` | 本次增加的进度值。 |

#### `is_quest_completed`

- API: `public`

```gdscript
func is_quest_completed(quest_id: StringName) -> bool:
```

查询任务是否已经完成。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 已完成时返回 true。

#### `get_quest_progress`

- API: `public`

```gdscript
func get_quest_progress(quest_id: StringName) -> float:
```

获取任务进度百分比。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 范围在 0.0 到 1.0 之间的进度值。

#### `get_quest_status`

- API: `public`

```gdscript
func get_quest_status(quest_id: StringName) -> StringName:
```

获取任务状态。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 状态文本。

#### `get_quests_by_status`

- API: `public`

```gdscript
func get_quests_by_status(status: StringName) -> PackedStringArray:
```

获取指定状态的任务 ID。

Parameters:

| Name | Description |
|---|---|
| `status` | 任务状态。 |

Returns: 任务 ID 列表。

#### `get_quest_report`

- API: `public`

```gdscript
func get_quest_report(quest_id: StringName) -> Dictionary:
```

获取任务报告。

Parameters:

| Name | Description |
|---|---|
| `quest_id` | 任务 ID。 |

Returns: 任务报告字典。

Schemas:

- `return`: Dictionary，包含 quest_id、event_id、target_count、current_count、is_completed、status、parent_id、child_ids、metadata、acceptance_condition_count 与 completion_blocker_count。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取任务系统调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含 quest_count、event_count 与 quests；quests 键为 String 任务 ID，值为任务报告字典。

## GFSlotInventoryModel

- Path: `addons/gf/extensions/domain/inventory/gf_slot_inventory_model.gd`
- Extends: `GFModel`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFSlotInventoryModel: 通用可序列化槽位库存模型。 管理固定或可增长槽位中的 `GFInventoryStack`，支持槽位接收规则、 堆叠容量、最大堆叠数量、实例数据兼容性、移动、交换和序列化。

### Signals

#### `slot_changed`

- API: `public`

```gdscript
signal slot_changed(slot_index: int)
```

任意槽位变化时发出。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 变化的槽位索引。 |

#### `slot_state_changed`

- API: `public`

```gdscript
signal slot_state_changed(slot_index: int, before_stack_data: Dictionary, after_stack_data: Dictionary)
```

槽位内容变化时发出，并携带变化前后的稳定快照。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 变化的槽位索引。 |
| `before_stack_data` | 变化前的槽位堆叠字典；空槽为 `{}`。 |
| `after_stack_data` | 变化后的槽位堆叠字典；空槽为 `{}`。 |

Schemas:

- `before_stack_data`: Dictionary，GFInventoryStack.to_dict() 形状的槽位快照；空槽为空字典。
- `after_stack_data`: Dictionary，GFInventoryStack.to_dict() 形状的槽位快照；空槽为空字典。

#### `slot_filled`

- API: `public`

```gdscript
signal slot_filled(slot_index: int, stack_data: Dictionary)
```

槽位从空变为有内容时发出。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 变化的槽位索引。 |
| `stack_data` | 新写入的槽位堆叠字典。 |

Schemas:

- `stack_data`: Dictionary，GFInventoryStack.to_dict() 形状的新堆叠快照。

#### `slot_emptied`

- API: `public`

```gdscript
signal slot_emptied(slot_index: int, previous_stack_data: Dictionary)
```

槽位从有内容变为空时发出。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 变化的槽位索引。 |
| `previous_stack_data` | 清空前的槽位堆叠字典。 |

Schemas:

- `previous_stack_data`: Dictionary，GFInventoryStack.to_dict() 形状的清空前堆叠快照。

#### `item_added`

- API: `public`

```gdscript
signal item_added(slot_index: int, item_id: StringName, amount: int)
```

物品加入槽位后发出。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 物品加入的槽位索引。 |
| `item_id` | 加入的物品 ID。 |
| `amount` | 实际加入数量。 |

#### `item_removed`

- API: `public`

```gdscript
signal item_removed(slot_index: int, item_id: StringName, amount: int)
```

物品从槽位移除后发出。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 物品移除的槽位索引。 |
| `item_id` | 移除的物品 ID。 |
| `amount` | 实际移除数量。 |

#### `inventory_changed`

- API: `public`

```gdscript
signal inventory_changed
```

库存整体发生变化时发出。

### Properties

#### `registry`

- API: `public`

```gdscript
var registry: GFInventoryItemRegistry = null
```

可选物品定义注册表。

#### `slot_definitions`

- API: `public`

```gdscript
var slot_definitions: Array[GFInventorySlotDefinition] = []
```

可选槽位定义。索引与库存槽位一致；空项表示该槽位不添加额外接收限制。

Schemas:

- `slot_definitions`: Array[GFInventorySlotDefinition]，按槽位索引存放的接收规则；空项表示不限制。

#### `allow_growth`

- API: `public`

```gdscript
var allow_growth: bool = false
```

是否允许库存在创建新堆叠时自动增长。 为 false 时，0 槽位库存不会接收 `add_item()` 的新堆叠。

#### `default_slot_count`

- API: `public`

```gdscript
var default_slot_count: int = 0
```

默认初始槽位数量。仅在 GF 生命周期调用 `init()` 时自动应用。 手动创建后直接使用时，应调用 `set_slot_count()` 或启用 `allow_growth`。

### Methods

#### `set_registry`

- API: `public`

```gdscript
func set_registry(item_registry: GFInventoryItemRegistry) -> void:
```

设置物品注册表。

Parameters:

| Name | Description |
|---|---|
| `item_registry` | 物品注册表。 |

#### `set_slot_count`

- API: `public`

```gdscript
func set_slot_count(count: int, preserve_existing: bool = true) -> void:
```

设置槽位数量。

Parameters:

| Name | Description |
|---|---|
| `count` | 新槽位数量。 |
| `preserve_existing` | 是否保留已有槽位内容。 |

#### `get_slot_count`

- API: `public`

```gdscript
func get_slot_count() -> int:
```

获取槽位数量。

Returns: 槽位数量。

#### `is_valid_slot`

- API: `public`

```gdscript
func is_valid_slot(slot_index: int) -> bool:
```

检查槽位索引是否有效。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 有效返回 true。

#### `set_slot_definition`

- API: `public`

```gdscript
func set_slot_definition(slot_index: int, definition: GFInventorySlotDefinition) -> bool:
```

设置槽位定义。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |
| `definition` | 槽位定义；传 null 表示清除该槽位额外规则。 |

Returns: 成功返回 true。

#### `get_slot_definition`

- API: `public`

```gdscript
func get_slot_definition(slot_index: int) -> GFInventorySlotDefinition:
```

获取槽位定义。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 槽位定义；无额外规则或无效槽位返回 null。

#### `can_accept_item_at_slot`

- API: `public`

```gdscript
func can_accept_item_at_slot( slot_index: int, item_id: StringName, instance_data: Dictionary = {} ) -> bool:
```

检查指定物品是否可被槽位接收。 该方法只检查全局注册表与槽位定义，不判断当前槽位是否为空、 是否可与已有堆叠合并或是否有剩余容量。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |
| `item_id` | 物品标识。 |
| `instance_data` | 实例数据。 |

Returns: 槽位可接收该物品时返回 true。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；会先经注册表规范化。

#### `get_stack`

- API: `public`

```gdscript
func get_stack(slot_index: int) -> GFInventoryStack:
```

获取槽位堆叠副本。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 堆叠副本；空槽或无效槽位返回 null。

#### `get_stack_data`

- API: `public`

```gdscript
func get_stack_data(slot_index: int) -> Dictionary:
```

获取槽位堆叠字典。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 堆叠字典；空槽或无效槽位返回空字典。

Schemas:

- `return`: Dictionary，GFInventoryStack.to_dict() 形状的槽位快照；空槽或无效槽位为空字典。

#### `is_slot_empty`

- API: `public`

```gdscript
func is_slot_empty(slot_index: int) -> bool:
```

检查槽位是否为空。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 空槽位返回 true。

#### `set_stack`

- API: `public`

```gdscript
func set_stack(slot_index: int, stack: GFInventoryStack) -> bool:
```

设置指定槽位堆叠。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |
| `stack` | 堆叠；传 null 表示清空。 |

Returns: 成功返回 true。

#### `clear_slot`

- API: `public`

```gdscript
func clear_slot(slot_index: int) -> bool:
```

清空指定槽位。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |

Returns: 成功返回 true。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空全部槽位内容。

#### `add_item`

- API: `public`

```gdscript
func add_item( item_id: StringName, amount: int = 1, instance_data: Dictionary = {}, start_slot: int = -1, partial_add: bool = true ) -> GFInventoryOperationResult:
```

添加物品到库存。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `amount` | 添加数量。 |
| `instance_data` | 实例数据。 |
| `start_slot` | 起始槽位；小于 0 时从头开始。 |
| `partial_add` | 容量不足时是否允许部分加入。 |

Returns: 操作结果。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；会先经注册表规范化。

#### `add_item_to_slot`

- API: `public`

```gdscript
func add_item_to_slot( slot_index: int, item_id: StringName, amount: int = 1, instance_data: Dictionary = {} ) -> GFInventoryOperationResult:
```

添加物品到指定槽位。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |
| `item_id` | 物品标识。 |
| `amount` | 添加数量。 |
| `instance_data` | 实例数据。 |

Returns: 操作结果。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；会先经注册表规范化。

#### `remove_item`

- API: `public`

```gdscript
func remove_item( item_id: StringName, amount: int = 1, instance_data: Dictionary = {}, start_slot: int = -1, partial_remove: bool = true ) -> GFInventoryOperationResult:
```

从库存移除物品。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `amount` | 移除数量。 |
| `instance_data` | 实例数据。 |
| `start_slot` | 起始槽位；小于 0 时从头开始。 |
| `partial_remove` | 数量不足时是否允许部分移除。 |

Returns: 操作结果。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；为空时匹配全部同 ID 物品。

#### `remove_item_from_slot`

- API: `public`

```gdscript
func remove_item_from_slot(slot_index: int, amount: int = 1) -> GFInventoryOperationResult:
```

从指定槽位移除物品。

Parameters:

| Name | Description |
|---|---|
| `slot_index` | 槽位索引。 |
| `amount` | 移除数量。 |

Returns: 操作结果。

#### `swap_slots`

- API: `public`

```gdscript
func swap_slots(first_slot: int, second_slot: int) -> bool:
```

交换两个槽位内容。

Parameters:

| Name | Description |
|---|---|
| `first_slot` | 第一个槽位。 |
| `second_slot` | 第二个槽位。 |

Returns: 成功返回 true。

#### `sort_slots`

- API: `public`

```gdscript
func sort_slots(order_resolver: Callable = Callable()) -> bool:
```

按排序规则重排槽位内容。 默认排序把非空槽位排在前面，再按 item_id 和原槽位索引稳定排序。 可传入回调覆盖本次排序，或继承并重写 `_should_sort_slot_before()`。

Parameters:

| Name | Description |
|---|---|
| `order_resolver` | 可选比较回调，签名为 `func(left_slot_index, left_stack_data, right_slot_index, right_stack_data) -> bool`。 |

Returns: 槽位顺序发生变化时返回 true。

#### `move_between_slots`

- API: `public`

```gdscript
func move_between_slots(source_slot: int, target_slot: int, amount: int = 0) -> GFInventoryOperationResult:
```

移动一个槽位的内容到另一个槽位，目标为空时移动，兼容时合并。

Parameters:

| Name | Description |
|---|---|
| `source_slot` | 源槽位。 |
| `target_slot` | 目标槽位。 |
| `amount` | 移动数量；小于等于 0 时移动全部。 |

Returns: 操作结果。

#### `get_item_total`

- API: `public`

```gdscript
func get_item_total(item_id: StringName, instance_data: Dictionary = {}) -> int:
```

获取指定物品总数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `instance_data` | 实例数据。为空时统计全部同 ID 物品。 |

Returns: 总数量。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；为空时统计全部同 ID 物品。

#### `has_item`

- API: `public`

```gdscript
func has_item(item_id: StringName, amount: int = 1, instance_data: Dictionary = {}) -> bool:
```

检查是否拥有足够数量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `amount` | 需要数量。 |
| `instance_data` | 实例数据。 |

Returns: 数量足够返回 true。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；为空时统计全部同 ID 物品。

#### `get_remaining_capacity_for_item`

- API: `public`

```gdscript
func get_remaining_capacity_for_item(item_id: StringName, instance_data: Dictionary = {}) -> int:
```

获取指定物品剩余可加入容量。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `instance_data` | 实例数据。 |

Returns: 剩余容量。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；用于筛选可合并堆叠。

#### `get_empty_slot_indices`

- API: `public`

```gdscript
func get_empty_slot_indices() -> PackedInt32Array:
```

获取空槽位索引。

Returns: 空槽位索引数组。

#### `get_occupied_slot_indices`

- API: `public`

```gdscript
func get_occupied_slot_indices() -> PackedInt32Array:
```

获取已占用槽位索引。

Returns: 已占用槽位索引数组。

#### `get_slots_for_item`

- API: `public`

```gdscript
func get_slots_for_item(item_id: StringName, instance_data: Dictionary = {}) -> PackedInt32Array:
```

获取指定物品所在槽位索引。

Parameters:

| Name | Description |
|---|---|
| `item_id` | 物品标识。 |
| `instance_data` | 实例数据。为空时返回全部同 ID 槽位。 |

Returns: 槽位索引列表。

Schemas:

- `instance_data`: Dictionary，项目自定义物品实例数据；为空时返回全部同 ID 槽位。

#### `rebuild_index`

- API: `public`

```gdscript
func rebuild_index() -> void:
```

立即重建物品到槽位的索引。

#### `get_index_debug_snapshot`

- API: `public`

```gdscript
func get_index_debug_snapshot() -> Dictionary:
```

获取索引调试快照。

Returns: 索引快照字典。

Schemas:

- `return`: Dictionary，包含 dirty: bool、item_count: int、stack_count_by_item: Dictionary 与 slot_indices_by_item: Dictionary。

#### `validate_inventory`

- API: `public`

```gdscript
func validate_inventory() -> Dictionary:
```

校验当前库存内容是否满足注册表约束。

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，包含 ok、healthy、summary、next_action、issue_count 与 issues；issues 每项包含 severity、kind、slot_index、item_id 与 message。

#### `apply_registry_constraints`

- API: `public`

```gdscript
func apply_registry_constraints(repair: bool = false) -> Dictionary:
```

应用注册表约束并返回报告。

Parameters:

| Name | Description |
|---|---|
| `repair` | 为 true 时会移除不合法堆叠并裁剪超过上限的数量。 |

Returns: 校验报告字典。

Schemas:

- `return`: Dictionary，包含 ok、healthy、summary、next_action、issue_count 与 issues；repair 为 true 时会同步修复可修复堆叠。

#### `get_debug_snapshot`

- API: `public`

```gdscript
func get_debug_snapshot() -> Dictionary:
```

获取库存调试快照。

Returns: 调试快照字典。

Schemas:

- `return`: Dictionary，包含 slot_count、occupied_slot_count、empty_slot_count、allow_growth、items 与 index。

#### `to_dict`

- API: `public`

```gdscript
func to_dict() -> Dictionary:
```

序列化为字典。

Returns: 可序列化字典。

Schemas:

- `return`: Dictionary，包含 slot_count、allow_growth 与 slots；slots 每项为 GFInventoryStack.to_dict() 形状或空字典。

#### `from_dict`

- API: `public`

```gdscript
func from_dict(data: Dictionary) -> void:
```

从字典恢复。

Parameters:

| Name | Description |
|---|---|
| `data` | 序列化数据。 |

Schemas:

- `data`: Dictionary，包含 slot_count、allow_growth 与 slots；slots 每项为 GFInventoryStack.to_dict() 形状或空字典。

## GFTrait

- Path: `addons/gf/extensions/domain/traits/gf_trait.gd`
- Extends: `Resource`
- API: `public`
- Category: `resource_definition`
- Since: `3.17.0`

GFTrait: 通用被动特征数据。 用于描述“某个来源对某个目标键产生的数值或标记影响”。 它不限定属性、伤害、装备等业务语义。

### Enums

#### `CombineMode`

- API: `public`

```gdscript
enum CombineMode { ## 与当前值相加。 ADD,  ## 与当前值相乘。 MULTIPLY,  ## 直接覆盖当前值。 SET,  ## 取当前值与特征值中的较大值。 MAX,  ## 取当前值与特征值中的较小值。 MIN, }
```

数值合并方式。

### Properties

#### `trait_id`

- API: `public`

```gdscript
var trait_id: StringName = &""
```

特征标识。

#### `target_id`

- API: `public`

```gdscript
var target_id: StringName = &""
```

目标键，例如属性名、规则名或项目自定义键。

#### `category`

- API: `public`

```gdscript
var category: StringName = &""
```

可选分类，用于过滤不同规则域。

#### `value`

- API: `public`

```gdscript
var value: float = 0.0
```

数值。

#### `combine_mode`

- API: `public`

```gdscript
var combine_mode: CombineMode = CombineMode.ADD
```

合并方式。

#### `priority`

- API: `public`

```gdscript
var priority: int = 0
```

排序优先级，值越小越先应用。

#### `metadata`

- API: `public`

```gdscript
var metadata: Dictionary = {}
```

自定义元数据。

Schemas:

- `metadata`: Dictionary，项目自定义特征元数据；GF 不读取或改写其中字段。

### Methods

#### `apply_number`

- API: `public`

```gdscript
func apply_number(current_value: float) -> float:
```

将当前特征应用到数值上。

Parameters:

| Name | Description |
|---|---|
| `current_value` | 当前值。 |

Returns: 应用后的值。

## GFTraitSet

- Path: `addons/gf/extensions/domain/traits/gf_trait_set.gd`
- Extends: `Resource`
- API: `public`
- Category: `domain_model`
- Since: `3.17.0`

GFTraitSet: 通用特征集合。 可从任意来源收集 `GFTrait`，再按目标键与分类计算最终数值。

### Properties

#### `traits`

- API: `public`

```gdscript
var traits: Array[GFTrait] = []
```

特征列表。

Schemas:

- `traits`: Array[GFTrait]，按 priority 排序保存的特征资源列表。

### Methods

#### `add_trait`

- API: `public`

```gdscript
func add_trait(p_trait: GFTrait) -> void:
```

添加一个特征。

Parameters:

| Name | Description |
|---|---|
| `p_trait` | 特征资源。 |

#### `remove_traits_by_id`

- API: `public`

```gdscript
func remove_traits_by_id(trait_id: StringName) -> void:
```

按 ID 移除特征。

Parameters:

| Name | Description |
|---|---|
| `trait_id` | 特征 ID。 |

#### `get_traits`

- API: `public`

```gdscript
func get_traits(target_id: StringName, category: StringName = &"") -> Array[GFTrait]:
```

查询匹配的特征。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标键。 |
| `category` | 可选分类；为空时不按分类过滤。 |

Returns: 匹配特征数组。

Schemas:

- `return`: Array[GFTrait]，匹配目标键和分类过滤条件的特征资源。

#### `calculate_number`

- API: `public`

```gdscript
func calculate_number(target_id: StringName, base_value: float, category: StringName = &"") -> float:
```

计算目标键的最终数值。

Parameters:

| Name | Description |
|---|---|
| `target_id` | 目标键。 |
| `base_value` | 基础值。 |
| `category` | 可选分类。 |

Returns: 合并后的数值。

#### `clear`

- API: `public`

```gdscript
func clear() -> void:
```

清空特征。

