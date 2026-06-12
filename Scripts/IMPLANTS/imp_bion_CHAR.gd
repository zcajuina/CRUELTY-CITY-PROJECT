extends CharacterBody3D
@onready var head: Node3D = $BYON_BODY/BYON_FACE_ROOT
@onready var byon_star_root: Node3D = $BYON_BODY/BYON_STAR_ROOT
@onready var yay: AudioStreamPlayer = $YAY
@onready var yay_echo: AudioStreamPlayer = $YAY_ECHO
@onready var byon_body: MeshInstance3D = $BYON_BODY
@onready var bion_menu: Control = $BION_MENU
@onready var await_panel: Panel = $BION_MENU/AWAIT_PANEL
@onready var byon_face_root: Node3D = $BYON_BODY/BYON_FACE_ROOT

var daddy

@onready var heal_btn: Button = $BION_MENU/HEAL_BTN
@onready var get_bullets: Button = $"BION_MENU/GET BULLETS"
@onready var time_await_label: Label = $BION_MENU/AWAIT_PANEL/TIME_AWAIT_LABEL



var inspect_name : String = "BION"
var inspect_desc : String = "Strange apparition of energy."

var camera : Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var direction : Vector3
var speed = 10.0
var acel = 0.8

func _ready() -> void:
	add_collision_exception_with(Global.player)
	camera = get_viewport().get_camera_3d()
	Global.player.hud.connect("opened_stocks",_on_hud_action)
	Global.player.hud.connect("opened_anim",_on_hud_action)
	yay.play()
func _on_hud_action():
	bion_menu.hide()

func _physics_process(delta: float) -> void:
	_byon_move(delta)
	if daddy != null:
		time_await_label.text = str(int(daddy.timer.get_time_left()))
		if daddy.can_bless:
			heal_btn.disabled = false
			get_bullets.disabled = false
		else:
			heal_btn.disabled = true
			get_bullets.disabled = true
			
		if daddy.timer.is_stopped():
			await_panel.hide()
		else:
			await_panel.show()

func _byon_move(delta : float):
	#pet.add_collision_exception_with(Global.Player)

	var target_pos = Global.player.head.global_position
	#PARTE IMPORTANTE
	#Ajustando a altura pra ser a mesma do player so que com um lerp pra ser
	#SU A VE
	self.global_position.y = lerp(self.global_position.y, target_pos.y, delta * acel)
	#pegando a direção certinha
	direction = (target_pos - self.global_position).normalized()
	#Basicamente a velocidade do pet vai ser igual a posição dele
	#Vezes a velocidade de movimento
	#Mas como essa variavel atualiza a cada frame, não tem bronca dele do nada passar reto
	if self.global_position.distance_to(target_pos) >= 15:
		self.velocity = direction * speed * 5
	else:
		self.velocity = direction * speed
	#Fazer a mesh do pet olhar pro personagem
	if self.global_position != target_pos:
		head_turn(8,delta)
		#_node_look(byon_star_root,8,delta)
		#pet.look_at(target.global_position)
	#Se ele tiver pertinho vai pra Idle
	if self.global_position.distance_to(target_pos) <= 2:
		self.velocity = Vector3.ZERO
	#Isso aqui é pra ele se mexer
	self.move_and_slide()

func head_turn(speed: float, delta: float) -> void:
	var target_pos: Vector3 = camera.global_position
	var to_target: Vector3 = (target_pos - head.global_transform.origin).normalized()
	
	# Get current and desired rotations as quaternions
	var current_quat: Quaternion = head.global_transform.basis.get_rotation_quaternion()
	var desired_basis: Basis = Basis.looking_at(to_target, Vector3.UP)
	var desired_quat: Quaternion = desired_basis.get_rotation_quaternion()
	
	# Smoothly interpolate using quaternion slerp
	var new_quat: Quaternion = current_quat.slerp(desired_quat, clamp(speed * delta, 0.0, 1.0))
	head.global_transform.basis = Basis(new_quat)

func _node_look(node : Node3D,speed: float, delta: float) -> void:
	var target_pos: Vector3 = camera.global_position
	var to_target: Vector3 = (target_pos - node.global_transform.origin).normalized()
	
	# Get current and desired rotations as quaternions
	var current_quat: Quaternion = node.global_transform.basis.get_rotation_quaternion()
	var desired_basis: Basis = Basis.looking_at(to_target, Vector3.UP)
	var desired_quat: Quaternion = desired_basis.get_rotation_quaternion()
	
	# Smoothly interpolate using quaternion slerp
	var new_quat: Quaternion = current_quat.slerp(desired_quat, clamp(speed * delta, 0.0, 1.0))
	node.global_transform.basis = Basis(new_quat)

func interact():
	_bion_menu()
	#Global.start_dialogue("bion_default")

func _byon_exit():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(byon_body,"scale:x",0.001,0.15)
	tween.tween_property(byon_body,"scale:z",0.001,0.15)
	tween.tween_property(byon_body,"scale:y",3,0.15)
	await tween.finished
	return true

func _bion_menu():
	if Global.player_sm.cur_state() == "interact":
		return
	if Global.player_sm.cur_state() == "emoting":
		return
	if Global.player.player_sm.cur_state() == "dead":
		return

	Global.on_menu = not Global.on_menu
	bion_menu.visible = Global.on_menu
	if not Global.on_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_exit_pressed() -> void:
	_bion_menu()

func _on_heal_btn_pressed() -> void:
	Global.player.heal(Global.player_caps["max_health"])
	heal_btn.disabled = true
	heal_btn.disabled = true
	await_panel.show()
	daddy.timer.start()
	yay_echo.play()
	Global._show_message("BLESSING GIVEN","Bion restored all your health.",2,"BLUE",true)
	_bion_menu()
func _on_get_bullets_pressed() -> void:
	if not Global.no_reload_guns.has(Global.player.gun.current_gun_name):
		var ammo_to_add = Global.guns_specs[Global.player.gun.current_gun_name]["max_storage"]
		var gun_name = Global.guns_specs[Global.player.gun.current_gun_name]["gun_name"]
		Global.player_gun_ammo[Global.player.gun.current_gun_pos]["storage"] += ammo_to_add
		heal_btn.disabled = true
		heal_btn.disabled = true
		await_panel.show()
		daddy.timer.start()
		yay_echo.play()
		Global._show_message("BLESSING GIVEN","Bion gave you +"+str(ammo_to_add)+" of "+gun_name+" ammo.",2,"BLUE",true)
	else:
		Global._show_message("BION CANNOT GIVE BULLETS TO THIS WEAPON.","",2,"RED",true)
	_bion_menu()
