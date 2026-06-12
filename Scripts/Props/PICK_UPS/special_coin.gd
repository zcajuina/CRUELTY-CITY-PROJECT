extends RigidBody3D

func interact():
	var daddy = Global.player.get_node("ImpCoiny")
	daddy.has_coin = true
	queue_free()

func _physics_process(delta: float) -> void:
	if global_position.y <0:
		if Global.player != null:
			Global.player.get_node("ImpCoiny").has_coin = true
			Global._show_message("TOKEN FELL OUT OF BOUNDS","TOKEN MAGICALLY RETURNED.SORRY :,(",2.0)
		queue_free()
