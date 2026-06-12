extends Control
@onready var dialogue_bg: Panel = $DIALOGUE_BG
@onready var dialogue_text_label: Label = $DIALOGUE_BG/DIALOGUE_TEXT_LABEL
var can_pass : bool = false
@onready var timer: Timer = $Timer
@onready var mouth: AnimatedSprite2D = $MOUTH
@onready var a_snd: AudioStreamPlayer = $A_SND
@onready var b_snd: AudioStreamPlayer = $B_SND
@onready var c_snd: AudioStreamPlayer = $C_SND
@onready var d_snd: AudioStreamPlayer = $D_SND

signal dialogue_started
signal dialogue_finished

# Add this at the top of your script
var mouth_shapes = {
	"A": "open",      # Open mouth (vowels, wide sounds)
	"B": "mid",       # Mid mouth (most consonants)
	"C": "closed"     # Closed mouth (M, B, P, etc.)
}

# Dialogue state variables
var current_dialogue: Array = []
var current_index: int = 0
var is_active: bool = false

func _text_box_in()->bool:
	dialogue_text_label.text = ""
	self.show()
	#self.position.y = 890
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self,"scale",Vector2(1,1),0.2)
	#tween.tween_property(self,"position",Vector2(556.0,636.0),0.2)
	await tween.finished
	return true

func _text_box_out():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self,"scale",Vector2(0.1,0.1),0.2)
	#tween.tween_property(self,"position",Vector2(556.0,890),0.2)
	await tween.finished
	self.hide()

func _ready():
	# Hide dialogue on start
	self.visible = false

func start_dialogue(dialogue_lines: Array):
	"""Start a new dialogue sequence with the given array of strings"""
	if dialogue_lines.is_empty():
		return
	
	current_dialogue = dialogue_lines.duplicate()
	current_index = 0
	is_active = true
	
	# Show first line
	Global.player_sm.change_state("interact")
	emit_signal("dialogue_started")
	await _text_box_in()
	if not current_dialogue.is_empty():
		_add_text(current_dialogue[0])

func _single_text_entrance(dialogue_lines: Array):
	auto_remove_add_text(dialogue_lines[0])

func _mouth_anim_and_snd(given_l):
	var letter = _get_mouth_shape_for_letter(given_l)
	mouth.play(letter)
	var snd_node
	var pitch
	match letter:
		"A":
			snd_node = a_snd
			pitch = -0.5
		"B":
			snd_node = b_snd
			pitch = -0.3
		"C":
			snd_node = c_snd
			pitch = -0.1
		"D":
			snd_node = d_snd
			pitch = -0.2
	snd_node.pitch_scale = 1
	snd_node.pitch_scale += pitch
	snd_node.play()

func _add_text(text_here : String):
	can_pass = false
	var skiped = false
	#Global.player_sm.change_state("interact")
	
	if self.visible == false:
		self.visible = true
	
	dialogue_text_label.text = ""
	
	# Typewriter effect
	for i in range(text_here.length() + 1):
		if skiped == false:
			dialogue_text_label.text = text_here.substr(0, i)
			if i > 0:  # Evita erro no primeiro caractere
				_mouth_anim_and_snd(text_here[i - 1])
			await get_tree().create_timer(0.04).timeout
		
		# Verifica se o jogador apertou WASD para cancelar
		if Input.is_action_just_pressed("w") or Input.is_action_just_pressed("a") or \
		   Input.is_action_just_pressed("s") or Input.is_action_just_pressed("d"):
			_cancel_dialogue()
			return
		
		# Allow player to skip by holding E
		if Input.is_action_just_pressed("e"):
			dialogue_text_label.text = text_here  # Show full text immediately
			break
	
	can_pass = true

func auto_remove_add_text(text_here : String):
	can_pass = false
	var skiped = false
	#Global.player_sm.change_state("interact")
	
	# Garante que a escala está correta antes de começar
	self.scale = Vector2(1, 1)
	
	if self.visible == false:
		self.visible = true
	
	dialogue_text_label.text = ""
	
	# Typewriter effect
	for i in range(text_here.length() + 1):
		if skiped == false:
			dialogue_text_label.text = text_here.substr(0, i)
			if i > 0:
				_mouth_anim_and_snd(text_here[i - 1])
			await get_tree().create_timer(0.04).timeout
		
		# Verifica se o jogador apertou WASD para cancelar
		if Input.is_action_just_pressed("w") or Input.is_action_just_pressed("a") or \
		   Input.is_action_just_pressed("s") or Input.is_action_just_pressed("d"):
			_cancel_dialogue()
			return
		
		# Allow player to skip by holding E
		if Input.is_action_just_pressed("e"):
			dialogue_text_label.text = text_here
			break
	
	can_pass = true
	await get_tree().create_timer(1.0).timeout
	await _text_box_out()
	is_active = false
	current_dialogue.clear()
	current_index = 0
	can_pass = false

func _cancel_dialogue():
	"""Cancela o diálogo atual e volta ao movimento"""
	print("Diálogo cancelado pelo movimento")
	
	# Para qualquer animação em andamento
	dialogue_text_label.text = ""
	
	# Fecha a caixa de diálogo
	await _text_box_out()
	
	# Reseta estados
	is_active = false
	current_dialogue.clear()
	current_index = 0
	can_pass = false
	
	# Volta o jogador para o estado de movimento
	Global.player_sm.change_state("move")
func _get_mouth_shape_for_letter(letter: String) -> String:
	var upper_letter = letter.to_upper()
	
	# Vowels - open mouth
	if upper_letter in ["A", "E", "I", "O", "U", "Y"]:
		return "A"  # Open
	
	# Closed mouth consonants
	elif upper_letter in ["M", "B", "P", "F", "V"]:
		return "B"  # Closed
	elif upper_letter  in ["N", "K", "R", "S", "T"]:
		return "C"  # Mid
	else:
		return "D"  # Mid

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("e") and can_pass:
		_advance_dialogue()
	
	# Verifica cancelamento por movimento a qualquer momento
	if is_active and (Input.is_action_just_pressed("w") or \
					  Input.is_action_just_pressed("a") or \
					  Input.is_action_just_pressed("s") or \
					  Input.is_action_just_pressed("d")):
		_cancel_dialogue()
func _advance_dialogue():
	if not is_active:
		return
	
	# Move to next line
	current_index += 1
	
	# Check if we reached the end
	if current_index >= current_dialogue.size():
		_close_dialogue()
	else:
		# Show next line
		_add_text(current_dialogue[current_index])

func _close_dialogue():
	"""Close dialogue box and clean up"""
	_text_box_out()
	#self.visible = false
	is_active = false
	current_dialogue.clear()
	current_index = 0
	can_pass = false
	
	await get_tree().process_frame
	emit_signal("dialogue_finished")
	Global.player_sm.change_state("idle")

func _on_timer_timeout() -> void:
	can_pass = true
