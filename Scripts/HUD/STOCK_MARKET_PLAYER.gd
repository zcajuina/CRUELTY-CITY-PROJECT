extends Control
@onready var stocks: ItemList = $STOCKS_MAKT/STOCKS
@onready var organs: ItemList = $STOCKS_MAKT/ORGANS
@onready var fish: ItemList = $STOCKS_MAKT/FISH
@onready var stock_desc: Label = $INFO_PANEL/STOCK_DESC
@onready var holdings_label: Label = $INFO_PANEL/HOLDINGS_LABEL
@onready var stocks_makt: TabContainer = $STOCKS_MAKT
@onready var money_label: Label = $HOLDINGS_PANEL/MONEY_LABEL
@onready var user_info_panel: Control = $USER_INFO_PANEL

@onready var buy_btn_container: HBoxContainer = $INFO_PANEL/BUY_BTN_CONTAINER
@onready var sell_btn_container: HBoxContainer = $INFO_PANEL/SELL_BTN_CONTAINER

@onready var fish_root: Node3D = $INFO_PANEL/FISH_VIEW/SubViewport/FISH_ROOT
@onready var fish_view: SubViewportContainer = $INFO_PANEL/FISH_VIEW
@onready var stock_comp_sprite: Sprite2D = $INFO_PANEL/STOCK_COMP_SPRITE

var fish_model_preview : Node3D = null

var current_index_backup : int = 0

var nodes_dic : Dictionary = {"STOCKS" : stocks,"ORGANS":organs,"FISH" : fish}


func _ready() -> void:
	FishSave.connect("new_fish_catch",_on_new_fish_catch)
	StockDb.connect("organ_obtained",_on_organ_obtained)
	#stocks.connect("on_stocks_item_clicked",_on_item_list_selected)
	StockDb.stock_menu = self
	
	await get_tree().create_timer(0.55).timeout
	_populate_everything()
	#stock_desc.text = ""
	#_populate_fish_list()
	#_populate_stocks()
	#_populate_organs()
	#await get_tree().process_frame
	#_update_money_label()
	
func _populate_everything():
	stock_desc.text = ""
	_populate_fish_list()
	_populate_stocks()
	_populate_organs()
	await get_tree().process_frame
	_update_money_label()

func _fish_preview_spawner(fish_name : String):
	if fish_name == "remove":
		if fish_model_preview != null:
			fish_model_preview.queue_free()
		return
	if not fish_view.visible:
		fish_view.show()
	
	if fish_model_preview != null:
		fish_model_preview.queue_free()
	
	if FishSave.special_fish_model.has(fish_name):
		fish_model_preview = load("res://Scenes/FISH/"+fish_name+".tscn").instantiate()
	else:
		fish_model_preview = load("res://Models/Props/FISH_MODELS/"+fish_name+".glb").instantiate()
	fish_root.add_child(fish_model_preview)

func _organ_preview_spawner(organ_name : String):
	if organ_name == "remove":
		if fish_model_preview != null:
			fish_model_preview.queue_free()
		return
	if not fish_view.visible:
		fish_view.show()
	
	if fish_model_preview != null:
		fish_model_preview.queue_free()
	
	if ResourceLoader.exists("res://Models/Props/ORGANS/"+organ_name+".glb"):
		fish_model_preview = load("res://Models/Props/ORGANS/"+organ_name+".glb").instantiate()
		fish_root.add_child(fish_model_preview)
		var scal = 0
		var rot = Vector3.ZERO
		if organ_name == "BRAIN":
			scal = 0.25
			rot = Vector3(-90,0,0)
		elif organ_name == "PYSCHO BRAIN":
			scal = 0.25
			rot = Vector3(0,0,-45)
		elif organ_name == "SPINE":
			scal = 0.10
		elif organ_name == "INTESTINES":
			scal = 0.20
		else:
			scal = 0.25
		fish_model_preview.scale = Vector3(scal,scal,scal)
		fish_model_preview.rotation_degrees = rot

func _update_things():
	await get_tree().create_timer(1).timeout
	_update_all_items_on_a_tab("ALL")
	print("tabs reloaded")
	return

