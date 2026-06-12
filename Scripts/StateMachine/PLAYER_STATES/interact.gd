extends State
@onready var gun_sm: StateMachine = $"../../GUN_SM"

func enter() -> void:
	gun_sm.change_state("gun_interact")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.on_menu = true

func exit():
	gun_sm.change_state("gun_idle")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.on_menu = false
