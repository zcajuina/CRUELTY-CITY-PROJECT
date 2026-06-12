extends Control
@onready var pole: ColorRect = $POLE
@onready var base: ColorRect = $BASE
@onready var target: ColorRect = $TARGET
@onready var label: Label = $Label

var target_position: float = 0.0
var current_position: float = 0.0
var speed: float = 10.0  # Velocidade de suavização
var reached : bool = false

const default_pole_pos : float =-6

func _ready():
	# Inicializa as posições
	target_position = target.position.y
	current_position = target.position.y

func _input(event: InputEvent) -> void:
	if Global.player.gun_sm.cur_state() == "gun_reload" and Global.crus_reload:
		if event is InputEventMouseMotion:
			# Acumula a posição desejada baseada no movimento do mouse
			target_position += event.relative.y * 2.9  # Ajuste o multiplicador conforme necessário
			target_position = clampf(target_position, -139, 139)
			Global.player.visuais._reload_anim_2(event.relative.y * 2.9 )
			# Verifica se atingiu o topo
			if target_position >= 138 and reached == false:
				reached = true
				print("GOT IT!")
				Global.player.gun._reload()
				#reset_target()

func _process(delta):
	if Global.player.gun_sm.cur_state() == "gun_reload":
		# Move suavemente em direção à posição alvo
		current_position = lerp(current_position, target_position, speed * delta)
		target.position.y = current_position
		
		# Atualiza o label com a posição atual
		label.text = str(int(current_position))

# Função para resetar o target (quando completar o reload)
func reset_target():
	target.position.y = default_pole_pos
	target_position = default_pole_pos
	current_position = default_pole_pos
