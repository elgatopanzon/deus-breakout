# ABOUTME: Spawns spark particles when ball bounces off the paddle
# ABOUTME: Injected after DeflectPipeline._stage_deflect; reads collision payload

class_name PaddleSparkPipeline extends DefaultPipeline

const BALL_SPARK = preload("res://scenes/effects/BallSpark.tscn")

static func _requires(): return []

static func _stage_spark(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	# Only spark on paddle (Deflector) hits
	if not context.world.component_registry.has_component(other_node, "Deflector"):
		return

	var other_pos = context.world.component_registry.get_component(other_node, "Position")
	var other_size = context.world.component_registry.get_component(other_node, "Size")
	if other_pos == null or other_size == null:
		return

	# Contact point: ball center x, top of paddle
	var ball_center_x = context.Position.value.x + context.Size.value.x * 0.5
	var paddle_top_y = other_pos.value.y
	var contact_pos = Vector2(ball_center_x, paddle_top_y)

	var pool = context.world.component_registry.get_component(context.world, "ParticlePool")
	var spark = pool.acquire(BALL_SPARK)
	spark.position = contact_pos
	spark.emitting = true
	pool.release_after(spark, spark.lifetime + 0.1)
