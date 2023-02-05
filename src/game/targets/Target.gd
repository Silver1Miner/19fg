extends Area2D
class_name Target

var shot = false
onready var body = $CollisionShape2D
export var mass = 10.0
export var velocity = Vector2.RIGHT * 100

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if body.global_position.y > 330:
		gravity = 0
		velocity = Vector2.ZERO
		shot = false
	position += velocity * delta
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
	if shot:
		velocity.y += gravity * mass * delta

func _on_Target_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow"):
		area.remove_from_group("arrow")
		area.fired = false
		area.get_parent().remove_child(area)
		call_deferred("add_child",area)
		shot = true
