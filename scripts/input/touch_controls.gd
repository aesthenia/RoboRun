extends CanvasLayer

@export var show_fire := true


func _ready() -> void:
	$Root/Fire.visible = show_fire
