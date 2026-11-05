extends Area3D

const LOCKED := Color(0.9, 0.3, 0.3)
const OPEN := Color(0.3, 1.0, 0.5)

@onready var ring: MeshInstance3D = $Ring
@onready var label: Label3D = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameManager.coins_changed.connect(_update)


func _update(collected: int, total: int) -> void:
	var open := collected >= total
	var m := StandardMaterial3D.new()
	m.albedo_color = OPEN if open else LOCKED
	m.emission_enabled = true
	m.emission = m.albedo_color
	m.emission_energy_multiplier = 1.5
	ring.material_override = m
	label.text = "ВЫХОД" if open else "ВЫХОД  %d / %d" % [collected, total]
	label.modulate = m.albedo_color


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.all_coins():
		GameManager.level_finished()
	else:
		GameManager.message.emit("Сначала собери все монеты: %d / %d" % [GameManager.coins, GameManager.coins_total])
