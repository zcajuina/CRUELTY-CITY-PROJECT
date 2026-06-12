extends CharacterBody3D
class_name BaseNPC

@export var inspect_name : String = "RANDOM CIVILIAN"
@export var inspect_desc : String = "TALK"

var human : bool = true
@export var is_target : bool = false
var dead : bool = false

@export var dialog_tag : String
var dialog_array : Array
@onready var visuais: Node3D = $VISUAIS

@onready var world_node : Node3D = get_tree().current_scene
@export var health : float = 100
var base_health : float = health
@export var gib_health : int = 0
@onready var gib_snd: AudioStreamPlayer3D = $GIB_SND
@onready var target_sprite: Sprite3D = $TARGET_SPRITE

@export var min_distance: float = 5.0    # When player is this close, sprite is normal size
@export var max_distance: float = 50.0   # When player is this far, sprite is at max scale
@export var min_scale: float = 0.3     # Scale when player is very close
@export var normal_scale: float = 0.25    # Scale at min_distance
@export var max_scale: float = 0.56       # Scale when player is at max_distance or farther


signal assasinated


func _blood_mark_spawner(_pos : Vector3):
	var chance = randi_range(0,10)
	if chance >=0 and chance <= 8:
		Global._spawn_part("res://Particles/part_small_blood_part.tscn",_pos,self)
	elif chance >=9 and chance <= 10:
		Global._spawn_part("res://Particles/part_blood_splat.tscn",_pos,self)

func _hit(damage : float = 1, _pos: Vector3 = Vector3.ZERO):
	if not dead:
		
		_blood_mark_spawner(_pos)
		if damage >= base_health:
			_spawn_gib_organs()
		else:
			health -= damage
			if health <= 0:
				if is_target:
					emit_signal("assasinated")
				
				#Global.emit_signal("kill")
				dead = true
				Global.player_lives_taken += 1
				Global.emit_signal("killed_something")
				rotation_degrees.z = 90
			
	else:
		gib_health -= damage
		if gib_health <= 0:
			Global._spawn_part("res://Particles/part_big_blood_splat.tscn",_pos)
			Global._spawn_part("res://Particles/part_blood_decal.tscn",self.global_position,self.get_parent())
			_spawn_gib_organs()
			visible = false

func _spawn_gib_organs():
	var random_organ_dic = Global.gibbing_results[randi_range(1,3)]
	if gib_snd != null:
		if not gib_snd.playing:
			gib_snd.play()
	for x in len(random_organ_dic):
		var organ  = load("res://Scenes/Props/ORGANS/GenericRigidOrgan.tscn").instantiate()
		world_node.add_child(organ)
		organ.global_position = self.global_position + Vector3(0,0.5,0)
		organ.rotation = Vector3(randf_range(0,5),randf_range(0,5),randf_range(0,5))
		organ.organ_name = random_organ_dic[x]
	#Global.player_lives_taken += 1
	#Global._receive_signal("kill")
	queue_free()

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()
	if Global.player != null:
		var scale_factor = _calculate_scale_factor(self.global_position.distance_to(Global.player.global_position))
		if target_sprite != null:
			target_sprite.scale = Vector3(scale_factor,scale_factor,scale_factor)

func interact():
	#print(dialog_array)
	if not dead:
		var direction = (Global.player.global_position - global_position).normalized()
		var target_angle = atan2(direction.x, direction.z)
		visuais.rotation.y = target_angle
		
		Global.player.visuais._look_at_me(global_position)


		Global.player.hud.dbox.start_dialogue(Diag.get_dialog(dialog_tag))

func _calculate_scale_factor(distance: float) -> float:
	# If player is very close (closer than min_distance)
	if distance <= min_distance:
		# Scale down as player gets closer
		var t = distance / min_distance  # 0 to 1
		return lerp(min_scale, normal_scale, t)
	
	# If player is between min_distance and max_distance
	elif distance <= max_distance:
		# Scale up as player gets farther
		var t = (distance - min_distance) / (max_distance - min_distance)  # 0 to 1
		return lerp(normal_scale, max_scale, t)
	
	# If player is farther than max_distance
	else:
		# Stay at max scale
		return max_scale
