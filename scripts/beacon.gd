extends Node2D
var activated := false

func _draw() -> void:
	var accent := Color("73e2c4") if activated else Color("d888a8")
	draw_colored_polygon(PackedVector2Array([Vector2(-12, 0), Vector2(0, -6), Vector2(12, 0), Vector2(0, 6)]), Color("344158"))
	draw_rect(Rect2(-4, -19, 8, 19), Color("111d2d"))
	draw_rect(Rect2(-3, -18, 6, 9), accent)
	draw_line(Vector2(-7, 5), Vector2(7, 5), accent, 1)
