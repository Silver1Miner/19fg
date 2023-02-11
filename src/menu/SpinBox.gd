extends HBoxContainer

signal request_increase()
signal request_decrease()
const max_value = 90
const min_value = 0
const max_step = 10
var step = 10
var value = 0
onready var display = $Label

func _ready() -> void:
	display.text = str(10)

func set_value(new_value: int) -> void:
	value = new_value
	display.text = str(value + 10)
	if value < 0 or value > max_value:
		push_error("invalid spinbox value")

func _on_Up_pressed() -> void:
	emit_signal("request_increase")

func _on_Down_pressed() -> void:
	emit_signal("request_decrease")
