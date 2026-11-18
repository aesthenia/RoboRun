extends SmartEnemy

enum State { PATROL, CHASE, FUSE, RECHARGE, RETURN }

@export_group("Patrol")
@export var patrol_points: Array[Vector3] = [Vector3(3, 0, 0), Vector3(-3, 0, 0)]
@export var point_wait := 0.8
@export_group("Chase")
@export var chase_speed := 3.6
@export var lose_sight_time := 2.0
@export var leash_range := 12.0
@export_group("Attack")
@export var trigger_range := 1.8
@export var fuse_time := 0.6
@export var fuse_swell := 0.35
@export var blast_radius := 2.4
@export var blast_damage := 1
@export var recharge_time := 2.0
@export var blast_mark_scene: PackedScene

var state := State.PATROL
var point_index := 0
var unseen_time := 0.0
var waiting := 0.0
var mark: Node3D

@onready var fuse_light: OmniLight3D = $Model/FuseLight


func _ready() -> void:
	super()
	change_state(State.PATROL)


func change_state(s: State) -> void:
	state = s
	unseen_time = 0.0
	waiting = 0.0
	model.scale = Vector3.ONE
	fuse_light.visible = false
	alert.visible = s == State.CHASE or s == State.FUSE
	alert.text = "!!" if s == State.FUSE else "!"
	_clear_mark()
	if s == State.FUSE:
		Audio.play("fireball", -2.0)
		if blast_mark_scene:
			mark = blast_mark_scene.instantiate()
			get_tree().current_scene.add_child(mark)
			mark.global_position = global_position + Vector3.UP * 0.05
			mark.scale = Vector3.ONE * (blast_radius / 1.1)
	enter_state(State.keys()[s])


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	state_time += delta
	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.FUSE:
			_fuse(delta)
		State.RECHARGE:
			_recharge()
		State.RETURN:
			_return(delta)


func _patrol_point() -> Vector3:
	if patrol_points.is_empty():
		return home
	return home + patrol_points[point_index % patrol_points.size()]


func _patrol(delta: float) -> void:
	if sees_player():
		change_state(State.CHASE)
		return
	if waiting > 0.0:
		waiting -= delta
		if waiting <= 0.0:
			point_index += 1
		return
	if walk_to(_patrol_point(), walk_speed, delta):
		waiting = point_wait


func _chase(delta: float) -> void:
	if sees_player():
		unseen_time = 0.0
	else:
		unseen_time += delta
	if not player_alive() or unseen_time > lose_sight_time or flat_distance(global_position, home) > leash_range:
		change_state(State.RETURN)
		return
	if state_time > 0.3 and not can_reach(player.global_position):
		change_state(State.RETURN)
		return
	if distance_to_player() < trigger_range:
		change_state(State.FUSE)
		return
	walk_to(player.global_position, chase_speed, delta)


func _fuse(delta: float) -> void:
	var k := clampf(state_time / fuse_time, 0.0, 1.0)
	model.scale = Vector3.ONE * (1.0 + fuse_swell * k)
	fuse_light.visible = int(state_time * (8.0 + 16.0 * k)) % 2 == 0
	if player_alive():
		turn_to_yaw(yaw_to(player.global_position), delta)
	if state_time >= fuse_time:
		_explode()
		change_state(State.RECHARGE)


func _explode() -> void:
	Audio.play("explosion")
	if player_alive() and distance_to_player() <= blast_radius and absf(player.global_position.y - global_position.y) < 2.0:
		player.hurt(blast_damage, global_position)


func _recharge() -> void:
	model.scale = Vector3(1.15, 0.7, 1.15)
	if state_time >= recharge_time:
		change_state(State.CHASE if sees_player() else State.RETURN)


func _return(delta: float) -> void:
	if sees_player() and flat_distance(global_position, home) < leash_range:
		change_state(State.CHASE)
		return
	if walk_to(_patrol_point(), walk_speed, delta):
		change_state(State.PATROL)


func on_hurt() -> void:
	super()
	if state == State.PATROL or state == State.RETURN:
		change_state(State.CHASE)


func on_death() -> void:
	_clear_mark()
	super()


func _clear_mark() -> void:
	if is_instance_valid(mark):
		mark.queue_free()
	mark = null
