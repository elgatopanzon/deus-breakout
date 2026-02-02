# ABOUTME: Combo component — tracks player combo count and multiplier
# ABOUTME: Singleton on DeusWorld; read/written by combo increment and decay pipelines

class_name Combo extends DefaultComponent
@export var count: int = 0
@export var timer: float = 0.0
@export var decay_window: float = 4.0
@export var multiplier: float = 1.0
