extends Control

func _ready():
	$back.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	var previous = "res://main_page.tscn"
	if GameState:
		previous = GameState.get_previous_scene()
	get_tree().change_scene_to_file(previous)
