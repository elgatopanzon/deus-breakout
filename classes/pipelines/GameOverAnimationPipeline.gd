# ABOUTME: Animates game over state -- overlay fades/scales in smoothly
# ABOUTME: Scheduled pipeline; triggers once on GameState.LOST

class_name GameOverAnimationPipeline extends DefaultPipeline

const FADE_DURATION = 0.3

static var played: bool = false

static func _requires(): return [GameState]

static func _stage_animate(context):
	if context.GameState.state != GameState.State.LOST:
		return
	if played:
		return
	played = true

	var world = context.world

	# Animate overlay fade-in
	var overlay = world.try_get_node("game_overlay")
	if overlay:
		overlay.pivot_offset = overlay.size * 0.5
		overlay.scale = Vector2.ZERO
		overlay.modulate.a = 0.0
		var tween = context._node.create_tween()
		tween.set_parallel(true)
		tween.tween_property(overlay, "scale", Vector2.ONE, FADE_DURATION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)
		tween.tween_property(overlay, "modulate:a", 1.0, FADE_DURATION)
