extends Node3D
#@onready var water_anim: AnimationPlayer = $"../HIDDEN_VALEY_RIVER/HIDDEN_VALEY_RIVER/AnimationPlayer"

@onready var trigon_1: Node3D = $TRIGON_1
@onready var trigon_2: Node3D = $TRIGON_2
@onready var trigon_3: Node3D = $TRIGON_3

@onready var trigon_1_anim: AnimationPlayer = $TRIGON_1/AnimationPlayer
@onready var trigon_2_anim: AnimationPlayer = $TRIGON_2/AnimationPlayer
@onready var trigon_3_anim: AnimationPlayer = $TRIGON_3/AnimationPlayer

var water_base_color : Vector3 = Vector3(0.0,0.578,1.0)
var water_magic_color : Vector3 = Vector3(1.0,0.0,0.423)
var water_current_color : Vector3 = Vector3(0.0,0.578,1.0)

var hostile : bool = true

func _ready() -> void:
	if trigon_1_anim != null:
		trigon_1_anim.play("TRIGON_MOTION")
		trigon_2_anim.play("TRIGON_MOTION")
		trigon_3_anim.play("TRIGON_MOTION")
	#print(water_anim)

#func _process(_delta: float) -> void:
	#_check_player_distance()

#func _check_player_distance():
	#if hostile == true:
		#var distance = self.global_position.distance_to(Global.player.global_position)
		#if distance <= 128:
			#Global.player.hit_no_anim(800)

#func _hit():
	#if hostile == true:
		#Global.player.hit_no_anim(800)

func _on_coin_area_body_entered(body: Node3D) -> void:
	if body.name == "COIN_SPECIAL" and hostile:
		hostile = false
		body.queue_free()
		Global.player.get_node("ImpCoiny").has_coin = true
		Global.player.hud.dbox.auto_remove_add_text(Diag.get_dialog("trigon_thanks")[0])
		#water_anim.play("WATER_RED")


func _on_trigon_hostile_area_body_entered(body: Node3D) -> void:
	if body == Global.player:
		if hostile == true:
			Global.player.hit_no_anim(800)
