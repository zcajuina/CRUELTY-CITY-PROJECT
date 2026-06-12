extends CharacterBody3D

var speed
var entradas : Vector2
var health : int = 100
@onready var gravity : float = get_gravity().y
@onready var player_sm: StateMachine = $PLAYER_SM
@onready var gun_sm: StateMachine = $GUN_SM

var kick_blocked : bool = false

var smooth_speed = 5.0
var walk_speed = 5.0
var run_speed = 0
var jump_vel = 2.2

var armor: int = 0
var max_armor: int = 10

var weapon_weight : float = 0.0

var crouching : bool = false

signal high_fall
signal damage
signal player_respawn
var gib

var suicide_double_tap : int = 0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var shape_cast: ShapeCast3D = $ShapeCast3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var tps_cam: Camera3D = $Head/TPS_PIVOT/SpringArm3D/TPS_CAM
@onready var sub_view: SubViewportContainer = $Head/Camera3D/visuais/SubViewportContainer
@onready var sub_view_cam: Camera3D = $Head/Camera3D/visuais/SubViewportContainer/SubViewport/SubViewCam
@onready var weapon_pivot: Node3D = $Head/Camera3D/visuais/SubViewportContainer/SubViewport/SubViewCam/WEAPON_PIVOT

@onready var shoot_timer: Timer = $shoot_timer
@onready var heart: Node3D = $Heart
@onready var gun: Node3D = $Head/Camera3D/GUN_RAYCAST
@onready var player_sprite: Node3D = $Player_sprite
@onready var hud: Control = $Control
@onready var visuais: Node3D = $Head/Camera3D/visuais
@onready var stock_market: Control = $Control/STOCK_MARKET


var old_vel : float = 0

