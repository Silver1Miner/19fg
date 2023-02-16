extends Control

signal back()
onready var anim = $AnimationPlayer

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
	if anim.is_playing():
		return
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
	pass # Replace with function body.

func _on_BuyBonusArrows2_pressed() -> void:
	pass # Replace with function body.
