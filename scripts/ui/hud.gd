extends CanvasLayer

@onready var hearts = %Hearts
@onready var coins_label: Label = %CoinsLabel
@onready var level_label: Label = %LevelLabel
@onready var message_label: Label = %MessageLabel
@onready var boss_box: Control = %BossBox
@onready var boss_bar: ProgressBar = %BossBar
@onready var pause_menu: Control = %PauseMenu

var tween: Tween


func _ready() -> void:
	pause_menu.hide()
	boss_box.hide()
	message_label.modulate.a = 0.0
	GameManager.coins_changed.connect(_on_coins)
	GameManager.message.connect(show_message)
	%BtnResume.pressed.connect(resume)
	%BtnRestart.pressed.connect(func(): _click(); GameManager.restart_level())
	%BtnMenu.pressed.connect(func(): _click(); GameManager.to_menu())


func setup(player: Node, title: String) -> void:
	hearts.max_hp = player.health.max_hp
	hearts.set_hp(player.health.hp)
	player.health.changed.connect(hearts.set_hp)
	level_label.text = title
	show_message(title)


func show_boss(boss: Node) -> void:
	boss_box.show()
	coins_label.hide()
	boss_bar.max_value = boss.max_hp
	boss_bar.value = boss.max_hp
	boss.hp_changed.connect(func(hp, _m): boss_bar.value = hp)


func _on_coins(collected: int, total: int) -> void:
	coins_label.text = "Монеты: %d / %d" % [collected, total]


func show_message(text: String) -> void:
	message_label.text = text
	if tween:
		tween.kill()
	message_label.modulate.a = 1.0
	tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.6)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not GameManager.busy:
		if pause_menu.visible:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()


func pause() -> void:
	_click()
	get_tree().paused = true
	pause_menu.show()


func resume() -> void:
	_click()
	pause_menu.hide()
	get_tree().paused = false


func _click() -> void:
	Audio.play("click")
