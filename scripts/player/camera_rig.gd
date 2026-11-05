extends Node3D

@export var target: Node3D
@export var mouse_sensitivity := 0.003
@export var follow_speed := 10.0

@onready var pitch: SpringArm3D = $Pitch


func _ready() -> void:
	if target:
		global_position = target.global_position
		if target is CollisionObject3D:
			pitch.add_excluded_object(target.get_rid())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.device != InputEvent.DEVICE_ID_EMULATION \
			and Input.is_action_pressed("camera_look"):
		look(event.relative)
	elif event is InputEventScreenDrag:
		look(event.relative)


func look(rel: Vector2) -> void:
	rotate_y(-rel.x * mouse_sensitivity)
	pitch.rotation.x = clamp(pitch.rotation.x - rel.y * mouse_sensitivity,
			deg_to_rad(-70), deg_to_rad(-5))


func _physics_process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, clamp(follow_speed * delta, 0.0, 1.0))
