extends CSGSphere3D
@export var inspect_name : String = "LOREM IPSUM"
@export var inspect_desc : String = "IPSUM LOREM"
@onready var marker_3d: Marker3D = $"../laser/Marker3D"
const DUMMY = preload("uid://c1fgffrnd6iiu")
var current_dummy_foe_node : CharacterBody3D


func interact():
	if current_dummy_foe_node != null:
		current_dummy_foe_node._hit(900)
		await get_tree().process_frame
		current_dummy_foe_node = null
		current_dummy_foe_node = DUMMY.instantiate()
		Global.world_node.add_child(current_dummy_foe_node)
		current_dummy_foe_node.global_position = marker_3d.global_position
	else:
		current_dummy_foe_node = null
		current_dummy_foe_node = DUMMY.instantiate()
		Global.world_node.add_child(current_dummy_foe_node)
		current_dummy_foe_node.global_position = marker_3d.global_position
