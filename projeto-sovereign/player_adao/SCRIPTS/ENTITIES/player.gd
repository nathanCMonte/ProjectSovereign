extends CharacterBody2D


@onready var sfx_hit : AudioStreamPlayer2D = $SFX_hit
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_particles : GPUParticles2D = $DashParticles
@onready var area_ataque : Area2D = $AreaAttack


#soms
var sfx_hit_playback : AudioStreamPlaybackPolyphonic
var hit1 = preload("res://player_adao/ASSETS/SOUNDS/dragon-studio-sword-slice-393847.mp3")
var hit2 =  preload("res://player_adao/ASSETS/SOUNDS/dragon-studio-sword-slice-2-393845.mp3")
var hit3 = preload("res://player_adao/ASSETS/dragon-studio-violent-sword-slice-393839.mp3")
var no_hit = preload("res://player_adao/ASSETS/SOUNDS/musicholder-sword-sound-260274.mp3")


# Configurações de Regeneração
var pode_regenerar = true
var tempo_espera_regen = 10 # Segundos sem combate para começar a curar
var taxa_regen = 5 # Quanto de vida recupera por segundo
@onready var timer_regen = Timer.new()

# Vida
var vivo = true
var vida_maxima = 100
var vida_atual = vida_maxima
var is_hurting = false

# Constantes
const SPEED = 275.0
const JUMP_VELOCITY = -375.0
const WALL_SLIDE_SPEED = 150.0
const WALL_JUMP_PUSH = 375.0

# Variaveis attack
var is_attacking = false
var current_attack = 1
var can_attack_air = true 

# Variaveis dash
var is_dashing = false
var can_dash = true
const DASH_FORCE = 600
const DASH_DURATION = 0.2

# Variaveis jump
var max_jumps = 1
var current_jump = 0
var is_wall_jumping = false

func _ready() -> void:
	sfx_hit.play()
	sfx_hit_playback  = sfx_hit.get_stream_playback() 
	vivo = true
	add_child(timer_regen)
	timer_regen.wait_time = tempo_espera_regen
	timer_regen.one_shot = true
	timer_regen.timeout.connect(func(): pode_regenerar = true)
	set_physics_process(true)
	dash_particles.emitting = false

func _physics_process(delta: float) -> void:
	if not vivo:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.x = move_toward(velocity.x, 0, 10) # Para suavemente no chão
		move_and_slide()
		return
	if pode_regenerar and vida_atual < vida_maxima:
		vida_atual += taxa_regen * delta
		# Garante que não passe do máximo
		vida_atual = min(vida_atual, vida_maxima)
	
	if is_attacking:
		velocity.y = 0
	
	if not is_on_floor():
		if not is_dashing:
			if is_on_wall() and velocity.y > 0:
				velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
			
			if Input.is_action_pressed("down"):
				velocity += get_gravity() * delta * 1.8
			else:
				velocity += get_gravity() * delta
		
	if is_on_floor():
		current_jump = 0
		can_attack_air = true
		
	dar_dash()
	atacks()
	movimentacao()
	move_and_slide()
	animacoes()

func movimentacao():
	if is_dashing:
		return
	
	# 1. LÓGICA DE PULO
	if Input.is_action_just_pressed("jump") and not is_attacking:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			current_jump = 1
		elif is_on_wall():
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * WALL_JUMP_PUSH
			animacao.flip_h = velocity.x < 0
			$AreaAttack/CollisionShape2D.position.x = 44 * (1 if velocity.x > 0 else -1)
			
			is_wall_jumping = true
			get_tree().create_timer(0.2).timeout.connect(func(): is_wall_jumping = false)
			
		elif current_jump < max_jumps:
			velocity.y = JUMP_VELOCITY
			current_jump += 1

	# 2. MOVIMENTAÇÃO HORIZONTAL
	var direction := Input.get_axis("left", "right")

	if is_wall_jumping:
		velocity.x = move_toward(velocity.x, 0, 8.0) 
	elif direction:
		if is_attacking or is_hurting:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, 50.0)

			var offset = 44
			if not (is_on_wall() and not is_on_floor()):
				animacao.flip_h = direction < 0
			dash_particles.scale.x = -1 if direction < 0 else 1
			$AreaAttack/CollisionShape2D.position.x = offset * direction
	else:
		velocity.x = move_toward(velocity.x, 0, 50.0)

