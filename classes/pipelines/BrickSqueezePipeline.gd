# ABOUTME: Squeeze-and-bounce on brick Visual when brick takes damage but survives
# ABOUTME: Injected before DamagePipeline._stage_apply to check pending Damage; tweens Visual scale

class_name BrickSqueezePipeline extends DefaultPipeline

static func _requires(): return [Health, Damage]

static func _stage_squeeze(context):
	# Only squeeze if damage is pending (runs before DamagePipeline._stage_apply)
	if context.Damage.value <= 0:
		return

	# Only squeeze if brick will survive the hit
	if context.Health.value - context.Damage.value <= 0:
		return

	var visual = context._node.get_node_or_null("Visual")
	if visual == null:
		return

	# Kill any active tween on this visual
	if visual.has_meta("squeeze_tween"):
		var old_tween = visual.get_meta("squeeze_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = visual.create_tween()
	visual.set_meta("squeeze_tween", tween)

	# Squeeze: scale to (1.1, 0.7) over 0.03s
	tween.tween_property(visual, "scale", Vector2(1.1, 0.7), 0.03)

	# Bounce back: scale to (1.0, 1.0) over 0.08s
	tween.tween_property(visual, "scale", Vector2.ONE, 0.08) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