func _on_new_fish_catch():
	print("NOVO PEIXE!!!")
	#var fish_index = FishSave._lista_de_peixes.find(FishSave.last_fish_catched_name)
	_update_all_items_on_a_tab("FISH")
	#_update_item_holding_on_list("FISH",fish_index)
	_update_money_label()

func _on_organ_obtained():
	#var organ_index = StockDb.list_of_organs.find(StockDb.last_organ_obtained)
	#_update_item_holding_on_list("ORGANS",organ_index)
	_update_money_label()
	_update_all_items_on_a_tab("ORGANS")

#func _on_item_list_selected(index: int, at_position: Vector2, mouse_button_index: int):
	#stock_desc.text = StockDb.empresas[index]["DESC"]

func _on_stocks_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	buy_btn_container.show()
	sell_btn_container.show()
	stock_desc.text = StockDb.get_stock_desc(index)
	var sholdings = StockDb.get_stock_hold(index)
	var sname = StockDb.get_stock_name(index)
	var sprice = StockDb.empresas[index]["PRICE"]
	holdings_label.text = str(
		"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
	if ResourceLoader.exists(str("res://Textures/SPRITES/EMPRESAS/", sname, ".png")):
		stock_comp_sprite.show()
		var texture = load(str("res://Textures/SPRITES/EMPRESAS/", sname, ".png"))
		
		# Create an image texture and resize it
		var image = texture.get_image()
		image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
		
		var resized_texture = ImageTexture.create_from_image(image)
		stock_comp_sprite.texture = resized_texture
		
		# Also set the sprite size
		stock_comp_sprite.region_enabled = false
	else:
		stock_comp_sprite.texture = null

func _on_organs_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	buy_btn_container.show()
	sell_btn_container.show()
	stock_desc.text = StockDb.get_organ_desc(index)
	var sholdings = StockDb.get_organ_hold(index)
	var sname = StockDb.organs[index]["NAME"]
	var sprice = StockDb.organs[index]["PRICE"]
	holdings_label.text = str(
		"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
	_organ_preview_spawner(StockDb.get_organ_name(index))

#func _on_fish_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	#var keys = FishSave._lista_de_peixes
	#if FishSave.fish_data[keys[index]]["discovered"] == true:
		#stock_desc.text = FishSave.fish_data[keys[index]]["description"]
		#buy_btn_container.show()
		#sell_btn_container.show()
		#var sholdings = FishSave.fish_data[keys[index]]["inventory"]
		#var sname = keys[index]
		#var sprice = FishSave.fish_data[keys[index]]["value"]
		#holdings_label.text = str(
			#"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
		#_fish_preview_spawner(sname)
	#else:
		#_fish_preview_spawner("remove")
		#stock_desc.text = "Somewhere in this world there's something waiting for you."
		#holdings_label.text = ""
		#buy_btn_container.hide()
		#sell_btn_container.hide()

func _on_fish_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	current_index_backup = index
	var keys = FishSave._lista_de_peixes
	var fish_name = keys[index]
	if FishSave.is_fish_discovered(fish_name):
		stock_desc.text = FishSave.get_fish_description(fish_name)
		buy_btn_container.show()
		sell_btn_container.show()
		var sholdings = FishSave.get_fish_quantity(fish_name)
		var sname = fish_name
		var sprice = FishSave.get_fish_value(fish_name)
		holdings_label.text = str(
			"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
		_fish_preview_spawner(sname)
	else:
		_fish_preview_spawner("remove")
		stock_desc.text = "Somewhere in this world there's something waiting for you."
		holdings_label.text = ""
		buy_btn_container.hide()
		sell_btn_container.hide()

func _on_stocks_makt_tab_changed(_tab: int) -> void:
	stock_comp_sprite.hide()
	buy_btn_container.hide()
	sell_btn_container.hide()
	stocks.deselect_all()
	organs.deselect_all()
	fish.deselect_all()
	fish_view.hide()
	stock_desc.text = ""
	holdings_label.text = ""
	

#func _populate_fish_list():
	#var fish_names = FishSave._lista_de_peixes
	#
	## Clear existing items first (optional, prevents duplicates)
	#fish.clear()
	#
	#for x in range(len(fish_names)):
		#var fish_name = fish_names[x]
		##var fish_entry = FishSave.fish_data[fish_name]
		#var fish_ammount = FishSave.fish_data[fish_name]["inventory"]
		#
		## Get fish display name, default to key if not found
		#var display_name = ""
		#if FishSave.fish_data[fish_name]["discovered"] == true:
			#display_name = str("[",fish_ammount,"] ",fish_names[x])
		#else:
			#display_name = str("[UNDISCOVERED FISH]")
		#
		## Add to the fish list (ItemList, OptionButton, etc.)
		#fish.add_item(display_name, null)
		#
		### Optional: Set custom metadata or tooltip
		##var idx = fish.get_item_count() - 1
		##fish.set_item_metadata(idx, fish_name)  # Store original key
		##
		### Optional: Add disabled style for undiscovered fish
		##if not fish_entry.get("discovered", false):
			##fish.set_item_disabled(idx, true)

func _populate_fish_list():
	# Clear existing items first (optional, prevents duplicates)
	fish.clear()
	
	for fish_name in FishSave.fish_data:
		#var fish_entry = FishSave.fish_data[fish_name]
		#var fish_ammount = FishSave.player_inventory[fish_name]["quantity"]
		var fish_ammount = FishSave.get_fish_quantity(fish_name)
		
		# Get fish display name, default to key if not found
		var display_name = ""
		if FishSave.is_fish_discovered(fish_name):
			display_name = str("[",fish_ammount,"] ",fish_name)
		else:
			display_name = str("[UNDISCOVERED FISH]")
		
		# Add to the fish list (ItemList, OptionButton, etc.)
		fish.add_item(display_name, null)
		
		## Optional: Set custom metadata or tooltip
		#var idx = fish.get_item_count() - 1
		#fish.set_item_metadata(idx, fish_name)  # Store original key
		#
		## Optional: Add disabled style for undiscovered fish
		#if not fish_entry.get("discovered", false):
			#fish.set_item_disabled(idx, true)

func _populate_stocks():
	# Clear existing items
	stocks.clear()
	
	# Loop through all stocks in the database
	for stock_id in StockDb.empresas.keys():
		#var stock_data = StockDb.empresas[stock_id]
		
		# Create display text with stock info
		var display_text = str("[",StockDb.get_stock_hold(stock_id),"] ",StockDb.empresas[stock_id]["NAME"])
		
		# Add item to the list
		stocks.add_item(display_text)

func _populate_organs():
	# Clear existing items
	organs.clear()
	
	# Loop through all stocks in the database
	for organ_id in StockDb.organs.keys():
		#var stock_data = StockDb.organs[organ_id]
		
		# Create display text with stock info
		var display_text = str("[",StockDb.get_organ_hold(organ_id),"] ",StockDb.organs[organ_id]["NAME"])
		
		# Add item to the list
		organs.add_item(display_text)

func _global_buy_function(ammount : int):
	var current_tab_name = stocks_makt.get_current_tab_control().name
	var cur_tab_node
	match current_tab_name:
		"STOCKS":
			cur_tab_node = stocks
		"FISH":
			cur_tab_node = fish
		"ORGANS":
			cur_tab_node = organs
	var selected_item = cur_tab_node.get_selected_items()
	
	if not selected_item.is_empty() and selected_item[0] != -1:
		if current_tab_name != "FISH":
			StockDb.buy_stock(current_tab_name,selected_item[0],ammount)
			_update_item_holdings(current_tab_name,selected_item[0])
			_update_item_holding_on_list(current_tab_name,selected_item[0])
			_update_money_label()
			
		else:
			var keys = FishSave._lista_de_peixes
			var fish_name = keys[selected_item[0]]
			FishSave.buy_fish(fish_name,ammount)
			_update_item_holdings(current_tab_name,selected_item[0])
			_update_item_holding_on_list(current_tab_name,selected_item[0])
			_update_money_label()

func _global_sell_function(amount: int):
	var current_tab_name = stocks_makt.get_current_tab_control().name
	var cur_tab_node
	
	# Determine which tab is currently active
	match current_tab_name:
		"STOCKS":
			cur_tab_node = stocks
		"FISH":
			cur_tab_node = fish
		"ORGANS":
			cur_tab_node = organs
	
	# Get the selected item
	var selected_item = cur_tab_node.get_selected_items()
	
	# Check if an item is selected
	if not selected_item.is_empty() and selected_item[0] != -1:
		if current_tab_name != "FISH":
			# For stocks and organs, sell from StockDb
			StockDb.sell_stock(current_tab_name, selected_item[0], amount)
			_update_item_holdings(current_tab_name, selected_item[0])
			_update_item_holding_on_list(current_tab_name,selected_item[0])
			_update_money_label()
		else:
			# For fish, sell from FishSave
			var keys = FishSave._lista_de_peixes
			var fish_name = keys[selected_item[0]]
			FishSave.sell_fish_by_quant(fish_name, amount)
			_update_item_holdings(current_tab_name, selected_item[0])
			_update_item_holding_on_list(current_tab_name,selected_item[0])
			_update_money_label()

func _update_item_holding_on_list(tab : String, index : int):
	match tab:
		"STOCKS":
			var sholdings = StockDb.get_stock_hold(index)
			var sname = StockDb.get_stock_name(index)
			stocks.set_item_text(index,str("[",sholdings,"] ",sname))
		"ORGANS":
			var sholdings = StockDb.get_organ_hold(index)
			var sname = StockDb.get_organ_name(index)
			organs.set_item_text(index,str("[",sholdings,"] ",sname))
		"FISH":
			var keys = FishSave._lista_de_peixes
			var sname = keys[index]
			var sholdings = FishSave.get_fish_quantity(sname)
			
			
			var display_name = ""
			
			if FishSave.is_fish_discovered(sname):
				display_name = str("[",sholdings,"] ",sname)
			else:
				display_name = str("[UNDISCOVERED FISH]")
			
			fish.set_item_text(index,display_name)

func _update_item_holdings(tab : String, index : int):
	match tab:
		"STOCKS":
			stock_desc.text = StockDb.get_stock_desc(index)
			var sholdings = StockDb.get_stock_hold(index)
			var sname = StockDb.get_stock_name(index)
			var sprice = StockDb.get_stock_price(index)
			holdings_label.text = str(
				"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
		"ORGANS":
			stock_desc.text = StockDb.get_organ_desc(index)
			var sholdings = StockDb.get_organ_hold(index)
			var sname = StockDb.organs[index]["NAME"]
			var sprice = StockDb.get_organ_price(index)
			holdings_label.text = str(
				"[",sholdings,"] ",sname,"\n","\n","PRICE: $",sprice)
		"FISH":
			var keys = FishSave._lista_de_peixes
			var fish_name = keys[index]
			stock_desc.text = FishSave.get_fish_description(fish_name)
			var sholdings = FishSave.get_fish_quantity(fish_name)
			var sprice = FishSave.get_fish_value(fish_name)
			holdings_label.text = str(
				"[",sholdings,"] ",fish_name,"\n","\n","PRICE: $",sprice)

func _update_money_label():
	var cash = Global.player_cash_money
	var thold = 0
	
	for x in StockDb.organs:
		if StockDb.get_organ_hold(x) >0:
			thold +=  StockDb.get_organ_hold(x) * StockDb.organs[x]["PRICE"]
	
	for y in StockDb.empresas:
		if StockDb.get_stock_hold(y) >0:
			thold += StockDb.get_stock_hold(y) * StockDb.empresas[y]["PRICE"]
	
	for z in FishSave.fish_data:
		if FishSave.get_fish_quantity(z) >0:
			thold += FishSave.get_fish_quantity(z) * FishSave.fish_data[z]["value"]
	
	
	Global.player_networth_money = thold
	money_label.text = str("Cash: $",cash,"\n","Total Holding: $",thold)

func _update_all_items_on_a_tab(tab : String):
	match tab:
		"FISH":
			for x in range(fish.item_count ):
				_update_item_holding_on_list("FISH",x)
		"ORGANS":
			for y in range(organs.item_count):
				_update_item_holding_on_list("ORGANS",y)
		"STOCKS":
			for z in range(stocks.item_count):
				_update_item_holding_on_list("STOCKS",z)
		"ALL":
			for x in range(fish.item_count):
				_update_item_holding_on_list("FISH",x)
			for y in range(organs.item_count):
				_update_item_holding_on_list("ORGANS",y)
			for z in range(stocks.item_count):
				_update_item_holding_on_list("STOCKS",z)
		_:
			pass
