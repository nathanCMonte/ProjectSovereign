extends Sprite2D


func _ready():
	add_to_group("meu_cursor")

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# 2. Configurações visuais (Ajuste conforme sua arma/espada)
	# Se ela aponta para a direita, -45 ou -135 costuma inclinar certo
	rotation_degrees = 135
	
	# 3. Garante que o Sprite ignore cliques (não bloqueia botões)
	# e que ele use coordenadas globais corretamente
	top_level = true
	z_index = 100

func _process(_delta):
	# 4. Segue o mouse em tempo real
	# Usamos get_global_mouse_position() para precisão total
	global_position = get_global_mouse_position()
	
