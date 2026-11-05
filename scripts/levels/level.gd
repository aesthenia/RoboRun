extends Node3D

func _ready() -> void:
	get_tree().paused = false
	GameManager.start_level(get_tree().get_nodes_in_group("coin").size())
	$HUD.setup($Player, GameManager.level_name())
	Audio.play_music()
