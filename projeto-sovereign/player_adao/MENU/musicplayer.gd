extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func parar_musica():

	propagate_call("set_playing", [false])

	propagate_call("stop") 
	print("Comando de parar música executado!")
