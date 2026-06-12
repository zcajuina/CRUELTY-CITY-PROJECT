extends Node3D
@onready var base_meat_ball: CSGSphere3D = $BASE_MEAT_BALL
@onready var meat_snd: AudioStreamPlayer3D = $MEAT_SND

func _ready():
	_spawn_children()

func _spawn_children():
	var last_child_pos = base_meat_ball.position
	for x in range(randi_range(8,12)):
		meat_snd.play()
		var child = base_meat_ball.duplicate()
		add_child(child)
		child.position = last_child_pos + Vector3(
			randf_range(-1.5, 1.5),   # X range reduced from 4.2 to 1.2
			randf_range(0.2, 0.4),    # Y range reduced for tighter cluster
			randf_range(-1.5, 1.5)    # Z range reduced from 4.5 to 1.5
		)
		child.rotation = Vector3(randf_range(0,180),randf_range(0,180),randf_range(0,180))
		last_child_pos = child.position
		#await _spawn_anim(child)

func _spawn_anim(node: CSGSphere3D):
	node.radius = 0.2
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node,"radius",randf_range(0.9,1.2),0.01)
	await  tween.finished
	return true