func animacoes():
	if is_attacking or is_hurting:
		return

	if not is_on_floor():
		if is_on_wall() and velocity.y > 0:
			animacao.play("fall") 
		elif velocity.y < 0:
			animacao.play("jump")
		else:
			animacao.play("fall")
	else:
		if velocity.x != 0:
			animacao.play("run")
		else:
			animacao.play("idle")
			
func atacks():
	if not is_attacking and not is_hurting:
		if Input.is_action_just_pressed("attack"):
			# Se estiver no chão, ataca normal
			if is_on_floor():
				realizar_ataque()
			# Se estiver no ar, checa se ainda tem o ataque disponível
			elif can_attack_air:
				can_attack_air = false # Consome o ataque aéreo
				realizar_ataque()

func realizar_ataque():
	resetar_timer_regen()
	is_attacking = true
	var anim_name = "attack" + str(current_attack)
	animacao.play(anim_name)
	#tocar_som_atk()
	
	await get_tree().create_timer(0.15).timeout
	
	if is_hurting or not is_attacking:
		return
	aplicar_dano_em_area()
	
	await animacao.animation_finished
	if is_hurting:
		current_attack = 1
		is_attacking = false
		return
	
	current_attack += 1
	if current_attack > 3:
		current_attack = 1
	
	$ATK_Cooldown.start()
	is_attacking = false

func aplicar_dano_em_area():
	var deu_dano = false
	var corpos = area_ataque.get_overlapping_bodies()
	for corpo in corpos:
		if corpo.is_in_group("enemy") and corpo.has_method("take_damage"):
			deu_dano = true
			if current_attack == 3 and corpo.has_method("take_kb"):
				var direcao_kb = sign(corpo.position.x - position.x)
				corpo.take_kb(direcao_kb)
			corpo.take_damage(20)
	tocar_som_atk(deu_dano)

func take_damage(dano):
	if not vivo: return
	
	resetar_timer_regen()
	vida_atual -= dano
	
	if vida_atual <= 0:
		vida_atual = 0
		morrer()
		return 

	if is_hurting: return 
	
	is_hurting = true
	is_attacking = false
	current_attack = 1
	
	animacao.play("take_hit")
	await get_tree().create_timer(0.8).timeout

	if vivo:
		is_hurting = false

func morrer():
	if not vivo: return
	vivo = false
	
	is_attacking = false
	is_dashing = false
	is_hurting = false
	
	velocity = Vector2.ZERO
	animacao.play("death")
	
	# Desativa colisões com inimigos para não levar "dano extra" depois de morto
	# Supondo que sua layer de colisão do player seja a 1
	set_collision_layer_value(1, false) 
	set_collision_mask_value(2, false) # Onde quer que os inimigos/espinhos estejam


	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()


func _on_atk_cooldown_timeout() -> void:
	if not is_attacking:
		current_attack = 1
	
func dar_dash():
	if Input.is_action_just_pressed("dash") and can_dash and not is_attacking:
		is_dashing = true
		can_dash = false
		
		dash_particles.emitting = true
		var dash_dir = -1 if animacao.flip_h else 1
		var input_dir = Input.get_axis("left","right")
		if input_dir != 0:
			dash_dir = input_dir
			
		velocity.x = dash_dir * DASH_FORCE
		velocity.y = 0
		

		await get_tree().create_timer(DASH_DURATION).timeout
		is_dashing = false
		dash_particles.emitting = false

		if Input.get_axis("left", "right") == 0:
			velocity.x = 0
		await get_tree().create_timer(0.8).timeout
		can_dash = true
		
func resetar_timer_regen():
	pode_regenerar = false
	timer_regen.start() # Reinicia a contagem de 5 segundos
	
func tocar_som_atk(deu_dano):
	if not sfx_hit_playback:
		return
	if deu_dano:
		if current_attack == 1:
			sfx_hit_playback.play_stream(hit1)
		if current_attack == 2:
			sfx_hit_playback.play_stream(hit2)
		if current_attack == 3:
			sfx_hit_playback.play_stream(hit3)
	else:
		sfx_hit_playback.play_stream(no_hit)
	
	
	
