class_name LevelData
extends Resource

enum Goal { COINS_THEN_PORTAL, DEFEAT_BOSS }

@export var title := ""
@export var layout: PackedScene
@export var goal := Goal.COINS_THEN_PORTAL
@export var time_limit := 120.0
@export var time_bonus_per_second := 10
@export var player_start := Vector3.ZERO
@export var coins: Array[Vector3] = []
@export var hearts: Array[Vector3] = []
@export var enemies: Array[EnemySpawn] = []
