# ABOUTME: Plays ping/blip when ball bounces off paddle
# ABOUTME: Injected after DeflectPipeline._stage_deflect; frame-debounced

class_name PaddleHitSoundPipeline extends DefaultPipeline

static var last_played_frame: int = -1

static func _requires(): return []

static func _stage_play(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	# Debounce: only play once per frame (collision overlap may persist)
	var frame = Engine.get_process_frames()
	if frame == last_played_frame:
		return
	last_played_frame = frame

	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("paddle_hit"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	for player in pool.get_children():
		if not player.playing:
			player.stream = sb.streams["paddle_hit"]
			player.play()
			return
