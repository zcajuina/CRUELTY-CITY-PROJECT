extends Node3D
@onready var root: Node3D = $"."
@export var SPEED : float =  32

var damg : int = 1

func _physics_process(delta: float) -> void:
	root.position += root.transform.basis * Vector3(0,0,-SPEED) * delta

func _on_hit_area_body_entered(body: Node3D) -> void:
	if body == Global.player:
		Global.player.hit(damg)
		queue_free()
