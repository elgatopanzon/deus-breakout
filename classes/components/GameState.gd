# ABOUTME: GameState component — tracks current game state as singleton on DeusWorld
# ABOUTME: Pure data container read/written by PausePipeline and PauseGuardPipeline

class_name GameState extends DefaultComponent

enum State { PLAYING, PAUSED }

@export var state: int = State.PLAYING
