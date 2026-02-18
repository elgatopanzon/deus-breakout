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

	# Reset one-shot animation flags and state tracking (statics persist across scene reloads)
	WinAnimationPipeline.played = false
	GameOverAnimationPipeline.played = false
	GameStateSoundPipeline.previous_state = GameState.State.STARTING
	WallBounceSoundPipeline.last_played_frame = -1
	PaddleHitSoundPipeline.last_played_frame = -1
	AudioPoolHelper.reset()

	# Register custom breakout phases: Input > Physics > Effects
	BreakoutPhases.init_phases(Deus.pipeline_scheduler)

	# Scheduled pipelines grouped by phase
	var input_pipelines = [
		TouchZoneInputPipeline,
		PaddleInputPipeline,
		TouchPaddleInputPipeline,
	]
	var physics_pipelines = [
		MovementPipeline,
		PositionClampPipeline,
		BallMovementPipeline,
		BallSpeedCurvePipeline,
		WallReflectionPipeline,
		DamagePipeline,
		DestructionPipeline,
		BallMissedPipeline,
	]
	var effects_pipelines = [
		BrickVisualSyncPipeline,
		PausePipeline,
		HUDSyncPipeline,
		OverlaySyncPipeline,
		ScreenShakePipeline,
		ComboDecayPipeline,
		WinAnimationPipeline,
		GameOverAnimationPipeline,
		GameStateSoundPipeline,
	]
	for p in input_pipelines:
		Deus.register_pipeline(p)
		Deus.pipeline_scheduler.register_task(BreakoutPhases.InputPhase, p)
	for p in physics_pipelines:
		Deus.register_pipeline(p)
		Deus.pipeline_scheduler.register_task(BreakoutPhases.PhysicsPhase, p)
	for p in effects_pipelines:
		Deus.register_pipeline(p)
		Deus.pipeline_scheduler.register_task(BreakoutPhases.EffectsPhase, p)

	# Pause guard injects before gameplay pipelines — cancels when not playing
	Deus.inject_pipeline(PauseGuardPipeline, Callable(TouchZoneInputPipeline, "_stage_detect_touch"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(TouchPaddleInputPipeline, "_stage_read_touch"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleInputPipeline, "_stage_read_input"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(MovementPipeline, "_stage_apply_movement"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PositionClampPipeline, "_stage_clamp"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMovementPipeline, "_stage_move"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallSpeedCurvePipeline, "_stage_ramp"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BallMissedPipeline, "_stage_detect"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(ScreenShakePipeline, "_stage_apply"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(ComboDecayPipeline, "_stage_decay"), true)

	# Shake trigger + brick sounds inject before damage — read pending Damage to detect hits
	Deus.inject_pipeline(ShakeTriggerPipeline, Callable(DamagePipeline, "_stage_apply"), true)
	Deus.inject_pipeline(BrickHitSoundPipeline, Callable(DamagePipeline, "_stage_apply"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickHitSoundPipeline, "_stage_play"), true)
	Deus.inject_pipeline(BrickBreakSoundPipeline, Callable(DamagePipeline, "_stage_apply"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickBreakSoundPipeline, "_stage_play"), true)

	# Scoring + win check + particle effects inject before destruction — components still available
	Deus.inject_pipeline(ScoringPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(WinCheckPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(BrickDestructionParticlePipeline, Callable(DestructionPipeline, "_stage_destroy"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickDestructionParticlePipeline, "_stage_spawn"), true)
	Deus.inject_pipeline(HitstopTriggerPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)

	# Lives + game over + respawn inject into ball-missed detection pipeline
	Deus.inject_pipeline(LifeLostSoundPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(LivesDecrementPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(GameOverPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(BallRespawnPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)
	Deus.inject_pipeline(LifeLostAnimationPipeline, Callable(BallRespawnPipeline, "_stage_respawn"), false)
	Deus.inject_pipeline(BallSpeedResetPipeline, Callable(BallRespawnPipeline, "_stage_respawn"), false)
	Deus.inject_pipeline(BallLaunchSoundPipeline, Callable(BallRespawnPipeline, "_stage_respawn"), false)

	# Damage accumulation injects into brick collision detection
	Deus.inject_pipeline(BallDamagePipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)

	# Visual effects inject after damage accumulation in collision chain
	Deus.inject_pipeline(HitFlashPipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)
	Deus.inject_pipeline(ImpactBurstPipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)
	Deus.inject_pipeline(BallImpactParticlePipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)
	Deus.inject_pipeline(ComboIncrementPipeline, Callable(BrickCollisionPipeline, "_stage_collide"), false)

	# Combo reset on life lost
	Deus.inject_pipeline(ComboResetPipeline, Callable(BallMissedPipeline, "_stage_detect"), false)

	# Paddle stretch and brick squeeze deformation
	Deus.inject_pipeline(PaddleStretchPipeline, Callable(DeflectPipeline, "_stage_deflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleStretchPipeline, "_stage_stretch"), true)
	Deus.inject_pipeline(BrickSqueezePipeline, Callable(DamagePipeline, "_stage_apply"), true)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(BrickSqueezePipeline, "_stage_squeeze"), true)

	# Wall and paddle spark particles + sound
	Deus.inject_pipeline(WallSparkPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallSparkPipeline, "_stage_spark"), true)
	Deus.inject_pipeline(WallBounceSoundPipeline, Callable(WallReflectionPipeline, "_stage_reflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(WallBounceSoundPipeline, "_stage_play"), true)
	Deus.inject_pipeline(PaddleSparkPipeline, Callable(DeflectPipeline, "_stage_deflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleSparkPipeline, "_stage_spark"), true)
	Deus.inject_pipeline(PaddleHitSoundPipeline, Callable(DeflectPipeline, "_stage_deflect"), false)
	Deus.inject_pipeline(PauseGuardPipeline, Callable(PaddleHitSoundPipeline, "_stage_play"), true)

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
	Deus.set_component(Deus, Level, Level.new())

	# Audio: preload streams into SoundBank singleton
	var sb = SoundBank.new()
	sb.streams = {
		"paddle_hit": preload("res://assets/audio/paddle_hit.wav"),
		"brick_break": preload("res://assets/audio/brick_break.wav"),
		"brick_hit": preload("res://assets/audio/brick_hit.wav"),
		"wall_bounce": preload("res://assets/audio/wall_bounce.wav"),
		"ball_launch": preload("res://assets/audio/ball_launch.wav"),
		"life_lost": preload("res://assets/audio/life_lost.wav"),
		"game_over": preload("res://assets/audio/game_over.wav"),
		"win": preload("res://assets/audio/win.wav"),
		"ui_click": preload("res://assets/audio/ui_click.wav"),
	}
	Deus.set_component(Deus, SoundBank, sb)

	# Spawn brick grid then animate level start
	Deus.register_pipeline(SpawnBricksPipeline)
	Deus.execute_pipeline(SpawnBricksPipeline, self)
	Deus.register_pipeline(LevelStartAnimationPipeline)
	Deus.execute_pipeline(LevelStartAnimationPipeline, self)
