extends HBoxContainer

func update_arrow_display(new_value: int) -> void:
	if new_value < 9999:
		$ArrowCount.text = str(new_value)
	else:
		# warning-ignore:integer_division
		$ArrowCount.text = str(new_value/1000) + "k"

func update_coins_display(new_value: int) -> void:
	if new_value < 9999:
		$CoinsCount.text = str(new_value)
	else:
		# warning-ignore:integer_division
		$CoinsCount.text = str(new_value/1000) + "k"
