extends Node3D

# Sinal para informar mudanças de energia
signal energia_mudou(energia_atual: float, energia_maxima: float)
signal energia_esgotada()
signal energia_critica() # Quando < 20%

# Configurações de Energia
@export var energia_maxima: float = 100.0
@export var energia_atual: float = 100.0
@export var taxa_consumo: float = 5.0 # Energia consumida por segundo
@export var energia_critica_percentual: float = 20.0

# Configurações visuais da luz
@export var intensidade_maxima: float = 10.0
@export var intensidade_minima: float = 0.2
@export var alcance_maximo: float = 20.0
@export var alcance_minimo: float = 5.0

# Estado
var esta_ativa: bool = true
var ja_alertou_critico: bool = false

# Referências
@onready var luz: SpotLight3D = $SpotLight3D
@onready var flicking_sound = $Flicking
@onready var start_flicking_sound = $StartFlicking
@onready var dying_sound = $Dying


func _ready() -> void:
	energia_atual = energia_maxima
	atualizar_intensidade_luz()
	emit_signal("energia_mudou", energia_atual, energia_maxima)

func _process(delta: float) -> void:
	if esta_ativa and energia_atual > 0:
		# Consumir energia
		consumir_energia(taxa_consumo * delta)
		
		# Atualizar intensidade da luz baseado na energia
		atualizar_intensidade_luz()
		
		# Verificar estado crítico
		var percentual: float = (energia_atual / energia_maxima) * 100.0
		if percentual <= energia_critica_percentual and not ja_alertou_critico:
			ja_alertou_critico = true
			emit_signal("energia_critica")
		elif percentual > energia_critica_percentual:
			ja_alertou_critico = false

func consumir_energia(quantidade: float) -> void:
	"""Consome energia da lanterna"""
	energia_atual = max(0.0, energia_atual - quantidade)
	emit_signal("energia_mudou", energia_atual, energia_maxima)
	
	if energia_atual <= 0:
		desativar_lanterna()

func recarregar_energia(quantidade: float) -> void:
	"""Recarrega energia da lanterna"""
	energia_atual = min(energia_maxima, energia_atual + quantidade)
	emit_signal("energia_mudou", energia_atual, energia_maxima)
	
	# Reativar lanterna se estava desativada
	if not esta_ativa and energia_atual > 0:
		ativar_lanterna()
	
	# Para sons:
	start_flicking_sound.stop()
	flicking_sound.stop()
	dying_sound.stop()

func atualizar_intensidade_luz() -> void:
	"""Atualiza intensidade e alcance da luz baseado na energia"""
	var percentual: float = energia_atual / energia_maxima
	
	# Interpolar intensidade
	luz.light_energy = lerp(intensidade_minima, intensidade_maxima, percentual)
	
	# Interpolar alcance
	luz.spot_range = lerp(alcance_minimo, alcance_maximo, percentual)
	
	# Ajustar cor baseado na energia (amarelada quando baixa)
	if percentual < 0.3:
		luz.light_color = Color(1.0, 0.8, 0.5, 1.0) # Amarelada
	elif percentual < 0.6:
		luz.light_color = Color(1.0, 0.9, 0.7, 1.0) # Meio termo
	else:
		luz.light_color = Color(1.0, 0.95, 0.8, 1.0) # Branca
	
	# Efeito de piscar quando muito baixa
	if percentual < 0.15 and percentual > 0:
		var flicker: float = randf_range(0.5, 1.0)
		luz.light_energy *= flicker
		start_flicking()

func desativar_lanterna() -> void:
	"""Desativa a lanterna quando energia acaba"""
	esta_ativa = false
	luz.visible = false
	emit_signal("energia_esgotada")
	
	start_flicking_sound.stop()
	flicking_sound.stop()
	
	dying_sound.play()
	

func ativar_lanterna() -> void:
	"""Ativa a lanterna"""
	esta_ativa = true
	luz.visible = true

func obter_percentual_energia() -> float:
	"""Retorna o percentual de energia (0-100)"""
	return (energia_atual / energia_maxima) * 100.0
	
func start_flicking():
	# Evita spam
	if start_flicking_sound.is_playing() or flicking_sound.is_playing():
		return

	# Toca o som de início
	start_flicking_sound.play()

	# Quando terminar, começa o loop
	start_flicking_sound.finished.connect(
		func():
			# Só toca se ainda houver energia
			if energia_atual > 0 and esta_ativa:
				flicking_sound.play(),
		CONNECT_ONE_SHOT
	)
