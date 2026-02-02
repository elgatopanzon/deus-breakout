# ABOUTME: Animates level start -- bricks pop in row-by-row, paddle slides up, ball drops in
# ABOUTME: One-shot pipeline executed from Main._ready(); sets GameState to PLAYING on complete

class_name LevelStartAnimationPipeline extends DefaultPipeline

const ROW_STAGGER = 0.08
const ROW_DURATION = 0.25
const ENTITY_DURATION = 0.3
const ENTITY_DELAY = 0.1

static func _requires(): return []

static func _stage_animate(context):
	var world = context.world
	var registry = world.component_registry

	# Set animation state
	var anim_state = world.get_component(world, AnimationState)
	if anim_state:
		anim_state.transitioning = true
		world.set_component(world, AnimationState, anim_state)

	# Find all bricks and group by row (y position)
	var brick_nodes = registry.get_matching_nodes([Health], [])
	var rows = {}
	for brick in brick_nodes:
		var y = brick.position.y
		if not rows.has(y):
			rows[y] = []
		rows[y].append(brick)

	# Sort row keys top to bottom
	var row_keys = rows.keys()
	row_keys.sort()

	# Start all bricks at scale 0
	for brick in brick_nodes:
		brick.scale = Vector2.ZERO

	# Find paddle and ball
	var paddle_nodes = registry.get_matching_nodes([Deflector], [])
	var ball_nodes = registry.get_matching_nodes([Velocity], [])
	var paddle = paddle_nodes[0] if paddle_nodes.size() > 0 else null
	var ball = ball_nodes[0] if ball_nodes.size() > 0 else null

	# Store original positions, move offscreen
	var vp = context._node.get_viewport_rect().size
	var paddle_target_y = 0.0
	var ball_target_y = 0.0

	if paddle:
		paddle_target_y = paddle.position.y
		paddle.position.y = vp.y + 40.0

	if ball:
		ball_target_y = ball.position.y
		ball.position.y = -40.0

	# Calculate total brick animation time
	var total_brick_time = row_keys.size() * ROW_STAGGER + ROW_DURATION

	# Create tween on the scene node (context._node is Main)
	var tween = context._node.create_tween()
	tween.set_parallel(false)

	# Animate brick rows popping in with stagger
	for i in range(row_keys.size()):
		var row_bricks = rows[row_keys[i]]
		var delay = i * ROW_STAGGER

		for brick in row_bricks:
			# Each brick gets its own parallel tween interval
			var brick_tween = context._node.create_tween()
			brick_tween.tween_interval(delay)
			brick_tween.tween_property(brick, "scale", Vector2.ONE, ROW_DURATION) \
				.from(Vector2.ZERO) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_BACK)

	# After bricks, animate paddle sliding up
	tween.tween_interval(total_brick_time + ENTITY_DELAY)
	if paddle:
		tween.tween_property(paddle, "position:y", paddle_target_y, ENTITY_DURATION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)

	# Then ball drops in
	if ball:
		tween.tween_interval(ENTITY_DELAY)
		tween.tween_property(ball, "position:y", ball_target_y, ENTITY_DURATION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)

	# On complete: transition to PLAYING
	tween.tween_callback(func():
		var gs = world.get_component(world, GameState)
		if gs:
			gs.state = GameState.State.PLAYING
			world.set_component(world, GameState, gs)
		var as_ = world.get_component(world, AnimationState)
		if as_:
			as_.transitioning = false
			world.set_component(world, AnimationState, as_)
	)
