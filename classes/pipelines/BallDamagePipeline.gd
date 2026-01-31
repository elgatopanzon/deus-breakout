# ABOUTME: Ball-specific damage source — validates ball identity then queues damage
# ABOUTME: Signal-triggered on area_entered, increments Damage accumulator

class_name BallDamagePipeline extends DefaultPipeline

static func _requires(): return [Damage]

static func _stage_damage(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	if other_node.get_meta("id") != "ball":
		return

	context.Damage.value += 1
