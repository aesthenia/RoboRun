extends RigidBody3D

@export var speed := 6.0
@export var acceleration := 10.0
@export var jump_speed := 7.5
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
	body_entered.connect(_on_body_entered)
	health.died.connect(die)


func _physics_process(delta: float) -> void:
	if dead:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := Vector3(input.x, 0.0, input.y)
	if camera_rig:
		dir = dir.rotated(Vector3.UP, camera_rig.global_rotation.y)
	var target := dir * speed + Vector3(floor_velocity.x, 0, floor_velocity.z)
	var k := clampf(acceleration * delta * (1.0 if on_floor else 0.5), 0.0, 1.0)
	linear_velocity.x = lerpf(linear_velocity.x, target.x, k)
	linear_velocity.z = lerpf(linear_velocity.z, target.z, k)

	if dir.length() > 0.1:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(dir.x, dir.z), 12.0 * delta)

	var moving := dir.length() > 0.1
	anim_tree.set("parameters/conditions/moving", on_floor and moving)
	anim_tree.set("parameters/conditions/idle", on_floor and not moving)
	anim_tree.set("parameters/conditions/airborne", not on_floor)
	anim_tree.set("parameters/conditions/landed", on_floor)

	if global_position.y < -12.0:
		die()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and on_floor and not dead:
		linear_velocity.y = jump_speed
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
		hurt(1, body.global_position)
	elif body is Enemy:
		hurt(body.contact_damage, body.global_position)


func hurt(dmg: int, from: Vector3) -> void:
	if dead or health.invincible:
		return
	health.take_damage(dmg)
	var away := global_position - from
	away.y = 0
	linear_velocity = away.normalized() * 5.0 + Vector3.UP * 4.0


func die() -> void:
	if dead:
		return
	dead = true
	anim_tree.active = false
	$Model/AnimationPlayer.play("Death")
	Audio.play("death")
	GameManager.player_died()
