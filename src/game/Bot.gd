extends Node

const center = Vector2.ZERO
var target_point = Vector2.ZERO
var archer2 = null

func take_turn() -> void:
	archer2 = get_parent().get_node("Archer2")
	set_target_point(500, PI*2.4)
	bot_spoof_click()
	yield(get_tree().create_timer(0.5), "timeout")
	bot_spoof_drag()
	yield(get_tree().create_timer(0.5), "timeout")
	bot_spoof_release()

func set_target_point(magnitude: float, angle: float) -> void:
	target_point.x = magnitude * cos(angle)
	target_point.y = magnitude * sin(angle)

func bot_spoof_click() -> void:
	if archer2:
		archer2.bow_grab(center)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false

func bot_spoof_drag() -> void:
	if archer2:
		archer2.bow_move(target_point)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false

func bot_spoof_release() -> void:
	if archer2:
		archer2.bow_release(target_point)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false
