extends Node3D
@onready var head: Node3D = $"../.."
@onready var player: CharacterBody3D = $"../../.."
@onready var shoot_timer: Timer = $"../../../shoot_timer"
@onready var camera: Camera3D = $".."
@onready var world_node : Node3D = get_tree().current_scene
@onready var gun_sm: StateMachine = $"../../../GUN_SM"
@onready var visuais: Node3D = $"../visuais"
@onready var weapon_pivot: Node3D = $"../visuais/SubViewportContainer/SubViewport/SubViewCam/WEAPON_PIVOT"
const DROPPED_GUN : String = "res://Scenes/Props/PICK_UPS/DROPPED_GUN_RIGID_BODY.tscn"
@onready var foot_raycast: RayCast3D = $"../FOOT_RAYCAST"
var can_fish : bool = true

var aim_gun_exeptions : Array = ["HANDS", "FISHING_ROD","NEURON_DISABLER","UBERBLADE","MOLTEM_BOY"]

var reloading : bool = false
var kicking : bool = false

var looking_at_pickup : bool = false
var weap_type : String = "auto"
var weap_rate : float = 0
@onready var aiming : bool = false
var weap_damage : float = 0.0
var current_gun_name : String = ""
var current_gun_pos : String = "gun1"
var current_gun_model
var current_gun_nozzle
var has_lazer : bool = false
@onready var reload_timer: Timer = $"../../../reload_timer"
@onready var kick_timer: Timer = $"../../../kick_timer"

const cam_aim_fov : float = 55.0
const cam_sniper_aim_fov : float = 15.0
const cam_normal_fov : float = 75.0

var lazer_sight : Node3D

signal hit_enemy
signal kick_something
signal kick_nothing
signal breaking_safe
signal safe_break_stop
signal switch_gun
signal dropped_gun


func _reload() ->bool:
	if Global.player_gun_ammo[current_gun_pos]["cur_magazine"] < Global.guns_specs[current_gun_name]["max_magazine"]and Global.player_gun_ammo[current_gun_pos]["storage"] > 0 and reloading == false:
		reloading = true
		_true_reloading_function()
		return true
	else:
		return false

func _on_reload_timer_timeout() -> void:
	reloading = false
	#Calcular quanto precisa
	var needed_ammo = Global.guns_specs[current_gun_name]["max_magazine"] - Global.player_gun_ammo[current_gun_pos]["cur_magazine"]
	var ammo_to_add = min(needed_ammo,Global.player_gun_ammo[current_gun_pos]["storage"])
	
	Global.player_gun_ammo[current_gun_pos]["cur_magazine"] += ammo_to_add
	Global.player_gun_ammo[current_gun_pos]["storage"] -= ammo_to_add

func _true_reloading_function():
	reloading = false
	#Calcular quanto precisa
	var needed_ammo = Global.guns_specs[current_gun_name]["max_magazine"] - Global.player_gun_ammo[current_gun_pos]["cur_magazine"]
	var ammo_to_add = min(needed_ammo,Global.player_gun_ammo[current_gun_pos]["storage"])
	
	Global.player_gun_ammo[current_gun_pos]["cur_magazine"] += ammo_to_add
	Global.player_gun_ammo[current_gun_pos]["storage"] -= ammo_to_add

func _gun_aquire(gun_name : String):
	match current_gun_pos:
		"gun1":
			Global.player_inv[0] = gun_name
		"gun2":
			Global.player_inv[1] = gun_name
	_update_gun_values(gun_name)
	Global.player_gun_ammo[current_gun_pos]["cur_magazine"] = Global.guns_specs[gun_name]["max_magazine"]
	Global.player_gun_ammo[current_gun_pos]["storage"] = Global.guns_specs[gun_name]["max_storage"]
	visuais._weapon_model_switch()

