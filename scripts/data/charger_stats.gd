class_name ChargerStats
extends EnemyStats

@export_group("Dash")
@export var rest_time := 0.8
@export var windup_time := 0.7
@export var windup_lock := 0.75
@export var dash_speed := 12.0
@export var dash_distance := 9.0
@export var dash_damage := 1
@export var edge_check_ahead := 1.0
@export_group("Stun")
@export var stun_time := 1.4
@export var stunned_damage_multiplier := 2
