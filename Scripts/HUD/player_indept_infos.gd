extends RichTextLabel
var player_info : String = ""
@onready var code_bar_text: Label = $"../CODE_BAR/CODE_BAR_TEXT"
@onready var code_bar_image: ColorRect = $"../CODE_BAR/CODE_BAR_IMAGE"
@onready var char_name_edit: LineEdit = $"../../CHAR_NAME_EDIT"


func update_stats_display():
	Global.player_tittle = get_title_from_networth(Global.player_networth_money)
	var text = ""
	
	# Build the formatted text with global values
	text += "NAME:" + Global.player_name + "\n"
	text += "CORE: " + str(Global.player_core) + "\n"
	text += "ALTAR: " + str(Global.player_altar) + "\n"
	text += "LIVES TAKEN: " + str(Global.player_lives_taken) + "\n"
	text += "DEATHS: " + str(Global.player_deaths) + "\n"
	text += "NETWORTH: " + "R$ "+str(Global.player_networth_money) + "\n"
	text += "CASH: " + "R$ "+str(Global.player_cash_money) + "\n"
	text += "IMPLANTS: " + str(Global.implants_owned.size()) + "/" + str(Global.total_implants_ammount) + "\n"
	#text += "CLOTHES: " + str(Global.clothes_current) + "/" + str(Global.clothes_max) + "\n"
	text += "SECRETS: " + str(Global.player_unique_props.size()) + "\n"
	text += "TITLE: " + get_title_from_networth(Global.player_networth_money)
	
	# Set the text
	self.text = text
	if Global.player_bar_code_number != "":
		code_bar_image.material.set_shader_parameter("seed",int(Global.player_bar_code_number.substr(0,2)))
		code_bar_text.text = Global.player_bar_code_number

func get_title_from_networth(networth: float) -> String:
	if networth <= 500:
		return "Low Networth Individual"
	elif networth <= 1000:
		return "Modest Earner"
	elif networth <= 5000:
		return "Growing Fortunes"
	elif networth <= 10000:
		return "Comfortable Living"
	elif networth <= 50000:
		return "Wealthy Person"
	elif networth <= 100000:
		return "High Networth Individual"
	elif networth <= 500000:
		return "Rich Individual"
	elif networth <= 1000000:
		return "Millionaire"
	elif networth <= 10000000:
		return "Multi-Millionaire"
	elif networth <= 100000000:
		return "Centimillionaire"
	else:
		return "Billionaire"

func _on_char_name_edit_text_submitted(new_text: String) -> void:
	if new_text != "":
		Global.player_name = new_text
		print("New name registered: ", new_text)
	else:
		new_text = "MT-FOXTROT"
		char_name_edit.text = new_text
		Global.player_name = new_text
		print("[ERROR]No name given!\nNew name registered: ", new_text)
	update_stats_display()
