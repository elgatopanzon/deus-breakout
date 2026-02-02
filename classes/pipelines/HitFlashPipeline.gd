# ABOUTME: Hit flash pipeline — tweens brick visual to white then back to health color
# ABOUTME: Injected after BallDamagePipeline in the BrickCollisionPipeline chain

class_name HitFlashPipeline extends DefaultPipeline

const FLASH_DURATION := 0.08

static func _requires(): return []

static func _stage_flash(context):
	if context.Damage.value <= 0:
		return

	var node = context._node
	if node.get_meta("id", "") != "brick":
		return

	var visual = node.get_node_or_null("Visual")
	if visual == null:
		return

	var restore_color = BrickVisualSyncPipeline.color_for_health(
		context.Health.value - context.Damage.value
	)

	var tween = node.create_tween()
	tween.tween_property(visual, "color", Color.WHITE, 0.0)
	tween.tween_property(visual, "color", restore_color, FLASH_DURATION)
