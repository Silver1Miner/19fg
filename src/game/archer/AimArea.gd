extends Area2D

signal bow_grabbed()
signal bow_released()
signal bow_moved(touch_position)

var aiming = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			emit_signal("bow_released")
			aiming = false
	if event is InputEventScreenDrag:
		if aiming:
			emit_signal("bow_moved", event.position)

func _on_AimArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			emit_signal("bow_grabbed")
			aiming = true
