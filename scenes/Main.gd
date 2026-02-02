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

	# Reset one-shot animation flags (statics persist across scene reloads)
	WinAnimationPipeline.played = false
	GameOverAnimationPipeline.played = false

	# Scheduled pipelines (run every frame)
	for pipeline in [TouchZoneInputPipeline, PaddleInputPipeline, TouchPaddleInputPipeline, MovementPipeline, PositionClampPipeline, BallMovementPipeline, WallReflectionPipeline, DamagePipeline, DestructionPipeline, BrickVisualSyncPipeline, BallMissedPipeline, PausePipeline, HUDSyncPipeline, OverlaySyncPipeline, ScreenShakePipeline, WinAnimationPipeline, GameOverAnimationPipeline]:
		Deus.register_pipeline(pipeline)
		Deus.pipeline_scheduler.register_task(
			PipelineSchedulerDefaults.OnUpdate, pipeline
		)

	# Pause guard injects before gameplay pipelines — cancels when not playing
	Deus.inject_pipeline(PauseGuardPipeline, Callable(TouchZoneInputPipeline, "_stage_detect_touch"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(TouchPaddleInputPipeline, "_stage_read_touch"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleInputPipeline, "_stage_read_input"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(MovementPipeline, "_stage_apply_movement"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PositionClampPipeline, "_stage_clamp"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMovementPipeline, "_stage_move"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMissedPipeline, "_stage_detect"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(ScreenShakePipeline, "_stage_apply"), true)

	# Shake trigger injects before damage — reads pending Damage to detect hits this frame
	Deus.inject_pipeline(ShakeTriggerPipeline, Callable(DamagePipeline, "_stage_apply"), true)

	# Scoring + win check + particle effects inject before destruction — components still available
	Deus.inject_pipeline(ScoringPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(WinCheckPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(BrickDestructionParticlePipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickDestructionParticlePipeline, "_stage_spawn"), true)

	# Lives + game over + respawn inject into ball-missed detection pipeline
	Deus.inject_pipeline(LivesDecrementPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(GameOverPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(BallRespawnPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(LifeLostAnimationPipeline, Callable(BallRespawnPipeline, "_stage_respawn"), false)

	# Damage accumulation injects into brick collision detection
	Deus.inject_pipeline(BallDamagePipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)

	# Visual effects inject after damage accumulation in collision chain
	Deus.inject_pipeline(HitFlashPipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)
	Deus.inject_pipeline(ImpactBurstPipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)
	Deus.inject_pipeline(BallImpactParticlePipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)

	# Paddle stretch and brick squeeze deformation
	Deus.inject_pipeline(PaddleStretchPipeline, Callable(DeflectPipeline, "_stage_deflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleStretchPipeline, "_stage_stretch"), true)
	Deus.inject_pipeline(BrickSqueezePipeline, Callable(DamagePipeline, "_stage_apply"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickSqueezePipeline, "_stage_squeeze"), true)

	# Wall and paddle spark particles
	Deus.inject_pipeline(WallSparkPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallSparkPipeline, "_stage_spark"), true)
	Deus.inject_pipeline(PaddleSparkPipeline, Callable(DeflectPipeline, "_stage_deflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleSparkPipeline, "_stage_spark"), true)

	# Game state singletons on world node
	Deus.set_component(Deus, Score, Score.new())
	Deus.set_component(Deus, Lives, Lives.new())
	Deus.set_component(Deus, GameState, GameState.new())
	Deus.set_component(Deus, ScreenShake, ScreenShake.new())
	Deus.set_component(Deus, AnimationState, AnimationState.new())
	Deus.set_component(Deus, Combo, Combo.new())
	Deus.set_component(Deus, ComboTiers, ComboTiers.new())
	Deus.set_component(Deus, BallSpeedCurve, BallSpeedCurve.new())
	Deus.set_component(Deus, Hitstop, Hitstop.new())

	# Spawn brick grid then animate level start
	Deus.register_pipeline(SpawnBricksPipeline)
	Deus.execute_pipeline(SpawnBricksPipeline, self)
	Deus.register_pipeline(LevelStartAnimationPipeline)
	Deus.execute_pipeline(LevelStartAnimationPipeline, self)
