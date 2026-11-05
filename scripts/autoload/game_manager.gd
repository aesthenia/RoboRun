extends Node

signal coins_changed(collected: int, total: int)
signal message(text: String)

const MENU := "res://scenes/ui/main_menu.tscn"
const WIN := "res://scenes/ui/win_screen.tscn"
const LEVELS := [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3_boss.tscn",
]
const LEVEL_NAMES := ["Уровень 1 — Облачные острова", "Уровень 2 — Опасный путь", "Уровень 3 — Каменный король"]

var level_index := 0
var coins := 0
var coins_total := 0
var coins_run := 0
var busy := false


func start_game() -> void:
	level_index = 0
	coins_run = 0
	_load_level()


func next_level() -> void:
	coins_run += coins
	level_index += 1
	if level_index >= LEVELS.size():
		win()
	else:
		_load_level()


func restart_level() -> void:
	_load_level()


func win() -> void:
	busy = false
	get_tree().paused = false
	get_tree().change_scene_to_file(WIN)


func to_menu() -> void:
	busy = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU)


func _load_level() -> void:
	busy = false
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVELS[level_index])


func level_name() -> String:
	return LEVEL_NAMES[level_index]


func start_level(total: int) -> void:
	coins = 0
	coins_total = total
	coins_changed.emit(coins, coins_total)


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins, coins_total)
	if all_coins():
		message.emit("Все монеты собраны — портал открыт!")


func all_coins() -> bool:
	return coins >= coins_total


func player_died() -> void:
	if busy:
		return
	busy = true
	message.emit("Ты погиб! Уровень начнётся заново")
	await get_tree().create_timer(1.6).timeout
	restart_level()


func level_finished() -> void:
	if busy:
		return
	busy = true
	Audio.play("portal")
	message.emit("Уровень пройден!")
	await get_tree().create_timer(1.0).timeout
	next_level()


func boss_defeated() -> void:
	if busy:
		return
	busy = true
	Audio.play("win")
	message.emit("Каменный король повержен!")
	await get_tree().create_timer(2.5).timeout
	coins_run += coins
	win()
