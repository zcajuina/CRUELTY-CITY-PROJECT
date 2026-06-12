extends RigidBody3D
class_name MoneyItem
@export var money_ammount : int = 0
@export var bio_currency : bool = false

@onready var bio_currency_model: Node3D = $BIO_CURRENCY
@onready var money_prop_model: Node3D = $MONEY_PROP


func match_currency():
	if bio_currency:
		bio_currency_model.visible = true
		money_prop_model.visible = false
	else:
		money_prop_model.visible = true
		bio_currency_model.visible = false


func _ready() -> void:
	self.add_collision_exception_with(Global.player)
	add_exeption_to_foes()
	await get_tree().process_frame
	match_currency()

func add_exeption_to_foes():
	for foe in get_tree().get_nodes_in_group("foes"):
		if foe is CharacterBody3D:  # or PhysicsBody2D
			self.add_collision_exception_with(foe)

func interact():
	if bio_currency:
		money_ammount = money_ammount * 10
	Global.player_cash_money += money_ammount
	#Global.player.hud.alert_panel.sub_text(str("MONEY AQUISITION COMPLETE!"))
	if bio_currency:
		Global._show_message("BIO CURRENCY AQUISITION COMPLETE",str("+",money_ammount))
	else:
		Global._show_message("MONEY AQUISITION COMPLETE",str("+",money_ammount))
	Global.player.hud.stock_market._update_money_label()
	self.queue_free()
