extends Projectile

@export var max_range := 11.0


func _ready() -> void:
	lifetime = max_range / speed
	super()


func on_hit(body: Node) -> bool:
	if body.is_in_group("player"):
		return false
	if body is Enemy:
		body.take_hit(1)
	elif body is Hazard:
		body.on_shot()
	return true