func _gun_scavenge(gun_name : String, magazine : int, storage : int):
	match current_gun_pos:
		"gun1":
			Global.player_inv[0] = gun_name
		"gun2":
			Global.player_inv[1] = gun_name
	_update_gun_values(gun_name)
	Global.player_gun_ammo[current_gun_pos]["cur_magazine"] = magazine
	Global.player_gun_ammo[current_gun_pos]["storage"] = storage
	visuais._weapon_model_switch()
	emit_signal("switch_gun")

func _gun_model_spawner():
	if current_gun_model !=null:
		current_gun_model.queue_free()
	#current_gun_model = load(Global.gun_models[current_gun_name]["scene"]).instantiate()
	current_gun_model = load(str("res://Scenes/GUNS/",current_gun_name,".tscn")).instantiate()
	weapon_pivot.add_child(current_gun_model)
	
	var gun_child = current_gun_model.get_children(true)
	print(gun_child)
	for x in len(gun_child):
		if gun_child[x].name == "GUN_NOZZLE":
			current_gun_nozzle = gun_child[x]
		elif gun_child[x] is MultiMeshInstance3D:
			gun_child[x].set_layer_mask_value(1,false)
			gun_child[x].set_layer_mask_value(2,true)

func _update_gun_values(gun_name : String):
	weap_type = Global.guns_specs[gun_name]["type"]
	weap_rate = Global.guns_specs[gun_name]["rate"]
	shoot_timer.wait_time = weap_rate
	weap_damage = Global.guns_specs[gun_name]["damage"]
	current_gun_name = gun_name
	has_lazer = Global.guns_specs[gun_name].get("lazer_sight", false)
	_calc_peso()
	#_change_ray_cast_lenght() #<-If it's a long or small ranged weapon

func _calc_peso():
	var peso_1 = Global.guns_specs[Global.player_inv[0]].get("weight",0)
	var peso_2 = Global.guns_specs[Global.player_inv[1]].get("weight",0)
	player.weapon_weight = peso_1 + peso_2


func _switch_guns():
	if shoot_timer.is_stopped() and Global.on_menu == false:
		if Input.is_action_just_pressed("wheel_down") or Input.is_action_just_pressed("wheel_up"):
			if reloading == true:
				reloading = false
				gun_sm.change_state("gun_idle")
				reload_timer.stop()
				visuais.animation_player.stop()
				visuais._anim_verify_player("IDLE")
		
		if Input.is_action_just_pressed("wheel_up"):
			var lastgun_name = current_gun_name
			_update_gun_values(Global.player_inv[1])
			current_gun_pos = "gun2"
			_delete_bait_on_switch(lastgun_name)
			if lastgun_name != current_gun_name:
				visuais._weapon_model_switch()
				#_lazer_sight()
				#_gun_model_spawner()
				emit_signal("switch_gun")
		if Input.is_action_just_pressed("wheel_down"):
			var lastgun_name = current_gun_name
			_update_gun_values(Global.player_inv[0])
			current_gun_pos = "gun1"
			_delete_bait_on_switch(lastgun_name)
			if lastgun_name != current_gun_name:
				visuais._weapon_model_switch()
				#_lazer_sight()
				#_gun_model_spawner()
				emit_signal("switch_gun")


func _delete_bait_on_switch(lastgun_name : String):
	if lastgun_name != current_gun_name:
		if FishSave.fish_bait_node != null:
			FishSave.fish_bait_node.queue_free()

func _setup_gun_inventory():
	Global.player_gun_ammo["gun1"]["cur_magazine"] = Global.guns_specs[Global.player_inv[0]]["max_magazine"]
	Global.player_gun_ammo["gun1"]["storage"] = Global.guns_specs[Global.player_inv[0]]["max_storage"]
	
	Global.player_gun_ammo["gun2"]["cur_magazine"] = Global.guns_specs[Global.player_inv[1]]["max_magazine"]
	Global.player_gun_ammo["gun2"]["storage"] = Global.guns_specs[Global.player_inv[1]]["max_storage"]

