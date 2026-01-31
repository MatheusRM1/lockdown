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

func _ready():
	$InteractionArea.body_entered.connect(func(b): if b.is_in_group("player"): player_nearby = true)
	$InteractionArea.body_exited.connect(func(b): if b.is_in_group("player"): player_nearby = false)
	label.visible = false
	start_transform = chest_top.transform

func _process(delta):
	label.visible = player_nearby
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		is_open = not is_open
		close_timer = 0.0
	
	var target = OPEN_ANGLE if is_open else 0.0
	rotation_angle = move_toward(rotation_angle, target, delta * SPEED)
	chest_top.transform = start_transform.rotated_local(Vector3.RIGHT, rotation_angle)
	
	if is_open and rotation_angle == OPEN_ANGLE:
		close_timer += delta
		if close_timer >= AUTO_CLOSE:
			is_open = false
