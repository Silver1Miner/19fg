extends Control

signal back()

func _ready() -> void:
	pass # Replace with function body.

func _on_Back_button_up() -> void:
	emit_signal("back")
