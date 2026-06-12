extends State
@onready var root: CharacterBody3D = $"../.."

func enter() -> void:
	root.rotation.x = deg_to_rad(90)
