# ABOUTME: Touch zone component — stores direction and pressed state for a touch region
# ABOUTME: Attached to invisible Control nodes that define left/right touch areas

class_name TouchZone extends DefaultComponent
@export var direction: float = 0.0
@export var pressed: bool = false
