extends Node2D

signal update_draw(draw_start, draw_end)
export var player_group = "P1"
export var enemy_group = "P2"
export var hunting_mode = false
export var bow_elastic_force = 1000.0
export var gravity = 10.0
onready var hitbox = $Hitbox
onready var pickupbox = $PickupBox
onready var reload_timer = $Timer
onready var reload_bar = $ProgressBar
onready var aiming_sprite = $Aiming
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
	reload_bar.max_value = reload_timer.time_left

func active_toggle(disable: bool) -> void:
	#visible = disable
	hitbox.monitoring = disable
	pickupbox.monitoring = disable

func _input(event):
	if state == States.READY:
		if event is InputEventScreenTouch:
			if event.is_pressed():
				trajectory_draw.visible = true
				bow_grab(event.position)
	elif state == States.AIMING:
		if event is InputEventScreenTouch:
			if not event.is_pressed():
				bow_release(event.position)
		if event is InputEventScreenDrag:
			bow_move(event.position)
	else:
		trajectory_draw.visible = false

func _physics_process(_delta):
	reload_bar.value = reload_timer.time_left
	match state:
		States.AIMING:
			if arrow_instance:
				launch_impulse = update_impulse()
				aiming_sprite.rotation = (draw_start - draw_end).angle()
				arrow_display.rotation = (draw_start - draw_end).angle()
				trajectory_draw.draw_trajectory(
					launch_impulse / arrow_instance.mass,
					arrow_instance.global_position,
					gravity
				)

func update_impulse() -> Vector2:
	return bow_elastic_force * (draw_start - draw_end).normalized()

func load_projectile():
	state = States.AIMING
	arrow_instance = Arrow.instance()
	arrow_instance.connect("landed", get_parent(), "_on_arrow_landed")
	get_parent().add_child(arrow_instance)
	arrow_instance.add_to_group(player_group)
	arrow_instance.position = position
	arrow_display.visible = true

func bow_grab(touch_position: Vector2) -> void:
	if state == States.IDLE:
		return
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
		arrow_instance.gravity = gravity * 10
		arrow_instance.fired = true
		arrow_instance.velocity = launch_impulse
		arrow_instance = null
	draw_start = Vector2.ZERO
	draw_end = Vector2.ZERO
	emit_signal("update_draw", draw_start, draw_end)
	state = States.IDLE
	if hunting_mode:
		reload_timer.start()

func _on_Timer_timeout() -> void:
	if hunting_mode and state == States.IDLE:
		state = States.READY

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(enemy_group):
		area.remove_from_group(enemy_group)
		area.stick_to(hitbox)

func _on_PickupBox_area_entered(area: Area2D) -> void:
	if area.is_in_group("prize"):
		print("prize collected")
		Audio.play_sound("res://assets/audio/sounds/confirmation_004.ogg")
		area.queue_free()
