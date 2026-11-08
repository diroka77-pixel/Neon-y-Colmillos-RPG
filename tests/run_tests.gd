extends SceneTree
const World = preload("res://scripts/world_generator.gd")
const Player = preload("res://scripts/player.gd")
const Controls = preload("res://scripts/touch_controls.gd")
const Definition = preload("res://scripts/character_definition.gd")
var failures := 0
var checks := 0

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := World.new()
	world.generate(1984)
	var fingerprint := world.fingerprint()
	world.generate(1984)
	check(world.fingerprint() == fingerprint, "Repeat generation resets local RNG")
	world.generate(1985)
	check(world.fingerprint() != fingerprint, "Different seeds vary buildings")
	for seed_value in range(50):
		world.generate(seed_value)
		check(not world.is_blocked(World.SPAWN), "Spawn clear: %d" % seed_value)
		var reached: Dictionary = {}
		var pending: Array[Vector2i] = [Vector2i(World.SPAWN)]
		reached[pending[0]] = true
		var index := 0
		while index < pending.size():
			var point := pending[index]
			index += 1
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next: Vector2i = point + offset
				if not reached.has(next) and not world.is_blocked(Vector2(next) + Vector2(0.5, 0.5)):
					reached[next] = true
					pending.append(next)
		var walkable := 0
		for y in range(1, World.SIZE.y - 1):
			for x in range(1, World.SIZE.x - 1):
				if not world.is_blocked(Vector2(x + 0.5, y + 0.5)):
					walkable += 1
		check(reached.size() == walkable, "All streets connected: %d" % seed_value)
		for point in World.BEACONS:
			check(reached.has(Vector2i(point)), "Reachable terminal: %d" % seed_value)
	world.generate(1984)
	check(world.is_blocked(Vector2(-0.1, 15)), "Negative border blocks")
	check(world.is_blocked(Vector2(40, 15)), "Far border blocks")
	for point in [Vector2.ZERO, World.SPAWN, Vector2(3.75, 27.125)]:
		check(World.unproject(World.project(point)).is_equal_approx(point), "Projection roundtrip")
	var player := Player.new()
	player.world = world
	player.ground_position = Vector2(15.5, 15.5)
	player.direction = Vector2.RIGHT * 0.5
	player.step(0.1)
	var half_distance := player.ground_position.distance_to(Vector2(15.5, 15.5))
	player.ground_position = Vector2(15.5, 15.5)
	player.direction = Vector2.RIGHT
	player.step(0.1)
	check(is_equal_approx(player.ground_position.distance_to(Vector2(15.5, 15.5)), half_distance * 2), "Analog speed preserved")
	player.ground_position = Vector2(1.5, 1.5)
	player.direction = Vector2.UP
	player.step(4.0)
	check(not world.is_blocked(player.ground_position), "Large delta cannot escape border")
	player.ground_position = Vector2(6.5, 3.5)
	player.direction = World.project(Vector2(-1, 0)).normalized()
	player.step(1.0)
	check(not world.is_blocked(player.ground_position) and player.ground_position.x > 5.0, "Building cannot be tunnelled through")
	player.free()
	var controls := Controls.new()
	root.add_child(controls)
	await process_frame
	var touch := InputEventScreenTouch.new()
	touch.index = 2
	touch.position = controls.origin
	touch.pressed = true
	controls._input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = controls.origin + Vector2(64, 0)
	controls._input(drag)
	check(controls.movement.x > 0.99, "Touch joystick full travel")
	var second := InputEventScreenTouch.new()
	second.index = 3
	second.position = controls.run_center
	second.pressed = true
	controls._input(second)
	check(controls.running and controls.movement.x > 0.99, "Two fingers: move and run")
	second.pressed = false
	controls._input(second)
	check(not controls.running and controls.movement.x > 0.99, "Run release keeps joystick")
	touch.pressed = false
	controls._input(touch)
	check(controls.movement == Vector2.ZERO, "Touch release stops")
	controls.movement = Vector2.ONE
	controls.running = true
	controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(controls.movement == Vector2.ZERO and not controls.running, "Focus loss clears input")
	controls.free()
	var definition := Definition.new()
	check(not definition.can_integrate(), "Canonical art gated until explicitly approved")
	# Real scene: wiring, terminal use, save/load and same-seed reset.
	var scene: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.reset_progress()
	var occlusion_checked := false
	for building in scene.buildings:
		var inside: Vector2 = building.position + (building.front + building.back) * 0.5 + Vector2(0, -10)
		building.update_occlusion(inside)
		if building.modulate.a < 0.5:
			occlusion_checked = true
		building.update_occlusion(Vector2(-10000, -10000))
		check(is_equal_approx(building.modulate.a, 1.0), "Facade restores opacity outside silhouette")
	check(occlusion_checked, "Foreground facades reveal marker")
	scene.interact()
	check(scene.active_count == 1, "Terminal activation")
	scene.interact()
	check(scene.active_count == 1, "No duplicate terminal activation")
	scene.save_progress()
	scene.active_count = 0
	scene.load_progress()
	check(scene.active_count == 1, "Saved progress reload")
	scene.reset_progress()
	check(scene.world.fingerprint() == fingerprint and scene.active_count == 0, "Reset keeps deterministic world")
	scene.free()
	print("TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
