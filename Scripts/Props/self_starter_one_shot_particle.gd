extends GPUParticles3D
@export var time : float = 1
@export var delete : bool = true

func _ready() -> void:
	self.emitting = true
	await get_tree().create_timer(time).timeout
	if delete:
		queue_free()
