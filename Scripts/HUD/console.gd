extends Control
@onready var rich_text: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/RichTextLabel
@onready var line_edit: LineEdit = $MarginContainer/ColorRect/VBoxContainer/LineEdit
@onready var hud: Control = $".."

func sub_text(text :String):
	rich_text.append_text("> "+str(text) + "\n")


func _on_line_edit_text_submitted(new_text: String) -> void:
	new_text = new_text.to_upper()
	match new_text:
		"DEATH":
			Global.player_core = "DEATH"
			sub_text("YOU'VE EMBRACED DEATH!")
			hud._match_core()
		"LIFE":
			Global.player_core = "LIFE"
			sub_text("DIVINE LIGHT RESTORED!")
			hud._match_core()
		"MEAGER","MAGNITUDE","DEFAULT":
			sub_text(match_altar(new_text))
		"HIT":
			Global.player.hit(50)
		_:
			pass
	line_edit.clear()
	Global._save_game()

func match_altar(altar : String):
	if altar == "MEAGER" or altar == "MAGNITUDE":
		Global.player_altar = altar
		Global._setup_player_stats(altar)
		Global._calculate_player_stats()
		return "ALTAR CHANGED!"
	else:
		return "ALTAR NOT FOUND"
