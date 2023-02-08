extends Control

var current_panel = 1
onready var tween = $Tween
onready var panes = $Panels
onready var duel_options = $Panels/Menu/MenuOptions/DuelOptions

func _ready() -> void:
	if OS.get_name() in ["HTML5", "iOS", "Android"]:
		$Panels/Menu/MenuOptions/Quit.visible = false

func change_panel(select: int) -> void:
	current_panel = select
	if tween:
		Audio.play_slide()
		tween.interpolate_property(panes, "rect_position:x",
		panes.rect_position.x, current_panel * -640, 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()

func _on_Shop_back() -> void:
	change_panel(1)

func _on_Hunt_back() -> void:
	change_panel(1)

func _on_Hunt_button_up() -> void:
	change_panel(2)

func _on_Shop_button_up() -> void:
	change_panel(0)

func _on_Quit_button_up() -> void:
	get_tree().quit()

func _on_Range_pressed() -> void:
	if get_tree().change_scene("res://src/game/GameWorld.tscn") != OK:
		push_error("fail to change scene")

func _on_Duel_toggled(button_pressed: bool) -> void:
	duel_options.visible = button_pressed
