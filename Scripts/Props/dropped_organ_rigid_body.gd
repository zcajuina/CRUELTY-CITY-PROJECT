extends RigidBody3D
class_name DroppedOrgan
@export var organ_name : String = "HEART"
@onready var brain: Node3D = $BRAIN
@onready var heart: Node3D = $HEART
@onready var intestines: Node3D = $INTESTINES
@onready var pancreas: Node3D = $PANCREAS
@onready var spine: Node3D = $SPINE
@onready var stomach: Node3D = $STOMACH
@onready var spine_col: CollisionShape3D = $SPINE_COL
@onready var apimba: Node3D = $APIMBA

@onready var dummy_colision: CollisionShape3D = $CollisionShape3D



func _ready() -> void:
	if Global.player != null:
		self.add_collision_exception_with(Global.player)
	add_exeption_to_foes()
	await get_tree().process_frame
	_match_organ_model()
	#mesh.global_rotation.x = deg_to_rad(randi_range(0,90))

func _match_organ_model():
	match organ_name:
		"HEART":
			heart.visible = true
		"BRAIN":
			brain.visible = true
		"INTESTINES":
			intestines.visible = true
		"PANCREAS":
			pancreas.visible = true
		"SPINE":
			spine.visible = true
		"STOMACH":
			stomach.visible = true
		"APENDIX":
			apimba.show()
	if organ_name != "SPINE":
		spine_col.queue_free()

func add_exeption_to_foes():
	for foe in get_tree().get_nodes_in_group("foe"):
		if foe is CharacterBody3D:  # or PhysicsBody2D
			self.add_collision_exception_with(foe)

func interact():
	var index = StockDb.list_of_organs.find(organ_name.to_upper())
	StockDb.add_organ(index,1)
	Global._show_message(str(organ_name," AQUISITION FINISHED"),"",0.9)
	Global.player.hud.stock_market._update_money_label()
	queue_free()

func _on_kill_spawn_timeout() -> void:
	queue_free()
