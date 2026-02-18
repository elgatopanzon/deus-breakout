# ABOUTME: Reflects ball velocity on any area collision using surface normals
# ABOUTME: Caches collision shape lookups per entity to avoid repeated get_node_or_null calls

class_name BallCollisionPipeline extends DefaultPipeline

# Cache collision shape lookups keyed by node instance_id
static var _shape_cache: Dictionary = {}

static func _requires(): return [Position, Velocity]

# Look up and cache the CollisionShape2D child for a given node
static func _get_cached_shape(node: Node) -> CollisionShape2D:
	var id = node.get_instance_id()
	if _shape_cache.has(id):
		var cached = _shape_cache[id]
		if is_instance_valid(cached):
			return cached
		_shape_cache.erase(id)
	var shape = node.get_node_or_null("CollisionShape2D")
	if shape != null:
		_shape_cache[id] = shape
	return shape

static func _stage_reflect(context):
	var payload = context.payload
	if payload == null or payload.size() < 2:
		return

	var other = payload[1]
	var other_node = other if other.has_meta("id") else other.get_parent()

	# Get collision shapes for normal derivation (cached)
	var ball_col = _get_cached_shape(context._node)
	var other_col = _get_cached_shape(other_node)
	if ball_col == null or other_col == null:
		return

	# Derive surface normal from shape geometry
	var diff = ball_col.global_position - other_col.global_position
	var other_half = Vector2.ZERO
	if other_col.shape is RectangleShape2D:
		other_half = other_col.shape.size * 0.5
	elif other_col.shape is CircleShape2D:
		other_half = Vector2(other_col.shape.radius, other_col.shape.radius)
	else:
		return

	# The axis where the ball is proportionally furthest outside determines the hit face
	var normal: Vector2
	var scale_x = abs(diff.x) / other_half.x if other_half.x > 0 else 0.0
	var scale_y = abs(diff.y) / other_half.y if other_half.y > 0 else 0.0
	if scale_x > scale_y:
		normal = Vector2(sign(diff.x), 0)
	else:
		normal = Vector2(0, sign(diff.y))

	# Only reflect if moving toward the surface
	var dir = context.Velocity.direction
	if dir.dot(normal) >= 0:
		return

	# Standard reflection: d' = d - 2(d·n)n
	context.Velocity.direction = (dir - 2.0 * dir.dot(normal) * normal).normalized()

	# Push ball out of collision surface to prevent multi-hit on next frame
	context.Position.value += normal * 3.0
