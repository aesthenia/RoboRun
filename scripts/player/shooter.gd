extends Node

@export var bullet_scene: PackedScene
@export var cooldown := 0.3

var next_shot := 0.0
var firing := false

@onready var player: RigidBody3D = get_parent()


func _unhandled_input(event: InputEvent) -> void:
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event.is_action("fire"):
		firing = event.is_pressed()


func _process(_delta: float) -> void:
	if firing and not Input.is_action_pressed("fire"):
		firing = false
	var now := Time.get_ticks_msec() / 1000.0
	if firing and now >= next_shot and not player.dead:
		next_shot = now + cooldown
		shoot()


func shoot() -> void:
	var dir: Vector3 = player.model.global_basis.z
	dir.y = 0.0
	dir = dir.normalized()
	var bullet: Projectile = bullet_scene.instantiate()
	bullet.direction = dir
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = player.global_position + dir * 0.7 + Vector3.UP * 0.9
	Audio.play("shoot", -4.0)
