extends Node3D

@export var time_offset := 0.0

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	anim.play("pulse")
	anim.seek(time_offset, true)
