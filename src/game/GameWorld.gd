extends Node2D

onready var line_draw = $Line2D
onready var angle_display = $HUD/Angle

func _ready() -> void:
	line_draw.add_point(Vector2.ZERO)
	line_draw.add_point(Vector2.ZERO)

func _on_Back_pressed() -> void:
	if get_tree().change_scene("res://src/menu/MainMenu.tscn") != OK:
		push_error("fail to change scene")

func _on_Archer_update_draw(draw_start: Vector2, draw_end: Vector2) -> void:
	line_draw.points[0] = draw_start
	line_draw.points[1] = draw_end
	angle_display = rad2deg((draw_start-draw_end).angle())
