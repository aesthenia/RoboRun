class_name EnemySpawn
extends Resource

@export var scene: PackedScene
@export var position := Vector3.ZERO
@export var yaw_degrees := 0.0
@export var stats: EnemyStats
@export var patrol_points: Array[Vector3] = []
@export var patrol_distance := 0.0
