extends Node2D
## Neutral test probe, intentionally not a protagonist or a canonical implant design.
const World = preload("res://scripts/world_generator.gd")
const SPEED := 3.4
var ground_position := World.SPAWN
var direction := Vector2.ZERO
var running := false
var world: RefCounted

func step(delta: float) -> void:
	var screen_direction := direction.limit_length(1.0)
	var logical_direction := World.unproject(screen_direction).normalized() * screen_direction.length()
	var displacement := logical_direction * SPEED * (1.55 if running else 1.0) * delta
	# Substeps protect collision even during a slow physics frame.
	var count := maxi(1, ceili(displacement.length() / 0.1))
	for i in range(count):
		var step_move := displacement / float(count)
		var next := ground_position + Vector2(step_move.x, 0)
		if not world.is_blocked(next):
			ground_position.x = next.x
		next = ground_position + Vector2(0, step_move.y)
		if not world.is_blocked(next):
			ground_position.y = next.y
	position = World.project(ground_position).round()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-10, 0), Vector2(0, -4), Vector2(10, 0), Vector2(0, 4)]), Color("080e1c"))
	draw_line(Vector2(0, 0), Vector2(0, -10), Color("357181"), 1)
	draw_colored_polygon(PackedVector2Array([Vector2(-7, -13), Vector2(0, -20), Vector2(7, -13), Vector2(0, -6)]), Color("b5f2e9"))
	draw_colored_polygon(PackedVector2Array([Vector2(-4, -13), Vector2(0, -17), Vector2(4, -13), Vector2(0, -9)]), Color("238c9c"))
