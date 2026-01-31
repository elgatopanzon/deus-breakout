# ABOUTME: Lives decrement pipeline — decrements Lives singleton on DeusWorld
# ABOUTME: Injected into BallMissedPipeline; assumes detection already gated

class_name LivesDecrementPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_decrement(context):
	var lives = context.world.get_component(context.world, Lives)
	if lives == null:
		return

	lives.value -= 1
	context.world.set_component(context.world, Lives, lives)
