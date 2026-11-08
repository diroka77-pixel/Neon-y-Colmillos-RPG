extends RefCounted
## Coordinates are logical ground tiles. Visual projection never changes collision data.
const SIZE := Vector2i(40, 32)
const SPAWN := Vector2(18.5, 15.5)
const BEACONS := [Vector2(18.5, 14.5), Vector2(26.5, 14.5), Vector2(18.5, 22.5)]
var blocked: Dictionary = {}
var buildings: Array[Dictionary] = []
var world_seed: int = 1984

static func project(point: Vector2) -> Vector2:
	return Vector2((point.x - point.y) * 24.0, (point.x + point.y) * 12.0)

static func unproject(point: Vector2) -> Vector2:
	return Vector2(point.x / 48.0 + point.y / 24.0, point.y / 24.0 - point.x / 48.0)

func generate(value: int) -> void:
	world_seed = value
	blocked.clear()
	buildings.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = value
	# Whole rectangular footprints: wide connected streets, no random sealed pockets.
	for y in range(2, SIZE.y - 4, 8):
		for x in range(2, SIZE.x - 4, 8):
			var footprint := Rect2i(x, y, rng.randi_range(3, 4), rng.randi_range(3, 4))
			buildings.append({"rect": footprint, "height": rng.randi_range(42, 78), "style": rng.randi_range(0, 3)})
			for cy in range(footprint.position.y, footprint.end.y):
				for cx in range(footprint.position.x, footprint.end.x):
					blocked[Vector2i(cx, cy)] = true

func is_blocked(point: Vector2, radius: float = 0.19) -> bool:
	for offset in [Vector2(-radius, -radius), Vector2(radius, -radius), Vector2(-radius, radius), Vector2(radius, radius)]:
		var cell := Vector2i((point + offset).floor())
		if cell.x < 1 or cell.y < 1 or cell.x >= SIZE.x - 1 or cell.y >= SIZE.y - 1 or blocked.has(cell):
			return true
	return false

func fingerprint() -> String:
	# Only ordered generated data; no Dictionary iteration or visual RNG dependence.
	return JSON.stringify(buildings).sha256_text()
