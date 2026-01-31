extends StaticBody3D

@export var destino_scene: String = "" # Cena para onde a porta leva
@export var requer_chave: bool = true

@onready var label = $InteractionArea/Label3D
@onready var collision = $CollisionShape3D

var player_nearby: bool = false

func _ready():
	if label:
		label.visible = false

func _process(_delta):
	if label:
		if requer_chave:
			var tem_chave = false
			if has_node("/root/GameState"):
				tem_chave = GameState.get_meta("tem_chave", false)
			
			if tem_chave:
				label.text = "Aperte E para abrir"
			else:
				label.text = "Precisa de uma chave"
		else:
			label.text = "Aperte E para abrir"
		
		label.visible = player_nearby
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		tentar_abrir()

func _on_interaction_area_entered(body: Node3D):
	if body.name == "Personagem" or body.is_in_group("player"):
		player_nearby = true

func _on_interaction_area_exited(body: Node3D):
	if body.name == "Personagem" or body.is_in_group("player"):
		player_nearby = false

func tentar_abrir():
	if requer_chave:
		var tem_chave = false
		if has_node("/root/GameState"):
			tem_chave = GameState.get_meta("tem_chave", false)
		
		if not tem_chave:
			print("Porta trancada! Precisa de uma chave.")
			return
	
	abrir_porta()

func abrir_porta():
	print("Porta aberta!")
	
	if destino_scene.is_empty():
		print("Nenhum destino configurado para esta porta")
		return
	
	# Trocar de cena
	get_tree().change_scene_to_file(destino_scene)
