######################################################################
# @author      : ElGatoPanzon
# @class       : PaddleInputPipeline
# @created     : Thursday Jan 29, 2026 20:45:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : reads horizontal input into InputIntent component
######################################################################

class_name PaddleInputPipeline extends DefaultPipeline

static func _requires(): return [InputIntent]

static func _stage_read_input(context):
	context.InputIntent.direction = Input.get_axis("ui_left", "ui_right")
