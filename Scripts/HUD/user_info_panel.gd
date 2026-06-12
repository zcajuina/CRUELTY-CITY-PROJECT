extends Control
@onready var user_image: Sprite2D = $USER_IMAGE
@onready var username: Label = $USERNAME
@onready var stats: Label = $STATS

func _ready() -> void:
	user_image.texture = Global.load_custom_player_image()
	Global.connect("killed_something",_on_kill)
	await get_tree().process_frame
	username.text = Global.player_name + "\n" + Global.player_tittle

func _set_up_stats():
	var livest = Global.player_lives_taken
	var speed = Global.player.walk_speed
	var jumph = Global.player.jump_vel
	stats.text = str("LIVES TAKEN: ",livest,"\n SPEED: ", speed,"\n JUMP HEIGHT: ",jumph).to_upper()
	#print("DATA UPDATED")

func _on_kill():
	_set_up_stats()
