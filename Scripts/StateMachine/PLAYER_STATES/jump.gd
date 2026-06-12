extends State
@onready var player: CharacterBody3D = $"../.."


func enter()-> void:
	player.velocity.y = player.jump_vel
	$"../../SOUNDS/JUMP_SND".play()
func physics_update(_delta: float)-> void:
	if player.is_on_floor():
		state_machine.change_state("idle")
	else:
		state_machine.change_state("falling")
	player.move_and_slide()