#func _fire_press():
	#match weap_type:
		#"manual":
			#if Input.is_action_just_pressed("mb_left"):
				#_shoot()
		#"auto":
			#if Input.is_action_pressed("mb_left") and shoot_timer.is_stopped():
				#_shoot()
		#"hand":
			#if Input.is_action_just_pressed("mb_left"):
				#return
		#"manual-proj":
			#if Input.is_action_just_pressed("mb_left"):
				#_shoot_projectile()
		#"fishing-rod":
			#if Input.is_action_just_pressed("mb_left"):
				#_shoot_bait()

func _change_ray_cast_lenght():
	match Global.guns_specs[current_gun_name]["special factor"]:
		"shotgun":
			scale.y = 48
			scale.x = 128
		"null":
			scale.y = 128
			scale.x = 1
		_:
			pass

func _spawn_bullet_hole(hit_pos : Vector3):
	var bullet = load("res://Scenes/Props/bullet_hole.tscn").instantiate()
	world_node.add_child(bullet)
	bullet.rotation.y = randf_range(0,360)
	bullet.global_position = hit_pos
	Global.bullet_marks.append(bullet)

func _camera_shake_when_shoot():
	var ammount = Global.guns_specs[current_gun_name].get("shake",1)
	camera_rotation_clamp(ammount)

func camera_rotation_clamp(ammount : float):
	head.rotate_y(randf_range(-0.001,0.001))
	if camera.rotation_degrees.x > -90 and camera.rotation.x < 90:
		var tween = create_tween()
		#tween.set_ease(Tween.EASE_IN_OUT)
		#tween.set_trans(Tween.TRANS_EXPO)
		if camera.rotation_degrees.x >= 89:
			camera.rotation_degrees.x -= ammount /2
		tween.tween_property(camera,"rotation_degrees:x",clamp(camera.rotation_degrees.x + ammount,-89,89),0.01)
		await tween.finished
		#camera.rotate_x(deg_to_rad(ammount))
		#camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,-89,89)
	if camera.rotation.y != 0:
		camera.rotation.y = 0
		camera.rotation.z = 0

func aim_cam_shake():
	var ammount = (Global.guns_specs[current_gun_name].get("shake",1))/2
	camera_rotation_clamp(ammount)

func _gun_drop():
	if Input.is_action_just_pressed("q"):
		if current_gun_name != "HANDS":
			emit_signal("dropped_gun")
			if aiming:
				aiming = false
				_aim()
			var dropped_gun = load(DROPPED_GUN).instantiate()
			player.get_parent().add_child(dropped_gun)
			player.add_collision_exception_with(dropped_gun)
			dropped_gun.add_to_group("reset_picks")
			dropped_gun.gun_name = current_gun_name
			dropped_gun.current_magazine = Global.player_gun_ammo[current_gun_pos]["cur_magazine"]
			dropped_gun.current_storage = Global.player_gun_ammo[current_gun_pos]["storage"]
			dropped_gun.global_position = head.global_position + Vector3(0,-0.2,0)
			dropped_gun.global_rotation.y = head.global_rotation.y
			dropped_gun.global_rotation.x = camera.global_rotation.x
			var throw_force = 0
			if player.velocity != Vector3.ZERO:
				throw_force = 35
			else:
				throw_force = 10
			var forward_direction = -dropped_gun.global_transform.basis.z  # Forward in Godot is -Z
			dropped_gun.linear_velocity = forward_direction * throw_force
			_gun_scavenge("HANDS",0,0)
			visuais._weapon_model_switch()

func scripted_gun_drop():
	if current_gun_name != "HANDS":
		var dropped_gun = load(DROPPED_GUN).instantiate()
		player.get_parent().add_child(dropped_gun)
		dropped_gun.gun_name = current_gun_name
		dropped_gun.current_magazine = Global.player_gun_ammo[current_gun_pos]["cur_magazine"]
		dropped_gun.current_storage = Global.player_gun_ammo[current_gun_pos]["storage"]
		dropped_gun.global_position = head.global_position + Vector3(0,-0.2,0)
		dropped_gun.global_rotation = head.global_rotation
		var throw_force = 10.0  # Adjust this value as needed
		var forward_direction = -dropped_gun.global_transform.basis.z  # Forward in Godot is -Z
		dropped_gun.linear_velocity = forward_direction * throw_force
		_gun_scavenge("HANDS",0,0)

