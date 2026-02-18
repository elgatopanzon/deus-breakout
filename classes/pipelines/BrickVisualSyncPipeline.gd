# ABOUTME: Syncs brick visual color when Health changes (injected after DamagePipeline)
# ABOUTME: Maps HP tiers to colors for visual damage feedback

class_name BrickVisualSyncPipeline extends DefaultPipeline

static var HEALTH_COLORS = {
	3: Color(0.2, 0.8, 0.2, 1),   # green
	2: Color(0.9, 0.7, 0.1, 1),   # yellow
	1: Color(0.8, 0.2, 0.2, 1),   # red
}

static func _requires(): return [Health]

static func color_for_health(hp: int) -> Color:
	if HEALTH_COLORS.has(hp):
		return HEALTH_COLORS[hp]
	return HEALTH_COLORS[1]

static func _stage_sync(context):
	# Skip when no damage was pending (DamagePipeline already drained Damage to 0)
	if context.ReadOnlyDamage.value <= 0:
		return
	if context._node.get_meta("id") != "brick":
		return
	var visual = context._node.get_node_or_null("Visual")
	if visual == null:
		return
	visual.color = color_for_health(context.Health.value)
