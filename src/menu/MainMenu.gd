extends Control

signal to_shop()
signal shop_to_main()
signal log_to_main()
signal to_log()
signal start_practice()
signal start_hunt(loaded_arrows)
var current_panel = 1
onready var tween = $Tween
onready var panes = $Panels
onready var duel_options = $Panels/Menu/MenuOptions/DuelOptions
onready var settings_menu = $Panels/Menu/Settings

func _ready() -> void:
	if OS.get_name() in ["HTML5", "iOS", "Android"]:
		$Panels/Menu/MenuOptions/Quit.visible = false

func change_panel(select: int) -> void:
	if select == 1:
		if current_panel == 0:
			emit_signal("shop_to_main")
		elif current_panel == 2:
			emit_signal("log_to_main")
	current_panel = select
	if current_panel == 0:
		emit_signal("to_shop")
	elif current_panel == 2:
		emit_signal("to_log")
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
	emit_signal("start_practice")

func _on_Duel_toggled(button_pressed: bool) -> void:
	duel_options.visible = button_pressed

func _on_Hunt_start_hunt(loaded_arrows: int) -> void:
	emit_signal("start_hunt", loaded_arrows)

func _on_Settings_pressed() -> void:
	settings_menu.visible = true
