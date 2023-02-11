extends Node2D

signal end_game()
enum GameModes {HUNT,DUEL,PRACTICE}
enum DuelStates {P1TURN, P2TURN, END}
export var duel_state = DuelStates.END
export var game_mode = GameModes.HUNT
export var targets = preload("res://src/game/targets/Target.tscn")
onready var line_draw = $Line2D
onready var game_objects = $GameObjects
onready var score_display = $CanvasLayer/HUD/Score
onready var angle_display = $CanvasLayer/HUD/Angle
onready var spawn_timer = $SpawnTimer
onready var tick = $Tick
onready var archer1 = $Archer
onready var archer2 = $Archer2
onready var hud = $CanvasLayer/HUD
onready var clock_display = $CanvasLayer/HUD/Clock
var current_seed = 1
var score = 0
var seconds = 0
var minutes = 0
var arrows = 10
var shots = 0
var hits = 0
var game_started = false

func _ready() -> void:
	hud.visible = false
	archer1.state = 0
	archer2.state = 0
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)

func start_game(new_mode: int) -> void:
	game_started = true
	hud.visible = true
	game_mode = new_mode
	match game_mode:
		0: # HUNT
			clock_display.visible = true
			seconds = 0
			minutes = 0
			arrows = UserData.arrows_brought
			clock_display.text = "00:00"
			tick.start(1.0)
			archer1.state = 1
			archer2.state = 0
			archer2.active_toggle(false)
			spawn_timer.start()
		1: # DUEL
			clock_display.visible = false
			tick.stop()
			duel_state = DuelStates.P1TURN
			archer2.active_toggle(true)
			archer1.state = 1
			archer2.state = 0
			spawn_timer.stop()
		2: # PRACTICE
			clock_display.visible = false
			tick.stop()
			archer1.state = 1
			archer2.state = 0
			archer2.active_toggle(false)
			spawn_timer.stop()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Engine.time_scale = 0.2
	elif event.is_action_released("ui_cancel"):
		Engine.time_scale = 1.0

func _on_arrow_landed() -> void:
	print("arrow landed")
	if game_mode == GameModes.DUEL:
		next_turn()
	elif game_started:
		archer1.state = 1

func next_turn() -> void:
	if duel_state == DuelStates.P1TURN:
		duel_state = DuelStates.P2TURN
		archer2.state = 1
		archer1.state = 0
	elif duel_state == DuelStates.P2TURN:
		duel_state = DuelStates.P1TURN
		archer1.state = 1
		archer2.state = 0

func _on_Back_pressed() -> void:
	end_game()

func _on_Archer_update_draw(draw_start: Vector2, draw_end: Vector2) -> void:
	line_draw.points[0] = draw_start
	line_draw.points[1] = draw_end
	var angle = 180 - rad2deg((draw_end - draw_start).angle())
	print(angle)
	angle_display = str(angle)

func _on_SpawnTimer_timeout() -> void:
	var target_instance = targets.instance()
	game_objects.add_child(target_instance)
	target_instance.global_position = $Spawner/Position2D4.global_position
	target_instance.direction = Vector2.RIGHT

func _on_Archer_arrow_fired() -> void:
	pass # Replace with function body.

func _on_Archer_increase_score(score_increase) -> void:
	score += score_increase
	score_display.text = str(score)

func _on_Tick_timeout() -> void:
	seconds += 1
	if seconds < 0:
		seconds = 1
	elif seconds >= 60:
		minutes += 1
		seconds = 0
	var minute_display = ""
	if minutes < 10:
		minute_display = "0" + str(minutes)
	else:
		minute_display = str(minutes)
	var second_display = ""
	if seconds < 10:
		second_display = "0" + str(int(seconds))
	else:
		second_display = str(int(seconds))
	clock_display.text = minute_display + ":" + second_display

func _on_Home_button_up() -> void:
	# save game result
	end_game()

func end_game() -> void:
	game_started = false
	for obj in game_objects.get_children():
		game_objects.remove_child(obj)
		obj.queue_free()
	archer1.state = 0
	archer2.state = 0
	spawn_timer.stop()
	tick.stop()
	hud.visible = false
	emit_signal("end_game")

