extends SmartEnemy

enum State { SCAN, AIM, FIRE, COOLDOWN }

@export var projectile_scene: PackedScene
@export var muzzle_forward := 1.0
@export var muzzle_height := 1.35

var state := State.SCAN
var scan_phase := 0.0

@onready var laser: MeshInstance3D = $Model/Laser
@onready var head: Node3D = $Model/Head
@onready var cfg: TurretStats = stats


func _ready() -> void:
	super()
	change_state(State.SCAN)


func change_state(s: State) -> void:
	state = s
	laser.visible = s == State.AIM
	alert.visible = s == State.AIM
	alert.text = "!"
	head.scale = Vector3.ONE
	if s == State.AIM:
		Audio.play("click", 2.0)
	elif s == State.FIRE:
		_fire()
	enter_state(State.keys()[s])


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	state_time += delta
	match state:
		State.SCAN:
			_scan(delta)
		State.AIM:
			_aim(delta)
		State.FIRE:
			_recoil()
		State.COOLDOWN:
			_cooldown(delta)


func _scan(delta: float) -> void:
	scan_phase += delta * cfg.scan_speed
	turn_to_yaw(home_yaw + sin(scan_phase) * deg_to_rad(cfg.scan_arc * 0.5), delta, cfg.scan_turn_speed)
	if sees_player():
		change_state(State.AIM)


func _aim(delta: float) -> void:
	if not sees_player():
		change_state(State.SCAN)
		return
	turn_to_yaw(yaw_to(player.global_position), delta, cfg.aim_turn_speed)
	var k := state_time / cfg.aim_time
	var length := maxf(distance_to_player() - muzzle_forward, 0.5)
	laser.scale = Vector3(1.0, 1.0, length)
	laser.position.z = muzzle_forward + length * 0.5
	laser.visible = k < 0.5 or int(state_time * 24.0) % 2 == 0
	if state_time >= cfg.aim_time:
		change_state(State.FIRE)


func _fire() -> void:
	if projectile_scene == null:
		return
	var dir := facing()
	var p: Projectile = projectile_scene.instantiate()
	p.direction = dir
	p.speed = cfg.projectile_speed
	p.damage = cfg.projectile_damage
	get_tree().current_scene.add_child(p)
	p.global_position = global_position + dir * muzzle_forward + Vector3.UP * muzzle_height
	Audio.play("fireball")


func _recoil() -> void:
	head.scale = Vector3(1.1, 1.1, 0.8)
	if state_time >= cfg.fire_time:
		change_state(State.COOLDOWN)


func _cooldown(delta: float) -> void:
	if sees_player():
		turn_to_yaw(yaw_to(player.global_position), delta, cfg.aim_turn_speed * 0.5)
	if state_time >= cfg.cooldown:
		change_state(State.AIM if sees_player() else State.SCAN)
