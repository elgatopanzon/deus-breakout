# ABOUTME: Spawns spark particles when ball reflects off walls
# ABOUTME: Injected after WallReflectionPipeline._stage_reflect; detects edge contact

class_name WallSparkPipeline extends DefaultPipeline

const BALL_SPARK = preload("res://scenes/effects/BallSpark.tscn")

static func _requires(): return [Position, Velocity, Size]

static func _stage_spark(context):
	var pos = context.Position.value
	var size = context.Size.value
	var vp = context._node.get_viewport_rect().size

	# Detect wall contact by checking if position was clamped to an edge
	var contact_pos = Vector2.ZERO
	var hit = false

	if pos.x <= 0.0:
		contact_pos = Vector2(0.0, pos.y + size.y * 0.5)
		hit = true
	elif pos.x + size.x >= vp.x:
		contact_pos = Vector2(vp.x, pos.y + size.y * 0.5)
		hit = true

	if pos.y <= 0.0:
		contact_pos = Vector2(pos.x + size.x * 0.5, 0.0)
		hit = true

	if not hit:
		return

	var spark = BALL_SPARK.instantiate()
	spark.position = contact_pos
	context._node.get_parent().add_child(spark)
	spark.emitting = true
	spark.get_tree().create_timer(spark.lifetime + 0.1).timeout.connect(spark.queue_free)
