extends CSGSphere3D

@export var altar_name : String = "NONE"
@export var required_lives : int = 100

#func _ready() -> void:
	#anim.play("ALTAR_BALL_ROTATE")

func interact():
	if Global.player_altar == altar_name:
		return
	else:
		if Global.player_stats.has(altar_name):
			if Global.player_lives_taken >= required_lives:
				Global.player_lives_taken -= required_lives
				Global.player_altar = altar_name
				Global.player.hit_no_anim(1000)
			else:
				Global._show_message("","YOU ARE NOT WORTHY.",1.25,"WHITE",false)
