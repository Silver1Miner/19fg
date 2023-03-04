extends Node2D

signal update_draw(draw_start, draw_end, force)
signal dodge_finished()
signal arrow_fired()
signal increase_score(score_increase)
signal picked_up(coin_value)
signal cooldown_update(time_left)
signal hp_changed(hp)
export var player_group = "P1"
export var enemy_group = "P2"
export var hunting_mode = false
export var bow_elastic_force = 500.0
const base_bow_force = 1000.0
export var bow_reload_time = 1.0
const base_reload_time = 1.0
export var arrow_mass = 10.0
const base_arrow_mass = 10.0
export var arrow_damage = 20
const base_arrow_damage = 20
export var gravity = 5.0
export var dodge_range = 300.0
const base_dodge_range = 300.0
export var dodge_duration = 1.0
const base_dodge_duration = 1.0
export var dodge_direction = 1
export var sight_range = 50
const base_sight_range = 20
onready var game_objects = get_node_or_null("../GameObjects")
onready var tween = $Tween
onready var ride_anim = $HorseBob
onready var bow_sprite = $Aiming/Bow
onready var arrow_sprite = $Aiming/Arrow
onready var arms_sprite = $Aiming/ArcherArms
onready var banner_sprite = $ArcherBody/Banner
onready var hat_sprite = $ArcherBody/Hat
onready var hitbox = $Hitbox
onready var hitboxc = $Hitbox/CollisionShape2D
onready var pickupbox = $PickupBox
onready var reload_timer = $Timer
onready var aiming_sprite = $Aiming
onready var trajectory_draw = $TrajectoryDraw
onready var anim = $AnimationPlayer
onready var draw_start = Vector2.ZERO
onready var draw_end = Vector2.ZERO
var launch_impulse = Vector2.ZERO
var bow_type = 0
var arrow_type = 0
var Arrow = preload("res://src/game/archer/Arrow.tscn")
var FCT = preload("res://src/game/effects/FCT.tscn")
var arrow_instance = null
var itemdata = preload("res://data/itemdata.tres")
enum States {
	IDLE,
	READY,
	AIMING,
	DODGE,
}
var state = States.READY
const base_hp = 100
export var hp = 100 setget _set_hp

func _ready() -> void:
	ride_anim.play("bob")
	if player_group == "P1":
		update_loadout(UserData.loadout)
	else:
		update_loadout(UserData.p2_loadout)

func reset_arms() -> void:
	bow_sprite.frame = 0
	arrow_sprite.frame = 0
	arms_sprite.frame = 0

func update_loadout(loadout_data: Dictionary) -> void:
	print(loadout_data)
	dodge_duration = base_dodge_duration
	dodge_range = base_dodge_range
	var start_hp = base_hp
	arrow_damage = base_arrow_damage
	arrow_mass = base_arrow_mass
	bow_elastic_force = base_bow_force
	bow_reload_time = base_reload_time
	if loadout_data.has("arrow"):
		arrow_type = loadout_data.arrow
		arrow_sprite.self_modulate = itemdata.colors[arrow_type]
		arrow_mass += itemdata.arrow_stats[arrow_type].mass
		arrow_damage += itemdata.arrow_stats[arrow_type].damage
		trajectory_draw.color = itemdata.colors[arrow_type]
	if loadout_data.has("bow"):
		bow_type = loadout_data.bow
		bow_sprite.self_modulate = itemdata.colors[bow_type]
		bow_elastic_force += itemdata.bow_stats[bow_type].force
		bow_reload_time += itemdata.bow_stats[bow_type].cooldown
		dodge_duration += itemdata.bow_stats[bow_type].weight
		reload_timer.wait_time = bow_reload_time
	if loadout_data.has("banner"):
		if loadout_data.banner < 0:
			banner_sprite.visible = false
		else:
			banner_sprite.self_modulate = itemdata.colors[loadout_data.banner]
			banner_sprite.visible = true
			dodge_range += itemdata.banner_stats[loadout_data.banner].range
			start_hp += itemdata.banner_stats[loadout_data.banner].hp
	if loadout_data.has("helm"):
		if loadout_data.helm < 0:
			hat_sprite.visible = false
		else:
			hat_sprite.self_modulate = itemdata.colors[loadout_data.helm]
			hat_sprite.visible = true
			start_hp += itemdata.helm_stats[loadout_data.helm].hp
			dodge_duration += itemdata.helm_stats[loadout_data.helm].weight
	_set_hp(start_hp)

func active_toggle(disable: bool) -> void:
	visible = disable
	hitbox.monitoring = disable
	pickupbox.monitoring = disable

func _set_hp(new_value: int) -> void:
	hp = int(clamp(new_value, 0, 999))
	emit_signal("hp_changed", hp)

func _input(event) -> void:
	if get_parent():
		if not get_parent().game_started or get_parent().game_over_screen.visible or get_parent().game_over_duel.visible:
			return
		elif get_parent().is_bots_turn:
			return
	if tween.is_active():
		return
	if state == States.READY:
		if event is InputEventScreenTouch:
			if event.is_pressed():
				bow_grab(event.position)
	elif state == States.AIMING:
		if event is InputEventScreenTouch:
			if not event.is_pressed():
				bow_release(event.position)
		if event is InputEventScreenDrag:
			bow_move(event.position)
	else:
		trajectory_draw.visible = false

