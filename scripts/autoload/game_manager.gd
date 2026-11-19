extends Node

signal coins_changed(collected: int, total: int)
signal message(text: String)

const MENU := "res://scenes/ui/main_menu.tscn"
const WIN := "res://scenes/ui/win_screen.tscn"
const GAME := "res://scenes/levels/game.tscn"

const ITEMS: ItemValues = preload("res://data/items.tres")

var campaign: Campaign = preload("res://data/campaign.tres")
var level_index := 0
var coins := 0
var coins_total := 0
var coins_run := 0
var score_run := 0
var time_left := 0.0
var busy := false


func level_count() -> int:
	return campaign.levels.size()


func current_level() -> LevelData:
	return campaign.levels[level_index]


func level_name() -> String:
	return current_level().title


func play_level(index: int) -> void:
	level_index = index
	coins_run = 0
	score_run = 0
	_load_level()


func next_level() -> void:
	level_index += 1
	if level_index >= level_count():
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
	get_tree().change_scene_to_file(GAME)


func start_level(total: int) -> void:
	coins = 0
	coins_total = total
	time_left = current_level().time_limit
	coins_changed.emit(coins, coins_total)


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins, coins_total)
	if all_coins():
		message.emit("Все монеты собраны — портал открыт!")


func all_coins() -> bool:
	return coins >= coins_total


func time_bonus() -> int:
	return int(maxf(time_left, 0.0)) * current_level().time_bonus_per_second


func player_died() -> void:
	_fail("Ты погиб! Уровень начнётся заново")


func time_up() -> void:
	_fail("Время вышло! Уровень начнётся заново")


func _fail(text: String) -> void:
	if busy:
		return
	busy = true
	message.emit(text)
	await get_tree().create_timer(1.6).timeout
	restart_level()


func _complete(score: int) -> void:
	coins_run += coins
	score_run += score
	SaveManager.level_completed(level_index + 1, score, level_count())


func level_finished() -> void:
	if busy:
		return
	busy = true
	var score := coins * ITEMS.coin_score + time_bonus()
	_complete(score)
	Audio.play("portal")
	message.emit("Уровень пройден! Очки: %d" % score)
	await get_tree().create_timer(1.2).timeout
	next_level()


func boss_defeated() -> void:
	if busy:
		return
	busy = true
	_complete(ITEMS.boss_score + time_bonus())
	Audio.play("win")
	message.emit("Каменный король повержен!")
	await get_tree().create_timer(2.5).timeout
	win()
