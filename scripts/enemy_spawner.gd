@tool
extends Node2D
@export var enemy_scenes: Array[PackedScene] = []
@export_range(0.1, 10.0, 0.1) var min_spawn_interval: float = 1
@export_range(0.1, 10.0, 0.1) var max_spawn_interval: float = 1
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
	# choose a spawn side outside the visible world rect and a random target inside it
	if instance is Node2D:
		# compute visible world rect
		var visible = get_viewport().get_visible_rect()
		var visible_world_pos = visible.position
		var visible_world_size = visible.size
		var cam = get_viewport().get_camera_2d()
		if cam != null:
			var cam_pos = cam.global_position
			var cam_zoom = cam.zoom
			visible_world_size = visible.size * cam_zoom
			visible_world_pos = cam_pos - visible_world_size * 0.5

		# pick a random point inside visible rect as target
		var target_x = randf_range(visible_world_pos.x, visible_world_pos.x + visible_world_size.x)
		var target_y = randf_range(visible_world_pos.y, visible_world_pos.y + visible_world_size.y)
		var target_pos = Vector2(target_x, target_y)

		# pick a spawn side: 0=left,1=right,2=top,3=bottom
		var side = randi() % 4
		var margin = 48.0
		var spawn_pos = Vector2()
		match side:
			0:
				# left
				spawn_pos.x = visible_world_pos.x - margin
				spawn_pos.y = randf_range(visible_world_pos.y, visible_world_pos.y + (visible_world_size.y*0.25))
			1:
				# righta
				spawn_pos.x = visible_world_pos.x + visible_world_size.x + margin
				spawn_pos.y = randf_range(visible_world_pos.y, visible_world_pos.y + (visible_world_size.y*0.25))
			2:
				# top
				spawn_pos.y = visible_world_pos.y - margin
				spawn_pos.x = randf_range(visible_world_pos.x, visible_world_pos.x + visible_world_size.x)
			#3:
				## bottom
				#spawn_pos.y = visible_world_pos.y + visible_world_size.y + margin
				#spawn_pos.x = randf_range(visible_world_pos.x, visible_world_pos.x + visible_world_size.x)

		instance.position = spawn_pos
		# provide the target position and a randomized speed to the enemy, if it supports it
		if instance.has_method("set_move_target"):
			var speed = randf_range(40.0, 120.0)
			instance.call("set_move_target", target_pos, speed)

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
