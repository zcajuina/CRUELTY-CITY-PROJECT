extends Node3D
@export var rotate_x : bool = false
@export var rotate_y : bool = false
@export var rotate_z : bool = false
@export var rotate_weight : float = 1.0
@export_group ("Sin wave","sin_")
@export var sin_x : bool = false
@export var sin_y : bool = false
@export var sin_z : bool = false
@export var sin_amp : float = 1.0
@export var sin_freq : float = 1.0
@export var sin_time_off : float = 0
@export var sin_center : float = 0

@export_group ("Scale Sin wave","sin_")
@export var sin_x_scale : bool = false
@export var sin_y_scale : bool = false
@export var sin_z_scale : bool = false
@export var sin_amp_scale : float = 1.0
@export var sin_freq_scale : float = 1.0
@export var sin_time_off_scale : float = 0
@export var sin_center_scale : float = 0


func _process(delta: float) -> void:
	if rotate_x:
		self.rotation_degrees.x += rotate_weight
	if rotate_y:
		self.rotation_degrees.y += rotate_weight
	if rotate_z:
		self.rotation_degrees.z += rotate_weight

	if sin_x:
		self.position.x += sine_wave(sin_amp,sin_freq,sin_time_off,sin_center)
	if sin_y:
		self.position.y += sine_wave(sin_amp,sin_freq,sin_time_off,sin_center)
	if sin_z:
		self.position.z += sine_wave(sin_amp,sin_freq,sin_time_off,sin_center)

	if sin_x_scale:
		self.scale.x += sine_wave(sin_amp_scale,sin_freq_scale,sin_time_off_scale,sin_center_scale)
	if sin_y_scale:
		self.scale.y += sine_wave(sin_amp_scale,sin_freq_scale,sin_time_off_scale,sin_center_scale)
	if sin_z_scale:
		self.scale.z += sine_wave(sin_amp_scale,sin_freq_scale,sin_time_off_scale,sin_center_scale)


func sine_wave(amplitude: float = 1.0, frequency: float = 1.0, time_offset: float = 0.0, center: float = 0.0) -> float:
	"""
	Returns a sine wave value between center - amplitude and center + amplitude
	
	Parameters:
	- amplitude: How far from center the wave goes
	- frequency: How fast it oscillates (cycles per second)
	- time_offset: Phase shift in seconds
	- center: The middle point of the wave
	"""
	var time = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	return center + amplitude * sin(time * frequency * TAU + time_offset)
