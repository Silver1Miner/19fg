extends Node2D

signal end_game()
enum GameModes {HUNT, DUEL, PRACTICE}
enum DuelStates {P1TURN, P2TURN, END}
export var duel_state = DuelStates.END
export var game_mode = GameModes.HUNT
export var targets = preload("res://src/game/targets/Target.tscn")
onready var line_draw = $Line2D
onready var game_over = $CanvasLayer/HUD/GameOver
onready var game_objects = $GameObjects
onready var status_display = $CanvasLayer/HUD/Status
onready var score_display = $CanvasLayer/HUD/Status/Score/ScoreValue
onready var angle_display = $CanvasLayer/HUD/Aim/Angle/AngleValue
onready var spawn_timer = $SpawnTimer
onready var tick = $Tick
onready var archer1 = $Archer
onready var archer2 = $Archer2
onready var hud = $CanvasLayer/HUD
onready var instructions = $CanvasLayer/Instructions
onready var clock_display = $CanvasLayer/HUD/Status/Clock
onready var shots_display = $CanvasLayer/HUD/Accuracy/Shots/ShotsValue
onready var hits_display = $CanvasLayer/HUD/Accuracy/Hits/HitsValue
onready var arrow_display = $CanvasLayer/HUD/Inventory/Arrows/ArrowValue
var current_seed = 1
var score = 0 setget _set_score
var seconds = 0
var minutes = 0
var arrows = 10 setget set_arrows
var shots = 0 setget _set_shots
var hits = 0 setget _set_hits
var game_started = false

func _ready() -> void:
	hud.visible = false
	instructions.visible = false
	archer1.state = 0
	archer2.state = 0
	archer2.active_toggle(false)
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)

func set_game_mode(new_mode: int) -> void:
	game_started = false
	archer1.state = 0
	archer2.state = 0
	archer2.active_toggle(false)
	spawn_timer.stop()
	tick.stop()
	hud.visible = false
	game_mode = new_mode
	match game_mode:
		0: # HUNT
			pass
		1: # DUEL
			pass
		2: # PRACTICE
			pass
	if UserData.tutorial_on:
		instructions.visible = true
	else:
		start_game()

func _on_Start_pressed() -> void:
	instructions.visible = false
	start_game()

func start_game() -> void:
	game_started = true
	hud.visible = true
	match game_mode:
		0: # HUNT
			status_display.visible = true
			seconds = 0
			minutes = 0
			_set_score(0)
			_set_shots(0)
			_set_hits(0)
			clock_display.text = "00:00"
			tick.start(1.0)
			archer1.hunting_mode = true
			archer1.state = 1
			archer2.state = 0
			archer2.active_toggle(false)
			spawn_timer.start()
		1: # DUEL
			status_display.visible = false
			tick.stop()
			duel_state = DuelStates.P1TURN
			archer1.hunting_mode = false
			archer2.active_toggle(true)
			archer1.state = 1
			archer2.state = 0
			spawn_timer.stop()
		2: # PRACTICE
			status_display.visible = false
			tick.stop()
			archer1.hunting_mode = true
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
	if game_mode == GameModes.HUNT:
		game_over.visible = true
	else:
		end_game()

func _on_Archer_update_draw(draw_start: Vector2, draw_end: Vector2) -> void:
	line_draw.points[0] = draw_start
	line_draw.points[1] = draw_end
	var angle = rad2deg((draw_end - draw_start).angle())
	var angle_displayed = 0
	if angle < 0.0:
		angle_displayed = -180.0 - angle
	elif angle < 180.0 and angle > 0:
		angle_displayed = 180.0 - angle
	else:
		angle_displayed = 0.0
	angle_display.text = str(stepify(angle_displayed, 0.01))
	print(angle)

func _on_SpawnTimer_timeout() -> void:
	var target_instance = targets.instance()
	game_objects.add_child(target_instance)
	if target_instance.connect("shot", self, "_on_target_hit") != OK:
		push_error("fail to connect target shot signal")
	target_instance.global_position = $Spawner/Position2D4.global_position
	target_instance.direction = Vector2.RIGHT

func _on_Archer_arrow_fired() -> void:
	_set_shots(shots + 1)
	set_arrows(arrows - 1)

func _on_target_hit() -> void:
	_set_hits(hits + 1)

func _on_Archer_increase_score(score_increase: int) -> void:
	_set_score(score + score_increase)

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

func _on_Home_pressed() -> void:
	# save game result
	end_game()

func end_game() -> void:
	game_started = false
	archer1.state = 0
	archer2.state = 0
	for obj in game_objects.get_children():
		game_objects.remove_child(obj)
		obj.queue_free()
	spawn_timer.stop()
	tick.stop()
	hud.visible = false
	emit_signal("end_game")

func _set_score(new_value: int) -> void:
	score = new_value
	score_display.text = str(score)

func set_arrows(new_value: int) -> void:
	arrows = new_value
	arrow_display.text = str(arrows)
	if arrows <= 0:
		archer1.hunting_mode = false
		archer1.reload_timer.stop()

func _set_shots(new_value: int) -> void:
	shots = new_value
	shots_display.text = str(shots)

func _set_hits(new_value: int) -> void:
	hits = new_value
	hits_display.text = str(hits)
