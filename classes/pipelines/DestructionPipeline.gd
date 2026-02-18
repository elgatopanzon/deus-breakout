# ABOUTME: Destruction pipeline — removes entities with Health <= 0
# ABOUTME: Scheduled after DamagePipeline; ScoringPipeline injects before _stage_destroy

class_name DestructionPipeline extends DefaultPipeline

static func _requires(): return [Health]

static func _stage_destroy(context):
	if context.Health.value > 0:
		return
	var reg = context.world.component_registry
	var node = context._node

	# Kill any active BrickSqueezePipeline tweens before destruction
	var visual = node.get_node_or_null("Visual")
	if visual and visual.has_meta("squeeze_tween"):
		var tween = visual.get_meta("squeeze_tween")
		if tween and tween.is_valid():
			tween.kill()

	# Batch-remove all components with single cache invalidation
	reg.remove_all_components(node)
	# Cancel result so PipelineManager doesn't re-commit cached components
	context.result.cancel("entity destroyed")
	node.queue_free()
