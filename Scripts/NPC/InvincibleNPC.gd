extends BaseNPC

const PART_SWEAT : String = "res://Particles/part_sweat.tscn"

func _ready() -> void:
	dialog_array = Diag.get_dialog(dialog_tag)

func _spawn_sweat():
	var sweat_pos = self.global_position
	sweat_pos.y += 1
	var sweat = load(PART_SWEAT).instantiate()
	add_child(sweat)
	sweat.global_position = sweat_pos

func _hit(damage : float = 1, _pos: Vector3 = Vector3.ZERO):
	print(self.name, "IS NOT KILLABE")
	
	_spawn_sweat()
	
	#anim.play("HIT")
	#await get_tree().create_timer(0.25).timeout
	#anim.play("IDLE")

func interact():
	print(dialog_array)
	Global.player.hud.dbox.start_dialogue(dialog_array)
