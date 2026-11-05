extends Control

@export var radius := 100.0
@export var device := 0

var pointer := -2
var knob := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and pointer == -2 and _hit(event.position):
			pointer = event.index
			_move(event.position)
		elif not event.pressed and event.index == pointer:
			_release()
		else:
			return
	elif event is InputEventScreenDrag and event.index == pointer:
		_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.pressed and pointer == -2 and _hit(event.position):
			pointer = -1
			_move(event.position)
		elif not event.pressed and pointer == -1:
			_release()
		else:
			return
	elif event is InputEventMouseMotion and pointer == -1:
		_move(event.position)
	else:
		return
	get_viewport().set_input_as_handled()


func _hit(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)


func _move(pos: Vector2) -> void:
	knob = (pos - get_global_rect().get_center()).limit_length(radius)
	queue_redraw()
	_send(knob / radius)


func _release() -> void:
	pointer = -2
	knob = Vector2.ZERO
	queue_redraw()
	_send(Vector2.ZERO)


func _send(v: Vector2) -> void:
	for pair in [[JOY_AXIS_LEFT_X, v.x], [JOY_AXIS_LEFT_Y, v.y]]:
		var e := InputEventJoypadMotion.new()
		e.device = device
		e.axis = pair[0]
		e.axis_value = pair[1]
		Input.parse_input_event.call_deferred(e)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and pointer != -2:
		_release()


func _draw() -> void:
	var c := size / 2
	draw_circle(c, radius + 30, Color(0.09, 0.1, 0.12, 0.45))
	draw_arc(c, radius + 30, 0, TAU, 64, Color(1, 1, 1, 0.35), 3, true)
	draw_circle(c + knob, 48, Color(0.88, 0.89, 0.92, 0.85 if pointer != -2 else 0.6))
