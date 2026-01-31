# ABOUTME: Game over pipeline — restarts scene when lives reach zero
# ABOUTME: Injected into BallMissedPipeline after LivesDecrementPipeline

class_name GameOverPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_check(context):
	var lives = context.world.get_component(context.world, Lives)
	if lives == null or lives.value > 0:
		return

	context._node.get_tree().reload_current_scene()
