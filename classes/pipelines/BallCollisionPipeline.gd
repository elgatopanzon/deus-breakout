######################################################################
# @author      : ElGatoPanzon
# @class       : BallCollisionPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : reflects ball velocity on any area collision
######################################################################

class_name BallCollisionPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity]

static func _stage_reflect(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	# Get collision shapes for normal derivation
	var ball_col = context._node.get_node_or_null("CollisionShape2D")
	var other_col = other_node.get_node_or_null("CollisionShape2D")
	if ball_col == null or other_col == null:
		return

	# Derive surface normal from shape geometry
	var diff = ball_col.global_position - other_col.global_position
	var other_half = Vector2.ZERO
	if other_col.shape is RectangleShape2D:
		other_half = other_col.shape.size * 0.5
	elif other_col.shape is CircleShape2D:
		other_half = Vector2(other_col.shape.radius, other_col.shape.radius)
	else:
		return

	# The axis where the ball is proportionally furthest outside determines the hit face
	var normal: Vector2
	var scale_x = abs(diff.x) / other_half.x if other_half.x > 0 else 0.0
	var scale_y = abs(diff.y) / other_half.y if other_half.y > 0 else 0.0
	if scale_x > scale_y:
		normal = Vector2(sign(diff.x), 0)
	else:
		normal = Vector2(0, sign(diff.y))

	# Only reflect if moving toward the surface
	var dir = context.Velocity.direction
	if dir.dot(normal) >= 0:
		return

	# Standard reflection: d' = d - 2(d·n)n
	context.Velocity.direction = (dir - 2.0 * dir.dot(normal) * normal).normalized()

	# Push ball out of collision surface to prevent multi-hit on next frame
	context.Position.value += normal * 3.0
