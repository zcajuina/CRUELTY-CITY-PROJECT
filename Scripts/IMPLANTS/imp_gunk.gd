extends Node

var double_jumped : bool = false
@onready var poop_snd: AudioStreamPlayer = $POOP_SND

func _physics_process(delta: float) -> void:
	if Global.player == null:
		return
	
	else:
		if Global.player_sm.cur_state() == "falling":
			if Input.is_action_just_pressed("space") and double_jumped == false:
				double_jumped = true
				poop_snd.play()
				Global.player_sm.change_state("jump")
		if Global.player.is_on_floor():
			double_jumped = false
