extends Node
var has_coin : bool = true
const coiny : String = "res://Scenes/Props/PICK_UPS/coin.tscn"

func _ready() -> void:
	Global.player.hud._add_control("DROP COIN - G")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("g") and has_coin:
		has_coin = false
		_spawn_coin()
		

func _spawn_coin():
	var coin = load(coiny).instantiate()
	Global.player.get_parent().add_child(coin)
	Global.player.add_collision_exception_with(coin)
	coin.global_position = Global.player.head.global_position + Vector3(0,-0.2,0)
	coin.global_rotation.y = Global.player.head.global_rotation.y
	await get_tree().process_frame
	coin.global_rotation.x = Global.player.camera.global_rotation.x
	var throw_force = 0
	if  Global.player.velocity != Vector3.ZERO:
		throw_force = 20
	else:
		throw_force = 10
	var forward_direction = -coin.global_transform.basis.z  # Forward in Godot is -Z
	coin.linear_velocity = forward_direction * throw_force
