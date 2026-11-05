extends Control

@export var max_hp := 3
@export var heart_size := 1.45
@export var spacing := 58.0

const FULL := Color(0.95, 0.27, 0.36)
const EMPTY := Color(0.12, 0.12, 0.15, 0.55)
const OUTLINE := Color(0.08, 0.06, 0.08, 0.9)

var hp := 3
var shape := PackedVector2Array()


func _ready() -> void:
	for i in 64:
		var t := TAU * i / 64.0
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)) - 2.5
		shape.append(Vector2(x, y) * heart_size)


func set_hp(value: int) -> void:
	hp = value
	queue_redraw()


func _draw() -> void:
	for i in max_hp:
		var c := Vector2(26 + i * spacing, 26)
		var pts := PackedVector2Array()
		for p in shape:
			pts.append(c + p)
		draw_colored_polygon(pts, FULL if i < hp else EMPTY)
		pts.append(pts[0])
		draw_polyline(pts, OUTLINE, 3.0, true)
