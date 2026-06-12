extends StaticBody3D

@export var direction : int = 1


var open : bool = false


func interact():
	if not open:
		open = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUART)
		tween.tween_property(self,"rotation_degrees:y",rotation_degrees.y + 90 * direction,1.0)
		await tween.finished
		_go_back()

func _go_back():
	await get_tree().create_timer(2.5).timeout
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self,"rotation_degrees:y",rotation_degrees.y - 90 * direction,1.0)
	await tween.finished
	open = false

func _hit(_damage : int = 1, _hit_pos : Vector3 = Vector3.ZERO):
	#Global._spawn_part("res://Particles/part_wood_break.tscn",self.global_position)
	self.queue_free()
