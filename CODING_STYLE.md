# Godot GDScript 编码风格指南

本指南旨在为项目提供一套统一、清晰的GDScript编码规范。遵循这些规范有助于提升代码的可读性、可维护性，并促进团队成员间的协作效率。

本文档中的规则主要基于项目现有代码的优秀实践和Godot官方文档的通用约定。

## 目录
1.  [命名规范](#1-命名规范)
2.  [代码布局与顺序](#2-代码布局与顺序)
3.  [注释风格](#3-注释风格)
4.  [类型提示](#4-类型提示)
5.  [格式与最佳实践](#5-格式与最佳实践)
6.  [文件格式与编码](#6-文件格式与编码)

---

## 1. 命名规范

清晰的命名是代码自解释能力的基础。

### 1.1 文件命名
*   **GDScript脚本**: 使用蛇形命名法 (`snake_case`)。这与Godot引擎源码风格一致，并能避免在跨平台（特别是大小写敏感的系统）时出现问题。
	*   示例: `game_board.gd`, `main_menu.gd`, `classic_interaction_rule.gd`
*   **场景文件**: 使用蛇形命名法 (`snake_case`)。
	*   示例: `game_play.tscn`, `mode_selection.tscn`

### 1.2 类与节点命名
*   **`class_name`**: 使用大驼峰命名法 (`PascalCase`)。
	*   示例: `class_name GameBoard`, `class_name StateMachine`
*   **场景树中的节点**: 使用大驼峰命名法 (`PascalCase`)。如果一个节点在脚本中会被频繁引用（通过 `%` 唯一名称获取），其名称应清晰表达其用途。
	*   示例: `GameBoard`, `ModeListContainer`, `StartGameButton`

### 1.3 函数与方法命名
*   **公共方法**: 使用蛇形命名法 (`snake_case`)。名称应为动词或动宾短语，清晰描述其功能。
	*   示例: `initialize_board()`, `get_state_snapshot()`, `update_display()`
*   **私有/内部方法**: 遵循蛇形命名法，并以一个下划线 `_` 开头。
	*   示例: `_update_board_layout()`, `_process_line()`
*   **Godot内置虚方法**: 遵循Godot的命名，例如 `_ready()`, `_process()`。
*   **信号回调函数**: 推荐使用 `_on_NodeName_signal_name` 的格式，这是Godot编辑器自动连接信号时生成的默认格式，非常直观。
	*   示例: `_on_start_game_button_pressed()`, `_on_hud_message_timer_timeout()`

### 1.4 变量与属性命名
*   **公共变量/属性**: 使用蛇形命名法 (`snake_case`)。
	*   示例: `var grid_size: int = 4`, `var move_count: int = 0`
*   **私有/内部变量**: 遵循蛇形命名法，并以一个下划线 `_` 开头。
	*   示例: `var _current_replay_data`, `var _game_state_history`
*   **常量 (`const`)**: 使用全大写蛇形命名法 (`CONSTANT_CASE`)。
	*   示例: `const CELL_SIZE: int = 100`, `const MAIN_MENU_SCENE_PATH = "..."`
*   **枚举 (`enum`)**: 枚举名使用大驼峰 (`PascalCase`)，其成员使用全大写 (`CONSTANT_CASE`)，每个成员占一行。
	*   示例:
		```gdscript
		enum State {
			READY,
			PLAYING,
			GAME_OVER,
		}
		```

### 1.5 信号命名
*   信号名称使用过去时态，描述已经发生的事件。
	*   示例: `signal score_changed`, `signal door_opened`

---

## 2. 代码布局与顺序

一个结构清晰的脚本文件能让人快速定位信息。脚本内的内容应遵循以下顺序组织：

1.  **文件路径注释**(例如 **`# global/bookmark_manager.gd`**)
2.  **脚本元注解**: `@tool`, `@icon` 等。(与上一条之间不需要空行)
3.  **文件级文档注释**: `##` 注释，说明该类的核心职责。(与上一条之间需要空行，如果没有第二条，仍然需要和第一条保持一个空行)
4.  **`class_name`**
5.  **`extends`**
6.  **`signal` 声明**
7.  **`enum` 定义**
8.  **`const` 定义**
9.  **`@export` 变量** (按 `@export_group` 分组)
10.  **公共变量**
11.  **私有变量** (以下划线 `_` 开头)
12.  **`@onready var` 变量** (节点引用)
13.  **Godot内置虚方法 (Lifecycle & Callbacks)**: 按逻辑执行顺序排列。
	 *   `_init()`
	 *   `_enter_tree()`
	 *   `_ready()`
	 *   `_unhandled_input()` / `_input()`
	 *   `_process()`
	 *   `_physics_process()`
	 *   `_exit_tree()`
	 *   ...等等
14.  **公共方法**
15.  **私有/辅助方法** (以下划线 `_` 开头)
16.  **信号回调函数** (例如 `_on_*`)
17.  **内部类 (Subclasses)**

**空行使用规则**:

*   **节与节之间**: 在不同的代码节（例如 `signal` 节和 `enum` 节，或变量区和函数区）之间，使用**一个**空行。推荐使用[节注释](#35-节注释-section-comments)来标记节的开始。
*   **节内部成员的空行**:
	*   任何带有文档注释 (`##`) 的成员（信号、变量、常量等），其完整的声明块（注释 + 声明）之后**必须**跟一个空行。这确保了每个有文档的成员都是一个清晰的视觉单元。
	*   连续的、**没有**文档注释的单行成员之间**不应**有空行，以保持内部或简单变量的紧凑性。
*   **函数之间**: 在函数、枚举、内部类定义之间使用**两个**空行，以提供清晰的视觉分隔。
*   **函数内部**: 在函数内部，使用**一个**空行来分隔不同的逻辑块。

---

## 3. 注释风格

注释的目的是解释**“为什么”**，而不是“是什么”。代码本身应该清晰地说明它在“做什么”。我们鼓励为所有非私有的类成员编写文档注释，以增强代码的自解释性。

### 3.1 文件级注释
*   每个脚本文件的顶部都应该有一个文档注释 (`##`)，简要说明该类的用途和核心职责。

	```gdscript
	## StateMachine: 一个通用的有限状态机 (FSM) 节点。
	##
	## 该节点被设计为任何需要状态管理逻辑的父节点的子节点...
	```

### 3.2 成员文档注释
*   所有公共的类成员（信号、枚举、常量、变量、函数等）都应该使用文档注释 (`##`) 来说明其用途。这有助于在Godot编辑器中获得悬停提示，并能自动生成文档。

*   **信号 (Signal)**
	```gdscript
	## 当状态成功切换后发出。
	## @param new_state_name: 进入的新状态的名称。
	signal state_changed(new_state_name)
	```

*   **枚举 (Enum) 与其成员**
	```gdscript
	## 定义了 GamePlay 的核心状态。
	enum State {
		## 游戏已初始化，等待开始
		READY,
		## 游戏正在进行中
		PLAYING,
		## 游戏已结束
		GAME_OVER,
	}
	```

*   **常量 (Constant)**
	```gdscript
	## 每个单元格的像素尺寸。
	const CELL_SIZE: int = 100
	```

*   **变量 (Variable)**
	```gdscript
	## 棋盘的尺寸（例如 4x4 中的 4）。
	@export var grid_size: int = 4

	## 存储棋盘上所有方块节点的二维数组引用。'null'代表空格。
	var grid = []
	```

*   **函数 (Function)**
	对于复杂的公共函数，可以使用文档注释来说明其功能、参数 (`@param`) 和返回值 (`@return`)。
	```gdscript
	## 切换到新状态。这是控制状态机的核心函数。
	## @param new_state_name: 要切换到的新状态的名称。
	## @param message: 一个可选的字典，用于在状态间传递数据。
	func set_state(new_state_name, message: Dictionary = {}) -> void:
		# ...
	```

### 3.3 行内注释 (函数内部)
*   **非必要不添加**: 函数内部应追求**代码即文档**。如果一段代码的逻辑可以通过良好的变量命名和结构清晰表达，则严禁添加注释。
*   **简洁至上**: 如果必须添加注释，注释内容越简洁越好，直击要害。
*   **仅解释“为什么”**: 注释应仅用于解释复杂的算法、反直觉的业务逻辑判断、魔法数字的来源或由于外部限制而采取的变通方案。
*   **禁止翻译代码**: 严禁出现“这行代码是用来赋值的”、“这里开始循环”等解释代码本身行为的废话注释。

### 3.4 注释间距
*   **说明性注释**: 井号 `#` 或 `##` 后应跟一个空格，以区分代码。
	*   `# 这是一个说明。`
	*   `## 这是一个文档注释。`
*   **被注释掉的代码**: 井号 `#` 与代码之间不留空格。这可以快速识别出哪些是临时禁用的代码。
	*   `#print("debug message")`

### 3.5 节注释 (Section Comments)

* **用途**: 为了严格遵循[代码布局与顺序](#2-代码布局与顺序)中定义的结构，我们使用节注释来创建视觉分隔，这极大地提高了代码的可扫描性和导航速度。

*   **规范**:
	*   节注释是**强制性**的，用于分隔代码布局顺序中的不同部分。
	*   统一使用格式：`# --- Section Name ---`
	*   每个节注释之后，必须紧跟一个空行，然后再开始该节的代码。
	*   即使某个节为空，也建议保留其注释（或省略），以维持结构的统一性。

*   **示例 (标准模板)**:

	```gdscript
	# 路径/到/你的/脚本.gd
	@tool

	## 简要说明该类的作用及其核心职责。
	##
	## 如果需要，可以有更详细的说明。
	class_name GamePlay
	extends Control

	# --- 信号 ---
	signal game_started
	signal score_updated(new_score)

	# --- 枚举 ---
	enum State {
		## 准备阶段
		READY,
		## 游戏进行中
		PLAYING,
		## 游戏结束
		GAME_OVER,
	}

	# --- 常量 ---
	const MAX_PLAYERS: int = 4

	# --- 导出变量 ---
	@export_group("游戏设置")
	@export var speed: float = 100.0
	@export var gravity: float = 9.8

	# --- 公共变量 ---
	var current_level: int = 1

	# --- 私有变量 ---
	var _score: int = 0
	var _time_elapsed: float = 0.0

	# --- @onready 变量 (节点引用) ---
	@onready var _game_board: Control = %GameBoard
	@onready var _hud: VBoxContainer = %HUD


	# --- Godot 生命周期方法 ---

	func _ready() -> void:
		# ...


	func _process(delta: float) -> void:
		# ...


	# --- 公共方法 ---

	func start_game() -> void:
		# ...


	# --- 私有/辅助方法 ---

	func _update_score(amount: int) -> void:
		# ...


	# --- 信号处理函数 ---

	func _on_player_died() -> void:
		# ...

	```

### 3.6 严禁修改记录 (No Changelogs)
*   **相信版本控制**: 代码文件中**严禁**出现任何形式的手动修改记录、变更日志或作者署名。
*   **禁止项示例**:
	*   `# [核心修复] `
	*   `# Modified: Fixed the crash bug`
	*   `# EDIT: Changed logic below`
*   **正确做法**: 文件的变更历史、具体修改内容和责任人应完全依赖版本控制系统（Git）的 `Commit Message` 和 `Blame` 功能进行追溯。代码库应只反映当前的最新状态。

---

## 4. 类型提示

本项目强制要求使用静态类型提示，以提高代码的健壮性和可读性，并利用Godot 4的类型检查功能。

### 4.1 基本用法
*   **变量**: `var my_variable: Type = value`
*   **函数参数**: `func my_function(param: Type):`
*   **函数返回值**: `func my_function() -> ReturnType:` (无返回值时用 `-> void:`)

### 4.2 类型推断 (`:=`)
*   **何时使用**: 当赋值运算符右侧的类型非常明确时（例如调用构造函数、字面量），使用 `:=` 来让编译器自动推断类型，避免冗余。
	```gdscript
	var direction := Vector3.UP
	var state_machine := StateMachine.new()
	```
*   **何时避免**: 当类型不明确或可能存在歧义时，必须使用显式类型声明。最常见的场景是 `get_node()`。
	```gdscript
	# 推荐 - 类型明确
	@onready var health_bar: ProgressBar = %HealthBar

	# 不推荐 - 类型被推断为基类 Node，丢失了 ProgressBar 的特定方法和属性
	@onready var health_bar := %HealthBar
	```
*   **类型转换**: 可以使用 `as` 关键字来辅助类型推断。
	```gdscript
	@onready var health_bar := get_node("UI/HealthBar") as ProgressBar
	```

---

## 5. 格式与最佳实践

保持一致的格式可以减少阅读时的认知负荷。

### 5.1 空格
*   在二元操作符 (`=`, `+`, `==`, `>`) 两侧加空格。
*   在逗号 `,` 后面加空格。
*   在类型提示的冒号 `:` 后面加空格。
*   不要在函数名和左括号 `(` 之间加空格。
*   在单行字典的 `{}` 内部两侧添加空格，以和数组的 `[]` 区分。
	*   `var dict = { "key": "value" }`
	*   `var array = [1, 2, 3]`

### 5.2 行尾逗号
*   在多行书写的数组、字典和枚举的最后一个元素后面，总是加上一个逗号。这会让版本控制的差异对比（diff）更清晰，且添加新元素更方便。
	```gdscript
	var my_array = [
		"one",
		"two",
		"three", # <-- 这个逗号很重要
	]
	```

### 5.3 多行语句
*   对于过长的表达式（如复杂的`if`条件），推荐使用圆括号 `()` 将其括起来换行，而不是使用反斜杠 `\`。
*   换行时，逻辑运算符 `and` 或 `or` 应放在下一行的开头，并增加一级缩进。
	```gdscript
	if (long_variable_name_a > 10
		and long_variable_name_b < 20
	):
		print("Condition met")
	```

### 5.4 布尔运算符
*   优先使用单词形式的运算符，它们更易读：`and`, `or`, `not`，而不是 `&&`, `||`, `!`。

### 5.5 数字格式
*   **浮点数**: 不要省略前导或后缀的零。使用 `1.0` 和 `0.5`，而不是 `1.` 或 `.5`。
*   **十六进制**: 使用小写字母，例如 `#ffffff`。
*   **大数字**: 使用下划线 `_` 作为千位分隔符来提高可读性。
	*   示例: `var large_number = 1_000_000`

### 5.6 代码简洁性
*   **一条语句一行**: 避免使用分号 `;` 在一行内写多条语句。
*   **避免冗余括号**: 除非为了改变运算优先级或多行书写，否则不要在 `if` 语句或表达式中滥用括号。

### 5.7 字符串
*   优先使用双引号 `"` 来定义字符串，保持一致性。

---

## 6. 文件格式与编码

*   **编码**: 所有 `.gd` 文件必须使用 **UTF-8** 编码（不带BOM）。
*   **换行符**: 使用 **Unix-style** 换行符 (**LF**)，而不是Windows-style (CRLF)。
*   **文件末尾**: 所有文件应以一个空行结束。
*   **缩进**: 使用制表符 (`Tab`) 进行缩进，而不是空格。

> 注意: 以上四条均为Godot编辑器的默认行为，保持默认设置即可。
