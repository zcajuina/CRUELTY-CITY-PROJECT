extends Node3D
@onready var neuron_ost: AudioStreamPlayer3D = $neuron_ost
var firing : bool = false
var current_tween: Tween = null

func _process(delta: float) -> void:
	var should_be_firing = false
	if not Global.on_menu:
		if Global.player.player_sm.cur_state() == "dead":
			return
		else:
			if Global.player.player_sm.cur_state() == "interact":
				return
			else:
				if Input.is_action_pressed("mb_left"):
					if Global.player_gun_ammo[Global.player.gun.current_gun_pos]["cur_magazine"] > 0:
						should_be_firing = true
	
	if should_be_firing and not firing:
		_start_msc()
	elif not should_be_firing and firing:
		_stop_msc()

func _start_msc():
	firing = true
	
	# Mata qualquer tween existente
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Se já está tocando, só ajusta o volume
	if not neuron_ost.playing:
		neuron_ost.play()
	
	# Cria novo tween para fade in
	current_tween = create_tween()
	current_tween.set_parallel(true)
	#neuron_ost.pitch_scale = 0.8
	#current_tween.tween_property(neuron_ost,"pitch_scale",1.0,0.5)
	current_tween.tween_property(neuron_ost, "volume_linear", 1.0, 0.25)

func _stop_msc():
	firing = false
	
	# Mata qualquer tween existente
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Cria novo tween para fade out
	current_tween = create_tween()
	current_tween.set_parallel(true)
	#neuron_ost.pitch_scale = 1.0
	#current_tween.tween_property(neuron_ost,"pitch_scale",0.8,0.5)
	current_tween.tween_property(neuron_ost, "volume_linear", 0.0, 0.25)
	
	# Espera o fade out terminar e para a música
	await current_tween.finished
	if not firing:  # Verifica se ainda não está atirando
		neuron_ost.stop()
		neuron_ost.volume_linear = 0.0  # Reseta o volume
