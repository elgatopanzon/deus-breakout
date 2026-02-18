# ABOUTME: Spawns spark particles on ball-brick collision impacts
# ABOUTME: Injected after BrickCollisionPipeline._stage_collide; reads collision payload

class_name BallImpactParticlePipeline extends DefaultPipeline

const BALL_SPARK = preload("res://scenes/effects/BallSpark.tscn")

static func _requires(): return []

static func _stage_spark(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var ball_node = other if other.has_meta("id") else other.get_parent()

	if ball_node.get_meta("id") != "ball":
		return

	# Calculate contact midpoint between ball and brick
	var brick_pos = context._node.position
	var ball_pos = ball_node.position
	var contact_pos = (brick_pos + ball_pos) / 2.0

	# Spawn spark from pool
	var pool = context.world.component_registry.get_component(context.world, "ParticlePool")
	var spark = pool.acquire(BALL_SPARK)
	spark.position = contact_pos
	spark.emitting = true
	pool.release_after(spark, spark.lifetime + 0.1)
