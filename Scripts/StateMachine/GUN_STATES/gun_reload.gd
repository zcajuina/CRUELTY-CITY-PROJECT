extends State
@onready var visuais: Node3D = $"../../Head/Camera3D/visuais"
@onready var reload_snd: AudioStreamPlayer = $"../../SOUNDS/RELOAD_SND"
@onready var reload_bar: Control = $"../../Head/Camera3D/visuais/SubViewportContainer/Control/RELOAD_BAR"
@onready var reload_timer: Timer = $"../../reload_timer"
@onready var gun: RayCast3D = $"../../Head/Camera3D/GUN_RAYCAST"


func enter() -> void:
	if Global.crus_reload:
		Global.on_menu = true
		reload_bar.show()
	else:
		visuais._reload_anim_via_code()
		reload_timer.start()
	#visuais._reload_anim_via_code()
	reload_snd.play()

func physics_update(_delta : float) -> void:
	if Global.crus_reload:
		if Input.is_action_just_released("r"):
			reload_bar.reset_target()
			reload_bar.reached = false
			reload_bar.hide()
			state_machine.change_state("gun_idle")
			await get_tree().process_frame
			Global.on_menu = false

func _on_reload_timer_timeout() -> void:
	#Global.on_menu = false
	state_machine.change_state("gun_idle")
