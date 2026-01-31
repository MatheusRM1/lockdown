extends CharacterBody3D

# Configurações de Movimento
@export var velocidade_caminhada: float = 5.0
@export var velocidade_corrida: float = 8.0
@export var aceleracao: float = 10.0
@export var desaceleracao: float = 15.0

# Configurações de Pulo
@export var forca_pulo: float = 5.0
@export var gravidade: float = 15.0

# Configurações do Mouse
@export var sensibilidade_mouse: float = 0.003
@export var limite_olhar_vertical: float = 89.0

# Referências dos nós
@onready var camera: Camera3D = $Camera3D
@onready var lanterna: Node3D = $Camera3D/Lanterna
@onready var hud: CanvasLayer = $HUD_Jogador

# Constantes para tempo de som
const WALK_STEP_TIME: float = 0.5
const RUN_STEP_TIME: float = 0.3

# Variáveis de controle
var rotacao_camera: float = 0.0
var pode_pular: bool = true
var step_timer: float = 0.0


func _ready() -> void:
	# Captura o mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Conectar sinais da lanterna
	if lanterna:
		lanterna.energia_mudou.connect(_on_lanterna_energia_mudou)
		lanterna.energia_esgotada.connect(_on_lanterna_esgotada)
		lanterna.energia_critica.connect(_on_lanterna_critica)
	
	# Adicionar personagem ao grupo para identificação
	add_to_group("player")
	
	# initialization

func _input(event: InputEvent) -> void:
	# Movimento do mouse para câmera
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotação horizontal (corpo do personagem)
		rotate_y(-event.relative.x * sensibilidade_mouse)
		
		# Rotação vertical (câmera)
		rotacao_camera -= event.relative.y * sensibilidade_mouse
		rotacao_camera = clamp(rotacao_camera, deg_to_rad(-limite_olhar_vertical), deg_to_rad(limite_olhar_vertical))
		camera.rotation.x = rotacao_camera
	
	# Sair do modo captura (ESC)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# Variavel de suporte para som de passos
	var is_running = false
	
	# Aplicar gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta
	
	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and pode_pular:
		velocity.y = forca_pulo
	
	# Obter direção de input
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Calcular direção de movimento baseada na rotação do personagem
	var direcao := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Determinar velocidade alvo (shift para correr)
	var velocidade_alvo: float = velocidade_caminhada
	if Input.is_action_pressed("ui_shift"):
		is_running = true
		velocidade_alvo = velocidade_corrida
	
	# Aplicar movimento com aceleração/desaceleração
	if direcao != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direcao.x * velocidade_alvo, aceleracao * delta)
		velocity.z = lerp(velocity.z, direcao.z * velocidade_alvo, aceleracao * delta)
		step_timer -= delta
		if step_timer <= 0 :
			$"Foot Steps".play()
			step_timer = RUN_STEP_TIME if is_running else WALK_STEP_TIME
	else:
		step_timer = 0
		velocity.x = lerp(velocity.x, 0.0, desaceleracao * delta)
		velocity.z = lerp(velocity.z, 0.0, desaceleracao * delta)
	
	# Aplicar movimento
	move_and_slide()

func obter_objeto_olhado() -> Object:
	"""Retorna o objeto que está sendo apontado pela câmera"""
	var raycast: RayCast3D = $Camera3D/RayCast3D
	if raycast.is_colliding():
		return raycast.get_collider()
	return null

func obter_energia_lanterna() -> float:
	"""Retorna o percentual de energia da lanterna"""
	if lanterna and lanterna.has_method("obter_percentual_energia"):
		return lanterna.obter_percentual_energia()
	return 0.0

# Callbacks da lanterna
func _on_lanterna_energia_mudou(energia_atual: float, energia_maxima: float) -> void:
	# Atualizar HUD
	if hud and hud.has_method("atualizar_energia"):
		hud.atualizar_energia(energia_atual, energia_maxima)

func _on_lanterna_esgotada() -> void:
	print("Lanterna esgotada! Procure pilhas!")
	# Adicionar feedback visual/sonoro aqui

func _on_lanterna_critica() -> void:
	print("Energia da lanterna crítica!")
	# Mostrar alerta no HUD
	if hud and hud.has_method("mostrar_alerta_critico"):
		hud.mostrar_alerta_critico()

func die(killer: Node3D = null) -> void:
	"""Chamado quando o jogador morre"""
	# Desabilitar controle
	set_physics_process(false)
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Apagar Lanterna
	lanterna.consumir_energia(lanterna.energia_maxima)
	
	# Virar para o killer
	if killer and camera:
		var killer_center = killer.global_position + Vector3(0, 1.0, 0)
		
		# Fazer o personagem olhar para o killer
		var look_target = Vector3(killer.global_position.x, global_position.y, killer.global_position.z)
		look_at(look_target, Vector3.UP)
		
		# Resetar câmera e fazer ela olhar para o centro do killer
		camera.rotation = Vector3.ZERO
		var cam_pos = camera.global_position
		var dir_to_killer = (killer_center - cam_pos).normalized()
		
		# Calcular pitch (olhar cima/baixo) em coordenadas locais da câmera
		var horizontal_dist = sqrt(pow(killer_center.x - cam_pos.x, 2) + pow(killer_center.z - cam_pos.z, 2))
		var vertical_diff = killer_center.y - cam_pos.y
		var pitch = -atan2(vertical_diff, horizontal_dist)
		
		# Animar a câmera olhando para o killer
		var tween = create_tween()
		tween.tween_property(camera, "rotation:x", pitch, 0.3)
		await tween.finished
		
		# Tocar animação de ataque do killer
		killer.kill_player()
	
	# Efeito de morte (FOV aumenta) - começar logo após câmera
	if camera:
		var tween_fov = create_tween()
		tween_fov.tween_property(camera, "fov", 120.0, 0.8)
	
	# Aguardar um pouco e ir para tela de game over
	await get_tree().create_timer(1.5).timeout
	
	# Verificar se ainda está na árvore antes de trocar cena
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/end_game.tscn")
