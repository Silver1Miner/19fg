extends Node2D

export var bow_elastic_force = 20
export var gravity = 98
export var max_draw = 10
onready var aim_area = $AimArea
onready var trajectory_draw = $TrajectoryDraw
onready var line_draw = $Line2D
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

func _ready() -> void:
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)

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

func _on_AimArea_bow_grabbed(touch_position: Vector2) -> void:
	load_projectile()
	line_draw.points[0] = touch_position
	print("start aiming")

func _on_AimArea_bow_moved(touch_position: Vector2) -> void:
	if state == States.IDLE:
		return
	line_draw.points[1] = touch_position
	state = States.AIMING

func _on_AimArea_bow_released(touch_position: Vector2) -> void:
	print("fire!")
	line_draw.points[1] = touch_position
	if arrow_instance:
		arrow_instance.gravity_scale = gravity
	state = States.IDLE
	line_draw.points[0] = Vector2.ZERO
	line_draw.points[1] = Vector2.ZERO
