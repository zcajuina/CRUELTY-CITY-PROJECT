extends SubViewportContainer

@onready var fish_root: Node3D = $SubViewport/FISH_ROOT

var mouse_inside: bool = false
var last_mouse_position: Vector2
var rotation_speed: float = 0.02  # Rotation amount per pixel moved
var rotation_direction : int = 1

func _ready():
	# Enable mouse filtering to receive input events
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_mouse_entered() -> void:
	mouse_inside = true
	last_mouse_position = get_local_mouse_position()
	print("Mouse entered viewport")

func _on_mouse_exited() -> void:
	mouse_inside = false
	print("Mouse exited viewport")

func _input(event: InputEvent) -> void:
	if not mouse_inside:
		return
	
	# Check if it's a mouse motion event
	if event is InputEventMouseMotion:
		var current_mouse_pos = event.position
		
		# Calculate horizontal movement direction
		var delta_x = current_mouse_pos.x - last_mouse_position.x
		
		# Rotate fish based on mouse direction
		if delta_x:
			fish_root.rotation.y += rotation_speed * delta_x
			print(delta_x)
		if delta_x > 0:
			rotation_direction = 1
		elif delta_x < 0:
			rotation_direction = -1
		#if delta_x > 0:
			## Mouse moved right - rotate fish to the right
			#fish_root.rotate_y(-rotation_speed * delta_x * 0.01)  # Scale down the movement
			#print("Moving right - rotating fish right")
		#elif delta_x < 0:
			## Mouse moved left - rotate fish to the left
			#fish_root.rotate_y(-rotation_speed * delta_x * 0.01)  # Negative delta_x becomes positive rotation
			#print("Moving left - rotating fish left")
		
		# Update last mouse position
		last_mouse_position = current_mouse_pos

func _process(delta: float) -> void:
	if not mouse_inside:
		fish_root.rotation.y += rotation_direction * rotation_speed
