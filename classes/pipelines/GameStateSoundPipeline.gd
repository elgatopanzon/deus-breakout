# ABOUTME: Plays game over and win sounds on GameState transitions
# ABOUTME: Event-driven via component_set signal; fires only when GameState changes

class_name GameStateSoundPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_play(context):
	var gs = context.world.get_component(context.world, GameState)
	if gs == null:
		return

	var sound_id = ""
	if gs.state == GameState.State.LOST:
		sound_id = "game_over"
	elif gs.state == GameState.State.WON:
		sound_id = "win"

	if sound_id.is_empty():
		return

	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has(sound_id):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	AudioPoolHelper.play(pool, sb.streams[sound_id])
