extends Node3D
@onready var slot_0: MeshInstance3D = $THE_ALTAR_OF_GREED_CURSE/SLOT_0
@onready var slot_1: MeshInstance3D = $THE_ALTAR_OF_GREED_CURSE/SLOT_1
@onready var slot_2: MeshInstance3D = $THE_ALTAR_OF_GREED_CURSE/SLOT_2
@onready var green_light: OmniLight3D = $GREEN_LIGHT
@onready var red_light: OmniLight3D = $RED_LIGHT
@onready var altar: Node3D = $THE_ALTAR_OF_GREED_CURSE
@onready var shaker: ShakerComponent3D = $THE_ALTAR_OF_GREED_CURSE/ShakerComponent3D
@onready var win_snd: AudioStreamPlayer = $WIN_SND
@onready var lose_snd: AudioStreamPlayer = $LOSE_SND
@onready var win_part: GPUParticles3D = $THE_ALTAR_OF_GREED_CURSE/WIN_PART
@onready var lose_part: GPUParticles3D = $THE_ALTAR_OF_GREED_CURSE/LOSE_PART

var easy = [slot_0,slot_1,slot_2]

var animating = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	shaker.play_shake()
	await _start_anim()
	await get_tree().create_timer(0.75).timeout
	animating = true
	await get_tree().create_timer(1.5).timeout
	animating = false
	_angle_snap()
	await get_tree().create_timer(4.5).timeout
	await _end_anim()
	self.queue_free()

func _start_anim():
	altar.position.y = 8.0
	altar.rotation_degrees.x = -45
	altar.rotation_degrees.z = -13
	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween1.set_trans(Tween.TRANS_BACK)
	tween1.set_parallel(true)
	tween1.tween_property(altar,"position:y",0,0.75)
	tween1.tween_property(altar,"rotation_degrees:x",0,0.85)
	tween1.tween_property(altar,"rotation_degrees:z",0,0.85)
	await tween1.finished


	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_QUART)
	#tween.set_parallel(true)
	#tween.tween_property(slot_0,"rotation_degrees:x",slot_0.rotation_degrees.x - 180,0.65)
	#tween.tween_property(slot_1,"rotation_degrees:x",slot_1.rotation_degrees.x - 180,0.65)
	#tween.tween_property(slot_2,"rotation_degrees:x",slot_2.rotation_degrees.x - 180,0.65)

func _end_anim():
	green_light.visible = false
	red_light.visible = false
	altar.position.y = 0
	altar.rotation_degrees.x = 0
	altar.rotation_degrees.z = 0
	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween1.set_trans(Tween.TRANS_BACK)
	tween1.set_parallel(true)
	tween1.tween_property(altar,"position:y",8,0.45)
	tween1.tween_property(altar,"rotation_degrees:x",15,0.25)
	tween1.tween_property(altar,"rotation_degrees:z",15,0.25)
	await tween1.finished

func _rotate_tambor():
	if animating == true:
		slot_0.rotation_degrees.x -= 45/4
		slot_1.rotation_degrees.x -= 45/4
		slot_2.rotation_degrees.x -= 45/4

func _process(delta: float) -> void:
	_rotate_tambor()



func _angle_snap():
	var rot = slot_0.rotation_degrees.x
	var chance = randi_range(0,1)
	if chance == 1:
		_light("green")
		win_snd.play()
		Global._show_message("YOU HAVE BEEN BLESSED WITH PRIMORDIAL LUCK!","")
		win_part.emitting = true 
		slot_0.rotation_degrees.x = -45
		slot_1.rotation_degrees.x = -45
		slot_2.rotation_degrees.x = -45
	else:
		_light("red")
		lose_snd.play()
		Global._show_message("YOU HAVE BEEN CURSED WITH ANCIENT MISFORTUUNE!","",3.5,"RED")
		lose_part.emitting = true 
		slot_0.rotation_degrees.x = -135.0
		slot_1.rotation_degrees.x = -135.0
		slot_2.rotation_degrees.x = -135.0

func _light(color : String):
	var lighto
	match color:
		"green":
			lighto = green_light
		"red":
			lighto = red_light
	var is_on = true
	for x in range(7):
		lighto.visible = is_on
		is_on = not is_on
		await get_tree().create_timer(0.25).timeout
	return true

func _green_light():
	green_light.show()
	
func _red_light():
	red_light.show()
