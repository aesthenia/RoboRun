extends Enemy

@export var fireball_scene: PackedScene
@export var rock_scene: PackedScene
@export var warning_scene: PackedScene
@export var target: Node3D
@export var arena_radius := 10.0

var active := false
var phase := 1

@onready var model: Node3D = $Model
@onready var alert: Label3D = $Alert


func start_fight() -> void:
	active = true
	Audio.play("boss_roar")
	attack_loop()


func attack_loop() -> void:
	var turn := 0
	while active and is_inside_tree():
		await wait(2.2 if phase == 1 else 1.4)
		if not active:
			return
		if turn % 2 == 0:
			await fan_attack()
		else:
			await rain_attack()
		turn += 1


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func fan_attack() -> void:
	alert.visible = true
	Audio.play("boss_roar", -6.0)
	await wait(0.7)
	alert.visible = false
	if not active:
		return
	var count := 5 if phase == 1 else 9
	var spread := deg_to_rad(50.0 if phase == 1 else 90.0)
	var to_player := target.global_position - global_position
	to_player.y = 0
	var base := atan2(to_player.x, to_player.z)
	for i in count:
		var a := base - spread / 2 + spread * i / (count - 1)
		var fb: Projectile = fireball_scene.instantiate()
		fb.direction = Vector3(sin(a), 0, cos(a))
		get_tree().current_scene.add_child(fb)
		fb.global_position = global_position + Vector3.UP * 1.2 + fb.direction * 2.5
	Audio.play("fireball")


func rain_attack() -> void:
	var count := 4 if phase == 1 else 7
	var spots := []
	for i in count:
		var p := target.global_position + Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
		if i == 0:
			p = target.global_position
		var flat := Vector2(p.x, p.z).limit_length(arena_radius - 1.0)
		spots.append(Vector3(flat.x, 0.05, flat.y))
	var marks := []
	for s in spots:
		var m: Node3D = warning_scene.instantiate()
		get_tree().current_scene.add_child(m)
		m.global_position = s
		marks.append(m)
	await wait(1.1)
	for m in marks:
		if is_instance_valid(m):
			m.queue_free()
	if not active:
		return
	for s in spots:
		var r: Node3D = rock_scene.instantiate()
		get_tree().current_scene.add_child(r)
		r.global_position = s + Vector3.UP * 9.0


func take_hit(dmg: int) -> void:
	if not active:
		return
	super(dmg)


func on_hurt() -> void:
	Audio.play("boss_hit")
	if phase == 1 and hp <= max_hp / 2:
		phase = 2
		Audio.play("boss_roar")
		GameManager.message.emit("Король в ярости!")


func on_death() -> void:
	active = false
	alert.visible = false
	Audio.play("explosion")
	collision_layer = 0
	var tw := create_tween()
	tw.tween_property(model, "scale", Vector3.ZERO, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	GameManager.boss_defeated()


func _physics_process(delta: float) -> void:
	if target and hp > 0:
		var d := target.global_position - global_position
		model.rotation.y = lerp_angle(model.rotation.y, atan2(d.x, d.z), 3.0 * delta)
