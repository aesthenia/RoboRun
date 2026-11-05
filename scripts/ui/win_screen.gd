extends Node3D

func _ready() -> void:
	get_tree().paused = false
	var ap: AnimationPlayer = $Robot/AnimationPlayer
	ap.get_animation("Dance").loop_mode = Animation.LOOP_LINEAR
	ap.play("Dance")
	%Result.text = "Каменный король повержен!\nМонет собрано: %d" % GameManager.coins_run
	%BtnMenu.pressed.connect(func(): Audio.play("click"); GameManager.to_menu())
	%BtnMenu.grab_focus()
	Audio.play("win")
