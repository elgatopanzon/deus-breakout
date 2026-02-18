# ABOUTME: Plays game over and win sounds on GameState transitions
# ABOUTME: Scheduled pipeline with previous_state tracking for debounce

class_name GameStateSoundPipeline extends DefaultPipeline

static var previous_state: int = GameState.State.STARTING

static func _requires(): return [GameState]

static func _stage_check(context):
	var current = context.GameState.state
	if current == previous_state:
		return

	previous_state = current

	var sound_id = ""
	if current == GameState.State.LOST:
		sound_id = "game_over"
	elif current == GameState.State.WON:
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
