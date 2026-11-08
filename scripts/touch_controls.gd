extends Control
signal interact_requested
signal reset_requested
var movement := Vector2.ZERO
var running := false
var finger := -1
var run_finger := -1
var origin := Vector2.ZERO
var radius := 64.0
var safe := Rect2()
var message: Label
var seed_label: Label
var interact_center := Vector2.ZERO
var run_center := Vector2.ZERO
var reset_rect := Rect2()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message = Label.new()
	message.add_theme_font_size_override("font_size", 17)
	message.add_theme_color_override("font_color", Color("b1c1d3"))
	add_child(message)
	seed_label = Label.new()
	seed_label.add_theme_font_size_override("font_size", 15)
	seed_label.add_theme_color_override("font_color", Color("69d6cd"))
	add_child(seed_label)
	resized.connect(layout)
	layout()

func layout() -> void:
	clear_input()
	var viewport_size := get_viewport_rect().size
	var inset := Vector2(24, 18)
	if OS.has_feature("android"):
		var physical := DisplayServer.get_display_safe_area()
		var window := Vector2(DisplayServer.window_get_size())
		if window.x > 0 and window.y > 0 and physical.size.x > 0:
			var scale_xy := viewport_size / window
			var left_top := Vector2(physical.position) * scale_xy
			var right_bottom := (window - Vector2(physical.end)) * scale_xy
			inset.x = maxf(inset.x, maxf(left_top.x, right_bottom.x) + 12)
			inset.y = maxf(inset.y, maxf(left_top.y, right_bottom.y) + 12)
	safe = Rect2(inset, viewport_size - inset * 2)
	origin = Vector2(safe.position.x + 88, safe.end.y - 86)
	interact_center = Vector2(safe.end.x - 68, safe.end.y - 75)
	run_center = interact_center + Vector2(-125, 16)
	reset_rect = Rect2(safe.end.x - 132, safe.position.y, 132, 46)
	message.position = safe.position + Vector2(16, 54)
	seed_label.position = safe.position + Vector2(16, 81)
	queue_redraw()

func clear_input() -> void:
	finger = -1
	run_finger = -1
	movement = Vector2.ZERO
	running = false
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		clear_input()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed:
			if event.index == finger:
				finger = -1
				movement = Vector2.ZERO
			if event.index == run_finger:
				run_finger = -1
				running = false
		elif reset_rect.has_point(event.position):
			reset_requested.emit()
		elif event.position.distance_to(interact_center) < 52:
			interact_requested.emit()
		elif event.position.distance_to(run_center) < 48 and run_finger == -1:
			run_finger = event.index
			running = true
		elif event.position.x < size.x * 0.52 and event.position.y > safe.position.y + 115 and finger == -1:
			finger = event.index
			origin = event.position.clamp(safe.position + Vector2(radius, 120), safe.end - Vector2(radius, radius))
			update_stick(event.position)
	if event is InputEventScreenDrag and event.index == finger:
		update_stick(event.position)
	queue_redraw()

func update_stick(point: Vector2) -> void:
	var raw := (point - origin).limit_length(radius) / radius
	var amount := raw.length()
	movement = raw.normalized() * ((amount - 0.12) / 0.88) if amount > 0.12 else Vector2.ZERO

func _draw() -> void:
	if safe.size == Vector2.ZERO:
		return
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(safe.position, Vector2(safe.size.x - 150, 106)), Color(0.025, 0.05, 0.09, 0.92))
	draw_rect(Rect2(safe.position, Vector2(3, 106)), Color("58d6cf"))
	draw_string(font, safe.position + Vector2(16, 30), "NEÓN Y COLMILLOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("e0e5ef"))
	draw_string(font, safe.position + Vector2(300, 30), "RPG / 0.2.0", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("8a9bac"))
	draw_rect(reset_rect, Color(0.03, 0.07, 0.12, 0.9))
	draw_rect(reset_rect, Color("476378"), false, 1)
	draw_string(font, reset_rect.position + Vector2(16, 29), "REINICIAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("b7c6d8"))
	draw_circle(origin, radius + 8, Color(0.03, 0.065, 0.10, 0.7))
	draw_arc(origin, radius, 0, TAU, 48, Color("547584"), 2)
	draw_line(origin - Vector2(14, 0), origin + Vector2(14, 0), Color("547584"), 1)
	draw_line(origin - Vector2(0, 14), origin + Vector2(0, 14), Color("547584"), 1)
	draw_circle(origin + movement * radius, 25, Color(0.27, 0.66, 0.68, 0.65))
	for item in [[run_center, "CORRER", 45.0], [interact_center, "USAR", 51.0]]:
		var center: Vector2 = item[0]
		var button_radius: float = item[2]
		draw_circle(center, button_radius, Color(0.035, 0.07, 0.11, 0.86))
		draw_arc(center, button_radius, 0, TAU, 48, Color("74b9c4") if running and item[1] == "CORRER" else Color("637c91"), 2)
		draw_string(font, center + Vector2(-32, 5), item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d9e3ed"))
