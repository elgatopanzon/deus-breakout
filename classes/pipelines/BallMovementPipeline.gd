######################################################################
# @author      : ElGatoPanzon
# @class       : BallMovementPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : applies velocity to position (kinematic integration)
######################################################################

class_name BallMovementPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity]

static func _stage_move(context):
	var pos = context.Position.value
	pos += context.Velocity.direction * context.Velocity.speed * context.world.delta
	context.Position.value = pos
	context._node.position = pos
