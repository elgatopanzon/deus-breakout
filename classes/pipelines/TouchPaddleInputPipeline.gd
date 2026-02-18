# ABOUTME: Reads active touch zones and overrides paddle InputIntent direction
# ABOUTME: Runs after PaddleInputPipeline so touch input takes priority over keyboard

class_name TouchPaddleInputPipeline extends DefaultPipeline

static var _touch_zone_cache: Array = []

static func _requires(): return [InputIntent]

static func _stage_read_touch(context):
	if _touch_zone_cache.is_empty():
		_touch_zone_cache = context.world.component_registry.get_matching_nodes([TouchZone], [])
	for node in _touch_zone_cache:
		var zone = context.world.get_component(node, TouchZone)
		if zone.pressed:
			context.InputIntent.direction = zone.direction
			return
