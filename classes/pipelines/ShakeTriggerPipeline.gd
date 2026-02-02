# ABOUTME: Shake trigger pipeline — sets ScreenShake intensity on brick damage events
# ABOUTME: Injected before DamagePipeline; uses Damage > 0 to detect hits this frame

class_name ShakeTriggerPipeline extends DefaultPipeline

const HIT_INTENSITY := 3.0
const HIT_DURATION := 0.1
const DESTROY_INTENSITY := 8.0
const DESTROY_DURATION := 0.2

static func _requires(): return []

static func _stage_trigger(context):
	# Only fire on frames where damage is pending (before DamagePipeline drains it)
	if context.Damage.value <= 0:
		return

	var shake = context.world.get_component(context.world, ScreenShake)
	if shake == null:
		return

	# Predict outcome: will this brick survive the pending damage?
	var health_after = context.Health.value - context.Damage.value

	if health_after <= 0:
		# Destroy shake — always overrides hit shake
		shake.intensity = DESTROY_INTENSITY
		shake.duration = DESTROY_DURATION
		shake.timer = DESTROY_DURATION
		shake.active = true
	else:
		# Hit shake — max-takes-priority: only override if this shake is stronger
		if shake.active and shake.intensity >= HIT_INTENSITY:
			return
		shake.intensity = HIT_INTENSITY
		shake.duration = HIT_DURATION
		shake.timer = HIT_DURATION
		shake.active = true

	context.world.set_component(context.world, ScreenShake, shake)
