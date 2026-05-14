extends Node2D

@onready var player = $player2
@onready var vida = $CanvasLayer2/TextureProgressBar


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		get_tree().change_scene_to_file("res://player_adao/SCENES/MAP/game_over.tscn")

func _ready():
	vida.max_value = player.vida_maxima

	get_tree().call_group("meu_cursor", "hide")
	print("Iniciando gameplay...")

	if musicaglobal:
		musicaglobal.parar_musica()

func _physics_process(delta: float) -> void:
	vida.value = player.vida_atual


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
