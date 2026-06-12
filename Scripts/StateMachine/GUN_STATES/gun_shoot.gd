extends State
@onready var gun: Node3D = $"../../Head/Camera3D/GUN_RAYCAST"
@onready var visuais: Node3D = $"../../Head/Camera3D/visuais"
@onready var shoot_snd: AudioStreamPlayer = $"../../SOUNDS/SHOOT_SND"
@onready var shoot_snd_2: AudioStreamPlayer = $"../../SOUNDS/SHOOT_SND2"
var one_shot_snd : bool = false

func enter() -> void:
	match gun.weap_type:
		"manual","auto","sniper-manual":
			gun._shoot()
		"manual-shotgun","auto-shotgun":
			gun._shoot_shotgun()
		"manual-proj":
			gun._shoot_projectile()
		"auto-proj":
			gun._shoot_projectile()
		"fishing-rod":
			state_machine.change_state("gun_fishing")
		"manual-dna":
			gun._shoot_dna()
		"melee":
			gun._melee()
		"flashlight":
			pass
		"bolt_acr":
			gun._bolt_acr()
		"manual-infinite":
			gun._infinite_bullet_shoot()
		"auto-infinite":
			gun._infinite_bullet_shoot()
		_:
			gun._shoot()
	
	
	visuais._gun_flash_sprite()

	var pitch_range = 0.12
	match gun.current_gun_pos:
		"gun1":
				shoot_snd.play()
		"gun2":
				shoot_snd_2.play()

func _on_shoot_timer_timeout() -> void:
	state_machine.change_state("gun_idle")
