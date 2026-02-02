# ABOUTME: Plays crunch/shatter sound when a brick is destroyed
# ABOUTME: Injected before DamagePipeline._stage_apply; predicts destruction from pending Damage

class_name BrickBreakSoundPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_play(context):
	# Only fire on frames where damage is pending (before DamagePipeline drains it)
	if context.Damage.value <= 0:
		return

	# Predict outcome: will this brick be destroyed?
	if context.Health.value - context.Damage.value > 0:
		return

	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("brick_break"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	for player in pool.get_children():
		if not player.playing:
			player.stream = sb.streams["brick_break"]
			player.play()
			return
