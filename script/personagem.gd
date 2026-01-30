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

# Variáveis de controle
var rotacao_camera: float = 0.0
var pode_pular: bool = true

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
	
	# Debug
	print("========== PERSONAGEM INICIADO ==========")
	print("  Nome: ", name)
	print("  Grupos: ", get_groups())
	print("  Collision Layer: ", collision_layer)
	print("  Collision Mask: ", collision_mask)
	print("  Posição: ", global_position)

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
		velocidade_alvo = velocidade_corrida
	
	# Aplicar movimento com aceleração/desaceleração
	if direcao != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direcao.x * velocidade_alvo, aceleracao * delta)
		velocity.z = lerp(velocity.z, direcao.z * velocidade_alvo, aceleracao * delta)
	else:
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

func die() -> void:
	"""Chamado quando o jogador morre"""
	print("========== JOGADOR MORREU ==========")
	print("die() foi chamado pelo killer!")
	
	# Desabilitar controle
	set_physics_process(false)
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Efeito de morte (opcional)
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "fov", 120.0, 0.5)
	
	# Aguardar um pouco e reiniciar
	print("Reiniciando em 2 segundos...")
	await get_tree().create_timer(2.0).timeout
	print("Recarregando cena...")
	get_tree().reload_current_scene()
