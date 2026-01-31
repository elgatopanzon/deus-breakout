# ABOUTME: Ball respawn pipeline — resets ball position and velocity after life lost
# ABOUTME: Injected into BallMissedPipeline after LivesDecrementPipeline

class_name BallRespawnPipeline extends DefaultPipeline

# Starting values matching Ball.tscn defaults
const START_POSITION = Vector2(572, 556)
const START_DIRECTION = Vector2(0.7071, -0.7071)
const START_SPEED = 400.0

static func _requires(): return []

static func _stage_respawn(context):
	var lives = context.world.get_component(context.world, Lives)
	if lives == null or lives.value <= 0:
		return

	context.Position.value = START_POSITION
	context.Velocity.direction = START_DIRECTION
	context.Velocity.speed = START_SPEED
	context._node.position = START_POSITION
