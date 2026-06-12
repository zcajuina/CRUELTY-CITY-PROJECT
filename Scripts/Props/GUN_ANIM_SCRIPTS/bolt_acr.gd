extends Node3D
@onready var bolt_canon: MeshInstance3D = $BOLT_ACR/BOLT_BODY/BOLT_CANON
@onready var gamma_rays: GPUParticles3D = $GAMMA_RAYS
@onready var lights_root: Node3D = $BOLT_ACR/LIGHTS_ROOT
@onready var microwave_sound: AudioStreamPlayer3D = $MICROWAVE_SOUND
@onready var micro_beep: AudioStreamPlayer3D = $MICRO_BEEP
@onready var microwave_sound_2: AudioStreamPlayer3D = $MICROWAVE_SOUND2
@onready var guiger_counter: AudioStreamPlayer3D = $GUIGER_COUNTER

var little_lights : Array

const lights_on : float = 1
const lights_out : float = -0.9

const pitch_normal : float = 0.4
const pitch_fire : float = 1.1

var rot_tween: Tween = null
var is_rotating: bool = false
var current_rotation_speed: float = 0.0
var target_rotation_speed: float = 0.0
var rotation_accumulator: float = 0.0
const MAX_SPEED: float = 780.0  # Degrees per second
const ACCELERATION: float = 4.0  # How fast it speeds up
const DECELERATION: float = 1.5  # How fast it slows down

func _ready() -> void:
	little_lights = lights_root.get_children()


func _process(delta: float) -> void:
	_anim_bolt_rot(delta)
	_lights_anim(delta)
	lights_root.rotation_degrees.x = bolt_canon.rotation_degrees.x

func _lights_anim(delta: float):
	if is_rotating:
		#bolt_canon.position.x = lerpf(bolt_canon.position.z,1.771,0.2)
		microwave_sound_2.pitch_scale = lerpf(microwave_sound.pitch_scale,pitch_fire,0.06)
		microwave_sound.pitch_scale = lerpf(microwave_sound.pitch_scale,pitch_fire,0.04)
		guiger_counter.pitch_scale = lerpf(guiger_counter.pitch_scale,1.8,0.2)
		for x in little_lights:
			x.omni_attenuation = lerpf(x.omni_attenuation, lights_on,0.2)
			gamma_rays.emitting = true
	else:
		#bolt_canon.position.x = lerpf(bolt_canon.position.z,1.771,0.2)
		microwave_sound_2.pitch_scale = lerpf(microwave_sound.pitch_scale,pitch_fire,0.04)
		microwave_sound.pitch_scale = lerpf(microwave_sound.pitch_scale,pitch_normal,0.04)
		guiger_counter.pitch_scale = lerpf(guiger_counter.pitch_scale,0.3,0.4)
		for x in little_lights:
			x.omni_attenuation =lerpf(x.omni_attenuation, lights_out,0.2) 
			gamma_rays.emitting = false

func _anim_bolt_rot(delta: float):
	if Input.is_action_pressed("mb_left"):
		is_rotating = true
		# Accelerate while holding
		target_rotation_speed = MAX_SPEED
		current_rotation_speed = lerp(current_rotation_speed, target_rotation_speed, ACCELERATION * delta)
		
		# Apply rotation
		rotation_accumulator += current_rotation_speed * delta
		
		# Apply to bolt
		bolt_canon.rotation_degrees.x = rotation_accumulator
		
	elif Input.is_action_just_released("mb_left"):
		micro_beep.pitch_scale = 1
		micro_beep.play()
		is_rotating = false
		# Start deceleration when released
		target_rotation_speed = 0.0
	if Input.is_action_just_pressed("mb_left"):
		micro_beep.pitch_scale = 1.1
		micro_beep.play()
	# Deceleration when not pressing or after release
	if not Input.is_action_pressed("mb_left"):
		is_rotating = false
		current_rotation_speed = lerp(current_rotation_speed, target_rotation_speed, DECELERATION * delta)
		
		# Only apply rotation if there's still speed
		if abs(current_rotation_speed) > 0.5:
			rotation_accumulator += current_rotation_speed * delta
			bolt_canon.rotation_degrees.x = rotation_accumulator
		else:
			current_rotation_speed = 0.0
			rotation_accumulator = 0.0
			#bolt_canon.rotation_degrees.z = 0

	# Optional: Reset when reaching full circle (if you want it to reset)
	#if abs(rotation_accumulator) >= 360.0:
		#rotation_accumulator = 0.0
		#bolt_canon.rotation_degrees.z = 0
