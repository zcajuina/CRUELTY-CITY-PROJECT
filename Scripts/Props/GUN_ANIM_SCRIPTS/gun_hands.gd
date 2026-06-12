extends Node3D
@onready var animation_player: AnimationPlayer = $MAOZINHA/AnimationPlayer

func _ready() -> void:
	animation_player.play("IDLE")
