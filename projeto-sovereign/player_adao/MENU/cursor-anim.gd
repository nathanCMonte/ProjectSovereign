extends Node

func _ready():
	pass
	# 1. Carrega a textura original
	#var textura_original = load("res://The_Dude_Free/arma-sovereing.png")
	#
	## Verificação de segurança (caso o caminho esteja errado)
	#if textura_original == null:
		#print("Erro: Não achei a imagem da arma no caminho especificado!")
		#return
#
	## 2. CORRIGIDO: Agora dizemos para a textura pegar a imagem
	#var imagem = textura_original.get_image()
	#
	## 3. Redimensiona para um tamanho de cursor (64x64 é ótimo)
	#imagem.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	#
	## 4. Cria a textura final
	#var cursor_final = ImageTexture.create_from_image(imagem)
	#
	## 5. Define como cursor
	## Mudei o Vector2 para (32, 32) caso queira o clique no MEIO da imagem.
	## Se a ponta da arma for no canto superior esquerdo, use Vector2(0, 0).
	#Input.set_custom_mouse_cursor(cursor_final, Input.CURSOR_ARROW, Vector2(0, 0))
