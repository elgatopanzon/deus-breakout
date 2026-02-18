# ABOUTME: Overlay sync pipeline — shows/hides game state overlays based on GameState
# ABOUTME: Event-driven via component_set signal; fires only when GameState changes

class_name OverlaySyncPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_sync(context):
	var gs = context.world.get_component(context.world, GameState)
	if gs == null:
		return
	var state = gs.state

	var game_overlay = context.world.try_get_node("game_overlay")
	var pause_overlay = context.world.try_get_node("pause_overlay")
	if game_overlay == null or pause_overlay == null:
		return

	var title_label = context.world.try_get_node("overlay_title")
	var score_label = context.world.try_get_node("overlay_score")

	match state:
		GameState.State.PLAYING:
			game_overlay.visible = false
			pause_overlay.visible = false
		GameState.State.PAUSED:
			game_overlay.visible = false
			pause_overlay.visible = true
		GameState.State.WON:
			pause_overlay.visible = false
			game_overlay.visible = true
			if title_label:
				title_label.text = "You Win!"
			if score_label:
				var score = context.world.get_component(context.world, Score)
				score_label.text = "Score: %d" % score.value
		GameState.State.LOST:
			pause_overlay.visible = false
			game_overlay.visible = true
			if title_label:
				title_label.text = "Game Over"
			if score_label:
				var score = context.world.get_component(context.world, Score)
				score_label.text = "Score: %d" % score.value
