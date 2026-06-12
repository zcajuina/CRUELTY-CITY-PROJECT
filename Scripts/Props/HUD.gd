extends Control
@onready var player: CharacterBody3D = $".."
@onready var head: Node3D = $"../Head"
@onready var camera: Camera3D = $"../Head/Camera3D"
@onready var mag: Label = $HUD_VARS/MAG
@onready var storage: Label = $HUD_VARS/STORAGE
@onready var life: Label = $HUD_VARS/LIFE
@onready var gun_raycast: Node3D = $"../Head/Camera3D/GUN_RAYCAST"
@onready var sub_viewport: SubViewport = $"../Head/Camera3D/visuais/SubViewportContainer/SubViewport"
@onready var pause_screen: Control = $PAUSE_SCREEN
@onready var death_screen: Control = $DEATH_SCREEN
@onready var hud_vars: Control = $HUD_VARS
@onready var core: AnimatedSprite2D = $HUD_VARS/CORE
@onready var suicide_alert: Control = $SUICIDE_ALERT
@onready var head_rot: Label = $HUD_VARS/HEAD_ROT
@onready var console: Control = $CONSOLE
@onready var player_stats: Label = $HUD_VARS/PLAYER_STATS
@onready var heal_bloom: ColorRect = $HUD_VARS/HEAL_BLOOM
@onready var alert_panel: Control = $NOTIFICATION_PANEL
@onready var fish_aquire_label: Label = $HUD_VARS/FISH_AQUIRE_LABEL
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_splash_sprite: Sprite2D = $DEATH_SCREEN/DEATH_SPLASH
@onready var user_info_panel: Control = $STOCK_MARKET/USER_INFO_PANEL
@onready var clock_label: Label = $CLOCK/CLOCK_LABEL
@onready var sun_clock: Sprite2D = $CLOCK/SUN_CLOCK
@onready var clock: Control = $CLOCK

@onready var controls_label: Label = $HUD_VARS/CONTROLS_LABEL

@onready var spawn_snd: AudioStreamPlayer = $SPAWN_SND

@onready var stock_market: Control = $STOCK_MARKET
@onready var dbox: Control = $DIALOGUE_SYSTEM
@onready var emotes: Control = $EMOTES
@onready var inspector: Control = $INSPECTOR
@onready var main_text: Label = $INSPECTOR/MAIN_TEXT
@onready var sub_text: Label = $INSPECTOR/SUB_TEXT
@onready var message_box_cont: VBoxContainer = $MESSAGE_BOX_CONT
@onready var sniper_hud: Control = $SNIPER_HUD

var player_sensi_backup : float = Global.player_sensi

signal opened_stocks
signal opened_anim

func _inspect(main_txt : String = "",sub_txt : String = ""):
	inspector.show()
	main_text.text = main_txt
	sub_text.text = sub_txt

func _add_control(texxxto : String):
	controls_label.text += "\n"+texxxto

func _clear_disappear():
	# Create tween (make sure you're not creating multiple tweens)
	sprite_2d.visible = true
	sprite_2d.material.set_shader_parameter("movement", 0.0)
	sprite_2d.material.set_shader_parameter("brightness", 0.0)
	sprite_2d.material.set_shader_parameter("alpha_multiplier", 1.0)
	var alpha_tween = create_tween()
	alpha_tween.set_parallel(true)
	alpha_tween.set_ease(Tween.EASE_IN_OUT)
	alpha_tween.set_trans(Tween.TRANS_QUART)
	
	# Tween the shader parameter
	alpha_tween.tween_property(sprite_2d.material, "shader_parameter/movement", 1.0, 0.8)
	alpha_tween.tween_property(sprite_2d.material, "shader_parameter/brightness", 1.0, 0.3)
	alpha_tween.tween_property(sprite_2d.material, "shader_parameter/alpha_multiplier", 0.0, 0.8)
	spawn_snd.play()
	# Animate from current alpha (1.0) to 0 over 1 second
	#alpha_tween.tween_property(simple_rect, "color:v", 0.28, 0.2)
	#alpha_tween.tween_property(simple_rect, "color:a", 0.0, 0.9)
	#alpha_tween.tween_property(simple_rect, "scale:y", 0.0, 0.7)

func _ready() -> void:
	_clear_disappear()
	await get_tree().process_frame
	Global.hud_node = self
	_match_core()
	gun_raycast.connect("dropped_gun",_sniper_scope_error_switch)
	gun_raycast.connect("switch_gun",_sniper_scope_error_switch)

func _match_core():
	match Global.player_core:
		"DEATH":
			core.play("DEATH")
			life.self_modulate = Color.ORCHID
			death_splash_sprite.texture = preload("res://Textures/HUD/DEATH_SPLASH_DEATH.png")
		"LIFE":
			core.play("LIFE")
			life.self_modulate = Color.RED
			death_splash_sprite.texture = preload("res://Textures/HUD/DEATH_SPLASH.png")

