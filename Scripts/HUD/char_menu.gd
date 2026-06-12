extends Control
@onready var main_screen: Control = $"../MAIN_SCREEN"

@onready var container: TabContainer = $AUGS/CONTAINER

@onready var head: ItemList = $AUGS/CONTAINER/HEAD
@onready var chest: ItemList = $AUGS/CONTAINER/CHEST
@onready var arm: ItemList = $AUGS/CONTAINER/ARM
@onready var leg: ItemList = $AUGS/CONTAINER/LEG
@onready var char_list: ItemList = $CHAR/CHAR_LIST

@onready var head_btn: Button = $HEAD_BTN
@onready var chest_btn: Button = $CHEST_BTN
@onready var arm_btn: Button = $ARM_BTN
@onready var leg_btn: Button = $LEG_BTN

@onready var aug_buy_btn: Button = $AUGS/AUG_BUY_BTN

@onready var aug_sprite: Sprite2D = $AUGS/AUG_SPRITE
@onready var aug_name: Label = $AUGS/AUG_NAME
@onready var aug_desc: Label = $AUGS/AUG_DESC

var aug_price : float = 0

#region FUNÇÕES DE PREENCHIMENTO
func global_populate_list(item_table : Dictionary):
	var list_node = null
	match item_table:
		Global.head_implants:
			list_node = head
		Global.arm_implants:
			list_node = arm
		Global.chest_implants:
			list_node = chest
		Global.leg_implants:
			list_node = leg
	
	#listinha com os nomes dos augs
	var dic_keys = item_table.keys()
	var index = 0
	if dic_keys.is_empty():
		return
	Global.total_implants_ammount += dic_keys.size()
	for i in range(dic_keys.size()):
		
		#pegar o nome do aug atual
		var key = dic_keys[i]
		
		
		#adiciona o aug na lista
		list_node.add_item(key)
		
		#verificação se o player tem o aug ou não pra trocar o nome
		var item_data = item_table[key]
		if item_data.has("unlockable"):
			if Global.implants_owned.has(key):
				list_node.set_item_text(index,key)
			else:
				list_node.set_item_text(index,"???")
		index += 1

func player_skins_populate_list():
	var dic_keys = Global.player_skins.keys()
	var index = 0
	if dic_keys.is_empty():
		return
	
	for i in range(dic_keys.size()):
		var skin_name = dic_keys[index]
		if Global.skins_owned.has(skin_name):
			if skin_name == "CUSTOM":
				char_list.add_item("",Global.load_custom_player_image())
			else:
				char_list.add_item("",load("res://Textures/SPRITES/SKIN_SPRITES/"+dic_keys[index]+".png"))
		else:
			char_list.add_item("",load("res://Textures/CRUS/greyfacedstrct.png"))
		
		#char_list.add_item("",load("res://Textures/CRUS/greyfacedstrct.png"))
		index += 1


func _set_up_item_description(implant_table : String,item_key : String):
	aug_name.visible = true
	aug_desc.visible = true
	var table
	match implant_table:
		"legs":
			table = Global.leg_implants
		"head":
			table = Global.head_implants
		"arm":
			table = Global.arm_implants
		"chest":
			table = Global.chest_implants
	if not item_key == "???":
		var item_desc = table[item_key]["DESC"]
		aug_name.text = item_key
		aug_desc.text = item_desc
		aug_sprite.texture = load(table[item_key]["sprite"])
	else:
		aug_name.text = item_key
		aug_desc.text = "Somewhere in this world there's something waiting for you."
		aug_sprite.texture = null

func _fill_current_item_slots():
	if not Global.player_head_implant == "NONE":
		head_btn.icon = load(Global.head_implants[Global.player_head_implant]["sprite"])
	if not Global.player_arm_implant == "NONE":
		arm_btn.icon = load(Global.arm_implants[Global.player_arm_implant]["sprite"])
	if not Global.player_chest_implant == "NONE":
		chest_btn.icon = load(Global.chest_implants[Global.player_chest_implant]["sprite"])
	if not Global.player_leg_implant == "NONE":
		leg_btn.icon = load(Global.leg_implants[Global.player_leg_implant]["sprite"])

func _equip_item(item_name : String, table : Dictionary, button : Button):
		var texture = load(table[item_name]["sprite"])
		
		button.disabled = false
		match table:
			Global.head_implants:
				Global.player_head_implant = item_name
			Global.arm_implants:
				Global.player_arm_implant = item_name
			Global.chest_implants:
				Global.player_chest_implant = item_name
			Global.leg_implants:
				Global.player_leg_implant = item_name
	
		if texture and texture is Texture2D:
			button.icon = texture
		else:
			print("Error: Could not load texture")
		#print(Global.player_head_implant,Global.player_arm_implant,Global.player_chest_implant,Global.player_leg_implant)

