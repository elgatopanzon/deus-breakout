# ABOUTME: Static helper providing O(1) audio player allocation from the AudioPool
# ABOUTME: Maintains a free-list populated once; players return via finished signal

class_name AudioPoolHelper

static var _free_players: Array = []
static var _initialized: bool = false

static func _ensure_init(pool: Node) -> void:
	if _initialized:
		return
	_initialized = true
	for player in pool.get_children():
		if player is AudioStreamPlayer:
			_free_players.append(player)
			player.finished.connect(_on_player_finished.bind(player))

static func _on_player_finished(player: AudioStreamPlayer) -> void:
	if player not in _free_players:
		_free_players.append(player)

## Returns a free AudioStreamPlayer or null if all busy.
static func acquire(pool: Node) -> AudioStreamPlayer:
	_ensure_init(pool)
	while _free_players.size() > 0:
		var player = _free_players.pop_back()
		if not player.playing:
			return player
	return null

## Convenience: acquire a player, assign stream, and play. Returns true on success.
static func play(pool: Node, stream: AudioStream) -> bool:
	var player = acquire(pool)
	if player == null:
		return false
	player.stream = stream
	player.play()
	return true

## Reset state (call on scene reload to avoid stale references)
static func reset() -> void:
	_free_players.clear()
	_initialized = false
