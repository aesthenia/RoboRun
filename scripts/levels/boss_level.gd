extends "res://scripts/levels/level.gd"

@onready var boss = $Boss


func _ready() -> void:
	super()
	$HUD.show_boss(boss)
	$ArenaTrigger.body_entered.connect(_on_arena_entered)


func _on_arena_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not boss.active and boss.hp > 0:
		boss.start_fight()
