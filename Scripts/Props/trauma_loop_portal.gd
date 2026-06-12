extends Node3D

var is_ready : bool = false

func _on_area_3d_body_exited(body: Node3D) -> void:
	if is_ready:
		if body == Global.player:
			get_tree().quit()

func bob_sin(_delta: float, node: Node3D, speed: float = 2.0, amount: float = 0.1, time_offset: float = 0.0,positive : bool = false) -> void:
	"""
	Simple sine wave bobbing motion for 3D nodes.
	
	Parameters:
	- delta: Time delta from _process
	- node: The Node3D to apply bobbing to
	- speed: How fast the bob cycles (Hz)
	- amount: How far up/down it moves
	- time_offset: Phase offset for multiple bobbing objects
	"""
	var time = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	var bob_value = sin((time + time_offset) * speed * TAU) * amount
	
	# Apply to node's position (only Y axis for up/down bobbing)
	if positive:
		node.position.y += bob_value
	else:
		node.position.y -= bob_value
	# Optional: Also add slight rotation for more natural look
	#node.rotation.z = sin((time + time_offset) * speed * TAU * 0.5) * amount * 0.1
