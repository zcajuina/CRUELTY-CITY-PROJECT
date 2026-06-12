extends HBoxContainer
@onready var aug_btn: Button = $AUG_BTN
@onready var char_btn: Button = $CHAR_BTN
@onready var info_btn: Button = $INFO_BTN

@onready var tab_label: Label = $"../TAB_LABEL"

@onready var augs: Panel = $"../AUGS"
@onready var char: Panel = $"../CHAR"
@onready var info: Panel = $"../INFO"

@onready var head_btn: Button = $"../HEAD_BTN"
@onready var chest_btn: Button = $"../CHEST_BTN"
@onready var arm_btn: Button = $"../ARM_BTN"
@onready var leg_btn: Button = $"../LEG_BTN"




func show_panel(panel_name : String):
	augs.hide()
	char.hide()
	info.hide()

	head_btn.hide()
	chest_btn.hide()
	arm_btn.hide()
	leg_btn.hide()

	match panel_name:
		"augs":
			augs.show()
			tab_label.text = "IMPLANTS"
			
			head_btn.show()
			chest_btn.show()
			arm_btn.show()
			leg_btn.show()
		"char":
			char.show()
			tab_label.text = "APPARENCE"
		"info":
			info.show()
			tab_label.text = "USER INFO"


func _on_aug_btn_pressed() -> void:
	show_panel("augs")
	if char.anim != null:
		char.anim.play("default/BIO_POSE")

func _on_char_btn_pressed() -> void:
	show_panel("char")
	if char.anim != null:
		char.anim.play("default/IDLE")

func _on_info_btn_pressed() -> void:
	show_panel("info")
	if char.anim != null:
		char.anim.play("default/IDLE")
	$"../INFO/INFOS".update_stats_display()
