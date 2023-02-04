extends Node2D

signal update_draw(draw_start, draw_end)

export var bow_elastic_force = 1.0
export var gravity = 0.98
onready var arrow_display = $ArrowDisplay
onready var trajectory_draw = $TrajectoryDraw
onready var draw_start = Vector2.ZERO
onready var draw_end = Vector2.ZERO
var launch_impulse = Vector2.ZERO
var Arrow = preload("res://src/game/archer/Arrow.tscn")
var arrow_instance = null

enum States {
	IDLE,
	READY,
	AIMING,
}
var state = States.READY

func _ready() -> void:
	arrow_display.visible = false

func _input(event):
	if state == States.READY:
		if event is InputEventScreenTouch:
			if event.is_pressed():
				bow_grab(event.position)
				state = States.AIMING
	elif state == States.AIMING:
		if event is InputEventScreenTouch:
			if not event.is_pressed():
				bow_release(event.position)
				state = States.IDLE
		if event is InputEventScreenDrag:
			bow_move(event.position)

func _physics_process(_delta):
	match state:
		States.AIMING:
			launch_impulse = update_impulse()
			arrow_display.rotation = (draw_start - draw_end).angle()
			trajectory_draw.draw_trajectory(
				launch_impulse / 10 / arrow_instance.mass,
				arrow_instance.global_position,
				gravity * 10
			)
			pass

func update_impulse() -> Vector2:
	return bow_elastic_force * (draw_start - draw_end)

func load_projectile():
	state = States.AIMING
	arrow_instance = Arrow.instance()
	add_child(arrow_instance)
	arrow_instance.global_position = global_position
	arrow_display.visible = true

func bow_grab(touch_position: Vector2) -> void:
	load_projectile()
	draw_start = touch_position
	draw_end = touch_position
	print("start aiming at ", touch_position)
	emit_signal("update_draw", draw_start, draw_end)

func bow_move(touch_position: Vector2) -> void:
	if state == States.IDLE:
		return
	draw_end = touch_position
	state = States.AIMING
	emit_signal("update_draw", draw_start, draw_end)

func bow_release(touch_position: Vector2) -> void:
	print("fire! at ", touch_position)
	draw_end = touch_position
	if arrow_instance:
		arrow_display.visible = false
		arrow_instance.visible = true
		arrow_instance.gravity_scale = gravity
		arrow_instance.apply_central_impulse(launch_impulse)
	state = States.READY
	draw_start = Vector2.ZERO
	draw_end = Vector2.ZERO
	emit_signal("update_draw", draw_start, draw_end)
