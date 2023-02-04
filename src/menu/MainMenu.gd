extends Control

var current_pane = 1
onready var tween = $Tween
onready var panes = $Panels

func _ready() -> void:
	pass
	#change_panel(1)

func change_panel(select: int) -> void:
	current_pane = select
	if tween:
		Audio.play_slide()
		tween.interpolate_property(panes, "rect_position:x",
		rect_position.x, (current_pane - 1) * 640, 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()
