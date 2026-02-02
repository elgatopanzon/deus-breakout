# ABOUTME: Ticks down combo timer each frame; resets combo when decay window expires
# ABOUTME: Scheduled pipeline; requires Combo so it runs on Deus node

class_name ComboDecayPipeline extends DefaultPipeline

static func _requires(): return [Combo]

static func _stage_decay(context):
	if context.Combo.count <= 0:
		return

	context.Combo.timer -= context.world.delta
	if context.Combo.timer <= 0.0:
		context.Combo.count = 0
		context.Combo.timer = 0.0
		context.Combo.multiplier = 1.0
