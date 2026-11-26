extends Enemy

@export var distance := 4.0

var start := Vector3.ZERO
var t := 0.0
var next_warn := 0.0
var player: Node3D

@onready var model: Node3D = $Model
@onready var cfg: PatrolBombStats = stats


func _ready() -> void:
	super()
	start = position
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	t += delta * stats.walk_speed / distance
	var k := pingpong(t, 2.0) - 1.0
	var prev := position
	position = start + transform.basis.x * k * distance
	var moved := position - prev
	if moved.length() > 0.001:
		model.rotation.y = atan2(moved.x, moved.z) - rotation.y
	_warn()


func _warn() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now < next_warn or player == null or player.dead:
		return
	if global_position.distance_to(player.global_position) <= cfg.warn_range:
		Audio.play_at("fuse", global_position)
		next_warn = now + cfg.warn_interval
