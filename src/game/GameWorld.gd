extends Node2D

export var targets = preload("res://src/game/targets/Target.tscn")
onready var line_draw = $Line2D
onready var angle_display = $HUD/Angle
onready var spawn_timer = $SpawnTimer

func _ready() -> void:
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Engine.time_scale = 0.2
	elif event.is_action_released("ui_cancel"):
		Engine.time_scale = 1.0

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
