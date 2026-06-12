# CameraTweener.gd (Add as autoload)
extends Node

var active_tween: Tween = null
var original_camera: Camera3D = null
var temp_camera: Camera3D = null

func tween_camera(from_camera: Camera3D, to_camera: Camera3D, duration: float = 1.0, trans: Tween.TransitionType = Tween.TRANS_QUART, ease: Tween.EaseType = Tween.EASE_IN_OUT):
	# Kill any existing tween
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	# Store original camera
	original_camera = from_camera
	
	# Create temporary camera
	temp_camera = Camera3D.new()
	temp_camera.current = true
	from_camera.get_parent().add_child(temp_camera)
	
	# Set temp camera to match original camera's position and rotation
	temp_camera.global_position = from_camera.global_position
	temp_camera.global_rotation = from_camera.global_rotation
	
	# Store original camera properties to restore later
	var original_current = from_camera.current
	from_camera.current = false
	
	# Create tween
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(trans)
	active_tween.set_ease(ease)
	
	# Tween position and rotation
	active_tween.tween_property(temp_camera, "global_position", to_camera.global_position, duration)
	active_tween.tween_property(temp_camera, "global_rotation", to_camera.global_rotation, duration)
	
	# Wait for tween to finish
	await active_tween.finished
	
	to_camera.make_current()
	
	# Clean up temp camera
	if temp_camera:
		temp_camera.queue_free()
		temp_camera = null
	
	active_tween = null
	print("Camera tween completed")

func tween_to_position(from_camera: Camera3D, target_position: Vector3, target_rotation: Vector3, duration: float = 1.0, trans: Tween.TransitionType = Tween.TRANS_QUART, ease: Tween.EaseType = Tween.EASE_IN_OUT):
	# Kill any existing tween
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	# Store original camera
	original_camera = from_camera
	
	# Create temporary camera
	temp_camera = Camera3D.new()
	temp_camera.current = true
	from_camera.get_parent().add_child(temp_camera)
	
	# Set temp camera to match original camera's position and rotation
	temp_camera.global_position = from_camera.global_position
	temp_camera.global_rotation = from_camera.global_rotation
	
	# Store original camera properties
	var original_current = from_camera.current
	from_camera.current = false
	
	# Create tween
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(trans)
	active_tween.set_ease(ease)
	
	# Tween position and rotation
	active_tween.tween_property(temp_camera, "global_position", target_position, duration)
	active_tween.tween_property(temp_camera, "global_rotation", target_rotation, duration)
	
	# Wait for tween to finish
	await active_tween.finished
	
	# Restore original camera
	from_camera.current = original_current
	
	# Clean up
	if temp_camera:
		temp_camera.queue_free()
		temp_camera = null
	
	active_tween = null
	print("Camera tween to position completed")

func cancel_tween():
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	if temp_camera:
		temp_camera.queue_free()
		temp_camera = null
	
	if original_camera:
		original_camera.current = true
	
	active_tween = null
