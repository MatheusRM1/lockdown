extends Node

# Guarda a cena anterior para navegação
var previous_scene: String = "res://main_page.tscn"

func set_previous_scene(scene_path: String):
	previous_scene = scene_path

func get_previous_scene() -> String:
	return previous_scene
