class_name Arrow
extends Area2D

onready var head = $CollisionShape2D

var fired = false
export var mass = 10.0
export var velocity = Vector2.ZERO

func _ready() -> void:
	add_to_group("arrow")

func _physics_process(delta: float) -> void:
	if head.global_position.y > 330:
		gravity = 0
		velocity = Vector2.ZERO
		fired = false
	if fired:
		velocity.y += gravity * mass * delta
		position += velocity * delta
		rotation = velocity.angle()
