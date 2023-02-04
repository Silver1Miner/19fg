class_name Arrow
extends RigidBody2D

func _ready() -> void:
	gravity_scale = 0

func _physics_process(_delta: float) -> void:
	rotation = linear_velocity.angle()
