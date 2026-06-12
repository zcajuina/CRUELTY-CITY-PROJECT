extends Node3D

func _ready() -> void:
	Global.connect("day_reload",_on_day_reload)

func _hit(damage : int = 1, pos : Vector3 = Vector3.ZERO):
	self.visible = false
	self.collision_layer = 0

func _on_day_reload():
	self.visible = true
	#1 + 2 = 3 (é bitwise. puta merda.)
	self.collision_layer = 3
