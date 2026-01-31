######################################################################
# @author      : ElGatoPanzon
# @class       : BallCollisionPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : reflects ball velocity on paddle/brick collision
######################################################################

class_name BallCollisionPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity, Size]

static func _stage_reflect(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other.get_parent() if other is Area2D else other
	var other_id = other_node.get_meta("id") if other_node.has_meta("id") else ""

	var dir = context.Velocity.direction

	if other_id == "paddle":
		# Reflect upward, angle based on paddle hit position
		var ball_center_x = context.Position.value.x + context.Size.value.x * 0.5
		var paddle_pos = other_node.position
		var paddle_size_comp = context.world.component_registry.get_component(other_node, "Size")
		var paddle_width = paddle_size_comp.value.x if paddle_size_comp else 120.0
		var paddle_center_x = paddle_pos.x + paddle_width * 0.5

		# Normalized offset: -1.0 (left edge) to 1.0 (right edge)
		var offset = (ball_center_x - paddle_center_x) / (paddle_width * 0.5)
		offset = clampf(offset, -1.0, 1.0)

		# Map offset to angle: -60 to +60 degrees from vertical
		var angle = offset * deg_to_rad(60.0)
		dir = Vector2(sin(angle), -cos(angle)).normalized()
	else:
		# Generic collision: reflect vertically
		dir.y = -abs(dir.y)

	context.Velocity.direction = dir
