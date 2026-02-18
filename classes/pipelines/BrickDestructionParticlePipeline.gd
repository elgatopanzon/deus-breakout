# ABOUTME: Spawns particle effects when bricks are destroyed
# ABOUTME: Injected before DestructionPipeline._stage_destroy; reads Health and position

class_name BrickDestructionParticlePipeline extends DefaultPipeline

const BRICK_DEBRIS = preload("res://scenes/effects/BrickDebris.tscn")
const DUST_PUFF = preload("res://scenes/effects/DustPuff.tscn")

# Pre-duplicated materials keyed by health color to avoid per-destruction allocations
static var _tier_materials: Dictionary = {}
static var _materials_initialized: bool = false

static func _init_tier_materials() -> void:
	if _materials_initialized:
		return
	var base_node = BRICK_DEBRIS.instantiate()
	var base_mat = base_node.process_material
	if base_mat:
		for hp in BrickVisualSyncPipeline.HEALTH_COLORS:
			var mat = base_mat.duplicate()
			mat.color = BrickVisualSyncPipeline.HEALTH_COLORS[hp]
			_tier_materials[hp] = mat
	base_node.queue_free()
	_materials_initialized = true

static func _requires(): return [Health]

static func _stage_spawn(context):
	# Only run if brick is being destroyed (Health <= 0)
	if context.Health.value > 0:
		return

	_init_tier_materials()

	var brick_pos = context._node.position + context._node.get_meta("size", Vector2(0, 0)) / 2.0
	var health_color_key = context.Health.value
	# Clamp to valid tier; destruction health is <= 0, falls back to tier 1
	if not _tier_materials.has(health_color_key):
		health_color_key = 1

	var pool = context.world.component_registry.get_component(context.world, "ParticlePool")

	# Spawn brick debris from pool with shared pre-duplicated material
	var debris = pool.acquire(BRICK_DEBRIS)
	debris.position = brick_pos
	if _tier_materials.has(health_color_key):
		debris.process_material = _tier_materials[health_color_key]
	debris.emitting = true
	pool.release_after(debris, debris.lifetime + 0.1)

	# Spawn dust puff from pool
	var dust = pool.acquire(DUST_PUFF)
	dust.position = brick_pos
	dust.emitting = true
	pool.release_after(dust, dust.lifetime + 0.1)
