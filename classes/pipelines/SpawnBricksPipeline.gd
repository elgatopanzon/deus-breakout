# ABOUTME: Brick grid spawner — instantiates brick rows with health tiers and visual sync
# ABOUTME: Executed once from Main._ready(); context._node is the parent for add_child

class_name SpawnBricksPipeline extends DefaultPipeline

const BrickScene = preload("res://scenes/Brick.tscn")

const BRICK_COLS = 8
const BRICK_ROWS = 5
const BRICK_SIZE = Vector2(50, 20)
const BRICK_GAP = 8.0
const BRICK_TOP_MARGIN = 60.0

# HP per row — top rows are tougher (classic breakout pattern)
const ROW_HEALTH = [3, 3, 2, 2, 1]

static func _requires(): return []

static func _stage_spawn(context):
	var parent = context._node
	var vp_width = parent.get_viewport_rect().size.x
	var grid_width = BRICK_COLS * BRICK_SIZE.x + (BRICK_COLS - 1) * BRICK_GAP
	var x_offset = (vp_width - grid_width) * 0.5

	for row in range(BRICK_ROWS):
		var hp = ROW_HEALTH[row]
		for col in range(BRICK_COLS):
			var brick = BrickScene.instantiate()
			brick.position = Vector2(
				x_offset + col * (BRICK_SIZE.x + BRICK_GAP),
				BRICK_TOP_MARGIN + row * (BRICK_SIZE.y + BRICK_GAP)
			)
			parent.add_child(brick)

			# Override default health for this row's tier
			var health = Health.new()
			health.value = hp
			context.world.set_component(brick, Health, health)

			# Point value for scoring (10 per HP tier)
			brick.set_meta("points", hp * 10)

			# Set initial color from health
			brick.get_node("Visual").color = BrickVisualSyncPipeline.color_for_health(hp)
