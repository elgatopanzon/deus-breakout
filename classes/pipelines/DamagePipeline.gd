# ABOUTME: Generic damage pipeline — drains Damage into Health each frame
# ABOUTME: Scheduled on OnUpdate, no-ops when Damage is zero

class_name DamagePipeline extends DefaultPipeline

static func _requires(): return [Health, Damage]

static func _stage_apply(context):
	if context.Damage.value <= 0:
		return
	context.Health.value -= context.Damage.value
	context.Damage.value = 0
	if context.Health.value <= 0:
		var reg = context.world.component_registry
		var node = context._node
		# Remove components (duplicate avoids mutate-during-iterate in remove_all_components)
		if reg.node_components.has(node):
			for comp_name in reg.node_components[node].duplicate():
				reg.remove_component(node, comp_name)
		# Cancel result so PipelineManager doesn't re-commit cached components
		context.result.cancel("entity destroyed")
		node.queue_free()
