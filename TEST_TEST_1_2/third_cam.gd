extends Node3D
@onready var node_3d: Node3D = $SubViewportContainer/SubViewport/Node3D
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Node3D/Camera3D
@onready var visuais: Node3D = $"../Camera3D/visuais"

func _process(delta: float) -> void:
	node_3d.global_position = Global.player.global_position
	node_3d.rotation = Global.player.head.rotation
	#if visuais != null and visuais.current_player_body_model != null:
		#if Input.is_action_pressed("e"):
			#visuais.current_player_body_model.show()
		#else:
			#visuais.current_player_body_model.hide()
