# ABOUTME: Custom scheduler phases for Breakout pipeline execution ordering.
# ABOUTME: Registers Input > Physics > Effects phases within the default phase group.

class_name BreakoutPhases

# Custom phases for pipeline execution ordering
# Registered between PreUpdate and PostUpdate in the DefaultPhase group
class InputPhase: pass
class PhysicsPhase: pass
class EffectsPhase: pass

static func init_phases(scheduler: PipelineScheduler):
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultPhase,
		InputPhase,
		null,
		PipelineSchedulerDefaults.PreUpdate
	)
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultPhase,
		PhysicsPhase,
		null,
		InputPhase
	)
	scheduler.register_phase(
		PipelineSchedulerDefaults.DefaultPhase,
		EffectsPhase,
		null,
		PhysicsPhase
	)
