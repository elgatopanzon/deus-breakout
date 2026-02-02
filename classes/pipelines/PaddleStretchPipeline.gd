# ABOUTME: Squash-and-stretch on paddle Visual when ball deflects off it
# ABOUTME: Injected after DeflectPipeline._stage_deflect; tweens Visual scale

class_name PaddleStretchPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_stretch(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	# Only stretch on paddle (Deflector) hits
	if not context.world.component_registry.has_component(other_node, "Deflector"):
		return

	var visual = other_node.get_node_or_null("Visual")
	if visual == null:
		return

	# Center pivot for symmetric scaling
	visual.pivot_offset = visual.size * 0.5

	# Kill any active tween on this visual
	if visual.has_meta("stretch_tween"):
		var old_tween = visual.get_meta("stretch_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = visual.create_tween()
	visual.set_meta("stretch_tween", tween)
	tween.tween_property(visual, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.1) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
