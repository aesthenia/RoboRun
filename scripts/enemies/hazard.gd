class_name Hazard
extends RigidBody3D

@export var lifetime := 4.0

var landed := false


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var health = body.get_node_or_null("Health")
		if health:
			on_hit_player(health)
		queue_free()
	elif not landed:
		landed = true
		on_landed()


func on_hit_player(health) -> void:
	health.take_damage(1)


func on_landed() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func on_shot() -> void:
	queue_free()
