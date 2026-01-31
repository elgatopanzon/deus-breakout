# ABOUTME: Ball missed detection — gates on ball reaching viewport bottom edge
# ABOUTME: Cancels if ball is not at bottom; injected pipelines handle consequences

class_name BallMissedPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity, Size]

static func _stage_detect(context):
	var vp = context._node.get_viewport_rect().size
	var bottom_clamp = vp.y - context.Size.value.y
	if context.Position.value.y < bottom_clamp:
		context.result.cancel("ball not at bottom")
