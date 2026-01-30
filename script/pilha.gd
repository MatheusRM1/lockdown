extends Area3D

# Configurações
@export var energia_recuperada: float = 30.0  # Quanto de energia a pilha recupera
@export var velocidade_rotacao: float = 2.0
@export var amplitude_flutuacao: float = 0.2
@export var velocidade_flutuacao: float = 2.0

# Som de coleta (opcional)
@export var som_coleta: AudioStream

# Variáveis internas
var tempo: float = 0.0
var posicao_inicial: Vector3
var foi_coletada: bool = false

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var luz: OmniLight3D = $OmniLight3D

func _ready() -> void:
	posicao_inicial = position
	
	# Configurar cor da pilha (azul/ciano para indicar energia)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.7, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.3, 0.8, 1.0)
	material.emission_energy = 1.5
	mesh.set_surface_override_material(0, material)

func _process(delta: float) -> void:
	if foi_coletada:
		return
	
	tempo += delta
	
	# Rotação contínua
	rotate_y(velocidade_rotacao * delta)
	
	# Flutuação vertical
	var offset_y: float = sin(tempo * velocidade_flutuacao) * amplitude_flutuacao
	position.y = posicao_inicial.y + offset_y
	
	# Pulsação da luz
	luz.light_energy = 2.0 + sin(tempo * 3.0) * 0.5

func _on_body_entered(body: Node3D) -> void:
	if foi_coletada:
		return
	
	# Verifica se é o personagem
	if body.name == "Personagem" or body.is_in_group("player"):
		coletar_pilha(body)

func coletar_pilha(personagem: Node3D) -> void:
	"""Processa a coleta da pilha"""
	if foi_coletada:
		return
	
	foi_coletada = true
	
	# Buscar a lanterna no personagem
	var lanterna = personagem.get_node_or_null("Camera3D/Lanterna")
	if lanterna and lanterna.has_method("recarregar_energia"):
		lanterna.recarregar_energia(energia_recuperada)
		
		# Feedback visual de coleta
		criar_efeito_coleta()
		
		# Tocar som (se configurado)
		if som_coleta:
			# Criar AudioStreamPlayer temporário
			var audio_player := AudioStreamPlayer3D.new()
			get_parent().add_child(audio_player)
			audio_player.stream = som_coleta
			audio_player.global_position = global_position
			audio_player.play()
			audio_player.finished.connect(audio_player.queue_free)
		
		# Remover a pilha
		queue_free()

func criar_efeito_coleta() -> void:
	"""Cria efeito visual quando a pilha é coletada"""
	# Aumentar brilho temporariamente
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(luz, "light_energy", 8.0, 0.2)
	tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.2)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.3)

func _on_animation_timer_timeout() -> void:
	# Timer para animações suaves (se necessário)
	pass
