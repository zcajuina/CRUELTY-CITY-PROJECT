extends Area3D
@export var fog_enabled : bool = true
@export var fog_density : float = 0
@export var fog_sky_affect : float = 0
@export var ambient_light_contribution : float = 0
@onready var world: WorldEnvironment = $"../../WorldEnvironment"


const default_values : Dictionary = {
	"fog": true,
	"fog_density": 0.0002,
	"ambient_light_contribution": 1,
	"fog_sky_affect": 0.25,
}


func _ready() -> void:
	self.connect("body_entered",_on_body_entered)
	self.connect("body_entered",_on_body_exited)
	


func _on_body_entered(body: Node3D) -> void:
	if world == null:
		print("WORLD_NOT FOUND")
		return
	if body == Global.player:
		world.environment.fog_enabled = self.fog_enabled
		world.environment.fog_density = self.fog_density
		world.environment.fog_sky_affect = self.fog_sky_affect
		world.environment.ambient_light_sky_contribution = self.ambient_light_contribution


func _on_body_exited(body: Node3D) -> void:
	if world == null:
		print("WORLD_NOT FOUND")
		return
	if body == Global.player:
		world.environment.fog_enabled = default_values["fog"]
		world.environment.fog_density = default_values["fog_density"]
		world.environment.fog_sky_affect = default_values["fog_sky_affect"]
		world.environment.ambient_light_sky_contribution = default_values["ambient_light_contribution"]
