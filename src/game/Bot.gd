extends Node

var pull = Vector2.ZERO
var target = Vector2.ZERO
var archer1 = null
var archer2 = null
var theta = 0

func take_turn() -> void:
	if not archer1:
		archer1 = get_parent().get_node("Archer")
	if not archer2:
		archer2 = get_parent().get_node("Archer2")
	target = archer2.global_position - archer1.hitboxc.global_position
	bot_spoof_click()
	calculate_theta(target)
	set_draw_pull(500, theta)
	yield(get_tree().create_timer(0.5), "timeout")
	bot_spoof_drag()
	yield(get_tree().create_timer(0.5), "timeout")
	bot_spoof_release()

func calculate_theta(r: Vector2) -> void:
	var v = archer2.bow_elastic_force
	print("target position: ", r)
	print("speed: ", v)
	var num = v*v+sqrt(v*v*v*v-98*(98*r.x*r.x+2*r.y*v*v))
	theta = atan(num/(98*r.x)) + PI*0.5
	print("angle: ", rad2deg(theta))

func set_draw_pull(magnitude: float, angle: float) -> void:
	pull.x = magnitude * -cos(angle)
	pull.y = magnitude * sin(angle)

func bot_spoof_click() -> void:
	if archer2:
		archer2.bow_grab(Vector2.ZERO)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false

func bot_spoof_drag() -> void:
	if archer2:
		archer2.bow_move(pull)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false

func bot_spoof_release() -> void:
	if archer2:
		archer2.bow_release(pull)
	else:
		push_error("no archer 2")
		get_parent().is_bots_turn = false
