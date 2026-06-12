extends Node3D
@onready var head: Node3D = $".."
@onready var tps_cam: Camera3D = $SpringArm3D/TPS_CAM
@onready var spring_arm: SpringArm3D = $SpringArm3D

@export var min_vertical_angle: float = -60.0  # Limite para baixo
@export var max_vertical_angle: float = 60.0   # Limite para cima

const sensi_multi = 28
var base_rotation: Vector3

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if Global.player_sm.cur_state() == "emoting":
			# Horizontal rotation (Y-axis)
			base_rotation.y += deg_to_rad(-event.relative.x * Global.player_sensi * sensi_multi)
			
			# Vertical rotation (X-axis)
			var vertical_change = deg_to_rad(-event.relative.y * Global.player_sensi * sensi_multi)
			base_rotation.x = clamp(base_rotation.x + vertical_change, 
				deg_to_rad(min_vertical_angle), 
				deg_to_rad(max_vertical_angle))
			
			# Apply rotation
			self.rotation = base_rotation

func _process(delta: float) -> void:
	if Global.player_sm.cur_state() == "emoting":
		if Input.is_action_just_pressed("wheel_up"):
			if spring_arm.spring_length < 4.0:
				spring_arm.spring_length += 0.25
		if Input.is_action_just_pressed("wheel_down"):
			if spring_arm.spring_length > 0.25:
				spring_arm.spring_length -= 0.25
