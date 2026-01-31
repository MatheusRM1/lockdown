extends Node

# Referência para o baú que contém a chave
var bau_com_chave: Node3D = null
var chave_coletada: bool = false

# Cena da chave
const CHAVE_SCENE = "res://scenes/key.tscn"

func _ready() -> void:
	# Aguarda a cena carregar completamente
	await get_tree().create_timer(1.0).timeout
	spawnar_chave_aleatoria()

func spawnar_chave_aleatoria() -> void:
	# Busca a cena principal
	var root = get_tree().current_scene
	if not root:
		push_error("Cena principal não encontrada!")
		return
	
	# Busca todos os baús na cena (nós que começam com "Chest")
	var baus: Array[Node] = []
	for child in root.get_children():
		if child.name.begins_with("Chest"):
			baus.append(child)
	
	if baus.is_empty():
		push_error("Nenhum baú foi encontrado na cena!")
		return
	
	# Escolhe um baú aleatório
	bau_com_chave = baus.pick_random()
	print("Chave vai spawnar no baú: ", bau_com_chave.name)
	
	# Carrega e instancia a chave
	var chave_scene = ResourceLoader.load(CHAVE_SCENE)
	if not chave_scene:
		push_error("Não foi possível carregar a cena da chave!")
		return
	
	var chave_instancia = chave_scene.instantiate()
	
	# Posiciona a chave dentro do baú (acima do fundo)
	chave_instancia.position = Vector3(0, 0.3, 0)
	# Diminui o tamanho da chave para caber no baú
	chave_instancia.scale = Vector3(0.15, 0.15, 0.15)
	
	# Notifica o baú que ele recebeu a chave
	if bau_com_chave.has_method("definir_chave"):
		bau_com_chave.definir_chave(chave_instancia)
		print("Chave adicionada ao ", bau_com_chave.name, "!")

func bau_tem_chave(bau: Node3D) -> bool:
	return bau == bau_com_chave and not chave_coletada

func coletar_chave(chave_node: Node3D) -> void:
	if not chave_coletada:
		chave_coletada = true
		GameState.set_meta("tem_chave", true)
		
		# Remove a chave da cena
		if chave_node:
			chave_node.queue_free()
		
		# Notifica o HUD para mostrar a mensagem
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("mostrar_mensagem_chave"):
			hud.mostrar_mensagem_chave()
		
		print("Chave coletada!")
