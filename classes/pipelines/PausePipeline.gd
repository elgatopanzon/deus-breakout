# ABOUTME: Pause pipeline — toggles GameState between PLAYING and PAUSED on Escape
# ABOUTME: Scheduled pipeline; requires GameState so it runs on the Deus node

class_name PausePipeline extends DefaultPipeline

static func _requires(): return [GameState]

static func _stage_toggle(context):
	if not Input.is_action_just_pressed("ui_cancel"):
		return

	var gs = context.GameState
	if gs.state == GameState.State.PLAYING:
		gs.state = GameState.State.PAUSED
	elif gs.state == GameState.State.PAUSED:
		gs.state = GameState.State.PLAYING
