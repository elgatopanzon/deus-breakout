# ABOUTME: Impact burst pipeline — spawns a brief flash sprite at ball-brick contact point
# ABOUTME: Injected after BallDamagePipeline in the BrickCollisionPipeline chain

class_name ImpactBurstPipeline extends DefaultPipeline

const BURST_SIZE := Vector2(24, 24)
const FADE_DURATION := 0.2
const POOL_SIZE := 8

static var _pool: Array = []
static var _initialized: bool = false

## Pre-allocate ColorRect pool as children of the current scene
static func _ensure_pool(scene: Node) -> void:
	if _initialized:
		return
	_initialized = true
	for i in POOL_SIZE:
		var rect = ColorRect.new()
		rect.size = BURST_SIZE
		rect.visible = false
		scene.add_child(rect)
		_pool.append(rect)

## Acquire an available ColorRect from the pool, or create a new one if exhausted
static func _acquire(scene: Node) -> ColorRect:
	_ensure_pool(scene)
	for i in range(_pool.size() - 1, -1, -1):
		var rect = _pool[i]
		if is_instance_valid(rect) and not rect.visible:
			return rect
	# Pool exhausted -- fallback to allocation
	push_warning("ImpactBurstPipeline: pool exhausted, allocating new ColorRect")
	var fallback = ColorRect.new()
	fallback.size = BURST_SIZE
	fallback.visible = false
	scene.add_child(fallback)
	_pool.append(fallback)
	return fallback

## Return a ColorRect to the pool by hiding it
static func _release(rect: ColorRect) -> void:
	if is_instance_valid(rect):
		rect.visible = false

## Reset pool state (call on scene reload to avoid stale references)
static func reset() -> void:
	_pool.clear()
	_initialized = false

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

	var scene = brick_node.get_tree().current_scene
	var burst = _acquire(scene)
	burst.position = midpoint - BURST_SIZE / 2.0
	burst.color = Color.WHITE
	burst.modulate.a = 1.0
	burst.visible = true

	var tween = burst.create_tween()
	tween.tween_property(burst, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(_release.bind(burst))
