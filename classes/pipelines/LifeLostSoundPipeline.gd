# ABOUTME: Plays descending sad tone when ball falls below paddle
# ABOUTME: Injected after BallMissedPipeline._stage_detect (before LivesDecrement)

class_name LifeLostSoundPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_play(context):
	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("life_lost"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	for player in pool.get_children():
		if not player.playing:
			player.stream = sb.streams["life_lost"]
			player.play()
			return
