extends Node3D

@export var gun_name : String = ""
@export var current_magazine : int = 0
@export var current_storage : int = 0

func _ready() -> void:
	await get_tree().process_frame
	var mesh = load(Global.gun_models[gun_name]["model"]).instantiate()
	self.add_child(mesh)
	mesh.global_rotation.x = deg_to_rad(randi_range(0,90))

func interact():
	if Global.player.gun.current_gun_name == gun_name:
		Global.player_gun_ammo[Global.player.gun.current_gun_pos]["storage"] += current_storage
		current_storage = 0
	else:
		if Global.player.gun.current_gun_name != "HANDS":
			retreive_and_create()
		#função pra atualizar/dar a arma que tá no chão pra o player
		Global.player.gun._gun_scavenge(gun_name,current_magazine,current_storage)
		if Global.guns_specs[gun_name]["owned"] == false:
			Global.guns_specs[gun_name]["owned"] = true
			Global._save_game()
		queue_free()

#função pra criar/droppar a arma que tá na mão do player
func retreive_and_create():
	var world = self.get_parent()
	var gun_drop = load("res://Scenes/Props/DROPPED_GUN.tscn").instantiate()
	world.add_child(gun_drop)
	gun_drop.global_position = self.global_position
	gun_drop.rotation.y = randf_range(20,80)
	gun_drop.gun_name = Global.player.gun.current_gun_name
	gun_drop.current_magazine = Global.player_gun_ammo[Global.player.gun.current_gun_pos]["cur_magazine"]
	gun_drop.current_storage = Global.player_gun_ammo[Global.player.gun.current_gun_pos]["storage"]
