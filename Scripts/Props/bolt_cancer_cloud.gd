extends Node3D
@onready var mini_cloud: MeshInstance3D = $MINI_CLOUD
@onready var cancer_root: Node3D = $CANCER_ROOT
@onready var area_3d: Area3D = $MINI_CLOUD/Area3D
@onready var cancer_death_timer: Timer = $CANCER_DEATH_TIMER


func _ready():
	_spawn_children()

#func _process(delta: float) -> void:
	#var cloud_scale = clamp(sine_wave(1.2,1.05),0.2,100)
	#mini_cloud.scale = lerp(mini_cloud.scale,Vector3(cloud_scale,cloud_scale,cloud_scale), 0.05)


func _spawn_children():
	var cloud_center = mini_cloud.position
	var cloud_radius = 5.25
	var spawn_count = 16
	
	for x in range(spawn_count):
		var child = mini_cloud.duplicate()
		#await get_tree().process_frame
		cancer_root.add_child(child)
		
		# Random point inside sphere
		var random_direction = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		
		var random_distance = randf_range(0, cloud_radius)
		var random_position = cloud_center + random_direction * random_distance
		
		child.position = random_position
		child.rotation = Vector3(
			randf_range(0, TAU),
			randf_range(0, TAU),
			randf_range(0, TAU)
		)


#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("space"):
		#var kids = cancer_root.get_children()
		#for x in kids:
			#x.queue_free()
		#_spawn_children()
	
func _on_cancer_cloud_tick_timeout() -> void:
	var lista = area_3d.get_overlapping_bodies()
	for x in lista:
		if x != null:
			if x == Global.player:
				if Global.player_core == "DEATH":
					pass
				else:
					x.hit(7)
			elif x.has_method("_hit"):
				x._hit(3)
				print("HIT_BODIE ",x.name)


func _on_cancer_death_timer_timeout() -> void:
	queue_free()
