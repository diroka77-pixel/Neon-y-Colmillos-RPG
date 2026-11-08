extends Node2D
## Prototipo técnico: arte temporal, sin sprites canónicos.
const TILE := 32
const W := 54
const H := 38
const SPEED := 155.0
var seed_value := 1984
var rng := RandomNumberGenerator.new()
var blocks: Dictionary = {}
var hero := Vector2(12 * TILE, 12 * TILE)
var input_vector := Vector2.ZERO
var touch_origin := Vector2.ZERO
var touch_id := -1
var touch_vector := Vector2.ZERO
var camera: Camera2D
var status: Label

func _ready() -> void:
 rng.seed = seed_value
 _generate()
 camera = Camera2D.new()
 camera.zoom = Vector2(2, 2)
 add_child(camera)
 camera.make_current()
 var ui := CanvasLayer.new()
 add_child(ui)
 status = Label.new()
 status.position = Vector2(14, 12)
 status.text = "NEÓN Y COLMILLOS | v0.1.0 | prototipo visual temporal"
 ui.add_child(status)
 var hint := Label.new()
 hint.position = Vector2(14, 36)
 hint.text = "WASD / flechas o arrastra desde la zona izquierda"
 ui.add_child(hint)
 queue_redraw()

func _generate() -> void:
 blocks.clear()
 for x in range(W):
  for y in range(H):
   if x < 2 or y < 2 or x > W - 3 or y > H - 3:
    blocks[Vector2i(x,y)] = 1
   elif (x % 10 >= 3 and x % 10 <= 7) and (y % 9 >= 3 and y % 9 <= 6) and rng.randf() < 0.96:
    blocks[Vector2i(x,y)] = 1
 for x in range(9, 16):
  for y in range(9, 16):
   blocks.erase(Vector2i(x,y))

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed and event.position.x < get_viewport_rect().size.x * 0.55 and touch_id == -1:
   touch_id = event.index
   touch_origin = event.position
  elif not event.pressed and event.index == touch_id:
   touch_id = -1
   touch_vector = Vector2.ZERO
 if event is InputEventScreenDrag and event.index == touch_id:
  touch_vector = (event.position - touch_origin).limit_length(65.0) / 65.0

func _physics_process(delta: float) -> void:
 input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
 if touch_vector.length() > 0.08:
  input_vector = touch_vector
 var move := input_vector.normalized() * SPEED * delta
 var next_x := hero + Vector2(move.x, 0)
 if not _blocked(next_x): hero.x = next_x.x
 var next_y := hero + Vector2(0, move.y)
 if not _blocked(next_y): hero.y = next_y.y
 camera.global_position = hero.round()
 queue_redraw()

func _blocked(pos: Vector2) -> bool:
 for offset in [Vector2(-8,-5),Vector2(8,-5),Vector2(-8,5),Vector2(8,5)]:
  var cell := Vector2i((pos + offset) / TILE)
  if blocks.has(cell): return true
 return false

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO, Vector2(W*TILE,H*TILE)), Color("171725"))
 for x in range(W):
  for y in range(H):
   var at := Vector2(x*TILE,y*TILE)
   var cell := Vector2i(x,y)
   if blocks.has(cell):
    draw_rect(Rect2(at,Vector2(TILE,TILE)),Color("333545"))
    draw_rect(Rect2(at + Vector2(2,2),Vector2(28,7)),Color("4a4459"))
    if (x*7+y*11)%5==0:
     draw_rect(Rect2(at+Vector2(7,12),Vector2(8,12)),Color("17b5c3"))
     draw_rect(Rect2(at+Vector2(19,12),Vector2(5,12)),Color("c02eea"))
   else:
    draw_rect(Rect2(at,Vector2(TILE-1,TILE-1)),Color("25283a") if (x+y)%2==0 else Color("292b3b"))
    if (x*17+y*13)%19==0:
     draw_rect(Rect2(at+Vector2(12,12),Vector2(3,3)),Color("9c4aab"))
 draw_ellipse_shadow(hero + Vector2(0,9))
 draw_rect(Rect2(hero+Vector2(-7,-13),Vector2(14,19)),Color("12131c"))
 draw_rect(Rect2(hero+Vector2(-5,-17),Vector2(10,8)),Color("272737"))
 draw_rect(Rect2(hero+Vector2(-4,-12),Vector2(2,2)),Color("36e6b0"))
 draw_rect(Rect2(hero+Vector2(3,-12),Vector2(2,2)),Color("36e6b0"))

func draw_ellipse_shadow(center: Vector2) -> void:
 draw_circle(center, 10, Color(0,0,0,0.45))
