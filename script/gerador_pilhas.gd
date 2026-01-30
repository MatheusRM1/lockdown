extends Node3D
class_name GeradorPilhas

# Configurações de Spawn
@export var pilha_scene: PackedScene  # Arraste a cena pilha.tscn aqui
@export var quantidade_inicial: int = 5
@export var quantidade_maxima: int = 10
@export var intervalo_spawn: float = 30.0  # Segundos entre spawns
@export var raio_spawn: float = 20.0  # Raio de spawn ao redor do spawn point

# Áreas de spawn (marcar pontos no mapa)
@export var areas_spawn: Array[Vector3] = []

# Timer interno
var timer_spawn: Timer
var pilhas_ativas: Array[Node3D] = []

func _ready() -> void:
	# Criar timer para spawns periódicos
	timer_spawn = Timer.new()
	add_child(timer_spawn)
	timer_spawn.wait_time = intervalo_spawn
	timer_spawn.timeout.connect(_on_spawn_timer_timeout)
	timer_spawn.start()
	
	# Spawnar pilhas iniciais
	for i in quantidade_inicial:
		spawnar_pilha()

func spawnar_pilha() -> void:
	"""Spawna uma pilha em posição aleatória"""
	if pilhas_ativas.size() >= quantidade_maxima:
		return
	
	if not pilha_scene:
		push_error("Pilha scene não configurada no GeradorPilhas!")
		return
	
	var posicao: Vector3
	
	# Se há áreas de spawn definidas, usar uma delas
	if areas_spawn.size() > 0:
		var area_base: Vector3 = areas_spawn.pick_random()
		posicao = obter_posicao_aleatoria_ao_redor(area_base, raio_spawn)
	else:
		# Caso contrário, spawnar ao redor do próprio gerador
		posicao = obter_posicao_aleatoria_ao_redor(global_position, raio_spawn)
	
	# Instanciar pilha
	var pilha: Node3D = pilha_scene.instantiate()
	get_parent().add_child(pilha)
	pilha.global_position = posicao
	
	# Adicionar à lista de pilhas ativas
	pilhas_ativas.append(pilha)
	
	# Remover da lista quando for destruída
	pilha.tree_exiting.connect(func(): remover_pilha_da_lista(pilha))

func obter_posicao_aleatoria_ao_redor(centro: Vector3, raio: float) -> Vector3:
	"""Retorna uma posição aleatória ao redor de um ponto"""
	var angulo: float = randf() * TAU
	var distancia: float = randf() * raio
	
	var offset := Vector3(
		cos(angulo) * distancia,
		0,
		sin(angulo) * distancia
	)
	
	return centro + offset

func remover_pilha_da_lista(pilha: Node3D) -> void:
	"""Remove pilha da lista de pilhas ativas"""
	var index := pilhas_ativas.find(pilha)
	if index >= 0:
		pilhas_ativas.remove_at(index)

func _on_spawn_timer_timeout() -> void:
	"""Callback do timer - spawna nova pilha periodicamente"""
	spawnar_pilha()

func adicionar_area_spawn(posicao: Vector3) -> void:
	"""Adiciona uma nova área de spawn"""
	areas_spawn.append(posicao)

func limpar_todas_pilhas() -> void:
	"""Remove todas as pilhas do mapa"""
	for pilha in pilhas_ativas:
		if is_instance_valid(pilha):
			pilha.queue_free()
	pilhas_ativas.clear()
