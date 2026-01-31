extends Node3D

@onready var chest_top = $"Armature/Skeleton3D/Chest_Top"
@onready var label = $InteractionArea/Label3D

const OPEN_ANGLE = -1.5
const SPEED = 2.0
const AUTO_CLOSE = 5.0

var is_open = false
var rotation_angle = 0.0
var close_timer = 0.0
var player_nearby = false
var start_transform: Transform3D
var chave_instancia: Node3D = null

func _ready():
	$InteractionArea.body_entered.connect(func(b): if b.is_in_group("player"): player_nearby = true)
	$InteractionArea.body_exited.connect(func(b): if b.is_in_group("player"): player_nearby = false)
	label.visible = false
	start_transform = chest_top.transform

func definir_chave(chave: Node3D) -> void:
	"""Método chamado pelo ChaveManager para adicionar a chave dentro deste baú"""
	chave_instancia = chave
	add_child(chave_instancia)
	# Torna a chave invisível até o baú abrir
	chave_instancia.visible = false

func _process(delta):
	# Atualiza o texto do label baseado no estado do baú e se tem chave
	if player_nearby:
		if is_open and chave_instancia and not ChaveManager.chave_coletada:
			label.text = "Aperte V para pegar a chave"
			label.visible = true
		else:
			label.text = "Aperte E para abrir"
			label.visible = true
	else:
		label.visible = false
	
	# Mostra/esconde a chave quando o baú abre/fecha
	if chave_instancia and not ChaveManager.chave_coletada:
		chave_instancia.visible = is_open
	
	# Abre/fecha o baú com E
	if player_nearby and Input.is_action_just_pressed("interact"):
		is_open = not is_open
		close_timer = 0.0
	
	# Coleta a chave com V (apenas se o baú estiver aberto e tiver a chave)
	if player_nearby and is_open and Input.is_physical_key_pressed(KEY_V) and chave_instancia and not ChaveManager.chave_coletada:
		ChaveManager.coletar_chave(chave_instancia)
		chave_instancia = null
	
	var target = OPEN_ANGLE if is_open else 0.0
	rotation_angle = move_toward(rotation_angle, target, delta * SPEED)
	chest_top.transform = start_transform.rotated_local(Vector3.RIGHT, rotation_angle)
	
	if is_open and rotation_angle == OPEN_ANGLE:
		close_timer += delta
		if close_timer >= AUTO_CLOSE:
			is_open = false
