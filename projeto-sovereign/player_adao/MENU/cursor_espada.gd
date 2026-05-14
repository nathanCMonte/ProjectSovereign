extends Node2D


func _ready():
	# 1. Esconde o mouse real do Windows
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# 2. Rotaciona para o ângulo de um cursor (ajuste conforme o gosto)
	# Se a ponta estava para baixo, -135 costuma deixar na diagonal padrão
	rotation_degrees = 135
	
	# 3. Garante que a espada fique na frente de tudo (UI, botões, etc)
	z_index = 100
	
	# 4. Opcional: Se quiser que ele ignore cliques e não atrapalhe os botões
	# (Caso o Sprite esteja dentro de algum Container)
	top_level = true 

func _process(_delta):
	# 5. Segue a posição do mouse a cada frame
	global_position = get_global_mouse_position()
