# ABOUTME: Procedural brick layout generator with pattern library
# ABOUTME: Produces deterministic BrickLayout for a given level using seeded RNG

class_name BrickLayoutGenerator

const BRICK_SIZE = Vector2(50, 20)
const BRICK_GAP = 8.0
const BRICK_TOP_MARGIN = 60.0
const BASE_COLS = 8
const BASE_ROWS = 5
const PATTERN_COUNT = 5


static func generate(level: int, viewport_size: Vector2) -> BrickLayout:
	var max_cols = _max_cols_for_viewport(viewport_size.x)
	var max_rows = _max_rows_for_viewport(viewport_size.y)

	# Scale grid slightly with level, capped by viewport
	var cols = mini(BASE_COLS + level / 5, max_cols)
	var rows = mini(BASE_ROWS + level / 8, max_rows)

	var rng = RandomNumberGenerator.new()
	rng.seed = hash(level)

	var pattern_index = level % PATTERN_COUNT
	var grid = _generate_pattern(pattern_index, cols, rows, rng)
	_apply_symmetry(grid, cols)

	var health_grid = _assign_health(grid, cols, rows, level)

	var layout = _grid_to_layout(grid, health_grid, cols, rows)

	# Fallback: ensure at least one brick
	if layout.cells.is_empty():
		layout.cells.append({"col": cols / 2, "row": rows / 2, "health": 1})

	return layout


static func _max_cols_for_viewport(vp_width: float) -> int:
	# How many bricks fit horizontally with gaps
	return int((vp_width - BRICK_GAP) / (BRICK_SIZE.x + BRICK_GAP))


static func _max_rows_for_viewport(vp_height: float) -> int:
	# Reserve top margin and bottom half for paddle/ball
	var available = vp_height * 0.5 - BRICK_TOP_MARGIN
	return int((available - BRICK_GAP) / (BRICK_SIZE.y + BRICK_GAP))


static func _generate_pattern(index: int, cols: int, rows: int, rng: RandomNumberGenerator) -> Array:
	match index:
		0: return _pattern_full(cols, rows)
		1: return _pattern_diamond(cols, rows)
		2: return _pattern_chevron(cols, rows)
		3: return _pattern_border(cols, rows)
		4: return _pattern_scatter(cols, rows, rng)
		_: return _pattern_full(cols, rows)


static func _pattern_full(cols: int, rows: int) -> Array:
	var grid = []
	for row in range(rows):
		var line = []
		for col in range(cols):
			line.append(true)
		grid.append(line)
	return grid


static func _pattern_diamond(cols: int, rows: int) -> Array:
	var grid = []
	var cx = cols / 2.0
	var cy = rows / 2.0
	var rx = cols / 2.0
	var ry = rows / 2.0
	for row in range(rows):
		var line = []
		for col in range(cols):
			var dx = absf((col + 0.5 - cx) / rx)
			var dy = absf((row + 0.5 - cy) / ry)
			line.append(dx + dy <= 1.0)
		grid.append(line)
	return grid


static func _pattern_chevron(cols: int, rows: int) -> Array:
	var grid = []
	var cx = cols / 2.0
	for row in range(rows):
		var line = []
		for col in range(cols):
			# V-shape: row threshold based on distance from center column
			var dist = absf(col + 0.5 - cx)
			var threshold = rows - 1 - int(dist * rows / cx) if cx > 0 else 0
			line.append(row <= threshold)
		grid.append(line)
	return grid


static func _pattern_border(cols: int, rows: int) -> Array:
	var grid = []
	for row in range(rows):
		var line = []
		for col in range(cols):
			var is_edge = row == 0 or row == rows - 1 or col == 0 or col == cols - 1
			line.append(is_edge)
		grid.append(line)
	return grid


static func _pattern_scatter(cols: int, rows: int, rng: RandomNumberGenerator) -> Array:
	var grid = []
	for row in range(rows):
		var line = []
		for col in range(cols):
			line.append(rng.randf() < 0.55)
		grid.append(line)
	return grid


static func _apply_symmetry(grid: Array, cols: int) -> void:
	# Mirror left half to right half; center column preserved on odd widths
	var half = cols / 2
	for row in grid:
		for col in range(half):
			var mirror_col = cols - 1 - col
			row[mirror_col] = row[col]


static func _assign_health(grid: Array, cols: int, rows: int, level: int) -> Array:
	# Top rows get more health, scaling up with level
	var health_grid = []
	var base_max_hp = mini(1 + level / 2, 5)
	for row in range(rows):
		var line = []
		# Row 0 (top) gets highest HP, bottom gets lowest
		var row_factor = 1.0 - float(row) / maxi(rows - 1, 1)
		var hp = maxi(1, int(ceilf(base_max_hp * (0.4 + 0.6 * row_factor))))
		for col in range(cols):
			line.append(hp if grid[row][col] else 0)
		health_grid.append(line)
	return health_grid


static func _grid_to_layout(grid: Array, health_grid: Array, cols: int, rows: int) -> BrickLayout:
	var layout = BrickLayout.new()
	layout.grid_cols = cols
	layout.grid_rows = rows
	layout.cells = []

	for row in range(rows):
		for col in range(cols):
			if grid[row][col]:
				layout.cells.append({
					"col": col,
					"row": row,
					"health": health_grid[row][col]
				})

	return layout
