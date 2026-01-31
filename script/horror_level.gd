extends Node3D

func _ready():
	# Aguardar um frame para os spawn points se registrarem
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Iniciar spawn de pilhas
	if has_node("/root/PilhaManager"):
		PilhaManager.iniciar_spawns(self )
		print("PilhaManager iniciado")
	
	# Spawnar a chave no Chest1
	if has_node("/root/ChaveManager"):
		ChaveManager.spawnar_chave_aleatoria()
		print("ChaveManager iniciado")
		
	# Iniciar Som
	$AudioStreamPlayer3D.stream.loop = true
	$AudioStreamPlayer3D.stream.loop_offset = 0.5
