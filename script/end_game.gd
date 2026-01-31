extends Control

enum GameResult {
	DEFEAT,
	VICTORY
}

@onready var defeat_texture: TextureRect = $Defeat
@onready var victory_texture: TextureRect = $Victory
@onready var back_button: Button = $Back
@onready var credits_button: Button = $Credits
@onready var exit_button: Button = $Exit

var result: GameResult = GameResult.DEFEAT

func _ready():
	# Conectar botões
	back_button.pressed.connect(_on_back_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Mostrar cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Verificar resultado do jogo via GameState
	var game_result_str = GameState.get_meta("game_result", "defeat")
	if game_result_str == "victory":
		result = GameResult.VICTORY
	else:
		result = GameResult.DEFEAT
	
	# Limpar o resultado
	GameState.set_meta("game_result", "defeat")
	GameState.set_meta("killer_pausado", false)
	
	# Mostrar resultado correto
	if result == GameResult.DEFEAT:
		defeat_texture.visible = true
		victory_texture.visible = false
	else:
		defeat_texture.visible = false
		victory_texture.visible = true

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_page.tscn")

func _on_credits_pressed():
	if GameState:
		GameState.set_previous_scene("res://scenes/end_game.tscn")
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_exit_pressed():
	get_tree().quit()

# Função para definir o resultado antes de carregar a cena
static func set_result(game_result: GameResult):
	# Armazenar resultado em um autoload ou variável global
	# Por enquanto vamos usar uma abordagem simples
	pass
