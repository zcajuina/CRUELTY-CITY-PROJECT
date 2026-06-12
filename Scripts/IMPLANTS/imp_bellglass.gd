extends Node
@onready var anim: AnimationPlayer = $Control/AnimationPlayer
@onready var sprite_2d_2: Sprite2D = $Control/Sprite2D2

var playing_anim : bool = false
var location : int = -1

func _ready() -> void:
	Global.connect("killed_something",_on_kill)

func _on_kill():
	if not playing_anim:
		_anim_()

func _anim_():
	sprite_2d_2.scale.y = 0.342 / 2
	sprite_2d_2.scale.x = sprite_2d_2.scale.x * -1
	sprite_2d_2.rotation_degrees = 0
	playing_anim = true
	var pos = randf_range(114,1002)
	sprite_2d_2.position.x = pos
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d_2,"scale:y",0.403,0.65)
	tween.tween_property(sprite_2d_2,"rotation_degrees",-20,0.38)
	tween.tween_property(sprite_2d_2,"position:y",411,0.48)
	await tween.finished
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(sprite_2d_2,"scale:y",0.363,0.36)
	tween2.tween_property(sprite_2d_2,"rotation_degrees",8,0.40)
	tween2.tween_property(sprite_2d_2,"position:y",800,0.7)
	await tween2.finished
	playing_anim = false
