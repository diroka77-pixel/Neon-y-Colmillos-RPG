extends Node2D
const World = preload("res://scripts/world_generator.gd")
const Ground = preload("res://scripts/ground.gd")
const Building = preload("res://scripts/building.gd")
const Player = preload("res://scripts/player.gd")
const Controls = preload("res://scripts/touch_controls.gd")
const Weather = preload("res://scripts/weather.gd")
const Beacon = preload("res://scripts/beacon.gd")
var world := World.new()
var player: Node2D
var controls: Control
var camera: Camera2D
var actors: Node2D
var beacons: Array[Node2D] = []
var buildings: Array[Node2D] = []
var world_seed := 1984
var active_count := 0
var toast_time := 0.0
var save_elapsed := 0.0
var movement_reported := false

func _ready() -> void:
	configure_keyboard()
	world.generate(world_seed)
	var ground := Ground.new()
	ground.world = world
	add_child(ground)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for data in world.buildings:
		var building := Building.new()
		building.configure(data)
		actors.add_child(building)
		buildings.append(building)
	for point in World.BEACONS:
		var beacon := Beacon.new()
		beacon.position = World.project(point)
		actors.add_child(beacon)
		beacons.append(beacon)
	player = Player.new()
	player.world = world
	actors.add_child(player)
	load_progress()
	player.step(0.0)
	camera = Camera2D.new()
	camera.zoom = Vector2(1.65, 1.65)
	camera.position = player.position
	add_child(camera)
	camera.make_current()
	var ui := CanvasLayer.new()
	add_child(ui)
	var weather := Weather.new()
	ui.add_child(weather)
	controls = Controls.new()
	ui.add_child(controls)
	controls.interact_requested.connect(interact)
	controls.reset_requested.connect(reset_progress)
	controls.seed_label.text = "SEMILLA %d · Explora con el joystick · Mantén CORRER para acelerar" % world_seed
	update_hint()
	get_tree().auto_accept_quit = false
	if OS.is_debug_build():
		print("NEON_READY seed=", world_seed)

func configure_keyboard() -> void:
	var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], "interact": [KEY_E, KEY_SPACE], "run": [KEY_SHIFT]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code in bindings[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(action, key)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		interact()

func _physics_process(delta: float) -> void:
	player.direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if controls.movement.length_squared() > 0:
		player.direction = controls.movement
	player.running = controls.running or Input.is_action_pressed("run")
	var previous_position: Vector2 = player.ground_position
	player.step(delta)
	if not movement_reported and player.ground_position.distance_to(previous_position) > 0.001:
		movement_reported = true
		if OS.is_debug_build():
			print("NEON_MOVED")
	for building in buildings:
		building.update_occlusion(player.position)
	camera.position = player.position
	toast_time = maxf(0, toast_time - delta)
	if toast_time == 0:
		update_hint()
	save_elapsed += delta
	if save_elapsed >= 5.0:
		save_elapsed = 0
		save_progress()

func nearest_beacon() -> int:
	for i in range(World.BEACONS.size()):
		if player.ground_position.distance_to(World.BEACONS[i]) < 1.7:
			return i
	return -1

func update_hint() -> void:
	var near := nearest_beacon()
	controls.message.text = "Terminal cerca: pulsa USAR / E · Exploración %d/3" % active_count if near >= 0 else "Explora las calles y activa los terminales · %d/3" % active_count

func interact() -> void:
	var index := nearest_beacon()
	if index < 0:
		controls.message.text = "Acércate a un terminal luminoso para usarlo."
	elif beacons[index].activated:
		controls.message.text = "Terminal ya registrado · %d/3" % active_count
	else:
		beacons[index].activated = true
		beacons[index].queue_redraw()
		active_count += 1
		if OS.is_debug_build():
			print("NEON_TERMINAL ", active_count)
		controls.message.text = "Terminal registrado · %d/3" % active_count if active_count < 3 else "Exploración completada · Los tres terminales están registrados."
		save_progress()
	toast_time = 3.0

func save_progress() -> void:
	if not is_instance_valid(player):
		return
	var config := ConfigFile.new()
	config.set_value("world", "seed", world_seed)
	config.set_value("world", "generator_version", 1)
	config.set_value("player", "position", player.ground_position)
	var states: Array[bool] = []
	for beacon in beacons:
		states.append(beacon.activated)
	config.set_value("player", "terminals", states)
	var error := config.save("user://progress.cfg")
	if error != OK:
		push_warning("No se pudo guardar el progreso: %s" % error_string(error))

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load("user://progress.cfg") != OK:
		return
	if config.get_value("world", "generator_version", 0) != 1 or config.get_value("world", "seed", 0) != world_seed:
		return
	var point: Variant = config.get_value("player", "position", World.SPAWN)
	if point is Vector2 and point.is_finite() and not world.is_blocked(point):
		player.ground_position = point
	var states: Variant = config.get_value("player", "terminals", [])
	if states is Array and states.size() == beacons.size():
		active_count = 0
		for i in range(beacons.size()):
			beacons[i].activated = states[i] == true
			if beacons[i].activated:
				active_count += 1

func reset_progress() -> void:
	controls.clear_input()
	player.ground_position = World.SPAWN
	player.step(0)
	active_count = 0
	for beacon in beacons:
		beacon.activated = false
		beacon.queue_redraw()
	save_progress()
	update_hint()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_progress()
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_progress()
		get_tree().quit()
