extends State
@onready var player: CharacterBody3D = $"../.."
@onready var gun_sm: StateMachine = $"../../GUN_SM"
@onready var camera_3d: Camera3D = $"../../Head/Camera3D"
@onready var tps_cam: Camera3D = $"../../Head/TPS_PIVOT/SpringArm3D/TPS_CAM"

func enter() -> void:
	Global.player.visuais.current_player_body_model.show()
	gun_sm.change_state("gun_interact")

func update(_delta : float) -> void:
	if player.entradas != Vector2.ZERO:
		Global.on_menu = false
		CameraTweener.tween_camera(tps_cam,camera_3d,0.05,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		#camera_3d.make_current()
		state_machine.change_state("move")


func exit() -> void:
	player.visuais.head.show()
	player.visuais.set_tps_shadow_to(Global.player.visuais.player_tps_meshes_list,GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
	await get_tree().process_frame
	gun_sm.change_state("gun_idle")
