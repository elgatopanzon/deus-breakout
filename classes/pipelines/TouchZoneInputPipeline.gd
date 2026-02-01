# ABOUTME: Detects screen touch/click within a touch zone Control node's rect
# ABOUTME: Sets TouchZone.pressed based on pointer position overlap

class_name TouchZoneInputPipeline extends DefaultPipeline

static func _requires(): return [TouchZone]

static func _stage_detect_touch(context):
	context.TouchZone.pressed = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = context._node.get_viewport().get_mouse_position()
		var rect = context._node.get_global_rect()
		if rect.has_point(mouse_pos):
			context.TouchZone.pressed = true
