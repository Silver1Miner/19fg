extends VBoxContainer

onready var sound_toggle = $Sound/SoundToggle
onready var sound_toggle_2 = $Sound/SoundToggle2
onready var music_toggle = $Music/MusicToggle
onready var music_toggle_2 = $Music/MusicToggle2
var ready = false

func _ready() -> void:
	sound_toggle.pressed = UserData.mute_sound
	music_toggle.pressed = UserData.mute_music
	ready = true

func _on_SoundToggle_toggled(button_pressed: bool) -> void:
	sound_toggle_2.pressed = !button_pressed
	AudioServer.set_bus_mute(1, button_pressed)
	UserData.mute_sound = button_pressed
	if ready:
		Audio.play_sound("res://assets/audio/sounds/switch_004.ogg")

func _on_SoundToggle2_toggled(button_pressed: bool) -> void:
	sound_toggle.pressed = !button_pressed

func _on_MusicToggle_toggled(button_pressed: bool) -> void:
	music_toggle_2.pressed = !button_pressed
	AudioServer.set_bus_mute(2, button_pressed)
	UserData.mute_music = button_pressed
	if ready:
		Audio.play_sound("res://assets/audio/sounds/switch_004.ogg")

func _on_MusicToggle2_toggled(button_pressed: bool) -> void:
	music_toggle.pressed = !button_pressed
