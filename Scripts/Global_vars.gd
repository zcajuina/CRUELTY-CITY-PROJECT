extends Node
#region SINAIS
signal killed_something
signal day_reload
signal door_close
#endregion

#region Path Variables
#var save_path = "user://crus_save.zcj"
var default_docs_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/CRUELTY CITY/"
var saves_folder_path = default_docs_path + "SAVE_FILES/"
var save_path = saves_folder_path + "crus_save.zcj"

var custom_char_path = default_docs_path + "CUSTOM/"
var player_img_path = custom_char_path + "player_image.png"


var settings_path: String = saves_folder_path + "settings.cfg"

const MODEL_PATH = "res://Models/DEFAULT_PLAYER_MODELS/FPS_ARM_SETUP.glb"  # Caminho do modelo com animações
const OUTPUT_PATH = "res://Animations/FPS_DEFAULT_ANIMS.res"  # Onde salvar as animações
const INFO_PANEL : String = "res://Scenes/HUD/INFO_AQUISITION_PANEL.tscn"

#endregion

#region Player Settings Var and Funcs
const BUS_MASTER = 0
const BUS_BGM = 1
const BUS_SFX = 2
var screen_number : int = 1


const DEFAULT_SETTINGS = {
	"master": 1.0,
	"bgm": 1.0,
	"sfx": 1.0,
	"sensi": 0.004,
	"reload": false,
	"fullscreen": 0  # 0 = fullscreen, 1 = windowed (ou vice-versa)
}

func save_settings(master: float, bgm: float, sfx: float, sensi: float, reload: bool, fullscreen: int):
	# Garante que a pasta existe
	_ensure_settings_folder()
	
	var config = ConfigFile.new()
	
	config.set_value("audio", "master", master)
	config.set_value("audio", "bgm", bgm)
	config.set_value("audio", "sfx", sfx)
	config.set_value("gameplay", "sensi", sensi)
	config.set_value("gameplay", "reload", reload)
	config.set_value("video", "fullscreen", fullscreen)
	
	var result = config.save(settings_path)
	if result == OK:
		print("Configurações salvas em: ", settings_path)
	else:
		print("Erro ao salvar configurações: ", result)

func load_settings() -> Dictionary:
	var config = ConfigFile.new()
	var settings = {}
	
	# Garante que a pasta existe
	_ensure_settings_folder()
	
	if config.load(settings_path) == OK:
		settings["master"] = config.get_value("audio", "master", DEFAULT_SETTINGS["master"])
		settings["bgm"] = config.get_value("audio", "bgm", DEFAULT_SETTINGS["bgm"])
		settings["sfx"] = config.get_value("audio", "sfx", DEFAULT_SETTINGS["sfx"])
		settings["sensi"] = config.get_value("gameplay", "sensi", DEFAULT_SETTINGS["sensi"])
		settings["reload"] = config.get_value("gameplay", "reload", DEFAULT_SETTINGS["reload"])
		settings["fullscreen"] = config.get_value("video", "fullscreen", DEFAULT_SETTINGS["fullscreen"])
		
		print("Configurações carregadas de: ", settings_path)
	else:
		print("Arquivo de configurações não encontrado. Usando valores padrão.")
		settings = DEFAULT_SETTINGS.duplicate()
		# Salva os padrões automaticamente
		save_settings(
			settings["master"], 
			settings["bgm"], 
			settings["sfx"], 
			settings["sensi"], 
			settings["reload"],
			settings["fullscreen"]
		)
	
	# Aplica as configurações de áudio
	set_volume(BUS_MASTER, settings["master"])
	set_volume(BUS_BGM, settings["bgm"])
	set_volume(BUS_SFX, settings["sfx"])
	
	# Aplica a configuração de tela
	_apply_screen_mode(settings["fullscreen"])
	
	# Atualiza as variáveis globais
	player_sensi = settings["sensi"]
	crus_reload = settings["reload"]
	
	return settings

func _ensure_settings_folder():
	if not DirAccess.dir_exists_absolute(default_docs_path):
		print("Pasta não encontrada. Criando: ", default_docs_path)
		var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
		if dir:
			dir.make_dir("CRUELTY CITY")
			print("Pasta criada com sucesso!")

func _apply_screen_mode(mode: int):
	match mode:
		0:  # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			print("Modo de tela: FULLSCREEN")
		1:  # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			print("Modo de tela: WINDOWED")
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_volume(bus: int, linear: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(linear))
	AudioServer.set_bus_mute(bus, linear <= 0.01)

func get_volume(bus: int) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(bus))
#endregion

#region Player Skins
var player_skins : Dictionary = {
	"BIO_SUIT":
	{"fps_path" : "res://Models/PLAYER_SKINS/AMEONNA_BIO_SUIT/FPS_AMEONNA_BIO_SUIT.glb",
	"body_path" : "res://Models/PLAYER_SKINS/AMEONNA_BIO_SUIT/TPS_AMEONNA_BIO_SUIT.glb"},
	"CUSTOM":
	{"fps_path" : "CUSTOM/CUSTOM_PLAYER_HANDS",
	"body_path" : "CUSTOM/CUSTOM_PLAYER_BODY"}
	}
var skins_owned : Array[String] = ["BIO_SUIT","CUSTOM"]
#endregion

#region Player Static Variables
var crus_reload : bool = false

