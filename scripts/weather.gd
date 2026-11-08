extends Node2D
var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed = fmod(elapsed + delta, 100.0)
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	for i in range(90):
		var x := fposmod(float(i * 73) - elapsed * 65.0, size.x + 20.0)
		var y := fposmod(float(i * 131) + elapsed * 250.0, size.y + 20.0)
		draw_line(Vector2(x, y), Vector2(x - 3, y + 8), Color(0.45, 0.65, 0.77, 0.20), 1)
