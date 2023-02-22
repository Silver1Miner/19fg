extends Node

signal purchase_ready()
signal purchase_consumed(gems)
var android_iap = null
var ios_iap = null
var itemToken
var gem_value = 0
onready var ios_timer = $Timer

func _ready() -> void:
	# Android
	if Engine.has_singleton("GodotGooglePlayBilling"):
		android_iap = Engine.get_singleton("GodotGooglePlayBilling")
		android_iap.connect("connected", self, "_on_connected") # No params
		android_iap.connect("disconnected", self, "_on_disconnected") # No params
		android_iap.connect("connect_error", self, "_on_connect_error") # Response ID (int), Debug message (string)
		android_iap.connect("purchases_updated", self, "_on_purchases_updated") # Purchases (Dictionary[])
		android_iap.connect("purchase_error", self, "_on_purchase_error") # Response ID (int), Debug message (string)
		#android_iap.connect("sku_details_query_completed", self, "_on_sku_details_query_completed") # SKUs (Dictionary[])
		#android_iap.connect("sku_details_query_error", self, "_on_sku_details_query_error") # Response ID (int), Debug message (string), Queried SKUs (string[])
		android_iap.connect("purchase_acknowledged", self, "_on_purchase_acknowledged") # Purchase token (string)
		android_iap.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error") # Response ID (int), Debug message (string), Purchase token (string)
		android_iap.connect("purchase_consumed", self, "_on_purchase_consumed") # Purchase token (string)
		android_iap.connect("purchase_consumption_error", self, "_on_purchase_consumption_error") # Response ID (int), Debug message (string), Purchase token (string)
		android_iap.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")
	# iOS
	if Engine.has_singleton("InAppStore"):
		ios_iap = Engine.get_singleton("InAppStore")
		get_ios_iap_details()
	else:
		print("iOS IAP plugin not available on this platform")

# =======
# ANDROID
# =======

func _on_connected() -> void:
	android_iap.querySkuDetails(
		["gems_600_99",
		"gems_3150_499",
		"gems_6300_999",
		"gems_16500_1999",
		]
		, "inapp"
	)

func _on_sku_details_query_completed(sku_details):
	for available_sku in sku_details:
		print(available_sku)

func _on_sku_details_query_error(response_id, debug_message, queried_skus) -> void:
	print("response: ", str(response_id), " ", debug_message, queried_skus)

func android_purchase(index: int) -> void:
	if not android_iap:
		print("Android IAP not connected")
		return
	match index:
		0:
			var response = android_iap.purchase("gems_60_99")
			gem_value = 600
			print("purchase attempted with result: ", response.status)
			if response.status != OK:
				print("error purchasing item")
		1:
			var response = android_iap.purchase("gems_315_499")
			gem_value = 3150
			print("purchase attempted with result: ", response.status)
			if response.status != OK:
				print("error purchasing item")
		2:
			var response = android_iap.purchase("gems_630_999")
			gem_value = 6300
			print("purchase attempted with result: ", response.status)
			if response.status != OK:
				print("error purchasing item")
		3:
			var response = android_iap.purchase("gems_1650_1999")
			gem_value = 16500
			print("purchase attempted with result: ", response.status)
			if response.status != OK:
				print("error purchasing item")


func _on_purchases_updated(items) -> void:
	emit_signal("purchase_ready")
	for item in items:
		if item.purchase_state == 1:
			if !item.is_acknowledged:
				print("acknowledging purchases: ", item.purchase_token)
				android_iap.consumePurchase(item.purchase_token)
	if items.size() > 0:
		itemToken = items[items.size()-1].purchase_token
	consume_items()

func _on_purchase_acknowledged(token: String) -> void:
	print("purchase acknowledged with token: ", token)
	emit_signal("purchase_ready")

func _on_purchase_consumed(token: String) -> void:
	print("purchase consumed with token: ", token)
	emit_signal("purchase_consumed", gem_value)
	gem_value = 0

func consume_items() -> void:
	var query = android_iap.queryPurchases("inapp") # Or "subs" for subscriptions
	print(query)
	for purchase in query.purchases:
		if purchase.sku == "gems_60_99" and purchase.purchase_state == 1:
			emit_signal("purchase_consumed", 600)
			android_iap.consumePurchase(purchase.purchase_token)
		elif purchase.sku == "gems_315_499" and purchase.purchase_state == 1:
			emit_signal("purchase_consumed", 3150)
			android_iap.consumePurchase(purchase.purchase_token)
		elif purchase.sku == "gems_630_999" and purchase.purchase_state == 1:
			emit_signal("purchase_consumed", 6300)
			android_iap.consumePurchase(purchase.purchase_token)
		elif purchase.sku == "gems_1650_1999" and purchase.purchase_state == 1:
			emit_signal("purchase_consumed", 16500)
			android_iap.consumePurchase(purchase.purchase_token)

#=====
# IOS
#=====
func ios_purchase(index: int) -> void:
	if not ios_iap:
		print("iOS IAP not connected")
		return
	ios_iap.set_auto_finish_transaction(true)
	match index:
		0:
			var response = ios_iap.purchase({"product_id": "gems_60_99"})
			gem_value = 600
			print("purchase attempted with result: ", response)
			if response != OK:
				print("error purchasing item")
		1:
			var response = ios_iap.purchase({"product_id": "gems_315_499"})
			gem_value = 3150
			print("purchase attempted with result: ", response)
			if response != OK:
				print("error purchasing item")
		2:
			var response = ios_iap.purchase({"product_id": "gems_630_999"})
			gem_value = 6300
			print("purchase attempted with result: ", response)
			if response != OK:
				print("error purchasing item")
		3:
			var response = ios_iap.purchase({"product_id": "gems_1650_1999"})
			gem_value = 16500
			print("purchase attempted with result: ", response)
			if response != OK:
				print("error purchasing item")
	print("starting search timer")
	ios_timer.start(1)

func _on_Timer_timeout() -> void:
	print("searching for event")
	while ios_iap.get_pending_event_count() > 0:
		var event = ios_iap.pop_pending_event()
		print(event)
		if event.type == "purchase":
			if event.result == "ok":
				handle_purchase(event.product_id)
				ios_timer.stop()
			else:
				print("error handling purchase")

func handle_purchase(product_id) -> void:
	if product_id == "gems_60_99":
		emit_signal("purchase_consumed", 600)
	elif product_id == "gems_315_499":
		emit_signal("purchase_consumed", 3150)
	elif product_id == "gems_630_999":
		emit_signal("purchase_consumed", 6300)
	elif product_id == "gems_1650_1999":
		emit_signal("purchase_consumed", 16500)

func non_mobile_testing(gem_index: int) -> void:
	match gem_index:
		0:
			emit_signal("purchase_consumed", 600)
		1:
			emit_signal("purchase_consumed", 3150)
		2:
			emit_signal("purchase_consumed", 6300)
		3:
			emit_signal("purchase_consumed", 16500)

func get_ios_iap_details() -> void:
	var event = ios_iap.request_product_info(
		 { "product_ids":
			 ["gems_600_99",
			"gems_3150_499",
			"gems_6300_999",
			"gems_16500_1999",
			]
		})
	print(event)