var player_skin_name : String = "BIO_SUIT"
var player_name : String = "AMEONNA"
var player_tittle : String = "Low Networth Individual"
var player_sensi : float = 0.004
var player_altar : String = "NONE"
var player_head_implant : String = "NONE"
var player_arm_implant : String = "NONE"
var player_chest_implant : String = "NONE"
var player_leg_implant : String = "NONE"
var player_aditional_armor : float = 0
var player_aditional_speed : float = 0
var player_aditional_jump : float = 0
var player_aditional_health : int = 0
var player_bar_code_number : String = generate_random_numeric_string(24)
var player_unique_props : Array[String] = []
var player_unique_npcs : Array[String] = []
var player_badges : Array[String] = [
"THE GOOD ON EVIL",
"THE EVIL ON GOOD",
"AN OFFERING WAS MADE",
"CHEATING THE NATURAL COURSE",
"I KNOW WHAT YOU ARE",
"PAY THE RENT!",
"THEY COME BACK. THEY ALWAYS COME BACK",
"DIVINE LIGHT RECOVERED",
"CELESTIAL ENTITY",
"HE SMILES AT ME.",
"I AM PERFECT AND PURE",
"MAN'S BEST FRIEND",
"BETTER THAN DARWIN",
"THIS MAKES ME SICK",
"SIDDHARTHA WOULD BE PROUD"
]
#endregion

#region Player Active Variables
var player_cash_money : float = 99999999999
var player_networth_money : float = 0
var player_lives_taken : int = 99999999
var player_deaths : int = 0
var on_menu : bool = false
var chosen_spawn : String = "FLAT PLANE"
#var controller : Node3D = null
var scene_to_change : String = "res://Scenes/DEBUG/le_flat_plane.tscn"
var player_pos : Vector3 = Vector3.ZERO
var cur_time : String = "00:00 ??"
var daytime : String = "DIA"
var sun_rotation : float = 0
#endregion

#region Player Core Variables
var player_core : String = "LIFE"
#endregion

#region Player Inventory Variables
var player_inv : Array = ["PARASONIC_D2","MINATO"]
var player_inv_backup : Array
var player_gun_ammo : Dictionary = {
	"gun1" : 
		{"cur_magazine" : 0,
		"storage" : 0},
	"gun2":
		{"cur_magazine" : 0,
		"storage" : 0},
}
#endregion

#region Gameplay Visual Effects
var bullet_marks : Array = []
var blood_splats : Array = []
#endregion

#region Guns Data
var guns_specs : Dictionary = {
	"HANDS":
		{"rate" : 0.1,
		"type" : "hand",
		"damage" : 0,
		"range" : 10,
		"max_magazine" : 0,
		"max_storage" : 0,
		"weight" : 0,
		"shake" : 0,
		"special factor" : "null",
		"gun_name": "",
		"desc" : "How many fingers are in the human hand?",},
	"MINATO" : 
		{"rate" : 0.045,
		"type" : "auto",
		"damage" : 16,
		"max_magazine" : 30,
		"max_storage" : 90,
		"weight" : 0,
		"shake" : 1.2,
		"special factor" : "null",
		"gun_name": "MINATO M-9",
		"desc" : "Imported in great quantities by people of taste after being featured in the anime Haato no DokiDoki: Zankokudan.",
		"price": 3000},
	"PARASONIC_D2" :
		{"rate" : 0.14,
		"type" : "manual",
		"damage" : 20,
		"lazer_sight" : true,
		"max_magazine" : 12,
		"max_storage" : 60,
		"weight" : 0,
		"shake" : 1.2,
		"special factor" : "null",
		"gun_name": "PARASONIC D2",
		"desc" : "Uses special 10mm subsonic ammunition for extremely silent operation. Popular among high-end private security and wetworks services, as well as tactical wannabes.",
		"price": 250},
	"FISHING_ROD":
		{"rate" : 0.495,
		"type" : "fishing-rod",
		"damage" : 0,
		"max_magazine" : 1,
		"max_storage" : 1,
		"weight" : 0,
		"shake" : 0,
		"special factor" : "null",
		"gun_name": "FIBER GLASS FISHING ROD",
		"desc" : "Enter the World of Fish and become who you were meant to be.",
		"price": 150},
	"REVOLVER":
		{"rate" : 0.895,
		"type" : "manual",
		"damage" : 120,
		"max_magazine" : 5,
		"max_storage" : 45,
		"weight" : 0,
		"shake" : 45,
		"special factor" : "null",
		"gun_name": "BIG IRON",
		"desc" : "Standard police issue handgun for more than a hundred years. While more efficient options exist the cops have decided to stick with this due to masculine associations created by the film industry.",
		"price": 1500},
	"GOLD_IRON":
		{"rate" : 0.895,
		"type" : "manual",
		"damage" : 120,
		"max_magazine" : 5,
		"max_storage" : 45,
		"weight" : 0,
		"shake" : 45,
		"special factor" : "REVOLVER",
		"gun_name": "GOLD DIGGER",
		"desc" : "Go and show off how rich you are.",
		"price": 1500000},
	"NEURON_DISABLER" : 
		{"rate" : 0.10,
		"type" : "auto-proj",
		"damage" : 16,
		"max_magazine" : 300,
		"max_storage" : 900,
		"weight" : 1.2,
		"shake" : 0.02,
		"special factor" : "null",
		"gun_name": "SECURITY SYSTEMS NEURON DISABLER",
		"desc" : "It's a party in a gun! Make the world dance and fear the power of your sickening beats!",},
	"UBERBLADE" : 
		{"rate" : 0.62,
		"type" : "melee",
		"damage" : 999999999,
		"max_magazine" : 1,
		"max_storage" : 1,
		"weight" : 0,
		"shake" : 0.0,
		"special factor" : "null",
		"gun_name": "UBERBLADE",
		"desc" : "Ancient weapon from another plane of existece. Tastes like space sandwich",
		"price": 999999999.99},
	"DNA_SCRAMBLER" :
		{"rate" : 0.14,
		"type" : "manual-dna",
		"damage" : 20,
		"lazer_sight" : true,
		"max_magazine" : 6,
		"max_storage" : 18,
		"weight" : 0,
		"shake" : 1.2,
		"special factor" : "PARASONIC_D2",
		"gun_name": "PARASONIC C3 DNA SCRAMBLER",
		"desc" : "High value targets often have immediate access to body reconstruction services and as such it has become a popular choice to mangle their genetic makeup beyond all repair with a hi-tech weapon like the Parasonic C3.",
		"price": 120000},
	"FLASHLIGHT":
		{"rate" : 1.0,
		"type" : "flashlight",
		"damage" : 0,
		"max_magazine" : 0,
		"max_storage" : 0,
		"weight" : 0,
		"shake" : 0,
		"special factor" : "null",
		"gun_name": "FLASHLIGHT",
		"desc" : "A simple flashlight, not very useful. Or is it?",},
	"NAILER": 
		{"rate" : 0.034,
		"type" : "auto",
		"damage" : 32,
		"lazer_sight" : true,
		"max_magazine" : 100,
		"max_storage" : 200,
		"weight" : 0.2,
		"shake" : 1.2,
		"special factor" : "null",
		"gun_name": "PARASONIC MP-1 NAILER",
		"desc" : "Parasonic's new personal defense weapon provides never before seen firepower in a compact form factor. Fires ultra high velocity depleted uranium nails from a high-capacity helical magazine.",
		"price": 50000},
	"MOLTEM_BOY":
		{"rate" : 0.14,
		"type" : "manual",
		"damage" : 20,
		"max_magazine" : 32,
		"max_storage" : 128,
		"weight" : 0,
		"shake" : 1.2,
		"special factor" : "null",
		"gun_name": "MOLTEN BOY",
		"desc" : "An ancient piece of technology, burn but still functional.",
		"price": 700},
	"BOLT_ACR":
		{"rate" : 0.7,
		"type" : "bolt_acr",
		"damage" : 120,
		"max_magazine" : 1,
		"max_storage" : 0,
		"weight" : 0,
		"shake" : 0,
		"special factor" : "null",
		"gun_name": "SECURITY SYSTEMS BOLT ACR",
		"desc" : "The goal of the Advanced Combat Rifle program was to create an energy weapon that wouldn't need to be reloaded at all. One of the results was this unfortunate portable gamma radiation emitter. Though often said to be illegal due to international agreements regarding radiation based weapons (no such agreements exist), the reason it never got much use is that most of the test subjects ended up accidentally killing themselves.",
		"price": 1},
	#"SNIPER" :
		#{"rate" : 0.14,
		#"type" : "sniper-manual",
		#"damage" : 20,
		#"lazer_sight" : false,
		#"max_magazine" : 12,
		#"max_storage" : 60,
		#"weight" : 0,
		#"shake" : 1.2,
		#"special factor" : "PARASONIC_D2",
		#"gun_name": "SNIPER",
		#"desc" : "Uses special 10mm subsonic ammunition for extremely silent operation. Popular among high-end private security and wetworks services, as well as tactical wannabes.",
		#"price": 250},
	#"MAGIC_WAND":
		#{"rate" : 0.48,
		#"type" : "manual-infinite",
		#"damage" : 120,
		#"max_magazine" : 1,
		#"max_storage" : 0,
		#"weight" : 0,
		#"shake" : 0,
		#"special factor" : "null",
		#"gun_name": "MAGIC WAND",
		#"desc" : "Orcus Porcus. There's pizza on your focus.",
		#"price": 1},
}
var guns_owned : Array = ["HANDS","PARASONIC_D2","FISHING_ROD"]