func _code_raycast_query(ray_range: float = 100.0, exclude_self: bool = true, collision_mask: int = 1) -> Dictionary:
	# Get center of screen
	var center = Vector2(576.0,324.0)
	#print(center)
	
	# Calculate ray from camera
	var ray_origin = camera.project_ray_origin(center)
	var ray_end = ray_origin + camera.project_ray_normal(center) * ray_range
	
	# Create query parameters
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	# Set collision mask (you can customize which layers to hit)
	query.collision_mask = collision_mask
	

	# Perform the raycast
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	
	return intersection

# Updated shoot function using the raycast
func _shoot():
	# Perform raycast with sniper range (10000)
	var intersection = _code_raycast_query(10000)
	
	# Check if we can shoot (not reloading and have ammo)
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		
		# Check if we hit something
		if not intersection.is_empty():
			var hit_pos = intersection.position
			var hit_normal = intersection.normal
			var col = intersection.collider
			
			# Handle different hit types
			if col is CharacterBody3D:
				# Hit a character - apply damage
				var damage = weap_damage - randi_range(0, weap_damage / 2)
				
				# Check if it's a headshot (optional)
				if intersection.collider.has_method("is_headshot") and intersection.collider.is_headshot(intersection):
					damage *= 2.0  # Double damage for headshots
					print("HEADSHOT!")
				if col.has_method("_hit"):
					col._hit(damage, hit_pos)
					emit_signal("hit_enemy")
				
			else:
				# Hit something else (wall, object, etc.)
				if col.has_method("_hit"):
					col.call("_hit")
				
				# Spawn bullet hole at hit position
				_spawn_bullet_hole(hit_pos)
		
		# Reduce ammo
		Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		
		# Camera shake based on aim state
		if aiming:
			aim_cam_shake()
		else:
			_camera_shake_when_shoot()

func _infinite_bullet_shoot():
	# Perform raycast with sniper range (10000)
	var intersection = _code_raycast_query(10000)
	
	# Check if we can shoot (not reloading and have ammo)
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		
		# Check if we hit something
		if not intersection.is_empty():
			var hit_pos = intersection.position
			var hit_normal = intersection.normal
			var col = intersection.collider
			
			# Handle different hit types
			if col is CharacterBody3D:
				# Hit a character - apply damage
				var damage = weap_damage - randi_range(0, weap_damage / 2)
				
				# Check if it's a headshot (optional)
				if intersection.collider.has_method("is_headshot") and intersection.collider.is_headshot(intersection):
					damage *= 2.0  # Double damage for headshots
					print("HEADSHOT!")
				if col.has_method("_hit"):
					col._hit(damage, hit_pos)
					emit_signal("hit_enemy")
				
			else:
				# Hit something else (wall, object, etc.)
				if col.has_method("_hit"):
					col.call("_hit")
				
				# Spawn bullet hole at hit position
				_spawn_bullet_hole(hit_pos)
		# Camera shake based on aim state
		if aiming:
			aim_cam_shake()
		else:
			_camera_shake_when_shoot()

