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
	for pipeline in [PaddleInputPipeline, MovementPipeline, PositionClampPipeline, BallMovementPipeline, WallReflectionPipeline, DamagePipeline]:
		Deus.register_pipeline(pipeline)
		Deus.pipeline_scheduler.register_task(
			PipelineSchedulerDefaults.OnUpdate, pipeline
		)

	# Signal-only pipelines (not scheduled)
	Deus.register_pipeline(BallDamagePipeline)

	_spawn_bricks()

func _spawn_bricks():
	var vp_width = get_viewport_rect().size.x
	var grid_width = BRICK_COLS * BRICK_SIZE.x + (BRICK_COLS - 1) * BRICK_GAP
	var x_offset = (vp_width - grid_width) * 0.5

	for row in range(BRICK_ROWS):
		for col in range(BRICK_COLS):
			var brick = BrickScene.instantiate()
			brick.position = Vector2(
				x_offset + col * (BRICK_SIZE.x + BRICK_GAP),
				BRICK_TOP_MARGIN + row * (BRICK_SIZE.y + BRICK_GAP)
			)
			add_child(brick)
			Deus.signal_to_pipeline(brick, "area_entered", brick, BallDamagePipeline)
