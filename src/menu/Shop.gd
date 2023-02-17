extends Control

signal back()
signal loadout_changed()
onready var inventory_display = $Inventory
onready var confirm_panel = $ConfirmPanel
onready var confirm_preview = $ConfirmPanel/Preview
onready var confirm_descrption = $ConfirmPanel/Description
onready var confirm_purchase = $ConfirmPanel/Options/Purchase
onready var confirm_equip = $ConfirmPanel/Options/Equip
var itemdata = preload("res://data/itemdata.tres")
var current_item_type = 0
var current_item_index = 0
var arrows = 0
var coins = 0

func _ready() -> void:
	confirm_panel.visible = false
	set_arrows(UserData.arrows)
	set_coins(UserData.gems)
	if not OS.get_name() in ["Android", "iOS"]:
		$ShopPanel/TabContainer/Coins.queue_free()

func set_arrows(new_value: int) -> void:
	arrows = new_value
	inventory_display.update_arrow_display(arrows)

func set_coins(new_value: int) -> void:
	coins = new_value
	inventory_display.update_coins_display(coins)

func _on_Back_button_up() -> void:
	emit_signal("back")

func _on_BuyTip_button_up() -> void:
	attempt_cash_purchase(0)

func _on_BuyGems1_button_up() -> void:
	attempt_cash_purchase(1)

func _on_BuyGems2_button_up() -> void:
	attempt_cash_purchase(2)

func _on_BuyGems3_button_up() -> void:
	attempt_cash_purchase(3)

func attempt_cash_purchase(index: int) -> void:
	if Billing.android_iap:
		print("attempting purchase via android")
		Billing.android_purchase(index)
	elif Billing.ios_iap:
		print("attempting purchase via iOS")
		Billing.ios_purchase(index)
	else:
		print("no shop connected")
		if not OS.get_name() in ["Android", "iOS"]:
			Billing.non_mobile_testing(index)

func _on_BuyBonusArrows1_pressed() -> void:
	current_item_type = 4
	current_item_index = 1
	confirm_preview.texture = preload("res://assets/gui/icons/arrows.png")
	confirm_equip.visible = false
	confirm_purchase.visible = true
	confirm_descrption.text = ""
	confirm_purchase.disabled = coins < 160

func _on_BuyBonusArrows2_pressed() -> void:
	current_item_type = 4
	current_item_index = 2
	confirm_preview.texture = preload("res://assets/gui/icons/arrows.png")
	confirm_equip.visible = false
	confirm_purchase.visible = true
	confirm_descrption.text = ""
	confirm_purchase.disabled = coins < 1600

func _on_LoadoutOptions_request_purchase(item_type: int, item_index: int) -> void:
	print(item_type, " item index: ", item_index)
	current_item_type = item_type
	current_item_index = item_index
	confirm_purchase.visible = true
	confirm_equip.visible = false
	match item_type:
		0:
			confirm_purchase.disabled = coins < itemdata.bow_stats[item_index].cost
			confirm_descrption.text = itemdata.bow_stats[item_index].description
		1:
			confirm_purchase.disabled = coins < itemdata.arrow_stats[item_index].cost
			confirm_descrption.text = itemdata.arrow_stats[item_index].description
		2:
			confirm_purchase.disabled = coins < itemdata.banner_stats[item_index].cost
			confirm_descrption.text = itemdata.banner_stats[item_index].description
		3:
			confirm_purchase.disabled = coins < itemdata.helm_stats[item_index].cost
			confirm_descrption.text = itemdata.helm_stats[item_index].description
	confirm_preview.self_modulate = itemdata.colors[item_index]
	confirm_panel.visible = true

func _on_LoadoutOptions_request_equip(item_type, item_index) -> void:
	print(item_type, " item index: ", item_index)
	current_item_type = item_type
	current_item_index = item_index
	confirm_purchase.visible = false
	confirm_equip.visible = true
	match item_type:
		0:
			confirm_descrption.text = itemdata.bow_stats[item_index].description
		1:
			confirm_descrption.text = itemdata.arrow_stats[item_index].description
		2:
			confirm_descrption.text = itemdata.banner_stats[item_index].description
		3:
			confirm_descrption.text = itemdata.helm_stats[item_index].description
	confirm_preview.self_modulate = itemdata.colors[item_index]
	confirm_panel.visible = true

func change_loadout(item_type: int, item_index: int) -> void:
	match item_type:
		0:
			UserData.loadout.bow = item_index
		1:
			UserData.loadout.arrow = item_index
		2:
			UserData.loadout.banner = item_index
		3:
			UserData.loadout.helm = item_index
	emit_signal("loadout_changed")

func _on_Cancel_pressed() -> void:
	confirm_panel.visible = false

func _on_Equip_pressed() -> void:
	if current_item_type >= 0 and current_item_type < 4:
		change_loadout(current_item_type, current_item_index)
	confirm_panel.visible = false

func _on_Purchase_pressed() -> void:
	if current_item_type == 4:
		match current_item_index:
			1:
				pass
			2:
				pass
	else:
		pass
	confirm_panel.visible = false
