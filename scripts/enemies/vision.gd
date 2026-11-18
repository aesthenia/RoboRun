class_name Vision
extends Node3D

@export var view_range := 9.0
@export_range(10.0, 360.0) var view_angle := 110.0
@export var target_height := 0.9
@export_flags_3d_physics var blocking_mask := 1

var body: CollisionObject3D


func _ready() -> void:
	var n := get_parent()
	while n and not n is CollisionObject3D:
		n = n.get_parent()
	body = n


func can_see(target: Node3D, ignore_angle := false) -> bool:
	if target == null:
		return false
	var aim := target.global_position + Vector3.UP * target_height
	var to := aim - global_position
	if to.length() > view_range:
		return false
	if not ignore_angle:
		var fwd := global_basis.z
		fwd.y = 0.0
		var flat := Vector3(to.x, 0.0, to.z)
		if flat.length() > 0.05 and rad_to_deg(fwd.angle_to(flat)) > view_angle * 0.5:
			return false
	var query := PhysicsRayQueryParameters3D.create(global_position, aim, blocking_mask)
	if body:
		query.exclude = [body.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == target
