extends Area3D

const ITEMS: ItemValues = preload("res://data/items.tres")

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var health = body.get_node("Health")
		if health.hp < health.max_hp:
			health.heal(ITEMS.heart_heal)
			queue_free()
