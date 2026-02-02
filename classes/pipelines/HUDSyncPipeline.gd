# ABOUTME: HUD sync pipeline — pushes Score and Lives values to HUD labels each frame
# ABOUTME: Scheduled pipeline; requires Score so it runs on the Deus node

class_name HUDSyncPipeline extends DefaultPipeline

static func _requires(): return [Score]

static func _stage_sync(context):
	var score = context.world.get_component(context.world, Score)
	var lives = context.world.get_component(context.world, Lives)
	if score == null or lives == null:
		return

	var score_label = context.world.try_get_node("hud_score")
	if score_label:
		score_label.text = "Score: %d" % score.value

	var lives_label = context.world.try_get_node("hud_lives")
	if lives_label:
		lives_label.text = "Lives: %d" % lives.value

	var combo = context.world.get_component(context.world, Combo)
	var combo_label = context.world.try_get_node("hud_combo")
	if combo_label and combo:
		if combo.count > 0:
			combo_label.text = "Combo: %dx" % combo.count
			combo_label.visible = true
		else:
			combo_label.visible = false
