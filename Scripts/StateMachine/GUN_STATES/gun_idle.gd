extends State
@onready var gun: Node3D = $"../../Head/Camera3D/GUN_RAYCAST"
@onready var foot_raycast: RayCast3D = $"../../Head/Camera3D/FOOT_RAYCAST"
@onready var shoot_timer: Timer = $"../../shoot_timer"
@onready var visuais: Node3D = $"../../Head/Camera3D/visuais"
@onready var hud: Control = $"../../Control"
@onready var gun_shoot: Node = $"../GUN_SHOOT"
@onready var gun_fishing: Node = $"../GUN_FISHING"
@onready var head: Node3D = $"../../Head"

const max_fish_force : int = 96


var fish_force : float = 0

var grab_dis = 4.5

func enter() -> void:
	await get_tree().create_timer(0.2).timeout
	gun.can_fish = true

func update(_delta: float) -> void:
	if not Global.on_menu:
		if gun.weap_type == "fishing-rod":
			if Input.is_action_pressed("mb_left") and gun.can_fish:
				if fish_force < max_fish_force:
					fish_force += 2
				visuais.fishrod_tilt()
				visuais._fish_face_rotate(false)
		match gun.weap_type:
			"manual","manual-shotgun","manual-proj","manual-infinite","sniper-manual":
				manual_logic()
			"auto","auto-shotgun","auto-proj","bolt_acr","auto-infinite","sniper-auto":
				auto_logic()
			"fishing-rod":
				fishing_logic()
			_:
				manual_logic()
		if Input.is_action_pressed("r"):
			if gun.weap_type == "fishing-rod":
				return
			state_machine.change_state("gun_reload")
		_looking_at_gun()

func fishing_logic():
	if Input.is_action_just_released("mb_left") and gun.can_fish:
		if Global.player_gun_ammo[gun.current_gun_pos]["cur_magazine"] > 0:
			gun_fishing.fishin_throw_force = fish_force
			fish_force = 0
			gun.can_fish = false
			visuais.reset_fishrod_tilt()
			state_machine.change_state("gun_fishing")

func manual_logic():
	if Input.is_action_just_pressed("mb_left"):
		if Global.player_gun_ammo[gun.current_gun_pos]["cur_magazine"] > 0:
			state_machine.change_state("gun_shoot")

func auto_logic():
	if Input.is_action_pressed("mb_left") and shoot_timer.is_stopped():
		if Global.player_gun_ammo[gun.current_gun_pos]["cur_magazine"] > 0:
			state_machine.change_state("gun_shoot")


func _looking_at_gun():
	if !foot_raycast.is_colliding():
		_clear_pickup()
		return
	
	var collider = foot_raycast.get_collider()

	
	if collider == null:
		_clear_pickup()
		return
	# Check for FOE - never show icon
	if collider.is_in_group("foe"):
		_clear_pickup()
		return
	
	# Check for NPC - only show if alive
	if collider.is_in_group("npc"):
		if collider.dead == true:
			_clear_pickup()
			return
		elif collider.has_method("interact"):
			_show_pickup(collider,collider.get_groups()[0])
			#_show_pickup(collider)
			return
	
	# Check for MONEY, FOOD, WEAPON - always show if they have interact
	if collider.is_in_group("money") or collider.is_in_group("food") or collider.is_in_group("weapon") or  collider.is_in_group("organ"):
		if collider.has_method("interact"):
			_show_pickup(collider,collider.get_groups()[0])
			return
			
	if collider.is_in_group("phone"):
		if collider.has_method("interact"):
			_show_pickup(collider,collider.get_groups()[0])
			return

	if collider.is_in_group("altar"):
		if collider.has_method("interact"):
			_show_pickup(collider,collider.get_groups()[0])
			return
			
	if collider.is_in_group("general"):
		if collider.has_method("interact"):
			_show_pickup(collider,collider.get_groups()[0])
			return
	# Check for generic interactable objects
	#if collider.has_method("interact"):
		#_show_pickup(collider)
		#return
	
	# Default - no pickup
	_clear_pickup()

func _show_pickup(collider: Node, group : String = ""):
	visuais._pickable_icon_logic(true)
	if not Global.player_sm.cur_state() == "interact" or not Global.player_sm.cur_state() == "dead":
		match group:
			"money":
				if collider.bio_currency:
					hud._inspect("Bio Currency","Aquire funancial power.")
				else:
					hud._inspect("Aquire Currency","Aquire funancial power.")
			"food":
				hud._inspect("Food","Restore your health.")
			"weapon":
				var gun_name = Global.guns_specs[collider.gun_name]["gun_name"]
				hud._inspect(gun_name,"Grab weapon.")
			"organ":
				var organ_name = collider.organ_name
				hud._inspect(organ_name,"Aquire bilogical part.")
			"altar":
				var altar_name = collider.altar_name
				altar_name = altar_name.to_pascal_case()
				hud._inspect("The Altar of "+altar_name,"Offer a Sacrifice.")
			"npc":
				hud._inspect("Talk","Start a transaction of words with this automaton.")
			"phone":
				hud._inspect("Phone","Make a phone call and start a contract kill.")
			"general":
				var msg0 = "???"
				var msg1 = "???"
				if "inspect_name" in collider:
					msg0 = collider.inspect_name
				if "inspect_desc" in collider:
					msg1 = collider.inspect_desc
				hud._inspect(msg0,msg1)
			"",_:
				hud._inspect("???","???")
	else:
		_clear_pickup()
	if Input.is_action_just_pressed("e"):
		#if head.global_position.distance_to(collider.global_position) <= grab_dis:
		collider.interact()
		_clear_pickup()


func _clear_pickup():
	if visuais.has_method("_pickable_icon_logic"):
		visuais._pickable_icon_logic(false)
		hud.inspector.hide()
