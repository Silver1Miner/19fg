extends Node2D

export var bow_elastic_force = 40
export var gravity = 9.8
export var max_draw = 10
onready var aim_area = $AimArea
onready var trajectory_draw = $TrajectoryDraw
var launch_impulse = Vector2.ZERO
var Arrow = preload("res://src/game/archer/Arrow.tscn")
var arrow_instance = null

enum States {
	IDLE,
	LOADING,
	READY,
	AIMING,
}
var state = States.IDLE

func _physics_process(_delta):
	match state:
		States.AIMING:
			launch_impulse = update_impulse()
			trajectory_draw.draw_trajectory(
				launch_impulse / arrow_instance.mass,
				arrow_instance.global_position,
				gravity
			)
			pass

func update_impulse() -> Vector2:
	return bow_elastic_force * (arrow_instance.global_position - global_position)

func load_projectile():
	state = States.LOADING
	arrow_instance = Arrow.instance()
	add_child(arrow_instance)
	arrow_instance.global_position = global_position

func _on_AimArea_bow_grabbed() -> void:
	load_projectile()
	print("start aiming")

func _on_AimArea_bow_moved(touch_position: Vector2) -> void:
	var xformed_position = get_viewport().canvas_transform.affine_inverse().xform(touch_position)
	if state == States.IDLE:
		return
	state = States.AIMING
	arrow_instance.global_position = (xformed_position - global_position).limit_length(max_draw) + global_position

func _on_AimArea_bow_released() -> void:
	print("fire!")
	arrow_instance.gravity_scale = gravity
	state = States.IDLE
