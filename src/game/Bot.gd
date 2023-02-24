extends Node

var pull = Vector2.ZERO
var target = Vector2(-900, 0)
var archer1 = null
var archer2 = null
var theta = 0

func take_turn() -> void:
	if not archer1:
		archer1 = get_parent().get_node("Archer")
	if not archer2:
		archer2 = get_parent().get_node("Archer2")
	bot_spoof_click()
	calculate_theta(target)
	randomize()
	set_draw_pull(1000, theta+rand_range(-0.01,0.01))
	randomize()
	yield(get_tree().create_timer(rand_range(0.4,0.6)), "timeout")
	bot_spoof_drag()
	yield(get_tree().create_timer(rand_range(0.4,0.6)), "timeout")
	bot_spoof_release()

func calculate_theta(r: Vector2) -> void:
	var v = archer2.bow_elastic_force
	var g = archer2.arrow_mass * archer2.arrow_mass * 5.0
	print("target position: ", r)
	print("speed: ", v)
	var num = v*v-sqrt(v*v*v*v-g*(g*r.x*r.x+2*r.y*v*v))
	theta = PI + atan(num/(g*r.x))
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
