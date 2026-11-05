extends Control
## SafeArea panel: keeps its children (buttons, text) out of the notch,
## rounded corners and the home bar. Background art stays outside it, full screen.
## On a real phone the insets come from DisplayServer.get_display_safe_area().
## In the editor the DeviceSim autoload (F1-F4) fakes a device and its insets.


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	get_viewport().size_changed.connect(_apply)
	DeviceSim.changed.connect(_apply)
	_apply()


func _apply() -> void:
	var f := _inset_fractions()  # left, top, right, bottom as parts of the screen
	var vp := get_viewport_rect().size
	offset_left = f.x * vp.x
	offset_top = f.y * vp.y
	offset_right = -f.z * vp.x
	offset_bottom = -f.w * vp.y


func _inset_fractions() -> Vector4:
	if DeviceSim.active:
		return DeviceSim.insets
	if not OS.has_feature("mobile"):
		return Vector4.ZERO
	var win := Vector2(DisplayServer.window_get_size())
	var safe := Rect2(DisplayServer.get_display_safe_area())
	if win.x <= 0 or win.y <= 0 or safe.size == Vector2.ZERO:
		return Vector4.ZERO
	return Vector4(
		safe.position.x / win.x,
		safe.position.y / win.y,
		(win.x - safe.end.x) / win.x,
		(win.y - safe.end.y) / win.y)
