# ABOUTME: Win check pipeline — sets GameState to WON when last brick is destroyed
# ABOUTME: Injected before DestructionPipeline._stage_destroy after ScoringPipeline

class_name WinCheckPipeline extends DefaultPipeline

static var _brick_cache: Array = []
static var _brick_cache_count: int = -1

static func _requires(): return []

static func _stage_check(context):
	if context.Health.value > 0:
		return

	# Re-query when cache is empty or count may have changed (brick destroyed)
	var registry = context.world.component_registry
	if _brick_cache.is_empty() or registry._cache_generation != _brick_cache_count:
		_brick_cache = registry.get_matching_nodes([Health], [])
		_brick_cache_count = registry._cache_generation

	# Brick still in registry (removed by _stage_destroy after us), so 1 = last brick
	if _brick_cache.size() > 1:
		return

	var gs = context.world.get_component(context.world, GameState)
	if gs:
		gs.state = GameState.State.WON
		context.world.set_component(context.world, GameState, gs)
