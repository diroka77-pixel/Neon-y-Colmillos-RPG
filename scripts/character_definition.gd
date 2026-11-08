extends Resource
## Future visual adapter. Canonical references must be reviewed equally for all three.
@export_enum("Diroka", "Sora", "Vane") var character_name: String = "Diroka"
@export var approved_sprite_frames: SpriteFrames
@export_multiline var canonical_reference: String = ""
@export var approved_for_game: bool = false

func can_integrate() -> bool:
	return approved_for_game and approved_sprite_frames != null and not canonical_reference.is_empty()
