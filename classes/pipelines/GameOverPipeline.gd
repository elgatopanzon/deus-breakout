# ABOUTME: Game over pipeline — sets GameState to LOST when lives reach zero
# ABOUTME: Injected into BallMissedPipeline after LivesDecrementPipeline

class_name GameOverPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_check(context):
	var lives = context.world.get_component(context.world, Lives)
	if lives == null or lives.value > 0:
		return

	var gs = context.world.get_component(context.world, GameState)
	if gs:
		gs.state = GameState.State.LOST
		context.world.set_component(context.world, GameState, gs)
