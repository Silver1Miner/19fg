extends Node

onready var gameworld = $GameWorld
onready var main_menu = $MainMenu
onready var anim = $AnimationPlayer
var start = false
var current_game_mode = 0
var arrows_loaded = 0

func _ready() -> void:
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "move_game":
		if start:
			gameworld.start_game(current_game_mode)
		else:
			main_menu.visible = true

func _on_MainMenu_start_practice() -> void:
	main_menu.visible = false
	current_game_mode = 2
	start = true
	anim.play("move_game")

func _on_GameWorld_end_game() -> void:
	start = false
	anim.play_backwards("move_game")

func _on_MainMenu_start_hunt() -> void:
	main_menu.visible = false
	current_game_mode = 0
	start = true
	anim.play("move_game")

func _on_MainMenu_to_shop() -> void:
	pass
