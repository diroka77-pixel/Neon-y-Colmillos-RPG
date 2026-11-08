extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.reset_progress()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	var path := args[0] if not args.is_empty() else "res://build/preview.png"
	var error := root.get_texture().get_image().save_png(path)
	print("SCREENSHOT: ", error_string(error))
	quit(error)
