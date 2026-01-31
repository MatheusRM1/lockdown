extends Control

func _ready():
	$Play.pressed.connect(_on_play_pressed)
	$How_to_play.pressed.connect(_on_how_to_play_pressed)
	$Credits.pressed.connect(_on_credits_pressed)
	$Exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/horror_level.tscn")

func _on_how_to_play_pressed():
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_credits_pressed():
	if GameState:
		GameState.set_previous_scene("res://scenes/main_page.tscn")
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_exit_pressed():
	get_tree().quit()
