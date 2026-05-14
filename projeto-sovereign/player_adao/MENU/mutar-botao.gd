extends CheckButton

# Pegamos o índice do "Master" uma vez para ganhar performance
@onready var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	# 1. Faz o botão começar "marcado" se o áudio já estiver mutado
	button_pressed = AudioServer.is_bus_mute(master_bus)
	
	# 2. Conecta o sinal do próprio botão a ele mesmo
	toggled.connect(_ao_alternar_mute)

func _ao_alternar_mute(ligado: bool):
	# 3. Muta o canal Master se o botão for ativado
	AudioServer.set_bus_mute(master_bus, ligado)
	
	# Debug para conferir no console
	if ligado:
		print("Áudio MUTADO")
	else:
		print("Áudio ATIVADO")
