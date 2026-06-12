extends Node3D

func _ready() -> void:
	if Global.player != null:
		look_at(Global.player.head.global_position)
