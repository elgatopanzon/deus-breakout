# ABOUTME: Scoring pipeline — increments Score when bricks are destroyed
# ABOUTME: Injected before DestructionPipeline._stage_destroy via inject_pipeline

class_name ScoringPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_score(context):
	if context.Health.value > 0:
		return

	var points = context._node.get_meta("points", 0)
	if points <= 0:
		return

	var score = context.world.get_component(context.world, Score)
	if score == null:
		return

	score.value += points
	context.world.set_component(context.world, Score, score)
