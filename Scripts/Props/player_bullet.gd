extends Node3D
@onready var root: Node3D = $"."
@export var SPEED : float =  32
@onready var ray_cast: RayCast3D = $RayCast3D

var damg : int = 1

func _physics_process(delta: float) -> void:
	root.position += root.transform.basis * Vector3(0,0,-SPEED) * delta
	_check_wall_colision()

#func _on_hit_area_body_entered(body: Node3D) -> void:
	#if body == Global.player:
		#pass
	#else:
		#if body.is_in_group("foe"):
			#if body.has_method("_hit"):
				#body._hit(damg,self.global_position)
		#else:
			#if body.has_method("_hit"):
				#body._hit(damg,self.global_position)
		#self.queue_free()

func _check_wall_colision():
	if ray_cast.is_colliding():
		var body = ray_cast.get_collider()
		
		if body == Global.player:
			return
		
		if body != null:
			if body is CharacterBody3D:
				if body.has_method("_hit"):
					body._hit(damg,self.global_position)
					queue_free()
			else:
				if body.has_method("_hit"):
					body._hit(damg,self.global_position)
					queue_free()
			if not ray_cast.get_collider() is CharacterBody3D:
				queue_free()


func _on_kill_timer_timeout() -> void:
	queue_free()