func _physics_process(_delta):
	if reload_timer.time_left > 0:
		emit_signal("cooldown_update", reload_timer.time_left)
	match state:
		States.AIMING:
			if arrow_instance:
				launch_impulse = update_impulse()
				aiming_sprite.rotation = (draw_start - draw_end).angle()
				trajectory_draw.draw_trajectory(
					launch_impulse / arrow_mass,
					arrow_instance.head.global_position,
					gravity
				)

func update_impulse() -> Vector2:
	return clamp((draw_start-draw_end).length() * 10, 0, bow_elastic_force) * (draw_start - draw_end).normalized()

func load_projectile():
	state = States.AIMING
	if game_objects:
		arrow_instance = Arrow.instance()
		game_objects.add_child(arrow_instance)
		arrow_instance.sprite.modulate = itemdata.colors[arrow_type]
		arrow_instance.mass = arrow_mass
		arrow_instance.damage = arrow_damage
		arrow_instance.connect("landed", get_parent(), "_on_arrow_landed")
		arrow_instance.connect("arrow_accounted_for", get_parent(), "_on_arrow_accounted_for")
		arrow_instance.add_to_group(player_group)
		arrow_instance.position = position
		arrow_instance.reset_physics_interpolation()
		arrow_instance.visible = false
		anim.play("start_aiming")

func bow_grab(touch_position: Vector2) -> void:
	if state == States.IDLE:
		return
	print("start aiming at ", touch_position)
	if touch_position.y > 0 and touch_position.y < 40 and touch_position.x > 0 and touch_position.x < 80:
		print("back button position")
		return
	Audio.play_sound("res://assets/audio/sounds/arrows/536067__eminyildirim__bow-loading.wav")
	load_projectile()
	draw_start = touch_position
	draw_end = touch_position
	var force = clamp((draw_start-draw_end).length() * 10, 0, bow_elastic_force)
	emit_signal("update_draw", draw_start, draw_end, force)
	trajectory_draw.visible = UserData.aim_sight_on

func bow_move(touch_position: Vector2) -> void:
	if state == States.IDLE:
		return
	draw_end = touch_position
	state = States.AIMING
	var force = clamp((draw_start-draw_end).length() * 10, 0, bow_elastic_force)
	emit_signal("update_draw", draw_start, draw_end, force)

func remove_arrows() -> void:
	for node in hitbox.get_children():
		if node.is_in_group("to_remove"):
			hitbox.remove_child(node)
			node.queue_free()

func bow_release(touch_position: Vector2) -> void:
	if (draw_start-draw_end).length() < 20:
		arrow_instance = null
		state = States.READY
		draw_start = Vector2.ZERO
		draw_end = Vector2.ZERO
		var force = 0
		trajectory_draw.clear()
		trajectory_draw.visible = false
		aiming_sprite.rotation_degrees = 0
		anim.play_backwards("start_aiming")
		emit_signal("update_draw", draw_start, draw_end, force)
		return
	print("fire! at ", touch_position)
	draw_end = touch_position
	if arrow_instance:
		Audio.play_sound("res://assets/audio/sounds/arrows/536068__eminyildirim__bow-release-hit.wav")
		arrow_instance.visible = true
		arrow_instance.gravity = gravity * arrow_mass
		arrow_instance.fired = true
		arrow_instance.velocity = launch_impulse
		arrow_instance = null
		emit_signal("arrow_fired")
		anim.play("fire")
	draw_start = Vector2.ZERO
	draw_end = Vector2.ZERO
	var force = 0
	trajectory_draw.visible = false
	emit_signal("update_draw", draw_start, draw_end, force)
	state = States.IDLE
	if hunting_mode:
		reload_timer.start()
	else:
		state = States.DODGE

func _on_Timer_timeout() -> void:
	if hunting_mode and state == States.IDLE:
		state = States.READY

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(enemy_group):
		var fct = FCT.instance()
		get_parent().add_child(fct)
		fct.rect_position = area.global_position
		area.remove_from_group(enemy_group)
		area.stick_to(hitbox)
		_set_hp(hp - area.damage)
		fct.show_value(str(area.damage), Vector2(0,-8), 1, PI/2, false)

func _on_HeadHitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(enemy_group):
		var fct = FCT.instance()
		get_parent().add_child(fct)
		fct.rect_position = area.global_position
		fct.reset_physics_interpolation()
		area.remove_from_group(enemy_group)
		area.stick_to(hitbox)
		_set_hp(hp - 2*area.damage)
		fct.show_value(str(2*area.damage), Vector2(0,-8), 1, PI/2, true)

func _on_PickupBox_area_entered(area: Area2D) -> void:
	if area.is_in_group("prize"):
		print("prize collected")
		var fct = FCT.instance()
		get_parent().add_child(fct)
		fct.rect_position = global_position
		fct.reset_physics_interpolation()
		fct.show_value(str(area.coin_value), Vector2(0,-8), 1, PI/2, area.coin_value>30)
		emit_signal("increase_score", area.score_value)
		emit_signal("picked_up", area.coin_value)
		Audio.play_sound("res://assets/audio/sounds/coin_c_02-102844.mp3")
		area.picked_up()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "fire":
		aiming_sprite.rotation_degrees = 0

func start_dodging() -> void:
	tween.interpolate_property(self, "position:x",
		position.x, position.x + dodge_range * dodge_direction,
		dodge_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "position:x",
		position.x + dodge_range * dodge_direction, position.x,
		dodge_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, dodge_duration)
	tween.start()

func _on_Tween_tween_all_completed() -> void:
	if state == States.DODGE:
		start_dodging()
	else:
		emit_signal("dodge_finished")
