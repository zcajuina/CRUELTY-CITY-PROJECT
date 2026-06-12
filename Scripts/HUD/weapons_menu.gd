extends Control
@onready var main_screen: Control = $"../MAIN_SCREEN"
@onready var inv_label: Label = $INV_LABEL
@onready var weapon_stats_label: Label = $WEAPON_STATS_LABEL
@onready var weapon_name_label: Label = $WEAPON_NAME_LABEL
@onready var weapons_list: ItemList = $WeaponsList
@onready var weapon_preview_pivot: Node3D = $SubViewportContainer/SubViewport/WEAPON_PREVIEW_NODE/WEAPON_PREVIEW_PIVOT
@onready var equip_1_btn: Button = $EQUIP1_BTN
@onready var equip_2_btn: Button = $EQUIP2_BTN
@onready var buy_gun_btn: Button = $BUY_GUN_BTN


var weapon_preview_node : Node3D = null
var gun_to_aquire : bool = false

var guns_with_offset : Dictionary = {"NEURON_DISABLER": {"position":Vector3(0.5,-0.32,0)},
"FISHING_ROD":{"position":Vector3(1.75,0,0),"rotation":Vector3(0,0,0)},
"UBERBLADE":{"position":Vector3(1,0,0),"rotation":Vector3(0,-180,-90)},
"MOLTEM_BOY":{"position":Vector3(0,0,0),"rotation":Vector3(0,90,90)}}

var selected_gun : String = "HANDS"
var gun_price : float = 0
var weapon_list_index : int = 0
var weapons_keys : Array

func _ready() -> void:
	_populate_weapon_list()
	await get_tree().process_frame
	#_unlock_weaps()
	#_set_unlocked_weapons()

#func _process(_delta: float) -> void:
	#update_labels()
	#_weapon_show_model(selected_gun)

func update_labels(has : bool = true):
	if has:
		weapon_stats_label.text = ""
		inv_label.text = str("SLOT 1: ",Global.guns_specs[Global.player_inv[0]]["gun_name"],"\nSLOT 2: ",Global.guns_specs[Global.player_inv[1]]["gun_name"])

		weapon_name_label.text = weapons_list.get_item_text(weapon_list_index)

		if selected_gun == "FISHING_ROD":
			weapon_stats_label.text  = Global.guns_specs[selected_gun]["desc"]
		else:
			var weap_type
			match Global.guns_specs[selected_gun]["type"]:
				"auto","auto-shotgun":
					weap_type = "AUTOMATIC"
				"manual","manual-shotgun":
					weap_type = "MANUAL"
				"melee":
					weap_type = "MELEE"
				_:
					weap_type = "MANUAL"
			
			weapon_stats_label.text += str(Global.guns_specs[selected_gun]["desc"],"\n \n")
			weapon_stats_label.text +="WEAPON STATISTICS \n \n"
			weapon_stats_label.text += str("FIRE DELAY: ",Global.guns_specs[selected_gun]["rate"],"\n")
			weapon_stats_label.text += str("WEAPON TYPE: ",weap_type,"\n")
			if selected_gun == "UBERBLADE":
				weapon_stats_label.text += str("DAMAGE: ","1e+303","\n")
			else:
				weapon_stats_label.text += str("DAMAGE: ",Global.guns_specs[selected_gun]["damage"],"\n")
			weapon_stats_label.text += str("AMMO CAP: ",Global.guns_specs[selected_gun]["max_magazine"],"/",Global.guns_specs[selected_gun]["max_storage"],"\n")
	else:
		weapon_stats_label.text = "Somewhere in this world there's something waiting for you."
		weapon_name_label.text = "[???]"
func _on_equip_1_btn_pressed() -> void:
	Global.player_inv[0] = selected_gun
	update_labels()

func _on_equip_2_btn_pressed() -> void:
	Global.player_inv[1] = selected_gun
	update_labels()

#func _on_go_back_to_menu_btn_pressed() -> void:
	#self.visible = false
	#main_screen.visible = true
	#Global.player_inv_backup = Global.player_inv.duplicate(true)

