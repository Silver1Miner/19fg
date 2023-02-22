extends Control

signal back()
signal start_hunt(loaded_arrows)
onready var hunt_button = $Hunt
onready var calendar_ui = $CalendarUI
onready var date_display = $HuntDisplay/DateDisplay
onready var spinbox = $SpinBox
onready var spinbox_up = $SpinBox/Buttons/Up
onready var spinbox_down = $SpinBox/Buttons/Down
onready var spinbox_up_one = $SpinBox/Buttons/UpOne
onready var spinbox_down_one = $SpinBox/Buttons/DownOne
onready var inventory_display = $Inventory
onready var hunt_display = $HuntDisplay
var arrows = 0 setget set_arrows
var coins = 0 setget set_coins
const max_arrows = 999999
var todays_hunt_completed = false

func _ready() -> void:
	todays_hunt_completed = false
	hunt_display.default_display()
	set_arrows(UserData.arrows)
	set_coins(UserData.gems)
	check_spin_buttons()

func _on_Back_button_up() -> void:
	emit_signal("back")

func _on_CalendarUI_date_selected(date_obj: Date) -> void:
	UserData.change_records_loaded(date_obj.get_year(), date_obj.get_month())
	if hunt_display:
		hunt_display.update_date_display(date_obj.get_year(), date_obj.get_month(), date_obj.get_day())
		if str(date_obj.get_day()) in UserData.current_loaded:
			hunt_display.attempt_update(UserData.current_loaded[str(date_obj.get_day())])
		else:
			hunt_display.default_display()

func check_today() -> void:
	calendar_ui.date.change_to_today()
	calendar_ui.refresh_data()
	_on_CalendarUI_date_selected(calendar_ui.date)
	todays_hunt_completed = str(calendar_ui.date.get_day()) in UserData.current_loaded
	hunt_button.disabled = todays_hunt_completed
	set_arrows(UserData.arrows)
	set_coins(UserData.gems)
	check_spin_buttons()

func _on_Hunt_pressed() -> void:
	emit_signal("start_hunt", spinbox.value)

func set_arrows(new_value: int) -> void:
	arrows = new_value
	inventory_display.update_arrow_display(arrows)

func set_coins(new_value: int) -> void:
	coins = new_value
	inventory_display.update_coins_display(coins)

func _on_SpinBox_request_decrease() -> void:
	spinbox_try_decrease(spinbox.step)

func _on_SpinBox_request_increase() -> void:
	spinbox_try_increase(spinbox.step)

func check_spin_buttons() -> void:
	spinbox_down.disabled = (spinbox.value == spinbox.min_value) or arrows == max_arrows or todays_hunt_completed
	spinbox_up.disabled = (spinbox.value == spinbox.max_value) or arrows == 0 or todays_hunt_completed
	spinbox_down_one.disabled = (spinbox.value == spinbox.min_value) or arrows == max_arrows or todays_hunt_completed
	spinbox_up_one.disabled = (spinbox.value == spinbox.max_value) or arrows == 0 or todays_hunt_completed
	if todays_hunt_completed:
		spinbox.display.text= "-"

func _on_SpinBox_request_decrease_one() -> void:
	spinbox_try_decrease(1)

func _on_SpinBox_request_increase_one() -> void:
	spinbox_try_increase(1)

func spinbox_try_increase(step_size: int) -> void:
	if arrows > step_size:
		if spinbox.value + step_size < spinbox.max_value:
			set_arrows(arrows - step_size)
			spinbox.set_value(spinbox.value + step_size)
		else:
			var step = spinbox.max_value - spinbox.value
			set_arrows(arrows - step)
			spinbox.set_value(spinbox.value + step)
	elif arrows > 0:
		if arrows + step_size < spinbox.max_value:
			spinbox.set_value(spinbox.value + arrows)
			set_arrows(arrows - arrows)
		else:
			var step = spinbox.max_value - spinbox.value
			spinbox.set_value(spinbox.value + step)
			set_arrows(arrows - step)
	check_spin_buttons()

func spinbox_try_decrease(step_size: int) -> void:
	if spinbox.value > step_size:
		set_arrows(arrows + step_size)
		spinbox.set_value(spinbox.value - step_size)
	elif spinbox.value > 0:
		set_arrows(arrows + spinbox.value)
		spinbox.set_value(spinbox.value - spinbox.value)
	check_spin_buttons()
