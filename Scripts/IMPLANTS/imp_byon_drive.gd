extends Node
var byon_out : bool = false
var byon_node : CharacterBody3D
var bion_root : Node3D
var can_bless : bool = true
const IMP_BION = preload("uid://rj1sjyl8mubf")
@onready var exit_snd: AudioStreamPlayer = $EXIT_SND
@onready var timer: Timer = $TIMEOUT

func _ready() -> void:
	Global.player.hud._add_control("BION - O")
	Global.player.connect("player_respawn",_on_player_respawn)
	bion_root = Node3D.new()
	Global.player.head.add_child(bion_root)
	bion_root.position.z = -4

func _process(delta: float) -> void:
	if not Global.on_menu:
		if Input.is_action_just_pressed("o"):
			_byon_spawn()
			byon_out = not byon_out

func _byon_spawn():
	if byon_out == true:
		if byon_node != null:
			await byon_node._byon_exit()
			if byon_node.bion_menu.visible:
				Global.on_menu = false
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			byon_node.queue_free()
			exit_snd.play()
	else:
		byon_node = IMP_BION.instantiate()
		byon_node.daddy = self
		if Global.world_node != null:
			Global.world_node.add_child(byon_node)
			byon_node.global_position = bion_root.global_position

func _on_player_respawn():
	if byon_node != null:
		byon_node.queue_free()


func _on_timeout_timeout() -> void:
	can_bless = true
