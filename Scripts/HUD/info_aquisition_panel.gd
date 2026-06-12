extends Control
@onready var main_label: Label = $MSG_PIVOT/MAIN_LABEL
@onready var sub_label: Label = $MSG_PIVOT/SUB_LABEL
@onready var msg_pivot: Control = $MSG_PIVOT
@onready var anim_player: AnimationPlayer = $ANIM_PLAYER
@onready var alert_snd: AudioStreamPlayer = $ALERT_SND

var text_offset : float = 0

@export var main_text : String = "MAIN TEXT"
@export var sub_text : String = "SUB TEXT"
@export var msg_time : float = 3.5
@export var text_color : String = "GREEN"
@export var play_snd : bool = true

@onready var timer: Timer = $Timer

func _color_set():
	match text_color:
		"WHITE":
			main_label.add_theme_color_override("font_color",Color.WHITE)
			main_label.add_theme_color_override("font_outline_color",Color.DIM_GRAY)

			sub_label.add_theme_color_override("font_color",Color.WHITE)
			sub_label.add_theme_color_override("font_outline_color",Color.DIM_GRAY)
		"GREEN":
			pass
		"RED":
			main_label.add_theme_color_override("font_color",Color.RED)
			main_label.add_theme_color_override("font_outline_color",Color.DARK_RED)

			sub_label.add_theme_color_override("font_color",Color.RED)
			sub_label.add_theme_color_override("font_outline_color",Color.DARK_RED)
		"BLUE":
			main_label.add_theme_color_override("font_color",Color.CYAN)
			main_label.add_theme_color_override("font_outline_color",Color.DARK_BLUE)

			sub_label.add_theme_color_override("font_color",Color.CYAN)
			sub_label.add_theme_color_override("font_outline_color",Color.DARK_BLUE)
		"PURPLE":
			main_label.add_theme_color_override("font_color",Color.MAGENTA)
			main_label.add_theme_color_override("font_outline_color",Color.DARK_BLUE)

			sub_label.add_theme_color_override("font_color",Color.MAGENTA)
			sub_label.add_theme_color_override("font_outline_color",Color.DARK_BLUE)
		_:
			pass
func _ready() -> void:
	await get_tree().process_frame
	_color_set()
	timer.wait_time = msg_time
	timer.start()
	main_label.text = main_text
	sub_label.text = sub_text
	text_offset = randf_range(32,78)
	_anim_start()
	await get_tree().process_frame
	main_label.show()
	sub_label.show()
	anim_player.play("PULSATE")
	alert_snd.playing = play_snd

func _anim_start():
	msg_pivot.position.y =348.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	#tween.tween_property(msg_pivot,"position:y",532,0.3)
	tween.tween_property(msg_pivot,"position:y",196.0,0.4)

func _anim_end()->bool:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(msg_pivot,"modulate:a",0,0.3)
	await tween.finished
	return true

func _on_timer_timeout() -> void:
	await _anim_end()
	Diag.message_array -= 1
	queue_free()
