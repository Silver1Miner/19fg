extends VBoxContainer

signal request_purchase(item_type, item_index)
signal request_equip(item_type, item_index)
var itemdata = preload("res://data/itemdata.tres")
onready var bow0 = $BowUnlocks/Bow0/Label
onready var bow1 = $BowUnlocks/Bow1/Label
onready var bow2 = $BowUnlocks/Bow2/Label
onready var bow3 = $BowUnlocks/Bow3/Label
onready var bow4 = $BowUnlocks/Bow4/Label
onready var arrow0 = $BowUnlocks/Arrow0/Label
onready var arrow1 = $BowUnlocks/Arrow1/Label
onready var arrow2 = $BowUnlocks/Arrow2/Label
onready var arrow3 = $BowUnlocks/Arrow3/Label
onready var arrow4 = $BowUnlocks/Arrow4/Label
onready var banner0 = $BannerTypes/Banner0/Label
onready var banner1 = $BannerTypes/Banner1/Label
onready var banner2 = $BannerTypes/Banner2/Label
onready var banner3 = $BannerTypes/Banner3/Label
onready var banner4 = $BannerTypes/Banner4/Label
onready var helm0 = $BannerTypes/Helm0/Label
onready var helm1 = $BannerTypes/Helm1/Label
onready var helm2 = $BannerTypes/Helm2/Label
onready var helm3 = $BannerTypes/Helm3/Label
onready var helm4 = $BannerTypes/Helm4/Label

func _ready() -> void:
	update_bows_display()
	update_banners_display()

func update_bows_display() -> void:
	bow0.text = "Black Bow\nEquip"
	arrow1.text = "Black Arrows\nEquip"
	if UserData.inventory.bow[1] > 0:
		bow1.text = "White Bow\nEquip"
	else:
		bow1.text = "White Bow\nBuy for %s" % itemdata.bow_stats[1].cost
	if UserData.inventory.bow[2] > 0:
		bow2.text = "Blue Bow\nEquip"
	else:
		bow2.text = "Blue Bow\nBuy for %s" % itemdata.bow_stats[2].cost
	if UserData.inventory.bow[3] > 0:
		bow3.text = "Yellow Bow\nEquip"
	else:
		bow3.text = "Yellow Bow\nBuy for %s" % itemdata.bow_stats[3].cost
	if UserData.inventory.bow[4] > 0:
		bow4.text = "Red Bow\nEquip"
	else:
		bow4.text = "Red Bow\nBuy for %s" % itemdata.bow_stats[4].cost
	if UserData.inventory.arrow[1] > 0:
		arrow1.text = "White Arrow\nEquip"
	else:
		arrow1.text = "White Bow\nBuy for %s" % itemdata.arrow_stats[1].cost
	if UserData.inventory.arrow[2] > 0:
		arrow2.text = "Blue Arrow\nEquip"
	else:
		arrow2.text = "Blue Arrow\nBuy for %s" % itemdata.arrow_stats[2].cost
	if UserData.inventory.arrow[3] > 0:
		arrow3.text = "Yellow Arrow\nEquip"
	else:
		arrow3.text = "Yellow Arrow\nBuy for %s" % itemdata.arrow_stats[3].cost
	if UserData.inventory.arrow[4] > 0:
		arrow4.text = "Red Arrow\nEquip"
	else:
		arrow4.text = "Red Arrow\nBuy for %s" % itemdata.arrow_stats[4].cost


