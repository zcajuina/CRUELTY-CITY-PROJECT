extends CharacterBody3D
@onready var camera_3d: Camera3D = $Camera3D
@onready var splater_snd: AudioStreamPlayer = $SPLATER_SND


func _ready() -> void:
	splater_snd.play()
	add_collision_exception_with(Global.player)
	CameraTweener.tween_camera(Global.player.camera,camera_3d,0.2)

func lerpzinho():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_parallel(true)
	tween.tween_property(self, "rotation:z", deg_to_rad(-32), 0.5)
	tween.tween_property(self, "rotation:x", deg_to_rad(15), 0.3)
	await tween.finished
	var tween2 = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween2.tween_property(self, "rotation:x", deg_to_rad(0), 0.3)
	await tween2.finished
