extends CanvasLayer

# Referências dos nós
@onready var barra_energia: TextureProgressBar = $Control/TextureProgressBar

func _ready() -> void:
	pass
	
func atualizar_energia(energia_atual: float, energia_maxima: float) -> void:
	"""Atualiza a barra de energia da lanterna"""
	var percentual: float = (energia_atual / energia_maxima) * 100.0
	
	# Atualizar barra
	barra_energia.value = percentual

func mostrar_alerta_critico() -> void:
	"""Mostra alerta de bateria crítica"""
	pass

func esconder_alerta_critico() -> void:
	"""Esconde alerta de bateria crítica"""
	pass
