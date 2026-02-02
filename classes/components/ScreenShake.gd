# ABOUTME: ScreenShake component — holds screen shake state as singleton on DeusWorld
# ABOUTME: Written by ShakeTriggerPipeline, consumed by ScreenShakePipeline

class_name ScreenShake extends DefaultComponent
@export var intensity: float = 0.0
@export var duration: float = 0.0
@export var timer: float = 0.0
@export var active: bool = false
