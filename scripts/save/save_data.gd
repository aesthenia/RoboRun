class_name SaveData
extends RefCounted

const VERSION := 1

var version := VERSION
var unlocked_levels: Array[int] = [1]
var best_scores := {}
var music_volume := 0.8
var sfx_volume := 1.0


func to_dict() -> Dictionary:
	return {
		"version": version,
		"unlocked_levels": unlocked_levels,
		"best_scores": best_scores,
		"settings": {"music_volume": music_volume, "sfx_volume": sfx_volume},
	}


static func from_dict(d: Dictionary) -> SaveData:
	var s := SaveData.new()
	if d.get("version") is float:
		s.version = int(d.version)
	if d.get("unlocked_levels") is Array:
		for v in d.unlocked_levels:
			if (v is float or v is int) and int(v) >= 1 and not s.unlocked_levels.has(int(v)):
				s.unlocked_levels.append(int(v))
		s.unlocked_levels.sort()
	if d.get("best_scores") is Dictionary:
		for k in d.best_scores:
			var v = d.best_scores[k]
			if str(k).is_valid_int() and (v is float or v is int) and v >= 0:
				s.best_scores[str(int(k))] = int(v)
	if d.get("settings") is Dictionary:
		var st: Dictionary = d.settings
		if st.get("music_volume") is float:
			s.music_volume = clampf(st.music_volume, 0.0, 1.0)
		if st.get("sfx_volume") is float:
			s.sfx_volume = clampf(st.sfx_volume, 0.0, 1.0)
	return s


func is_unlocked(level_number: int) -> bool:
	return unlocked_levels.has(level_number)


func best_score(level_number: int) -> int:
	return best_scores.get(str(level_number), 0)


func total_best() -> int:
	var t := 0
	for v in best_scores.values():
		t += v
	return t
