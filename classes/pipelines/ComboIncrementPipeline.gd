# ABOUTME: Increments combo count on brick hit, resets decay timer, updates multiplier
# ABOUTME: Injected after BrickCollisionPipeline._stage_collide in collision chain

class_name ComboIncrementPipeline extends DefaultPipeline

# Pre-sorted tier keys cached to avoid sorting on every brick hit
static var _sorted_tier_keys: Array = _init_sorted_keys()

static func _init_sorted_keys() -> Array:
	var keys = ComboTiers.new().tiers.keys()
	keys.sort()
	return keys

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
		for threshold in _sorted_tier_keys:
			if combo.count >= threshold:
				combo.multiplier = tiers.tiers[threshold]

	context.world.set_component(context.world, Combo, combo)
