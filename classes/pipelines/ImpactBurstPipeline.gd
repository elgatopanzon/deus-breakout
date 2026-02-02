# ABOUTME: Impact burst pipeline — spawns a brief flash sprite at ball-brick contact point
# ABOUTME: Injected after BallDamagePipeline in the BrickCollisionPipeline chain

class_name ImpactBurstPipeline extends DefaultPipeline

const BURST_SIZE := Vector2(16, 16)
const FADE_DURATION := 0.15

static func _requires(): return []

static func _stage_burst(context):
	if context.Damage.value <= 0:
		return

	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var brick_node = context._node
	var other = payload[1]
	var ball_node = other if other.has_meta("id") else other.get_parent()

	# Midpoint between ball and brick centers
	var brick_center = brick_node.global_position + Vector2(25, 10)
	var ball_center = ball_node.global_position + Vector2(12, 12)
	var midpoint = (brick_center + ball_center) / 2.0

	var burst = ColorRect.new()
	burst.size = BURST_SIZE
	burst.position = midpoint - BURST_SIZE / 2.0
	burst.color = Color.WHITE

	brick_node.get_tree().current_scene.add_child(burst)

	var tween = burst.create_tween()
	tween.tween_property(burst, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(burst.queue_free)
