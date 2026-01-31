######################################################################
# @author      : ElGatoPanzon
# @class       : BallCollisionPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : reflects ball velocity upward on any area collision
######################################################################

class_name BallCollisionPipeline extends DefaultPipeline

static func _requires(): return [Velocity]

static func _stage_reflect(context):
	var dir = context.Velocity.direction
	dir.y = -abs(dir.y)
	context.Velocity.direction = dir
