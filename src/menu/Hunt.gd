extends Control

signal back()
signal start_hunt(loaded_arrows)
onready var date_display = $HuntDisplay/DateDisplay
onready var spinbox = $SpinBox
onready var spinbox_up = $SpinBox/Buttons/Up
onready var spinbox_down = $SpinBox/Buttons/Down
onready var arrow_display = $Inventory/ArrowCount
var arrows = 120 setget set_arrows
const max_arrows = 999999

func _ready() -> void:
	set_arrows(UserData.owned_arrows)
	check_spin_buttons()

func _on_Back_button_up() -> void:
	emit_signal("back")

func _on_CalendarUI_date_selected(date_obj: Date) -> void:
	if date_display:
		date_display.text = str(date_obj.get_year()) + "/" + str(date_obj.get_month()) + "/" + str(date_obj.get_day())

func _on_Hunt_pressed() -> void:
	emit_signal("start_hunt", spinbox.value)

func set_arrows(new_value: int) -> void:
	arrows = new_value
	arrow_display.text = str(arrows)

func _on_SpinBox_request_decrease() -> void:
	if spinbox.value > spinbox.step:
		set_arrows(arrows + spinbox.step)
		spinbox.set_value(spinbox.value - spinbox.step)
	elif spinbox.value > 0:
		set_arrows(arrows + spinbox.value)
		spinbox.set_value(spinbox.value - spinbox.value)
	check_spin_buttons()

func _on_SpinBox_request_increase() -> void:
	if arrows > spinbox.step:
		if spinbox.value + spinbox.step < spinbox.max_value:
			set_arrows(arrows - spinbox.step)
			spinbox.set_value(spinbox.value + spinbox.step)
		else:
			var step = spinbox.max_value - spinbox.value
			set_arrows(arrows - step)
			spinbox.set_value(spinbox.value + step)
	elif arrows > 0:
		if arrows + spinbox.step < spinbox.max_value:
			spinbox.set_value(spinbox.value + arrows)
			set_arrows(arrows - arrows)
		else:
			var step = spinbox.max_value - spinbox.value
			spinbox.set_value(spinbox.value + step)
			set_arrows(arrows - step)
	check_spin_buttons()

func check_spin_buttons() -> void:
	spinbox_down.disabled = (spinbox.value == spinbox.min_value) or arrows == max_arrows
	spinbox_up.disabled = (spinbox.value == spinbox.max_value) or arrows == 0
