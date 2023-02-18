extends Camera2D

signal camera_ready()
onready var anim = $AnimationPlayer

func _ready() -> void:
	pass # Replace with function body.

func to_duel_view() -> void:
	anim.play("to_duel_view")

func to_normal_view() -> void:
	anim.play_backwards("to_duel_view")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "to_duel_view" or anim_name == "to_normal_view":
		emit_signal("camera_ready")
