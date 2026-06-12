extends State
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var root: CharacterBody3D = $"../.."
@onready var head: Node3D = $"../../head"
@onready var ray: RayCast3D = $"../../head/RayCast3D"
@onready var shoot_timer: Timer = $"../../shoot_timer"
@onready var reload_timer: Timer = $"../../reload_timer"
@onready var shoot_snd: AudioStreamPlayer3D = $"../../SHOOT_SND"

const FOE_BULLET : String = "res://Scenes/Props/FOE_BULLET/FOE_BULLET.tscn"

func enter() -> void:
	nav.target_position = Global.player.global_position

func physics_update(delta)->void:
	if root.health >0:
		_moving_logic(delta)
		if nav.distance_to_target() >= root.see_distance:
			state_machine.change_state("foe_idle")
		elif nav.distance_to_target() <= root.shooting_distance:
			_projectile_shoot()
			#_shooting_logic()
	else:
		state_machine.change_state("foe_dead")

func update(delta : float)->void:
	await get_tree().create_timer(randf_range(0.25,1)).timeout
	root.head_turn(root.head_rotation_speed,delta)
	root.look_at_player_y()
	#root.head.look_at(Global.player.global_position)

func _moving_logic(delta : float):
	await get_tree().create_timer(randf_range(0.25,1)).timeout
	nav.target_position = Global.player.global_position
	var direction = (nav.get_next_path_position() - root.global_position).normalized()
	direction.y = 0
	root.velocity = root.velocity.lerp(direction * root.speed,  root.acel * delta)
	root.move_and_slide()

func _shooting_logic():
	if ray.is_colliding() and ray.get_collider() == Global.player:
		if shoot_timer.is_stopped() and root.bullets >0:
			root.bullets -= 1
			Global.player.hit(root.gun_damage)
			shoot_timer.start()
		elif root.bullets <= 0 and reload_timer.is_stopped():
			reload_timer.start()

func _on_reload_timer_timeout() -> void:
	root.bullets = root.max_bullets

func _projectile_shoot():
	if ray.is_colliding() and ray.get_collider() == Global.player:
		if shoot_timer.is_stopped() and root.bullets >0:
			shoot_timer.start()
			root.bullets -= 1
			bullet_spawn()
			shoot_snd.play()
		elif root.bullets <= 0 and reload_timer.is_stopped():
			reload_timer.start()

func bullet_spawn():
	var bullet = load("res://Scenes/Props/FOE_BULLET/FOE_BULLET.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.damg = root.gun_damage - (randi_range(0,root.gun_damage))
	bullet.global_position = head.global_position
	bullet.global_rotation = head.global_rotation