func _on_weapons_list_item_selected(index: int) -> void:
	gun_to_aquire = false
	weapon_list_index = index
	selected_gun = weapons_keys[index]
	_check_is_gun_owned(selected_gun)

func _on_buy_gun_btn_pressed() -> void:
	if Global.player_cash_money > gun_price:
		Global.player_cash_money -= gun_price
		Global.guns_owned.append(selected_gun)
		buy_gun_btn.release_focus()
		buy_gun_btn.visible = false
		_check_is_gun_owned(selected_gun)

func _check_is_gun_owned(_gun_name : String)->bool:
	if Global.guns_owned.has(selected_gun):
		print("HAS GUN")
		equip_1_btn.show()
		equip_2_btn.show()
		buy_gun_btn.hide()
		buy_gun_btn.disabled = true
		update_labels(true)
		_weapon_show_model(_gun_name)
		#buy_gun_btn.text = "OWNED"
		#get_gun_price(_gun_name)
		return true
	else:
		gun_to_aquire = false
		print("DOES NOT")
		if Global.guns_to_aquire.has(_gun_name):
			gun_to_aquire = true
			buy_gun_btn.show()
			buy_gun_btn.disabled = true
			buy_gun_btn.text = "This weapon can be found in the world."
			buy_gun_btn.theme = load("res://Resourcers/SELL_BTN_THEME.tres")
			equip_1_btn.hide()
			equip_2_btn.hide()
			update_labels(false)
			if weapon_preview_node != null:
				weapon_preview_node.queue_free()
				weapon_preview_node = null
		else:
			gun_to_aquire = false
			buy_gun_btn.theme = load("res://Resourcers/BUY_BTN_THEME.tres")
			buy_gun_btn.disabled = false
			buy_gun_btn.show()
			equip_1_btn.hide()
			equip_2_btn.hide()
			get_gun_price(_gun_name)
			update_labels(true)
			_weapon_show_model(_gun_name)
		return false

func get_gun_price(gun_name : String):
	var gun_data = Global.guns_specs[gun_name]
	if gun_data.has("price"):
		gun_price = gun_data["price"]
	else:
		gun_price = 0
	buy_gun_btn.text = str("PURCHASE $ ",gun_price)

#func _populate_weapon_list():
	#weapons_keys = Global.guns_specs.keys()
	#weapons_keys.pop_front()
	#for i in weapons_keys:
		#if i == "HANDS":
			#continue
		#var weapon_key = Global.guns_specs[i]["gun_name"]
		#weapons_list.add_item(weapon_key)
		##weapons_list.set_item_disabled(i, true)

func _populate_weapon_list():
	weapons_keys = Global.guns_specs.keys()
	weapons_keys.pop_front()
	print(weapons_keys)
	for i in weapons_keys:
		
		if i == "HANDS":
			continue
		var weapon_key = Global.guns_specs[i]["gun_name"]
		if Global.guns_to_aquire.has(i):
			if Global.guns_owned.has(i):
				weapons_list.add_item(weapon_key)
			else:
				weapons_list.add_item("[UNDISCOVERED WEAPON]")
		else:
			weapons_list.add_item(weapon_key)

func _unlock_weaps():
	for i in range(weapons_keys.size()):
		var weapon_key = weapons_keys[i]
		if Global.guns_owned.has(weapon_key):
			weapons_list.set_item_disabled(i, false)

func _weapon_show_model(weapon_name : String):
	if weapon_preview_node != null:
		weapon_preview_node.queue_free()
	if weapon_name != "HANDS":
		weapon_preview_node = load(str("res://Models/Guns/",weapon_name,".glb")).instantiate()
		weapon_preview_pivot.add_child(weapon_preview_node)
		if guns_with_offset.has(selected_gun):
			weapon_preview_pivot.position = guns_with_offset[selected_gun].get("position", Vector3(0.5,0,0))
			weapon_preview_pivot.rotation_degrees = guns_with_offset[selected_gun].get("rotation", Vector3(0, 180, 0))
		else:
			weapon_preview_pivot.position = Vector3(0.5,0,0)
			weapon_preview_pivot.rotation_degrees = Vector3(0,180,0)
