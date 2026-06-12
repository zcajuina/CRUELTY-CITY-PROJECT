extends Control

func _process(delta: float) -> void:
	if visible:
		top_level = true
	else:
		top_level = false

func _on_respawn_btn_pressed() -> void:
	Global.player.re_spawn()
	#get_tree().reload_current_scene()


func _on_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/HUD/MAIN_MENU.tscn")
