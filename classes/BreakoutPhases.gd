# ABOUTME: Custom scheduler phases for Breakout pipeline execution ordering.
# ABOUTME: Input and Physics run at fixed rate (_physics_process), Effects run at render rate (_process).

class_name BreakoutPhases

# Fixed-rate phases for deterministic gameplay (run in _physics_process)
class InputPhase: pass
class PhysicsPhase: pass

# Render-rate phase for visual sync, HUD, particles, sound (run in _process)
class EffectsPhase: pass

static func init_phases(scheduler: PipelineScheduler):
	# Input > Physics registered under DefaultFixedPhase for consistent tick rate
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultFixedPhase,
		InputPhase,
		null,
		PipelineSchedulerDefaults.PreFixedUpdate
	)
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultFixedPhase,
		PhysicsPhase,
		null,
		InputPhase
	)
	# Effects stays under DefaultPhase for render-coupled updates
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultPhase,
		EffectsPhase,
		null,
		PipelineSchedulerDefaults.PreUpdate
	)
