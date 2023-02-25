class_name Arrow
extends Area2D

signal landed()
signal arrow_accounted_for()

onready var sprite = $Sprite
onready var head = $CollisionShape2D
var fired = false
var on_ground = false
export var damage = 10
export var mass = 10.0
export var ground_speed = 200
export var velocity = Vector2.ZERO

func _ready() -> void:
	add_to_group("arrow")
	add_to_group("to_remove")

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
	global_position = new_parent.global_position - (hit_pos)
	global_rotation = velocity.angle()
	reset_physics_interpolation()
	Audio.play_sound("res://assets/audio/sounds/arrows/368606__samsterbirdies__thump.wav")
	deactivate()

func _physics_process(delta: float) -> void:
	if fired:
		if head.global_position.y > 340:
			deactivate()
			Audio.play_sound("res://assets/audio/sounds/arrows/559233__bl31gt0__breath_kick.wav")
			on_ground = true
			return
		velocity.y += gravity * mass * delta
		global_position += velocity * delta
		global_rotation = velocity.angle()
	elif on_ground:
		global_position += Vector2.LEFT * ground_speed * delta
	if on_ground and global_position.x < -1280:
		print("arrow out of range")
		emit_signal("arrow_accounted_for")
		queue_free()
