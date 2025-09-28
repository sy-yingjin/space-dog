@tool
extends Node2D
@export var enemy_scenes: Array[PackedScene] = []
@export_range(0.1, 10.0, 0.1) var min_spawn_interval: float = 1.0
@export_range(0.1, 10.0, 0.1) var max_spawn_interval: float = 3.0
@export var spawn_area: Rect2 = Rect2(-32, -32, 320, 40) # relative to this node's global_position
@export var max_enemies: int = 5

var _current_enemies: int = 0
var _timer: Timer

func _ready() -> void:
	randomize()
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timeout)
	# if running in the editor, don't start spawning
	if Engine.is_editor_hint():
		return
	_start_timer()

func _start_timer() -> void:
	var wait = randf_range(min_spawn_interval, max_spawn_interval)
	_timer.wait_time = wait
	_timer.start()

func _on_timeout() -> void:
	if enemy_scenes.size() == 0:
		_start_timer()
		return

	if _current_enemies >= max_enemies:
		_start_timer()
		return

	var idx = randi() % enemy_scenes.size()
	var scene: PackedScene = enemy_scenes[idx]
	if scene == null:
		_start_timer()
		return

	var instance = scene.instantiate()
	# position relative to this spawner's global_position
	var local_x = randf() * spawn_area.size.x + spawn_area.position.x
	var local_y = randf() * spawn_area.size.y + spawn_area.position.y
	if instance is Node2D:
		var world_pos = global_position + Vector2(local_x, local_y)
		# clamp to viewport visible rect (convert canvas coords to world coords)
		var visible = get_viewport().get_visible_rect()
		# Default: treat visible rect as world rect (works when Camera2D is default)
		var visible_world_pos = visible.position
		var visible_world_size = visible.size
		# If there's an active Camera2D, compute visible world rect from its position and zoom
		var cam = get_viewport().get_camera_2d()
		if cam != null:
			var cam_pos = cam.global_position
			var cam_zoom = cam.zoom
			visible_world_size = visible.size * cam_zoom
			visible_world_pos = cam_pos - visible_world_size * 0.5
		# clamp to computed world visible rect
		world_pos.x = clamp(world_pos.x, visible_world_pos.x, visible_world_pos.x + visible_world_size.x)
		world_pos.y = clamp(world_pos.y, visible_world_pos.y, visible_world_pos.y + visible_world_size.y)
		instance.position = world_pos

	# add to the current active scene root
	var root = get_tree().current_scene
	if root == null:
		root = get_tree().get_root()
	root.add_child(instance)

	_current_enemies += 1
	# when the enemy is removed from the scene tree, decrement counter
	instance.connect("tree_exited", Callable(self, "_on_enemy_exited"))

	_start_timer()

func _on_enemy_exited() -> void:
	_current_enemies = max(0, _current_enemies - 1)
