extends State
@onready var player: CharacterBody3D = $"../.."


func enter() -> void:
	player.velocity = Vector3.ZERO

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state("falling")
	else:
		if Input.is_action_just_pressed("space"):
			state_machine.change_state("jump")
		if player.entradas == Vector2.ZERO:
			state_machine.change_state("idle")
		else:
			player._move(player.walk_speed - player.weapon_weight,delta)
	player.move_and_slide()
