# ABOUTME: Win check pipeline — sets GameState to WON when last brick is destroyed
# ABOUTME: Injected before DestructionPipeline._stage_destroy after ScoringPipeline

class_name WinCheckPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_check(context):
	if context.Health.value > 0:
		return

	# Brick still in registry (removed by _stage_destroy after us), so 1 = last brick
	var remaining = context.world.component_registry.get_matching_nodes([Health], [])
	if remaining.size() > 1:
		return

	var gs = context.world.get_component(context.world, GameState)
	if gs:
		gs.state = GameState.State.WON
		context.world.set_component(context.world, GameState, gs)
