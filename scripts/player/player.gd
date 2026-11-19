extends RigidBody3D

const HAZARDS: HazardStats = preload("res://data/hazards.tres")

@export var stats: PlayerStats
@export var camera_rig: Node3D

var on_floor := false
var floor_velocity := Vector3.ZERO
var dead := false

@onready var model: Node3D = $Model
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var health = $Health


func _ready() -> void:
	var ap: AnimationPlayer = $Model/AnimationPlayer
	for a in ["Idle", "Running", "Dance"]:
		ap.get_animation(a).loop_mode = Animation.LOOP_LINEAR
	health.setup(stats)
	body_entered.connect(_on_body_entered)
	health.died.connect(die)


func _physics_process(delta: float) -> void:
	if dead:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := Vector3(input.x, 0.0, input.y)
	if camera_rig:
		dir = dir.rotated(Vector3.UP, camera_rig.global_rotation.y)
	var target := dir * stats.speed + Vector3(floor_velocity.x, 0, floor_velocity.z)
	var k := clampf(stats.acceleration * delta * (1.0 if on_floor else stats.air_control), 0.0, 1.0)
	linear_velocity.x = lerpf(linear_velocity.x, target.x, k)
	linear_velocity.z = lerpf(linear_velocity.z, target.z, k)

	if dir.length() > 0.1:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(dir.x, dir.z), stats.turn_speed * delta)

	var moving := dir.length() > 0.1
	anim_tree.set("parameters/conditions/moving", on_floor and moving)
	anim_tree.set("parameters/conditions/idle", on_floor and not moving)
	anim_tree.set("parameters/conditions/airborne", not on_floor)
	anim_tree.set("parameters/conditions/landed", on_floor)

	if global_position.y < stats.fall_limit:
		die()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and on_floor and not dead:
		linear_velocity.y = stats.jump_speed
		on_floor = false
		Audio.play("jump")


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	on_floor = false
	floor_velocity = Vector3.ZERO
	for i in state.get_contact_count():
		if state.get_contact_local_normal(i).y > 0.6:
			on_floor = true
			floor_velocity = state.get_contact_collider_velocity_at_position(i)
			break


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("spikes"):
		hurt(HAZARDS.spike_damage, body.global_position)
	elif body is Enemy and body.contact_damage > 0:
		hurt(body.contact_damage, body.global_position)


func hurt(dmg: int, from: Vector3) -> void:
	if dead or health.invincible:
		return
	health.take_damage(dmg)
	var away := global_position - from
	away.y = 0
	linear_velocity = away.normalized() * stats.knockback_speed + Vector3.UP * stats.knockback_up


func die() -> void:
	if dead:
		return
	dead = true
	anim_tree.active = false
	$Model/AnimationPlayer.play("Death")
	Audio.play("death")
	GameManager.player_died()
