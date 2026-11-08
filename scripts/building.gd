extends Node2D
const World = preload("res://scripts/world_generator.gd")
var footprint: Rect2i
var height_px: float
var style: int
var front := Vector2.ZERO
var left := Vector2.ZERO
var right := Vector2.ZERO
var back := Vector2.ZERO
const ACCENTS := [Color("48c6cf"), Color("c65289"), Color("bba568"), Color("708fae")]

func configure(data: Dictionary) -> void:
	footprint = data.rect
	height_px = float(data.height)
	style = int(data.style)
	position = World.project(Vector2(footprint.end))
	left = World.project(Vector2(footprint.position.x, footprint.end.y)) - position
	right = World.project(Vector2(footprint.end.x, footprint.position.y)) - position
	back = World.project(Vector2(footprint.position)) - position
	queue_redraw()

func quad(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func _draw() -> void:
	var up := Vector2(0, -height_px)
	var accent: Color = ACCENTS[style]
	quad([left, front, front + up, left + up], Color("242c40"))
	quad([front, right, right + up, front + up], Color("141f30"))
	quad([left + up, back + up, right + up, front + up], Color("384253"))
	draw_polyline(PackedVector2Array([left + up, back + up, right + up, front + up, left + up]), Color("626479"), 1.0)
	draw_line(front, front + up, Color("687187"), 1.0)
	# Horizontal facade bands, perspective windows and shutters.
	for floor_index in range(1, int(height_px / 18.0)):
		var rise := Vector2(0, -floor_index * 18.0)
		draw_line(left + rise, front + rise, Color("394156"), 1.0)
		draw_line(front + rise, right + rise, Color("273147"), 1.0)
		for window_index in range(1, footprint.size.x * 2):
			var t := float(window_index) / float(footprint.size.x * 2)
			var p := left.lerp(front, t) + rise + Vector2(0, -11)
			var lit := (window_index + floor_index + style) % 4 != 0
			quad([p, p + Vector2(6, 3), p + Vector2(6, 10), p + Vector2(0, 7)], accent.darkened(0.35) if lit else Color("141d2c"))
		for window_index in range(1, footprint.size.y * 2):
			var t := float(window_index) / float(footprint.size.y * 2)
			var p := front.lerp(right, t) + rise + Vector2(0, -9)
			quad([p, p + Vector2(6, -3), p + Vector2(6, 4), p + Vector2(0, 7)], accent.darkened(0.6))
	# Roof machinery; all geometry remains authored in pixel coordinates.
	var center := (back + front) * 0.5 + up
	draw_rect(Rect2(center + Vector2(-16, -8), Vector2(27, 12)), Color("202c3b"))
	draw_rect(Rect2(center + Vector2(-16, -12), Vector2(27, 8)), Color("586173"))
	for i in range(5):
		draw_line(center + Vector2(-12 + i * 4, -11), center + Vector2(-12 + i * 4, -5), Color("283647"), 1)
	draw_line(center + Vector2(18, -5), center + Vector2(18, -25), Color("6d7181"), 2)
	draw_rect(Rect2(center + Vector2(16, -27), Vector2(4, 3)), accent)
	var sign := left.lerp(front, 0.5) + Vector2(0, -22)
	quad([sign + Vector2(-18, -9), sign + Vector2(18, 9), sign + Vector2(18, 18), sign + Vector2(-18, 0)], Color("101c2c"))
	draw_line(sign + Vector2(-16, -6), sign + Vector2(16, 10), accent, 2)
	for i in range(4):
		var p := sign + Vector2(-12 + i * 7, -2 + i * 3.5)
		draw_line(p, p + Vector2(0, 5), accent, 2)
	# Entry bay and drainpipe.
	var door := front.lerp(right, 0.45)
	quad([door, door + Vector2(12, -6), door + Vector2(12, -25), door + Vector2(0, -19)], Color("0a1523"))
	draw_line(door + Vector2(0, -20), door + Vector2(12, -26), accent, 2)
	draw_line(left + Vector2(6, 0), left + up + Vector2(6, 4), Color("797080"), 2)
