######################################################################
# @author      : ElGatoPanzon
# @class       : DeflectPipeline
# @created     : Friday Jan 31, 2026 00:00:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : steers ball angle based on hit offset against a Deflector entity
######################################################################

class_name DeflectPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity, Size]

static func _stage_deflect(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	# Use the node directly if it's an entity, otherwise try parent
	var other_node = other if other.has_meta("id") else other.get_parent()

	# Only deflect if the other entity has the Deflector component
	if not context.world.component_registry.has_component(other_node, "Deflector"):
		return
	var deflector = context.world.component_registry.get_component(other_node, "Deflector")

	var other_size = context.world.component_registry.get_component(other_node, "Size")
	var other_pos = context.world.component_registry.get_component(other_node, "Position")
	if other_size == null or other_pos == null:
		return

	var ball_center_x = context.Position.value.x + context.Size.value.x * 0.5
	var deflector_center_x = other_pos.value.x + other_size.value.x * 0.5

	# Normalized offset: -1.0 (left edge) to 1.0 (right edge)
	var offset = (ball_center_x - deflector_center_x) / (other_size.value.x * 0.5)
	offset = clampf(offset, -1.0, 1.0)

	# Map offset to angle from vertical using deflector's max angle
	var angle = offset * deg_to_rad(deflector.max_angle_degrees)
	context.Velocity.direction = Vector2(sin(angle), -cos(angle)).normalized()
