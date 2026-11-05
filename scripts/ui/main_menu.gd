extends Node3D

func _ready() -> void:
	get_tree().paused = false
	var ap: AnimationPlayer = $Robot/AnimationPlayer
	ap.get_animation("Dance").loop_mode = Animation.LOOP_LINEAR
	ap.play("Dance")
	%BtnPlay.pressed.connect(func(): Audio.play("click"); GameManager.start_game())
	%BtnQuit.pressed.connect(func(): get_tree().quit())
	%BtnPlay.grab_focus()
	Audio.play_music()
