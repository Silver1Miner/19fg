extends ColorRect

onready var tutorial_toggle = $TutorialSettings/TutorialToggle
onready var about_panel = $AboutPanel
onready var privacy_panel = $AboutPanel/PrivacyPanel
var ready = false

func _ready() -> void:
	tutorial_toggle.pressed = UserData.tutorial_on
	about_panel.visible = false
	privacy_panel.visible = false
	ready = true

func _on_Back_button_up() -> void:
	visible = false

func _on_TutorialToggle_toggled(button_pressed: bool) -> void:
	if ready:
		Audio.play_sound("res://assets/audio/sounds/arrows/559233__bl31gt0__breath_kick.wav")
	UserData.tutorial_on = button_pressed

func _on_About_toggled(button_pressed: bool) -> void:
	about_panel.visible = button_pressed

func _on_Privacy_toggled(button_pressed: bool) -> void:
	privacy_panel.visible = button_pressed
	if button_pressed:
		if OS.shell_open(UserData.privacy_policy_link) != OK:
			push_error("fail to open link")

