extends Panel
@export var badge_tittle_text  : String = ""
@export var badge_desc_text  : String = ""
@export var badge_image : Texture2D = null
@onready var badge_icon: Sprite2D = $BADGE_ICON

@onready var badge_panel: Panel = $"../../BADGE_PANEL"

@onready var badge_sprite: Sprite2D = $"../../BADGE_PANEL/BADGE_SPRITE"
@onready var badge_name: Label = $"../../BADGE_PANEL/BADGE_NAME"
@onready var badge_desc: Label = $"../../BADGE_PANEL/BADGE_DESC"
const DUMMY_BADGE = preload("uid://b13s5xa00dvhv")



func _ready() -> void:
	if Global.player_badges.has(badge_tittle_text):
		if badge_image != null:
			badge_icon.texture = badge_image
		else:
			badge_icon.texture = DUMMY_BADGE
	else:
		badge_icon.texture = null

func _show_badge_logic():
	if Global.player_badges.has(badge_tittle_text):
		badge_panel.show()

func _on_mouse_entered() -> void:
	_show_badge_logic()
	#badge_panel.show()
	#_badge_anim_in()
	_detail_badge()

func _on_mouse_exited() -> void:
	#await get_tree().process_frame
	#_badge_anim_out()
	badge_panel.hide()

func _detail_badge():
	badge_name.text = badge_tittle_text
	badge_desc.text = badge_desc_text
	badge_sprite.texture = badge_icon.texture
	badge_sprite.scale = Vector2(0.375,0.375)

func _badge_anim_in():
	var tween = create_tween()
	badge_panel.scale = Vector2(0,0)
	tween.tween_property(badge_panel,"scale",Vector2(1,1),0.05)
	await tween.finished
func _badge_anim_out():
	var tween = create_tween()
	tween.tween_property(badge_panel,"scale",Vector2(0,0),0.25)
	await tween.finished
	badge_panel.hide()
