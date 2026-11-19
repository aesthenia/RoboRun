class_name PlayerStats
extends Resource

@export_group("Movement")
@export var speed := 6.0
@export var acceleration := 10.0
@export var air_control := 0.5
@export var jump_speed := 7.5
@export var turn_speed := 12.0
@export var fall_limit := -12.0
@export_group("Health")
@export var max_hp := 3
@export var invincibility_time := 2.0
@export var blink_interval := 0.2
@export var knockback_speed := 5.0
@export var knockback_up := 4.0
@export_group("Shooting")
@export var shoot_cooldown := 0.3
@export var bullet_damage := 1
@export var bullet_speed := 18.0
@export var bullet_range := 11.0
