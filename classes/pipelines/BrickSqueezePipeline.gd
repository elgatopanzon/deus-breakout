# ABOUTME: Squeeze-and-bounce on brick Visual when brick takes damage but survives
# ABOUTME: Injected after DamagePipeline._stage_apply; tweens Visual scale

class_name BrickSqueezePipeline extends DefaultPipeline

static func _requires(): return [Health]

static func _stage_squeeze(context):
	# Only squeeze if brick survived the hit
	if context.Health.value <= 0:
		return

	var visual = context._node.get_node_or_null("Visual")
	if visual == null:
		return

	# Center pivot for symmetric scaling
	visual.pivot_offset = visual.size * 0.5

	# Kill any active tween on this visual
	if visual.has_meta("squeeze_tween"):
		var old_tween = visual.get_meta("squeeze_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = visual.create_tween()
	visual.set_meta("squeeze_tween", tween)
	tween.tween_property(visual, "scale", Vector2(1.1, 0.7), 0.03)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.08) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
