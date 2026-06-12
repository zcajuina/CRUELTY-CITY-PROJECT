extends RigidBody3D
class_name HealthItem
@export var heal_ammount : int = 5
@export var food_mesh : FoodType = FoodType.SALGADIN
@onready var pizza: Node3D = $PIZZA
@onready var super_crunchers: Node3D = $SUPER_CRUNCHERS
@onready var soda: Node3D = $SODA
@onready var square_shape: CollisionShape3D = $SQUARE_SHAPE
@onready var cilinder_shape: CollisionShape3D = $CILINDER_SHAPE

enum FoodType {PIZZA,SALGADIN,SODA}

var junk_meshes : Array = [FoodType.SALGADIN,FoodType.SODA]


func _ready() -> void:
	#add_collision_exception_with(Global.player)
	await get_tree().process_frame
	match food_mesh:
		FoodType.PIZZA:
			pizza.show()
		FoodType.SALGADIN:
			super_crunchers.show()
		FoodType.SODA:
			soda.show()
			square_shape.process_mode = Node.PROCESS_MODE_DISABLED
			cilinder_shape.process_mode = Node.PROCESS_MODE_INHERIT

func junk_food_mesh():
	food_mesh = junk_meshes.pick_random()
func interact():
	if Global.player.health < Global.player_caps["max_health"]:
		Global.player.heal(heal_ammount)
		Global.player.visuais._heal_anim()
		Global._show_message("FOOD CONSUMED.","5+ health restored.",0.75,"GREEN",false)
		#Global.player.hud.alert_panel.sub_text(str("HEALTH ITEM CONSUMED! +",heal_ammount," HEALTH!"))
		self.queue_free()
	else:
		Global.player.hud.alert_panel.sub_text("HEALTH FULL!")
