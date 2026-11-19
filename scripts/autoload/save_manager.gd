extends Node

signal changed

var data: SaveData


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	data = SaveSystem.read()
	apply_settings()
	print("Save file: ", SaveSystem.file_path())


func save() -> void:
	SaveSystem.write(data)


func level_completed(level_number: int, score: int, level_count: int) -> void:
	data.best_scores[str(level_number)] = maxi(data.best_score(level_number), score)
	if level_number < level_count and not data.is_unlocked(level_number + 1):
		data.unlocked_levels.append(level_number + 1)
	save()
	changed.emit()


func set_music_volume(v: float) -> void:
	data.music_volume = v
	Audio.set_music_volume(v)


func set_sfx_volume(v: float) -> void:
	data.sfx_volume = v
	Audio.set_sfx_volume(v)


func apply_settings() -> void:
	Audio.set_music_volume(data.music_volume)
	Audio.set_sfx_volume(data.sfx_volume)


func reset_progress() -> void:
	SaveSystem.erase()
	data = SaveData.new()
	apply_settings()
	changed.emit()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			if data:
				save()
