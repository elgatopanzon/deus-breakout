######################################################################
# @author      : ElGatoPanzon
# @class       : Main
# @created     : Thursday Jan 29, 2026 20:45:00 CST
# @copyright   : Copyright (c) ElGatoPanzon 2026
#
# @description : game bootstrap — registers pipelines with scheduler
######################################################################

extends Node2D

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

	# Damage accumulation injects into brick collision detection
	Deus.inject_pipeline(BallDamagePipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)

	# Game state singletons on world node
	Deus.set_component(Deus, Score, Score.new())
	Deus.set_component(Deus, Lives, Lives.new())
	Deus.set_component(Deus, GameState, GameState.new())

	# Spawn brick grid
	Deus.register_pipeline(SpawnBricksPipeline)
	Deus.execute_pipeline(SpawnBricksPipeline, self)
