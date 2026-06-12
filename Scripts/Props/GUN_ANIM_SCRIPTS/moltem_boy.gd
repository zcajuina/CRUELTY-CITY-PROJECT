extends Node3D
@onready var sprite_shoot: Sprite3D = $MOLTEM_BOY2/MOLTEM_BOY/SPRITE_SHOOT
@onready var sprite_idle: AnimatedSprite3D = $MOLTEM_BOY2/MOLTEM_BOY/SPRITE_IDLE

func _ready() -> void:
	sprite_idle.play("IDLE")

func _process(delta: float) -> void:
	if Global.player.gun_sm != null:
		match Global.player.gun_sm.cur_state():
			"gun_idle":
				sprite_idle.show()
				sprite_shoot.hide()
			"gun_shoot":
				sprite_idle.hide()
				sprite_shoot.show()
