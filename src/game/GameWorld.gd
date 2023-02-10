extends Node2D

enum GameModes {HUNT,DUEL,PRACTICE}
enum DuelStates {P1TURN, P2TURN, END}
export var duel_state = DuelStates.END
export var game_mode = GameModes.HUNT
export var targets = preload("res://src/game/targets/Target.tscn")
onready var line_draw = $Line2D
onready var score_display = $CanvasLayer/HUD/Score
onready var angle_display = $CanvasLayer/HUD/Angle
onready var spawn_timer = $SpawnTimer
onready var tick = $Tick
onready var archer1 = $Archer
onready var archer2 = $Archer2
onready var hud = $CanvasLayer/HUD
var score = 0
var arrows = 10
var time = 0

func _ready() -> void:
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)
	change_game_mode(game_mode)
	archer1.player_group = "P1"
	archer1.enemy_group = "P2"
	archer2.player_group = "P2"
	archer2.enemy_group = "P1"
	hud.get_node("Score").text = str(score)

func change_game_mode(new_mode: int) -> void:
	game_mode = new_mode
	match game_mode:
		0: # HUNT
			archer1.state = 1
			archer2.state = 0
			archer2.active_toggle(false)
			spawn_timer.start()
		1: # DUEL
			duel_state = DuelStates.P1TURN
			archer2.active_toggle(true)
			archer1.state = 1
			archer2.state = 0
			spawn_timer.stop()
		2: # PRACTICE
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
	else:
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
	if get_tree().change_scene("res://src/menu/MainMenu.tscn") != OK:
		push_error("fail to change scene")

func _on_Archer_update_draw(draw_start: Vector2, draw_end: Vector2) -> void:
	line_draw.points[0] = draw_start
	line_draw.points[1] = draw_end
	var angle = 180 - rad2deg((draw_end - draw_start).angle())
	print(angle)
	angle_display = str(angle)

func _on_SpawnTimer_timeout() -> void:
	var target_instance = targets.instance()
	add_child(target_instance)
	target_instance.global_position = $Spawner/Position2D4.global_position
	target_instance.direction = Vector2.RIGHT

func _on_Archer_arrow_fired() -> void:
	pass # Replace with function body.

func _on_Archer_increase_score(score_increase) -> void:
	score += score_increase
	score_display.text = str(score)

func _on_Tick_timeout() -> void:
	time += 1
