extends CanvasLayer
## Device simulator for testing the UI in the editor (Godot has no Device Simulator like Unity).
## Debug builds on desktop only:
##   F1 = 16:9 phone (1920x1080)
##   F2 = iPhone 13, 19.5:9 (2532x1170), notch on the left, yellow line = safe area
##   F3 = iPad, 4:3 (2048x1536)
##   F4 = simulator off
##   F9 = screenshot into the project folder screenshots/

signal changed

const DEVICES := [
	{"name": "16-9_phone", "size": Vector2i(1920, 1080), "insets": Vector4(0, 0, 0, 0), "notch": false},
	# iPhone 13 landscape: 141 px left/right for the notch and corners, 63 px home bar
	{"name": "iPhone13_19.5-9", "size": Vector2i(2532, 1170), "insets": Vector4(141.0 / 2532, 0, 141.0 / 2532, 63.0 / 1170), "notch": true},
	{"name": "iPad_4-3", "size": Vector2i(2048, 1536), "insets": Vector4(0, 0, 0, 0), "notch": false},
]

var active := false
var insets := Vector4.ZERO
var device := -1
var overlay: Control


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_overlay)
	add_child(overlay)
	get_viewport().size_changed.connect(overlay.queue_redraw)
	if not OS.is_debug_build() or OS.has_feature("mobile"):
		set_process_input(false)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_F1: use_device(0)
		KEY_F2: use_device(1)
		KEY_F3: use_device(2)
		KEY_F4: use_device(-1)
		KEY_F9: screenshot()
		_: return
	get_viewport().set_input_as_handled()


func use_device(i: int) -> void:
	device = i
	active = i >= 0
	insets = DEVICES[i].insets if active else Vector4.ZERO
	if active:
		# Same aspect ratio as the real device, scaled down to fit the monitor.
		var real := Vector2(DEVICES[i].size)
		var screen := Vector2(DisplayServer.screen_get_usable_rect().size) * 0.85
		var k := minf(1.0, minf(screen.x / real.x, screen.y / real.y))
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(real * k))
		var usable := DisplayServer.screen_get_usable_rect()
		DisplayServer.window_set_position(usable.position + (usable.size - DisplayServer.window_get_size()) / 2)
		print("DeviceSim: ", DEVICES[i].name, " ", DEVICES[i].size)
	changed.emit()
	overlay.queue_redraw()


func screenshot() -> void:
	await RenderingServer.frame_post_draw
	var dir := "res://screenshots" if OS.has_feature("editor") else "user://screenshots"
	DirAccess.make_dir_recursive_absolute(dir)
	var tag: String = DEVICES[device].name if active else "window"
	var scene: String = get_tree().current_scene.name if get_tree().current_scene else "scene"
	var path := "%s/%s_%s_%d.png" % [dir, scene, tag, Time.get_ticks_msec()]
	get_viewport().get_texture().get_image().save_png(path)
	print("Screenshot: ", ProjectSettings.globalize_path(path))


func _draw_overlay() -> void:
	if not active:
		return
	var vp := overlay.get_viewport_rect().size
	if DEVICES[device].notch:
		var notch := Rect2(0, vp.y * 0.32, vp.x * 0.03, vp.y * 0.36)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.BLACK
		sb.corner_radius_top_right = 30
		sb.corner_radius_bottom_right = 30
		overlay.draw_style_box(sb, notch)
	if insets != Vector4.ZERO:
		var safe := Rect2(insets.x * vp.x, insets.y * vp.y,
				vp.x * (1.0 - insets.x - insets.z), vp.y * (1.0 - insets.y - insets.w))
		overlay.draw_dashed_line(safe.position, Vector2(safe.end.x, safe.position.y), Color(0.96, 0.78, 0.26), 3, 14)
		overlay.draw_dashed_line(Vector2(safe.end.x, safe.position.y), safe.end, Color(0.96, 0.78, 0.26), 3, 14)
		overlay.draw_dashed_line(safe.end, Vector2(safe.position.x, safe.end.y), Color(0.96, 0.78, 0.26), 3, 14)
		overlay.draw_dashed_line(Vector2(safe.position.x, safe.end.y), safe.position, Color(0.96, 0.78, 0.26), 3, 14)
