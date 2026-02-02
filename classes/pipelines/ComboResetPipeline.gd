# ABOUTME: Resets combo to zero on life lost
# ABOUTME: Injected after BallMissedPipeline._stage_detect

class_name ComboResetPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_reset(context):
	var combo = context.world.get_component(context.world, Combo)
	if combo == null:
		return

	combo.count = 0
	combo.timer = 0.0
	combo.multiplier = 1.0
	context.world.set_component(context.world, Combo, combo)
