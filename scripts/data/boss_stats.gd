class_name BossStats
extends EnemyStats

@export var arena_radius := 10.0
@export var phase2_hp_fraction := 0.5
@export_group("Rhythm")
@export var pause_phase1 := 2.2
@export var pause_phase2 := 1.4
@export var roar_warning := 0.7
@export_group("Fireball fan")
@export var fan_count_phase1 := 5
@export var fan_count_phase2 := 9
@export var fan_spread_phase1 := 50.0
@export var fan_spread_phase2 := 90.0
@export var fireball_speed := 18.0
@export var fireball_damage := 1
@export_group("Rock rain")
@export var rain_count_phase1 := 4
@export var rain_count_phase2 := 7
@export var rain_scatter := 4.0
@export var rain_warning := 1.1
@export var rock_drop_height := 9.0
@export var rock_damage := 1
@export var rock_lifetime := 4.0
