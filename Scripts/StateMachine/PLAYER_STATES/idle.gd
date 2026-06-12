extends State
@onready var player: CharacterBody3D = $"../.."
@onready var emotes: Control = $"../../Control/EMOTES"
@onready var gun_sm: StateMachine = $"../../GUN_SM"


func enter() -> void:
	player.velocity = Vector3.ZERO

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("falling")
	else:
		if Input.is_action_just_pressed("space"):
			state_machine.change_state("jump")
		if player.entradas != Vector2.ZERO:
			state_machine.change_state("move")
		else:
			player._move(0.0,delta)
	player.move_and_slide()
