extends Node2D

enum GameModes {HUNT,DUEL,PRACTICE}
enum DuelStates {P1TURN, P2TURN, END}
export var duel_state = DuelStates.END
export var game_mode = GameModes.DUEL
export var targets = preload("res://src/game/targets/Target.tscn")
onready var line_draw = $Line2D
onready var angle_display = $HUD/Angle
onready var spawn_timer = $SpawnTimer
onready var archer1 = $Archer1
onready var archer2 = $Archer2

func _ready() -> void:
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)
	change_game_mode(game_mode)
	archer1.player_group = "P1"
	archer1.enemy_group = "P2"
	archer2.player_group = "P2"
	archer2.enemy_group = "P1"

func change_game_mode(new_mode: int) -> void:
	game_mode = new_mode
	match game_mode:
		0: # HUNT
			archer1.state = 1
			archer2.state = 0
			spawn_timer.start()
		1: # DUEL
			duel_state = DuelStates.P1TURN
			archer1.state = 1
			archer2.state = 0
			spawn_timer.stop()
		2: # PRACTICE
			archer1.state = 1
			archer2.state = 0
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
	if get_tree().change_scene("res://src/menu/MainMenu.tscn") != OK:
		push_error("fail to change scene")

func _on_Archer_update_draw(draw_start: Vector2, draw_end: Vector2) -> void:
	line_draw.points[0] = draw_start
	line_draw.points[1] = draw_end
	angle_display = rad2deg((draw_start-draw_end).angle())

func _on_SpawnTimer_timeout() -> void:
	var target_instance = targets.instance()
	add_child(target_instance)
	target_instance.global_position = $Spawner/Position2D2.global_position
	target_instance.velocity = Vector2.LEFT * 100
