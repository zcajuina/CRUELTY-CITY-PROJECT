extends Node3D

@export var time : float

func _ready() -> void:
	await get_tree().create_timer(time).timeout
	queue_free()
