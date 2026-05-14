extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://player_adao/SCENES/MAP/mapateste.tscn")



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits1_pressed() -> void:
	get_tree().change_scene_to_file("res://player_adao/MENU/credits.tscn")


func _on_how_2_play_pressed() -> void:
	get_tree().change_scene_to_file("res://player_adao/MENU/how-to-play.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://player_adao/MENU/option2.tscn")
