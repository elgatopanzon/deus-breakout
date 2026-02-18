# ABOUTME: Animates game over state -- overlay fades/scales in smoothly
# ABOUTME: Oneshot injected after GameOverPipeline; deregisters after firing once

class_name GameOverAnimationPipeline extends DefaultPipeline

const FADE_DURATION = 0.3

static func _requires(): return []

static func _stage_animate(context):
	var gs = context.world.get_component(context.world, GameState)
	if gs == null or gs.state != GameState.State.LOST:
		return

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
