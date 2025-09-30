extends CharacterBody2D

@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var spawn_bullet: SpawnBullet = $SpawnBullet
@onready var fire_timer: Timer = $fireTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

var HP = 3
var _move_target = null
var _move_speed: float = 80.0
var _drift_direction: Vector2 = Vector2.ZERO
var _drift_amount: float = 0.0
var _time_passed: float = 0.0
var _entered: bool = false
var _free_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	fire_timer.timeout.connect(fire_bullets)
	add_to_group("enemies")

func _process(delta: float) -> void:
	# accumulate time for oscillation/drift
	_time_passed += delta
	# destruction handled in take_damage to avoid double-scoring
	# (keep process light)
	
	pass

func take_damage(amount: int = 1) -> void:
	# reduce HP, play destroyed animation and award score when HP reaches 0
	HP -= amount
	if HP <= 0:
		# stop further actions
		fire_timer.stop()
		animated_sprite_2d.play("destroyed")
		# hide collision so no more hits
		if collision_polygon != null:
			collision_polygon.disabled = true
		# update score (find Game node)
		var root = get_tree().current_scene
		if root != null and root.has_method("add_score"):
			root.call("add_score", 100)
		# spawn explosion scene at this position and free when it finishes
		var exp = EXPLOSION_SCENE.instantiate()
		if exp != null:
			exp.global_position = global_position
			get_tree().current_scene.add_child(exp)
			# when explosion finishes, free this enemy node
			if exp.has_signal("finished"):
				exp.finished.connect(Callable(self, "_on_explosion_finished"))
			else:
				# fallback: free after short delay
				call_deferred("queue_free")
		else:
			queue_free()

func _on_explosion_finished() -> void:
	# explosion finished -> free enemy
	queue_free()

func set_move_target(target: Vector2, speed: float = 80.0) -> void:
	# called by spawner to tell the enemy where to go and how fast
	_move_target = target
	_move_speed = speed
	# small random lateral drift to make movement less linear
	_drift_amount = randf_range(0.0, 30.0)
	var angle = randf_range(0.0, PI * 2.0)
	_drift_direction = Vector2(cos(angle), sin(angle))
	_entered = false
	_free_velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if _move_target != null:
		var dir = (_move_target - global_position)
		var distance = dir.length()
		if distance > 4.0:
			dir = dir.normalized()
			# apply slight perpendicular drift that oscillates with time
			var perp = Vector2(-dir.y, dir.x)
			# use _time_passed to create a smooth oscillation; scale to get a similar period
			var drift = perp * _drift_amount * sin(_time_passed * 3.3333) # ~300ms period -> 1/0.3 = 3.333
			var new_velocity = (dir * _move_speed) + drift
			# assign to CharacterBody2D velocity and call move_and_slide()
			velocity = new_velocity
			move_and_slide()
		else:
			# reached target: switch to free movement state
			_move_target = null
			_entered = true
			# pick random free velocity (direction) while preserving a similar speed
			var ang = randf_range(0.0, TAU)
			var speed = randf_range(40.0, 100.0)
			_free_velocity = Vector2(cos(ang), sin(ang)) * speed
			velocity = _free_velocity
			move_and_slide()
			return

	# if in free movement state, move and constrain to visible viewport
	if _entered:
		# move
		velocity = _free_velocity
		move_and_slide()

		# ensure we stay within the visible rect; reflect velocity at edges
		var visible = get_viewport().get_visible_rect()
		var visible_world_pos = visible.position
		var visible_world_size = visible.size
		var cam = get_viewport().get_camera_2d()
		if cam != null:
			var cam_pos = cam.global_position
			var cam_zoom = cam.zoom
			visible_world_size = visible.size * cam_zoom
			visible_world_pos = cam_pos - visible_world_size * 0.5

		# small margin so enemies don't get stuck half-offscreen
		var margin = 8.0
		var min_x = visible_world_pos.x + margin
		var max_x = visible_world_pos.x + visible_world_size.x - margin
		var min_y = visible_world_pos.y + margin
		var max_y = visible_world_pos.y + visible_world_size.y - margin

		var changed = false
		if global_position.x < min_x:
			global_position.x = min_x
			_free_velocity.x = abs(_free_velocity.x)
			changed = true
		elif global_position.x > max_x:
			global_position.x = max_x
			_free_velocity.x = -abs(_free_velocity.x)
			changed = true

		if global_position.y < min_y:
			global_position.y = min_y
			_free_velocity.y = abs(_free_velocity.y)
			changed = true
		elif global_position.y > max_y:
			global_position.y = max_y
			_free_velocity.y = -abs(_free_velocity.y)
			changed = true

		if changed:
			# update velocity on reflection
			velocity = _free_velocity
			move_and_slide()

func fire_bullets() -> void:
	spawn_bullet.spawn(right_muzzle.global_position)
	spawn_bullet.spawn(left_muzzle.global_position)
	
