extends CharacterBody2D

@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var spawn_bullet: SpawnBullet = $SpawnBullet
@onready var fire_timer: Timer = $fireTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var HP = 100

func _ready() -> void:
	fire_timer.timeout.connect(fire_bullets)

func _process(delta: float) -> void:
	
	
	if HP <= 0:
		animated_sprite_2d.play("destroyed")
		# update score
		# self destruct
		queue_free()
	
	pass

func fire_bullets() -> void:
	spawn_bullet.spawn(right_muzzle.global_position)
	spawn_bullet.spawn(left_muzzle.global_position)
	
