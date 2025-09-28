extends CharacterBody2D

var speed = 100

@onready var muzzle: Marker2D = $Muzzle
@onready var spawn_bullet: SpawnBullet = $SpawnBullet
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# get direction
	var horizontal_dir = Input.get_axis("move_left", "move_right")
	var vertical_dir = Input.get_axis("move_forward", "move_downward")
	
	# apply movement
	if horizontal_dir:
		velocity.x = horizontal_dir * speed
	else: 
		velocity.x = 0
	if vertical_dir:
		velocity.y = vertical_dir * speed
	else: 
		velocity.y = 0
		
	move_and_slide()
	
	# clamp player within the screen
	global_position = global_position.clamp(Vector2.ZERO, get_viewport_rect().size)
	
	# shooting 
	if Input.is_action_just_pressed("shoot"):
		fire_bullet()
		
func fire_bullet() -> void:
	spawn_bullet.spawn(muzzle.global_position)

func _ready() -> void:
	add_to_group("player")

func die() -> void:
	# hide visuals and disable collision
	if animated_sprite_2d != null:
		animated_sprite_2d.visible = false
	if collision_shape != null:
		collision_shape.disabled = true
	# spawn explosion
	var exp = EXPLOSION_SCENE.instantiate()
	if exp != null:
		exp.global_position = global_position
		get_tree().current_scene.add_child(exp)
		if exp.has_signal("finished"):
			exp.finished.connect(Callable(self, "_on_explosion_finished"))
		else:
			# fallback: notify game over and free
			_call_game_over()
	else:
		_call_game_over()

func _on_explosion_finished() -> void:
	_call_game_over()

func _call_game_over() -> void:
	# inform game to show game over and then free player
	var root = get_tree().current_scene
	if root != null and root.has_method("show_game_over"):
		root.call("show_game_over")
	queue_free()
