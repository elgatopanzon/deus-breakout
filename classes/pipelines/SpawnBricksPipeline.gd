# ABOUTME: Brick spawner — instantiates bricks from a procedural BrickLayout
# ABOUTME: Executed once from Main._ready(); context._node is the parent for add_child

class_name SpawnBricksPipeline extends DefaultPipeline

const BrickScene = preload("res://scenes/Brick.tscn")

const BRICK_SIZE = Vector2(50, 20)
const BRICK_GAP = 8.0
const BRICK_TOP_MARGIN = 60.0

static func _requires(): return []

static func _stage_spawn(context):
	var parent = context._node
	var vp_size = parent.get_viewport_rect().size

	# Level defaults to 1 until Level component is wired (task #4)
	var level = 1

	var layout = BrickLayoutGenerator.generate(level, vp_size)
	var grid_width = layout.grid_cols * BRICK_SIZE.x + (layout.grid_cols - 1) * BRICK_GAP
	var x_offset = (vp_size.x - grid_width) * 0.5

	for cell in layout.cells:
		var brick = BrickScene.instantiate()
		brick.position = Vector2(
			x_offset + cell.col * (BRICK_SIZE.x + BRICK_GAP),
			BRICK_TOP_MARGIN + cell.row * (BRICK_SIZE.y + BRICK_GAP)
		)
		parent.add_child(brick)

		# Override default health from layout cell
		var health = Health.new()
		health.value = cell.health
		context.world.set_component(brick, Health, health)

		# Point value for scoring (10 per HP tier)
		brick.set_meta("points", cell.health * 10)

		# Set initial color from health
		brick.get_node("Visual").color = BrickVisualSyncPipeline.color_for_health(cell.health)
