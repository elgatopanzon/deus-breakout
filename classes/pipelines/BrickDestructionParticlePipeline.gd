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

	# Spawn brick debris
	var debris = BRICK_DEBRIS.instantiate()
	debris.position = brick_pos
	if debris.process_material:
		debris.process_material = debris.process_material.duplicate()
		debris.process_material.color = health_color
	context._node.get_parent().add_child(debris)
	debris.emitting = true

	# Spawn dust puff
	var dust = DUST_PUFF.instantiate()
	dust.position = brick_pos
	context._node.get_parent().add_child(dust)
	dust.emitting = true
