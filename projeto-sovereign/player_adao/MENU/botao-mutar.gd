extends CheckButton


# Nome do bus que queremos mutar (geralmente 'Master')
var bus_index

func _ready():
	# Descobre qual é o número do canal "Master"
	bus_index = AudioServer.get_bus_index("Master")
	
	# Conecta o sinal do próprio botão a uma função via código
	# (Você também pode fazer isso pela aba 'Node' no editor)
	toggled.connect(_on_toggled)

func _on_toggled(is_pressed: bool):
	# Se o botão estiver ATIVO (pressed), mutamos o áudio.
	# AudioServer.set_bus_mute(índice, verdadeiro/falso)
	AudioServer.set_bus_mute(bus_index, is_pressed)
	
	if is_pressed:
		print("Áudio Mutado")
	else:
		print("Áudio Ativado")
