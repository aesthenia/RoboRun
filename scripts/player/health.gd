extends Node

signal changed(hp: int)
signal died

@export var max_hp := 3
@export var blink_target: Node3D

var hp := 3
var invincible := false


func _ready() -> void:
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
	for i in 10:
		if not is_inside_tree():
			return
		blink_target.visible = not blink_target.visible
		await get_tree().create_timer(0.2).timeout
	blink_target.visible = true
	invincible = false
