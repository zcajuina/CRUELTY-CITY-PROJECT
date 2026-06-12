extends Node

func _process(delta: float) -> void:
	if Global.player.player_sm.cur_state() == "falling":
		Global.player.gravity = -9.8
		Global.player.velocity.y = clamp(Global.player.velocity.y,-20,900)
		#Global.player.velocity.y = clampf(-)
	else:
		Global.player.gravity =-14.7
