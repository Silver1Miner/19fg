extends AudioStreamPlayer

var tracks = [
	["heart", preload("res://assets/audio/music/chinese-peaceful-heartwarming-harp-asian-emotional-traditional-music-21041.mp3")],
]

func play_music(id: int) -> void:
	if id >= 0 and id < len(tracks):
		stream = tracks[id][1]
	else:
		stream = tracks[0][1]
	play()

var available = []
var queue = []
func _ready():
	AudioServer.set_bus_mute(1, UserData.mute_sound)
	AudioServer.set_bus_mute(2, UserData.mute_music)
	play_music(0)
	for i in 4:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_sound_finished", [p])
		p.bus = "Sound"

func _physics_process(_delta: float) -> void:
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

func _on_sound_finished(next_stream) -> void:
	available.append(next_stream)

func play_sound(sound_path: String) -> void:
	queue.append(sound_path)

func play_slide() -> void:
	play_sound("res://assets/audio/sounds/arrows/536068__eminyildirim__bow-release-hit.wav")
