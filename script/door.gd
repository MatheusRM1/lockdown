extends StaticBody3D

@export var destino_scene: String = "" # Cena para onde a porta leva
@export var requer_chave: bool = true

@onready var label = $InteractionArea/Label3D
@onready var collision = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D

var player_nearby: bool = false
var is_opening: bool = false
var opening_angle: float = 0.0
const OPEN_SPEED: float = 1.5
const MAX_OPEN_ANGLE: float = 1.57 # 90 graus

func _ready():
	$InteractionArea.body_entered.connect(func(b): if b.is_in_group("player"): player_nearby = true)
	$InteractionArea.body_exited.connect(func(b): if b.is_in_group("player"): player_nearby = false)
	if label:
		label.visible = false

func _process(delta):
	# Animação de abertura da porta
	if is_opening:
		opening_angle = move_toward(opening_angle, MAX_OPEN_ANGLE, delta * OPEN_SPEED)
		if mesh_instance:
			mesh_instance.rotation.y = opening_angle
		return
	
	# Mostrar texto quando jogador está próximo
	if label:
		label.visible = player_nearby
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		tentar_abrir()

func tentar_abrir():
	if requer_chave:
		var tem_chave = false
		if has_node("/root/GameState"):
			tem_chave = GameState.get_meta("tem_chave", false)
		
		if not tem_chave:
			print("Porta trancada! Precisa de uma chave.")
			# Mostrar mensagem de porta trancada
			if label:
				label.text = "Está trancada!"
				# Voltar para o texto original após 2 segundos
				await get_tree().create_timer(2.0).timeout
				if label:
					label.text = "Aperte E para abrir a porta"
			return
	
	abrir_porta()

func abrir_porta():
	print("Porta aberta! Vitória!")
	
	# Pausar o killer
	GameState.set_meta("killer_pausado", true)
	
	# Configurar resultado como vitória e ir para tela de vitória
	GameState.set_meta("game_result", "victory")
	get_tree().change_scene_to_file("res://scenes/end_game.tscn")
