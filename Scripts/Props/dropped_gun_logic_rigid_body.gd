extends RigidBody3D
class_name DroppedGun
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@export var gun_name : String = ""
@export var current_magazine : int = 0
@export var current_storage : int = 0
@export var special_gun_retreive : bool = false
@export var full_magazine : bool = false
@onready var kill_spawn: Timer = $KILL_SPAWN

var collision_generated: bool = false

func _ready() -> void:
	await get_tree().process_frame
	self.add_collision_exception_with(Global.player)
	csg_box_3d.hide()
	if special_gun_retreive:
		if Global.guns_owned.has(gun_name):
			self.queue_free()
		else:
			print(gun_name, " NOT FOUND ON PLAYER INV")
			current_magazine = Global.guns_specs[gun_name].get("max_magazine",1)
			current_storage = Global.guns_specs[gun_name].get("max_storage",1)
	else:
		kill_spawn.start()
	if full_magazine:
		current_magazine = Global.guns_specs[gun_name].get("max_magazine",1)
		current_storage = Global.guns_specs[gun_name].get("max_storage",1)
	
	#add_exeption_to_foes()
	
	# Disable physics temporarily while generating collision
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	# Wait for everything to be ready
	await get_tree().process_frame
	
	# Load and add the gun mesh
	if ResourceLoader.exists(str("res://Models/Guns/", gun_name, ".glb")):
		var mesh = load(str("res://Models/Guns/", gun_name, ".glb")).instantiate()
		self.add_child(mesh)
		mesh.rotation.x = deg_to_rad(90)
		
		# Generate collision from the mesh
		await _generate_collision_from_mesh(mesh)
	
	# Enable physics after collision is ready
	freeze = false
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func _generate_collision_from_mesh(mesh_node: Node3D) -> void:
	# Find all MeshInstance3D nodes in the gun model
	var mesh_instances: Array[MeshInstance3D] = []
	_find_mesh_instances(mesh_node, mesh_instances)
	
	if mesh_instances.is_empty():
		print("No mesh instances found in gun: ", gun_name)
		# Fallback to simple collision shape
		var fallback_collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(0.5, 0.2, 0.3)
		fallback_collision.shape = box_shape
		add_child(fallback_collision)
		return
	
	# Create collision shapes for each mesh instance
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			_create_simple_collision(mesh_instance)
	
	# Wait for collision to be processed
	await get_tree().process_frame
	print("Collision generated for gun: ", gun_name, " (", mesh_instances.size(), " shapes)")

func _find_mesh_instances(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	
	for child in node.get_children():
		_find_mesh_instances(child, result)

func _create_collision_from_mesh(mesh_instance: MeshInstance3D) -> void:
	var mesh = mesh_instance.mesh
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	
	# Get the mesh data
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	
	if vertices.is_empty():
		return
	
	# Create a convex shape from the mesh vertices
	var convex_shape = ConvexPolygonShape3D.new()
	
	# Collect all unique vertices (simplified for performance)
	var vertex_list: Array[Vector3] = []
	for v in vertices:
		vertex_list.append(v)
	
	convex_shape.set_points(vertex_list)
	collision_shape.shape = convex_shape
	
	# Set position and rotation to match the mesh instance
	collision_shape.global_position = mesh_instance.global_position
	collision_shape.global_rotation = mesh_instance.global_rotation
	
	# Add to rigidbody
	add_child(collision_shape)

# Alternative: Use multiple convex shapes for better accuracy
func _create_concave_collision(mesh_instance: MeshInstance3D) -> void:
	var mesh = mesh_instance.mesh
	
	# Create a concave shape (more accurate but heavier)
	var concave_shape = ConcavePolygonShape3D.new()
	
	# Get all faces from the mesh
	var faces = mesh.get_faces()
	concave_shape.set_faces(faces)
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = concave_shape
	collision_shape.global_position = mesh_instance.global_position
	collision_shape.global_rotation = mesh_instance.global_rotation
	
	add_child(collision_shape)

# Alternative: Use box colliders for simple guns (performance)
func _create_simple_collision(mesh_node: Node3D) -> void:
	# Calculate bounding box of the entire gun
	var aabb: AABB
	var first = true
	
	var mesh_instances: Array[MeshInstance3D] = []
	_find_mesh_instances(mesh_node, mesh_instances)
	
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			var mesh_aabb = mesh_instance.mesh.get_aabb()
			var transformed_aabb = mesh_instance.transform * mesh_aabb
			
			if first:
				aabb = transformed_aabb
				first = false
			else:
				aabb = aabb.merge(transformed_aabb)
	
	if not first:
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = aabb.size
		collision_shape.shape = box_shape
		collision_shape.position = aabb.get_center()
		add_child(collision_shape)

func add_exeption_to_foes():
	for foe in get_tree().get_nodes_in_group("foe"):
		if foe is CharacterBody3D:
			self.add_collision_exception_with(foe)

func interact():
	# Disable physics while interacting
	freeze = true
	
	if Global.player.gun.current_gun_name == gun_name:
		Global.player_gun_ammo[Global.player.gun.current_gun_pos]["storage"] += current_storage
		current_storage = 0
	else:
		if Global.player.gun.current_gun_name != "HANDS":
			retreive_and_create()
		
		Global.player.gun._gun_scavenge(gun_name, current_magazine, current_storage)
		
		if special_gun_retreive:
			check_if_has_gun()
		
		queue_free()

func retreive_and_create():
	var world = self.get_parent()
	var gun_drop = load("res://Scenes/Props/PICK_UPS/DROPPED_GUN_RIGID_BODY.tscn").instantiate()
	world.add_child(gun_drop)
	gun_drop.global_position = self.global_position + Vector3(0, 0.2, 0)
	gun_drop.gun_name = Global.player.gun.current_gun_name
	gun_drop.current_magazine = Global.player_gun_ammo[Global.player.gun.current_gun_pos]["cur_magazine"]
	gun_drop.current_storage = Global.player_gun_ammo[Global.player.gun.current_gun_pos]["storage"]

func check_if_has_gun():
	var found = false
	if Global.guns_owned.has(gun_name):
		found = true
	
	if not found:
		Global.guns_owned.append(gun_name)
		Global._show_message(gun_name + " AQUISITION COMPLETE!",gun_name+" CAN NOW BE EQUIPED ON THE MENU.")
		Global._save_game()

func _on_kill_spawn_timeout() -> void:
	queue_free()
