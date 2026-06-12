extends Node3D
@export var direction : int = 1

func _ready() -> void:
	self.rotation_degrees.z = randf_range(0,360) * direction

func _process(delta: float) -> void:
	self.rotation_degrees.z += 1 * direction
