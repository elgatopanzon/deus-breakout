# ABOUTME: Animates win state -- remaining bricks explode outward, overlay scales in
# ABOUTME: Oneshot pipeline injected after WinCheckPipeline; fires once on WON then deregisters

class_name WinAnimationPipeline extends DefaultPipeline

const BRICK_FLY_DURATION = 0.5
const OVERLAY_SCALE_DURATION = 0.4

static func _requires(): return []

static func _stage_animate(context):
	var gs = context.world.get_component(context.world, GameState)
	if gs == null or gs.state != GameState.State.WON:
		context.result.cancel("not won")
		return

	var world = context.world
	var vp = context._node.get_viewport().get_visible_rect().size
	var center = vp * 0.5

	# Explode remaining bricks outward from center
	var bricks = world.component_registry.get_matching_nodes([Health], [])
	for brick in bricks:
		var dir = (brick.position - center).normalized()
		var target = brick.position + dir * 600.0
		var brick_tween = context._node.create_tween()
		brick_tween.set_parallel(true)
		brick_tween.tween_property(brick, "position", target, BRICK_FLY_DURATION) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
		brick_tween.tween_property(brick, "rotation", randf_range(-3.0, 3.0), BRICK_FLY_DURATION)
		brick_tween.tween_property(brick, "modulate:a", 0.0, BRICK_FLY_DURATION)

	# Animate overlay scale-in with overshoot
	var overlay = world.try_get_node("game_overlay")
	if overlay:
		overlay.pivot_offset = overlay.size * 0.5
		overlay.scale = Vector2.ZERO
		var overlay_tween = context._node.create_tween()
		overlay_tween.tween_interval(0.15)
		overlay_tween.tween_property(overlay, "scale", Vector2.ONE, OVERLAY_SCALE_DURATION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)
