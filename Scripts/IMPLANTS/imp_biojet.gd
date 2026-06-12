extends Node

func _ready() -> void:
	Global.player.hud._add_control("BIO JET - LSHIFT")


func _physics_process(_delta: float) -> void:
	if Global.player != null:
		if Input.is_action_pressed("shift"):
			Global.player.velocity.y += 0.25
			Global.player.move_and_slide()