func death_splash():
	hud_vars.visible = false
	pause_screen.visible = false
	death_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _pause_game():
	if Input.is_action_just_pressed("escape") and Global.cur_st(Global.player.player_sm) != "death":
		if stock_market.visible == true:
			stock_market.hide()
		if console.visible == true:
			_manual_console_disable()
		get_tree().paused = not get_tree().paused
		#sub_viewport.fix_screen_positioning()
		if get_tree().paused:
			# Game is now paused - show mouse
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_screen.visible = true
			pause_screen._show_buttons()
			pause_screen.options_menu.hide()
			pause_screen.go_back_btn.hide()
		else:
			if Global.player.player_sm.cur_state() == "interact" or Global.player.player_sm.cur_state() == "death" or Global.player.player_sm.cur_state() == "emoting":
				pass
			else:
				Global.on_menu = false
			# Game is now unpaused - hide and capture mouse
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pause_screen.visible = false

func _process(_delta: float) -> void:
	update_head_values()
	_update_player_stats_on_screen()
	_pause_game()
	if not get_tree().paused:
		if Global.player_sm.cur_state() == "dead":
			return
		if Global.player_sm.cur_state() == "interact":
			return
		_emote_btn_update()
		_enable_console()
		_stocks_btn_update()
	if mag != null and storage != null:
		_update_gun_values_on_screen()
	if Global.cur_st(Global.player.player_sm) == "dead":
		$HUD_VARS.visible = false

func _stocks_btn_update():
	if Global.player_sm.cur_state() == "interact":
		return
	if Global.player_sm.cur_state() == "emoting":
		return
	if player.player_sm.cur_state() == "dead":
		return
	if Input.is_action_just_pressed("tab"):
		if emotes.visible:
			emotes.hide()
			Global.on_menu = not Global.on_menu
		if not Global.player_sm.cur_state() == "interact" or not Global.player_sm.cur_state() == "emoting":
			emit_signal("opened_stocks")
			Global.on_menu = not Global.on_menu
			stock_market.visible = Global.on_menu
			if not Global.on_menu:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _emote_btn_update():
	if Global.player_sm.cur_state() == "emoting":
		return
	if player.player_sm.cur_state() == "dead":
		return
	if Input.is_action_just_pressed("k"):
		if stock_market.visible:
			stock_market.hide()
			Global.on_menu = not Global.on_menu
		if not Global.player_sm.cur_state() == "interact" or not Global.player_sm.cur_state() == "emoting":
			emit_signal("opened_anim")
			Global.on_menu = not Global.on_menu
			emotes.visible = Global.on_menu
			if not Global.on_menu:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func sniper_cover(make : bool = false):
	match make:
		true:
			if not sniper_hud.visible:
				sniper_hud.modulate = Color.from_hsv(0,0,1,0)
				sniper_hud.show()
				await get_tree().process_frame
				var t = create_tween()
				t.tween_property(sniper_hud,"modulate",Color.from_hsv(0,0,1,1),0.2)
				player_sensi_backup = Global.player_sensi
				Global.player_sensi = player_sensi_backup / 4.45
		false:
			if sniper_hud.visible:
				sniper_hud.modulate = Color.from_hsv(0,0,1,1)
				var t = create_tween()
				t.tween_property(sniper_hud,"modulate",Color.from_hsv(0,0,1,0),0.2)
				await t.finished
				sniper_hud.hide()
				Global.player_sensi = player_sensi_backup

func update_head_values():
	head_rot.text = str("HEAD ROTATION: ",head.rotation,"\n","CAMERA ROTATION: ", camera.rotation)

func suicide_alert_anim():
	suicide_alert.visible = true
	await get_tree().create_timer(1.0).timeout
	suicide_alert.visible = false

func _update_gun_values_on_screen():
	mag.text = str(Global.player_gun_ammo[gun_raycast.current_gun_pos]["cur_magazine"])
	storage.text = str(Global.player_gun_ammo[gun_raycast.current_gun_pos]["storage"])
	life.text = str(Global.player.health)

func _sniper_scope_error_switch():
	sniper_cover(false)

func _update_player_stats_on_screen():
	clock_label.text = Global.cur_time
	sun_clock.rotation_degrees = Global.sun_rotation
	player_stats.text = str(
		"WALK SPEED : ", Global.player.walk_speed,"\n",
		"RUN SPEED : ", Global.player.run_speed,"\n",
		"JUMP HEIGHT : ", Global.player.jump_vel,"\n",
		"VELOCITY :", Global.player.velocity
	)

func _fish_aquire_anim(fish_name : String):
	fish_aquire_label.visible = true
	fish_aquire_label.text = str(fish_name, " AQUISITION COMPLETE.").to_upper()
	await get_tree().create_timer(1.25).timeout
	fish_aquire_label.visible = false

func _enable_console():
	if Input.is_action_just_pressed("console"):
		get_tree().paused = not get_tree().paused
		console.visible = not console.visible
		await get_tree().process_frame
		_console_anim_(console.visible)

func _console_anim_(appear : bool):
	match appear:
		true:
			console.global_position.y = 0
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		false:
			console.global_position.y = -305
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#var console_tween = create_tween()
	#console_tween.set_parallel(true)
	#console_tween.set_ease(Tween.EASE_IN_OUT)
	#match appear:
		#true:
			#console_tween.tween_property(console,"global_position:y",-305,0.2)
		#false:
			#console_tween.tween_property(console,"global_position:y",0,0.2)
	#await console_tween.finished

func _manual_console_disable():
	get_tree().paused = not get_tree().paused
	console.visible = not console.visible
