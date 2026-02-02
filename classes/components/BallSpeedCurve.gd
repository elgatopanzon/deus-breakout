# ABOUTME: BallSpeedCurve component — tracks ball speed progression over game lifetime
# ABOUTME: Singleton on DeusWorld; read/written by speed curve pipeline

class_name BallSpeedCurve extends DefaultComponent
@export var base_speed: float = 400.0
@export var max_speed: float = 700.0
@export var ramp_rate: float = 15.0
@export var elapsed: float = 0.0
