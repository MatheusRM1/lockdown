extends Node

signal pilha_coletada
signal pilha_spawnada

@export var quantidade_pilhas: int = 2

var spawn_points: Array[Node3D] = []
var pilhas_ativas: Array[Node3D] = []
var nivel_atual: Node3D = null

func registrar_spawn_point(ponto: Node3D) -> void:
	if ponto not in spawn_points:
		spawn_points.append(ponto)
		print("Spawn point registrado: ", ponto.name)

func desregistrar_spawn_point(ponto: Node3D) -> void:
	spawn_points.erase(ponto)

func iniciar_spawns(nivel: Node3D) -> void:
	nivel_atual = nivel
	print("Iniciando spawns. Spawn points: ", spawn_points.size())
	for i in quantidade_pilhas:
		spawnar_pilha()

func spawnar_pilha() -> void:
	if pilhas_ativas.size() >= quantidade_pilhas:
		return
	
	if spawn_points.is_empty():
		push_warning("Nenhum spawn point disponível!")
		return
	
	var ponto = obter_spawn_point_livre()
	if not ponto:
		push_warning("Nenhum spawn point livre!")
		return
	
	var pilha_scene = load("res://scenes/pilha.tscn")
	if not pilha_scene:
		push_error("Erro ao carregar pilha.tscn")
		return
	
	var pilha = pilha_scene.instantiate()
	
	# Adicionar ao nível atual ou ao pai do spawn point
	if nivel_atual:
		nivel_atual.add_child(pilha)
	else:
		get_tree().current_scene.add_child(pilha)
	
	pilha.global_position = ponto.global_position
	print("Pilha spawnada em: ", pilha.global_position)
	
	pilhas_ativas.append(pilha)
	ponto.set_meta("ocupado", true)
	pilha.set_meta("spawn_point", ponto)
	
	pilha.tree_exiting.connect(func(): _on_pilha_removida(pilha))
	pilha_spawnada.emit()

func obter_spawn_point_livre() -> Node3D:
	var pontos_livres: Array[Node3D] = []
	
	for ponto in spawn_points:
		if is_instance_valid(ponto) and not ponto.get_meta("ocupado", false):
			pontos_livres.append(ponto)
	
	if pontos_livres.is_empty():
		return null
	
	return pontos_livres.pick_random()

func _on_pilha_removida(pilha: Node3D) -> void:
	pilhas_ativas.erase(pilha)
	
	var ponto = pilha.get_meta("spawn_point", null)
	if ponto and is_instance_valid(ponto):
		ponto.set_meta("ocupado", false)
	
	pilha_coletada.emit()
	call_deferred("spawnar_pilha")

func set_quantidade(qtd: int) -> void:
	quantidade_pilhas = qtd
