extends SubViewport
@onready var cross_hair: Sprite2D = $"../Control/CROSS_HAIR"
@onready var foot_anim_player: AnimationPlayer = $FOOT_ANIM_PLAYER
@onready var safe_hit_snd: AudioStreamPlayer = $"../SAFE_HIT_SND"
@onready var camera: Camera3D = $"../../.."
@onready var sub_view_cam: Camera3D = $SubViewCam
@onready var reload_bar: Control = $"../Control/RELOAD_BAR"
@onready var target: ColorRect = $"../Control/RELOAD_BAR/TARGET"
@onready var weapon_pivot: Node3D = $SubViewCam/WEAPON_PIVOT
@onready var raycast: RayCast3D = $"../../../FOOT_RAYCAST"




var screen_size : Vector2

#func _ready() -> void:
	#get_tree().root.size_changed.connect(_on_window_size_changed)
	#_on_window_size_changed()
#
#func _on_window_size_changed():
	#fix_screen_positioning()
#
#func fix_screen_positioning():
	#screen_size = get_window().size
	#size = screen_size
	#cross_hair.global_position.x = screen_size[0] / 2
	#cross_hair.global_position.y = screen_size[1] / 2

func _weapon_clip_fix():
	pass

func _on_safe_hit_snd_finished() -> void:
	safe_hit_snd.pitch_scale = randf_range(0.8,1.8)

func _inspector_show():
	pass

func _process(delta: float) -> void:
	cross_hair.position = get_viewport().get_size() / 2
	#sub_view_cam.global_transform = camera.global_transform
