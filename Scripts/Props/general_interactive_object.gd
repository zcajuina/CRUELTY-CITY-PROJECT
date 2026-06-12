extends Node3D

# === UNIQUE OBJECTS ===
@export var unique_prop : bool = false
@export var unique_prop_name : String = "THINGY"

# === INSPECT INFO ===
@export var inspect_name : String = "LOREM IPSUM"
@export var inspect_desc : String = "IPSUM LOREM"

# === DIALOGUE ===
@export_group("Dialogue", "dialogue_")
@export var dialogue_enabled : bool = false
@export var dialogue_tag : String = "default"

# === MESSAGE ===
@export_group("Message", "msg_")
@export var msg_enabled : bool = false
@export var msg_title : String = "TITLE"
@export var msg_subtitle : String = "SUBTITLE"
@export var msg_duration : float = 1.0
@export var msg_color : String = "GREEN"

# === GUN ===
@export_group("Gun", "gun_")
@export var gun_enabled : bool = false
@export var gun_name : String = ""

# === BADGE ===
@export_group("Badge", "badge_")
@export var badge_enabled : bool = false
@export var badge_name : String = ""

# === MONEY ===
@export_group("Money", "money_")
@export var money_enabled : bool = false
@export var money_amount : int = 0

#=== AUG ===
@export_group("Augs","aug_")
@export var aug_enabled : bool = false
@export var aug_name : String = ""

# === CLEANUP ===
@export_group("Cleanup")
@export var delete_after_interaction : bool = false
@export var delete_after_dialogue : bool = false

func _ready() -> void:
	Global.player.hud.dbox.connect("dialogue_finished", _on_diag_finished)
	
	if unique_prop and Global.player_unique_props.has(unique_prop_name):
		self.queue_free()

func interact():
	if dialogue_enabled:
		Global.start_dialogue(dialogue_tag)
	if money_enabled:
		Global.player_cash_money += money_amount
		Global._show_message("MONEY ACQUISITION COMPLETE", "+" + str(money_amount))
	if msg_enabled:
		Global._show_message(msg_title, msg_subtitle, msg_duration, msg_color)
	if badge_enabled and badge_name != "" and badge_name not in Global.player_badges:
		Global.player_badges.append(badge_name)
		Global._show_message("BADGE EARNED: " + badge_name, "", 2.0, "PURPLE")
		Global._save_game()
	if aug_enabled:
		_add_aug()
	if gun_enabled:
		_add_gun()
	if unique_prop:
		Global.player_unique_props.append(unique_prop_name)
		Global._save_game()
	
	
	await get_tree().process_frame
	
	
	if delete_after_interaction:
		self.queue_free()


func _on_diag_finished():
	if delete_after_dialogue:
		self.queue_free()

func _add_gun():
	if not Global.guns_owned.has(gun_name):
		Global.guns_owned.append(gun_name)
		Global._show_message(gun_name + " ACQUISITION COMPLETE!", gun_name + " CAN NOW BE EQUIPED ON THE MENU.")
		Global._save_game()

func _add_aug():
	if not Global.implants_owned.has(aug_name):
		Global.implants_owned.append(aug_name)
		Global._show_message(aug_name + " ACQUISITION COMPLETE!", aug_name + " CAN NOW BE EQUIPED ON THE MENU.")
		Global._save_game()
