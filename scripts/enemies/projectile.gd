class_name Projectile
extends Area3D

@export var speed := 18.0
@export var lifetime := 3.0

var direction := Vector3.FORWARD


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	if on_hit(body):
		queue_free()


func on_hit(_body: Node) -> bool:
	return true
