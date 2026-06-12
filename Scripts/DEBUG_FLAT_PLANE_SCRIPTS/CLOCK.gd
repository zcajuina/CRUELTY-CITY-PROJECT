extends Node3D

@export var inspect_name : String = "CLOCK"
@export var inspect_desc : String = "CHANGE TIME"


func interact():
	Global.world_node.set_time_angle(Global.world_node.sun.rotation_degrees.x + 45)
