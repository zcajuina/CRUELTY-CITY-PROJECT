extends Control
@onready var scene_to_go : String = "res://Scenes/WORLD/NEW_CRUS_DISTRICT/CRUS_DISTRICT_v2.tscn"
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var melt: Sprite2D = $MELT

var load_status : int = 0
var progresso : Array = []
var cena_destinada

@onready var mask: Sprite2D = $MASK
@onready var abraxas_face: AnimatedSprite2D = $MASK/ABRAXAS_FACE


func _ready() -> void:
	mask.rotation_degrees = randi_range(0,360)
	abraxas_face.play("default")
	scene_to_go = SceneChanger.scene_to_change
	await get_tree().create_timer(.5).timeout
	ResourceLoader.load_threaded_request(scene_to_go)

func _process(_delta: float) -> void:
	mask.rotation += deg_to_rad(1)
	if scene_to_go != "":
		load_status = ResourceLoader.load_threaded_get_status(scene_to_go,progresso)
		progress_bar.value = progresso[0]
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			await get_tree().create_timer(.5).timeout
			var cena_destinada = ResourceLoader.load_threaded_get(scene_to_go)
			if cena_destinada != null:
				get_tree().change_scene_to_packed(cena_destinada)
	var progres = progress_bar.value
	melt.material.set_shader_parameter("movement",progres-1)
