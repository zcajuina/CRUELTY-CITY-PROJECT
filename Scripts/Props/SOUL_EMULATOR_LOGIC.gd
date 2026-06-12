extends CSGSphere3D
@export var core_name : String = "DEATH"
@export var inspect_name : String = "PERFORM DEATH SURGERY"
@export var inspect_desc : String = ""
#@onready var camera_3d: Camera3D = $"../../Camera3D"

func interact():
	if Global.player_core == core_name:
		Global._show_message("YOU AND I ARE ALREADY ONE, CHILD.", "",1.0,"white", true)
	else:
		Global.player.player_sm.change_state("interact")
		Global.player_core = core_name
		Global._save_game()
		Global.player.hit_no_anim(800)
