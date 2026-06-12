extends Control
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var top: Sprite2D = $LABEL/TOP
@onready var bottom: Sprite2D = $LABEL/BOTTOM
@onready var frame: ColorRect = $FRAME
@onready var video_stream_player: VideoStreamPlayer = $FRAME/VideoStreamPlayer
@onready var in_snd: AudioStreamPlayer = $IN
@onready var label: Control = $LABEL

var can_skip : bool = false

const videos = ["res://Textures/VIDEOS/DUMB.ogv","res://Textures/VIDEOS/LEWD.ogv"]
const adv_btn = ["res://Textures/SPRITES/ADV_SPRITES/adv_bottom_dumb.png", "res://Textures/SPRITES/ADV_SPRITES/adv_bottom_expli.png", "res://Textures/SPRITES/ADV_SPRITES/adv_bottom_lewd.png"]

const offset = -610
func _ready() -> void:
	#Global._load_everything()
	print(videos.size())
	var index = randi_range(0,videos.size()-1)
	video_stream_player.stream = load(videos[index])
	bottom.texture = load(adv_btn[index])
	await _frame_app()
	await get_tree().create_timer(0.5).timeout
	in_snd.play()
	_frame_open()
	video_stream_player.play()
	await get_tree().create_timer(video_stream_player.get_stream_length()-0.5).timeout
	await _frame_close()
	await _frame_dis()
	await get_tree().process_frame
	#get_tree().reload_current_scene()
	get_tree().change_scene_to_file("res://Scenes/HUD/MAIN_MENU.tscn")

func _process(delta: float) -> void:
	sprite_2d.rotation += 0.02
	await get_tree().process_frame
	if can_skip == true:
		if Input.is_action_just_pressed("mb_left"):
			get_tree().change_scene_to_file("res://Scenes/HUD/MAIN_MENU.tscn")
	#if Input.is_action_just_pressed("mb_right"):
		#get_tree().reload_current_scene()

func _frame_open():
	frame.show()
	var time = 0.5
	var t1 = create_tween()
	t1.set_parallel(true)
	t1.set_ease(Tween.EASE_IN_OUT)
	t1.set_trans(Tween.TRANS_EXPO)
	t1.tween_property(top,"position:y",top.position.y + offset,time)
	t1.tween_property(bottom,"position:y",bottom.position.y - offset,time)
	t1.tween_property(frame,"scale",Vector2(1,1.1),time)
	await t1.finished

func _frame_close():
	in_snd.play()
	var t2 = create_tween()
	t2.set_parallel(true)
	t2.set_ease(Tween.EASE_IN_OUT)
	t2.set_trans(Tween.TRANS_EXPO)
	t2.tween_property(top,"position:y",top.position.y - offset,0.5)
	t2.tween_property(bottom,"position:y",bottom.position.y + offset,0.5)
	t2.tween_property(frame,"scale",Vector2(1,0.625),0.5)
	await t2.finished
	return true

func _frame_dis():
	frame.hide()
	var t2 = create_tween()
	t2.set_parallel(true)
	t2.set_ease(Tween.EASE_IN_OUT)
	t2.set_trans(Tween.TRANS_EXPO)
	t2.tween_property(label,"modulate",Color(0,0,0,0),0.5)
	await t2.finished
	return true

func _frame_app():
	label.scale.y = 0
	label.scale.x = 0
	label.modulate = Color(1,1,1,0)
	var t2 = create_tween()
	t2.set_parallel(true)
	t2.set_ease(Tween.EASE_IN_OUT)
	t2.set_trans(Tween.TRANS_EXPO)
	t2.tween_property(label,"scale:y",0.25,0.5).set_trans(Tween.TRANS_BACK)
	t2.tween_property(label,"scale:x",0.25,0.55).set_trans(Tween.TRANS_BACK)
	t2.tween_property(label,"modulate",Color(1,1,1,1),0.55)
	#t2.tween_property(top,"modulate",Color(1,1,1,1),0.5)
	#t2.tween_property(bottom,"modulate",Color(1,1,1,1),0.5)
	await t2.finished
	return true


func _on_timer_timeout() -> void:
	can_skip = true