func _shoot_shotgun():
	# Check if we can shoot (not reloading and have ammo)
	if aiming:
		aim_cam_shake()
	else:
		_camera_shake_when_shoot()
	
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		
		# Shotgun configuration
		var pellet_count = 8  # Number of pellets
		var spread_angle = 5.0  # Spread angle in degrees
		var pellet_damage = weap_damage / pellet_count  # Divide damage among pellets
		
		#var hit_enemies = []  # Track enemies hit to avoid multiple damage to same enemy
		var total_damage_dealt = 0
		
		# Get camera and center position once
		var center = Vector2(576.0, 324.0)
		var ray_origin = camera.project_ray_origin(center)
		var base_direction = camera.project_ray_normal(center)
		
		# Cast multiple pellets
		for i in range(pellet_count):
			# Calculate spread direction
			var spread = _calculate_spread(base_direction, spread_angle)
			var ray_end = ray_origin + spread * 10000  # Full range for shotguns
			
			# Create query for this pellet
			var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			query.collision_mask = 1  # Adjust as needed
			
			# Perform raycast
			var intersection = get_world_3d().direct_space_state.intersect_ray(query)
			
			# Check if we hit something
			if not intersection.is_empty():
				var hit_pos = intersection.position
				#var hit_normal = intersection.normal
				var col = intersection.collider
				
				# Handle different hit types
				if col is CharacterBody3D:
						# Calculate damage for this pellet (with slight random variation)
						var pellet_final_damage = pellet_damage - randi_range(0, pellet_damage / 4)
						
						# Apply damage
						if col.has_method("_hit"):
							col._hit(pellet_final_damage, hit_pos)
							total_damage_dealt += pellet_final_damage
							emit_signal("hit_enemy")
							#print("Shotgun hit ",col, " enemies for ", total_damage_dealt, " total damage")
						
				else:
					# Hit something else - only spawn bullet hole for first pellet that hits
					if col.has_method("_hit"):
						col.call("_hit")
					# Spawn bullet hole for first pellet that hits a surface
					_spawn_bullet_hole(hit_pos)
			await get_tree().process_frame
		
		# Reduce ammo
		Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		
		# Camera shake (more intense for shotgun)

			# Extra shake for shotgun feel
			#_camera_shake_when_shoot()

# Helper function to calculate spread direction
func _calculate_spread(base_direction: Vector3, spread_degrees: float) -> Vector3:
	# Convert spread to radians
	var spread_rad = deg_to_rad(spread_degrees)
	
	# Generate random angles within spread
	var random_yaw = randf_range(-spread_rad, spread_rad)
	var random_pitch = randf_range(-spread_rad, spread_rad)
	
	# Create rotation matrices
	var yaw_rotation = Quaternion(Vector3.UP, random_yaw)
	var pitch_rotation = Quaternion(Vector3.RIGHT, random_pitch)
	
	# Apply rotations to base direction
	var rotated_dir = yaw_rotation * base_direction
	rotated_dir = pitch_rotation * rotated_dir
	
	return rotated_dir.normalized()

#func _shoot_oold():
	#if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		#shoot_timer.start()
		#if self.is_colliding():
			#var hit_pos = self.get_collision_point()
			#var col = self.get_collider()
			#if col is CharacterBody3D:
				#var damage = weap_damage - randi_range(0,weap_damage/2)
				#col._hit(damage,hit_pos)
				#emit_signal("hit_enemy")
			#else:
				#if col.has_method("_hit"):
					#col.call("_hit")
				#_spawn_bullet_hole(hit_pos)
		#Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		#if aiming == true:
			#aim_cam_shake()
		#else:
			#_camera_shake_when_shoot()


func _shoot_dna():
	# Perform raycast with sniper range (10000)
	var intersection = _code_raycast_query(10000)
	
	# Check if we can shoot (not reloading and have ammo)
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		
		# Check if we hit something
		if not intersection.is_empty():
			var hit_pos = intersection.position
			var hit_normal = intersection.normal
			var col = intersection.collider
			
			# Handle different hit types
			if col is CharacterBody3D:
				if col.human:
					var col_pos = col.global_position
					Global.player_lives_taken += 1
					col.queue_free()
					var cball = preload("res://Scenes/Props/ORGANS/DNA_CANCER_BALLS.tscn").instantiate()
					Global.player.get_parent().add_child(cball)
					cball.global_position = col_pos
				else:
					var damage = weap_damage - randi_range(0, weap_damage / 2)
					
					col._hit(damage, hit_pos)
					emit_signal("hit_enemy")
			else:
				# Hit something else (wall, object, etc.)
				if col.has_method("_hit"):
					col.call("_hit")
				
				# Spawn bullet hole at hit position
				#_spawn_bullet_hole(hit_pos)
		
		# Reduce ammo
		Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		
		# Camera shake based on aim state
		if aiming:
			aim_cam_shake()
		else:
			_camera_shake_when_shoot()

