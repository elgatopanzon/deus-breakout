# ABOUTME: Plays UI click sound when RestartButton is pressed
# ABOUTME: Signal-driven via DeusConfiguration, not PauseGuarded (plays in any state)

class_name UIClickSoundPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_play(context):
	var sb = context.world.get_component(context.world, SoundBank)
	if sb == null or not sb.streams.has("ui_click"):
		return

	var pool = context._node.get_tree().get_first_node_in_group("audio_pool")
	if pool == null:
		return

	AudioPoolHelper.play(pool, sb.streams["ui_click"])
