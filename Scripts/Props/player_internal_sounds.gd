extends Node
@onready var player: CharacterBody3D = $".."

@onready var shoot_snd: AudioStreamPlayer = $SHOOT_SND
@onready var shoot_snd_2: AudioStreamPlayer = $SHOOT_SND2
@onready var reload_snd: AudioStreamPlayer = $RELOAD_SND
@onready var jump_snd: AudioStreamPlayer = $JUMP_SND
@onready var fall_snd: AudioStreamPlayer = $FALL_SND
@onready var heal_snd: AudioStreamPlayer = $HEAL_SND
@onready var pain_snd: AudioStreamPlayer = $PAIN_SND

func _ready() -> void:
	player.connect("damage",_on_player_damage)

func _on_player_damage():
	pain_snd.play()
