extends Control

func _ready():
	$Play.pressed.connect(_on_play_pressed)
	$How_to_play.pressed.connect(_on_how_to_play_pressed)
	$Credits.pressed.connect(_on_credits_pressed)
	$Exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	print("Iniciar jogo - adicione a cena do jogo aqui!")

func _on_how_to_play_pressed():
	get_tree().change_scene_to_file("res://how_to_play.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_exit_pressed():
	get_tree().quit()
