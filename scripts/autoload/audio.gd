extends Node

const SFX := {
	"jump": ["jump"],
	"pickup": ["pickup"],
	"hurt": ["hurt", "hurt_2", "hurt_3"],
	"heal": ["heal"],
	"shoot": ["shoot", "shoot_2", "shoot_3"],
	"explosion": ["explosion"],
	"boss_hit": ["boss_hit", "boss_hit_2", "boss_hit_3"],
	"boss_roar": ["boss_roar"],
	"fireball": ["fireball"],
	"fuse": ["fuse"],
	"charge": ["charge"],
	"portal": ["portal"],
	"win": ["win"],
	"lose": ["lose"],
	"click": ["click"],
	"death": ["death"],
}
const TRACKS := {
	"menu": "res://audio/music/menu_loop.ogg",
	"level": "res://audio/music/level_loop.ogg",
}
const PITCH_RANDOM := 1.08
const VOICES := 12
const VOICES_3D := 12
const CROSSFADE_TIME := 1.0
const PAUSE_FADE_TIME := 0.3
const PAUSE_DROP_DB := -6.0
const PAUSE_CUTOFF_HZ := 800.0
const OPEN_CUTOFF_HZ := 20000.0
const SILENT_DB := -80.0
const UNIT_SIZE_3D := 8.0
const MAX_DISTANCE_3D := 45.0

var sounds := {}
var pool: Array[AudioStreamPlayer] = []
var pool_3d: Array[AudioStreamPlayer3D] = []
var music_a: AudioStreamPlayer
var music_b: AudioStreamPlayer
var current: AudioStreamPlayer
var current_track := ""
var music_tween: Tween
var pause_tween: Tween
var is_paused := false
var tracks_bus := 0
var tracks_db := 0.0
var lowpass: AudioEffectLowPassFilter


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key in SFX:
		var r := AudioStreamRandomizer.new()
		r.random_pitch = PITCH_RANDOM
		r.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS if SFX[key].size() > 1 else AudioStreamRandomizer.PLAYBACK_RANDOM
		for clip in SFX[key]:
			r.add_stream(-1, load("res://audio/sfx/%s.wav" % clip))
		sounds[key] = r
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		pool.append(p)
	for i in VOICES_3D:
		var p := AudioStreamPlayer3D.new()
		p.bus = &"SFX"
		p.unit_size = UNIT_SIZE_3D
		p.max_distance = MAX_DISTANCE_3D
		add_child(p)
		pool_3d.append(p)
	music_a = _music_player()
	music_b = _music_player()
	current = music_a
	tracks_bus = AudioServer.get_bus_index(&"Tracks")
	tracks_db = AudioServer.get_bus_volume_db(tracks_bus)
	lowpass = AudioServer.get_bus_effect(tracks_bus, 0)
	lowpass.cutoff_hz = OPEN_CUTOFF_HZ


func _music_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = &"Tracks"
	p.volume_db = SILENT_DB
	add_child(p)
	return p


func _process(_delta: float) -> void:
	if get_tree().paused != is_paused:
		set_paused(get_tree().paused)


func play(name: String, volume_db := 0.0) -> void:
	for p in pool:
		if not p.playing:
			p.stream = sounds[name]
			p.volume_db = volume_db
			p.play()
			return


func play_at(name: String, position: Vector3, volume_db := 0.0) -> void:
	for p in pool_3d:
		if not p.playing:
			p.stream = sounds[name]
			p.volume_db = volume_db
			p.global_position = position
			p.play()
			return


func play_music(track: String) -> void:
	if track == current_track and current.playing:
		return
	current_track = track
	var stream: AudioStream = load(TRACKS[track])
	stream.loop = true
	var from := current
	var to := music_b if current == music_a else music_a
	to.stream = stream
	to.volume_db = SILENT_DB
	to.play()
	current = to
	if music_tween:
		music_tween.kill()
	music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	music_tween.tween_method(_crossfade.bind(from, to), 0.0, 1.0, CROSSFADE_TIME)
	music_tween.tween_callback(from.stop)


func _crossfade(t: float, from: AudioStreamPlayer, to: AudioStreamPlayer) -> void:
	from.volume_db = linear_to_db(maxf(1.0 - t, 0.0001))
	to.volume_db = linear_to_db(maxf(t, 0.0001))


func set_paused(paused: bool) -> void:
	is_paused = paused
	if pause_tween:
		pause_tween.kill()
	pause_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel()
	pause_tween.tween_method(func(db): AudioServer.set_bus_volume_db(tracks_bus, db),
			AudioServer.get_bus_volume_db(tracks_bus), tracks_db + (PAUSE_DROP_DB if paused else 0.0), PAUSE_FADE_TIME)
	pause_tween.tween_property(lowpass, "cutoff_hz", PAUSE_CUTOFF_HZ if paused else OPEN_CUTOFF_HZ, PAUSE_FADE_TIME)


func set_music_volume(v: float) -> void:
	_set_bus(&"Music", v)


func set_sfx_volume(v: float) -> void:
	_set_bus(&"SFX", v)


func _set_bus(bus: StringName, v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(maxf(v, 0.0001)))
