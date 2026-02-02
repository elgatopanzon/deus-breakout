# ABOUTME: Hitstop component — tracks active hitstop effect (frame freeze on hit)
# ABOUTME: Singleton on DeusWorld; read/written by hitstop trigger and decay pipelines

class_name Hitstop extends DefaultComponent
@export var active: bool = false
@export var duration: float = 0.0
@export var timer: float = 0.0
@export var base_duration: float = 0.05
