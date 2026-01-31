# ABOUTME: Restart pipeline — reloads the current scene to reset game state
# ABOUTME: Signal-driven from RestartButton via DeusConfiguration

class_name RestartPipeline extends DefaultPipeline

static func _requires(): return []

static func _stage_restart(context):
	context._node.get_tree().reload_current_scene()
