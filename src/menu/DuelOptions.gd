extends ColorRect

signal closed_duel()
signal duel_start()
onready var p1bow = $Players/Player1/Bow1
onready var p2bow = $Players/Player2/Bow2
onready var p1arrow = $Players/Player1/Arrow1
onready var p2arrow = $Players/Player2/Arrow2
onready var p1banner = $Players/Player1/Banner1
onready var p2banner = $Players/Player2/Banner2
onready var p1hat = $Players/Player1/Hat1
onready var p2hat = $Players/Player2/Hat2
var bow_indices = []
var arrow_indices = []
var banner_indices = []
var hat_indices = []
var itemdata = preload("res://data/itemdata.tres")

func _on_DuelCancel_pressed() -> void:
	emit_signal("closed_duel")

func _on_Start_pressed() -> void:
	UserData.save_inventory()
	emit_signal("closed_duel")
	emit_signal("duel_start")

func update_option_buttons() -> void:
	p1bow.clear()
	p2bow.clear()
	bow_indices.clear()
	var j = -1
	for i in len(UserData.inventory.bow):
		if UserData.inventory.bow[i] > 0:
			bow_indices.append(i)
			p1bow.add_item(itemdata.bow_stats[i].name)
			p2bow.add_item(itemdata.bow_stats[i].name)
			j += 1
		if i == UserData.loadout.bow:
			p1bow.select(j)
		if i == UserData.p2_loadout.bow:
			p2bow.select(j)
	j = -1
	p1arrow.clear()
	p2arrow.clear()
	arrow_indices.clear()
	for i in len(UserData.inventory.arrow):
		if UserData.inventory.arrow[i] > 0:
			arrow_indices.append(i)
			p1arrow.add_item(itemdata.arrow_stats[i].name)
			p2arrow.add_item(itemdata.arrow_stats[i].name)
			j += 1
		if i == UserData.loadout.arrow:
			p1arrow.select(j)
		if i == UserData.p2_loadout.arrow:
			p2arrow.select(j)
	j = -1
	p1banner.clear()
	p2banner.clear()
	banner_indices.clear()
	for i in len(UserData.inventory.banner):
		if UserData.inventory.banner[i] > 0:
			banner_indices.append(i)
			p1banner.add_item(itemdata.banner_stats[i].name)
			p2banner.add_item(itemdata.banner_stats[i].name)
			j += 1
		if i == UserData.loadout.banner:
			p1banner.select(j)
		if i == UserData.p2_loadout.banner:
			p2banner.select(j)
	banner_indices.append(-1)
	p1banner.add_item("No Banner")
	p2banner.add_item("No Banner")
	j += 1
	if UserData.loadout.banner == -1:
		p1banner.select(j)
	if UserData.p2_loadout.banner == -1:
		p2banner.select(j)
	j = -1
	p1hat.clear()
	p2hat.clear()
	hat_indices.clear()
	for i in len(UserData.inventory.helm):
		if UserData.inventory.helm[i] > 0:
			hat_indices.append(i)
			p1hat.add_item(itemdata.helm_stats[i].name)
			p2hat.add_item(itemdata.helm_stats[i].name)
			j += 1
		if i == UserData.loadout.helm:
			p1hat.select(j)
		if i == UserData.p2_loadout.helm:
			p2hat.select(j)
	hat_indices.append(-1)
	p1hat.add_item("No Cap")
	p2hat.add_item("No Cap")
	j += 1
	if UserData.loadout.helm == -1:
		p1hat.select(j)
	if UserData.p2_loadout.helm == -1:
		p2hat.select(j)

func _on_Bow1_item_selected(index: int) -> void:
	if index < len(bow_indices):
		UserData.loadout.bow = bow_indices[index]

func _on_Arrow1_item_selected(index: int) -> void:
	if index < len(arrow_indices):
		UserData.loadout.arrow = arrow_indices[index]

func _on_Banner1_item_selected(index: int) -> void:
	if index < 5 and index < len(banner_indices):
		UserData.loadout.banner = banner_indices[index]
	else:
		UserData.loadout.banner = -1

func _on_Hat1_item_selected(index: int) -> void:
	if index < 5 and index < len(hat_indices):
		UserData.loadout.helm = hat_indices[index]
	else:
		UserData.loadout.helm = -1

func _on_Bow2_item_selected(index: int) -> void:
	if index < len(bow_indices):
		UserData.p2_loadout.bow = bow_indices[index]

func _on_Arrow2_item_selected(index: int) -> void:
	if index < len(arrow_indices):
		UserData.p2_loadout.arrow = arrow_indices[index]

func _on_Banner2_item_selected(index: int) -> void:
	if index < 5 and index < len(banner_indices):
		UserData.p2_loadout.banner = banner_indices[index]
	else:
		UserData.p2_loadout.banner = -1

func _on_Hat2_item_selected(index: int) -> void:
	if index < 5 and index < len(hat_indices):
		UserData.p2_loadout.helm = hat_indices[index]
	else:
		UserData.p2_loadout.helm = -1
