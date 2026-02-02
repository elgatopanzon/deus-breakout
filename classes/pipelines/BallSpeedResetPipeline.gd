# ABOUTME: Resets ball speed curve elapsed timer on life lost
# ABOUTME: Injected after BallRespawnPipeline; BallRespawnPipeline already resets Velocity.speed

class_name BallSpeedResetPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_reset(context):
	var curve = context.world.get_component(context.world, BallSpeedCurve)
	if curve == null:
		return

	curve.elapsed = 0.0
	context.world.set_component(context.world, BallSpeedCurve, curve)