func _bolt_acr():
	_infinite_bullet_shoot()
	var cancer_cloud = preload("res://Scenes/Props/bolt_cancer_cloud.tscn").instantiate()
	get_tree().current_scene.add_child(cancer_cloud)
	cancer_cloud.global_position = current_gun_nozzle.global_position
	

func _melee():
	# Perform raycast with sniper range (10000)
	var intersection = _code_raycast_query(1.8)
	
	# Check if we can shoot (not reloading and have ammo)
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		
		# Check if we hit something
		if not intersection.is_empty():
			var hit_pos = intersection.position
			var hit_normal = intersection.normal
			var col = intersection.collider
			
			# Handle different hit types
			if col is CharacterBody3D:
				# Hit a character - apply damage
				var damage = weap_damage - randi_range(0, weap_damage / 2)
				
				# Check if it's a headshot (optional)
				if intersection.collider.has_method("is_headshot") and intersection.collider.is_headshot(intersection):
					damage *= 2.0  # Double damage for headshots
					print("HEADSHOT!")
				if col.has_method("_hit"):
					col._hit(damage, hit_pos)
					emit_signal("hit_enemy")
				
			else:
				# Hit something else (wall, object, etc.)
				if col.has_method("_hit"):
					col.call("_hit")
				
				# Spawn bullet hole at hit position
				_spawn_bullet_hole(hit_pos)
		
		# Reduce ammo
		#Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		
		# Camera shake based on aim state
		if aiming:
			aim_cam_shake()
		else:
			_camera_shake_when_shoot()

func _shoot_projectile():
	if reloading == false and Global.player_gun_ammo[current_gun_pos]["cur_magazine"] > 0:
		shoot_timer.start()
		if current_gun_name != "NEURON_DISABLER":
			_spawn_bullet_instance_2()
		else:
			_spawn_bullet_instance_2("res://Scenes/Props/PLAYER_BULLET/NEURON_BULLET.tscn")
		Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		if aiming == true:
			aim_cam_shake()
		else:
			_camera_shake_when_shoot()





func _shoot_bait():
	pass
		#Global.player_gun_ammo[current_gun_pos]["cur_magazine"] -= 1
		#if aiming == true:
			#aim_cam_shake(0.01)
		#else:
			#_camera_shake_when_shoot()

func _spawn_bullet_instance(bullet_scene : String = "res://Scenes/Props/PLAYER_BULLET/PLAYER_BULLET.tscn"):
	var bullet = load(bullet_scene).instantiate()
	player.get_parent().add_child(bullet)
	bullet.damg = weap_damage
	bullet.global_position = head.global_position
	bullet.global_rotation.y = head.global_rotation.y
	bullet.global_rotation.x = camera.global_rotation.x

func _spawn_bullet_instance_2(bullet_scene : String = "res://Scenes/Props/PLAYER_BULLET/PLAYER_BULLET.tscn"):
	var bullet = load(bullet_scene).instantiate()
	player.get_parent().add_child(bullet)
	bullet.damg = weap_damage
	
	if current_gun_nozzle == null:
		return
	# Spawn at hand
	bullet.global_position = current_gun_nozzle.global_position
	
	# Raycast from camera to find exact crosshair target
	var ray_length = 1000
	var ray_origin = camera.global_position
	var ray_end = ray_origin + (-camera.global_transform.basis.z * ray_length)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_end
	query.collision_mask = 0b0001
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	var target_point = ray_end  # Default to far point if no hit
	
	if result:
		target_point = result.position
	
	# Calculate direction from hand to target point
	var direction = (target_point - current_gun_nozzle.global_position).normalized()
	
	# Rotate bullet
	bullet.look_at(bullet.global_position + direction, Vector3.UP)


