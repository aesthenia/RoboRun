extends Enemy

@export var distance := 4.0
@export var speed := 2.0

var start := Vector3.ZERO
var t := 0.0

@onready var model: Node3D = $Model


func _ready() -> void:
	super()
	start = position


func _physics_process(delta: float) -> void:
	t += delta * speed / distance
	var k := pingpong(t, 2.0) - 1.0
	var prev := position
	position = start + transform.basis.x * k * distance
	var moved := position - prev
	if moved.length() > 0.001:
		model.rotation.y = atan2(moved.x, moved.z) - rotation.y
