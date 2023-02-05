extends Control

signal back()
onready var date_display = $HuntDisplay/DateDisplay

func _ready() -> void:
	pass # Replace with function body.

func _on_Back_button_up() -> void:
	emit_signal("back")

func _on_CalendarUI_date_selected(date_obj: Date) -> void:
	if date_display:
		date_display.text = str(date_obj.get_year()) + "/" + str(date_obj.get_month()) + "/" + str(date_obj.get_day())
