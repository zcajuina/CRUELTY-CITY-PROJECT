extends Node3D
@onready var env: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D
var cave_tween : Tween
# Time settings
var sun_speed: float = 0.25 # Degrees per second
var current_angle: float = 270.0  # Start at midday

func _ready() -> void:
	Global.world_node = self
	set_time_clock(14.0,0.0)

func _process(delta: float) -> void:
	current_angle += sun_speed * delta
	if current_angle >= 360.0:
		current_angle -= 360.0
	
	sun.rotation_degrees.x = current_angle
	Global.sun_rotation = sun.rotation_degrees.x
	_sun_energy()
	Global.cur_time = get_clock_time_24h()

# Set time directly by angle
func set_time_angle(angle: float):
	current_angle = angle
	if current_angle >= 360.0:
		current_angle -= 360.0
	if current_angle < 0:
		current_angle += 360.0

# Set time by clock (using a lookup table)
func set_time_clock(hour: int, minute: int):
	# This lookup table maps clock time to angle
	# Based on your shader: 270° = midday, 90° = midnight
	var total_minutes = hour * 60 + minute
	
	# 24 hours = 360 degrees, so 1 minute = 0.25 degrees
	# But we need 12:00 (720 minutes) to be 270 degrees
	var angle = fmod((total_minutes * 0.25 + 90), 360)
	set_time_angle(angle)

# Get current clock time
func get_clock_time() -> String:
	# Convert angle back to clock time
	# 270° = 12:00, so subtract 90° offset
	var angle = current_angle
	var adjusted = angle - 90
	if adjusted < 0:
		adjusted += 360
	
	var total_minutes = adjusted * 4  # 1° = 4 minutes
	var hours = int(total_minutes / 60)
	var minutes = fmod(total_minutes,60)
	#var minutes = int(total_minutes / 60)
	
	# Fix for 12:00 showing as 0:00
	if hours == 0:
		hours = 12
	elif hours > 12:
		hours -= 12
	
	return "%02d:%02d" % [hours, minutes]

# Get 24-hour format
func get_clock_time_24h() -> String:
	var angle = current_angle
	var adjusted = angle - 90
	if adjusted < 0:
		adjusted += 360
	
	var total_minutes = adjusted * 4
	var hours = int(total_minutes / 60)
	var minutes = fmod(total_minutes,60)
	#var minutes = int(total_minutes % 60)
	
	return "%02d:%02d" % [hours, minutes]

func _sun_energy():
	#function so the light does not sip trough the floor when is night and get back up when is day
	var rot = sun.rotation_degrees.x
	if rot >= 0 and rot <= 180:
		sun.light_energy = 0
		Global.daytime = "NOITE"
	if rot >= 180 and rot <=360:
		sun.light_energy = 1
		Global.daytime = "DIA"

func _get_time():
	var rot = sun.rotation_degrees.x
	if rot >= 0 and rot <= 180:
		return "NOITE"
	if rot >= 180 and rot <=360:
		return "DIA"

func _on_dark_area_body_entered(body: Node3D) -> void:
	if body == Global.player:
		#env.environment.ambient_light_sky_contribution = 0
		print(env.environment.get_reflection_source())
		env.environment.set_reflection_source(1)
		#env.environment.reflected_light_source = 0
		#env.environment.fog_enabled = false
		if cave_tween != null:
			cave_tween.kill()
		cave_tween = create_tween()
		cave_tween.tween_property(env,"environment:ambient_light_sky_contribution",0,0.25)
		#sun.hide()
		#tween.tween_property(env,"environment:fog_enabled",false,0.25)

func _on_dark_area_body_exited(body: Node3D) -> void:
	if body == Global.player:
		if cave_tween != null:
			cave_tween.kill()
		cave_tween = create_tween()
		cave_tween.tween_property(env,"environment:ambient_light_sky_contribution",1,0.25)
		env.environment.set_reflection_source(0)
		#sun.show()
		#env.environment.set_reflection_source(valor)
		#print(env.environment.get_reflection_source())
		#tween.tween_property(env,"environment:fog_enabled",true,0.25)
		#env.environment.ambient_light_sky_contribution = 1
		#env.environment.fog_enabled = true
