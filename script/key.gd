extends Node3D

@export var velocidade_rotacao: float = 2.0
@export var amplitude_flutuacao: float = 0.1
@export var velocidade_flutuacao: float = 2.0

var tempo: float = 0.0
var posicao_inicial_y: float = 0.0
var foi_coletada: bool = false

@onready var area = $Area3D

func _ready() -> void:
	posicao_inicial_y = global_position.y
	print("Chave criada em: ", global_position)

func _process(delta: float) -> void:
	if foi_coletada:
		return
	
	tempo += delta
	rotate_y(velocidade_rotacao * delta)
	global_position.y = posicao_inicial_y + sin(tempo * velocidade_flutuacao) * amplitude_flutuacao

func _on_body_entered(body: Node3D) -> void:
	if foi_coletada:
		return
	
	if body.name == "Personagem" or body.is_in_group("player"):
		coletar_chave(body)

func coletar_chave(_personagem: Node3D) -> void:
	if foi_coletada:
		return
	
	foi_coletada = true
	print("Chave coletada!")
	
	# Notificar o game state que a chave foi coletada
	if has_node("/root/GameState"):
		GameState.set_meta("tem_chave", true)
	
	queue_free()
