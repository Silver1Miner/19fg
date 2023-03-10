extends Control

signal to_shop()
signal shop_to_main()
signal log_to_main()
signal to_log()
signal start_practice()
signal start_hunt()
signal start_duel()
signal loadout_changed()
var current_panel = 1
onready var tween = $Tween
onready var panes = $Panels
onready var menu_options = $Panels/Menu/MenuOptions
onready var duel_options = $Panels/Menu/DuelOptions
onready var settings_menu = $Panels/Menu/Settings
onready var shop_pane = $Panels/Shop
onready var hunt_pane = $Panels/Hunt

func _ready() -> void:
	menu_options.visible = true
	duel_options.visible = false
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
		shop_pane.check_status()
		emit_signal("to_shop")
	elif current_panel == 2:
		hunt_pane.check_today()
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

func _on_Hunt_start_hunt() -> void:
	emit_signal("start_hunt")

func _on_Settings_pressed() -> void:
	settings_menu.visible = true

func _on_Shop_loadout_changed() -> void:
	emit_signal("loadout_changed")

func _on_DuelOptions_closed_duel() -> void:
	emit_signal("loadout_changed")
	menu_options.visible = true
	duel_options.visible = false

func _on_Duel_pressed() -> void:
	duel_options.update_option_buttons()
	duel_options.visible = true
	menu_options.visible = false

func _on_DuelOptions_duel_start() -> void:
	emit_signal("start_duel")
