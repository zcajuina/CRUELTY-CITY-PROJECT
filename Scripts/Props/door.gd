extends Node3D
@export var ammount_to_retract : float = 10
var open : bool = false

func _ready() -> void:
	Global.connect("door_close",_on_door_close)
func _on_door_close():
	if open:
		_close()

func interact():
	match open:
		true:
			_close()
		false:
			_open()
func _open():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self,"global_position:y",global_position.y - ammount_to_retract,1.0)
	await tween.finished
	open = true
func _close():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self,"global_position:y",global_position.y + ammount_to_retract,1.0)
	await tween.finished
	open = false
