extends Node3D
@onready var gun: Node3D = $"../GUN_RAYCAST"
@onready var foot: RayCast3D = $"../FOOT_RAYCAST"
@onready var head: Node3D = $"../.."

@onready var weap: Node3D = $SubViewportContainer/SubViewport/SubViewCam/WEAPON_PIVOT
@onready var weapon_pivot: Node3D = $SubViewportContainer/SubViewport/SubViewCam/WEAPON_PIVOT
@onready var cross_hair: Sprite2D = $SubViewportContainer/Control/CROSS_HAIR
@onready var reload_face: Sprite2D = $"../../../Control/HUD_VARS/RELOAD_FACE"
@onready var heal_bloom: ColorRect = $"../../../Control/HUD_VARS/HEAL_BLOOM"
@onready var hud: Control = $"../../../Control"
@onready var player_sprite: Node3D = $"../../../Player_sprite"

@onready var player: CharacterBody3D = $"../../.."

@onready var player_sm: StateMachine = $"../../../PLAYER_SM"
@onready var gun_sm: StateMachine = $"../../../GUN_SM"
@onready var heal_snd: AudioStreamPlayer = $"../../../SOUNDS/HEAL_SND"
@onready var foot_raycast: RayCast3D = $"../FOOT_RAYCAST"
@onready var gun_raycast: RayCast3D = $"../GUN_RAYCAST"

@onready var camera: Camera3D = $".."

@onready var pickable_hand: AnimatedSprite2D = $SubViewportContainer/Control/PICKABLE_HAND

@onready var fall_snd: AudioStreamPlayer = $"../../../SOUNDS/FALL_SND"
@onready var foot_root: Node3D = $SubViewportContainer/SubViewport/SubViewCam/FOOT_ROOT
@onready var foot_anim_player: AnimationPlayer = $SubViewportContainer/SubViewport/FOOT_ANIM_PLAYER

@onready var sub_view_cam: Camera3D = $SubViewportContainer/SubViewport/SubViewCam

@onready var shoot_snd: AudioStreamPlayer = $"../../../SOUNDS/SHOOT_SND"
@onready var shoot_snd_2: AudioStreamPlayer = $"../../../SOUNDS/SHOOT_SND2"

@onready var shaker: ShakerComponent3D = $"../ShakerComponent3D"



var current_player_model : Node3D
var animation_player : AnimationPlayer
var gun_anim_player : AnimationPlayer
var player_skeleton : Skeleton3D
var atch : BoneAttachment3D
var gun_model : Node3D
var player_fps_meshes_list : Array
var player_tps_meshes_list : Array

var current_player_body_model: Node3D
var animation_player_body: AnimationPlayer
var player_body_skeleton: Skeleton3D


const base_gun_pos : Vector3 = Vector3(0.444,-0.299,-0.45)
const aim_gun_pos : Vector3 = Vector3(-0.5/4,0,0.05/4)

var mouse_vel : Vector2 = Vector2(0,0)

var fish_tilting : bool = false
var fishing_bait_out : bool = false
var thinker_with_gun : bool = false



var played_gun_anim  : bool = false



func _ready() -> void:
	gun.connect("hit_enemy",_on_signal_received.bind("hit_enemy"))
	gun.connect("kick_something",_on_signal_received.bind("kick_something"))
	gun.connect("kick_nothing",_on_signal_received.bind("kick_nothing"))
	gun.connect("breaking_safe",_on_signal_received.bind("breaking_safe"))
	gun.connect("safe_break_stop",_on_signal_received.bind("safe_break_stop"))
	await get_tree().process_frame
	_weap_and_hands_model_instantiate()
	_player_sprite_instantiate()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate head (Y-axis rotation)
		mouse_vel = event.relative

func _heal_anim():
	heal_snd.play()
	heal_bloom.visible = true
	heal_bloom.self_modulate.a = 0.75  # Set initial alpha to fully visible
	
	var alpha_tween = create_tween()
	alpha_tween.set_parallel(true)
	alpha_tween.set_ease(Tween.EASE_IN_OUT)
	alpha_tween.tween_property(heal_bloom, "self_modulate:a", 0.0, 0.3)
	await alpha_tween.finished
	heal_bloom.visible = false

