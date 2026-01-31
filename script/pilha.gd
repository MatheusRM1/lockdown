extends Area3D

@export var energia_recuperada: float = 30.0
@export var velocidade_rotacao: float = 2.0
@export var amplitude_flutuacao: float = 0.1
@export var velocidade_flutuacao: float = 2.0
@export var som_coleta: AudioStream

var tempo: float = 0.0
var posicao_inicial_y: float = 0.0
var foi_coletada: bool = false

func _ready() -> void:
	posicao_inicial_y = global_position.y
	print("Pilha criada em: ", global_position)

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
		coletar_pilha(body)

func coletar_pilha(personagem: Node3D) -> void:
	if foi_coletada:
		return
	
	foi_coletada = true
	print("Pilha coletada!")
	
	var lanterna = personagem.get_node_or_null("Camera3D/Lanterna")
	if lanterna and lanterna.has_method("recarregar_energia"):
		lanterna.recarregar_energia(energia_recuperada)
	
	queue_free()
