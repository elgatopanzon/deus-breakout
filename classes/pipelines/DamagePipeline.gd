# ABOUTME: Generic damage pipeline — drains Damage into Health each frame
# ABOUTME: Scheduled on OnUpdate, no-ops when Damage is zero

class_name DamagePipeline extends DefaultPipeline

static func _requires(): return [Health, Damage]

static func _stage_apply(context):
	if context.Damage.value <= 0:
		return
	context.Health.value -= context.Damage.value
	context.Damage.value = 0
