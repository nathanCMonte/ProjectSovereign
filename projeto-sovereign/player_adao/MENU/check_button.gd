extends CheckButton

# Certifique-se de que o nome após o $ é EXATAMENTE o que aparece na árvore de cenas
@onready var meu_botao = $CheckButton 

func _ready():
	# PROTEÇÃO: Se 'meu_botao' for nulo, ele avisa no console em vez de travar o jogo
	if meu_botao == null:
		print("ERRO: O botão não foi encontrado! Verifique o nome na árvore de cenas.")
		return # Para a execução aqui para não dar erro de 'null instance'

	var master_bus = AudioServer.get_bus_index("Master")
	
	# Sincroniza o botão com o áudio
	meu_botao.button_pressed = AudioServer.is_bus_mute(master_bus)
	
	# Conecta o sinal
	meu_botao.toggled.connect(_on_check_button_toggled)

func _on_check_button_toggled(is_it_pressed: bool):
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, is_it_pressed)
