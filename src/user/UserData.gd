extends Node

const privacy_policy_link = "https://itch.io/t/2660829/privacy-policy"
const copyright_text = """v 1.0.1.27 -- February 27, 2023
Copyright © 2023 Jack Anderson"""
# GAME MODE
var current_game_mode = 0
var duel_vs_bot = false
var is_extra_hunt = false
# SETTINGS
var mute_music = false
var mute_sound = false
var tutorial_on = true
var aim_sight_on = true
# RECORDS
var current_year_loaded = 0
var current_month_loaded = 0
var current_loaded = {}
# INVENTORY
var owned_tracks = 1
var arrows = 10 setget set_arrows
var gems = 0 setget set_gems
const max_gems = 999999
const max_arrows = 999999
var inventory = {
	"arrow": [1, 0, 0, 0, 0],
	"bow": [1, 0, 0, 0, 0],
	"banner": [0, 0, 0, 0, 0],
	"helm": [0, 0, 0, 0, 0],
}
var loadout = {
	"arrow": 0,
	"bow": 0,
	"banner": -1,
	"helm": -1,
}
var p2_loadout = {
	"arrow": 0,
	"bow": 0,
	"banner": -1,
	"helm": -1,
}

func _ready() -> void:
	load_settings()
	load_inventory()

func save_settings() -> void:
	print("attempting to save settings")
	var settings = File.new()
	settings.open("user://settings.save", File.WRITE)
	var settings_dict = {
		"mute_music": mute_music,
		"mute_sound": mute_sound,
		"tutorial_on": tutorial_on,
		"aim_sight_on": aim_sight_on,
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
		if sd.has("tutorial_on"):
			tutorial_on = bool(sd.tutorial_on)
		if sd.has("aim_sight_on"):
			aim_sight_on = bool(sd.aim_sight_on)
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

func save_today(minutes: int, seconds: int, shots: int, hits: int, score: int, pay: int) -> void:
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])
	var day = OS.get_date()["day"]
	if current_loaded.has(day):
		print("a record was already saved for this day; overwriting it")
	current_loaded[day] = {
		"shots": shots,
		"hits": hits,
		"score": score,
		"minutes": minutes,
		"seconds": seconds,
		"pay": pay
	}
	#set_arrows(arrows + 10 - shots)
	set_gems(gems + pay)
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])

func set_gems(new_value: int) -> void:
	gems = int(clamp(new_value, 0, max_gems))
	save_inventory()

func set_arrows(new_value: int) -> void:
	arrows = int(clamp(new_value, 0, max_arrows))
	save_inventory()

func save_inventory() -> void:
	var save = File.new()
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists("user://records/"):
		dir.make_dir("user://records/")
	save.open("user://records/inventory.save", File.WRITE)
	var inv_dict = {
		"owned_tracks": owned_tracks,
		"arrows": arrows,
		"gems": gems,
		"inventory": inventory.duplicate(true),
		"loadout": loadout.duplicate(true),
		"p2_loadout": p2_loadout.duplicate(true)
	}
	save.store_line(to_json(inv_dict))
	save.close()

func load_inventory() -> void:
	print("attempting to load iventory")
	var save_dir = "user://records/inventory.save"
	var save = File.new()
	if not save.file_exists(save_dir):
		print("no inventory save found")
		return
	save.open(save_dir, File.READ)
	var invd = parse_json(save.get_line())
	print(invd)
	if typeof(invd) == TYPE_DICTIONARY:
		if invd.has("owned_tracks"):
			owned_tracks = int(invd.owned_tracks)
		if invd.has("arrows"):
			arrows = int(invd.arrows)
		if invd.has("gems"):
			gems = int(invd.gems)
		if invd.has("inventory"):
			inventory = invd.inventory.duplicate(true)
		if invd.has("loadout"):
			loadout = invd.loadout.duplicate(true)
		if invd.has("p2_loadout"):
			p2_loadout = invd.p2_loadout.duplicate(true)
	save.close()
