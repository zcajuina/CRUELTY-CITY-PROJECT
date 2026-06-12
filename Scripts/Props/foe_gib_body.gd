extends CharacterBody3D
@onready var gib_snd: AudioStreamPlayer3D = $GIB_SND

var gib_durabil : int = 24

func _ready() -> void:
	add_collision_exception_with(Global.player)

func _spawn_gib_organs():
	var random_organ_dic = Global.gibbing_results[randi_range(1,3)]
	for x in len(random_organ_dic):
		var organ  = load("res://Scenes/Props/ORGANS/GenericRigidOrgan.tscn").instantiate()
		self.get_parent().add_child(organ)
		organ.global_position = self.global_position + Vector3(0,0.5,0)
		organ.rotation = Vector3(randf_range(0,5),randf_range(0,5),randf_range(0,5))
		organ.organ_name = random_organ_dic[x]

func _hit(damage : int, pos : Vector3):
	gib_durabil -= damage
	if gib_durabil <=0:
		_spawn_gib_organs()
		Global._spawn_part("res://Particles/part_big_blood_splat.tscn",self.global_position)
		gib_snd.play()
		visible = false



func _on_gib_snd_finished() -> void:
	queue_free()
