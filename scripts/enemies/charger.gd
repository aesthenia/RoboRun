extends SmartEnemy

enum State { IDLE, WINDUP, DASH, STUNNED, RETURN }

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

var state := State.IDLE
var dash_dir := Vector3.FORWARD
var dashed := 0.0
var hit_player := false

@onready var dash_mark: MeshInstance3D = $Model/DashMark
@onready var body_mesh: Node3D = $Model/Body


func _ready() -> void:
	super()
	change_state(State.IDLE)


func change_state(s: State) -> void:
	state = s
	body_mesh.position = Vector3.ZERO
	body_mesh.rotation = Vector3.ZERO
	dash_mark.visible = s == State.WINDUP
	alert.visible = s == State.WINDUP or s == State.STUNNED
	alert.text = "zz" if s == State.STUNNED else "!"
	if s == State.WINDUP:
		Audio.play("boss_roar", -8.0)
		dash_mark.scale = Vector3(1.0, 1.0, dash_distance)
		dash_mark.position.z = dash_distance * 0.5
	elif s == State.DASH:
		dash_dir = facing()
		dashed = 0.0
		hit_player = false
	elif s == State.STUNNED:
		Audio.play("boss_hit", -4.0)
	enter_state(State.keys()[s])


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	state_time += delta
	match state:
		State.IDLE:
			_idle(delta)
		State.WINDUP:
			_windup(delta)
		State.DASH:
			_dash(delta)
		State.STUNNED:
			_stunned()
		State.RETURN:
			_return(delta)


func _idle(delta: float) -> void:
	turn_to_yaw(home_yaw, delta, 2.0)
	if state_time >= rest_time and sees_player():
		change_state(State.WINDUP)


func _windup(delta: float) -> void:
	if state_time < windup_time * windup_lock and player_alive():
		turn_to_yaw(yaw_to(player.global_position), delta, turn_speed * 1.5)
	body_mesh.position.x = sin(state_time * 70.0) * 0.07
	dash_mark.visible = state_time < windup_time * 0.5 or int(state_time * 20.0) % 2 == 0
	if state_time >= windup_time:
		change_state(State.DASH)


func _dash(delta: float) -> void:
	if not _ground_ahead():
		change_state(State.STUNNED)
		return
	var motion := dash_dir * dash_speed * delta
	var col := move_and_collide(motion)
	dashed += motion.length()
	if not hit_player and player_alive() and distance_to_player() < 1.1:
		_hit_player()
	if col:
		if col.get_collider() == player:
			_hit_player()
		change_state(State.STUNNED)
	elif dashed >= dash_distance:
		change_state(State.STUNNED)


func _hit_player() -> void:
	hit_player = true
	player.hurt(dash_damage, global_position - dash_dir)


func _ground_ahead() -> bool:
	var from := global_position + dash_dir * edge_check_ahead + Vector3.UP * 0.5
	var query := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 2.0, 1)
	query.exclude = [get_rid()]
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _stunned() -> void:
	body_mesh.rotation.z = sin(state_time * 7.0) * 0.18
	if state_time >= stun_time:
		change_state(State.RETURN)


func _return(delta: float) -> void:
	if state_time >= rest_time and sees_player():
		change_state(State.WINDUP)
		return
	if walk_to(home, walk_speed, delta):
		change_state(State.IDLE)


func take_hit(dmg: int) -> void:
	super(dmg * (stunned_damage_multiplier if state == State.STUNNED else 1))


func on_hurt() -> void:
	super()
	if state == State.IDLE or state == State.RETURN:
		state_time = maxf(state_time, rest_time)
