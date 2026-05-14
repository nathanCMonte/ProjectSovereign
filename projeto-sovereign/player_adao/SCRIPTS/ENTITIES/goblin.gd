extends CharacterBody2D

# Configurações
@export var vida_maxima = 100
var vida_atual = 50
@export var dano_do_inimigo = 15
const SPEED = 200

# Nós
@onready var barra_vida: TextureProgressBar = $TextureProgressBar
@onready var raycast: RayCast2D = $RayCast2D
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_ataque: Area2D = $AreaAttack

# Estados
var tomando_kb = false
var player_na_area_ataque = false
var player = null
var is_attacking = false
var is_hurting = false
var direcao_patrulha = 1
var can_atk = true

func _ready() -> void:
	vida_atual = vida_maxima
	barra_vida.max_value= vida_maxima
	barra_vida.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not tomando_kb:
		movimentacao()
	move_and_slide()
	atualizar_animacoes()

func movimentacao():
	var direcao_final = direcao_patrulha
	
	if player:
		# 1. Calculamos a distância bruta
		var distancia_x = player.global_position.x - global_position.x
		
		# 2. Só mudamos a direção se a distância for MAIOR que 5 pixels (a "zona morta")
		if abs(distancia_x) > 5:
			var direction_x = sign(distancia_x)
			direcao_final = direction_x
			direcao_patrulha = direction_x
		else:
			# Se estiver muito perto, ele mantém a última direção para não tremer
			direcao_final = direcao_patrulha
		
		# 3. Lógica de ataque ou perseguição
		if player_na_area_ataque:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			iniciar_ataque()
		elif not is_attacking and not is_hurting:
			# Só corre se não estiver na zona morta de 5 pixels
			if abs(distancia_x) > 5:
				velocity.x = direcao_final * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Patrulha normal (seu código original)
		if not is_attacking and not is_hurting:
			velocity.x = direcao_patrulha * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if raycast.is_colliding():
			direcao_patrulha *= -1
			direcao_final = direcao_patrulha
			
	# Atualiza o Raycast e o Sprite
	raycast.target_position.x = abs(raycast.target_position.x) * direcao_final
	animacao.flip_h = direcao_final < 0
	$AreaAttack/CollisionShape2D.position.x = 20 * direcao_final

func iniciar_ataque():
	if is_attacking or is_hurting or not can_atk: return
	
	is_attacking = true
	can_atk = false
	animacao.play("attack")
	
	await get_tree().create_timer(0.4).timeout
	

	if is_attacking:
		causar_dano_na_area()
	
	await animacao.animation_finished
	is_attacking = false
	
	await get_tree().create_timer(0.8).timeout
	can_atk = true

func causar_dano_na_area():
	var corpos_atingidos = area_ataque.get_overlapping_bodies()
	
	for corpo in corpos_atingidos:
		if corpo.is_in_group("player") and corpo.has_method("take_damage"):
			corpo.take_damage(dano_do_inimigo)

func take_damage(dano):
	if vida_atual <= 0: return
	barra_vida.visible = true
	vida_atual -= dano
	barra_vida.value = vida_atual
	is_hurting = true
	is_attacking = false 
	
	if vida_atual <= 0:
		morrer()
	else:
		animacao.play("take_hit")
		await animacao.animation_finished
		is_hurting = false

func morrer():
	set_physics_process(false)
	animacao.play("death")
	await animacao.animation_finished
	queue_free()

func atualizar_animacoes():
	if is_attacking or is_hurting or tomando_kb:
		return
		
	if velocity.x != 0:
		animacao.play("walk")
	else:
		animacao.play("idle")

func _on_detection_aura_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_detection_aura_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		


func _on_area_attack_body_entered(body: Node2D) -> void:
	if body == player:
		player_na_area_ataque = true

func _on_area_attack_body_exited(body: Node2D) -> void:
	if body == player:
		player_na_area_ataque = false
		
func take_kb(direcao):
	tomando_kb = true
	velocity.x = 300 * direcao
	velocity.y = -100
	animacao.play("take_hit")
	animacao.frame = 2
	await get_tree().create_timer(0.4).timeout
	tomando_kb = false
