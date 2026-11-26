extends Node3D

@onready var level_grid: GridContainer = %LevelGrid
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider


func _ready() -> void:
	get_tree().paused = false
	var ap: AnimationPlayer = $Robot/AnimationPlayer
	ap.get_animation("Dance").loop_mode = Animation.LOOP_LINEAR
	ap.play("Dance")
	%BtnPlay.pressed.connect(_open.bind(%LevelPanel))
	%BtnSettings.pressed.connect(_open.bind(%SettingsPanel))
	%BtnQuit.pressed.connect(_quit)
	%BtnLevelsBack.pressed.connect(_close.bind(%LevelPanel))
	%BtnSettingsBack.pressed.connect(_close_settings)
	%BtnReset.pressed.connect(_ask_reset)
	%BtnCancel.pressed.connect(_close.bind(%ConfirmPanel))
	%BtnDelete.pressed.connect(_confirm_reset)
	music_slider.value = SaveManager.data.music_volume
	sfx_slider.value = SaveManager.data.sfx_volume
	music_slider.value_changed.connect(SaveManager.set_music_volume)
	sfx_slider.value_changed.connect(SaveManager.set_sfx_volume)
	music_slider.drag_ended.connect(func(_c): SaveManager.save())
	sfx_slider.drag_ended.connect(func(_c): SaveManager.save(); Audio.play("click"))
	_build_level_buttons()
	%BtnPlay.grab_focus()
	Audio.play_music("menu")


func _build_level_buttons() -> void:
	for c in level_grid.get_children():
		c.queue_free()
	for i in GameManager.level_count():
		var level: LevelData = GameManager.campaign.levels[i]
		var number := i + 1
		var open := SaveManager.data.is_unlocked(number)
		var best := SaveManager.data.best_score(number)
		var b := Button.new()
		b.custom_minimum_size = Vector2(620, 150)
		b.disabled = not open
		var status := "Закрыто"
		if open:
			status = "Рекорд: %d" % best if best > 0 else "Не пройден"
		b.text = "%s\n%s" % [level.title, status]
		b.pressed.connect(_start_level.bind(i))
		level_grid.add_child(b)


func _start_level(index: int) -> void:
	Audio.play("click")
	GameManager.play_level(index)


func _open(panel: Control) -> void:
	Audio.play("click")
	panel.show()
	var first := panel.find_children("*", "Button", true, false)
	for b in first:
		if not b.disabled:
			b.grab_focus()
			break


func _close(panel: Control) -> void:
	Audio.play("click")
	panel.hide()


func _close_settings() -> void:
	SaveManager.save()
	_close(%SettingsPanel)


func _ask_reset() -> void:
	var d := SaveManager.data
	var top := 1
	for n in d.unlocked_levels:
		top = maxi(top, n)
	if d.total_best() > 0 or top > 1:
		%ConfirmText.text = "Рекорды (всего %d очков) и открытые уровни 1–%d будут удалены. Настройки звука вернутся к исходным. Это нельзя отменить." % [d.total_best(), top]
	else:
		%ConfirmText.text = "Прогресса пока нет. Всё равно сбросить настройки?"
	_open(%ConfirmPanel)
	%BtnCancel.grab_focus()


func _confirm_reset() -> void:
	Audio.play("click")
	SaveManager.reset_progress()
	get_tree().reload_current_scene()


func _quit() -> void:
	SaveManager.save()
	get_tree().quit()
