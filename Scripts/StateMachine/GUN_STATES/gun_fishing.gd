extends State
@onready var player: CharacterBody3D = $"../.."
@onready var gun: Node3D = $"../../Head/Camera3D/GUN_RAYCAST"
@onready var fishin_throw_force : float = 0
@onready var fish_out: AudioStreamPlayer = $"../../SOUNDS/FISH_OUT"
@onready var fish_in: AudioStreamPlayer = $"../../SOUNDS/FISH_IN"
@onready var visuais: Node3D = $"../../Head/Camera3D/visuais"

func enter() -> void:
	visuais._fish_face_rotate(true)
	visuais.fish_tilting = false
	if FishSave.fish_bait_node == null:
		gun._spawn_bait_instance(fishin_throw_force)
	else:
		FishSave.fish_bait_node.queue_free()
		FishSave.fish_bait_node = null
	fish_out.play()

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("mb_left"):
		await get_tree().process_frame
		state_machine.change_state("gun_idle")
	if gun.current_gun_name != "FISHING_ROD":
		state_machine.change_state("gun_idle")
	if FishSave.fish_bait_node != null:
		if player.global_position.distance_to(FishSave.fish_bait_node.global_position) >= 38:
			state_machine.change_state("gun_idle")

func exit() -> void:
	if FishSave.fish_bait_node != null:
		FishSave.fish_bait_node.queue_free()
		fish_in.play()
