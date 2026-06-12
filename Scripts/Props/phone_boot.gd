extends Node3D


var dialog_array : Array
var on_mission : bool = false
var target : CharacterBody3D

const target_scene : String = "res://Scenes/NPCS/dummy.tscn"
const hostile_target : String = "res://Scenes/NPCS/FOES/basic_melee_foe.tscn"

var listt : Array = [target_scene,hostile_target]

func _ready() -> void:
	dialog_array = Diag.get_dialog("phone_boot")

func interact():
	if not on_mission:
		on_mission = true
		var t_scene = listt.pick_random()
		target = load(t_scene).instantiate()
		add_child(target)
		target.is_target = true
		Global.player.hud.dbox.start_dialogue(dialog_array)
		target.connect("assasinated",_on_target_assasinated)
		target.global_position = Vector3(0.0,0.5,0.0)
	else:
		pass

func _on_target_assasinated():
	target = null
	var reward = randi_range(256,1024)
	Global.player_cash_money += reward
	Global.player.hud.stock_market._update_money_label()
	Global._show_message("CONTRACT KILLING COMPLETE",str("PAYMENT RECEIVED: $",reward))
	on_mission = false
