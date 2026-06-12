extends Node
var save_path = Global.saves_folder_path + "fish_save.zcj"
var fish_bait_node : Node3D = null
var fish_node : Node3D = null
var cpf_do_peixe : Dictionary
var _lista_de_peixes = []
signal new_fish_catch
var last_fish_catched_name : String


var fish_data = {
	# --- NORMAL TIER --- 
	"Le Fishe": {
		"water" : "water_normal",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "It sounds italian.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"FUGU FISH": {
		"water" : "water_normal",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 3,
		"description": "Common replacement for revolvers during russian roulette sessions.",
		"model": "res://cenas/fish/FISH_MODELS/trench_trout.tscn"
	},
	"CHOCOLATE STARFISH": {
		"water" : "water_normal",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 5,
		"description": "Little biological engenered fish, bread to reduce the need of cocoa trees.",
		"model": "res://cenas/fish/FISH_MODELS/data_minnow.tscn"
	},
	"DELPHINO": {
		"water" : "water_normal",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 4,
		"description": "A deranged gamer.",
		"model": "res://cenas/fish/FISH_MODELS/gutter_eel.tscn"
	},
	"COINY": {
		"water" : "water_normal",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Avoid predators by hiding among coins.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"OCTOSAUR": {
		"water" : "water_normal",
		"raridade": 7,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "A unit.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"HEXASAUR": {
		"water" : "water_normal",
		"raridade": 4,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "AAbsolute unit.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"SUCCESS": {
		"water" : "water_normal",
		"raridade": 4,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Now that's what i'm talking about.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},


	"SLURPER": {
		"water" : "water_swamp",
		"raridade": 10,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 25,
		"description": "That's disgusting, who would want that?",
		"model": "res://cenas/fish/FISH_MODELS/cubicle_perch.tscn"
	},
	"RUBBER WIFE": {
		"water" : "water_swamp",
		"raridade": 10,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 25,
		"description": "It's imobile, yet you feel it pumping and overloading with sentimental power of shame and lust.",
		"model": "res://cenas/fish/FISH_MODELS/cubicle_perch.tscn"
	},
	"SWAMP SUCKER": {
		"water" : "water_swamp",
		"raridade": 10,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 25,
		"description": "Eats green swamp shit.",
		"model": "res://cenas/fish/FISH_MODELS/cubicle_perch.tscn"
	},
	"WHEEL OF FORTUNE": {
		"water" : "water_swamp",
		"raridade": 6,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 25,
		"description": "yeah.",
		"model": "res://cenas/fish/FISH_MODELS/cubicle_perch.tscn"
	},
	"WHEEL OF PAIN": {
		"water" : "water_swamp",
		"raridade": 20,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 25,
		"description": "What in the fuck is this?",
		"model": "res://cenas/fish/FISH_MODELS/cubicle_perch.tscn"
	},

	"GORBINO": {
		"water" : "water_pure",
		"raridade": 30,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Catch other 500 of these for a complete mind pumping action event. (don't do it)",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"TRIGON TOY": {
		"water" : "water_pure",
		"raridade": 80,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Strange little pastic toy.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"BIG BOY": {
		"water" : "water_pure",
		"raridade": 80,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Eats sin suckers.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"AVERAGE COMENTARY YOUTUBER": {
		"water" : "water_pure",
		"raridade": 80,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "'Why am i the water, man?'",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},
	"SIN SUCKER": {
		"water" : "water_pure",
		"raridade": 150,
		"inventory": 0,
		"catch_time": 3.0,
		"value": 2,
		"description": "Thrives by eating the sins of this doomed world. Strange that it's not gigantic.",
		"model": "res://cenas/fish/FISH_MODELS/industrial_carp.tscn"
	},

}

var special_fish_model : Array[String] = ["RUBBER WIFE"]

#region Utility Functions
# Player inventory (separate from master data)
var player_inventory: Dictionary = {}  # fish_name -> {quantity: int, discovered: bool}

func _ready():
	#_load_fish()
	# Update list of fish names
	_update_fish_list()

func _update_fish_list():
	_lista_de_peixes = fish_data.keys()

func _save_fish():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(player_inventory)
		file.close()
		print("Fish save saved successfully")
	else:
		push_error("Could not save fish data to: ", save_path)

func _load_fish():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			player_inventory = file.get_var()
			file.close()
			print("Fish save loaded successfully")
		else:
			push_error("Could not open fish save file")
			_create_default_inventory()
	else:
		print("No fish save found, creating default inventory")
		_create_default_inventory()

func _create_default_inventory():
	player_inventory.clear()
	for fish_name in fish_data.keys():
		player_inventory[fish_name] = {
			"quantity": 0,
			"discovered": false
		}
	# Discover some default fish? Optional
	# player_inventory["Le Fishe"]["discovered"] = true
	_save_fish()

func add_fish(fish_name: String, amount: int = 1):
	if not fish_data.has(fish_name):
		push_error("Fish not defined in master data: " + fish_name)
		return
	
	# Initialize inventory entry if it doesn't exist
	if not player_inventory.has(fish_name):
		player_inventory[fish_name] = {
			"quantity": 0,
			"discovered": false
		}
	
	last_fish_catched_name = fish_name
	player_inventory[fish_name]["quantity"] += amount
	
	if not player_inventory[fish_name]["discovered"]:
		player_inventory[fish_name]["discovered"] = true
		emit_signal("new_fish_catch")
		print("New fish discovered: ", fish_name)
	
	_save_fish()
	Global._save_game()
	print("Added ", amount, "x ", fish_name, " (Total: ", player_inventory[fish_name]["quantity"], ")")

func get_fish_quantity(fish_name: String) -> int:
	if not player_inventory.has(fish_name):
		return 0
	return player_inventory[fish_name]["quantity"]

func is_fish_discovered(fish_name: String) -> bool:
	if not player_inventory.has(fish_name):
		return false
	return player_inventory[fish_name]["discovered"]

func get_fish_data(fish_name: String) -> Dictionary:
	return fish_data.get(fish_name, {})

func get_all_fish_names() -> Array:
	return fish_data.keys()

func get_discovered_fish() -> Array:
	var discovered = []
	for fish_name in fish_data.keys():
		if player_inventory.get(fish_name, {}).get("discovered", false):
			discovered.append(fish_name)
	return discovered

func get_owned_fish() -> Array:
	var owned = []
	for fish_name in fish_data.keys():
		if player_inventory.get(fish_name, {}).get("quantity", 0) > 0:
			owned.append(fish_name)
	return owned

func get_fish_price(index: int) -> int:
	return fish_data.get(index, {}).get("value", 0)

func buy_fish(fish_name: String, amount: int = 1):
	if not fish_data.has(fish_name):
		push_error("Fish not defined: " + fish_name)
		return
	
	var fish_value = fish_data[fish_name]["value"]
	var total_cost = fish_value * amount
	
	if Global.player_cash_money >= total_cost:
		add_fish(fish_name, amount)
		Global.player_cash_money -= total_cost
		Global._save_game()
		print("Bought ", amount, "x ", fish_name, " for $", total_cost)
	else:
		print("Not enough money. Need $", total_cost, " have $", Global.player_cash_money)

func sell_fish(fish_name: String):
	var quantity = get_fish_quantity(fish_name)
	if quantity > 0:
		sell_fish_by_quant(fish_name, quantity)
	else:
		print("No fish to sell: ", fish_name)

func sell_fish_by_quant(fish_name: String, quantidade: int):
	if not fish_data.has(fish_name):
		print("Fish not found: ", fish_name)
		return
	
	var current_amount = get_fish_quantity(fish_name)
	
	if quantidade <= 0:
		print("Invalid quantity: ", quantidade)
		return
	
	if current_amount < quantidade:
		print("Not enough fish (Have: ", current_amount, ", Trying to sell: ", quantidade, ")")
		return
	
	var value_per_fish = fish_data[fish_name]["value"]
	var total_value = quantidade * value_per_fish
	
	Global.player_cash_money += total_value
	
	# Update inventory
	if current_amount == quantidade:
		player_inventory[fish_name]["quantity"] = 0
	else:
		player_inventory[fish_name]["quantity"] = current_amount - quantidade
	
	_save_fish()
	Global._save_game()
	
	print("Sold ", quantidade, "x ", fish_name, " for $", total_value)

func get_fish_value(fish_name: String) -> int:
	return fish_data.get(fish_name, {}).get("value", 0)

func get_fish_description(fish_name: String) -> String:
	return fish_data.get(fish_name, {}).get("description", "Unknown fish")

func get_fish_catch_time(fish_name: String) -> float:
	return fish_data.get(fish_name, {}).get("catch_time", 3.0)

func get_fish_rarity(fish_name: String) -> int:
	return fish_data.get(fish_name, {}).get("raridade", 30)

func get_fish_water(fish_name: String) -> String:
	return fish_data.get(fish_name, {}).get("water", "water_normal")

func get_fish_chance(fish_name: String) -> int:
	return fish_data.get(fish_name, {}).get("chance", 0)

func reset_fish_data():
	_create_default_inventory()
	print("Fish data reset to default")
#endregion
