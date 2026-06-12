extends Node
var stocks_save_path = Global.saves_folder_path + "stocks_save.zcj"

var list_of_organs : Array = []
var last_organ_obtained : String
var stock_menu : Control

var offset

signal organ_obtained

#region Organs and Stocks Dictionary
var empresas : Dictionary = {
	0: {"NAME":"THIRD STREET SAINTS",
		"DESC" : "A multifaceted pop culture company, offering beverages, toys games, clothing, and other products featuring its logo and characters.",
		"HOLD" : 0,
		"PRICE" : 256},
	1:{"NAME" : "BRIAN'S MINING COMPANY",
		"DESC" : "A bio-currency mining company that owns many prime excavation sites of ancient bio-currency.",
		"HOLD" : 0,
		"PRICE" : 1015},
	2:{"NAME" : "JOKAPHO PARANORMALITIES",
		"DESC" : "A technology company aiming to achieve interdimensional travel through rituals and esoteric artifacts. It didn't have much success.",
		"HOLD" : 0,
		"PRICE" : 30},
	3:{"NAME" : "TONY KILL RECORDS",
		"DESC" : "A music production company that is currently abandoned. Responsible for the success of the group ''SPG'' in mid-2009.",
		"HOLD" : 0,
		"PRICE" : 159},
	4:{"NAME" : "CIRCORPORATION",
		"DESC" : "A rival music production company to TonyKillRecords. Abandoned in 2014 after its owners died in a car accident.",
		"HOLD" : 0,
		"PRICE" : 1}}

var organs : Dictionary = {
	0: {"NAME": "BRAIN",
		"DESC" : "Raw material used by the AI industry",
		"HOLD": 0,
		"PRICE": 200},
	1: {"NAME": "STOMACH",
		"DESC" : "The origin of death.",
		"HOLD": 0,
		"PRICE": 10},
	2: {"NAME": "HEART",
		"DESC" : "A disgustingly persistent little biological pump.",
		"HOLD": 0,
		"PRICE": 10},
	3: {"NAME": "PANCREAS",
		"DESC" : "Manages the regulation of blood sugar levels. Completely superfluous due to advances in the food industry.",
		"HOLD": 0,
		"PRICE": 10},
	4: {"NAME": "SPINE",
		"DESC" : "Mark of a celestial prisoner.",
		"HOLD": 0,
		"PRICE": 10},
	5: {"NAME": "INTESTINES",
		"DESC" : "The one in the driver's seat. The homunculus.",
		"HOLD": 0,
		"PRICE": 10},
	6: {"NAME": "APENDIX",
		"DESC" : "The Primitive Seat of the Soul",
		"HOLD": 0,
		"PRICE": 10},
	7: {"NAME": "PSYCHO BRAIN",
		"DESC" : "The brain of a psychogenic controller, or psyker. Capable of sentience.",
		"HOLD": 0,
		"PRICE": 10},
}
#endregion

# Player inventory (separate from master data)
var player_stocks: Dictionary = {}  # {stock_index: {"hold": int}}
var player_organs: Dictionary = {}  # {organ_index: {"hold": int}}

#region Utility Functions
func _ready() -> void:
	_get_organ_names()
	#_load_stocks()

func _get_organ_names():
	list_of_organs.clear()
	for x in organs:
		list_of_organs.append(organs[x]["NAME"])

func _init_player_inventory():
	# Initialize player stocks if not exists
	for index in empresas:
		if not player_stocks.has(index):
			player_stocks[index] = {"hold": 0}
	
	# Initialize player organs if not exists
	for index in organs:
		if not player_organs.has(index):
			player_organs[index] = {"hold": 0}
#endregion

#region BUY and SELL functions

func add_organ(index: int, amount: int):
	if not organs.has(index):
		push_error(str("Organ not found: ", index))
		return
	
	# Initialize if not exists
	if not player_organs.has(index):
		player_organs[index] = {"hold": 0}
	
	player_organs[index]["hold"] += amount
	last_organ_obtained = organs[index]["NAME"]
	emit_signal("organ_obtained")
	_save_stocks()
	Global._save_game()

func get_organ_hold(index: int) -> int:
	if player_organs.has(index):
		return player_organs[index]["hold"]
	return 0

func get_stock_hold(index: int) -> int:
	if player_stocks.has(index):
		return player_stocks[index]["hold"]
	return 0

func get_stock_price(index: int) -> int:
	return empresas.get(index, {}).get("PRICE", 0)

func get_organ_price(index: int) -> int:
	return organs.get(index, {}).get("PRICE", 0)

func get_stock_name(index: int) -> String:
	return empresas.get(index, {}).get("NAME", "Unknown")

func get_organ_name(index: int) -> String:
	return organs.get(index, {}).get("NAME", "Unknown")

func get_stock_desc(index: int) -> String:
	return empresas.get(index, {}).get("DESC", "No description")

func get_organ_desc(index: int) -> String:
	return organs.get(index, {}).get("DESC", "No description")

