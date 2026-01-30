######################################################################
# @author      : ElGatoPanzon
# @class       : PositionClampPipeline
# @created     : Thursday Jan 29, 2026 21:30:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : clamps position to viewport bounds and syncs node
######################################################################

class_name PositionClampPipeline extends DefaultPipeline

static func _requires(): return [Position, Size]

static func _stage_clamp(context):
	var pos = context.Position.value
	var size = context.Size.value
	var vp = context._node.get_viewport_rect().size
	pos.x = clampf(pos.x, 0.0, vp.x - size.x)
	pos.y = clampf(pos.y, 0.0, vp.y - size.y)
	context.Position.value = pos
	context._node.position = pos
