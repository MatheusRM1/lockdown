extends Node

# Referência para o baú que contém a chave
var bau_com_chave: Node3D = null
var chave_coletada: bool = false

# Cena da chave
const CHAVE_SCENE = "res://scenes/key.tscn"

func _ready() -> void:
	# Não faz nada aqui - será chamado pela cena principal
	pass

func spawnar_chave_aleatoria() -> void:
	# Busca o Chest1 na árvore de nós
	bau_com_chave = get_tree().root.find_child("Chest1", true, false)
	
	if not bau_com_chave:
		push_error("Chest1 não foi encontrado na cena!")
		return
	
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