func _buy_or_bought_check(implant_name : String, table:Dictionary)->bool:
	#se o item é de encontrar
	if implant_name == "???":
		aug_buy_btn.visible = true
		aug_buy_btn.text = "???"
		aug_buy_btn.disabled = true
		return false
	
	#caso contrario
	var aug_data = table[implant_name]

	if Global.implants_owned.has(implant_name):
		aug_buy_btn.visible = true
		aug_buy_btn.text = "BOUGHT"
		aug_buy_btn.disabled = true
		return true
	else:
		aug_buy_btn.visible = true
		aug_buy_btn.disabled = false
		if not aug_data.has("price"):
			aug_price = 1
		else:
			aug_price = aug_data["price"]
		aug_buy_btn.text = str("$",aug_price)
		return false

#endregion

func _ready() -> void:
	global_populate_list(Global.head_implants)
	global_populate_list(Global.arm_implants)
	global_populate_list(Global.chest_implants)
	global_populate_list(Global.leg_implants)
	player_skins_populate_list()
	#_populate_leg_list()
	#_populate_chest_list()
	await get_tree().process_frame
	_fill_current_item_slots()
	$CHAR_NAME_EDIT.text = Global.player_name
	$INFO/PLAYER_PFP.texture = Global.load_custom_player_image()
	#leg_label.text = Global.player_leg_implant

func _on_go_back_to_menu_btn_pressed() -> void:
	self.visible = false
	main_screen.visible = true
	Global._save_game()

func _on_aug_buy_btn_pressed() -> void:
	if Global.player_cash_money >= aug_price:
		Global.player_cash_money -= aug_price
		Global.implants_owned.append(aug_name.text)
		await get_tree().process_frame
		aug_buy_btn.release_focus()
		aug_buy_btn.text = "BOUGHT"
		aug_buy_btn.disabled = true

func _on_container_tab_changed(_tab: int) -> void:
	aug_sprite.texture = null
	aug_name.text = ""
	aug_desc.text = ""
	aug_buy_btn.visible = false

#region ACTIVATE ITEM LIST
func _on_head_item_activated(index: int) -> void:
	if not head.is_item_disabled(index):
		var item_key = head.get_item_text(index)
		if _buy_or_bought_check(item_key,Global.head_implants) == true:
			_equip_item(item_key,Global.head_implants,head_btn)

func _on_chest_item_activated(index: int) -> void:
	if not chest.is_item_disabled(index):
		var item_key = chest.get_item_text(index)
		if _buy_or_bought_check(item_key,Global.chest_implants) == true:
			_equip_item(item_key,Global.chest_implants,chest_btn)

func _on_arm_item_activated(index: int) -> void:
	if not arm.is_item_disabled(index):
		var item_key = arm.get_item_text(index)
		if _buy_or_bought_check(item_key,Global.arm_implants) == true:
			_equip_item(item_key,Global.arm_implants,arm_btn)

func _on_leg_item_activated(index: int) -> void:
	if not leg.is_item_disabled(index):
		var item_key = leg.get_item_text(index)
		if _buy_or_bought_check(item_key,Global.leg_implants) == true:
			_equip_item(item_key,Global.leg_implants,leg_btn)
#endregion

#region REMOVE BUTTONS
func _on_head_btn_pressed() -> void:
	Global.player_head_implant = "NONE"
	head_btn.icon = null
func _on_arm_btn_pressed() -> void:
	Global.player_arm_implant = "NONE"
	arm_btn.icon = null
func _on_chest_btn_pressed() -> void:
	Global.player_chest_implant = "NONE"
	chest_btn.icon = null
func _on_leg_btn_pressed() -> void:
	Global.player_leg_implant = "NONE"
	leg_btn.icon = null
#endregion

#region ITEM LIST CLICKED
func _on_head_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_key = head.get_item_text(index)
	_set_up_item_description("head",item_key)
	_buy_or_bought_check(item_key,Global.head_implants)
func _on_arm_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_key = arm.get_item_text(index)
	_set_up_item_description("arm",item_key)
	_buy_or_bought_check(item_key,Global.arm_implants)
func _on_chest_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_key = chest.get_item_text(index)
	_set_up_item_description("chest",item_key)
	_buy_or_bought_check(item_key,Global.chest_implants)
func _on_leg_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_key = leg.get_item_text(index)
	_set_up_item_description("legs",item_key)
	_buy_or_bought_check(item_key,Global.leg_implants)
#endregion
