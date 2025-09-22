extends CharacterBody2D

var speed = 100

@onready var muzzle: Marker2D = $Muzzle
@onready var spawn_bullet: SpawnBullet = $SpawnBullet


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
