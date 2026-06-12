extends CSGSphere3D
@export var spawn_gibs : bool = false


func _hit(damage : float = 1, pos: Vector3 = Vector3.ZERO):
	if spawn_gibs:
		pass
	self.queue_free()
