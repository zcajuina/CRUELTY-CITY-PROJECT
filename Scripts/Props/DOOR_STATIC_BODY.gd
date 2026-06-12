extends StaticBody3D

var open : bool = false


func interact():
	if not open:
		open = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUART)
		tween.tween_property(self,"global_position:y",global_position.y - 10,1.0)
		await tween.finished
		_go_back()

func _go_back():
	await get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self,"global_position:y",global_position.y + 10,1.0)
	await tween.finished
	open = false
