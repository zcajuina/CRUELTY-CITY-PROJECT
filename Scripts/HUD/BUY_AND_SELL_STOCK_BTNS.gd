extends HBoxContainer
@onready var stock_market: Control = $"../.."


func _on_buy_button_pressed() -> void:
	stock_market._global_buy_function(1)
	

func _on_buy_5_button_pressed() -> void:
	stock_market._global_buy_function(5)

func _on_buy_10_button_pressed() -> void:
	stock_market._global_buy_function(10)

func _on_buy_100_button_pressed() -> void:
	stock_market._global_buy_function(100)


func _on_sell_button_pressed() -> void:
	stock_market._global_sell_function(1)


func _on_sell_5_button_pressed() -> void:
	stock_market._global_sell_function(5)


func _on_sell_10_button_pressed() -> void:
	stock_market._global_sell_function(10)


func _on_sell_100_button_pressed() -> void:
	stock_market._global_sell_function(100)
