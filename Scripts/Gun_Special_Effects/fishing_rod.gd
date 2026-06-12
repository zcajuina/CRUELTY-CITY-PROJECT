extends Node
@onready var line_2d: Line2D = $Line2D

func _process(_delta: float) -> void:
	await get_tree().process_frame
	if FishSave.fish_bait_node != null and line_2d != null:
		var nozzle_pos = Global.player.camera.unproject_position(Global.player.gun.current_gun_nozzle.global_position)
		var bait_nozzle = Global.player.camera.unproject_position(FishSave.fish_bait_node.global_position)
		bait_nozzle.y -= 5.5
		line_2d.set_point_position(1,bait_nozzle)
		line_2d.set_point_position(0,nozzle_pos)
		if Global.player.camera.is_position_behind(FishSave.fish_bait_node.global_position):
			line_2d.visible = false
		else:
			line_2d.visible = true
	else:
		line_2d.visible = false
