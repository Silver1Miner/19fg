extends ColorRect

onready var tutorial_toggle = $TutorialSettings/TutorialToggle
onready var aim_toggle = $AimSettings/AimToggle
onready var about_panel = $AboutPanel
onready var privacy_panel = $AboutPanel/PrivacyPanel
onready var copyright_label = $AboutPanel/Copyright
var ready = false

func _ready() -> void:
	tutorial_toggle.pressed = UserData.tutorial_on
	aim_toggle.pressed = UserData.aim_sight_on
	copyright_label.text = UserData.copyright_text
	about_panel.visible = false
	privacy_panel.visible = false
	ready = true

func _on_Back_button_up() -> void:
	visible = false

func _on_TutorialToggle_toggled(button_pressed: bool) -> void:
	if ready:
		Audio.play_sound("res://assets/audio/sounds/arrows/559233__bl31gt0__breath_kick.wav")
	UserData.tutorial_on = button_pressed
	UserData.save_settings()

func _on_AimToggle_toggled(button_pressed: bool) -> void:
	if ready:
		Audio.play_sound("res://assets/audio/sounds/arrows/559233__bl31gt0__breath_kick.wav")
	UserData.aim_sight_on = button_pressed
	UserData.save_settings()

func _on_Back_pressed() -> void:
	privacy_panel.visible = false
	about_panel.visible = false

func _on_About_pressed() -> void:
	privacy_panel.visible = false
	about_panel.visible = true

func _on_FullRead_pressed() -> void:
	if OS.shell_open(UserData.privacy_policy_link) != OK:
		push_error("fail to open link")

func _on_ClosePrivacy_pressed() -> void:
	privacy_panel.visible = false

func _on_Privacy_pressed() -> void:
	privacy_panel.visible = true
