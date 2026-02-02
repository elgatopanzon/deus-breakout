# ABOUTME: Increments combo count on brick hit, resets decay timer, updates multiplier
# ABOUTME: Injected after BrickCollisionPipeline._stage_collide in collision chain

class_name ComboIncrementPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_increment(context):
	var combo = context.world.get_component(context.world, Combo)
	if combo == null:
		return

	var tiers = context.world.get_component(context.world, ComboTiers)

	combo.count += 1
	combo.timer = combo.decay_window

	# Look up multiplier from highest tier threshold <= count
	if tiers:
		combo.multiplier = 1.0
		var keys = tiers.tiers.keys()
		keys.sort()
		for threshold in keys:
			if combo.count >= threshold:
				combo.multiplier = tiers.tiers[threshold]

	context.world.set_component(context.world, Combo, combo)
