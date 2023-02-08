class_name Arrow
extends Area2D

signal landed()

onready var head = $CollisionShape2D
var fired = false
export var mass = 10.0
export var velocity = Vector2.ZERO

func _ready() -> void:
	add_to_group("arrow")

func deactivate() -> void:
	monitoring = false
	gravity = 0
	velocity = Vector2.ZERO
	fired = false
	emit_signal("landed")

func stick_to(target: Area2D) -> void:
	remove_from_group("arrow")
	call_deferred("_reparent", target, target.global_position - global_position)

func _reparent(new_parent: Node, hit_pos: Vector2) -> void:
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = new_parent.global_position - hit_pos
	global_rotation = velocity.angle()
	deactivate()

func _physics_process(delta: float) -> void:
	if fired and head.global_position.y > 330:
		deactivate()
	if fired:
		velocity.y += gravity * mass * delta
		global_position += velocity * delta
		global_rotation = velocity.angle()
