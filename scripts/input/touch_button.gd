extends Control

@export var button := JOY_BUTTON_A
@export var text := "JUMP"
@export var device := 0

var pointer := -2


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and pointer == -2 and _hit(event.position):
			_press(event.index)
		elif not event.pressed and event.index == pointer:
			_release()
		else:
			return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.pressed and pointer == -2 and _hit(event.position):
			_press(-1)
		elif not event.pressed and pointer == -1:
			_release()
		else:
			return
	else:
		return
	get_viewport().set_input_as_handled()


func _hit(pos: Vector2) -> bool:
	return get_global_rect().get_center().distance_to(pos) <= size.x / 2


func _press(index: int) -> void:
	pointer = index
	_send(true)


func _release() -> void:
	pointer = -2
	_send(false)


func _send(pressed: bool) -> void:
	queue_redraw()
	var e := InputEventJoypadButton.new()
	e.device = device
	e.button_index = button
	e.pressed = pressed
	Input.parse_input_event.call_deferred(e)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and pointer != -2:
		_release()


func _draw() -> void:
	var c := size / 2
	var r := size.x / 2
	var down := pointer != -2
	draw_circle(c, r, Color(0.88, 0.89, 0.92, 0.85) if down else Color(0.09, 0.1, 0.12, 0.5))
	draw_arc(c, r, 0, TAU, 64, Color(1, 1, 1, 0.4), 3, true)
	var font := get_theme_default_font()
	var fs := 36
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, c + Vector2(-w / 2, fs * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs,
			Color(0.09, 0.1, 0.12) if down else Color(1, 1, 1, 0.9))
