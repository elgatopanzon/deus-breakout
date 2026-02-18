# ABOUTME: Spawns particle effects when bricks are destroyed
# ABOUTME: Injected before DestructionPipeline._stage_destroy; reads Health and position

class_name BrickDestructionParticlePipeline extends DefaultPipeline

const BRICK_DEBRIS = preload("res://scenes/effects/BrickDebris.tscn")
const DUST_PUFF = preload("res://scenes/effects/DustPuff.tscn")

static func _requires(): return [Health]

static func _stage_spawn(context):
	# Only run if brick is being destroyed (Health <= 0)
	if context.Health.value > 0:
		return

	var brick_pos = context._node.position + context._node.get_meta("size", Vector2(0, 0)) / 2.0
	var health_color = BrickVisualSyncPipeline.color_for_health(context.Health.value)

	var pool = context.world.component_registry.get_component(context.world, "ParticlePool")

	# Spawn brick debris from pool
	var debris = pool.acquire(BRICK_DEBRIS)
	debris.position = brick_pos
	if debris.process_material:
		debris.process_material = debris.process_material.duplicate()
		debris.process_material.color = health_color
	debris.emitting = true
	pool.release_after(debris, debris.lifetime + 0.1)

	# Spawn dust puff from pool
	var dust = pool.acquire(DUST_PUFF)
	dust.position = brick_pos
	dust.emitting = true
	pool.release_after(dust, dust.lifetime + 0.1)
