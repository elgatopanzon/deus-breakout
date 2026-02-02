# ABOUTME: Screen shake pipeline — applies decaying random camera offset each frame
# ABOUTME: Reads ScreenShake singleton; resets camera offset when shake expires

class_name ScreenShakePipeline extends DefaultPipeline

static func _requires(): return [ScreenShake]

static func _stage_apply(context):
	var camera = context._node.get_viewport().get_camera_2d()
	if camera == null:
		return

	if not context.ScreenShake.active:
		camera.offset = Vector2.ZERO
		return

	context.ScreenShake.timer -= context.world.delta
	if context.ScreenShake.timer <= 0.0:
		context.ScreenShake.active = false
		camera.offset = Vector2.ZERO
		return

	var decay = context.ScreenShake.timer / context.ScreenShake.duration
	var offset_x = randf_range(-context.ScreenShake.intensity, context.ScreenShake.intensity) * decay
	var offset_y = randf_range(-context.ScreenShake.intensity, context.ScreenShake.intensity) * decay
	camera.offset = Vector2(offset_x, offset_y)
