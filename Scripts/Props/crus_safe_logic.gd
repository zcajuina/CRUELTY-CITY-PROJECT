extends StaticBody3D
class_name SafeBox

@onready var crus_safe: Node3D = $"../../.."
@onready var door: MeshInstance3D = $".."
var arrombado : bool = false
var break_progress : float = 0
var tween : Tween
@onready var player_position_base: Node3D = $"../../../PLAYER_POSITION_BASE"

# ====== OPTIONS MENU (Grouped for Inspector) ======
@export_category("Money Options")
@export var enable_money: bool = false
@export_range(1, 20, 1) var money_count: int = 1
@export_range(1, 1000, 1) var base_money_value: int = 100
@export_range(1, 10000, 1) var max_money_value: int = 100
@export var is_bio_currency: bool = false

@export_category("Organ Options")
@export var enable_organs: bool = false
@export_range(1, 10, 1) var organ_count: int = 1
@export_range(0, 10, 1) var organ_table_index: int = 0  # Which Global.gibbing_results index to use
@export var spawn_height_offset: float = 0.5

@export_category("Scatter Options")
@export var scatter_range: float = 0.8
@export var spawn_force: float = 2.0
@export var randomize_rotation: bool = true

# Scene paths
const MONEY_SCENE = preload("res://Scenes/Props/PICK_UPS/MONEY_RIGID_BODY.tscn")
const ORGAN_SCENE = preload("res://Scenes/Props/ORGANS/GenericRigidOrgan.tscn")

@onready var safe_hit: AudioStreamPlayer3D = $"../../../SAFE_HIT"
@onready var safe_break: AudioStreamPlayer3D = $"../../../SAFE_BREAK"

@onready var safe_brek_hud: Control = $"../../../SAFE_BREK_HUD"
@onready var safe_break_progress_bar: ProgressBar = $"../../../SAFE_BREK_HUD/SAFE_BREAK_PROGRESS_BAR"


# ====== FUNCTIONS ======
func _spawn_money():
	for i in range(money_count):
		var money = MONEY_SCENE.instantiate()
		crus_safe.get_parent().add_child(money)
		
		# Position with scatter
		money.global_position = self.global_position
		money.global_position.x += randf_range(-scatter_range, scatter_range)
		money.global_position.z += randf_range(-scatter_range, scatter_range)
		
		if randomize_rotation:
			money.global_rotation.y = randf_range(0, 360)
		
		# Set money properties
		money.bio_currency = is_bio_currency
		money.money_ammount = randi_range(base_money_value, max_money_value)
		
		# Apply random force
		if money is RigidBody3D and spawn_force > 0:
			var force_dir = Vector3(
				randf_range(-1, 1),
				randf_range(0.3, 1),
				randf_range(-1, 1)
			).normalized()
			money.apply_central_impulse(force_dir * spawn_force)

func _spawn_organs():
	# Check if organ table index exists
	if organ_table_index >= Global.gibbing_results.size():
		push_warning("Organ table index %d out of range! Using default." % organ_table_index)
		return
	
	var organ_table = Global.gibbing_results[organ_table_index]
	
	for i in range(organ_count):
		# Get random organ from the selected table
		var organ_name = organ_table[randi() % organ_table.size()]
		
		var organ = ORGAN_SCENE.instantiate()
		crus_safe.add_child(organ)
		
		# Set organ name
		organ.organ_name = organ_name
		print(organ.organ_name)
		# Position with offset
		organ.global_position = self.global_position + Vector3(0, spawn_height_offset, 0)
		organ.global_position.x += randf_range(-scatter_range, scatter_range)
		organ.global_position.z += randf_range(-scatter_range, scatter_range)
		
		# Random rotation
		if randomize_rotation:
			organ.rotation = Vector3(
				randf_range(0, 5),
				randf_range(0, 5),
				randf_range(0, 5)
			)
		

		
		# Apply force
		if organ is RigidBody3D and spawn_force > 0:
			var force_dir = Vector3(
				randf_range(-1, 1),
				randf_range(0.5, 1.5),
				randf_range(-1, 1)
			).normalized()
			organ.apply_central_impulse(force_dir * spawn_force)

func interact():
	if not arrombado:
		if door != null:
			# Spawn based on enabled options
			Global.player_sm.change_state("interact")
			#Global.player.gun_sm.change_state("gun_interact")
			Global.player.global_position = player_position_base.global_position
			Global.player.camera.rotation.y = 0
			Global.player.camera.rotation.z = 0
			safe_brek_hud.visible = true
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_make_player_look_at_door()
			#Global.on_menu = true
			Global.player.gun.emit_signal("breaking_safe")
			_progress_bar_anim()

func _make_player_look_at_door():
	Global.player.camera.rotation.x = -32
	var direction = Global.player.global_position - door.global_position
	direction.y = 0
	if direction.length() > 0.1:
		Global.player.head.rotation.y = atan2(direction.x, direction.z)

func _spawn_thinghy():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().process_frame
	safe_brek_hud.visible = false
	#Global.on_menu = false
	Global.player_sm.change_state("idle")
	Global.player.gun_sm.change_state("gun_idle")
	Global.player.gun.emit_signal("safe_break_stop")
	if enable_money:
		_spawn_money()
	
	if enable_organs:
		_spawn_organs()
	
	# If nothing enabled, spawn default money
	if not enable_money and not enable_organs:
		push_warning("SafeBox: No spawn options enabled! Spawning default money.")
		enable_money = true
		_spawn_money()
	safe_break.pitch_scale += randf_range(-0.25,0.25)
	safe_break.play()
	door.queue_free()
	arrombado = true

func _progress_bar_anim():
	safe_break_progress_bar.value = 0
	tween = create_tween()
	tween.tween_property(safe_break_progress_bar,"value",100,8.5)
	await tween.finished
	_spawn_thinghy()

func _on_cancel_btn_pressed() -> void:
	if tween != null:
		tween.kill()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().process_frame
	Global.player_sm.change_state("idle")
	Global.player.gun_sm.change_state("gun_idle")
	Global.player.gun.emit_signal("safe_break_stop")
	safe_brek_hud.visible = false
	Global.on_menu = false
