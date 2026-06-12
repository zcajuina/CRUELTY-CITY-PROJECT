extends Panel
@onready var anim: AnimationPlayer
@onready var char_preview_viewport: SubViewportContainer = $"../CHAR_PREVIEW_VIEWPORT"
@onready var player_root: Node3D = $"../CHAR_PREVIEW_VIEWPORT/SubViewport/Camera3D/PLAYER_ROOT"
@onready var skin_keys : Array = Global.player_skins.keys()

var player_model : Node3D

func _ready() -> void:
	await get_tree().process_frame
	if skin_keys.is_empty():
		return
	_check_and_instantiate(skin_keys.find(Global.player_skin_name),"default/IDLE")

func _check_and_instantiate(index : int,animation : String = "default/BIO_POSE"):
	if player_model != null:
		player_model.queue_free()
	
	var skin_name = skin_keys[index]
	print(skin_name)
	if Global.skins_owned.has(skin_name):
		if skin_name == "CUSTOM":
			player_model = Global.load_glb(Global.player_skins[skin_name]["body_path"])
		else:
			player_model = load(Global.player_skins[skin_name]["body_path"]).instantiate()
		
		player_root.add_child(player_model)
		#player_model.scale = Vector3(0.42,0.42,0.42)
		
		anim = AnimationPlayer.new()
		var anim_lib = load("res://Animations/TPS_DEFAULT_ANIMS.res")
		anim.add_animation_library("default",anim_lib)
		anim.playback_default_blend_time = 0.2
		player_model.add_child(anim)
		anim.play(animation)
		Global.player_skin_name = skin_name
		
		
		
		
	


func _on_char_list_item_selected(index: int) -> void:
	_check_and_instantiate(index,"default/IDLE")
	
