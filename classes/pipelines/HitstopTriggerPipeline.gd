# ABOUTME: Triggers hitstop freeze when a brick is destroyed
# ABOUTME: Injected before DestructionPipeline; scales duration by combo multiplier

class_name HitstopTriggerPipeline extends DefaultPipeline

static func _requires(): return [Health]

static func _stage_trigger(context):
	if context.ReadOnlyHealth.value > 0:
		return

	var hitstop = context.world.get_component(context.world, Hitstop)
	if hitstop == null:
		return

	var combo = context.world.get_component(context.world, Combo)
	var combo_scale = 1.0
	if combo:
		combo_scale = 1.0 + combo.multiplier * 0.5

	var new_duration = hitstop.base_duration * combo_scale

	# Extend if already active, don't shorten
	if hitstop.active:
		hitstop.duration = maxf(hitstop.duration, new_duration)
		return

	hitstop.active = true
	hitstop.duration = new_duration
	context.world.set_component(context.world, Hitstop, hitstop)

	# Freeze and schedule restore via process-always timer
	Engine.time_scale = 0.0
	var tree = context._node.get_tree()
	tree.create_timer(new_duration, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0
		var hs = context.world.get_component(context.world, Hitstop)
		if hs:
			hs.active = false
			hs.duration = 0.0
			hs.timer = 0.0
			context.world.set_component(context.world, Hitstop, hs)
	)
