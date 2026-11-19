extends Node

signal changed(hp: int)
signal died

@export var blink_target: Node3D

var max_hp := 1
var hp := 1
var stats: PlayerStats
var invincible := false


func setup(s: PlayerStats) -> void:
	stats = s
	max_hp = s.max_hp
	hp = max_hp


func take_damage(dmg: int) -> void:
	if invincible or hp <= 0:
		return
	hp = max(hp - dmg, 0)
	changed.emit(hp)
	Audio.play("hurt")
	if hp <= 0:
		died.emit()
		return
	invincibility()


func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)
	changed.emit(hp)
	Audio.play("heal")


func invincibility() -> void:
	invincible = true
	for i in int(stats.invincibility_time / stats.blink_interval):
		if not is_inside_tree():
			return
		blink_target.visible = not blink_target.visible
		await get_tree().create_timer(stats.blink_interval).timeout
	blink_target.visible = true
	invincible = false
