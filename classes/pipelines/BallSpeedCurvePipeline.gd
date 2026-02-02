# ABOUTME: Gradually increases ball speed over gameplay time via linear ramp
# ABOUTME: Scheduled pipeline; reads BallSpeedCurve singleton for ramp parameters

class_name BallSpeedCurvePipeline extends DefaultPipeline

static func _requires(): return [Velocity]

static func _stage_ramp(context):
	var curve = context.world.get_component(context.world, BallSpeedCurve)
	if curve == null:
		return

	curve.elapsed += context.world.delta
	var target_speed = curve.base_speed + curve.ramp_rate * curve.elapsed
	target_speed = minf(target_speed, curve.max_speed)
	context.Velocity.speed = target_speed
	context.world.set_component(context.world, BallSpeedCurve, curve)
