extends Node3D
@onready var spot_light_3d: SpotLight3D = $FLASHLIGHT/FLASH/GUN_NOZZLE/SpotLight3D
var head_light
@onready var click_btn: AudioStreamPlayer3D = $FLASHLIGHT/FLASH/GUN_NOZZLE/CLICK_BTN
@onready var rim: Sprite3D = $FLASHLIGHT/FLASH/GUN_NOZZLE/RIM

func _process(delta: float) -> void:
	if not Global.on_menu:
		if Input.is_action_just_pressed("mb_left"):
			click_btn.play()
			spot_light_3d.visible = not spot_light_3d.visible
			rim.visible = not rim.visible
