extends Area2D
class_name Target

var shot = false
onready var body = $CollisionShape2D
onready var anim = $AnimationPlayer
export var mass = 0.1
export var speed = 50
export var score_value = 200
export var direction = Vector2.RIGHT

func _ready() -> void:
	add_to_group("prize")
	anim.play("flap")

func _physics_process(delta: float) -> void:
	if body.global_position.x < -80 or body.global_position.x > 640 + 80:
		print("target out of range")
		queue_free()
	if body.global_position.y > 330:
		gravity = 0
		direction = Vector2.LEFT
		shot = false
	global_position += direction * speed * delta
	if direction.y != 0:
		rotation = direction.angle()
	if shot:
		direction.y += gravity * mass * delta

func _on_Target_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow"):
		area.remove_from_group("arrow")
		anim.stop()
		var impulse = area.velocity.normalized()
		direction += Vector2(impulse.x, impulse.y * 5)
		area.stick_to(self)
		shot = true
