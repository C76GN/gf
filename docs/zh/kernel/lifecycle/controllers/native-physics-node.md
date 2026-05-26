# 原生物理节点桥接

角色、载具等 Godot 物理节点应继续继承自己的原生类型，Controller 作为子节点接入 GF 架构。这样可以保留 Godot 物理语义，同时把输入、模型读取和系统调用收敛到 Controller。

## 宿主节点

```gdscript
class_name ActorBody
extends CharacterBody2D

@onready var state_machine: GFNodeStateMachine = $StateMachine


func move_by_input(input_vector: Vector2, speed: float) -> void:
	velocity = input_vector * speed
	move_and_slide()
```

## Controller 桥接

```gdscript
class_name ActorMovementController
extends GFController

@onready var _actor: ActorBody = get_host_as(ActorBody) as ActorBody

var _actor_model: ActorModel = null
var _state_machine: GFNodeStateMachine = null


func _ready() -> void:
	var architecture := await wait_for_context_ready()
	_actor_model = architecture.get_model(ActorModel) as ActorModel
	_state_machine = _actor.state_machine


func _physics_process(_delta: float) -> void:
	if _actor == null or _actor_model == null or not _actor_model.can_move:
		return

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_actor.move_by_input(input_vector, _actor_model.move_speed)
```

## 使用边界

物理移动、碰撞响应和节点生命周期仍遵循 Godot 原生规则。Controller 只负责把架构数据和输入意图转交给宿主节点。
