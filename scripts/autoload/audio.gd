extends Node

const SFX := ["jump", "pickup", "hurt", "heal", "shoot", "explosion", "boss_hit",
		"boss_roar", "fireball", "portal", "win", "click", "death"]
const MUSIC := "res://audio/music/music.mp3"

var sounds := {}
var pool: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for s in SFX:
		sounds[s] = load("res://audio/sfx/%s.wav" % s)
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	music = AudioStreamPlayer.new()
	var stream: AudioStream = load(MUSIC)
	if stream is AudioStreamMP3:
		stream.loop = true
	music.stream = stream
	music.volume_db = -14.0
	add_child(music)


func play(name: String, volume_db := 0.0) -> void:
	for p in pool:
		if not p.playing:
			p.stream = sounds[name]
			p.volume_db = volume_db
			p.pitch_scale = randf_range(0.95, 1.05)
			p.play()
			return


func play_music() -> void:
	if not music.playing:
		music.play()
