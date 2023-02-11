class_name Arrow
extends Area2D

signal landed()

onready var head = $CollisionShape2D
var fired = false
var on_ground = false
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
	call_deferred("_reparent", target, target.global_position - global_position)

func _reparent(new_parent: Node, hit_pos: Vector2) -> void:
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = new_parent.global_position - (hit_pos*0.2)
	global_rotation = velocity.angle()
	deactivate()

func _physics_process(delta: float) -> void:
	if fired:
		if head.global_position.y > 340:
			deactivate()
			on_ground = true
			return
		velocity.y += gravity * mass * delta
		global_position += velocity * delta
		global_rotation = velocity.angle()
	elif on_ground:
		global_position += Vector2.LEFT * 50 * delta
	if global_position.x < -80:
		emit_signal("landed")
		print("arrow out of range")
		queue_free()