var advanced_guns : Array[String] = ["NEURON_DISABLER","UBERBLADE","FLASHLIGHT","MOLTEM_BOY","BOLT_ACR"]

var guns_to_aquire : Array[String] = [
	"MEDUSA","FISHING_ROD","UBERBLADE","NEURON_DISABLER",
]
var no_reload_guns : Array[String] = ["HANDS","UBERBLADE","FLASHLIGHT","BOLT_ACR","FISHING_ROD"]


#endregion

#region Player Stats Data
var player_stats : Dictionary = {
	"NONE" : {
		"health" : 100,
		"walk_speed" : 8.2,
		"run_speed": 32.0,
		"jump_vel": 5.8
	},
	"MEAGER": {
		"health" : 75,
		"walk_speed" : 14.2,
		"run_speed": 9.3,
		"jump_vel": 6.8
	},
	"MAGNITUDE" : {
		"health" : 200,
		"walk_speed" : 10.5,
		"run_speed": 4.8,
		"jump_vel": 4.3
	},
}

var player_caps : Dictionary = {
	"max_health" : 0,
	"max_walk" : 0.0,
	"max_run" : 0.0,
	"max_jump" : 0.0,
	"max_armor" : 0.0
}
#endregion

#region Implants Data
var head_implants : Dictionary = {
	"Flowerchute" : 
		{"DESC" : "A alien flower that is instaled in the head and makes the user glide.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/flower.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_FLOWER.tscn",
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"Goon Glasses 3000" : 
		{"DESC" : "Spawns a e-girl on your screen after each liquidation.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/bell_glass.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_BELLGLASS.tscn",
		"unlockable":true,
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"Vigilance Satelite":
		{"DESC" : "A fragment of space rock that orbits around your head and has a 1/3 chance to deflect bullets when hit",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/moon.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_MINIATURE_CRADLE.tscn",
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"Tattered Rain Hat":
		{"DESC" : "Old and worn. You've never seen it before but it feels nostalgic.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/fishinghat.png",
		"aditional_node" : "",
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"Byon Drive":
		{"DESC" : "YEY!",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/bion_drive.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_BYON_DRIVE.tscn",
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
}
var arm_implants : Dictionary = {
	"Ancient coin" : 
		{"DESC" : "A strange and ancient artifact. You feel peaceful.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/coin.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_COINY.tscn",
		"unlockable":true,
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
}
var chest_implants : Dictionary = {
	"CSIJ Level II Body Armor" : 
		{"DESC" : "Armor +10",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/light_armor.png",
		"aditional_node" : "",
		"armor" : 10,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"CSIJ Level IIB Body Armor" : 
		{"DESC" : "Armor +15",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/advanced_armor.png",
		"aditional_node" : "",
		"armor" : 15,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"CSIJ Level III Body Armor" : 
		{"DESC" : "Armor +20 Speed -1",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/medium_armor.png",
		"aditional_node" : "",
		"armor" : 10,
		"health" : 0,
		"speed" : -1,
		"jump" : 0},
	"CSIJ Level IV Body Armor" : 
		{"DESC" : "Armor +50\nSpeed -3\nJump -5",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/heavy_armor.png",
		"aditional_node" : "",
		"armor" : 50,
		"health" : 0,
		"speed" : -3,
		"jump" : -5},
	"CSIJ Level V Biosuit" : 
		{"DESC" : "Armor +40",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/ultra_armor.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_TERRORSUIT.tscn",
		"armor" : 40,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
	"Biojet" : 
		{"DESC" : "A powerful steady stream of warm liquid smoothly lifts you up and lets you fly like a bird.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/jetpack.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_BIOJET.tscn",
		"armor" : 0,
		"health" : 0,
		"speed" : 0,
		"jump" : 0},
}
var leg_implants : Dictionary = {
	"IKAROS_MACHINE" : 
		{"DESC" : "Now you have your legs. Now you have a fracture.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/icaros.png",
		"aditional_node" : "",
		"price" : 16,
		"armor" : 0,
		"health" : 0,
		"speed" : 5,
		"jump" : 8},
	"Gunk Boosters" : 
		{"DESC" : "Boost yourself upwards in mid-air by releasing a jet of assorted biological detritus. Makes a huge mess that is extremely unpleasant to clean up.",
		"sprite" : "res://Textures/HUD/IMPLANTS_SPRITES/gunkbooster.png",
		"aditional_node" : "res://Scenes/Props/IMPLANTS/IMP_GUNK.tscn",
		"unlockable":true,
		"price" : 2,
		"armor" : 0,
		"health" : 0,
		"speed" : 2,
		"jump" : 0}
	}

var implants_owned : Array = []
var total_implants_ammount : int = 0
#endregion

#region Active Implant Nodes
var active_implant_nodes = {}
#endregion

#region Map Data
var map_locs : Dictionary = {
	"FLAT PLANE": {
		"POSITION" : Vector3(0.0,0.0,0.0)
		},
}
#endregion

#region Gameplay Data
var gibbing_results : Dictionary = {
	0 : ["HEART"],
	1 : ["HEART","BRAIN","STOMACH"],
	2 : ["PANCREAS","SPINE","INTESTINES"],
	3 : ["APENDIX"],
	4 : ["BRAIN","HEART"],  # Added more variety
	5 : ["STOMACH","INTESTINES","APENDIX"],
	6 : ["HEART","BRAIN","PANCREAS","SPINE"],
	7 : ["PSYCHO BRAIN"]
}
var world_node : Node3D
#endregion

#region Game State Variables
var fishing_bait_out : bool = false
var hud_node : Control
var player : CharacterBody3D
var player_sm : StateMachine
#endregion

#region Save/Load Functions
func _save_game():
	# Verifica se a pasta CRUELTY CITY existe
	if not DirAccess.dir_exists_absolute(default_docs_path):
		print("Pasta CRUELTY CITY não encontrada. Criando: ", default_docs_path)
		var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
		if dir:
			dir.make_dir("CRUELTY CITY")
			print("Pasta CRUELTY CITY criada com sucesso!")
	
	# Verifica se a pasta SAVE_FILES existe dentro de CRUELTY CITY
	if not DirAccess.dir_exists_absolute(saves_folder_path):
		print("Pasta SAVE_FILES não encontrada. Criando: ", saves_folder_path)
		var dir = DirAccess.open(default_docs_path)
		if dir:
			dir.make_dir("SAVE_FILES")
			print("Pasta SAVE_FILES criada com sucesso!")
	
	# Tenta abrir o arquivo para escrita
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		print("GAME SAVED em: ", save_path)
		file.store_var(player_sensi)
		file.store_var(player_altar)
		file.store_var(player_core)
		file.store_var(player_cash_money)
		file.store_var(player_lives_taken)
		file.store_var(implants_owned)
		file.store_var(guns_owned)
		file.store_var(player_name)
		file.store_var(player_tittle)
		file.store_var(player_bar_code_number)
		file.store_var(player_skin_name)
		
		file.store_var(player_head_implant)
		file.store_var(player_arm_implant)
		file.store_var(player_chest_implant)
		file.store_var(player_leg_implant)
		file.store_var(skins_owned)
		file.store_var(player_badges)
		
		
		file.close()
		return true
	else:
		print("ERRO: Não foi possível criar/abrir o arquivo de save em: ", save_path)
		return false

func _load_game():
	await get_tree().process_frame
	
	# Verifica se o arquivo existe
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			player_sensi = file.get_var()
			player_altar = file.get_var()
			player_core = file.get_var()
			player_cash_money = file.get_var()
			player_lives_taken = file.get_var()
			implants_owned = file.get_var()
			guns_owned = file.get_var()
			player_name = file.get_var()
			player_tittle = file.get_var()
			player_bar_code_number = file.get_var()
			player_skin_name = file.get_var()
			
			player_head_implant = file.get_var()
			player_arm_implant = file.get_var()
			player_chest_implant = file.get_var()
			player_leg_implant = file.get_var()
			skins_owned = file.get_var()
			player_badges = file.get_var()
			
			file.close()
			print("GAME LOADED de: ", save_path)
		else:
			print("ERRO: Não foi possível abrir o arquivo de save")
	else:
		print("Arquivo de save não encontrado. Usando valores padrão.")
		player_sensi = 0.004
		player_altar = player_altar
		player_core = player_core
		player_cash_money = player_cash_money
		player_lives_taken = 0
		implants_owned = []
		guns_owned = guns_owned
		player_name = player_name
		player_tittle = player_tittle
		player_bar_code_number = generate_random_numeric_string(24)
		player_skin_name = player_skin_name
		
		player_head_implant = player_head_implant
		player_arm_implant = player_arm_implant
		player_chest_implant = player_chest_implant
		player_leg_implant = player_leg_implant
		skins_owned = skins_owned
		player_badges = player_badges

#func _save_owned_guns():
	#var file = FileAccess.open(save_guns_path,FileAccess.WRITE)
	#var json_string = JSON.stringify(guns_owned, "\t")
	#file.store_string(json_string)
	#file.close()
	#
#func _load_owned_guns():
	#if FileAccess.file_exists(save_guns_path):
		#var file = FileAccess.open(save_guns_path, FileAccess.READ)
		#var json_string = file.get_as_text()
		#file.close()
		#var result = JSON.parse_string(json_string)
		#guns_owned = result
	#else:
		#guns_owned = guns_owned
#endregion

#region Player Stat Functions
func _player_caps():
	await get_tree().process_frame
	if not SceneChanger.keep_health:
		player_caps["max_health"] = player.health
		player_caps["max_walk"] = player.walk_speed
		player_caps["max_run"] = player.run_speed
		player_caps["max_jump"] = player.jump_vel
		player_caps["max_armor"] = player.armor

func _setup_player_stats(TABLE : String):
	player.health = player_stats[TABLE]["health"]
	player.walk_speed = player_stats[TABLE]["walk_speed"]
	player.run_speed = player_stats[TABLE]["run_speed"]
	player.jump_vel = player_stats[TABLE]["jump_vel"]

func _calculate_player_stats():
	player_aditional_health = 0
	player_aditional_speed = 0
	player_aditional_jump = 0
	
	# GET ALTAR STATS
	if player_stats.has(player_altar):
		player_aditional_health += player_stats[player_altar].get("health", 0)
		player_aditional_speed += player_stats[player_altar].get("walk_speed", 0)
		player_aditional_jump += player_stats[player_altar].get("jump_vel", 0)
	
	# PROCESS LEG IMPLANT
	if player_leg_implant != "NONE" and leg_implants.has(player_leg_implant):
		_process_implant(player_leg_implant, leg_implants[player_leg_implant])
	
	# PROCESS OTHER IMPLANT TYPES
	if player_arm_implant != "NONE" and arm_implants.has(player_arm_implant):
		_process_implant(player_arm_implant, arm_implants[player_arm_implant])
	
	if player_head_implant != "NONE" and head_implants.has(player_head_implant):
		_process_implant(player_head_implant, head_implants[player_head_implant])
	
	if player_chest_implant != "NONE" and chest_implants.has(player_chest_implant):
		_process_implant(player_chest_implant, chest_implants[player_chest_implant])
	
	# Apply final stats
	player.armor = player_aditional_armor
	if not SceneChanger.keep_health:
		player.health = player_aditional_health
	else:
		player.health = SceneChanger.player_cur_health
	player.walk_speed = player_aditional_speed
	player.jump_vel = player_aditional_jump

func _process_implant(implant_name: String, implant_data: Dictionary):
	player_aditional_armor += implant_data.get("armor", 0)
	player_aditional_speed += implant_data.get("speed", 0)
	player_aditional_jump += implant_data.get("jump", 0)
	player_aditional_health += implant_data.get("health", 0)
	
	var node_path = implant_data.get("aditional_node", "")
	if not node_path.is_empty():
		_attach_implant_node(node_path, implant_name)

func _attach_implant_node(node_path: String, implant_name: String):
	var node_scene = ResourceLoader.load(node_path)
	if node_scene:
		var implant_node = node_scene.instantiate()
		player.add_child(implant_node)
		print("IMPLANT ADDED")
		active_implant_nodes[implant_name] = implant_node
	else:
		push_error("Failed to load implant node: " + node_path)
#endregion

#region Utility Functions
func _ready() -> void:
	await get_tree().process_frame
	_load_everything()
	
	
	
	await get_tree().process_frame
	ensure_file_exists("res://Textures/SPRITES/player_image.png",player_img_path,"player_image")
	await get_tree().process_frame
	ensure_file_exists("res://Models/DEFAULT_PLAYER_MODELS/FPS_ARM_BASE.glb",custom_char_path+"FPS_ARM_BASE.glb","CUSTOM_PLAYER_HANDS")
	await get_tree().process_frame
	ensure_file_exists("res://Models/DEFAULT_PLAYER_MODELS/CUSTOM_PLAYER_BODY.glb",custom_char_path+"CUSTOM_PLAYER_BODY.glb","CUSTOM_PLAYER_BODY")
	
	
	await get_tree().process_frame
	ensure_file_exists("res://Models/DEFAULT_PLAYER_MODELS/PLAYER_HANDS.blend",default_docs_path+ "CUSTOM/PLAYER_HANDS.blend")
	await get_tree().process_frame
	ensure_file_exists("res://Models/DEFAULT_PLAYER_MODELS/PLAYER_BODY.blend",default_docs_path+ "CUSTOM/PLAYER_BODY.blend")
	
	await get_tree().process_frame
	extract_animations("res://Models/DEFAULT_PLAYER_MODELS/TPS_BODY_SETUP.glb","res://Animations/TPS_DEFAULT_ANIMS.res")
	SceneChanger.player_offset_vector = map_locs[chosen_spawn]["POSITION"]
	print(SceneChanger.player_offset_vector)
	#_load_owned_guns()
	player_inv_backup = player_inv.duplicate(true)
	_reset_player_inventory()
	#player_bar_code_number = generate_random_numeric_string(24)

func sine_wave(amplitude: float = 1.0, frequency: float = 1.0, time_offset: float = 0.0, center: float = 0.0) -> float:
	"""
	Returns a sine wave value between center - amplitude and center + amplitude
	
	Parameters:
	- amplitude: How far from center the wave goes
	- frequency: How fast it oscillates (cycles per second)
	- time_offset: Phase shift in seconds
	- center: The middle point of the wave
	"""
	var time = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	return center + amplitude * sin(time * frequency * TAU + time_offset)

func load_custom_player_image() -> Texture2D:
	# Define os caminhos
	var documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var folder_path = documents_path + "/CRUELTY CITY/"
	var image_path = player_img_path
	var default_image_path = "res://Textures/SPRITES/player_image.png"
	print("NÃO SOU EU QUEM TÔ FAZENDO ISSO!!!!")
	
	# Garante que a pasta existe
	if not DirAccess.dir_exists_absolute(folder_path):
		print("Pasta não encontrada. Criando: ", folder_path)
		var dir = DirAccess.open(documents_path)
		if dir:
			dir.make_dir("CRUELTY CITY")
			print("Pasta criada com sucesso!")
	
	# Usa a função ensure_file_exists para copiar a imagem se necessário
	if not ensure_file_exists(default_image_path, image_path):
		print("ERRO: Não foi possível preparar a imagem do jogador")
		return null
	
	# Carrega a imagem
	var image = Image.new()
	var result = image.load(image_path)
	
	if result != OK:
		print("Erro ao carregar imagem. Código: ", result)
		return null
	
	# Redimensiona se necessário
	if image.get_width() > 128 or image.get_height() > 128:
		print("Imagem muito grande! Redimensionando...")
		image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	
	# Cria e retorna a textura
	var texture = ImageTexture.create_from_image(image)
	print("Imagem carregada com sucesso de: ", image_path)
	return texture

func _load_player_hand_model_glb():
	# Define o caminho base na pasta user:// do jogo
	var model_path = default_docs_path + "CUSTOM_PLAYER_HANDS.glb"
	
	# Caminho do modelo padrão no jogo
	var default_model_path = "res://Models/DEFAULT_PLAYER_MODELS/CUSTOM_PLAYER_HANDS.glb"
	
	# Verifica se o arquivo do modelo personalizado existe
	if not FileAccess.file_exists(model_path):
		print("Arquivo de modelo personalizado não encontrado em: ", model_path)
		print("Copiando modelo padrão do jogo...")
		
		# Verifica se o modelo padrão existe no jogo
		if FileAccess.file_exists(default_model_path):
			# Abre o arquivo padrão para leitura
			var source_file = FileAccess.open(default_model_path, FileAccess.READ)
			if source_file:
				# Lê todo o conteúdo do arquivo
				var file_data = source_file.get_buffer(source_file.get_length())
				
				# Abre o arquivo de destino para escrita
				var dest_file = FileAccess.open(model_path, FileAccess.WRITE)
				if dest_file:
					# Escreve os dados no novo arquivo
					dest_file.store_buffer(file_data)
					print("Modelo padrão copiado com sucesso para: ", model_path)
				else:
					print("ERRO: Não foi possível criar o arquivo de destino")
					return null
			else:
				print("ERRO: Não foi possível abrir o modelo padrão para leitura")
				return null
		else:
			print("ERRO: Modelo padrão não encontrado no jogo: ", default_model_path)
			return null

func _load_player_body_model_glb():
	# Define o caminho base na pasta user:// do jogo
	var model_path = default_docs_path + "CUSTOM_PLAYER_BODY.glb"
	
	# Caminho do modelo padrão no jogo
	var default_model_path = "res://Models/DEFAULT_PLAYER_MODELS/CUSTOM_PLAYER_BODY.glb"
	
	# Verifica se o arquivo do modelo personalizado existe
	if not FileAccess.file_exists(model_path):
		print("Arquivo de modelo personalizado não encontrado em: ", model_path)
		print("Copiando modelo padrão do jogo...")
		
		# Verifica se o modelo padrão existe no jogo
		if FileAccess.file_exists(default_model_path):
			# Abre o arquivo padrão para leitura
			var source_file = FileAccess.open(default_model_path, FileAccess.READ)
			if source_file:
				# Lê todo o conteúdo do arquivo
				var file_data = source_file.get_buffer(source_file.get_length())
				
				# Abre o arquivo de destino para escrita
				var dest_file = FileAccess.open(model_path, FileAccess.WRITE)
				if dest_file:
					# Escreve os dados no novo arquivo
					dest_file.store_buffer(file_data)
					print("Modelo padrão copiado com sucesso para: ", model_path)
				else:
					print("ERRO: Não foi possível criar o arquivo de destino")
					return null
			else:
				print("ERRO: Não foi possível abrir o modelo padrão para leitura")
				return null
		else:
			print("ERRO: Modelo padrão não encontrado no jogo: ", default_model_path)
			return null

func ensure_file_exists(source_path: String, dest_path: String, new_name: String = "") -> bool:
	# Determina o caminho final do destino
	var final_dest_path = dest_path
	
	# Se um novo nome foi fornecido, substitui o nome do arquivo no caminho
	if new_name != "":
		var dest_folder = dest_path.get_base_dir()
		var dest_extension = dest_path.get_extension()
		# Se a extensão estiver vazia, tenta pegar do source_path
		if dest_extension == "":
			dest_extension = source_path.get_extension()
		
		# Constrói o novo caminho com o novo nome
		if dest_extension != "":
			final_dest_path = dest_folder + "/" + new_name + "." + dest_extension
		else:
			final_dest_path = dest_folder + "/" + new_name
	
	# Verifica se o arquivo de destino já existe
	if FileAccess.file_exists(final_dest_path):
		print("Arquivo já existe em: ", final_dest_path)
		return true
	
	print("Arquivo não encontrado em: ", final_dest_path)
	print("Copiando de: ", source_path)
	
	# Verifica se o arquivo fonte existe
	if not FileAccess.file_exists(source_path):
		print("ERRO: Arquivo fonte não encontrado: ", source_path)
		return false
	
	# Abre o arquivo fonte para leitura
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if not source_file:
		print("ERRO: Não foi possível abrir o arquivo fonte: ", source_path)
		return false
	
	# Lê todo o conteúdo do arquivo
	var file_data = source_file.get_buffer(source_file.get_length())
	source_file.close()
	
	# Garante que a pasta de destino existe
	var dest_folder = final_dest_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dest_folder):
		print("Pasta de destino não existe. Criando: ", dest_folder)
		var dir = DirAccess.open(dest_folder.get_base_dir())
		if dir:
			dir.make_dir(dest_folder.get_file())
	
	# Abre o arquivo de destino para escrita
	var dest_file = FileAccess.open(final_dest_path, FileAccess.WRITE)
	if not dest_file:
		print("ERRO: Não foi possível criar o arquivo de destino: ", final_dest_path)
		return false
	
	# Escreve os dados no novo arquivo
	dest_file.store_buffer(file_data)
	dest_file.close()
	
	print("Arquivo copiado com sucesso para: ", final_dest_path)
	return true

func load_glb(model_name : String):
	##Returns a instantiated .glb model scene from the CRUELTY CITY documents folder of the given model name
	
	var model_path = Global.default_docs_path + model_name + ".glb"
	
	# Verifica se o arquivo existe
	if not FileAccess.file_exists(model_path):
		print("Arquivo não encontrado: ", model_path)
		return null
	
	# Carrega o arquivo GLB usando GLTFDocument
	var gltf = GLTFDocument.new()
	var image = Image.new()
	var ctx = GLTFState.new()
	
	# Abre o arquivo e carrega
	var file = FileAccess.open(model_path, FileAccess.READ)
	if file:
		var error = gltf.append_from_file(model_path, ctx)
		if error == OK:
			# Gera a cena a partir do GLTF
			var scene = gltf.generate_scene(ctx)
			if scene:
				print("Modelo carregado com sucesso!")
				return scene
			else:
				print("Erro ao gerar cena do modelo")
				return null
		else:
			print("Erro ao carregar GLB: ", error)
			return null
	else:
		print("Erro ao abrir arquivo")
		return null

func _load_everything():
	# ===== ARQUIVO DO JOGADOR =====
	if FileAccess.file_exists(save_path):
		print("Arquivo de save encontrado. Carregando...")
		_load_game()
	else:
		print("Arquivo de save não encontrado. Criando novo...")
		_save_game()
	
	await get_tree().process_frame

	# ===== ARQUIVO DAS CONFIGS =====
	if FileAccess.file_exists(settings_path):
		print("Arquivo de config encontrado. Carregando...")
		load_settings()
	else:
		print("Arquivo de config não encontrado. Criando novo...")
		var settings = DEFAULT_SETTINGS.duplicate()
		save_settings(settings["master"], settings["bgm"], settings["sfx"], settings["sensi"], settings["reload"],settings["fullscreen"])
	
	
	await get_tree().process_frame

	# ===== ARQUIVO DE STOCKS =====
	if FileAccess.file_exists(StockDb.stocks_save_path):
		print("Arquivo de stocks encontrado. Carregando...")
		StockDb._load_stocks()
	else:
		print("Arquivo de stocks não encontrado. Criando novo...")
		StockDb._save_stocks()
	
	await get_tree().process_frame
	
	# ===== ARQUIVO DE PEIXES =====
	if FileAccess.file_exists(FishSave.save_path):
		print("Arquivo de peixes encontrado. Carregando...")
		FishSave._load_fish()
	else:
		print("Arquivo de peixes não encontrado. Criando novo...")
		FishSave._save_fish()
	
	await get_tree().process_frame
	
	print("TODOS OS ARQUIVOS VERIFICADOS E CARREGADOS!")
	
	print("EXTRAINDO ANIMAÇÕES...")
	extract_animations_from_model()

func _process(_delta: float) -> void:
	_delete_bullet_marks()
	_delete_blood_splats()
	if Input.is_action_just_pressed("ui_text_backspace"):
		emit_signal("day_reload")
		emit_signal("door_close")

func extract_animations_from_model():
	print("Iniciando extração de animações de: ", MODEL_PATH)
	
	# Verifica se o modelo existe
	if not ResourceLoader.exists(MODEL_PATH):
		push_error("Modelo não encontrado: ", MODEL_PATH)
		return false
	
	# Carrega o modelo
	var model_scene = load(MODEL_PATH)
	if not model_scene:
		push_error("Falha ao carregar modelo: ", MODEL_PATH)
		return false
	
	# Instancia o modelo
	var model_instance = model_scene.instantiate()
	
	# Procura pelo AnimationPlayer no modelo
	var animation_player = model_instance.find_child("AnimationPlayer",true)
	await get_tree().process_frame
	
	if not animation_player:
		push_error("Nenhum AnimationPlayer encontrado no modelo!")
		model_instance.queue_free()
		return false
	
	print("AnimationPlayer encontrado: ", animation_player.name)
	print("Animações encontradas: ", animation_player.get_animation_list())
	
	# Cria uma nova biblioteca de animações
	var anim_library = AnimationLibrary.new()
	
	# Copia todas as animações do AnimationPlayer para a biblioteca
	var animation_names = animation_player.get_animation_list()
	for anim_name in animation_names:
		var animation = animation_player.get_animation(anim_name)
		anim_library.add_animation(anim_name, animation)
		print("  - Animação copiada: ", anim_name)
	
	# Salva a biblioteca como recurso
	var result = ResourceSaver.save(anim_library, OUTPUT_PATH)
	
	if result == OK:
		print("SUCESSO! Animações salvas em: ", OUTPUT_PATH)
	else:
		push_error("Falha ao salvar animações. Código de erro: ", result)
	
	# Limpa a instância temporária
	model_instance.queue_free()
	
	return result == OK

func extract_animations(MODEL_PATH : String,OUTPUT_PATH : String):
	print("Iniciando extração de animações de: ", MODEL_PATH)
	
	# Verifica se o modelo existe
	if not ResourceLoader.exists(MODEL_PATH):
		push_error("Modelo não encontrado: ", MODEL_PATH)
		return false
	
	# Carrega o modelo
	var model_scene = load(MODEL_PATH)
	if not model_scene:
		push_error("Falha ao carregar modelo: ", MODEL_PATH)
		return false
	
	# Instancia o modelo
	var model_instance = model_scene.instantiate()
	
	# Procura pelo AnimationPlayer no modelo
	var animation_player = model_instance.find_child("AnimationPlayer",true)
	await get_tree().process_frame
	
	if not animation_player:
		push_error("Nenhum AnimationPlayer encontrado no modelo!")
		model_instance.queue_free()
		return false
	
	print("AnimationPlayer encontrado: ", animation_player.name)
	print("Animações encontradas: ", animation_player.get_animation_list())
	
	# Cria uma nova biblioteca de animações
	var anim_library = AnimationLibrary.new()
	
	# Copia todas as animações do AnimationPlayer para a biblioteca
	var animation_names = animation_player.get_animation_list()
	for anim_name in animation_names:
		var animation = animation_player.get_animation(anim_name)
		anim_library.add_animation(anim_name, animation)
		print("  - Animação copiada: ", anim_name)
	
	# Salva a biblioteca como recurso
	var result = ResourceSaver.save(anim_library, OUTPUT_PATH)
	
	if result == OK:
		print("SUCESSO! Animações salvas em: ", OUTPUT_PATH)
	else:
		push_error("Falha ao salvar animações. Código de erro: ", result)
	
	# Limpa a instância temporária
	model_instance.queue_free()
	
	return result == OK

func _receive_signal(signau : String)->String:
	match signau:
		"kill":
			if player != null:
				emit_signal("killed_something")
				return "kill"
		"update_infos":
			if player != null:
				player.hud.stock_market.user_info_panel._set_up_stats()
				return "update_infos"
		_:
			"WHAT I'M SUPOSED TO DO WITH THIS SHIT?"
			return ""
	return ""

func _reset_player_inventory():
	player_inv = player_inv_backup.duplicate(true)
	for x in get_tree().get_nodes_in_group("reset_picks"):
		x.queue_free()

func _delete_bullet_marks():
	if len(bullet_marks) > 20:
		if bullet_marks[0] != null:
			bullet_marks[0].queue_free()
		bullet_marks.pop_front()

func _delete_blood_splats():
	if len(blood_splats) > 2:
		if blood_splats[0] != null:
			blood_splats[0].queue_free()
		blood_splats.pop_front()

func _show_message(main_msg : String, sub_msg : String,time : float = 3.5, color : String = "GREEN", play_snd : bool = true):
	if hud_node == null:
		return
	else:
		var msg = load(INFO_PANEL).instantiate()
		hud_node.message_box_cont.add_child(msg)
		msg.visible = false
		msg.text_color = color
		msg.main_text = main_msg
		msg.sub_text = sub_msg
		msg.msg_time = time + 0.45
		msg.play_snd = play_snd
		await get_tree().process_frame
		msg.visible = true

func cur_st(sm : StateMachine)->String:
	return str(sm.current_state.name).to_lower()

func re_spawn_player_at_spawn():
	Global.player.global_position = Global.map_locs[Global.chosen_spawn]["POSITION"]

func _spawn_part(particle_file : String, location : Vector3, parent = self):
	var part = load(particle_file).instantiate()
	parent.add_child(part)
	part.global_position = location
	return part

func generate_random_numeric_string(length: int) -> String:
	const chars = "0123456789"
	var output_string := ""
	var rng = RandomNumberGenerator.new()

	for i in range(length):
		var random_index = rng.randi_range(0, chars.length() - 1)
		output_string += chars[random_index]

	return output_string

func _gib_spawner(position: Vector3, force_array: Array = [], random_range: Array = [0, 6], custom_amount: int = -1):
	# Determine which array to use
	var selected_organs: Array
	
	if force_array.size() > 0:
		# Use forced array if provided
		selected_organs = force_array
		print("Using forced organ array: ", selected_organs)
	else:
		# Select random array from specified range
		var min_index = random_range[0] if random_range.size() > 0 else 0
		var max_index = random_range[1] if random_range.size() > 1 else 6
		var random_key = randi_range(min_index, max_index)
		selected_organs = gibbing_results[random_key]
		print("Randomly selected array ", random_key, ": ", selected_organs)
	
	# Determine how many organs to spawn
	var spawn_count = custom_amount if custom_amount > 0 else selected_organs.size()
	
	# Spawn organs
	for i in range(spawn_count):
		# Get organ name (cycle through available organs if custom_amount > array size)
		var organ_index = i % selected_organs.size()
		var organ_name = selected_organs[organ_index]
		
		# Create and setup organ
		var organ = load("res://Scenes/Props/ORGANS/GenericRigidOrgan.tscn").instantiate()
		self.add_child(organ)
		
		# Add some random offset
		var random_offset = Vector3(
			randf_range(-0.3, 0.3),
			0.5,
			randf_range(-0.3, 0.3)
		)
		organ.global_position = position + random_offset
		
		# Random rotation
		organ.rotation = Vector3(
			randf_range(0, TAU),
			randf_range(0, TAU),
			randf_range(0, TAU)
		)
		
		# Set organ name
		organ.organ_name = organ_name
func start_dialogue(dialog_tag : String):
	Global.player.hud.dbox.start_dialogue(Diag.get_dialog(dialog_tag))
#endregion
