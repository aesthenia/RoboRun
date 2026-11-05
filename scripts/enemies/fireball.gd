extends Projectile

func on_hit(body: Node) -> bool:
	if body.is_in_group("player"):
		body.hurt(1, global_position)
		return true
	return not (body is Enemy)
