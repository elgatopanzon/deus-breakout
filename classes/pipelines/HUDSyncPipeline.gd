# ABOUTME: HUD sync pipeline — pushes Score, Lives, and Combo values to HUD labels
# ABOUTME: Uses dirty-flag change detection to skip string formatting on unchanged frames

class_name HUDSyncPipeline extends DefaultPipeline

static var _last_score: int = -1
static var _last_lives: int = -1
static var _last_combo: int = -1

static func _requires(): return [Score]

static func _stage_sync(context):
	var score = context.world.get_component(context.world, Score)
	var lives = context.world.get_component(context.world, Lives)
	if score == null or lives == null:
		return

	if score.value != _last_score:
		var score_label = context.world.try_get_node("hud_score")
		if score_label:
			score_label.text = "Score: %d" % score.value
			_last_score = score.value

	if lives.value != _last_lives:
		var lives_label = context.world.try_get_node("hud_lives")
		if lives_label:
			lives_label.text = "Lives: %d" % lives.value
			_last_lives = lives.value

	var combo = context.world.get_component(context.world, Combo)
	var combo_label = context.world.try_get_node("hud_combo")
	if combo_label and combo:
		if combo.count != _last_combo:
			if combo.count > 0:
				combo_label.text = "Combo: %dx" % combo.count
				combo_label.visible = true
			else:
				combo_label.visible = false
			_last_combo = combo.count
