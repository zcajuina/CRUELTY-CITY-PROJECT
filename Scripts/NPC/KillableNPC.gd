extends BaseNPC
class_name FoeNPC

@export var gun_holding : String = "PARASONIC_D2"
@export var head_rotation_speed: float = .0  # Adjust per enemy type
@export var see_distance : float = 40.5
@export var shooting_distance : float = 20
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var head: Node3D = $head
@onready var sm: StateMachine = $StateMachine
@onready var shoot_timer: Timer = $shoot_timer
@onready var gun_pos: Node3D = $VISUAIS/GUN_POS

var max_bullets : int = 0
var fire_rate : float = 0.2
var gun_damage : int = 0

const PART_BLOOD : String = "res://Particles/part_blood_splat.tscn"
const DROPPED_GUN : String = "res://Scenes/Props/PICK_UPS/DROPPED_GUN_RIGID_BODY.tscn"

var bullets : int = 5
@export var speed : float = 800.0
@export var acel : float = 100.0
signal got_hit

func interact():
	pass

func _ready()->void:
	await get_tree().process_frame
	setup_gun_values(gun_holding)
	_spawn_gun_model()

func setup_gun_values(gun_name : String):
	if gun_name == "":
		return
	fire_rate = Global.guns_specs[gun_name]["rate"]
	shoot_timer.wait_time = fire_rate
	max_bullets = Global.guns_specs[gun_name]["max_magazine"]
	gun_damage = Global.guns_specs[gun_name]["damage"] / 7

func _spawn_gun_model():
	if ResourceLoader.exists(str("res://Models/Guns/",gun_holding,".glb")):
		var gun_model = load(str("res://Models/Guns/",gun_holding,".glb")).instantiate()
		var gun_scale = 1
		gun_pos.add_child(gun_model)
		gun_model.rotation.y = deg_to_rad(90)
		gun_model.global_position = gun_pos.global_position + Vector3()
		gun_model.scale = Vector3(gun_scale,gun_scale,gun_scale)

func get_nodes_in_radius_advanced(origin_node, radius, collision_mask):
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsShapeQueryParameters3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius

	query.shape = sphere_shape
	query.transform = Transform3D(Basis(), origin_node.global_position)
	query.collision_mask = collision_mask

	var results = space_state.intersect_shape(query)
	var nearby_foes = []
	
	for result in results:
		var collider = result.collider
		# Handle both direct nodes and nodes via CollisionObject3D
		var node = collider
		if collider is CollisionObject3D:
			node = collider.get_parent()
		
		if node and node.is_in_group("foes"):
			nearby_foes.append(node)
	
	return nearby_foes

func _spawn_blood(pos : Vector3):
	var blood = preload(PART_BLOOD).instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = pos

func _blood_mark_spawner(_pos : Vector3):
	var chance = randi_range(0,10)
	if chance >=0 and chance <= 8:
		Global._spawn_part("res://Particles/part_small_blood_part.tscn",_pos,self)
	elif chance >=9 and chance <= 10:
		Global._spawn_part("res://Particles/part_blood_splat.tscn",_pos,self)

func _hit(damage : float = 1, _pos: Vector3 = Vector3.ZERO):
	if not dead:
		
		_blood_mark_spawner(_pos)
		health -= damage
		if health <= 0:
			if is_target:
				emit_signal("assasinated")
			
			#Global.emit_signal("kill")
			dead = true
			Global.player_lives_taken += 1
			Global.emit_signal("killed_something")
			#rotation_degrees.z = 90
			
	else:
		gib_health -= damage
		if gib_health <= 0:
			Global._spawn_part("res://Particles/part_big_blood_splat.tscn",_pos)
			Global._spawn_part("res://Particles/part_blood_decal.tscn",self.global_position,Global.player.get_parent())
			_drop_gun()
			_spawn_gib_organs()
			visible = false

func _spawn_gib_organs():
	var random_organ_dic = Global.gibbing_results[randi_range(1,3)]
	if not gib_snd.playing:
		gib_snd.play()
	for x in len(random_organ_dic):
		var organ  = load("res://Scenes/Props/ORGANS/GenericRigidOrgan.tscn").instantiate()
		self.get_parent().add_child(organ)
		organ.global_position = self.global_position + Vector3(0,0.5,0)
		organ.rotation = Vector3(randf_range(0,5),randf_range(0,5),randf_range(0,5))
		organ.organ_name = random_organ_dic[x]
	#Global.player_lives_taken += 1
	#Global._receive_signal("kill")
	queue_free()

func _drop_gun():
	if gun_holding != "":
		var gun_instance = load(DROPPED_GUN).instantiate()
		get_tree().current_scene.add_child(gun_instance)
		gun_instance.gun_name = gun_holding
		gun_instance.current_magazine = bullets
		gun_instance.current_storage = Global.guns_specs[gun_holding]["max_storage"]
		gun_instance.global_position = self.global_position + Vector3(0,0.2,0)
		gun_instance.global_rotation.y = deg_to_rad(randf_range(0,90))

func look_at_player_y():
	var self_pos = global_transform.origin
	var path_pos = Global.player.global_position
	
	var target_pos = Vector3(path_pos.x, self_pos.y, path_pos.z)
	look_at(target_pos)

func look_at_path():
	var self_pos = global_transform.origin
	var path_pos = nav.get_next_path_position()
	
	var target_pos = Vector3(path_pos.x, self_pos.y, path_pos.z)
	if target_pos != global_position:
		look_at(target_pos)

func head_turn(speed: float, delta: float) -> void:
	var target_pos: Vector3 = Global.player.heart.global_position
	var to_target: Vector3 = (target_pos - head.global_transform.origin).normalized()
	
	# Get current and desired rotations as quaternions
	var current_quat: Quaternion = head.global_transform.basis.get_rotation_quaternion()
	var desired_basis: Basis = Basis.looking_at(to_target, Vector3.UP)
	var desired_quat: Quaternion = desired_basis.get_rotation_quaternion()
	
	# Smoothly interpolate using quaternion slerp
	var new_quat: Quaternion = current_quat.slerp(desired_quat, clamp(speed * delta, 0.0, 1.0))
	head.global_transform.basis = Basis(new_quat)

#função de verificar a vida do jogador
func look_alive():
	if Global.player.health <= 0:
		sm.change_state("foe_stop")

func _process(delta: float) -> void:
	look_alive()

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()
