extends Node3D
@onready var vel : float = 0.04
@onready var can_move : bool = false
@onready var kill_timer: Timer = $kill_timer
@onready var fish_catch_snd: AudioStreamPlayer3D = $fish_catch_snd

var played_snd : bool = false
var fish_model
var fish_node : Node3D = null
var processing : bool = false

func _ready() -> void:
	await get_tree().process_frame
	if fish_model != null:
		fish_node = load(fish_model).instantiate()
		add_child(fish_node)
	fish_catch_snd.play()
	Global._spawn_part("res://Particles/part_fish_appear.tscn",self.global_position)

func _physics_process(_delta: float) -> void:
	if can_move == true:
		move_to_player()

func move_to_player():
	if self.global_position.distance_to(Global.player.head.global_position) <= 1:
		if processing == false:
			fish_aquire()
	else:
		global_rotation.y += .1
		global_position = lerp(global_position,Global.player.head.global_position,vel)
		#global_position.y = move_toward(global_position.y, Global.player.head.global_position.y, vel)
		#global_position.x = move_toward(global_position.x, Global.player.head.global_position.x, vel)
		#global_position.z = move_toward(global_position.z, Global.player.head.global_position.z, vel)

func fish_aquire():
	processing = true
	FishSave.add_fish(FishSave.cpf_do_peixe["nome"], 1)
	FishSave._save_fish()
	var _index = FishSave._lista_de_peixes.find(FishSave.cpf_do_peixe["nome"])
	#Global.hud_node.stock_market._update_item_holding_on_list("FISH",index)
	FishSave.emit_signal("new_fish_catch")
	var fish_name = FishSave.cpf_do_peixe["nome"]
	Global._show_message(str(fish_name.to_upper()," AQUISITION COMPLETE"),"",2,"GREEN")
	#aquire_snd.play()
	visible = false



func _on_kill_timer_timeout() -> void:
	if can_move == false:
		queue_free()
