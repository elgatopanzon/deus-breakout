# ABOUTME: Pause guard pipeline — cancels host pipeline when game is not playing
# ABOUTME: Injected before PaddleInputPipeline and BallMovementPipeline stages

class_name PauseGuardPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_guard(context):
	var game_state = context.world.get_component(context.world, GameState)
	if game_state == null:
		return

	if game_state.state != GameState.State.PLAYING:
		context.result.cancel("game not playing")
