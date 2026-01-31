######################################################################
# @author      : ElGatoPanzon
# @class       : WallReflectionPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : reflects ball velocity at top, left, and right edges
######################################################################

class_name WallReflectionPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity, Size]

static func _stage_reflect(context):
	var pos = context.Position.value
	var size = context.Size.value
	var vp = context._node.get_viewport_rect().size
	var dir = context.Velocity.direction

	# Reflect horizontally at left/right edges
	if pos.x <= 0.0 or pos.x + size.x >= vp.x:
		dir.x = -dir.x
		pos.x = clampf(pos.x, 0.0, vp.x - size.x)

	# Reflect vertically at top edge only (bottom = ball lost)
	if pos.y <= 0.0:
		dir.y = -dir.y
		pos.y = 0.0

	context.Velocity.direction = dir
	context.Position.value = pos
