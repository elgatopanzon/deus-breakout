######################################################################
# @author      : ElGatoPanzon
# @class       : Main
# @created     : Thursday Jan 29, 2026 20:45:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : game bootstrap — registers pipelines with scheduler
######################################################################

extends Node2D

const BrickScene = preload("res://scenes/Brick.tscn")

const BRICK_COLS = 8
const BRICK_ROWS = 5
const BRICK_SIZE = Vector2(50, 20)
const BRICK_GAP = 8.0
const BRICK_TOP_MARGIN = 60.0

func _ready():
	# Purge stale component entries from previous scene load (Deus autoload persists across reloads)
	for node in Deus.component_registry.node_components.keys().duplicate():
		if not is_instance_valid(node):
			Deus.component_registry.node_components.erase(node)

	# Scheduled pipelines (run every frame)
	for pipeline in [PaddleInputPipeline, MovementPipeline, PositionClampPipeline, BallMovementPipeline, WallReflectionPipeline, DamagePipeline, DestructionPipeline, BrickVisualSyncPipeline, BallMissedPipeline, PausePipeline, HUDSyncPipeline, OverlaySyncPipeline]:
		Deus.register_pipeline(pipeline)
		Deus.pipeline_scheduler.register_task(
			PipelineSchedulerDefaults.OnUpdate, pipeline
		)

	# Signal-only pipelines (not scheduled)
	Deus.register_pipeline(BallDamagePipeline)

	# Pause guard injects before gameplay pipelines — cancels when not playing
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleInputPipeline, "_stage_read_input"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMovementPipeline, "_stage_move"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMissedPipeline, "_stage_detect"), true)

	# Scoring + win check inject before destruction — components still available
	Deus.inject_pipeline(ScoringPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(WinCheckPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)

	# Lives + game over + respawn inject into ball-missed detection pipeline
	Deus.inject_pipeline(LivesDecrementPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(GameOverPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(BallRespawnPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)

	# Game state singletons on world node
	Deus.set_component(Deus, Score, Score.new())
	Deus.set_component(Deus, Lives, Lives.new())
	Deus.set_component(Deus, GameState, GameState.new())

	_spawn_bricks()
	_create_hud()

func _create_hud():
	var canvas = CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var vp_width = get_viewport_rect().size.x

	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(10, 10)
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_to_group("hud_score")
	canvas.add_child(score_label)

	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.position = Vector2(vp_width - 130, 10)
	lives_label.text = "Lives: 3"
	lives_label.add_theme_font_size_override("font_size", 24)
	lives_label.add_to_group("hud_lives")
	canvas.add_child(lives_label)

	# Win/lose overlay — centered panel, hidden by default
	var vp = get_viewport_rect().size
	var game_overlay = _create_overlay_panel(canvas, "game_overlay", vp)
	game_overlay.visible = false

	# Pause overlay — centered text, hidden by default
	var pause_label = Label.new()
	pause_label.name = "PauseOverlay"
	pause_label.text = "PAUSED"
	pause_label.add_theme_font_size_override("font_size", 48)
	pause_label.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 - 30)
	pause_label.visible = false
	pause_label.add_to_group("pause_overlay")
	canvas.add_child(pause_label)

func _create_overlay_panel(parent: Node, group: String, vp: Vector2) -> Control:
	var panel = PanelContainer.new()
	panel.name = "GameOverlay"
	panel.position = Vector2(vp.x / 2.0 - 150, vp.y / 2.0 - 80)
	panel.custom_minimum_size = Vector2(300, 160)
	panel.add_to_group(group)
	parent.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_to_group("overlay_title")
	vbox.add_child(title)

	var score = Label.new()
	score.name = "Score"
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score.add_theme_font_size_override("font_size", 24)
	score.add_to_group("overlay_score")
	vbox.add_child(score)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	var restart_btn = Button.new()
	restart_btn.name = "RestartButton"
	restart_btn.text = "Play Again"
	restart_btn.pressed.connect(_on_restart)
	vbox.add_child(restart_btn)

	return panel

func _on_restart():
	get_tree().reload_current_scene()

func _spawn_bricks():
	# HP per row — top rows are tougher (classic breakout pattern)
	var row_health = [3, 3, 2, 2, 1]

	var vp_width = get_viewport_rect().size.x
	var grid_width = BRICK_COLS * BRICK_SIZE.x + (BRICK_COLS - 1) * BRICK_GAP
	var x_offset = (vp_width - grid_width) * 0.5

	for row in range(BRICK_ROWS):
		var hp = row_health[row]
		for col in range(BRICK_COLS):
			var brick = BrickScene.instantiate()
			brick.position = Vector2(
				x_offset + col * (BRICK_SIZE.x + BRICK_GAP),
				BRICK_TOP_MARGIN + row * (BRICK_SIZE.y + BRICK_GAP)
			)
			add_child(brick)

			# Override default health for this row's tier
			var health = Health.new()
			health.value = hp
			Deus.set_component(brick, Health, health)

			# Point value for scoring (10 per HP tier)
			brick.set_meta("points", hp * 10)

			# Set initial color from health
			brick.get_node("Visual").color = BrickVisualSyncPipeline.color_for_health(hp)

			Deus.signal_to_pipeline(brick, "area_entered", brick, BallDamagePipeline)
