# ABOUTME: GameState component — tracks current game state as singleton on DeusWorld
# ABOUTME: Pure data container read/written by PausePipeline and PauseGuardPipeline

class_name GameState extends DefaultComponent

enum State { STARTING, PLAYING, PAUSED, WON, LOST }

@export var state: int = State.STARTING