func _ready():
	Global.player = self
	Global.player_sm = player_sm
	await get_tree().process_frame
	
	if gravity == 0:
		gravity = get_gravity().y
	Global._calculate_player_stats()
	await get_tree().process_frame
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global._player_caps()
	Global._receive_signal("update_infos")
	
	
	await get_tree().process_frame
	SceneChanger.player_offset_vector = Global.map_locs[Global.chosen_spawn]["POSITION"]
	if SceneChanger.player_offset_vector != Vector3.ZERO:
		self.global_position = SceneChanger.player_offset_vector
		#SceneChanger.player_offset_vector = Vector3.ZERO
	if SceneChanger.player_head_rot != 0:
		head.rotation_degrees.y = SceneChanger.player_head_rot
		#SceneChanger.player_head_rot = 0
	shape_cast.add_exception(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate head (Y-axis rotation)
		if not Global.on_menu:
			head.rotate_y(-event.relative.x * Global.player_sensi)
			# Rotate camera (X-axis rotation) with clamping
			var new_x_rotation = camera.rotation.x - event.relative.y * Global.player_sensi
			camera.rotation.x = clamp(new_x_rotation, deg_to_rad(-90), deg_to_rad(90))

#region PLAYER_MOVEMENT
func _move(spd : float,delta : float)->void:
	if not is_on_floor():
		velocity.y += (gravity -weapon_weight) * delta
		old_vel = velocity.y
	move_and_slide()
	fall_damage()
	# Get the input direction and handle the movement/deceleration.
	var direction = (head.transform.basis * transform.basis * Vector3(entradas.x, 0, entradas.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * spd
			velocity.z = direction.z * spd
		else:
			velocity.x = lerp(velocity.x, direction.x * spd, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * spd, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * spd, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * spd, delta * 3.0)

func _crouch():
	if Input.is_action_just_pressed("c"):
		if crouching == false:
			collision_shape.shape.height = 1
			head.position.y = 0.679
			shape_cast.position.y = -0.651
			crouching = true
		else:
			if shape_cast.is_colliding() == false:
				collision_shape.shape.height = 2
				head.position.y = 1.679
				shape_cast.position.y = -0.179
				crouching = false
			else:
				print(shape_cast.get_collider(0))
#endregion

func death():
	if gib == null:
		gib = preload("res://Scenes/Props/death_giblet.tscn").instantiate()
		get_parent().add_child(gib)
		sub_view.visible = false
		player_sprite.visible = false
		gib.global_position = head.global_position + Vector3(0,9,0)
		gib.global_rotation.x = camera.global_rotation.x
		gib.global_rotation.y = head.global_rotation.y
		hud.death_splash()
		Global.blood_splats.append(Global._spawn_part("res://Particles/part_big_blood_splat.tscn",self.global_position + Vector3(0,4,0)))
		Global._spawn_part("res://Particles/blood_splater_decal.tscn",self.global_position)
		SceneChanger.keep_health = false
		if Global.player_core != "DEATH":
			Global.player_cash_money -= 250
		Global.player_deaths += 1

func suicide():
	if player_sm.cur_state() != "dead":
		if Input.is_action_just_pressed("m"):
			suicide_double_tap += 1
			Global._show_message("PRESS 'M' AGAIN TO RETURN TO MENU. ","",3.5,"RED")
			#hud.suicide_alert_anim()
			if suicide_double_tap == 2:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Global._save_game()
				StockDb._save_stocks()
				FishSave._save_fish()
				await get_tree().process_frame
				Global._reset_player_inventory()
				Global.on_menu = false
				await get_tree().process_frame
				get_tree().change_scene_to_file("res://Scenes/HUD/MAIN_MENU.tscn")

func fall_damage():
	var diff = velocity.y - old_vel
	
	if diff >= 30:
		hit_no_anim(diff * 2)
		emit_signal("high_fall")
	old_vel = velocity.y

func heal(heal_ammount : int):
	health += heal_ammount
	health = clamp(self.health,0,Global.player_caps["max_health"])

func re_spawn():
	emit_signal("player_respawn")
	Global._reset_player_inventory()
	await get_tree().process_frame
	gib.queue_free()
	camera.current = false
	var player_child = load("res://Scenes/PLAYER.tscn").instantiate()
	self.get_parent().add_child(player_child)
	Global.re_spawn_player_at_spawn()
	self.queue_free()

func _rigid_body_spawn():
	if Input.is_action_just_pressed("ui_accept"):
		var rigid = load("res://Scenes/Props/RIGID_BODY_ITEM.tscn").instantiate()
		self.get_parent().add_child(rigid)
		rigid.add_collision_exception_with(self)
		rigid.global_position = head.global_position 
		
		# Set rotation to match player's head rotation
		rigid.global_rotation = head.global_rotation
		
		# Apply forward force relative to the rigid body's rotation
		var throw_force = 15.0  # Adjust this value as needed
		var forward_direction = -rigid.global_transform.basis.z  # Forward in Godot is -Z
		rigid.linear_velocity = forward_direction * throw_force

func _process(_delta: float) -> void:
	suicide()
	if Input.is_action_just_pressed("t"):
		hit(10)
		Global._show_message("10 DAMAGE TAKEN","")

func _physics_process(_delta):
	entradas = Input.get_vector("a", "d", "w", "s")
	#_crouch()

func hit(dam: int, _is_splash : bool = false):
	# Calculate damage after armor reduction
	var final_damage = _calculate_armor_damage(dam)
	
	# Apply damage
	health -= final_damage
	
	if health <= 0:
		gun_sm.change_state("gun_dead")
		player_sm.change_state("dead")
		death()
	else:
		emit_signal("damage")
		Global._spawn_part("res://Particles/part_blood_splat.tscn", head.global_position)

func _calculate_armor_damage(base_damage: int) -> int:
	if armor <= 0:
		return base_damage
	
	# Armor reduces damage (percentage-based)
	var armor_reduction = clamp(float(armor) / max_armor, 0.0, 0.8)  # Max 80% reduction
	var damage_reduced = base_damage * armor_reduction
	
	# Also degrade armor
	_damage_armor(base_damage)
	
	return int(max(base_damage - damage_reduced, 1))  # Minimum 1 damage

func _damage_armor(dam : int):
	armor -= dam

func hit_no_anim(dam : int):
	health -= dam
	if health <= 0:
		player_sm.change_state("dead")
		gun_sm.change_state("gun_dead")
		death()
