class_name Enemy
extends AnimatableBody3D

signal hp_changed(hp: int, max_hp: int)
signal died

@export var max_hp := 2
@export var contact_damage := 1

var hp := 0


func _ready() -> void:
	hp = max_hp


func take_hit(dmg: int) -> void:
	if hp <= 0:
		return
	hp = max(hp - dmg, 0)
	hp_changed.emit(hp, max_hp)
	flash()
	if hp <= 0:
		died.emit()
		on_death()
	else:
		on_hurt()


func on_hurt() -> void:
	Audio.play("boss_hit", -6.0)


func on_death() -> void:
	Audio.play("explosion")
	queue_free()


func flash() -> void:
	var m := get_node_or_null("Model") as Node3D
	if m == null:
		return
	var tw := create_tween()
	tw.tween_property(m, "scale", m.scale * 0.85, 0.06)
	tw.tween_property(m, "scale", m.scale, 0.1)
