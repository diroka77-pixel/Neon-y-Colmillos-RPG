extends Node2D
const World = preload("res://scripts/world_generator.gd")
var world: RefCounted

func _draw() -> void:
	for y in range(World.SIZE.y):
		for x in range(World.SIZE.x):
			var cell := Vector2i(x, y)
			var p: Vector2 = World.project(Vector2(cell))
			var tone := Color("182332") if (x + y) % 2 == 0 else Color("1b2737")
			if x == 0 or y == 0 or x == World.SIZE.x - 1 or y == World.SIZE.y - 1:
				tone = Color("394357")
			var diamond := PackedVector2Array([p, p + Vector2(24, 12), p + Vector2(0, 24), p + Vector2(-24, 12)])
			draw_colored_polygon(diamond, tone)
			draw_polyline(diamond, Color("223043"), 1)
			if world.blocked.has(cell):
				continue
			var detail := posmod(x * 73 + y * 37 + world.world_seed, 23)
			if detail < 4:
				var wet := Color("254256") if detail % 2 == 0 else Color("3a2b4c")
				draw_line(p + Vector2(-10, 12), p + Vector2(10, 12), wet, 2)
				draw_line(p + Vector2(-5, 15), p + Vector2(5, 15), wet, 1)
			if x % 8 == 7 and y % 3 == 0:
				draw_line(p + Vector2(-2, 9), p + Vector2(7, 14), Color("897d65"), 2)
			if detail == 7:
				for i in range(4):
					draw_line(p + Vector2(-5 + i * 3, 9), p + Vector2(-5 + i * 3, 15), Color("0d1827"), 1)
	for data in world.buildings:
		var rect: Rect2i = data.rect
		var p: Vector2 = World.project(Vector2(rect.end))
		draw_colored_polygon(PackedVector2Array([p, p + Vector2(30, 16), p + Vector2(85, -10), p + Vector2(48, -27)]), Color(0.015, 0.025, 0.055, 0.45))
		var accent: Color = Color("245365") if int(data.style) % 2 == 0 else Color("4c2947")
		for i in range(5):
			draw_line(p + Vector2(-48 + i * 7, 4 + i * 3), p + Vector2(-32 + i * 7, 4 + i * 3), accent, 1)
