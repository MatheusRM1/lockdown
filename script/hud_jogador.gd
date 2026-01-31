extends CanvasLayer

# Referências dos nós
@onready var barra_energia: TextureProgressBar = $Control/TextureProgressBar
@onready var mensagem_chave: Label = $Control/MensagemChave

func _ready() -> void:
	add_to_group("hud")
	if mensagem_chave:
		mensagem_chave.visible = false
	
func atualizar_energia(energia_atual: float, energia_maxima: float) -> void:
	var percentual: float = (energia_atual / energia_maxima) * 100.0
	
	barra_energia.value = percentual

func mostrar_mensagem_chave() -> void:
	if mensagem_chave:
		mensagem_chave.visible = true
