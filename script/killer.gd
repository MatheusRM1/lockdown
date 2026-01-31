extends CharacterBody3D

# Estados da IA
enum State {
	IDLE,
	PATROL,
	CHASE,
	STUNNED
}

# Configurações
@export var move_speed: float = 3.5
@export var chase_speed: float = 9
@export var detection_range: float = 55.0
@export var kill_range: float = 1.5
@export var stun_duration: float = 1.0
@export var light_sensitivity: float = 0.3
@export var debug_mode: bool = false
# Referências
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var vision_timer: Timer = $VisionTimer
@onready var stun_particles: CPUParticles3D = $StunParticles
@onready var anim_player: AnimationPlayer = $PSX_BagMan/AnimationPlayer

# Estado
var current_state: State = State.IDLE
var target_player: Node3D = null
var stun_timer: float = 0.0
var is_lit_by_flashlight: bool = false
var last_known_player_pos: Vector3 = Vector3.ZERO

func _ready():
	# Conectar sinais
	detection_area.body_entered.connect(_on_body_entered_detection)
	detection_area.body_exited.connect(_on_body_exited_detection)
	
	if vision_timer:
		vision_timer.timeout.connect(_on_vision_check)
	
	# Configurar navegação
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# Iniciar animação Idle
	if anim_player:
		anim_player.play("Idle")
	
	# Aguardar o NavigationServer ficar pronto
	call_deferred("_setup_navigation")

func _setup_navigation():
	# Aguardar NavigationServer ficar pronto
	await get_tree().create_timer(0.5).timeout
	# navigation ready
	# S\u00f3 iniciar PATROL se ainda estiver IDLE
	if current_state == State.IDLE:
		set_state(State.PATROL)

func _physics_process(delta: float):
	# Verificar se está pausado (porta abrindo)
	if GameState.get_meta("killer_pausado", false):
		velocity = Vector3.ZERO
		if anim_player and anim_player.current_animation != "Idle":
			anim_player.play("Idle")
		return
	
	# Máquina de estados
	match current_state:
		State.IDLE:
			_idle_behavior(delta)
		State.PATROL:
			_patrol_behavior(delta)
		State.CHASE:
			_chase_behavior(delta)
		State.STUNNED:
			_stunned_behavior(delta)
	
	# Aplicar movimento
	move_and_slide()

func _idle_behavior(_delta: float):
	velocity = Vector3.ZERO

func _patrol_behavior(_delta: float):
	# Se tem target_player, deveria estar perseguindo!
	if is_instance_valid(target_player):
		# detected target in patrol
		set_state(State.CHASE)
		return
	
	# Patrulha simples - pode ser expandida com waypoints
	if nav_agent.is_navigation_finished():
		# Escolher ponto aleatório próximo
		var random_point = global_position + Vector3(
			randf_range(-10, 10),
			0,
			randf_range(-10, 10)
		)
		nav_agent.target_position = random_point
		# new patrol point selected
	
	_move_towards_target(move_speed * 0.5)

func _chase_behavior(_delta: float):
	if not is_instance_valid(target_player):
		# lost sight of player
		set_state(State.PATROL)
		return
	
	# Verificar distância para matar PRIMEIRO
	var distance = global_position.distance_to(target_player.global_position)
	# distance debug removed
	
	if distance <= kill_range:
		_kill_player()
		return
	
	# Verificar se está sendo iluminado
	if is_lit_by_flashlight:
		set_state(State.STUNNED)
		return
	
	# Atualizar posição do jogador
	last_known_player_pos = target_player.global_position
	
	# Perseguir
	nav_agent.target_position = target_player.global_position
	_move_towards_target(chase_speed)
	
	# Olhar para o jogador
	_look_at_target(target_player.global_position)

func _stunned_behavior(_delta: float):
	velocity = Vector3.ZERO
	
	# Verificar se ainda est\u00e1 iluminado
	if not is_lit_by_flashlight:
		if is_instance_valid(target_player):
			set_state(State.CHASE)
		else:
			set_state(State.PATROL)

func _move_towards_target(speed: float):
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	var desired_velocity = direction * speed
	nav_agent.velocity = desired_velocity

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity

func _look_at_target(target_pos: Vector3):
	var look_pos = Vector3(target_pos.x, global_position.y, target_pos.z)
	look_at(look_pos, Vector3.UP)

func _on_body_entered_detection(body: Node3D):
	if body.is_in_group("player"):
		target_player = body
		if current_state != State.STUNNED:
			set_state(State.CHASE)

func _on_body_exited_detection(body: Node3D):
	if body == target_player:
		target_player = null
		if current_state == State.CHASE:
			set_state(State.PATROL)

func _on_vision_check():
	# Verificar se está sendo iluminado pela lanterna
	check_flashlight_exposure()

func check_flashlight_exposure():
	if not is_instance_valid(target_player):
		is_lit_by_flashlight = false
		return
	
	# Buscar lanterna do jogador (SpotLight3D dentro da lanterna.tscn)
	var flashlight = _find_flashlight(target_player)
	if not flashlight or not flashlight.visible:
		is_lit_by_flashlight = false
		return
	
	# Verificar se a luz está apontando para o killer
	var to_killer = (global_position - flashlight.global_position).normalized()
	var flashlight_forward = - flashlight.global_transform.basis.z
	
	var angle = to_killer.dot(flashlight_forward)
	var distance = global_position.distance_to(flashlight.global_position)
	
	# Se está no cone de luz e próximo o suficiente
	if angle > 0.65 and distance < 12.0:
		# Raycast para verificar linha de visão
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			flashlight.global_position,
			global_position + Vector3(0, 1, 0)
		)
		query.exclude = [target_player]
		
		var result = space_state.intersect_ray(query)
		
		if result and result.collider == self:
			is_lit_by_flashlight = true
			is_lit_by_flashlight = true
			if current_state == State.CHASE:
				set_state(State.STUNNED)
		else:
			is_lit_by_flashlight = false
	else:
		is_lit_by_flashlight = false

func _find_flashlight(player: Node3D) -> SpotLight3D:
	# Buscar SpotLight3D dentro de Camera3D/Lanterna
	for child in player.get_children():
		if child is Camera3D:
			for cam_child in child.get_children():
				# Lanterna é Node3D que contém SpotLight3D
				if cam_child.name == "Lanterna":
					for light in cam_child.get_children():
						if light is SpotLight3D:
							return light
	return null

func set_state(new_state: State):
	if current_state == new_state:
		return

	# Sair do estado anterior
	match current_state:
		State.STUNNED:
			stun_particles.emitting = false

	current_state = new_state

	# Entrar no novo estado e tocar animação
	match new_state:
		State.IDLE:
			if anim_player:
				anim_player.play("Idle")
		State.PATROL:
			nav_agent.max_speed = move_speed * 0.5
			if anim_player:
				anim_player.play("Walk")
		State.CHASE:
			nav_agent.max_speed = chase_speed
			if anim_player:
				anim_player.play("Run")
		State.STUNNED:
			stun_particles.emitting = true
			velocity = Vector3.ZERO
			if anim_player:
				anim_player.play("Idle")

func _kill_player():
		# Não pode matar se a porta está abrindo
		if GameState.get_meta("killer_pausado", false):
			return
		
		# Parar de se mover
		velocity = Vector3.ZERO

		if is_instance_valid(target_player):
			if target_player.has_method("die"):
				target_player.die(self )
			else:
				get_tree().reload_current_scene()
		else:
			# target invalid
			pass
		# target_player invalid
