# ABOUTME: Plays ball launch ascending blip on respawn after life lost
# ABOUTME: Injected after BallRespawnPipeline._stage_respawn

class_name BallLaunchSoundPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_play(context):
	var lives = context.world.get_component(context.world, Lives)
	if lives == null or lives.value <= 0:
		return

	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("ball_launch"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	for player in pool.get_children():
		if not player.playing:
			player.stream = sb.streams["ball_launch"]
			player.play()
			return
