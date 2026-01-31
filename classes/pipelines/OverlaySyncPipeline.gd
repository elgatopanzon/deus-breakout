# ABOUTME: Overlay sync pipeline — shows/hides game state overlays based on GameState
# ABOUTME: Scheduled pipeline; requires GameState so it runs on the Deus node

class_name OverlaySyncPipeline extends DefaultPipeline

static func _requires(): return [GameState]

static func _stage_sync(context):
	var state = context.GameState.state
	var tree = context._node.get_tree()

	var game_overlay = tree.get_first_node_in_group("game_overlay")
	var pause_overlay = tree.get_first_node_in_group("pause_overlay")
	if game_overlay == null or pause_overlay == null:
		return

	var title_label = tree.get_first_node_in_group("overlay_title")
	var score_label = tree.get_first_node_in_group("overlay_score")

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
