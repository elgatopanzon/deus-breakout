# ABOUTME: Object pool for GPU particle nodes, keyed by scene resource path
# ABOUTME: Acquire/release pattern avoids per-event instantiation across particle pipelines

class_name ParticlePool extends DefaultComponent

# pools[scene_path] = Array of inactive GPUParticles2D nodes
var pools: Dictionary = {}
# scene_root: Node that owns all pooled particle children
var scene_root: Node = null

## Pre-allocate count instances of the given scene, parented to root.
func preallocate(scene: PackedScene, root: Node, count: int) -> void:
	scene_root = root
	var path = scene.resource_path
	if not pools.has(path):
		pools[path] = []
	for i in count:
		var node = scene.instantiate()
		node.emitting = false
		node.visible = false
		root.add_child(node)
		pools[path].append(node)

## Return an inactive particle node for the given scene, or instantiate fallback.
## Bumps an epoch counter on the node to invalidate stale timer callbacks.
func acquire(scene: PackedScene) -> GPUParticles2D:
	var path = scene.resource_path
	if pools.has(path):
		var pool: Array = pools[path]
		for i in range(pool.size() - 1, -1, -1):
			var entry = pool[i]
			if is_instance_valid(entry) and not entry.visible:
				entry.visible = true
				entry.set_meta("pool_epoch", entry.get_meta("pool_epoch", 0) + 1)
				return entry
	# Pool exhausted -- fallback instantiation
	push_warning("ParticlePool: pool exhausted for %s, allocating" % path)
	var node = scene.instantiate()
	node.visible = true
	node.set_meta("pool_epoch", 0)
	if scene_root:
		scene_root.add_child(node)
	if not pools.has(path):
		pools[path] = []
	pools[path].append(node)
	return node

## Schedule release after the particle's lifetime + margin.
## Uses epoch to ignore stale callbacks from previous acquire cycles.
func release_after(node: GPUParticles2D, delay: float) -> void:
	if not is_instance_valid(node):
		return
	var tree = node.get_tree() if node.is_inside_tree() else (scene_root.get_tree() if scene_root else null)
	if tree == null:
		return
	var epoch = node.get_meta("pool_epoch", 0)
	tree.create_timer(delay).timeout.connect(_deferred_release.bind(node, epoch))

func _deferred_release(node: GPUParticles2D, epoch: int) -> void:
	if not is_instance_valid(node):
		return
	if node.get_meta("pool_epoch", 0) != epoch:
		return
	node.emitting = false
	node.visible = false
	node.position = Vector2.ZERO
