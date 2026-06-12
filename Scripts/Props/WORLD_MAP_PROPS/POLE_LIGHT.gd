extends Node3D
@onready var light: CSGCylinder3D = $LIGHT
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

func _process(delta: float) -> void:
	match Global.daytime:
		"DIA":
			light.material.emission_energy_multiplier = 0.0
			omni_light_3d.light_energy = 0.0
		"NOITE":
			light.material.emission_energy_multiplier = 1
			omni_light_3d.light_energy = 8
