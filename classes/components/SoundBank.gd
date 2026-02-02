# ABOUTME: SoundBank component — singleton holding preloaded AudioStream references keyed by name
# ABOUTME: Populated in Main._ready(), read by sound pipelines to play audio via AudioPool

class_name SoundBank extends DefaultComponent
@export var streams: Dictionary = {}
