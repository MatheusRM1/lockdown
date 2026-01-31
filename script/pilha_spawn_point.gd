@tool
extends Marker3D
class_name PilhaSpawnPoint

## Ponto de spawn para pilhas
## Adicione este nó nas salas onde pilhas podem aparecer

@export var sala_id: String = "" # Identificador da sala (opcional)

func _ready():
	if Engine.is_editor_hint():
		return
	
	# Registrar no manager
	if has_node("/root/PilhaManager"):
		PilhaManager.registrar_spawn_point(self )

func _exit_tree():
	if Engine.is_editor_hint():
		return
	
	if has_node("/root/PilhaManager"):
		PilhaManager.desregistrar_spawn_point(self )

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if sala_id.is_empty():
		warnings.append("Defina um sala_id para identificar a sala deste spawn point")
	return warnings
