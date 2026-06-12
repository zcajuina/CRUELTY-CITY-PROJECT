extends Node
@export var effect_name : String = "poison"
@export var damage_amnt : int = 1
@onready var timer: Timer = $Timer
@onready var death_timer: Timer = $DEATH_TIMER
var daddy

func _ready() -> void:
	daddy = get_parent()


func _on_timer_timeout() -> void:
	if daddy.has_method("_hit") and !daddy == null:
		daddy._hit(damage_amnt)


func _on_death_timer_timeout() -> void:
	self.queue_free()

func _setup(nam : String = "poison",dam : int = 1,ticks : float = 1,death : float = 2):
	effect_name = nam
	damage_amnt = dam
	death_timer.wait_time = death
	timer.wait_time = ticks
	await get_tree().process_frame
	timer.start()
	death_timer.start()
	
