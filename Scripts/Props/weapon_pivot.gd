extends Node3D
@onready var gun: RayCast3D = $Head/Camera3D/RayCast3D
@onready var anim: AnimationPlayer = $Head/Camera3D/visuais/SubViewportContainer/SubViewport/SubViewCam/WEAPON_PIVOT/WEAP_PIVOT_ANIM


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	gun = $Head/Camera3D/RayCast3D
	gun.shoot.connect(_on_gun_signal.bind("shoot"))
	gun.aim.connect(_on_gun_signal.bind("aim"))
	gun.reload.connect(_on_gun_signal.bind("reload"))
	#control.fed.connect(_on_emotion_signal.bind("fed"))

func _on_gun_signal(sign : String):
	match sign:
		"shoot":
			anim.play("FIRE")
		"aim":
			anim.play("AIM")
		"notaim":
			anim.play_backwards("AIM")
		"reload":
			pass

func _process(delta: float) -> void:
	pass
