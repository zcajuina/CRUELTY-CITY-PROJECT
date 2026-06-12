extends Node3D
const HEALTH_ITEM_RIGID_BODY = preload("uid://cwpgihi570hb")
@onready var dispenser: Node3D = $"../DISPENSER"
@export var inspect_name : String = "Vending Machine"
@export var inspect_desc : String = "Buy a snack for $5"
@onready var drop_snd: AudioStreamPlayer3D = $"../DROP_SND"
@onready var shaker: ShakerComponent3D = $"../VENDING MACHINE/SHAKER"

func interact():
	if Global.player_cash_money >= 5:
		Global.player_cash_money -= 5
		var candy = HEALTH_ITEM_RIGID_BODY.instantiate()
		candy.junk_food_mesh()
		await get_tree().process_frame
		Global.world_node.add_child(candy)
		candy.global_position = dispenser.global_position
		candy.linear_velocity.z = randf_range(-1,-5)
		
		candy.angular_velocity.x = randf_range(3,10)
		candy.angular_velocity.y = randf_range(3,30)
		candy.angular_velocity.z = randf_range(3,30)
		drop_snd.pitch_scale = 1 + randf_range(0.05,-0.05)
		
		drop_snd.play()
		if shaker.is_playing:
			shaker.stop_shake()
		shaker.play_shake()
		Global._show_message("","-5 dollars.",0.75,"RED",false)
	else:
		Global._show_message("","Not enough money.",0.75,"RED",false)
