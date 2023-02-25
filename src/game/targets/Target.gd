extends Area2D
class_name Target

signal shot()
signal shot_score(score_value)
var is_shot = false
export var pickup = true
export var takes_impulse = true
onready var body = $CollisionShape2D
onready var anim = $AnimationPlayer
export var coin_value = 10
export var mass = 0.1
export var speed = 200
export var ground_speed = 200
export var score_value = 200
export var direction = Vector2.RIGHT
export var animation_name = "flap"

func _ready() -> void:
	if pickup:
		add_to_group("prize")
	anim.play(animation_name)

func _physics_process(delta: float) -> void:
	if body.global_position.x < -160 or body.global_position.x > 640 + 1280:
		if is_shot:
			#emit_signal("out_of_range")
			return
		else:
			queue_free()
	if body.global_position.y > 330:
		gravity = 0
		direction = Vector2.LEFT
		speed = ground_speed
	global_position += direction * speed * delta
	if direction.y != 0:
		rotation = direction.angle()
	if is_shot and gravity > 0:
		direction.y += gravity * mass * delta

func _on_Target_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow") and area.fired:
		if area.velocity.y > 0:
			emit_signal("shot_score", 200)
		else:
			emit_signal("shot_score", 50)
		emit_signal("shot")
		area.remove_from_group("arrow")
		anim.stop()
		speed = ground_speed
		if takes_impulse:
			var impulse = area.velocity.normalized()
			direction += Vector2(impulse.x, impulse.y)
		area.stick_to(self)
		is_shot = true

func picked_up() -> void:
	queue_free()
