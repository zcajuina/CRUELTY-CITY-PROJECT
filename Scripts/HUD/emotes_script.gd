extends Control
@onready var back_btn: Button = $BACK_BTN
@onready var anim_list: ItemList = $ANIM_LIST
@onready var tps_cam: Camera3D = $"../../Head/TPS_PIVOT/SpringArm3D/TPS_CAM"


func _on_back_btn_pressed() -> void:
	Global.on_menu = false
	self.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.player_sm.change_state("idle")
	Global.player.gun_sm.change_state("gun_idle")

func _on_anim_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	CameraTweener.tween_camera(Global.player.camera,tps_cam,0.25,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	#tps_cam.make_current()
	Global.player.player_sm.change_state("emoting")
	Global.player.visuais.animation_player_body.play("default/"+anim_list.get_item_text(index))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.hide()
	Global.player.visuais.head.hide()
	Global.player.visuais.set_tps_shadow_to(Global.player.visuais.player_tps_meshes_list,GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	await get_tree().process_frame
