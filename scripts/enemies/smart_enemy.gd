class_name SmartEnemy
extends Enemy

signal state_changed(state_name: String)

static var show_states := OS.is_debug_build()

var player: Node3D
var home := Vector3.ZERO
var home_yaw := 0.0
var state_time := 0.0
var alerted_until := 0.0
var last_target := Vector3.INF

@onready var model: Node3D = $Model
@onready var vision: Vision = $Model/Vision
@onready var alert: Label3D = $Alert
@onready var state_label: Label3D = get_node_or_null("StateLabel")
@onready var agent: NavigationAgent3D = get_node_or_null("NavAgent")


func _ready() -> void:
	super()
	add_to_group("smart_enemy")
	player = get_tree().get_first_node_in_group("player")
	home = global_position
	home_yaw = model.global_rotation.y
	vision.view_range = stats.vision_range
	vision.view_angle = stats.view_angle


func enter_state(state_name: String) -> void:
	state_time = 0.0
	if state_label:
		state_label.text = state_name
		state_label.visible = show_states
	state_changed.emit(state_name)


func now() -> float:
	return Time.get_ticks_msec() / 1000.0


func player_alive() -> bool:
	return player != null and is_instance_valid(player) and not player.dead


func sees_player() -> bool:
	return player_alive() and vision.can_see(player, now() < alerted_until)


func flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func distance_to_player() -> float:
	return flat_distance(global_position, player.global_position) if player_alive() else INF


func yaw_to(point: Vector3) -> float:
	var d := point - global_position
	return atan2(d.x, d.z)


func turn_to_yaw(yaw: float, delta: float, speed := -1.0) -> void:
	var s := stats.turn_speed if speed < 0.0 else speed
	var r := model.global_rotation
	r.y = lerp_angle(r.y, yaw, clampf(s * delta, 0.0, 1.0))
	model.global_rotation = r


func facing() -> Vector3:
	var f := model.global_basis.z
	f.y = 0.0
	return f.normalized()


func nav_ready() -> bool:
	return agent != null and NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) > 0


func walk_to(point: Vector3, speed: float, delta: float) -> bool:
	if flat_distance(global_position, point) < agent.target_desired_distance:
		return true
	if not nav_ready():
		return false
	if last_target.distance_to(point) > 0.3:
		agent.target_position = point
		last_target = point
	if agent.is_navigation_finished():
		return true
	var dir := agent.get_next_path_position() - global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		return false
	dir = dir.normalized()
	turn_to_yaw(atan2(dir.x, dir.z), delta)
	move_and_collide(dir * speed * delta)
	return false


func can_reach(point: Vector3) -> bool:
	if not nav_ready():
		return true
	var map := agent.get_navigation_map()
	var closest := NavigationServer3D.map_get_closest_point(map, point)
	if flat_distance(closest, point) > 1.0:
		return false
	var path := NavigationServer3D.map_get_path(map, global_position, closest, true)
	return path.size() > 0 and flat_distance(path[path.size() - 1], closest) < 0.5


func take_hit(dmg: int) -> void:
	alerted_until = now() + stats.alert_time
	super(dmg)
