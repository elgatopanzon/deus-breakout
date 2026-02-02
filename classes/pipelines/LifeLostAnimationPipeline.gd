# ABOUTME: Animates life-lost sequence -- brief freeze, screen flash, ball drop-in
# ABOUTME: Injected after BallRespawnPipeline; uses Engine.time_scale for freeze

class_name LifeLostAnimationPipeline extends DefaultPipeline

const FREEZE_DURATION = 0.15
const FLASH_DURATION = 0.1
const DROP_DURATION = 0.3

static func _requires(): return []

static func _stage_animate(context):
	var world = context.world

	# Skip if game over (no respawn happened)
	var lives = world.get_component(world, Lives)
	if lives == null or lives.value <= 0:
		return

	# Skip if already transitioning
	var anim_state = world.get_component(world, AnimationState)
	if anim_state and anim_state.transitioning:
		return

	if anim_state:
		anim_state.transitioning = true
		world.set_component(world, AnimationState, anim_state)

	var ball = context._node
	var scene_root = ball.get_parent()
	var target_y = ball.position.y
	var registry = world.component_registry

	# Gate gameplay pipelines during animation by switching to STARTING state
	var gs = world.get_component(world, GameState)
	if gs:
		gs.state = GameState.State.STARTING
		world.set_component(world, GameState, gs)

	# Move ball above viewport for drop-in after freeze
	ball.position.y = -40.0
	# Disable collision during drop-in to prevent false area_entered signals
	ball.monitoring = false
	ball.monitorable = false

	# Freeze gameplay briefly
	Engine.time_scale = 0.0

	# Use process-always timer to unfreeze after FREEZE_DURATION real seconds
	var tree = scene_root.get_tree()
	tree.create_timer(FREEZE_DURATION, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0

		# Screen flash: tween root modulate white then back
		var flash_tween = scene_root.create_tween()
		flash_tween.tween_property(scene_root, "modulate", Color(2.0, 2.0, 2.0, 1.0), FLASH_DURATION * 0.5)
		flash_tween.tween_property(scene_root, "modulate", Color.WHITE, FLASH_DURATION * 0.5)

		# Ball drop-in animation after flash
		flash_tween.tween_property(ball, "position:y", target_y, DROP_DURATION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK)

		flash_tween.tween_callback(func():
			# Re-enable collision and sync ECS Position with final node position
			ball.monitoring = true
			ball.monitorable = true
			var pos_comp = registry.get_component(ball, "Position")
			if pos_comp:
				pos_comp.value = ball.position
				world.set_component(ball, Position, pos_comp)
			# Restore PLAYING state so gameplay resumes
			var gs2 = world.get_component(world, GameState)
			if gs2:
				gs2.state = GameState.State.PLAYING
				world.set_component(world, GameState, gs2)
			var as_ = world.get_component(world, AnimationState)
			if as_:
				as_.transitioning = false
				world.set_component(world, AnimationState, as_)
		)
	)
