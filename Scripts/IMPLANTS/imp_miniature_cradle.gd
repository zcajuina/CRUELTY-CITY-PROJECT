extends Node3D
@onready var cradle_mesh: Node3D = $CRADLE/IMP_MOON_MODEL
@onready var spark: Sprite3D = $CRADLE/IMP_MOON_MODEL/SPARK
@onready var deflect_snd: AudioStreamPlayer3D = $CRADLE/DEFLECT_SND

@onready var cradle: Area3D = $CRADLE
@export var chance_range : int = 3
var current_tween: Tween = null

func _ready() -> void:
	position = Global.player.head.position

func _process(delta: float) -> void:
	rotation_degrees.y += 0.5
	cradle_mesh.rotation_degrees.y -= 3

func _on_cradle_area_entered(area: Area3D) -> void:
	var chance = randi_range(1,chance_range)
	if chance == 1:
		if area.is_in_group("foe_bullet"):
			var area_pos = area.global_position
			area.get_parent().queue_free()
			await get_tree().process_frame
			_spark_deflect_tween()
			_deflect_tween(area_pos)
			print("BULLET_DEFLECTED")
			deflect_snd.play()
		else:
			print(area)
	else:
		print("COULD NOT DEFLECT BULLET")

func _deflect_tween(pos : Vector3):
		
		var range = 0.5
		# Calculate direction to the bullet
		var direction = (pos - global_position).normalized()
		
		# Calculate rotation angle in degrees (atan2 uses x and z for Y-axis rotation)
		var target_angle = atan2(direction.x, direction.z)
		
		# Kill any existing tween
		if current_tween and current_tween.is_running():
			current_tween.kill()
		
		# Create new tween for smooth rotation
		current_tween = create_tween()
		current_tween.set_parallel(true)
		current_tween.set_ease(Tween.EASE_OUT)
		current_tween.set_trans(Tween.TRANS_QUART)
		current_tween.tween_property(self, "rotation:y", target_angle, 0.2)
		current_tween.tween_property(cradle_mesh,"position",Vector3(randf_range(-range,range),randf_range(-range,range),1.25),0.2)
		await current_tween.finished
		current_tween = create_tween()
		current_tween.set_ease(Tween.EASE_OUT)
		current_tween.set_trans(Tween.TRANS_QUART)
		current_tween.tween_property(cradle_mesh,"position",Vector3(0,0,1.25),0.2)

func _spark_deflect_tween():
	spark.show()
	var scal = 0.5
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(spark,"scale",Vector3(scal,scal,scal),0.05)
	await tween.finished
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(spark,"scale",Vector3(0.2,0.2,0.2),0.05)
	await tween.finished
	spark.hide()
