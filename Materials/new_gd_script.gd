extends StandardMaterial3D

# Day/night settings
@export var day_emission: float = 0.0
@export var night_emission: float = 1.0
@export var day_alpha: float = 1.0
@export var night_alpha: float = 0.5  # Example: semi-transparent at night
@export var transition_speed: float = 2.0  # Transition smoothness

var current_blend: float = 0.0
var target_blend: float = 0.0

func _ready():
	# Ensure we're using transparency if needed
	if night_alpha < 1.0:
		self.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	


func _process(delta):
	print("im here")
