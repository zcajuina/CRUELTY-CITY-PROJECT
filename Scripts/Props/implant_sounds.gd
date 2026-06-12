extends Node
@onready var player_sm: StateMachine = $"../PLAYER_SM"

@onready var ikaros_jump: AudioStreamPlayer = $IKAROS_JUMP

func _physics_process(_delta: float) -> void:
	match Global.player_leg_implant:
		"IKAROS_MACHINE":
			if player_sm.cur_state() == "jump":
				ikaros_jump.play()