func _on_signal_received(sig : String):
	match sig:
		"hit_enemy":
			_enemy_hit_cross_anim()
		"kick_something":
			kick_anim_via_code(true)
		"kick_nothing":
			kick_anim_via_code(false)
		"breaking_safe":
			foot_anim_player.play("BREAKING_SAFE")
		"safe_break_stop":
			foot_anim_player.play("RESET")

func _shake_cam(intensity : float = 0.05,duration :float = 1, speed : float = 1,):
	shaker.set_intensity(intensity)
	shaker.set_shake_speed(speed)
	shaker.set_duration(duration)
	shaker.play_shake()
	#await shaker.get_duration()
	#shaker.stop_shake()

func _enemy_hit_cross_anim():
	cross_hair.show()
	var t1 = create_tween()
	t1.tween_property(cross_hair,"scale",Vector2(0.30,0.30),0.02)
	await t1.finished
	var t2 = create_tween()
	t2.tween_property(cross_hair,"scale",Vector2(0.06,0.06),0.2)
	await t2.finished
	cross_hair.hide()


#func _instantiate_player_hands():
	#var model_path = "res://Models/DEFAULT_PLAYER_MODELS/noanim_FPS_ARM_SETUP.glb"
	#var anim_path = "res://Animations/FPS_DEFAULT_ANIMS.res"
	#
	#current_player_model = load(model_path).instantiate()
	#sub_view_cam.add_child(current_player_model)
	#current_player_model.position = Vector3(0,0,0)
	#_set_visibility_layers(current_player_model,2)
	#
	#animation_player = AnimationPlayer.new()
	#current_player_model.add_child(animation_player)
	#
	#var anim_lib = load(anim_path)
	#animation_player.add_animation_library("default",anim_lib)
	#print(animation_player.get_animation_list())
	#
	#animation_player.play("default/REVOLVER_SHOOT")
	#player_skeleton = _find_skeleton(current_player_model)
	#
	#print(player_skeleton)
	#
	#var gun_root_bone = player_skeleton.find_bone("GUN_ROOT.L")
	#print(gun_root_bone)
	#
	#atch = BoneAttachment3D.new()
	#player_skeleton.add_child(atch)
	#atch.bone_name = "GUN_ROOT.L"
	#atch.bone_idx = gun_root_bone
	#
	#
	#atch.position = Vector3(0.649,-0.279,-0.918)
	#atch.rotation_degrees = Vector3(-85.2,17.2,75.1)
	#await get_tree().process_frame
	#
	#var gun_model = preload("res://Models/Guns/REVOLVER.glb").instantiate()
	#atch.add_child(gun_model)
	#
	#_set_visibility_layers(gun_model,2)
	#
	#gun_model.position = Vector3(0,0.1,0)
	#gun_model.rotation_degrees = Vector3(90,0,0)


func _gun_verifications_before_instantiation():
	if gun.current_gun_name != "HANDS":
		if Global.advanced_guns.has(gun.current_gun_name):
			gun_model = load("res://Scenes/GUNS/"+str(gun.current_gun_name)+".tscn").instantiate()
			print("TSCN GUN MODEL FOUND")
		else:
			gun_model = load("res://Models/Guns/"+str(gun.current_gun_name)+".glb").instantiate()
			print("GLB GUN MODEL FOUND")
		atch.add_child(gun_model)
		if ResourceLoader.exists("res://Sounds/GUN_FIRE/"+gun.current_gun_name+".mp3"):
			match gun.current_gun_pos:
				"gun1":
					shoot_snd.stream = load("res://Sounds/GUN_FIRE/"+gun.current_gun_name+".mp3")
				"gun2":
					shoot_snd_2.stream = load("res://Sounds/GUN_FIRE/"+gun.current_gun_name+".mp3")
		else:
			match gun.current_gun_pos:
				"gun1":
					shoot_snd.stream = null
				"gun2":
					shoot_snd_2.stream = null
	if gun.current_gun_name == "FISHING_ROD":
		var fishing_line = preload("res://Scenes/GUNS/FISHING_LINE.tscn").instantiate()
		gun_model.add_child(fishing_line)