func update_banners_display() -> void:
	if UserData.inventory.banner[0] > 0:
		banner0.text = "Black Banner\nEquip"
	else:
		banner0.text = "Black Banner\nBuy for %s" % itemdata.banner_stats[1].cost
	if UserData.inventory.banner[1] > 0:
		banner1.text = "White Banner\nEquip"
	else:
		banner1.text = "White Banner\nBuy for %s" % itemdata.banner_stats[1].cost
	if UserData.inventory.banner[2] > 0:
		banner2.text = "Blue Banner\nEquip"
	else:
		banner2.text = "Blue Banner\nBuy for %s" % itemdata.banner_stats[2].cost
	if UserData.inventory.banner[3] > 0:
		banner3.text = "Yellow Banner\nEquip"
	else:
		banner3.text = "Yellow Banner\nBuy for %s" % itemdata.banner_stats[3].cost
	if UserData.inventory.banner[4] > 0:
		banner4.text = "Red Banner\nEquip"
	else:
		banner4.text = "Red Banner\nBuy for %s" % itemdata.banner_stats[4].cost
	if UserData.inventory.helm[0] > 0:
		helm0.text = "Black Cap\nEquip"
	else:
		helm0.text = "Black Cap\nBuy for %s" % itemdata.helm_stats[1].cost
	if UserData.inventory.helm[1] > 0:
		helm1.text = "White Cap\nEquip"
	else:
		helm1.text = "White Cap\nBuy for %s" % itemdata.helm_stats[1].cost
	if UserData.inventory.helm[2] > 0:
		helm2.text = "Blue Cap\nEquip"
	else:
		helm2.text = "Blue Cap\nBuy for %s" % itemdata.helm_stats[2].cost
	if UserData.inventory.helm[3] > 0:
		helm3.text = "Yellow Cap\nEquip"
	else:
		helm3.text = "Yellow Cap\nBuy for %s" % itemdata.helm_stats[3].cost
	if UserData.inventory.helm[4] > 0:
		helm4.text = "Red Cap\nEquip"
	else:
		helm4.text = "Red Cap\nBuy for %s" % itemdata.helm_stats[4].cost

func handle_bow(index: int) -> void:
	if UserData.inventory.bow[index] > 0:
		UserData.loadout.bow = index
		emit_signal("request_equip", 0, index)
	else:
		emit_signal("request_purchase", 0, index)

func handle_arrow(index: int) -> void:
	if UserData.inventory.arrow[index] > 0:
		UserData.loadout.arrow = index
		emit_signal("request_equip", 1, index)
	else:
		emit_signal("request_purchase", 1, index)

func handle_banner(index: int) -> void:
	if UserData.inventory.banner[index] > 0:
		emit_signal("request_equip", 2, index)
	else:
		emit_signal("request_purchase", 2, index)

func handle_helm(index: int) -> void:
	if UserData.inventory.helm[index] > 0:
		emit_signal("request_equip", 3, index)
	else:
		emit_signal("request_purchase", 3, index)


func _on_Bow0_pressed() -> void:
	handle_bow(0)

func _on_Arrow0_pressed() -> void:
	handle_arrow(0)

func _on_Bow1_pressed() -> void:
	handle_bow(1)

func _on_Arrow1_pressed() -> void:
	handle_arrow(1)

func _on_Bow2_pressed() -> void:
	handle_bow(2)

func _on_Arrow2_pressed() -> void:
	handle_arrow(2)

func _on_Bow3_pressed() -> void:
	handle_bow(3)

func _on_Arrow3_pressed() -> void:
	handle_arrow(3)

func _on_Arrow4_pressed() -> void:
	handle_arrow(4)

func _on_Bow4_pressed() -> void:
	handle_bow(4)

func _on_Banner0_pressed() -> void:
	handle_banner(0)

func _on_Helm0_pressed() -> void:
	handle_helm(0)

func _on_Banner1_pressed() -> void:
	handle_banner(1)

func _on_Helm1_pressed() -> void:
	handle_helm(1)

func _on_Banner2_pressed() -> void:
	handle_banner(2)

func _on_Helm2_pressed() -> void:
	handle_helm(2)

func _on_Banner3_pressed() -> void:
	handle_banner(3)

func _on_Helm3_pressed() -> void:
	handle_helm(3)

func _on_Banner4_pressed() -> void:
	handle_banner(4)

func _on_Helm4_pressed() -> void:
	handle_helm(4)

func _on_BannerNo_pressed() -> void:
	emit_signal("request_equip", 2, -1)

func _on_HelmNo_pressed() -> void:
	emit_signal("request_equip", 3, -1)
