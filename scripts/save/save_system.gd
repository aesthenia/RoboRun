class_name SaveSystem
extends RefCounted

const PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"


static func write(data: SaveData) -> bool:
	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("Save failed: %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_string(JSON.stringify(data.to_dict(), "\t", false))
	f.close()
	if DirAccess.rename_absolute(TMP_PATH, PATH) != OK:
		DirAccess.remove_absolute(PATH)
		if DirAccess.rename_absolute(TMP_PATH, PATH) != OK:
			push_warning("Save failed: cannot replace %s" % PATH)
			return false
	return true


static func read() -> SaveData:
	if not FileAccess.file_exists(PATH):
		return SaveData.new()
	var text := FileAccess.get_file_as_string(PATH)
	if text.strip_edges().is_empty():
		push_warning("Save file is empty, using defaults")
		return SaveData.new()
	var json := JSON.new()
	if json.parse(text) != OK:
		push_warning("Save file is broken (line %d: %s), using defaults" % [json.get_error_line(), json.get_error_message()])
		return SaveData.new()
	if not json.data is Dictionary:
		push_warning("Save file has a wrong format, using defaults")
		return SaveData.new()
	return SaveData.from_dict(json.data)


static func erase() -> void:
	for p in [PATH, TMP_PATH]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


static func file_path() -> String:
	return ProjectSettings.globalize_path(PATH)