func load_custom_player_model():
	var model_path = Global.custom_char_path + "CUSTOM_PLAYER_HANDS.glb"
	
	# Verifica se o arquivo existe
	if not FileAccess.file_exists(model_path):
		print("Arquivo não encontrado: ", model_path)
		return null
	
	# Carrega o arquivo GLB usando GLTFDocument
	var gltf = GLTFDocument.new()
	var image = Image.new()
	var ctx = GLTFState.new()
	
	# Abre o arquivo e carrega
	var file = FileAccess.open(model_path, FileAccess.READ)
	if file:
		var error = gltf.append_from_file(model_path, ctx)
		if error == OK:
			# Gera a cena a partir do GLTF
			var scene = gltf.generate_scene(ctx)
			if scene:
				print("Modelo carregado com sucesso!")
				return scene
			else:
				print("Erro ao gerar cena do modelo")
				return null
		else:
			print("Erro ao carregar GLB: ", error)
			return null
	else:
		print("Erro ao abrir arquivo")
		return null




func _player_sprite_instantiate():
	# Clear existing model
	if current_player_body_model != null:
		current_player_body_model.queue_free()
	
	# Load the appropriate model
	if Global.player_skin_name == "CUSTOM":
		current_player_body_model = Global.load_glb(Global.player_skins["CUSTOM"]["body_path"])
	else:
		current_player_body_model = load(Global.player_skins[Global.player_skin_name]["body_path"]).instantiate()
	
	if current_player_body_model == null:
		return
	
	# Add to head node
	player_sprite.add_child(current_player_body_model)
	await get_tree().process_frame
	player_tps_meshes_list = current_player_body_model.find_children("*", "MeshInstance3D", true, false)
	await get_tree().process_frame
	set_tps_shadow_to(player_tps_meshes_list,GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
	await get_tree().process_frame
	
	# Set position and scale
	current_player_body_model.global_position = player.global_position
	#current_player_body_model.hide()
	# Set visibility layer
	#_set_visibility_layers(current_player_body_model, 2)
	
	
	# Setup animation player
	animation_player_body = AnimationPlayer.new()
	current_player_body_model.add_child(animation_player_body)
	
	var anim_path = "res://Animations/TPS_DEFAULT_ANIMS.res"
	var anim_lib = load(anim_path)
	animation_player_body.add_animation_library("default", anim_lib)
	print(animation_player_body.get_animation_list())
	# Play idle animation if available
	if animation_player_body.has_animation("default/IDLE"):
		animation_player_body.play("default/IDLE")
	
	animation_player_body.playback_default_blend_time = 0.2
	
	# Find skeleton for potential future use
	player_body_skeleton = current_player_body_model.find_child("Skeleton3D", true)
	print("Player body skeleton found: ", player_body_skeleton)



func _weap_and_hands_model_instantiate():
	var anim_path = "res://Animations/FPS_DEFAULT_ANIMS.res"
	if current_player_model != null:
		current_player_model.queue_free()
	
	###################
	if Global.player_skin_name == "CUSTOM":
		current_player_model = load_custom_player_model()
	else:
		current_player_model = load(Global.player_skins[Global.player_skin_name]["fps_path"]).instantiate()
	###################
	camera.add_child(current_player_model)
	#camera.add_child(current_player_model)
	if current_player_model == null:
		return
	await get_tree().process_frame
	current_player_model.position = Vector3(0,0,100)
	var scal = 0.25
	current_player_model.scale = Vector3(scal,scal,scal)
	
	
	#Tira as sombras do modelo FPS do jogador
	await get_tree().process_frame
	player_fps_meshes_list = current_player_model.find_children("*", "MeshInstance3D", true, false)
	set_tps_shadow_to(player_fps_meshes_list, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	await get_tree().process_frame
	
	
	animation_player = AnimationPlayer.new()
	current_player_model.add_child(animation_player)
	animation_player.connect("animation_finished",_on_animation_finished)
	
	var anim_lib = load(anim_path)
	animation_player.add_animation_library("default",anim_lib)
	
	if animation_player.has_animation("default/"+gun.current_gun_name.to_upper()+"_THINKER"):
		animation_player.play("default/"+gun.current_gun_name.to_upper()+"_THINKER")
		thinker_with_gun = true
	elif animation_player.has_animation("default/"+gun.current_gun_name.to_upper()+"_IDLE"):
		animation_player.play("default/"+gun.current_gun_name.to_upper()+"_IDLE")
	animation_player.playback_default_blend_time = 0.2
	player_skeleton = current_player_model.find_child("Skeleton3D", true)
	#player_skeleton = _find_skeleton(current_player_model)
	
	print(player_skeleton)
	
	var gun_root_bone = player_skeleton.find_bone("GUN_ROOT.L")
	print(gun_root_bone)
	
	atch = BoneAttachment3D.new()
	player_skeleton.add_child(atch)
	atch.bone_name = "GUN_ROOT.L"
	atch.bone_idx = gun_root_bone
	atch.position = Vector3(0.649,-0.279,-0.918)
	atch.rotation_degrees = Vector3(-85.2,17.2,75.1)
	
	await get_tree().process_frame
	
	_gun_verifications_before_instantiation()
	
	
	gun.current_gun_nozzle = gun_model.find_child("GUN_NOZZLE",true)
	await get_tree().process_frame
	if gun.current_gun_nozzle != null:
		_clip_raycast_instantiate()
	gun_anim_player = gun_model.find_child("AnimationPlayer",true)
	if gun_anim_player != null:
		gun_anim_player.playback_default_blend_time = 0.2
	await get_tree().process_frame
	if animation_player.has_animation("default/"+gun.current_gun_name.to_upper()+"_THINKER"):
		animation_player.play("default/"+gun.current_gun_name.to_upper()+"_THINKER")
		thinker_with_gun = true
	elif animation_player.has_animation("default/"+gun.current_gun_name.to_upper()+"_IDLE"):
		animation_player.play("default/"+gun.current_gun_name.to_upper()+"_IDLE")
	#_set_visibility_layers(gun_model,2)
	gun_model.position = Vector3(0,0.1,0)
	gun_model.rotation_degrees = Vector3(90,0,0)

func _weapon_model_switch():
	if animation_player == null:
		return
	if thinker_with_gun:
		thinker_with_gun = false
	animation_player.playback_default_blend_time = 0.0
	current_player_model.hide()
	animation_player.stop()
	await get_tree().process_frame
	if gun_model != null:
		gun_model.queue_free()
	_gun_verifications_before_instantiation()
	
	gun.current_gun_nozzle = gun_model.find_child("GUN_NOZZLE",true)
	await get_tree().process_frame
	if gun.current_gun_nozzle != null:
		_clip_raycast_instantiate()
	if gun_model != null:
		gun_anim_player = gun_model.find_child("AnimationPlayer",true)
	if gun_anim_player != null:
		gun_anim_player.playback_default_blend_time = 0.2
	
	#_set_visibility_layers(gun_model,2)
	if gun_model != null:
		gun_model.position = Vector3(0,0.1,0)
		gun_model.rotation_degrees = Vector3(90,0,0)
	await get_tree().process_frame
	#animation_player.playback_default_blend_time = 0.2
	
	var gunzinha_name 
	if Global.guns_specs[gun.current_gun_name]["special factor"] != "null":
		gunzinha_name = Global.guns_specs[gun.current_gun_name]["special factor"]
	else:
		gunzinha_name = gun.current_gun_name
	if not gun.aiming:
		if animation_player.has_animation("default/"+gunzinha_name.to_upper()+"_THINKER"):
			_anim_verify_player("THINKER")
			thinker_with_gun = true
		else:
			_anim_verify_player("IDLE")
	await get_tree().process_frame
	current_player_model.show()
	animation_player.playback_default_blend_time = 0.2

func _weap_anims():
	if gun_sm and animation_player:
		match gun_sm.cur_state():
			"gun_idle":
				if not thinker_with_gun:
					played_gun_anim = false
					fishing_bait_out = false
					if gun.current_gun_name == "HANDS":
						animation_player.play("default/IDLE")
					else:
						if gun.current_gun_name == "FISHING_ROD":
							if Input.is_action_pressed("mb_left"):
								fishrod_tilt()
							else:
								_anim_verify_player("IDLE")
						else:
							_anim_verify_player("IDLE")
			"gun_shoot":
				played_gun_anim = false
				thinker_with_gun = false
				_anim_verify_player("SHOOT")
			"gun_fishing":
				fish_tilting = false
				if fishing_bait_out  == false:
					fishing_bait_out = true
					animation_player.play("default/FISHING_ROD_SHOOT")

func set_tps_shadow_to(lista : Array,render_type : GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.SHADOW_CASTING_SETTING_ON):
	for x in lista:
		if x is MeshInstance3D:
			x.set_cast_shadows_setting(render_type)

func _tps_anims():
	if current_player_body_model != null and head != null:
		current_player_body_model.rotation = head.rotation
	if player_sm and animation_player_body:
		match player_sm.cur_state():
			"idle","interact":
				animation_player_body.play("default/IDLE")
			"move":
				animation_player_body.play("default/MOVE")
			"falling","jump":
				animation_player_body.play("default/JUMP")
			"dead":
				animation_player_body.play("default/DEAD")

func _anim_verify_player(anim_name : String):
	if Global.guns_specs[gun.current_gun_name]["special factor"] != "null":
		if animation_player.has_animation("default/"+Global.guns_specs[gun.current_gun_name]["special factor"]+"_"+anim_name):
			animation_player.play("default/"+Global.guns_specs[gun.current_gun_name]["special factor"]+"_"+anim_name)
	else:
		if animation_player.has_animation("default/"+gun.current_gun_name.to_upper()+"_"+anim_name):
			animation_player.play("default/"+gun.current_gun_name.to_upper()+"_"+anim_name)
	if gun_anim_player != null:
		if gun_anim_player.has_animation(anim_name) and played_gun_anim == false:
			gun_anim_player.play(anim_name)
			played_gun_anim = true

func _clip_raycast_instantiate():
	if gun.current_gun_nozzle != null:
		pass
		#clip_raycast.position = gun.current_gun_nozzle.position
		#clip_raycast.rotation.y = 180

func _on_animation_finished(anim_name : StringName):
	if Global.guns_specs[gun.current_gun_name]["special factor"] != "null":
		if anim_name == "default/"+Global.guns_specs[gun.current_gun_name]["special factor"]+"_THINKER":
			thinker_with_gun = false
	else:
		if anim_name == "default/"+gun.current_gun_name+"_THINKER":
			thinker_with_gun = false

func fishrod_tilt():
	if $"../../../GUN_SM/GUN_IDLE".fish_force > 0:
		if fish_tilting == false:
			fish_tilting = true
			animation_player.play("default/FISHING_ROD_TILT")
			if weap.rotation_degrees.x < 45:
				weap.rotation.x += deg_to_rad(0.5)

func _find_skeleton(node: Node) -> Skeleton3D:
	# Search recursively for Skeleton3D
	if node is Skeleton3D:
		return node
	
	for child in node.get_children():
		var result = _find_skeleton(child)
		if result:
			return result
	
	return null

func _set_visibility_layers(node: Node, layer: int):
	# If this node is a MeshInstance3D, set its layers
	if node is MeshInstance3D:
		# Disable layer 1 and enable the specified layer
		node.layers = 0  # Clear all layers first
		node.layers |= 1 << (layer - 1)  # Enable the specified layer (layer 2 = bit 1)
		print("Set ", node.name, " to layer ", layer)
	
	# Recursively process all children
	for child in node.get_children():
		_set_visibility_layers(child, layer)

func _hand_movement_wave():
	if Global.cur_st(player_sm) == "move":
		current_player_model.position.z += Global.sine_wave(0.002,1.5)

func reset_fishrod_tilt():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(weap,"rotation_degrees:x",-15,0.2)
	
	await tween.finished
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(weap,"rotation_degrees:x",0,0.75)

func kick_anim_via_code(play_sound : bool):
	var inwards_tween = create_tween()
	inwards_tween.set_parallel(true)
	inwards_tween.set_ease(Tween.EASE_IN)
	inwards_tween.tween_property(foot_root,"position:z", 0.2,0.2)
	foot_root.visible = true
	await inwards_tween.finished
	var fowa_tween = create_tween()
	fowa_tween.set_parallel(true)
	fowa_tween.set_ease(Tween.EASE_OUT)
	fowa_tween.tween_property(foot_root,"position:z", -0.8,0.15)
	await fowa_tween.finished
	if play_sound == true:
		fall_snd.play()
	var back_tween = create_tween()
	back_tween.set_parallel(true)
	back_tween.set_ease(Tween.EASE_IN)
	back_tween.tween_property(foot_root,"position:z", 0.2,0.2)
	await get_tree().create_timer(0.2).timeout
	foot_root.visible = false

func _aim_pos(make : bool):
	if current_player_model != null:
		if gun_raycast.weap_type == "sniper-manual" or gun_raycast.weap_type == "sniper-auto":
			current_player_model.visible = not make
			hud.sniper_cover(make)
		match make:
			true:
				weap.position = lerp(weap.position, aim_gun_pos,0.2)
				current_player_model.position = lerp(current_player_model.position, aim_gun_pos,0.2)
				#current_player_model.rotation_degrees.y = -5
			false:
				weap.position = lerp(weap.position, base_gun_pos,0.2)
				current_player_model.position = lerp(current_player_model.position, Vector3.ZERO,0.2)
				#current_player_model.rotation_degrees.y = 0

func _reload_anim_via_code():
	# Animate down smoothly
	var tween_down = create_tween()
	tween_down.set_ease(Tween.EASE_IN_OUT)
	tween_down.set_trans(Tween.TRANS_QUAD)
	tween_down.set_parallel(true)
	#tween_down.tween_property(weap, "rotation_degrees:x", -14, 0.4)
	#tween_down.tween_property(weap, "rotation_degrees:y", 40, 0.8)
	#tween_down.tween_property(weap, "rotation_degrees:z", 25, 0.4)
	tween_down.tween_property(current_player_model, "position:y", -0.96, .4)

	await tween_down.finished
	#await get_tree().create_timer(1).timeout

	# Animate up smoothly
	var tween_up = create_tween()
	tween_up.set_ease(Tween.EASE_IN_OUT)
	tween_up.set_trans(Tween.TRANS_QUAD)
	tween_up.set_parallel(true)
	#tween_up.tween_property(weap, "rotation", Vector3(0,0,0), 0.1)
	tween_up.tween_property(current_player_model, "position:y", base_gun_pos.y, .2)
	#tween_up.tween_property(weap, "rotation:x", 0.0, 0.5)
	#tween_down.tween_property(weap, "rotation_degrees:x", 0, 0.5)
	#tween_down.tween_property(weap, "rotation_degrees:y", 0, 0.2)
	#tween_down.tween_property(weap, "rotation_degrees:z", 0, 0.3)
	
	
	#await tween_down.finished

func _reload_anim_2(amnt : float):
	var desired_pos = current_player_model.position.y + amnt
	desired_pos = clampf(desired_pos,-4.96,0)
	current_player_model.position.y = lerpf(current_player_model.position.y,desired_pos,10 * get_process_delta_time())


func _look_at_me(target_pos: Vector3):
	# Get direction to target (ignore Y axis)
	var direction = target_pos - global_position
	direction.y = 0
	
	# Calculate rotation to face that direction
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		head.rotation.y = target_angle + PI  # Add 180 degrees to flip


func _gun_flash_sprite():
	if gun.current_gun_nozzle == null:
		return
	if gun.weap_type == "sniper-auto" or gun.weap_type == "sniper-manual":
		if gun.aiming == true:
			return
	var flash
	if gun.current_gun_name == "NEURON_DISABLER":
		flash = load("res://Particles/part_neuron_gun_flash.tscn").instantiate()
	if gun.current_gun_name == "BOLT_ACR":
		flash = load("res://Particles/part_bolt_acr_flash.tscn").instantiate()
	else:
		flash = load("res://Particles/part_gun_flash.tscn").instantiate()
	camera.add_child(flash)
	flash.global_position = gun.current_gun_nozzle.global_position
	flash.global_rotation.z = deg_to_rad(randf_range(0,360))
	var b_value = 0.25
	var e_value = 0.10
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash,"scale",Vector3(b_value,b_value,b_value),0.04)
	tween.tween_property(flash,"rotation_degrees:z",flash.rotation_degrees.z - 180,0.04)
	await tween.finished
	var tween1 = create_tween()
	tween1.tween_property(flash,"scale",Vector3(e_value,e_value,e_value),0.04)
	await tween1.finished

func _shoot_and_reload_face_anim():
	match Global.cur_st(gun_sm):
		"gun_idle":
			pass
		"gun_shoot":
			var shoot_rotation_value = reload_face.rotation + deg_to_rad(randi_range(45,90))
			var shoot_tween = create_tween()
			shoot_tween.set_parallel(true)
			shoot_tween.set_trans(Tween.TRANS_CUBIC)
			shoot_tween.set_ease(Tween.EASE_OUT)
			shoot_tween.tween_property(reload_face,"rotation",shoot_rotation_value,0.3)
			await shoot_tween.finished
		"gun_reload":
			var shoot_rotation_value = reload_face.rotation + deg_to_rad(128)
			var reload_tween = create_tween()
			reload_tween.set_parallel(true)
			reload_tween.set_trans(Tween.TRANS_CUBIC)
			reload_tween.set_ease(Tween.EASE_OUT)
			reload_tween.tween_property(reload_face,"rotation",shoot_rotation_value,0.4)
			await reload_tween.finished

func _fish_face_rotate(ease: bool = true):
	match ease:
		false:
			reload_face.rotation = lerpf(reload_face.rotation, reload_face.rotation + deg_to_rad(90),0.2)
		true:
			var shoot_rotation_value = reload_face.rotation + deg_to_rad(128)
			var reload_tween = create_tween()
			reload_tween.set_parallel(true)
			reload_tween.set_trans(Tween.TRANS_CUBIC)
			reload_tween.set_ease(Tween.EASE_OUT)
			reload_tween.tween_property(reload_face,"rotation",shoot_rotation_value,0.8)
			await reload_tween.finished
	
func _physics_process(_delta: float) -> void:
	_aim_pos(gun.aiming)
	_shoot_and_reload_face_anim()

func _pickable_icon_logic(mostrar : bool):
	if mostrar:
		pickable_hand.visible = true
		pickable_hand.play("GRAB")
	else:
		pickable_hand.visible = false
		pickable_hand.stop()

func _camera_tilt(input_vector: Vector2):
	# Tilt camera on Z axis based on horizontal movement (A/D keys)
	var tilt_speed = 0.01      # How much tilt per unit of movement
	var return_speed = 0.1     # How quickly it returns to zero
	var max_tilt = 0.05        # Maximum tilt angle in radians
	
	
	
	# Current camera rotation
	var current_rotation = camera.rotation
	
	# Apply tilt based on horizontal input (input_vector.x)
	var new_tilt_z = current_rotation.z + (-input_vector.x * tilt_speed)
	
	# Clamp to max tilt
	new_tilt_z = clamp(new_tilt_z, -max_tilt, max_tilt)
	
	# Gradually return to zero
	new_tilt_z = lerp(new_tilt_z, 0.0, return_speed)
	
	# Apply only Z rotation
	camera.rotation.z = new_tilt_z

func _weap_delay(weight: Vector2):
	# Apply the mouse motion to weapon_pivot rotation
	# X mouse movement rotates around Z axis (tilt side to side)
	# Y mouse movement rotates around X axis (tilt up/down)
	
	# Convert mouse input to rotation amounts (adjust these multipliers as needed)
	if gun.current_gun_name != "FISHING_ROD":
		if weight != Vector2.ZERO and not Global.on_menu:
			var rotation_speed = 0.005  # How much rotation per pixel of mouse movement
			var return_speed = 0.1     # How quickly it returns to zero (0-1, higher = faster)
			
			# Calculate current rotation
			var current_rotation = weapon_pivot.rotation
			
			# Apply new rotation based on mouse input
			weight.x = weight.x /4
			weight.y = weight.y /4
			var new_rotation = Vector3(
				current_rotation.x + (weight.y * rotation_speed),  # X axis from Y mouse
				current_rotation.y,  # Y axis unaffected (usually handled by player body)
				current_rotation.z + (-weight.x * rotation_speed)   # Z axis from X mouse
			)
			
			# Gradually return towards zero
			new_rotation.x = lerp(new_rotation.x, 0.0, return_speed)
			new_rotation.z = lerp(new_rotation.z, 0.0, return_speed)
			
			# Apply the rotation
			weapon_pivot.rotation = new_rotation

func _weap_delay2(weight: Vector2):
	# Apply the mouse motion to weapon_pivot rotation
	# X mouse movement rotates around Z axis (tilt side to side)
	# Y mouse movement rotates around X axis (tilt up/down)
	
	# Convert mouse input to rotation amounts (adjust these multipliers as needed)
	if gun.current_gun_name != "FISHING_ROD":
		if weight != Vector2.ZERO and not Global.on_menu:
			var rotation_speed = 0.005  # How much rotation per pixel of mouse movement
			var return_speed = 0.1     # How quickly it returns to zero (0-1, higher = faster)
			
			var current_rotation
			# Calculate current rotation
			if current_player_model != null:
				current_rotation = current_player_model.rotation
			else:
				return
			
			# Apply new rotation based on mouse input
			weight.x = weight.x / 4
			weight.y = weight.y / 4
			var new_rotation = Vector3(
				current_rotation.x + (weight.y * rotation_speed),  # X axis from Y mouse
				current_rotation.y + (weight.x * rotation_speed),  # Y axis unaffected (usually handled by player body)
				0  # current_rotation.z + (-weight.x * rotation_speed)   # Z axis from X mouse
			)
			
			# Gradually return towards zero
			new_rotation.x = lerp(new_rotation.x, 0.0, return_speed)
			new_rotation.y = lerp(new_rotation.y, 0.0, return_speed)
			
			# Convert degrees to radians for clamping (7 degrees = 0.122 rad)
			var max_rotation_rad = deg_to_rad(14.0)
			
			# Clamp X rotation (up/down)
			new_rotation.x = clamp(new_rotation.x, -max_rotation_rad, max_rotation_rad)
			
			# Clamp Y rotation (left/right)
			new_rotation.y = clamp(new_rotation.y, -max_rotation_rad, max_rotation_rad)
			
			# Apply the rotation
			current_player_model.rotation = new_rotation

#####
func _process(_delta: float) -> void:
	#update_gun_position(_delta)
	_tps_anims()
	_weap_anims()
	_camera_tilt(Vector2(player.entradas.x,player.entradas.y))
	_weap_delay2(mouse_vel)
	_hand_movement_wave()
	
	#self.global_position = camera.global_position
	#print(camera.global_position)
	#sub_view_cam.global_position = camera.global_position
	#sub_view_cam.rotation = camera.rotation
