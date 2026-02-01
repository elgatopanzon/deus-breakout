# ABOUTME: Reads active touch zones and overrides paddle InputIntent direction
# ABOUTME: Runs after PaddleInputPipeline so touch input takes priority over keyboard

class_name TouchPaddleInputPipeline extends DefaultPipeline

static func _requires(): return [InputIntent]

static func _stage_read_touch(context):
	var touch_nodes = context.world.component_registry.get_matching_nodes([TouchZone], [])
	for node in touch_nodes:
		var zone = context.world.get_component(node, TouchZone)
		if zone.pressed:
			context.InputIntent.direction = zone.direction
			return
