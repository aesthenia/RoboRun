extends Node3D

const COIN := preload("res://scenes/objects/coin.tscn")
const HEART := preload("res://scenes/objects/heart_pickup.tscn")

var data: LevelData
var layout: Node3D
var boss: Node

@onready var world: Node3D = $World
@onready var player: RigidBody3D = $Player
@onready var camera_rig: Node3D = $CameraRig
@onready var hud = $HUD


func _ready() -> void:
	get_tree().paused = false
	data = GameManager.current_level()
	layout = data.layout.instantiate()
	world.add_child(layout)
	player.global_position = data.player_start
	camera_rig.global_position = data.player_start
	for p in data.coins:
		_spawn(COIN, p)
	for p in data.hearts:
		_spawn(HEART, p)
	for s in data.enemies:
		_spawn_enemy(s)
	GameManager.start_level(data.coins.size())
	hud.setup(player, data.title)
	hud.set_time(data.time_limit)
	if data.goal == LevelData.Goal.DEFEAT_BOSS and boss:
		hud.show_boss(boss)
		var trigger: Area3D = layout.get_node("ArenaTrigger")
		trigger.body_entered.connect(_on_arena_entered)
	Audio.play_music("level")


func _process(delta: float) -> void:
	if data.time_limit <= 0.0 or GameManager.busy or player.dead:
		return
	GameManager.time_left -= delta
	hud.set_time(GameManager.time_left)
	if GameManager.time_left <= 0.0:
		GameManager.time_up()


func _spawn(scene: PackedScene, pos: Vector3) -> Node3D:
	var n: Node3D = scene.instantiate()
	n.position = pos
	world.add_child(n)
	return n


func _spawn_enemy(s: EnemySpawn) -> void:
	var e: Node3D = s.scene.instantiate()
	if s.stats:
		e.stats = s.stats
	if not s.patrol_points.is_empty() and "patrol_points" in e:
		e.patrol_points = s.patrol_points.duplicate()
	if s.patrol_distance > 0.0 and "distance" in e:
		e.distance = s.patrol_distance
	if "target" in e:
		e.target = player
	e.position = s.position
	e.rotation.y = deg_to_rad(s.yaw_degrees)
	world.add_child(e)
	if e.has_method("start_fight"):
		boss = e


func _on_arena_entered(body: Node3D) -> void:
	if body.is_in_group("player") and boss and is_instance_valid(boss) and not boss.active and boss.hp > 0:
		boss.start_fight()
