extends Area2D
class_name Target

signal shot()
signal out_of_range()
var is_shot = false
export var pickup = true
export var takes_impulse = true
onready var body = $CollisionShape2D
onready var anim = $AnimationPlayer
export var mass = 0.1
export var speed = 50
export var score_value = 200
export var direction = Vector2.RIGHT
export var animation_name = "flap"

func _ready() -> void:
	if pickup:
		add_to_group("prize")
	anim.play(animation_name)

func _physics_process(delta: float) -> void:
	if body.global_position.x < -160 or body.global_position.x > 640 + 640:
		print("target out of range")
		if is_shot:
			emit_signal("out_of_range")
		queue_free()
	if body.global_position.y > 330:
		gravity = 0
		direction = Vector2.LEFT
	global_position += direction * speed * delta
	if direction.y != 0:
		rotation = direction.angle()
	if is_shot and gravity > 0:
		direction.y += gravity * mass * delta

func _on_Target_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow") and area.fired:
		area.remove_from_group("arrow")
		anim.stop()
		if takes_impulse:
			var impulse = area.velocity.normalized()
			direction += Vector2(impulse.x, impulse.y * 5)
		area.stick_to(self)
		is_shot = true
		emit_signal("shot")

func picked_up() -> void:
	emit_signal("out_of_range")
	queue_free()
