extends Node

const privacy_policy_link = "https://itch.io/t/2578167/privacy-policy"
var current_game_mode = 0
var arrows_brought = 10
# SETTINGS
var jukebox_index = 0
var mute_music = false
var mute_sound = false
var tutorial_on = true
# RECORDS
var current_year_loaded = 0
var current_month_loaded = 0
var current_loaded = {}
# INVENTORY
var owned_tracks = 1
var owned_arrows = 0
var gems = 0

var tracks = [
	["A Cozy Day", preload("res://assets/audio/music/a-cozy-day-114852.mp3")],
	["Dreamy", preload("res://assets/audio/music/dreamy-114855.mp3")],
]

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	print("attempting to save settings")
	var settings = File.new()
	settings.open("user://settings.save", File.WRITE)
	var settings_dict = {
		"mute_music": mute_music,
		"mute_sound": mute_sound,
	}
	print(settings_dict)
	settings.store_line(to_json(settings_dict))
	settings.close()

func load_settings() -> void:
	print("attemting to load settings")
	var settings = File.new()
	if not settings.file_exists("user://settings.save"):
		print("no settings file found")
		return
	settings.open("user://settings.save", File.READ)
	var sd = parse_json(settings.get_line())
	if sd != null:
		if sd.has("mute_music"):
			mute_music = bool(sd.mute_music)
		if sd.has("mute_sound"):
			mute_sound = bool(sd.mute_sound)
	settings.close()

func change_records_loaded(new_year: int, new_month: int) -> void:
	if len(current_loaded) > 0:
		save_to_records(current_year_loaded, current_month_loaded)
	current_year_loaded = new_year
	current_month_loaded = new_month
	load_from_records(current_year_loaded, current_month_loaded)

func save_to_records(year: int, month: int) -> void:
	#print("attempting to save records from year ", year, " month ", month)
	var dir = Directory.new()
	if not dir.dir_exists("user://records/"):
		dir.make_dir("user://records/")
	if not dir.dir_exists("user://records/" + str(year) + "/"):
		dir.make_dir("user://records/" + str(year) + "/")
	if not dir.dir_exists("user://records/" + str(year) + "/" + str(month) + "/"):
		dir.make_dir("user://records/" + str(year) + "/" + str(month) + "/")
	var d = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	records.open(d, File.WRITE)
	var records_dict = current_loaded.duplicate(true)
	records.store_line(to_json(records_dict))
	records.close()

func load_from_records(year: int, month: int) -> void:
	#print("attemting to load records from year: ", year, " month ", month)
	var d = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	if not records.file_exists(d):
		print("no records file found for year ", year, " month ", month)
		current_loaded = {}
		return
	records.open(d, File.READ)
	var sd = parse_json(records.get_line())
	if sd:
		current_loaded = sd.duplicate(true)
	else:
		current_loaded = {}
	records.close()

func has_record(year: int, month: int, day: int) -> bool:
	change_records_loaded(year, month)
	return str(day) in current_loaded

func save_today(seconds: int, minutes: int, shots_fired: int, quarry_bagged: int, points: int) -> void:
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])
	var day = OS.get_date()["day"]
	if current_loaded.has(day):
		push_error("a record was already saved for this day; overwriting")
	current_loaded[day] = {
		"shots_fired": shots_fired,
		"quarry_bagged": quarry_bagged,
		"points": points,
		"minutes": minutes,
		"seconds": seconds
	}
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])

