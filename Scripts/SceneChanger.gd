extends Node

var scene_to_change : String = ""
var player_offset_vector : Vector3
var player_head_rot : float = 0
var player_cur_health : float = 0
var keep_health : bool  = false
const loading_screen_scene : String = "res://Scenes/HUD/LOADING_SCREEN.tscn"

func change_level(Scene_Path : String, player_offset : Vector3, player_hrot: float = 0,khealth : bool = false):
	scene_to_change = Scene_Path
	if khealth:
		keep_health = true
		player_cur_health = Global.player.health
	player_offset_vector = player_offset
	player_head_rot = player_hrot
	get_tree().change_scene_to_file(loading_screen_scene)
