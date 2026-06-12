extends Control
@onready var options_menu: Control = $OPTIONS_MENU
@onready var go_back_btn: Button = $GO_BACK_BTN
@onready var resume: Button = $RESUME
@onready var setting: Button = $SETTING
@onready var go_to_menu: Button = $GO_TO_MENU

@onready var master_slider: HSlider = $OPTIONS_MENU/MASTER_SLIDER
@onready var bgm_slider: HSlider = $OPTIONS_MENU/BGM_SLIDER
@onready var misc_slider: HSlider = $OPTIONS_MENU/MISC_SLIDER
@onready var sensi_slider: HSlider = $OPTIONS_MENU/SENSI_SLIDER
@onready var reload_btn: CheckButton = $OPTIONS_MENU/RELOAD_BTN
@onready var screen_sizes: ItemList = $OPTIONS_MENU/SCREEN_SIZES


func _hide_buttons():
	go_to_menu.hide()
	resume.hide()
	setting.hide()

func _show_buttons():
	go_to_menu.show()
	resume.show()
	setting.show()

func _on_resume_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	self.hide()
	Global.on_menu = false

func _on_setting_pressed() -> void:
	options_menu.show()
	go_back_btn.show()
	_hide_buttons()

func _on_go_to_menu_pressed() -> void:
	
	Global.on_menu = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global._save_game()
	StockDb._save_stocks()
	FishSave._save_fish()
	await get_tree().process_frame
	Global._reset_player_inventory()
	await get_tree().process_frame
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/HUD/MAIN_MENU.tscn")

func _on_go_back_btn_pressed() -> void:
	_show_buttons()
	Global.save_settings(master_slider.value,bgm_slider.value,misc_slider.value,sensi_slider.value,reload_btn.button_pressed,Global.screen_number)
	options_menu.hide()
	go_back_btn.hide()
