# ABOUTME: HUD sync pipeline — pushes Score and Lives values to HUD labels each frame
# ABOUTME: Scheduled pipeline; requires Score so it runs on the Deus node

class_name HUDSyncPipeline extends DefaultPipeline

static func _requires(): return [Score]

static func _stage_sync(context):
	var score = context.Score
	var lives = context.world.get_component(context.world, Lives)

	var score_label = context._node.get_tree().get_first_node_in_group("hud_score")
	if score_label:
		score_label.text = "Score: %d" % score.value

	var lives_label = context._node.get_tree().get_first_node_in_group("hud_lives")
	if lives_label:
		lives_label.text = "Lives: %d" % lives.value
