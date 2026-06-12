extends CSGSphere3D
@export var internal_trigon_name : String = ""
@export var trigon_head_mesh : MeshInstance3D
@export var blessing : String = ""
var dead : bool = false
var friendly : bool = false

func _ready() -> void:
	await get_tree().process_frame
	if Global.player_unique_npcs.has(internal_trigon_name):
		if trigon_head_mesh != null:
			trigon_head_mesh.queue_free()
			dead = true

func _hit():
	if not dead or not friendly:
		if trigon_head_mesh != null:
			trigon_head_mesh.queue_free()
		match blessing:
			"raymond":
				Global.player.hud.dbox.auto_remove_add_text(Diag.get_dialog("trigon_1_bless")[0])
			"money":
				Global.player.hud.dbox.auto_remove_add_text(Diag.get_dialog("trigon_2_bless")[0])
			"suit":
				Global.player.hud.dbox.auto_remove_add_text(Diag.get_dialog("trigon_3_bless")[0])
			_:
				pass
	print("HEAD HIT")
