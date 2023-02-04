extends Area2D

signal bow_grabbed(touch_position)
signal bow_released(touch_position)
signal bow_moved(touch_position)

var aiming = false

func _input(event):
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			emit_signal("bow_released", event.position)
			aiming = false
	if event is InputEventScreenDrag:
		if aiming:
			emit_signal("bow_moved", event.position)

func _on_AimArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			emit_signal("bow_grabbed", event.position)
			aiming = true