func buy_stock(tab: String, stock_index: int, amount: int = 1):
	match tab:
		"STOCKS":
			if not empresas.has(stock_index):
				push_error(str("Stock not defined: ", stock_index))
				return
			
			var price = empresas[stock_index]["PRICE"]
			var total_cost = price * amount
			
			if Global.player_cash_money >= total_cost:
				# Initialize if not exists
				if not player_stocks.has(stock_index):
					player_stocks[stock_index] = {"hold": 0}
				
				player_stocks[stock_index]["hold"] += amount
				Global.player_cash_money -= total_cost
				_save_stocks()
				Global._save_game()
				print("Bought ", amount, "x ", empresas[stock_index]["NAME"], " for $", total_cost)
			else:
				print("Not enough money. Need $", total_cost, " have $", Global.player_cash_money)
		
		"ORGANS":
			if not organs.has(stock_index):
				push_error(str("Organ not defined: ", stock_index))
				return
			
			var price = organs[stock_index]["PRICE"]
			var total_cost = price * amount
			
			if Global.player_cash_money >= total_cost:
				if not player_organs.has(stock_index):
					player_organs[stock_index] = {"hold": 0}
				
				player_organs[stock_index]["hold"] += amount
				Global.player_cash_money -= total_cost
				_save_stocks()
				Global._save_game()
				print("Bought ", amount, "x ", organs[stock_index]["NAME"], " for $", total_cost)
			else:
				print("Not enough money. Need $", total_cost, " have $", Global.player_cash_money)
		
		_:
			print("Invalid tab: ", tab)

func sell_stock(tab: String, stock_index: int, amount: int = 1):
	match tab:
		"STOCKS":
			if not empresas.has(stock_index):
				push_error(str("Stock not defined: ", stock_index))
				return
			
			if not player_stocks.has(stock_index):
				print("You don't own any of this stock")
				return
			
			var current_hold = player_stocks[stock_index]["hold"]
			
			if amount <= current_hold:
				var price = empresas[stock_index]["PRICE"]
				var total_value = amount * price
				
				Global.player_cash_money += total_value
				player_stocks[stock_index]["hold"] -= amount
				
				# Clean up if zero
				if player_stocks[stock_index]["hold"] == 0:
					player_stocks.erase(stock_index)
				
				_save_stocks()
				Global._save_game()
				print("Sold ", amount, "x ", empresas[stock_index]["NAME"], " for $", total_value)
			else:
				print("Not enough stocks to sell. Have: ", current_hold, " Trying to sell: ", amount)
		
		"ORGANS":
			if not organs.has(stock_index):
				push_error(str("Organ not defined: ", stock_index))
				return
			
			if not player_organs.has(stock_index):
				print("You don't own any of this organ")
				return
			
			var current_hold = player_organs[stock_index]["hold"]
			
			if amount <= current_hold:
				var price = organs[stock_index]["PRICE"]
				var total_value = amount * price
				
				Global.player_cash_money += total_value
				player_organs[stock_index]["hold"] -= amount
				
				# Clean up if zero
				if player_organs[stock_index]["hold"] == 0:
					player_organs.erase(stock_index)
				
				_save_stocks()
				Global._save_game()
				print("Sold ", amount, "x ", organs[stock_index]["NAME"], " for $", total_value)
			else:
				print("Not enough organs to sell. Have: ", current_hold, " Trying to sell: ", amount)
		
		_:
			print("Invalid tab: ", tab)

func sell_all_stocks(tab: String, stock_index: int):
	match tab:
		"STOCKS":
			if player_stocks.has(stock_index):
				var amount = player_stocks[stock_index]["hold"]
				sell_stock(tab, stock_index, amount)
		
		"ORGANS":
			if player_organs.has(stock_index):
				var amount = player_organs[stock_index]["hold"]
				sell_stock(tab, stock_index, amount)

func get_total_organ_hold() -> int:
	var total = 0
	for organ in player_organs.values():
		total += organ["hold"]
	return total

func get_total_stock_hold() -> int:
	var total = 0
	for stock in player_stocks.values():
		total += stock["hold"]
	return total
#endregion

#region Save and Load Functions
func _save_stocks():
	var file = FileAccess.open(stocks_save_path, FileAccess.WRITE)
	if file:
		file.store_var(player_stocks)
		file.store_var(player_organs)
		file.close()
		print("STOCK FILES SAVED!")
	else:
		push_error("Could not save stocks to: ", stocks_save_path)

func _load_stocks():
	if FileAccess.file_exists(stocks_save_path):
		var file = FileAccess.open(stocks_save_path, FileAccess.READ)
		if file:
			player_stocks = file.get_var()
			player_organs = file.get_var()
			file.close()
			print("STOCK FILES LOADED!")
		else:
			push_error("Could not open stock save file")
			_init_player_inventory()
	else:
		print("No stock save found, creating default inventory")
		_init_player_inventory()
	
	# Ensure all master data entries exist in inventory
	for index in empresas:
		if not player_stocks.has(index):
			player_stocks[index] = {"hold": 0}
	
	for index in organs:
		if not player_organs.has(index):
			player_organs[index] = {"hold": 0}
	
	_save_stocks()  # Save the initialized state
