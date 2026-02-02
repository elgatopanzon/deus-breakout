# ABOUTME: Screen shake pipeline — applies decaying random camera offset each frame
# ABOUTME: Reads ScreenShake singleton; resets camera offset when shake expires

class_name ScreenShakePipeline extends DefaultPipeline

static func _requires(): return [ScreenShake]

static func _stage_apply(context):
	var shake = context.world.get_component(context.world, ScreenShake)
	if shake == null:
		return

	var camera = context._node.get_viewport().get_camera_2d()
	if camera == null:
		return

	if not shake.active:
		camera.offset = Vector2.ZERO
		return

	shake.timer -= context.world.delta
	if shake.timer <= 0.0:
		shake.active = false
		camera.offset = Vector2.ZERO
		return

	var decay = shake.timer / shake.duration
	var offset_x = randf_range(-shake.intensity, shake.intensity) * decay
	var offset_y = randf_range(-shake.intensity, shake.intensity) * decay
	camera.offset = Vector2(offset_x, offset_y)
