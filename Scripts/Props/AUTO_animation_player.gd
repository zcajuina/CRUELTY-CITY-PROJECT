extends AnimationPlayer
@export var anim_name : String = ""
@export var random_time : bool = false
func _ready() -> void:
	if self.has_animation(anim_name):
		play(anim_name)
		if random_time:
			self.speed_scale = randf_range(1,0.75)
