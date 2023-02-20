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
			gameworld.set_game_mode(current_game_mode)
		else:
			main_menu.visible = true
			if main_menu.current_panel == 2:
				anim.play("to_log")
				main_menu.hunt_pane.check_today()

func _on_MainMenu_start_practice() -> void:
	main_menu.visible = false
	current_game_mode = 2
	gameworld.set_arrows(10)
	start = true
	anim.play("move_game")

func _on_GameWorld_end_game() -> void:
	start = false
	anim.play_backwards("move_game")

func _on_MainMenu_start_hunt(loaded_arrows: int) -> void:
	main_menu.visible = false
	current_game_mode = 0
	gameworld.set_arrows(loaded_arrows + 10)
	start = true
	anim.play("move_game")

func _on_MainMenu_to_shop() -> void:
	anim.play("to_store")

func _on_MainMenu_to_log() -> void:
	anim.play("to_log")

func _on_MainMenu_shop_to_main() -> void:
	anim.play_backwards("to_store")

func _on_MainMenu_log_to_main() -> void:
	anim.play_backwards("to_log")

func _on_MainMenu_loadout_changed() -> void:
	gameworld.update_archer()

func _on_MainMenu_start_duel() -> void:
	main_menu.visible = false
	current_game_mode = 1
	gameworld.set_arrows(10)
	start = true
	anim.play("move_game")

func _on_GameWorld_end_camera() -> void:
	$Camera2D.make_current()
