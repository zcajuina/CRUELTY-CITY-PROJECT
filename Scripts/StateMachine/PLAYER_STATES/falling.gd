extends State
@onready var player: CharacterBody3D = $"../.."
@onready var fall_snd: AudioStreamPlayer = $"../../SOUNDS/FALL_SND"

func _ready() -> void:
	player.connect("high_fall", _on_high_fall)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		#player.fall_damage()
		state_machine.change_state("idle")
	else:
		#player.fall_damage()
		player._move(player.walk_speed - player.weapon_weight,delta)
	#player.fall_damage()
	player.move_and_slide()

func _on_high_fall():
	fall_snd.play()
