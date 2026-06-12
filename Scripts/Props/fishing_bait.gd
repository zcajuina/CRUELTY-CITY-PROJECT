extends CharacterBody3D
@onready var catch_timer: Timer = $catch_timer
@onready var processing : bool = false
@onready var raycast: RayCast3D = $RayCast3D
@onready var fish_catch_snd: AudioStreamPlayer3D = $fish_catch_snd


var rng = RandomNumberGenerator.new()
var peixe : int = 0
var is_in_water: bool = false
var has_triggered: bool = false
var current_water_name : String = ""


func drop_peixe(water_type: String = "water_normal") -> Dictionary:
	# Collect all fish that spawn in this water
	var eligible_fish: Array = []
	var total_chance: int = 0
	
	print("=== DROP PEIXE DEBUG ===")
	print("Looking for water type: ", water_type)
	print("Total fish in database: ", FishSave.fish_data.size())
	
	for fish_name in FishSave.fish_data:
		var fish = FishSave.fish_data[fish_name]
		
		# CORRECT: Get water from the fish variable, not from the main dictionary
		var fish_water = fish.get("water", "NOT SET")
		
		print("Fish: ", fish_name, " | Water: ", fish_water, " | Chance: ", fish.get("raridade", 0))
		
		# Check if water matches
		if fish_water == water_type:
			print("  -> MATCH FOUND for ", fish_name)
			var chance = fish.get("raridade", 0)
			if chance > 0:
				eligible_fish.append({
					"name": fish_name,
					"chance": chance,
					"tempo": fish.get("catch_time", 3.0)
				})
				total_chance += chance
			else:
				print("  -> Chance is 0 or not set for ", fish_name)
		else:
			print("  -> NO MATCH (water: ", fish_water, ")")
	
	print("Eligible fish found: ", eligible_fish.size())
	print("Total chance sum: ", total_chance)
	
	if eligible_fish.is_empty():
		print("No fish found for water type: ", water_type)
		return _get_default_fish()
	
	# Roll for which fish to catch
	var roll = rng.randi_range(1, total_chance)
	print("Roll: ", roll, " out of ", total_chance)
	
	var cumulative = 0
	var selected_fish = null
	
	for fish in eligible_fish:
		cumulative += fish["chance"]
		print("Fish: ", fish["name"], " | Chance: ", fish["chance"], " | Cumulative: ", cumulative)
		if roll <= cumulative:
			selected_fish = fish
			print("SELECTED: ", fish["name"])
			break
	
	if selected_fish == null:
		print("No fish selected, using first eligible fish")
		selected_fish = eligible_fish[0]
	if Global.player_head_implant == "Tattered Rain Hat":
		print("HAS RAIN HAT")
		return {
			"nome": selected_fish["name"],
			"tempo": selected_fish["tempo"]+ 1.5,
			"water": water_type
		}
	else:
		print("DOES NOT HAVE RAIN HAT")
		return {
			"nome": selected_fish["name"],
			"tempo": selected_fish["tempo"],
			"water": water_type
		}

func _get_default_fish() -> Dictionary:
	# Fallback in case no fish found
	return {
		"nome": "Le Fishe",
		"raridade": 30,
		"tempo": 3.0,
		"water": "water_normal"
	}

func fish_logic(water_name : String = "water_normal"):
	if has_triggered:  # Evita múltiplas chamadas
		return
	has_triggered = true
	
	print("logic_started")
	processing = true
	
	# Para o movimento do bait
	velocity = Vector3.ZERO
	
	await get_tree().create_timer(randf_range(0.2, 5)).timeout
	
	FishSave.cpf_do_peixe = drop_peixe(water_name)
	
	FishSave.fish_node = preload("res://Scenes/Props/fish.tscn").instantiate()
	var fish_model
	if FishSave.special_fish_model.has(FishSave.cpf_do_peixe["nome"]):
		fish_model = load("res://Scenes/FISH/" + FishSave.cpf_do_peixe["nome"] + ".tscn").instantiate()
	else:
		fish_model = load("res://Models/Props/FISH_MODELS/" + FishSave.cpf_do_peixe["nome"] + ".glb").instantiate()
	FishSave.fish_node.add_child(fish_model)
	self.get_parent().add_child(FishSave.fish_node)
	
	# Posiciona o peixe na superfície da água (no mesmo Y do bait)
	FishSave.fish_node.global_position = global_position
	
	catch_timer.wait_time = FishSave.cpf_do_peixe.tempo
	catch_timer.start()

func _ready():
	
	# Configura o raycast - APONTA PARA BAIXO
	raycast.enabled = true
	raycast.collision_mask = 2  # Ajuste para a camada da água
	raycast.target_position = Vector3(0, -0.5, 0)  # Aponta 0.5 unidades para baixo
	raycast.hit_from_inside = true  # Importante: detecta colisão mesmo se o raycast começar dentro do objeto
	
	if FishSave.fish_bait_node == null:
		FishSave.fish_bait_node = self
	else:
		FishSave.fish_bait_node.queue_free()
		FishSave.fish_bait_node = self

func _physics_process(_delta: float) -> void:
	# Aplica gravidade até tocar a água
	if processing == false:
		if not raycast.is_colliding():  # Só cai se não estiver na água
			velocity.y -= 9.8 * _delta
		else:
			# Está sobre a água - para
			velocity.y = 0
			# Verifica se é água e ainda não iniciou a pesca
			var col = raycast.get_collider()
			print(col.get_groups())
			if col and col.is_in_group("water") and not has_triggered:
				print("Bait chegou na água!")
				is_in_water = true
				_get_water_type(col)
				current_water_name = _get_water_type(col)
				fish_logic(current_water_name)
		
		move_and_slide()
	
	# Lógica de pesca
	if FishSave.fish_node != null:
		if not catch_timer.is_stopped() and catch_timer.time_left > 0:
			if Input.is_action_just_pressed("mb_left"):
				FishSave.fish_node.can_move = true
				catch_timer.stop()
				_catch_fish_success()

func _get_water_type(col)->String:
	if col.is_in_group("water_normal"):
		return "water_normal"
	if col.is_in_group("water_swamp"):
		return "water_swamp"
	if col.is_in_group("water_digital"):
		return "water_digital"
	if col.is_in_group("water_lava"):
		return "water_lava"
	if col.is_in_group("water_pure"):
		return "water_pure"
	else:
		return "water_pure"

func _on_catch_timer_timeout() -> void:
	if FishSave.fish_node:
		FishSave.fish_node.queue_free()
		FishSave.fish_node = null
	
	processing = false
	has_triggered = false
	fish_logic(current_water_name)

func _catch_fish_success():
	#fish_bait.play()
	print("Peixe capturado!")
	queue_free()