func _spawn_bait_instance(throw_force: float):
	if current_gun_nozzle != null and head != null:
		if reloading == false:
				#shoot_timer.start()
				var bait = load("res://Scenes/Props/fishing_bait.tscn").instantiate()
				player.get_parent().add_child(bait)
				# Set position and rotation
				bait.global_position = current_gun_nozzle.global_position
				bait.global_position.y = current_gun_nozzle.global_position.y
				bait.global_rotation.y = head.global_rotation.y
				
				# Apply throw force in the direction the player is looking
					# Calculate forward direction based on camera/head rotation
				var forward_direction = -camera.global_transform.basis.z  # Z axis typically points forward in Godot
					
					# Apply velocity
				bait.velocity = forward_direction * throw_force/2
				print("bait spawned")

func _aim():
	if Global.on_menu == false:
		if Input.is_action_just_pressed("mb_right") and not aim_gun_exeptions.has(current_gun_name):
			aiming = not aiming
		
		if Input.is_action_just_pressed("wheel_down") or Input.is_action_just_pressed("wheel_up"):
			if aim_gun_exeptions.has(current_gun_name) and aiming:
				aiming = false
		
		match aiming:
			true:
				if weap_type == "sniper-manual" or weap_type == "sniper-auto":
					camera.fov = lerpf(camera.fov,cam_sniper_aim_fov,.1)
				else:
					camera.fov = lerpf(camera.fov,cam_aim_fov,.1)
			false:
				camera.fov = lerpf(camera.fov,cam_normal_fov,.1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if is_colliding():
		#print(get_collider())
	#else:
		#print("hitting_nothing")

func _ready() -> void:
	_setup_gun_inventory()
	_update_gun_values(Global.player_inv[0])
	#_gun_model_spawner()

func _physics_process(_delta: float) -> void:
	_switch_guns()
	_aim()
	_gun_drop()
	_kick_function()
	_lazer_sight()
	if Global.cur_st(Global.player.player_sm) != "dead":
		await get_tree().create_timer(0.5).timeout
		if lazer_sight != null:
			var intersection = _code_raycast_query()
			if not intersection.is_empty():
				lazer_sight.global_position = intersection.get("position",Vector3(0,0,0))

func _lazer_sight():
	if has_lazer == true:
		if lazer_sight == null:
			lazer_sight = preload("res://Particles/part_lazer_sight.tscn").instantiate()
			Global.add_child(lazer_sight)
		#lazer_sight.show()
		if Global.cur_st(Global.player.player_sm) != "dead":
			await get_tree().create_timer(0.5).timeout
			if lazer_sight != null:
				await get_tree().create_timer(2.5).timeout
				var intersection = _code_raycast_query()
				if not intersection.is_empty():
					if lazer_sight != null:
						if lazer_sight.visible == false:
							lazer_sight.show()
						lazer_sight.global_position = lerp(lazer_sight.global_position,intersection.get("position",Vector3(0,0,0)),0.5 * get_physics_process_delta_time())
					#lazer_sight.global_position = intersection.get("position",Vector3(0,0,0))
				else:
					if lazer_sight != null:
						lazer_sight.hide()
	else:
		if lazer_sight != null:
			lazer_sight.queue_free()



func _kick_function():
	if Global.player_sm.cur_state() == "dead":
		return
	if Global.player_sm.cur_state() == "interact":
		return
	if Global.player_sm.cur_state() == "emoting":
		return
	if Global.player.kick_blocked == false:
		if Input.is_action_just_pressed("f") and kicking == false:
			kicking = true
			emit_signal("kick_something")
			kick_timer.start()

func _on_kick_timer_timeout() -> void:
	kicking = false
	if foot_raycast.is_colliding():
		
		print("kicking something")
		var hit_pos = foot_raycast.get_collision_point()
		var col = foot_raycast.get_collider()
		if col is CharacterBody3D:
			if col.has_method("_hit"):
				var damage = int(500)
				col._hit(damage,hit_pos)
		else:
			if col.has_method("_hit"):
				var damage = int(500)
				col._hit(damage,hit_pos)
	else:
		emit_signal("kick_nothing")
		print("kicking nothing")
