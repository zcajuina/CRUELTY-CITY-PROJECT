extends Node3D
@onready var main_screen: Control = $MAIN_SCREEN
@onready var weapons_menu: Control = $WEAPONS_MENU
@onready var char_menu: Control = $CHAR_MENU
@onready var networth_label: Label = $MAIN_SCREEN/NETWORTH_LABEL
@onready var stock_market: Control = $STOCK_MARKET
@onready var options_menu: Control = $OPTIONS_MENU
@onready var go_back_to_menu_btn: Button = $GO_BACK_TO_MENU_BTN

#region CONFIG MENU NODES
@onready var master_slider: HSlider = $OPTIONS_MENU/MASTER_SLIDER
@onready var sensi_slider: HSlider = $OPTIONS_MENU/SENSI_SLIDER
@onready var bgm_slider: HSlider = $OPTIONS_MENU/BGM_SLIDER
@onready var misc_slider: HSlider = $OPTIONS_MENU/MISC_SLIDER
@onready var reload_btn: CheckButton = $OPTIONS_MENU/RELOAD_BTN
@onready var screen_sizes: ItemList = $OPTIONS_MENU/SCREEN_SIZES
#endregion






func _find_animation_player(node: Node) -> AnimationPlayer:
	# Procura por AnimationPlayer no nó e seus filhos
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	
	return null

func _easy_back():
	if Input.is_action_just_pressed("escape"):
		main_screen.visible = true
		weapons_menu.visible = false
		char_menu.visible = false
		stock_market.visible = false

func _on_play_btn_pressed() -> void:
	#Global.scene_to_change = "res://Scenes/WORLD/CRUELTY_DISTRICT.tscn"
	SceneChanger.change_level(Global.scene_to_change,Global.player_pos)

func _on_spawn_list_item_selected(index: int) -> void:
	var key_names = Global.map_locs.keys()
	print(key_names)
	var selected_key = key_names[index]
	var spawn_data = Global.map_locs[selected_key]["POSITION"]
	
	Global.chosen_spawn = selected_key
	SceneChanger.player_offset_vector = spawn_data
	#Global._save_game()
	
	print("Selected: ", selected_key)
	print("Scene: ", Global.scene_to_change)

func _on_weapon_btn_pressed() -> void:
	go_back_to_menu_btn.show()
	main_screen.visible = false
	weapons_menu.visible = true

func _on_char_btn_pressed() -> void:
	go_back_to_menu_btn.show()
	main_screen.visible = false
	char_menu.visible = true

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_settings_btn_pressed() -> void:
	go_back_to_menu_btn.show()
	main_screen.hide()
	options_menu.show()

func _on_stocks_btn_pressed() -> void:
	go_back_to_menu_btn.show()
	main_screen.visible = false
	stock_market.visible = true

func _on_stock_back_btn_pressed() -> void:
	main_screen.visible = true
	stock_market.visible = false

func _match_money():
	var formatted_money = str(Global.player_networth_money)
	# Add thousands separators
	var pos = formatted_money.find(".")
	if pos == -1:
		pos = formatted_money.length()
	
	while pos > 3:
		pos -= 3
		formatted_money = formatted_money.insert(pos, ".")
	
	networth_label.text = str("NETWORTH VALUE: $", formatted_money)


func _on_go_back_to_menu_btn_pressed() -> void:
	go_back_to_menu_btn.hide()
	if weapons_menu.visible:
		Global.player_inv_backup = Global.player_inv.duplicate(true)
	if options_menu.visible:
		Global.save_settings(master_slider.value,bgm_slider.value,misc_slider.value,sensi_slider.value,reload_btn.button_pressed,Global.screen_number)
	else:
		Global._save_game()
	
	main_screen.show()
	weapons_menu.hide()
	char_menu.hide()
	networth_label.hide()
	stock_market.hide()
	options_menu.hide()
