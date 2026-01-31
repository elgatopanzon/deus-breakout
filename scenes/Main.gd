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
	# Scheduled pipelines (run every frame)
	for pipeline in [PaddleInputPipeline, MovementPipeline, PositionClampPipeline, BallMovementPipeline, WallReflectionPipeline, DamagePipeline, BrickVisualSyncPipeline]:
		Deus.register_pipeline(pipeline)
		Deus.pipeline_scheduler.register_task(
			PipelineSchedulerDefaults.OnUpdate, pipeline
		)

	# Signal-only pipelines (not scheduled)
	Deus.register_pipeline(BallDamagePipeline)

	_spawn_bricks()

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

			# Set initial color from health
			brick.get_node("Visual").color = BrickVisualSyncPipeline.color_for_health(hp)

			Deus.signal_to_pipeline(brick, "area_entered", brick, BallDamagePipeline)
