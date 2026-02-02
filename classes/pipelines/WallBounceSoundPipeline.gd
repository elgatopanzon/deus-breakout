# ABOUTME: Plays short bounce blip when ball reflects off a wall
# ABOUTME: Injected after WallReflectionPipeline._stage_reflect; detects edge contact

class_name WallBounceSoundPipeline extends DefaultPipeline

static func _requires(): return [Position, Size]

static func _stage_play(context):
	var pos = context.Position.value
	var size = context.Size.value
	var vp = context._node.get_viewport_rect().size

	# Detect wall contact by checking if position is at an edge
	var hit = pos.x <= 0.0 or pos.x + size.x >= vp.x or pos.y <= 0.0
	if not hit:
		return

	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("wall_bounce"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	for player in pool.get_children():
		if not player.playing:
			player.stream = sb.streams["wall_bounce"]
			player.play()
			return
