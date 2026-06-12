extends RayCast3D

var grab_dis : float = 12.0
var looking_at_pickup : bool = false
@onready var visuais: Node3D = $"../visuais"

func _ready() -> void:
	add_exception($"../../..")

#func _looking_at_self():
	#if !self.is_colliding():
		#looking_at_pickup = false
		#return
	#
	#var collider = self.get_collider()
	##print(collider.name)
	#
	## Check if collider has the interact method (common interface)
	#if collider.has_method("interact"):
		#looking_at_pickup = true
		#if Input.is_action_just_pressed("e") and self.global_position.distance_to(collider.global_position) <= grab_dis:
			#looking_at_pickup = false
			#visuais._pickable_icon_logic(collider.global_position)
			#collider.interact()
	#else:
		#looking_at_pickup = false
