# ABOUTME: Brick collision gate — validates area_entered is from a ball
# ABOUTME: Signal-driven entry point; DamagePipeline and DestructionPipeline injected into chain

class_name BrickCollisionPipeline extends DefaultPipeline

# Health + Damage required so injected DamagePipeline and DestructionPipeline share root context
static func _requires(): return [Health, Damage]

static func _stage_collide(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		context.result.cancel("no collision payload")
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	if other_node.get_meta("id") != "ball":
		context.result.cancel("not a ball collision")
		return
