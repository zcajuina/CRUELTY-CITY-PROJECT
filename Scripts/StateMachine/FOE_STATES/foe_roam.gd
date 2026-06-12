extends State
@onready var root: CharacterBody3D = $"../.."
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"

var roam_range: float = 9.0

func enter() -> void:
	nav.target_position = _get_valid_roam_point()

func physics_update(delta: float) -> void:
	if root.health <= 0:
		state_machine.change_state("foe_dead")
		return
	
	# Check if player is detected
	if root.global_position.distance_to(Global.player.global_position) <= root.see_distance:
		state_machine.change_state("foe_chase")
		return
	
	# Movement logic
	var direction = (nav.get_next_path_position() - root.global_position).normalized()
	direction.y = 0
	root.velocity = root.velocity.lerp(direction * root.speed, root.acel * delta)
	root.move_and_slide()
	root.look_at_path()
	
	# Get new point when reached destination
	if nav.is_navigation_finished() or nav.distance_to_target() <= 2.0:
		nav.target_position = _get_valid_roam_point()

func _get_valid_roam_point() -> Vector3:
	var attempts = 0
	while attempts < 5:
		var random_point = Vector3(
			root.global_position.x + randf_range(-roam_range, roam_range),
			root.global_position.y,
			root.global_position.z + randf_range(-roam_range, roam_range)
		)
		
		# Check if point is on navigation mesh
		var map = nav.get_navigation_map()
		var closest_point = NavigationServer3D.map_get_closest_point(map, random_point)
		
		if closest_point.distance_to(random_point) < 2.0:  # Valid point found
			return closest_point
		
		attempts += 1
	
	# Fallback to current position if no valid point found
	return root.global_position


func _on_chase_timer_timeout() -> void:
	pass # Replace with function body.
