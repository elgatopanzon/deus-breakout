# ABOUTME: Ball damage accumulator — increments Damage component on collision
# ABOUTME: Injected into BrickCollisionPipeline; ball identity validated upstream

class_name BallDamagePipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_damage(context):
	context.Damage.value += 1
