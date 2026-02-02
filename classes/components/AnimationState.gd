# ABOUTME: AnimationState component — tracks whether a transition tween is active
# ABOUTME: Singleton on DeusWorld; prevents overlapping animations

class_name AnimationState extends DefaultComponent
@export var transitioning: bool = false
