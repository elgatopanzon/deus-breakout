######################################################################
# @author      : ElGatoPanzon
# @class       : MovementPipeline
# @created     : Thursday Jan 29, 2026 21:30:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : translates InputIntent into position change
######################################################################

class_name MovementPipeline extends DefaultPipeline

static func _requires(): return [Position, Speed, InputIntent]

static func _stage_apply_movement(context):
	var pos = context.Position.value
	pos.x += context.InputIntent.direction * context.Speed.value * context.world.delta
	context.Position.value = pos
