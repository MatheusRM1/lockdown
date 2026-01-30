extends CanvasLayer

# Referências dos nós
@onready var barra_energia: TextureProgressBar = $Control/TextureProgressBar

func _ready() -> void:
	pass
	
func atualizar_energia(energia_atual: float, energia_maxima: float) -> void:
	var percentual: float = (energia_atual / energia_maxima) * 100.0
	
	barra_energia.value = percentual
