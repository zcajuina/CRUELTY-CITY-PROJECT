extends Control
@onready var master_slider: HSlider = $MASTER_SLIDER
@onready var sensi_slider: HSlider = $SENSI_SLIDER
@onready var bgm_slider: HSlider = $BGM_SLIDER
@onready var misc_slider: HSlider = $MISC_SLIDER
@onready var reload_btn: CheckButton = $RELOAD_BTN

func _ready() -> void:
	# Carrega as configurações da Global
	_load_settings_from_global()
	
	# Conecta os sinais
	master_slider.value_changed.connect(_on_master_changed)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	misc_slider.value_changed.connect(_on_sfx_changed)
	sensi_slider.value_changed.connect(_on_sensi_changed)
	reload_btn.toggled.connect(_on_reload_toggled)

func _load_settings_from_global():
	# Usa a função da Global para carregar
	var settings = Global.load_settings()
	
	# Atualiza os sliders com os valores carregados
	master_slider.value = settings["master"]
	bgm_slider.value = settings["bgm"]
	misc_slider.value = settings["sfx"]
	sensi_slider.value = settings["sensi"]
	reload_btn.button_pressed = settings["reload"]

# ===== FUNÇÕES DE CALLBACK =====
func _on_master_changed(value: float):
	Global.set_volume(Global.BUS_MASTER, value)

func _on_bgm_changed(value: float):
	Global.set_volume(Global.BUS_BGM, value)

func _on_sfx_changed(value: float):
	Global.set_volume(Global.BUS_SFX, value)

func _on_sensi_changed(value: float):
	Global.player_sensi = value

func _on_reload_toggled(toggled: bool):
	Global.crus_reload = toggled


func _on_screen_sizes_item_selected(index: int) -> void:
	Global.screen_number = index
	match index:
		0:
			
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
